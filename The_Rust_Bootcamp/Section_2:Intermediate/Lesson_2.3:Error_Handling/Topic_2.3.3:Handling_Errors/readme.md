# **Topic 2.3.3: Handling Errors**

Errors are an expected part of real-world software, particularly when dealing with user input, external systems, or fallible operations. Rust treats error handling as an explicit design concern, providing structured mechanisms to propagate, transform, handle, or intentionally discard errors. Mastery of these patterns enables robust systems that fail predictably and recover gracefully.

## **Learning Objectives**

- Propagate errors safely using idiomatic Rust patterns and understand when to use `?` vs explicit `match`
- Transform error types while preserving intent, context, and correctness across system boundaries
- Decide when errors should be handled, propagated, discarded, or converted based on abstraction layers
- Manage multiple failure modes using structured error types and custom error enums
- Implement error handling in library vs application code with appropriate abstraction levels
- Design error types that communicate intent and enable precise handling at call sites

---

## **Propagating Errors**

Propagation is the most common error-handling strategy in Rust, allowing failures to be handled at an appropriate boundary rather than locally. The key principle is **deferring error handling to code that has sufficient context to respond appropriately**.

### The `?` Operator

The `?` operator returns early from a function if an error occurs. It's syntactic sugar over explicit `match` expressions but with important semantics.

- Automatically propagates `Err` or `None` variants
- Requires the function's return type to be compatible (or implement `From`)
- Eliminates boilerplate `match` expressions
- Converts error types implicitly via `From` trait implementations
- Readability improves significantly in deeply nested operations

**Basic Example:**

```rust
fn read_config(path: &str) -> Result<String, std::io::Error> {
  let contents = std::fs::read_to_string(path)?; // Direct error propagation
  Ok(contents)
}
```

**Advanced Example with Multiple Operations:**

```rust
use std::fs;
use std::io;

fn process_pipeline(input_file: &str, output_file: &str) -> Result<usize, io::Error> {
  // Each `?` propagates io::Error up the call stack
  let input = fs::read_to_string(input_file)?;
  let processed = input.lines()
    .filter(|line| !line.is_empty())
    .collect::<Vec<_>>()
    .join("\n");
  let byte_count = processed.len();
  fs::write(output_file, &processed)?;
  Ok(byte_count)
}
```

**When to Use `?` vs Explicit `match`:**

Use `?` when propagating is the intended behavior. Use explicit `match` when you need local recovery logic or want to inspect error details:

```rust
// Good: Simple propagation
fn load_data(path: &str) -> Result<Vec<u8>, std::io::Error> {
  std::fs::read(path)
}

// Good: Local recovery with explicit handling
fn load_data_with_fallback(path: &str) -> Result<Vec<u8>, std::io::Error> {
  match std::fs::read(path) {
    Ok(data) => Ok(data),
    Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
      // Specific recovery for missing files
      Ok(Vec::new())
    }
    Err(e) => Err(e), // Propagate other errors
  }
}
```

---

## **Mapping Errors**

Error mapping transforms one error type into another before propagation. This is essential for maintaining abstraction boundaries and enabling consistent error models across system layers.

### Inline Mapping with `.map_err()`

Use `.map_err()` to transform error types while preserving context:

```rust
use std::num::ParseIntError;

fn parse_number(input: &str) -> Result<u32, String> {
  input.parse::<u32>()
    .map_err(|e: ParseIntError| format!("Invalid number: {e}"))
}
```

**More Sophisticated Example:**

```rust
use std::fmt;

#[derive(Debug)]
struct ParseError {
  original: String,
  position: usize,
  reason: String,
}

impl fmt::Display for ParseError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    write!(f, "Parse error at position {}: {} (input: {})", 
         self.position, self.reason, self.original)
  }
}

fn parse_config_value(input: &str, expected: &str) -> Result<i32, ParseError> {
  input.parse::<i32>()
    .map_err(|_| ParseError {
      original: input.to_string(),
      position: 0,
      reason: format!("Expected {}, got invalid input", expected),
    })
}
```

### Mapping via `From` Trait

Implementing `From` enables implicit error conversion when using `?`. This is the idiomatic approach for error propagation across abstraction layers:

```rust
use std::io;
use std::num::ParseIntError;

#[derive(Debug)]
enum AppError {
  Io(io::Error),
  Parse(ParseIntError),
  Validation(String),
}

impl From<io::Error> for AppError {
  fn from(err: io::Error) -> Self {
    AppError::Io(err)
  }
}

impl From<ParseIntError> for AppError {
  fn from(err: ParseIntError) -> Self {
    AppError::Parse(err)
  }
}

impl fmt::Display for AppError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      AppError::Io(e) => write!(f, "IO error: {}", e),
      AppError::Parse(e) => write!(f, "Parse error: {}", e),
      AppError::Validation(msg) => write!(f, "Validation error: {}", msg),
    }
  }
}
```

**Using `From` for Clean Propagation:**

```rust
fn load_and_parse_config(path: &str) -> Result<i32, AppError> {
  // io::Error automatically converts to AppError via `?`
  let content = std::fs::read_to_string(path)?;
  
  // ParseIntError automatically converts to AppError via `?`
  let value: i32 = content.trim().parse()?;
  
  Ok(value)
}
```

---

## **Library-Level Error Handling**

For library code, use `thiserror` crate for ergonomic error definitions:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum LibraryError {
  #[error("IO error: {0}")]
  Io(#[from] std::io::Error),
  
  #[error("Parse error: {0}")]
  Parse(#[from] ParseIntError),
  
  #[error("Invalid configuration: {0}")]
  InvalidConfig(String),
}

pub fn library_function(path: &str) -> Result<i32, LibraryError> {
  let content = std::fs::read_to_string(path)?;
  let value: i32 = content.trim().parse()?;
  Ok(value)
}
```

---

## **Discarding Errors**

In some cases, errors can be acknowledged and safely discarded after corrective action. This should be **deliberate and well-justified**.

- Appropriate only when failure is truly non-critical
- Should be documented with comments explaining why
- Consider logging before discarding in production systems

**Anti-pattern - Hiding Errors:**

```rust
// DON'T: Silently ignores all errors
let value = risky_operation().unwrap_or(0);
```

**Better Pattern - Explicit Fallback:**

```rust
let value = option.or(Some(default_value()))
  .expect("Both option and fallback should succeed");
```

### Production-Grade Pattern

```rust
fn attempt_with_fallback(primary: &str) -> Result<Config, AppError> {
  match load_config(primary) {
    Ok(config) => Ok(config),
    Err(e) => {
      // Log the error for debugging
      eprintln!("Failed to load primary config: {}", e);
      
      // Attempt fallback
      load_config("default.toml")
        .map_err(|fallback_err| {
          AppError::Validation(format!(
            "Primary config failed: {}, fallback also failed: {}",
            e, fallback_err
          ))
        })
    }
  }
}
```

---

## **Multiple Error Types**

Complex systems often have multiple distinct failure modes. Modeling these explicitly enables **granular control over handling logic and precise error reporting**.

### Designing Error Enums

```rust
#[derive(Debug)]
pub enum ServiceError {
  NotFound { resource: String },
  PermissionDenied { user: String, action: String },
  Timeout { operation: String, duration_ms: u64 },
  InternalError(String),
}

impl fmt::Display for ServiceError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      ServiceError::NotFound { resource } => {
        write!(f, "Resource not found: {}", resource)
      }
      ServiceError::PermissionDenied { user, action } => {
        write!(f, "User '{}' denied permission for '{}'", user, action)
      }
      ServiceError::Timeout { operation, duration_ms } => {
        write!(f, "{} timed out after {}ms", operation, duration_ms)
      }
      ServiceError::InternalError(msg) => write!(f, "Internal error: {}", msg),
    }
  }
}
```

### Granular Error Handling

```rust
fn handle_user_request(user_id: &str, action: &str) -> Result<String, ServiceError> {
  match check_permissions(user_id, action) {
    Ok(true) => perform_action(action),
    Ok(false) => Err(ServiceError::PermissionDenied {
      user: user_id.to_string(),
      action: action.to_string(),
    }),
    Err(e) => Err(ServiceError::InternalError(e.to_string())),
  }
}

fn process_request(req: Request) -> Result<Response, ServiceError> {
  match handle_user_request(&req.user, &req.action) {
    Ok(result) => Ok(Response::success(result)),
    Err(ServiceError::NotFound { resource }) => {
      Ok(Response::not_found(resource)) // HTTP 404
    }
    Err(ServiceError::PermissionDenied { .. }) => {
      Ok(Response::forbidden()) // HTTP 403
    }
    Err(ServiceError::Timeout { .. }) => {
      Ok(Response::gateway_timeout()) // HTTP 504
    }
    Err(ServiceError::InternalError(msg)) => {
      eprintln!("Internal error: {}", msg);
      Ok(Response::internal_error()) // HTTP 500
    }
  }
}
```

### Combining Multiple Error Sources

```rust
#[derive(Error, Debug)]
pub enum DatabaseError {
  #[error("Connection failed: {0}")]
  Connection(String),
  
  #[error("Query error: {0}")]
  Query(String),
  
  #[error("Parse error: {0}")]
  Parse(#[from] serde_json::Error),
}

fn fetch_user(id: &str) -> Result<User, DatabaseError> {
  let connection = establish_connection()
    .map_err(|e| DatabaseError::Connection(e.to_string()))?;
  
  let json = connection.query_user(id)
    .map_err(|e| DatabaseError::Query(e.to_string()))?;
  
  // Parse errors automatically convert via From
  let user: User = serde_json::from_str(&json)?;
  
  Ok(user)
}
```

---

## **Effective Error Handling**

Effective error handling in production systems requires:

**1. Clear Error Semantics in Public APIs:**

- Document what errors a function can return
- Distinguish recoverable vs fatal errors
- Provide context to help callers respond appropriately

**2. Abstraction Layer Considerations:**

```rust
// Library layer: Generic, reusable error types
pub enum ParseError {
  InvalidFormat,
  UnexpectedEof,
}

// Application layer: Domain-specific errors
#[derive(Error, Debug)]
pub enum ConfigError {
  #[error("Config parse error: {0:?}")]
  Parse(ParseError),
  
  #[error("Missing required field: {0}")]
  MissingField(String),
}
```

**3. Error Recovery Strategies:**

```rust
// Retry with exponential backoff
fn fetch_with_retry<F, T, E>(mut f: F, max_retries: u32) -> Result<T, E>
where
  F: FnMut() -> Result<T, E>,
{
  let mut retries = 0;
  loop {
    match f() {
      Ok(val) => return Ok(val),
      Err(e) if retries < max_retries => {
        std::thread::sleep(std::time::Duration::from_millis(2_u64.pow(retries)));
        retries += 1;
      }
      Err(e) => return Err(e),
    }
  }
}
```

**4. Logging and Observability:**

```rust
fn operation_with_logging() -> Result<String, AppError> {
  match risky_operation() {
    Ok(result) => {
      log::info!("Operation succeeded: {}", result);
      Ok(result)
    }
    Err(e) => {
      log::error!("Operation failed: {}", e);
      Err(e)
    }
  }
}
```

---

## **Professional Applications and Implementation**

Effective error handling strategies support:

- Clean separation of concerns across system layers
- Clear failure semantics in public APIs
- Resilient systems that degrade gracefully
- Maintainable error logic as systems scale

Thoughtful decisions about propagation, transformation, and handling are critical in production Rust systems

---

## **Key Takeaways**

| Concept         | Summary                                                                    |
| --------------- | -------------------------------------------------------------------------- |
| Propagation     | `?` enables concise, safe early returns; use when caller should handle.    |
| Mapping         | Transform errors at abstraction boundaries; use `From` for implicit conv.  |
| Discarding      | Only when failure is truly non-critical; document and consider logging.    |
| Multiple Errors | Enum variants enable precise handling of distinct failure modes.           |
| Design          | Error handling is a core architectural concern requiring careful planning. |

**Senior Developer Principles:**

- Errors are data—design types that communicate intent clearly
- Propagation is the default; make explicit recovery decisions rare and justified
- Map errors at abstraction boundaries to prevent implementation details from leaking
- Every error type should answer: "What should the caller do with this?"
- Consider error handling in system design, not as an afterthought
- Use type system to guide callers toward correct error handling behavior
- Test error paths as rigorously as success paths

# **Topic 2.3.5: Third-Party Error Crates**

As Rust applications scale, manually implementing error traits, conversions, and contextual logging can become repetitive and error-prone. The Rust ecosystem provides mature third-party crates that streamline error creation, propagation, and diagnostics while preserving Rust's explicit error-handling philosophy. This topic surveys commonly used crates and clarifies when each approach is appropriate.

## **Learning Objectives**

- Understand why third-party error crates are commonly used in Rust projects
- Use derive-based tooling to reduce boilerplate in custom error types
- Apply context-rich error handling for application-level code
- Recognize advanced error stacking models for complex systems
- Choose an error-handling strategy aligned with project scope and complexity
- Implement error handling patterns that balance transparency with developer ergonomics
- Design error hierarchies that scale across architectural boundaries

---

## **Why Third-Party Error Crates Exist**

Rust's standard error traits are intentionally minimal. While powerful, they require:

- Manual `Display` and `Error` implementations
- Explicit `From` conversions for each error type combination
- Careful propagation of context across layers
- Manual source chain tracking for diagnostics

Third-party crates address these pain points while remaining compatible with Rust's core error model. The key insight is that **error handling is not a solved problem once solved**—different architectural layers, deployment contexts, and consumer expectations demand different trade-offs.

### The Abstraction Ladder Problem

In layered architectures, errors flow from low-level I/O or parsing layers up through business logic to presentation layers. Each boundary introduces decisions:

- **Should errors be typed or opaque?** Typed errors provide compile-time safety but leak implementation details. Opaque errors hide internals but sacrifice precision.
- **How much context should each layer add?** Adding too much creates noise; too little leaves debugging harder.
- **Should low-level errors be transformed or wrapped?** Transformation loses historical context; wrapping can obscure root causes.

Third-party crates provide patterns and tooling for these decisions.

---

## **The `thiserror` Crate**

`thiserror` focuses on **defining structured, typed errors** with minimal boilerplate. It is the standard for library-facing error types and domain-specific error hierarchies.

### Core Capabilities

- Provides `thiserror::Error`, a derive macro for `std::error::Error`
- Automatically implements `Debug` and `Display`
- Enables pattern-matched error handling in consuming code
- Ideal for library and domain-specific error types

### Single Error Variant

```rust
use thiserror::Error;

#[derive(Error, Debug)]
#[error("invalid input: {0}")]
struct InvalidInput(String);

// Automatically implements:
// - std::error::Error
// - std::fmt::Display
// - std::fmt::Debug

fn validate_username(name: &str) -> Result<String, InvalidInput> {
  if name.len() < 3 {
    Err(InvalidInput(format!("username '{}' is too short", name)))
  } else {
    Ok(name.to_string())
  }
}
```

### Enum-Based Error Type with Transparent Forwarding

```rust
use thiserror::Error;
use std::io;
use std::num::ParseIntError;

#[derive(Error, Debug)]
enum DataProcessingError {
  #[error("invalid input: {0}")]
  InvalidInput(String),

  #[error("parsing failed at position {position}: {reason}")]
  ParseError { position: usize, reason: String },

  #[error("io operation failed")]
  Io(#[from] io::Error),  // Automatically derives From<io::Error>

  #[error("integer parsing failed")]
  IntParse(#[from] ParseIntError),  // Allows chaining multiple source types

  #[error(transparent)]
  Other(#[from] Box<dyn std::error::Error + Send + Sync>),
}

// Usage with ? operator
fn process_data(input: &str) -> Result<i32, DataProcessingError> {
  let trimmed = input.trim();
  if trimmed.is_empty() {
    return Err(DataProcessingError::InvalidInput(
      "input cannot be empty".to_string()
    ));
  }

  // Automatically converted via From trait
  let number: i32 = trimmed.parse()?;
  Ok(number * 2)
}

#[test]
fn test_error_handling() {
  // Pattern matching on typed errors
  match process_data("") {
    Err(DataProcessingError::InvalidInput(msg)) => {
      println!("Input validation failed: {}", msg);
    }
    Err(e) => eprintln!("Other error: {}", e),
    Ok(v) => println!("Parsed: {}", v),
  }

  // Display implementation is automatic
  let err = process_data("not_a_number").unwrap_err();
  println!("Error message: {}", err);  // "integer parsing failed"
}
```

### Key Features Explained

- **`#[error("...")]`**: Defines the `Display` implementation. Supports interpolation with field names: `#[error("field is {field}")]`.
- **`transparent`**: Forwards `Display` and `source()` directly to the inner error. Use when wrapping a single error type.
- **`#[from]`**: Generates `From<T>` implementation, enabling automatic conversion with the `?` operator.
- **`#[source]`**: Explicitly marks the error chain source for introspection.

### When to Use `thiserror`

- **Libraries or reusable modules**: Consumers benefit from typed errors they can pattern-match.
- **APIs with well-defined error contracts**: Domain-specific errors clarify expected failure modes.
- **Situations requiring precise error handling**: Distinguish between recoverable vs. fatal errors at compile time.
- **Building error hierarchies**: Organize related errors in enums for clarity.

### Nested Error Hierarchies

```rust
#[derive(Error, Debug)]
enum ApiError {
  #[error("validation error")]
  Validation(#[from] ValidationError),

  #[error("database error")]
  Database(#[from] DatabaseError),

  #[error("authentication failed")]
  Auth(String),
}

#[derive(Error, Debug)]
enum ValidationError {
  #[error("field '{field}' is missing")]
  MissingField { field: String },

  #[error("invalid format: {0}")]
  InvalidFormat(String),
}

#[derive(Error, Debug)]
enum DatabaseError {
  #[error("connection failed")]
  ConnectionFailed(#[from] std::io::Error),

  #[error("query failed: {0}")]
  QueryFailed(String),
}

// Allows graceful error composition
fn create_user(name: &str) -> Result<User, ApiError> {
  validate_name(name)?;  // ValidationError converted to ApiError
  insert_in_db(name)?;   // DatabaseError converted to ApiError
  Ok(User::new(name))
}
```

---

## **The `anyhow` Crate**

`anyhow` prioritizes **ergonomics and developer productivity** over strict typing. It uses type erasure to provide a flexible error container suitable for application-level code where the caller rarely needs to handle specific error types.

### Core Design Philosophy

`anyhow` treats errors as **opaque, context-rich messages** rather than strongly-typed variants. This trades compile-time precision for runtime flexibility and reduced boilerplate.

### Basic Usage

```rust
use anyhow::{Context, Result, anyhow};

fn read_config(path: &str) -> Result<String> {
  // anyhow::Result<T> is shorthand for Result<T, anyhow::Error>
  std::fs::read_to_string(path)
    .with_context(|| format!("failed to read config at {}", path))?;
  Ok(/* ... */)
}

// Errors are opaque to callers—they see anyhow::Error
fn process_file(path: &str) -> Result<()> {
  let config = read_config(path)?;
  // Error from read_config is automatically propagated
  Ok(())
}
```

### Context Chaining and Error Creation

```rust
use anyhow::{Context, Result, anyhow, bail};
use std::fs;
use std::path::Path;

#[derive(Debug)]
struct Config {
  database_url: String,
  log_level: String,
}

fn parse_config(content: &str) -> Result<Config> {
  let lines: Vec<&str> = content.lines().collect();
  
  let database_url = lines
    .iter()
    .find(|l| l.starts_with("DATABASE_URL="))
    .map(|l| l.strip_prefix("DATABASE_URL=").unwrap().to_string())
    .ok_or_else(|| anyhow!("missing DATABASE_URL in config"))?;

  let log_level = lines
    .iter()
    .find(|l| l.starts_with("LOG_LEVEL="))
    .map(|l| l.strip_prefix("LOG_LEVEL=").unwrap().to_string())
    .unwrap_or_else(|| "INFO".to_string());

  // Validate database URL format
  if !database_url.starts_with("postgres://") && !database_url.starts_with("mysql://") {
    bail!("invalid database URL scheme: {}", database_url);
  }

  Ok(Config { database_url, log_level })
}

fn load_and_parse_config(path: &str) -> Result<Config> {
  let content = fs::read_to_string(path)
    .with_context(|| format!("could not read config file at '{}'", path))?;

  parse_config(&content)
    .with_context(|| format!("failed to parse config from '{}'", path))?;

  Ok(Config { /* ... */ })
}

fn main() -> Result<()> {
  let config = load_and_parse_config("config.toml")?;
  
  // Errors automatically display full context chain
  // Output: "failed to parse config from 'config.toml': missing DATABASE_URL in config"
  
  println!("Loaded config: {:?}", config);
  Ok(())
}
```

### Key Characteristics

- **Type erasure**: All errors become `anyhow::Error` internally, losing type information.
- **Context at error sites**: Use `.with_context(|| ...)` where errors occur, not where they're handled.
- **Backtrace support**: `anyhow` can capture and display backtraces when `RUST_BACKTRACE=1`.
- **Opaque to callers**: Consumers cannot pattern-match specific error variants—they receive a generic `anyhow::Error`.

### Context vs. Information

- **`.with_context(|| ...)`**: Adds semantic context; closure is only called if an error occurs.
- **`.context("string")`**: Adds a static string context (less preferred; use closure for lazy evaluation).
- **Display chain**: Errors print as: "context1: context2: underlying error"

### When to Use `anyhow`

- **Application-level code**: CLI tools, servers, and internal services where consumers don't need to handle specific error types.
- **Rapid development**: Minimize boilerplate when error structure is in flux.
- **Middleware and support layers**: Where errors are simply logged and propagated upward.
- **Single-binary projects**: No external consumers depending on your error types.

### When NOT to Use `anyhow`

> `anyhow` is **strongly discouraged for public libraries**, where consumers need to implement error handling logic. Opaque errors force callers to use string matching, defeating Rust's type system.

```rust
// ❌ BAD: Library returns anyhow::Error
pub fn parse_user(input: &str) -> anyhow::Result<User> {
  // Consumers cannot pattern-match specific errors
}

// ✅ GOOD: Library returns typed error
pub fn parse_user(input: &str) -> Result<User, ParseError> {
  // Consumers can handle ValidationError, FormatError, etc.
}
```

### Converting Between `anyhow` and Typed Errors

```rust
use anyhow::Result;
use thiserror::Error;

#[derive(Error, Debug)]
enum SpecificError {
  #[error("validation failed")]
  Validation(String),
  #[error("io error")]
  Io(#[from] std::io::Error),
}

// Library returns typed error
fn library_fn() -> Result<String, SpecificError> {
  Ok("data".to_string())
}

// Application wraps in anyhow for ergonomics
fn app_fn() -> Result<String> {
  let result = library_fn()
    .map_err(|e| anyhow::anyhow!("{}", e))?;
  Ok(result)
}
```

---

## **The `error-stack` Crate**

`error-stack`, developed by Hash.dev, introduces a **structured, layered error model** designed for complex systems that cross multiple architectural boundaries. It addresses the limitation that simple context chaining doesn't preserve the *evolution* of errors through system layers.

### Problem It Solves

In deeply layered architectures, errors lose context as they propagate:

```rust
// Suppose we have layers: Network → HTTP Handler → Business Logic

// Without error-stack:
// Network error: "connection refused"
// ↓ (loses context)
// HTTP handler catches it: "connection refused"
// ↓ (loses context)
// Business logic sees: "connection refused"
// → Debugger doesn't know which network operation failed or why

// With error-stack:
// Report tracks all layers, allowing introspection of the full error evolution
```

### Core Design Philosophy

Errors are built incrementally as they propagate through system boundaries, accumulating structured context and attachments at each layer. The error history is preserved, not collapsed.

---

### Key Concepts

#### Report

The central error container that wraps a base error and maintains a stack of frames showing how the error evolved.

```rust
use error_stack::Report;

// Report<E> wraps error of type E and accumulates frames
// Each frame represents a layer's context
let base_error = std::io::Error::new(std::io::ErrorKind::NotFound, "file not found");
let report = Report::new(base_error);
// Report can then be enhanced with context as it propagates upward
```

#### Frame

Each propagation step adds a new frame to the report.

##### Context

The *semantic error type* at that layer—represents the meaning of the failure in that specific abstraction.

```rust
#[derive(Debug)]
enum NetworkError {
  ConnectionFailed,
  Timeout,
}

#[derive(Debug)]
enum ApiError {
  InvalidResponse,
  NetworkFailure,
}

#[derive(Debug)]
enum ApplicationError {
  DataFetchFailed,
}

// As error propagates: NetworkError → ApiError → ApplicationError
// Each frame shows the semantic context at that boundary
```

##### Attachments

Arbitrary structured or printable data attached to a report—metadata, request IDs, environment state, etc.

```rust
struct RequestId(String);
struct UserId(u64);

// Attachments enrich error context without changing the error type
report.attach(RequestId("req-12345".to_string()));
report.attach(UserId(user_id));
```

### Imports and Core Types

```rust
use error_stack::{IntoReport, Report, Result, ResultExt};
```

- **`Report<E>`**: Container holding error of type `E` and accumulated frames
- **`Result<T, E>`**: Alias for `std::result::Result<T, Report<E>>`; Note: the error type is automatically wrapped in `Report`
- **`IntoReport`**: Trait converting standard `std::result::Result` into a `Report`
- **`ResultExt`**: Extension trait adding context, attachment, and transformation methods

---

## **Using `error-stack`**

### Creating and Converting Reports

```rust
use error_stack::{Report, IntoReport};

#[derive(Debug)]
struct NetworkError(String);

fn network_operation() -> std::result::Result<String, std::io::Error> {
  Err(std::io::Error::new(std::io::ErrorKind::ConnectionRefused, "refused"))
}

fn create_report() {
  // Create from existing error
  let err = NetworkError("connection refused".to_string());
  let report = Report::new(err);

  // Convert std::result::Result into Report
  let result: error_stack::Result<String, std::io::Error> = 
    network_operation().into_report();
}
```

### Attaching Context and Data

Context is added where errors occur, preserving the layer at which each piece of information became relevant.

```rust
use error_stack::ResultExt;

#[derive(Debug)]
enum FileError {
  ReadFailed,
  ParseFailed,
}

#[derive(Debug)]
struct UserId(u64);
#[derive(Debug)]
struct RequestId(String);

fn load_user_config(user_id: u64, request_id: &str) -> error_stack::Result<String, FileError> {
  let path = format!("/config/user_{}.toml", user_id);
  
  std::fs::read_to_string(&path)
    .into_report()
    .map_err(|_| Report::new(FileError::ReadFailed))
    .attach(UserId(user_id))
    .attach(RequestId(request_id.to_string()))
    .attach_printable(format!("attempted to read from '{}'", path))?;

  // Parse the config
  let content = std::fs::read_to_string(&path)
    .into_report()
    .map_err(|_| Report::new(FileError::ParseFailed))
    .attach(UserId(user_id))?;

  Ok(content)
}

// Attachments preserved in error chain for debugging
```

### Methods for Error Context

```rust
use error_stack::ResultExt;

result
  .attach("while loading configuration")           // Adds printable context
  .attach_opaque(user_id)                          // Adds structured data (printed with Debug)
  .attach_printable(format!("file: {}", path))    // Adds printable formatted data
  .attach_printable_lazy(|| "deferred context")   // Defers context creation
```

### Changing Error Context

Transform an error's semantic type when crossing architectural boundaries.

```rust
use error_stack::{Report, ResultExt};

#[derive(Debug)]
enum IoError {
  NotFound,
}

#[derive(Debug)]
enum DatabaseError {
  ConnectionFailed,
}

#[derive(Debug)]
enum AppError {
  DataAccessFailed,
}

fn database_connect(path: &str) -> error_stack::Result<String, IoError> {
  std::fs::read_to_string(path)
    .into_report()
    .map_err(|_| Report::new(IoError::NotFound))
}

fn app_layer() -> error_stack::Result<String, AppError> {
  database_connect("db.txt")
    .change_context(AppError::DataAccessFailed)  // Transforms IoError → AppError
}

// The original IoError is preserved in the stack; AppError is the new context
```

### Advanced Example: Layered Error Propagation

```rust
use error_stack::{Report, ResultExt, IntoReport};

#[derive(Debug)]
enum NetworkError {
  Timeout,
  Refused,
}

#[derive(Debug)]
enum HttpError {
  BadResponse,
}

#[derive(Debug)]
enum ServiceError {
  DataFetchFailed,
}

fn network_call() -> error_stack::Result<String, NetworkError> {
  Err(Report::new(NetworkError::Timeout))
    .attach_printable("connecting to 192.168.1.1:8080")
}

fn http_layer() -> error_stack::Result<String, HttpError> {
  network_call()
    .change_context(HttpError::BadResponse)  // Transform context
    .attach_printable("while parsing HTTP headers")
}

fn service_layer() -> error_stack::Result<String, ServiceError> {
  http_layer()
    .change_context(ServiceError::DataFetchFailed)  // Final transformation
    .attach_printable("user_id: 42")
}

fn main() {
  if let Err(err) = service_layer() {
    eprintln!("Error chain: {:#?}", err);
    // Shows full history: ServiceError → HttpError → NetworkError
    // With all attachments preserved
  }
}
```

### Expanding and Pushing Context

```rust
// `.expand()` when you have nested Report types
let outer_report: error_stack::Result<T, OuterError> = /* ... */;
let expanded = outer_report.expand();

// `.push()` adds additional frames to an existing report
error_report
  .push("additional context")
  .push("more context");
```

---

## **Comparison: Choosing the Right Crate**

Each crate serves a distinct architectural role:

| Crate         | Error Model      | Typing        | Use Case                                     | Observability        |
| ------------- | ---------------  | ------------- | -------------------------------------------- | -------------------- |
| `thiserror`   | Typed enum       | Compile-time  | Libraries; domain APIs; typed handling       | Pattern-matching     |
| `anyhow`      | Type-erased      | Runtime       | Applications; CLI tools; rapid development   | Context strings      |
| `error-stack` | Layered report   | Compile-time  | Complex systems; cross-boundary errors       | Full error evolution |

### Decision Matrix

```text
┌─ Is this a public library?
│  ├─ YES → use thiserror (expose typed errors to consumers)
│  └─ NO → continue
│
└─ Does the system have multiple architectural layers?
   ├─ YES, with deep error propagation → use error-stack
   └─ NO, or simple error chains → use anyhow (if internal app) or thiserror (if library)
```

---

## **Professional Applications and Implementation**

Third-party error crates enable:

- **Cleaner APIs**: Less boilerplate; focus on business logic
- **Improved observability**: Rich context and structured attachments for logging
- **Faster development**: Type-safe or ergonomic depending on crate choice
- **Safer propagation**: Error handling patterns baked into the framework

---

## **Key Takeaways**

| Concept           | Summary                                                                      |
| -------------     | ---------------------------------------------------------------------------- |
| **Motivation**    | Ecosystem crates reduce boilerplate while improving clarity and diagnostics. |
| **`thiserror`**   | Best for typed, library-facing errors; consumers pattern-match variants.     |
| **`anyhow`**      | Best for application-level ergonomics; internal services and CLI tools.      |
| **`error-stack`** | Best for complex systems needing layered context and full error evolution.   |
| **Strategy**      | Error handling tools should match system scale and architectural boundaries. |

- **Rust's ecosystem complements its explicit error model** by providing tools for different abstraction layers.
- **No single crate fits every use case**—match the tool to the architectural context.
- **Typed errors favor libraries**; opaque errors favor applications.
- **Context-rich error stacks improve debugging and reliability** by preserving error evolution.
- **Error handling is an architectural decision**, not an afterthought—plan it early.

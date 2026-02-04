# **Topic 2.3.4: Custom Errors and Logging**

This topic focuses on designing application-specific error types and integrating logging to support observability, diagnostics, and maintainability. Custom errors allow systems to communicate failure with precision, while structured logging provides insight into system behavior across development and production environments. Together, they form a critical layer of professional-grade Rust applications.

## **Learning Objectives**

- Design custom error types appropriate to application scope and error propagation patterns
- Implement the `std::error::Error` trait correctly with proper `source()` chaining
- Choose between enums, structs, or hybrid error representations based on error semantics
- Integrate logging frameworks with structured, contextual error information
- Balance clarity, security, and verbosity in error reporting across user and developer contexts
- Understand error recovery strategies and their relationship to error design
- Apply best practices for error handling in async/concurrent systems

---

## **Creating Custom Error Types**

Custom error types can be as simple or as expressive as the system requires. The choice of representation directly impacts how errors propagate, are handled, and can be diagnosed.

### Fundamental Design Considerations

- **Enums** model distinct failure categories when the type of failure determines recovery strategy
- **Structs** store structured, contextual error data when errors share common metadata
- **Hybrid designs** combine both for maximum flexibility in complex domains
- **Error semantics** should reflect whether an error is recoverable, fatal, or transient
- **Ownership semantics** matter: should errors be cloneable, reference-counted, or consumed?

The goal is to encode *what went wrong*, *why it happened*, and *what information is needed to recover* in a way that supports both immediate handling and post-mortem diagnostics.

### When to Use Enums

Enum-based errors excel when failure modes are discrete and represent genuinely different recovery paths:

```rust
use std::error::Error;
use std::fmt;
use std::io;

#[derive(Debug)]
enum DatabaseError {
  ConnectionFailed(String),
  QueryTimeout { query: String, duration_ms: u64 },
  DecodingError { row: usize, column: String, reason: String },
  ConstraintViolation { constraint: String, value: String },
  TransactionAborted,
}

impl fmt::Display for DatabaseError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      Self::ConnectionFailed(reason) => 
        write!(f, "failed to establish database connection: {}", reason),
      Self::QueryTimeout { query, duration_ms } => 
        write!(f, "query timed out after {}ms: {}", duration_ms, query),
      Self::DecodingError { row, column, reason } => 
        write!(f, "failed to decode row {} column {}: {}", row, column, reason),
      Self::ConstraintViolation { constraint, value } => 
        write!(f, "constraint violation on {}: invalid value {}", constraint, value),
      Self::TransactionAborted => 
        write!(f, "transaction was aborted"),
    }
  }
}

impl Error for DatabaseError {}
```

Each variant communicates a fundamentally different condition, enabling pattern matching for recovery:

```rust
fn handle_db_error(err: DatabaseError) -> Result<(), Box<dyn Error>> {
  match err {
    DatabaseError::QueryTimeout { .. } => {
      // Retry with exponential backoff
      Ok(())
    }
    DatabaseError::ConnectionFailed(_) => {
      // Circuit break and alert
      Err(Box::new(err))
    }
    DatabaseError::ConstraintViolation { .. } => {
      // Client error; log and return to user
      Ok(())
    }
    DatabaseError::DecodingError { .. } => {
      // Data corruption; escalate immediately
      Err(Box::new(err))
    }
    DatabaseError::TransactionAborted => {
      // Retry entire transaction
      Ok(())
    }
  }
}
```

### When to Use Structs

Struct-based errors work well when errors carry consistent, heterogeneous metadata that varies per instance:

```rust
use std::error::Error;
use std::fmt;
use std::time::SystemTime;

#[derive(Debug)]
struct ApiError {
  status_code: u16,
  error_code: String,
  message: String,
  timestamp: SystemTime,
  request_id: String,
  details: Option<serde_json::Value>,
}

impl fmt::Display for ApiError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    write!(f, "[{}] {}: {} (request: {})", 
      self.status_code, self.error_code, self.message, self.request_id)
  }
}

impl Error for ApiError {}

impl ApiError {
  fn new(status_code: u16, error_code: impl Into<String>, message: impl Into<String>, request_id: String) -> Self {
    Self {
      status_code,
      error_code: error_code.into(),
      message: message.into(),
      timestamp: SystemTime::now(),
      request_id,
      details: None,
    }
  }

  fn with_details(mut self, details: serde_json::Value) -> Self {
    self.details = Some(details);
    self
  }

  fn is_retryable(&self) -> bool {
    matches!(self.status_code, 408 | 429 | 500 | 502 | 503 | 504)
  }

  fn is_client_error(&self) -> bool {
    (400..500).contains(&self.status_code)
  }
}
```

This pattern is particularly useful for API clients where errors are instances of a service contract, not categories of failure.

### Hybrid Designs for Complex Domains

Large systems often benefit from layered error types that combine enum and struct approaches:

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum NetworkErrorKind {
  Dns(String),
  Connection { host: String, port: u16 },
  Timeout { operation: String, duration_ms: u64 },
  Tls(String),
}

#[derive(Debug)]
struct NetworkError {
  kind: NetworkErrorKind,
  context: String,
  source_error: Option<Box<dyn Error + Send + Sync>>,
  occurred_at: std::time::SystemTime,
}

impl fmt::Display for NetworkError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match &self.kind {
      NetworkErrorKind::Dns(host) => 
        write!(f, "DNS resolution failed for {}", host),
      NetworkErrorKind::Connection { host, port } => 
        write!(f, "connection to {}:{} failed", host, port),
      NetworkErrorKind::Timeout { operation, duration_ms } => 
        write!(f, "{} timed out after {}ms", operation, duration_ms),
      NetworkErrorKind::Tls(reason) => 
        write!(f, "TLS error: {}", reason),
    }?;
    write!(f, " (context: {})", self.context)
  }
}

impl Error for NetworkError {
  fn source(&self) -> Option<&(dyn Error + 'static)> {
    self.source_error.as_ref().map(|e| e.as_ref() as &(dyn Error + 'static))
  }
}

impl NetworkError {
  fn is_transient(&self) -> bool {
    matches!(self.kind, NetworkErrorKind::Timeout { .. } | NetworkErrorKind::Connection { .. })
  }

  fn is_fatal(&self) -> bool {
    matches!(self.kind, NetworkErrorKind::Tls(_))
  }
}
```

This design allows matching on error categories while preserving rich instance data.

---

## **The `Error` Trait and Error Chaining**

Rust's standard error trait defines the minimum contract for interoperable error types. Understanding its full semantics is crucial for professional error handling.

### Core Trait Definition

```rust
pub trait Error: Debug + Display {
  fn source(&self) -> Option<&(dyn Error + 'static)> {
    None
  }

  fn backtrace(&self) -> Option<&Backtrace> {
    None
  }
}
```

The trait requires only `Debug` and `Display`, but proper implementations support error chaining via `source()`.

### Basic Implementation

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct ParseError {
  line: usize,
  column: usize,
  message: String,
}

impl fmt::Display for ParseError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    write!(f, "parse error at {}:{}: {}", self.line, self.column, self.message)
  }
}

impl Error for ParseError {}
```

### Proper Error Chaining with `source()`

Professional applications must preserve the full error context through causality chains:

```rust
use std::error::Error;
use std::fmt;
use std::io;

#[derive(Debug)]
struct ConfigLoadError {
  path: String,
  source: Box<dyn Error + Send + Sync>,
}

impl fmt::Display for ConfigLoadError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    write!(f, "failed to load config from {}", self.path)
  }
}

impl Error for ConfigLoadError {
  fn source(&self) -> Option<&(dyn Error + 'static)> {
    Some(&*self.source)
  }
}

fn load_config(path: &str) -> Result<String, ConfigLoadError> {
  std::fs::read_to_string(path)
    .map_err(|e| ConfigLoadError {
      path: path.to_string(),
      source: Box::new(e),
    })
}

// Utility to walk error chain
fn print_error_chain(err: &dyn Error) {
  eprintln!("Error: {}", err);
  let mut source = err.source();
  while let Some(err) = source {
    eprintln!("Caused by: {}", err);
    source = err.source();
  }
}
```

### Working with Error Objects

```rust
fn process_file(path: &str) -> Result<String, Box<dyn Error>> {
  let content = std::fs::read_to_string(path)?;
  let parsed = serde_json::from_str(&content)?;
  Ok(parsed)
}

// Errors automatically upcast through ? operator
// io::Error and serde_json::Error become Box<dyn Error>
```

---

## **Logging Errors Effectively**

Logging is the primary mechanism for observing system behavior in production. Professional logging requires strategy, not just insertion of print statements.

### Choosing a Logging Framework

**`log` crate**: Facade-style API that abstracts logging implementation

- Lightweight, zero-cost abstractions
- Used by most Rust libraries
- Requires a concrete logger implementation (env_logger, tracing, etc.)

**`tracing` crate**: Structured, async-aware logging with span context

- Better for complex systems and distributed tracing
- Maintains execution context across async boundaries
- Integrates with OpenTelemetry for observability

**`slog` crate**: Structured, compositional logging

- Composable filters and drains
- Excellent for complex logging hierarchies

For most applications, start with `log` + `env_logger`, graduate to `tracing` as complexity grows.

### Structured Logging Example

```rust
use log::{error, warn, info, debug};
use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum DataProcessingError {
  ParseError(String),
  ValidationError { field: String, reason: String },
  StorageError(String),
}

impl fmt::Display for DataProcessingError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      Self::ParseError(msg) => write!(f, "parse error: {}", msg),
      Self::ValidationError { field, reason } => 
        write!(f, "validation failed on {}: {}", field, reason),
      Self::StorageError(msg) => write!(f, "storage error: {}", msg),
    }
  }
}

impl Error for DataProcessingError {}

fn process_user_record(record: &str) -> Result<(), DataProcessingError> {
  info!("Processing user record");
  
  let parsed = serde_json::from_str::<serde_json::Value>(record)
    .map_err(|e| {
      error!("Failed to parse JSON: {}", e);
      DataProcessingError::ParseError(e.to_string())
    })?;

  if parsed.get("email").is_none() {
    warn!("Missing email field in record");
    return Err(DataProcessingError::ValidationError {
      field: "email".to_string(),
      reason: "required field missing".to_string(),
    });
  }

  debug!("Record validation passed");
  Ok(())
}
```

### Logging Configuration

```rust
fn main() {
  env_logger::Builder::from_default_env()
    .format_timestamp_millis()
    .filter_level(log::LevelFilter::Info)
    .init();

  // RUST_LOG=debug cargo run  -- enables debug level
  // RUST_LOG=myapp=debug,other_crate=warn -- per-module control
}
```

---

## **User-Facing vs. Developer-Facing Error Reporting**

The same error must be presented differently depending on audience.

### User-Facing Error Messages

Principles:

- **Minimal and actionable**: "Please check your email address" not "validation regex match failed"
- **No internal details**: Never expose system paths, database names, or stack traces
- **No credentials or secrets**: Filter sensitive data from all user-visible output
- **Polite and non-technical**: Avoid jargon; explain what went wrong in business terms

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum UserFacingError {
  InvalidEmail,
  PasswordTooShort,
  AccountLocked,
  ServiceUnavailable,
}

impl fmt::Display for UserFacingError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      Self::InvalidEmail => write!(f, "Please enter a valid email address"),
      Self::PasswordTooShort => write!(f, "Password must be at least 12 characters"),
      Self::AccountLocked => write!(f, "Your account is temporarily locked. Try again in 15 minutes."),
      Self::ServiceUnavailable => write!(f, "Service is temporarily unavailable. Please try again later."),
    }
  }
}

impl Error for UserFacingError {}

// In handlers:
fn handle_auth_error(internal_err: &dyn Error) -> UserFacingError {
  // Internal error internals never leak to user
  error!("Authentication error: {}", internal_err);
  UserFacingError::ServiceUnavailable
}
```

### Developer-Facing Error Messages

Principles:

- **Maximum diagnostic detail**: Include timestamps, context, state
- **Structured formatting**: JSON or key=value for log aggregation
- **Full error chains**: Preserve causality for root cause analysis
- **Request/trace context**: Correlate errors across distributed systems

```rust
use log::error;
use std::error::Error;
use uuid::Uuid;

#[derive(Debug)]
struct OperationContext {
  request_id: Uuid,
  user_id: Option<u64>,
  component: String,
  operation: String,
}

fn log_developer_error(ctx: &OperationContext, err: &dyn Error) {
  error!(
    "operation_failed request_id={} user_id={:?} component={} operation={} error=\"{}\" error_chain=\"{}\"",
    ctx.request_id,
    ctx.user_id,
    ctx.component,
    ctx.operation,
    err,
    format_error_chain(err)
  );
}

fn format_error_chain(err: &dyn Error) -> String {
  let mut chain = format!("{}", err);
  let mut source = err.source();
  while let Some(e) = source {
    chain.push_str(" <- ");
    chain.push_str(&e.to_string());
    source = e.source();
  }
  chain
}
```

---

## **Error Handling in Async Contexts**

Async systems introduce complexity to error handling due to context loss across .await boundaries.

```rust
use tokio::task;
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct User {
  id: u64,
  name: String,
}

#[derive(Debug)]
struct AsyncOperationError {
  operation: String,
  reason: String,
  task_id: u64,
}

impl fmt::Display for AsyncOperationError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    write!(f, "async operation '{}' failed: {} (task: {})", 
      self.operation, self.reason, self.task_id)
  }
}

impl Error for AsyncOperationError {}

async fn fetch_user(id: u64) -> Result<User, AsyncOperationError> {
  let task_id = std::thread::current().id().as_u64().get();
  
  tokio::time::timeout(
    std::time::Duration::from_secs(5),
    async {
      // Actual fetch logic
      Ok(User { id, name: "Alice".to_string() })
    }
  )
  .await
  .map_err(|_| AsyncOperationError {
    operation: "fetch_user".to_string(),
    reason: "operation timed out".to_string(),
    task_id,
  })?
}
```

For complex async error propagation, consider `tracing` crate which maintains context across spawn boundaries.

---

## **Best Practices**

### Error Type Design

- Use enums for categorical errors where recovery differs by variant
- Use structs for errors with rich, instance-specific metadata
- Implement `Error::source()` to preserve causality chains
- Consider making errors `Send + Sync` for thread-safe propagation

### Logging Integration

- Log at decision points: when errors occur, when recovery happens
- Use structured, machine-parseable formats
- Include correlation IDs (request, trace) for distributed debugging
- Separate user-facing messaging from diagnostic logging

### Security

- Never log credentials, tokens, or personally identifiable information
- Sanitize file paths, database queries, and error messages before logging
- Filter sensitive fields when converting errors to strings
- Use different log levels for production vs. development

### Observability

- Ensure every error path is logged or explicitly handled
- Include enough context to reproduce issues from logs alone
- Use consistent error codes or error types for alerting/monitoring
- Implement error rate monitoring and anomaly detection

---

## **Professional Applications and Implementation**

Custom errors and logging support:

- Debugging complex production failures
- Auditing and monitoring system behavior
- Building observable services and APIs
- Maintaining security while preserving diagnosability

Well-designed error and logging systems scale with application complexity.

---

## **Key Takeaways**

| Concept | Summary |
| --- | --- |
| **Error Design** | Choose representation (enum/struct/hybrid) based on recovery needs and usage patterns |
| **Error Trait** | Implement `Display`, optionally `source()` for error chains and causal analysis |
| **Logging Strategy** | Separate user-facing and developer-facing contexts; use structured logging |
| **Security** | Aggressively filter sensitive data from all error output and logs |
| **Async Context** | Preserve task context and correlation IDs across .await boundaries |

- Custom errors communicate intent; they are design decisions, not implementation details
- Error chaining via `source()` preserves root cause information essential for debugging
- Structured logging and proper log levels are foundational to operational observability
- Professional systems balance diagnostic detail with security and user experience

# **Topic 2.3.1: Error Overview**

Error handling is a foundational concern in software engineering and a core design principle in Rust. Rather than treating errors as exceptional side effects, Rust models failure explicitly and enforces correct handling through its type system. This approach enables the construction of sustainable, predictable systems where failure modes are visible, intentional, and verifiable at compile time. Understanding the distinction between recoverable and unrecoverable errors is essential for writing robust, maintainable code that gracefully handles edge cases without surprising runtime behavior.

## **Learning Objectives**

- Distinguish between unrecoverable and recoverable errors in Rust, and understand the philosophical differences in how each category is handled
- Understand when and why a program should terminate versus continue safely, including trade-offs in production systems
- Recognize how Rust encodes error states using types and leverage the type system for compile-time guarantees
- Apply comprehensive safeguards to prevent unnecessary runtime failures and validate assumptions at system boundaries
- Use debugging tools effectively to inspect error-related behavior and trace control flow during development
- Design error hierarchies and custom error types that communicate intent and improve API ergonomics
- Understand panic semantics, unwinding behavior, and when to use `abort` vs `unwind` strategies

---

## **Unrecoverable Errors**

Unrecoverable errors represent conditions from which the program cannot safely continue. In Rust, these trigger a *panic*, which immediately terminates the current thread (and often the entire program). Panics are not exceptions, they don't unwind the call stack in search of a handler. Instead, they represent a contract violation: the program has entered an invalid state that contradicts the assumptions embedded in your code.

From a senior perspective, panics should be reserved for genuinely unexpected conditions: violated invariants, broken preconditions, or assertions that, if false, indicate a fundamental logic error rather than an expected runtime condition.

- Implemented via the `panic!` macro (or indirectly through operations like unwrap)
- Prints an error message and optional stack trace (in debug builds)
- Used when program invariants are violated or preconditions fail
- Indicates a logic error, invalid internal state, or unmet assumptions
- Panics propagate differently depending on the panic hook and unwinding strategy (default is unwind; can be abort)

### Common Causes

- Accessing an index outside the bounds of a collection
- Dividing by zero
- Assuming the existence of a file and accessing it directly
- Calling `unwrap()` on a `None` or `Err` value
- Failing assertions (`assert!`, `debug_assert!`)
- Thread poisoning (accessing a mutex after a panic in another thread)

### Example: Index Out of Bounds

```rust
let values = vec![1, 2, 3];
println!("{}", values[10]); // panics: thread 'main' panicked at 'index out of bounds'
```

This panic indicates a programmer error: the code assumes the vector has at least 11 elements without verifying the length first. In production, this is a logic bug.

---

## **Handling Unrecoverable Errors**

Preventing panics is often preferable in production systems, particularly in server applications where a single thread's panic should not crash the entire process.

### Defensive Programming Strategies

- **Safeguards against invalid assumptions**: Validate preconditions before executing critical operations
- **Input validation at system boundaries**: Check external inputs (file data, network packets, user input) before processing
- **Defensive checks before unsafe operations**: Use safe alternatives (`get()` instead of direct indexing) whenever possible
- **Assertions for invariants**: Use `debug_assert!` for checks that should only run in debug builds, reducing overhead in release builds

```rust
// Anti-pattern: assumes vec has 3+ elements
fn sum_first_three(values: &[i32]) -> i32 {
  values[0] + values[1] + values[2]
}

// Better: validates precondition
fn sum_first_three(values: &[i32]) -> Result<i32, String> {
  if values.len() < 3 {
    return Err("Vector must contain at least 3 elements".to_string());
  }
  Ok(values[0] + values[1] + values[2])
}

// Even better: generic over slice length
fn sum_first_three(values: &[i32]) -> Option<i32> {
  Some(values.get(0)? + values.get(1)? + values.get(2)?)
}
```

These techniques reduce the likelihood of unexpected program termination and make failure modes explicit.

---

## **Recoverable Errors**

Recoverable errors represent expected failure modes where the program can respond gracefully. These are conditions that occur under normal operation and don't indicate a logic error.

- Operations that may succeed or fail under normal conditions (file I/O, network requests, parsing)
- Failures that can be handled, reported, retried, or escalated
- Encoded explicitly in return types via `Option<T>` and `Result<T, E>`
- Allow the caller to decide how to respond

With proper design, many scenarios that would otherwise panic can be converted into recoverable errors, resulting in more resilient systems.

### Examples

- Using safe accessors (`get()`) instead of direct indexing
- Validating inputs before arithmetic operations
- Checking file existence before opening
- Parsing strings into structured data with potential validation failures

```rust
let values = vec![1, 2, 3];

// Safe access with pattern matching
match values.get(10) {
  Some(v) => println!("Value: {v}"),
  None => println!("Index out of bounds"),
}

// Or using if-let for brevity
if let Some(v) = values.get(10) {
  println!("Value: {v}");
} else {
  println!("Index out of bounds");
}
```

This approach avoids a panic and allows controlled handling. The caller knows the operation might fail and has explicit handling paths.

---

## **Error Types**

Rust represents recoverable errors using types that encode failure information in the type signature itself. This is fundamentally different from languages with exceptions—error handling is not implicit or hidden; it's visible in the API.

### Option<T>

`Option<T>` represents the presence or absence of a value:

```rust
pub enum Option<T> {
  Some(T),
  None,
}
```

Use `Option` when a value may or may not exist, but there's no additional failure information:

```rust
fn first_even(values: &[i32]) -> Option<i32> {
  values.iter().copied().find(|&x| x % 2 == 0)
}

match first_even(&[1, 3, 4, 5]) {
  Some(n) => println!("Found: {n}"),
  None => println!("No even number found"),
}
```

### Result<T, E>

`Result<T, E>` represents success (`Ok`) or failure (`Err`), with rich error information:

```rust
pub enum Result<T, E> {
  Ok(T),
  Err(E),
}
```

Use `Result` when an operation may fail and you need to communicate *why* it failed:

```rust
use std::fs;
use std::io;

fn read_file(path: &str) -> Result<String, io::Error> {
  fs::read_to_string(path)
}

match read_file("config.toml") {
  Ok(content) => println!("Config: {content}"),
  Err(e) => eprintln!("Failed to read config: {e}"),
}
```

### Error Trait

Error details are often carried by types that implement the `std::error::Error` trait:

```rust
pub trait Error: Debug + Display {
  fn source(&self) -> Option<&(dyn Error + 'static)> { None }
}
```

This trait provides:

- `Display` for human-readable error messages
- `Debug` for detailed error inspection
- `source()` for error chains (understanding root causes)
- Interoperability with the wider error-handling ecosystem

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum ConfigError {
  ParseError(String),
  MissingKey(String),
  InvalidValue { key: String, value: String },
}

impl fmt::Display for ConfigError {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    match self {
      ConfigError::ParseError(msg) => write!(f, "Parse error: {msg}"),
      ConfigError::MissingKey(key) => write!(f, "Missing required key: {key}"),
      ConfigError::InvalidValue { key, value } => {
        write!(f, "Invalid value for {key}: {value}")
      }
    }
  }
}

impl Error for ConfigError {}
```

These mechanisms enable structured, expressive error reporting without exceptions, making error handling predictable and testable.

---

## **Easy Visualization and Debugging**

Rust provides simple tools to inspect values and error states during development:

- `println!("{:?}", value)` for debug-format output (requires `Debug` trait)
- `dbg!(value)` for annotated debug printing with file and line context (returns the value for chaining)
- `eprintln!()` for writing to stderr without disrupting stdout

```rust
let result = values.get(10);
dbg!(result); // prints: [src/main.rs:42] result = None

// dbg! returns the value, so it can be chained
let number = dbg!(values.get(0).copied()).unwrap_or(0);

// For more complex debugging, use eprintln!
if let Err(e) = perform_operation() {
  eprintln!("Operation failed: {}", e);
}
```

### Custom Debug Output

For senior-level debugging, implement custom `Debug` or use `#[derive(Debug)]` with field-level control:

```rust
use std::fmt;

struct LargeData {
  id: u64,
  payload: Vec<u8>,
}

impl fmt::Debug for LargeData {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    f.debug_struct("LargeData")
      .field("id", &self.id)
      .field("payload_size", &self.payload.len())
      .finish()
  }
}
```

These tools are invaluable for understanding control flow, tracing state changes, and diagnosing error conditions during development without stepping through a debugger.

---

## **Professional Applications and Implementation**

Clear separation between recoverable and unrecoverable errors improves system robustness and maintainability:

- **Prevents crashes caused by invalid assumptions**: Explicit error handling forces developers to think through failure modes
- **Makes failure modes explicit in APIs**: Signatures communicate what can fail, improving code clarity
- **Enables safer interaction with user input and external systems**: Validates boundaries between trusted and untrusted code
- **Improves debuggability and observability during development**: Error types carry rich information for diagnostics
- **Facilitates error recovery and resilience strategies**: Allows graceful degradation rather than catastrophic failure

---

## **Key Takeaways**

| Concept              | Summary                                                                          |
| -------------------- | ------------------------------------------------------------------------------   |
| Unrecoverable Errors | Panics indicate violated invariants and terminate execution; use sparingly.      |
| Recoverable Errors   | Expected failures are encoded in types and handled explicitly and gracefully.    |
| Error Modeling       | Rust uses types (`Option`, `Result`) instead of exceptions to represent failure. |
| Prevention           | Validation, safeguards, and defensive checks reduce unnecessary panics.          |
| Debugging            | Built-in macros and traits simplify inspecting error states and control flow.    |
| Error Traits         | Custom error types implementing `Error` enable rich error reporting.             |

- Rust enforces intentional error handling through its type system; errors cannot be silently ignored
- Panics signal bugs and violated contracts; recoverable errors signal expected failure modes
- Proper API design converts many potential panics into explicit, recoverable errors
- Explicit error modeling leads to safer, more maintainable, and more observable systems
- Senior developers use the type system to make failure modes obvious and handle them systematically

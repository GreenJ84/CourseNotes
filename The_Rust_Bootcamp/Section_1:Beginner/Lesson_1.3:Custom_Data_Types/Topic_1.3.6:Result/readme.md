# **Topic 1.3.6: Result**

`Result` is a core enum in Rust's standard library used to represent operations that may succeed or fail. Unlike `Option`, which models the absence of a value, `Result` encodes *recoverable errors* and forces explicit error handling. It is a central pillar of Rust's reliability model and a defining feature of production-grade Rust systems.

## **Learning Objectives**

- Understand what `Result` represents and how it differs from `Option`  
- Use `Ok` and `Err` to model success and failure explicitly  
- Identify appropriate scenarios for returning `Result`  
- Recognize safety risks when assuming a `Result` is successful  
- Apply safe patterns for handling and propagating errors  
- Define custom error types using enums  
- Chain operations with combinators for ergonomic error handling

---

## **What Are Results**

`Result<T, E>` is defined as:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

Where `T` is the success type and `E` is the error type. This generic design allows flexibility in both success and failure representations.

### `Ok` and `Err`

- `Ok(T)` represents a successful outcome with a value of type `T`
- `Err(E)` represents a recoverable error with a value of type `E`
- Errors are values, not exceptions—they follow the type system

```rust
fn parse_number(input: &str) -> Result<i32, std::num::ParseIntError> {
    input.parse::<i32>()
}
```

### When to Use `Result`

- An operation can fail in a meaningful way with recoverable errors
- The caller should decide how to handle failure (delegation of responsibility)
- Errors contain useful information for the caller to make decisions
- Use `Option` only when absence of a value, not error details, matters

```rust
let value = parse_number("42");  // Returns Result<i32, ParseIntError>
```

### Result vs Option

| Aspect | Result | Option |
| --- | --- | --- |
| Represents | Success or error | Some value or none |
| Error info | Detailed error | No information |
| Use case | Fallible operations | Absence/presence |

---

## **Result Safety Concerns**

### Working with the Assumption It's `Ok`

- Assuming success without handling errors is unsafe and violates Rust's guarantees
- The compiler enforces explicit handling—unused `Result` values trigger warnings

```rust
let result: Result<i32, &str> = Err("invalid input");
// let x = result + 1; // ❌ type error: can't operate on Result directly
// let x = result.unwrap(); // ⚠️ panics at runtime
```

### Unsafe Unwrapping

- `.unwrap()` extracts the value or panics if an `Err` is encountered
- Suitable only when failure is logically impossible
- Should be documented or avoided in production code

```rust
let value = parse_number("42").unwrap(); // ⚠️ panics on error
// Only safe if you guarantee the input is always valid
```

### The `?` Operator (Error Propagation)

The `?` operator provides ergonomic error propagation:

```rust
fn double(input: &str) -> Result<i32, std::num::ParseIntError> {
    let n = input.parse::<i32>()?;  // Early return if Err
    Ok(n * 2)
}
```

This is equivalent to:

```rust
fn double(input: &str) -> Result<i32, std::num::ParseIntError> {
    match input.parse::<i32>() {
        Ok(n) => Ok(n * 2),
        Err(e) => Err(e),  // Early return
    }
}
```

> **Advanced Insight:**
> The `?` operator automatically converts error types using the `From` trait, enabling seamless error propagation across different error types.

---

## **Safely Opening Results**

### `if let` – Single Path Handling

- Useful when only one outcome matters; ignores the other
- Less verbose than `match` for single-case scenarios

```rust
if let Ok(n) = parse_number("42") {
    println!("Parsed: {}", n);
}
// Err case is silently ignored
```

### `match` – Exhaustive Pattern Matching

- Exhaustively handles both success and failure
- Enforced by the compiler—all branches must be addressed

```rust
match parse_number("abc") {
    Ok(n) => println!("Parsed: {}", n),
    Err(e) => println!("Error: {}", e),
}
```

### Safe Unwrapping Practices

Combinators provide ergonomic and safe error handling without panics:

```rust
// Default value on error
let value = parse_number("abc").unwrap_or(0);

// Computed default
let value = parse_number("abc").unwrap_or_else(|_| 0);

// Transform success value
let doubled = parse_number("42").map(|n| n * 2);

// Chain operations, short-circuit on error
let result = parse_number("42")
    .map(|n| n * 2)
    .map(|n| n + 1);

// Transform error type
let result = parse_number("abc").map_err(|_| "parse failed");
```

Common combinator methods:

| Method | Purpose |
| --- | --- |
| `map(f)` | Transform success value |
| `and_then(f)` | Chain operations returning `Result` |
| `unwrap_or(default)` | Provide fallback value |
| `unwrap_or_else(f)` | Compute fallback value |
| `map_err(f)` | Transform error type |
| `ok()` | Convert `Result<T, E>` to `Option<T>` |

---

## **Custom Result Errors**

### Error Enums

Custom error types allow precise, domain-specific error modeling:

```rust
#[derive(Debug)]
enum ConfigError {
    MissingField(String),
    InvalidValue { field: String, reason: String },
    IoError(std::io::Error),
}
```

Using the custom error:

```rust
fn load_config(value: Option<&str>) -> Result<String, ConfigError> {
    match value {
        Some(v) if !v.is_empty() => Ok(v.to_string()),
        Some(_) => Err(ConfigError::InvalidValue {
            field: "config".to_string(),
            reason: "empty string".to_string(),
        }),
        None => Err(ConfigError::MissingField("config".to_string())),
    }
}
```

### Benefits of Custom Errors

- **Clarity**: Error types document what can go wrong
- **Pattern matching**: Handle specific errors differently
- **Type safety**: Compiler enforces error handling
- **Composability**: Errors integrate naturally with the `From` trait and error conversion

> **Advanced Insight:**
> Custom error enums are the foundation for implementing `std::error::Error` trait, enabling sophisticated error handling in libraries and applications.

---

## **Professional Applications and Implementation**

`Result` is ubiquitous in professional Rust codebases. It enables:

- **Predictable error handling**: No silent failures or exceptions
- **Explicit control flow**: Errors become visible in function signatures
- **Robust APIs**: Callers understand what can fail
- **Testability**: Error cases are explicit and testable
- **Resilience**: Systems gracefully handle failures

By modeling failure explicitly and avoiding panics in production code, developers create systems that are resilient, maintainable, and suitable for critical infrastructure, distributed systems, and embedded applications.

---

## **Key Takeaways**

| Concept | Summary |
| --- | --- |
| `Result<T, E>` | Encodes success (`Ok`) and recoverable failure (`Err`) |
| `Ok` / `Err` | Replace exceptions with explicit, type-safe outcomes |
| `?` operator | Ergonomic error propagation with early returns |
| Unsafe practices | `.unwrap()` panics; use only when failure is impossible |
| Safe handling | Use `match`, `if let`, and combinators |
| Custom errors | Domain-specific enums improve clarity and robustness |

**Core Principles:**

- Errors are values in Rust, not exceptions
- Safe error handling is enforced at compile time
- Custom error types improve API clarity and maintainability
- Mastery of `Result` is essential for production-grade Rust


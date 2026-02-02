# **Topic 2.3.2: Results and Options**

This topic introduces `Result` and `Option`, Rust's primary mechanisms for modeling fallible behavior and absence of values. These enums form the foundation of recoverable error handling and are used extensively across the standard library and ecosystem. While similar in structure, each serves a distinct semantic purpose, enabling APIs to communicate intent clearly and enforce correct handling at compile time.

## **Learning Objectives**

- Differentiate between `Result` and `Option` and their intended use cases
- Use pattern matching and conditional constructs to handle outcomes safely
- Convert between `Result` and `Option` when integrating with external APIs
- Avoid unsafe unwrapping patterns that lead to runtime panics
- Leverage combinator methods for ergonomic error handling and composition
- Understand type-driven design principles for resilient APIs

---

## **Results**

`Result<T, E>` represents an operation that may succeed or fail, carrying either a success value (`Ok`) or an error value (`Err`). The type parameter `E` should communicate meaningful error context, whether through custom error types, standard library errors, or error handling crates like `anyhow` and `thiserror`.

- `Ok(T)` indicates successful completion with a value of type `T`
- `Err(E)` indicates a recoverable failure with error details of type `E`
- Commonly used when failure information matters and clients need to respond differently based on error type
- Forces explicit error handling at compile time, eliminating silent failures

```rust
fn utility_function(arg: bool) -> Result<usize, String> {
  if arg {
    Ok(42)
  } else {
    Err("argument was false".to_string())
  }
}

fn main() {
  match utility_function(true) {
    Ok(value) => println!("Success: {}", value),
    Err(e) => eprintln!("Failed: {}", e),
  }
}
```

### Inspecting and Matching Results

```rust
let result: Result<usize, String> = Ok(42);

result.is_ok();  // true if Ok
result.is_err(); // true if Err

// Pattern matching is the idiomatic approach
match result {
  Ok(value) => {
    println!("Operation succeeded with value: {}", value);
  }
  Err(error) => {
    eprintln!("Operation failed: {}", error);
  }
}
```

### Conditional Handling with `if let`

```rust
let result: Result<usize, String> = Ok(42);

// Extract success path only
if let Ok(value) = result {
  println!("Handling success: {}", value);
}

// Extract error path only
if let Err(error) = result {
  eprintln!("Handling error: {}", error);
}
```

This approach reduces boilerplate when only one variant is relevant, improving readability without sacrificing safety.

### Combinator Methods for Ergonomic Handling

Senior Rust developers leverage combinator methods to chain operations without nesting `match` expressions:

```rust
fn parse_config(input: &str) -> Result<usize, String> {
  input
    .parse::<usize>()
    .map_err(|_| "failed to parse as number".to_string())
    .and_then(|n| {
      if n > 0 && n < 100 {
        Ok(n)
      } else {
        Err("number out of valid range".to_string())
      }
    })
}

// Chain multiple operations
let result = parse_config("42")
  .map(|n| n * 2)           // Transform Ok value
  .map_err(|e| format!("Config error: {}", e))  // Transform Err
  .or_else(|_| Ok(0))       // Provide fallback on error
  .unwrap_or(0);            // Extract with default

assert_eq!(result, 84);
```

Key combinator methods:

- `map(f)` - transform `Ok` value, pass through `Err`
- `map_err(f)` - transform `Err` value, pass through `Ok`
- `and_then(f)` - chain operations that return `Result`
- `or_else(f)` - provide fallback computation on error
- `unwrap_or(default)` - extract value or use default
- `expect(msg)` - unwrap with panic message context

---

## **Option**

`Option<T>` represents the presence or absence of a value, without error semantics. Use `Option` when absence is a legitimate outcome, not an error condition. This distinction is crucial for API design: absence (`None`) and error are different concerns.

- `Some(T)` indicates a value exists
- `None` indicates no value is available
- Used when absence is expected and not inherently erroneous
- Preferred over `null` references, eliminating null pointer dereferences

```rust
fn find_user(id: u32) -> Option<String> {
  let users = vec!["Alice", "Bob", "Charlie"];
  users.get(id as usize).map(|s| s.to_string())
}

fn main() {
  match find_user(0) {
    Some(name) => println!("Found user: {}", name),
    None => println!("User not found"),
  }
}
```

### Inspecting and Matching Options

```rust
let option: Option<usize> = Some(42);

option.is_some(); // true if Some
option.is_none(); // true if None

match option {
  Some(value) => {
    println!("Value exists: {}", value);
  }
  None => {
    println!("Value absent");
  }
}
```

### Conditional Handling with `if let`

```rust
let option: Option<usize> = Some(42);

if let Some(value) = option {
  println!("Using value: {}", value);
}
```

### Advanced Option Patterns

Combine options with iterators for powerful functional patterns:

```rust
let values = vec![Some(1), None, Some(3), None, Some(5)];

// Filter out None values and operate on Some values
let sum: usize = values
  .into_iter()
  .flatten()  // Converts Iterator<Option<T>> to Iterator<T>
  .map(|n| n * 2)
  .sum();

assert_eq!(sum, 18); // (1 + 3 + 5) * 2

// Working with nested Options
let nested: Option<Option<usize>> = Some(Some(42));

if let Some(Some(value)) = nested {
  println!("Deeply nested value: {}", value);
}
```

---

## **Converting Between `Result` and `Option`**

Interoperating with different APIs often requires converting between these types. Understanding conversion semantics is critical for designing composable libraries.

### `Result` → `Option` with `.ok()`

```rust
let result: Result<usize, String> = Ok(42);
let option: Option<usize> = result.ok(); // Some(42)

let result: Result<usize, String> = Err("error context".to_string());
let option: Option<usize> = result.ok(); // None
```

This conversion discards error details, preserving only success or absence. Use when error context is irrelevant downstream:

```rust
fn process_user_input(input: &str) -> Option<usize> {
  // Parse might fail, but we only care about success/absence
  input.parse().ok()
}
```

### `Option` → `Result` with `.ok_or()` and `.ok_or_else()`

```rust
let option: Option<usize> = Some(42);
let result: Result<usize, String> = option.ok_or("value was missing".to_string()); // Ok(42)

let option: Option<usize> = None;
let result: Result<usize, String> = option.ok_or("value was missing".to_string()); // Err(...)
```

For dynamic error generation, use `.ok_or_else()` to avoid unnecessary computation:

```rust
let option: Option<usize> = None;
let result: Result<usize, String> = option.ok_or_else(|| {
  // This closure only runs if option is None
  format!("Expected value at {}", chrono::Local::now())
});
```

### Bidirectional Conversions in Practice

```rust
fn validate_age(age: Option<u32>) -> Result<u32, String> {
  age
    .ok_or("age not provided".to_string())
    .and_then(|a| {
      if a >= 18 {
        Ok(a)
      } else {
        Err("must be 18 or older".to_string())
      }
    })
}

assert!(validate_age(Some(25)).is_ok());
assert!(validate_age(Some(15)).is_err());
assert!(validate_age(None).is_err());
```

---

## **Avoid Unwrapping**

Calling `unwrap()` or `expect()` on a `Result` or `Option` is inherently unsafe unless failure is impossible by construction. Production code should avoid unwrapping outside of tests and examples.

- `unwrap()` panics on `Err` or `None`
- `expect(msg)` panics with a message, slightly better but still converts recoverable errors into crashes
- Violates Rust's explicit error-handling philosophy
- Causes runtime panics in production when assumptions prove false

```rust
// AVOID THIS in production code
let value = option.unwrap(); // panics if None
let value = result.unwrap(); // panics if Err

// BETTER: Use explicit handling
let value = option.unwrap_or(default);
let value = result.expect("invariant: this should never fail");
```

### When Unwrapping Is Acceptable

Unwrapping is appropriate in specific contexts:

```rust
#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_parsing() {
    // In tests, panic on unexpected failures
    let config = parse_config("42").unwrap();
    assert_eq!(config, 42);
  }
}

fn main() {
  // In examples and demos, clarity is prioritized
  let result: Result<_, _> = "42".parse();
  let number = result.unwrap();
}
```

Real-world production outages have resulted from unchecked unwrapping in otherwise robust systems. Idiomatic Rust favors explicit handling via combinators or propagation with the `?` operator.

---

## **The Question Mark Operator (?)**

The `?` operator provides syntactic sugar for early returns on error, enabling clean error propagation without nested match statements:

```rust
fn read_config(path: &str) -> Result<usize, String> {
  let contents = std::fs::read_to_string(path)
    .map_err(|e| format!("failed to read file: {}", e))?;
  
  let value: usize = contents.trim().parse()
    .map_err(|e| format!("failed to parse: {}", e))?;
  
  if value > 0 {
    Ok(value)
  } else {
    Err("value must be positive".to_string())
  }
}

// Error propagates through call stack
fn main() -> Result<(), String> {
  let config = read_config("config.txt")?;
  println!("Config: {}", config);
  Ok(())
}
```

The `?` operator automatically converts error types when they implement `From` trait, enabling seamless interoperability across error types.

---

## **Professional Applications and Implementation**

Effective use of `Result` and `Option` enables:

- **Clear and honest API contracts** - Type signatures communicate success/failure/absence expectations
- **Safe interaction with external systems and user input** - Compile-time enforcement of error handling
- **Composable control flow** - Chainable operations without nested conditionals
- **Elimination of exception-style hidden failure paths** - No surprise panics in production
- **Type-driven design** - Let the type system guide correct implementations

These enums form the backbone of error-aware, production-grade Rust code. Design APIs that return `Result` for fallible operations and `Option` for value absence, making error handling explicit and unavoidable.

---

## **Key Takeaways**

| Concept    | Summary                                                      |
| ---------- | ------------------------------------------------------------ |
| `Result`   | Models success with `Ok(T)` or failure with `Err(E)`.        |
| `Option`   | Models presence with `Some(T)` or absence with `None`.       |
| Handling   | Pattern matching, `if let`, and combinators enable safe ops. |
| Conversion | `.ok()`, `.ok_or()`, `.ok_or_else()` bridge API boundaries.  |
| Propagation| `?` operator enables clean error propagation.                |
| Safety     | Avoid `unwrap()` except in tests; use combinators instead.   |

- `Result` and `Option` encode failure and absence explicitly in types
- Choosing the correct enum communicates API intent and forces correct handling
- Combinators like `map`, `and_then`, and `or_else` enable ergonomic composition
- The `?` operator provides clean error propagation without nesting
- Avoiding unwrap preserves Rust's reliability guarantees and production stability

# **Topic 1.1.6: Functions**

This topic introduces functions as the primary unit of abstraction and reuse in Rust. Functions in Rust emphasize explicitness, strong typing, and expression-based design. Understanding how to define, name, parameterize, and return values from functions is essential for structuring programs, encapsulating logic, and composing larger systems.

## **Learning Objectives**

- Define functions using Rust's syntax and conventions
- Apply idiomatic naming conventions
- Pass parameters with explicit types and understand ownership implications
- Return values using expressions or the `return` keyword
- Specify and reason about function return types
- Leverage function signatures for type safety and documentation

---

## **Function Definition**

Functions are defined using the `fn` keyword and serve as the building blocks of Rust programs.

```rs
fn greet() {
  println!("Hello!");
}
```

- `fn` declares a function
- The function body is enclosed in braces `{}`
- Functions may or may not return values
- All function signatures must be explicitly typed (except the body inference)

### Naming Convention

Rust uses **snake_case** for function names, improving consistency across codebases.

```rs
fn calculate_total() {}
fn process_input_data() {}
fn fetch_user_by_id() {}
```

- Lowercase letters with underscores separating words
- Improves readability and consistency
- Enforced by Rust style guidelines and tooling (`rustfmt`)
- Deviation from conventions may trigger linter warnings

### Parameters

Function parameters must have explicitly declared types. This eliminates ambiguity and enables the compiler to catch type errors at compile time.

```rs
fn add(a: i32, b: i32) {
  println!("{}", a + b);
}

fn concat_strings(s1: &str, s2: &str) -> String {
  format!("{}{}", s1, s2)
}
```

- Types are required; no implicit parameter typing
- Parameters are immutable by default
- Mutability must be explicitly declared with `mut`
- Reference types (`&T`) allow borrowing without transferring ownership

```rs
fn increment(mut value: i32) {
  value += 1;
  println!("{}", value);
}

fn modify_vec(vec: &mut Vec<i32>) {
  vec.push(42);
}
```

> **Advanced Insight:**
> Parameters participate in Rust's ownership and borrowing rules. Passing by value transfers ownership (unless the type implements `Copy`), while passing references (`&T` or `&mut T`) enables borrowing without transfer. Understanding this distinction is critical for writing efficient APIs.

---

## **Returning Values**

Rust functions return values using expressions, which is more declarative than traditional statement-based returns.

```rs
fn square(x: i32) -> i32 {
  x * x
}

fn greet_user(name: &str) -> String {
  format!("Hello, {}!", name)
}
```

- The final expression is returned implicitly (no semicolon)
- Semicolons convert expressions into statements, preventing implicit returns
- Return type must be specified with `->`

### Return Keyword

The `return` keyword allows early exits and explicit returns.

```rs
fn absolute(value: i32) -> i32 {
  if value < 0 {
    return -value;
  }
  value
}

fn validate_age(age: i32) -> bool {
  if age < 0 {
    return false;
  }
  if age > 150 {
    return false;
  }
  true
}
```

- Explicit `return` exits the function immediately
- Commonly used in conditional logic for early termination
- Less idiomatic than expression-based returns in Rust

### Return Type

Return types are specified using `->` and provide critical type safety guarantees.

```rs
fn is_even(n: i32) -> bool {
  n % 2 == 0
}

fn divide(a: f64, b: f64) -> f64 {
  a / b
}
```

- Required when returning a value
- Functions returning nothing implicitly return the unit type `()`
- Return types document function intent and enable type checking

```rs
fn log_message(msg: &str) {
  println!("{}", msg);
}
// Implicitly returns ()
```

> **Advanced Insight:**
> Rust's expression-based return model encourages concise, declarative functions and reduces the need for explicit `return` statements. This design pattern makes code more readable and aligns with functional programming principles.

---

## **Professional Applications and Implementation**

Functions are fundamental to building modular, testable Rust code. In real-world applications:

- **API Design:** Clear function signatures with explicit parameter and return types serve as self-documenting contracts
- **Performance:** Understanding ownership in function signatures helps avoid unnecessary copies
- **Concurrency:** Ownership rules in function parameters prevent data races at compile time
- **Maintainability:** Strong typing enables refactoring with compiler support

Clear naming and explicit types improve readability and maintainability in collaborative environments. Understanding ownership in function signatures becomes critical when designing APIs, performance-sensitive routines, and concurrent systems.

---

## **Key Takeaways**

| Concept    | Summary                                                                    |
| ---------- | -------------------------------------------------------------------------- |
| Definition | Functions are declared with `fn` and encapsulate logic.                    |
| Naming     | Snake_case naming ensures consistency and readability.                     |
| Parameters | Types are explicit, immutable by default, and interact with ownership.     |
| Returns    | Functions return expressions; `return` keyword for early exit.             |
| Types      | Return types are explicit and strongly enforced by the compiler.           |

- Establishes the core abstraction for Rust programs
- Encourages explicit, readable, and maintainable code
- Lays groundwork for ownership-aware API design
- Supports composition and reuse across codebases
- Provides compile-time safety guarantees through typing

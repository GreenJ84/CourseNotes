# **Topic 1.6.4: Documentation**

Documentation in Rust is a first-class concern tightly integrated with the language, tooling, and testing ecosystem. Well-written documentation communicates intent, usage, guarantees, and constraints to other developers, while also serving as executable verification of examples through doctests. This topic focuses on writing clear, intentional documentation that explains *why* and *how* code should be used, rather than restating what the code already expresses.

## **Learning Objectives**

- Understand the role of documentation in Rust codebases and its relationship to the type system
- Write effective, concise documentation without unnecessary verbosity
- Use doc comments and structured sections correctly with semantic precision
- Create testable, maintainable examples within documentation
- Generate, customize, and publish documentation using Cargo tooling
- Apply documentation patterns for complex APIs, generics, and safety guarantees
- Leverage doctests as a form of executable specification and regression prevention

---

## **Why Documentation Matters**

Rust's type system is exceptionally expressive, but it cannot capture intent, design rationale, or usage patterns. Documentation complements types by bridging the gap between what is possible and what is intended.

Effective documentation:

- Explains design decisions, trade-offs, and non-obvious constraints
- Clarifies how APIs are intended to be used and their implicit contracts
- Documents safety invariants and preconditions not expressible in the type system
- Reduces cognitive load during code review and integration
- Serves as onboarding material for new contributors and users
- Acts as an executable specification through doctests, catching regressions early
- Builds trust in public APIs by making guarantees explicit and verifiable

Poor documentation, by contrast:

- Restates obvious implementation details or reiterates type signatures
- Duplicates information already conveyed by types, trait bounds, or function names
- Becomes outdated and misleading, creating false expectations
- Forces users to read implementation source to understand usage
- Increases support burden and API misuse incidents

---

## **Writing the Right Amount of Documentation**

Documentation should be **intentional and targeted**, not exhaustive or narrative.

### Core Principles

**Document the "why" and "how," not the "what":**

- The type system already declares *what* exists; documentation explains *why* it exists and *how* to use it
- Avoid narrating control flow, variable assignments, or loop mechanics
- Focus on invariants, guarantees, and constraints that users need to know

**Example of excessive documentation:**

```rust
/// This function takes two i32 values.
/// It creates a mutable variable named result.
/// It adds a to b and stores it in result.
/// Then it returns result.
pub fn add(a: i32, b: i32) -> i32 {
  let result = a + b;  // Add the numbers
  result               // Return the sum
}
```

**Better approach:**

```rust
/// Adds two integers using saturating arithmetic.
///
/// This function wraps on overflow, ensuring no panic occurs.
/// For unchecked arithmetic, use the `wrapping_add` method directly.
pub fn add(a: i32, b: i32) -> i32 {
  a.saturating_add(b)
}
```

**Prefer idiomatic naming over explanatory comments:**

```rust
// Clear, self-documenting names
let valid_entries = entries.filter(|e| e.is_valid()).collect();

// Instead of:
// Filter to keep only entries where is_valid returns true
let ve = entries.filter(|e| e.is_valid()).collect();
```

---

## **Doc Comments and Rustdoc**

Rust uses doc comments to generate structured, browsable documentation via Rustdoc.

### Doc Comment Syntax

- `///` documents the item that immediately follows (preferred for items)
- `//!` documents the enclosing item (used at module/crate level)
- Doc comments support Markdown formatting and are compiled into HTML via `rustdoc`

### Placement and Scope

```rust
//! Module-level documentation describes the module's purpose and design.
//!
//! This crate provides utilities for safe, efficient data processing.

use std::collections::HashMap;

/// Documents the struct that immediately follows.
///
/// This struct manages cache state with thread-safe access patterns.
pub struct Cache {
  /// Internal hash map storing key-value pairs.
  /// 
  /// # Invariant
  /// This map is never directly accessed without holding the associated lock.
  data: HashMap<String, Vec<u8>>,
}

/// Documents a function.
///
/// # Parameters
/// - `key`: The cache key to retrieve
/// - `ttl`: Time-to-live in seconds; 0 means no expiration
///
/// # Returns
/// Some(value) if key exists and hasn't expired, None otherwise
///
/// # Example
/// ```
/// let cache = my_crate::Cache::new();
/// assert!(cache.get("key", 0).is_none());
/// ```
pub fn get(key: &str, ttl: u64) -> Option<Vec<u8>> {
  unimplemented!()
}
```

---

## **Structured Documentation Sections**

Rustdoc recognizes conventional Markdown section headings that organize information semantically.

### Examples

The most critical section for public APIs. Examples demonstrate typical usage patterns and serve as executable tests.

```rust
/// Attempts to parse a JSON object from a string.
///
/// # Examples
///
/// Basic parsing:
/// ```
/// use my_crate::parse_json;
///
/// let json = r#"{"name": "Alice", "age": 30}"#;
/// let result = parse_json(json)?;
/// assert_eq!(result["name"], "Alice");
/// # Ok::<(), Box<dyn std::error::Error>>(())
/// ```
///
/// Handling invalid JSON:
/// ```
/// use my_crate::parse_json;
///
/// let invalid = "{ invalid json }";
/// assert!(parse_json(invalid).is_err());
/// ```
pub fn parse_json(input: &str) -> Result<serde_json::Value, serde_json::Error> {
  serde_json::from_str(input)
}
```

**Key practices:**

- Provide minimal, focused examples that demonstrate the primary use case
- Include error cases when relevant
- Use the `#` prefix to hide boilerplate required for compilation but irrelevant to the example
- Ensure examples compile and run as part of the test suite

### Panics

Document conditions under which a function panics. Only include if panics are possible or intentional—and consider whether panicking is the right design choice.

```rust
/// Retrieves an element at the given index.
///
/// # Panics
///
/// Panics if `index` is out of bounds. Use `get(index)` for fallible access.
///
/// # Example
/// ```should_panic
/// let vec = vec![1, 2, 3];
/// let _ = vec[10]; // Panics
/// ```
pub fn index_checked(v: &[i32], index: usize) -> i32 {
  v[index]
}
```

**Senior insight:** In production code, prefer returning `Result` or `Option` over panicking. Document panics only when they're truly exceptional or when the design explicitly rejects graceful error handling.

### Errors

Document error conditions for functions returning `Result`. Be specific about what errors can occur and why.

```rust
/// Reads configuration from a file.
///
/// # Errors
///
/// Returns `ConfigError::IoFailure` if the file cannot be read.
/// Returns `ConfigError::ParseFailure` if the file is not valid TOML.
/// Returns `ConfigError::ValidationFailure` if required fields are missing.
///
/// # Example
/// ```no_run
/// use my_crate::Config;
///
/// match Config::from_file("config.toml") {
///     Ok(cfg) => println!("Loaded: {:?}", cfg),
///     Err(e) => eprintln!("Failed: {}", e),
/// }
/// ```
pub fn from_file(path: &str) -> Result<Config, ConfigError> {
  unimplemented!()
}
```

### Safety

Document safety invariants for `unsafe` code. This is critical for unsafe functions and blocks.

```rust
/// Dereferences a raw pointer without bounds checking.
///
/// # Safety
///
/// The caller must ensure:
/// - `ptr` is non-null and properly aligned for type `T`
/// - `ptr` points to a valid, initialized instance of `T`
/// - No other thread holds a mutable reference to the data
/// - The memory pointed to will not be deallocated for the duration of use
///
/// # Example
/// ```
/// let value = 42i32;
/// let ptr = &value as *const i32;
/// let result = unsafe { my_crate::deref_raw(ptr) };
/// assert_eq!(result, 42);
/// ```
pub unsafe fn deref_raw<T>(ptr: *const T) -> T
where
  T: Copy,
{
  *ptr
}
```

---

## **Doctests: Executable Specifications**

Doctests are code examples embedded in documentation that are compiled and executed during testing. They serve as regression tests and executable specifications.

### Basic Doctests

```rust
/// Computes the factorial of n.
///
/// # Examples
/// ```
/// assert_eq!(my_crate::factorial(5), 120);
/// assert_eq!(my_crate::factorial(0), 1);
/// ```
pub fn factorial(n: u32) -> u32 {
  match n {
    0 | 1 => 1,
    _ => n * factorial(n - 1),
  }
}
```

Run with `cargo test --doc`.

### Advanced Doctest Patterns

**Handling Result types:**

```rust
/// Parses a port number from a string.
///
/// # Examples
/// ```
/// use my_crate::parse_port;
///
/// let port = parse_port("8080")?;
/// assert_eq!(port, 8080);
/// # Ok::<(), Box<dyn std::error::Error>>(())
/// ```
pub fn parse_port(s: &str) -> Result<u16, std::num::ParseIntError> {
  s.parse()
}
```

**Testing panics:**

```rust
/// Panics if the slice is empty.
///
/// # Examples
/// ```should_panic
/// my_crate::first_element(&[])
/// ```
pub fn first_element(slice: &[i32]) -> i32 {
  slice[0]
}
```

**Conditional compilation:**

```rust
/// Returns the current system memory usage.
///
/// # Examples
/// ```ignore
/// let usage = my_crate::memory_usage();
/// println!("Memory: {} MB", usage);
/// ```
#[cfg(target_os = "linux")]
pub fn memory_usage() -> u64 {
  unimplemented!()
}
```

**Hiding implementation details:**

```rust
/// Demonstrates custom error handling.
///
/// # Examples
/// ```
/// # fn setup() -> Result<String, Box<dyn std::error::Error>> {
/// #     Ok("data".to_string())
/// # }
/// let data = setup()?;
/// assert!(!data.is_empty());
/// # Ok::<(), Box<dyn std::error::Error>>(())
/// ```
pub fn process(data: &str) -> Result<(), Box<dyn std::error::Error>> {
  Ok(())
}
```

---

## **Complex API Documentation**

### Generic Types and Trait Bounds

```rust
/// A generic cache with compile-time capacity guarantees.
///
/// # Type Parameters
/// - `K`: Key type; must be hashable and comparable
/// - `V`: Value type; must be cloneable
/// - `const CAPACITY`: Maximum number of entries
///
/// # Examples
/// ```
/// use my_crate::GenericCache;
///
/// let mut cache: GenericCache<String, i32, 100> = GenericCache::new();
/// cache.insert("answer".to_string(), 42);
/// assert_eq!(cache.get("answer"), Some(&42));
/// ```
pub struct GenericCache<K: std::hash::Hash + Eq, V: Clone, const CAPACITY: usize> {
  data: std::collections::HashMap<K, V>,
}
```

### Trait Documentation

```rust
/// A processor that transforms data through a pipeline.
///
/// Implementors should ensure that `process` is:
/// - **Deterministic:** Same input always produces the same output
/// - **Idempotent:** Processing twice equals processing once (when appropriate)
/// - **Thread-safe:** If used across threads, synchronization is the implementor's responsibility
///
/// # Example
/// ```
/// use my_crate::Processor;
///
/// struct UppercaseProcessor;
/// impl Processor for UppercaseProcessor {
///     fn process(&self, input: &str) -> String {
///         input.to_uppercase()
///     }
/// }
/// ```
pub trait Processor {
  fn process(&self, input: &str) -> String;
}
```

---

## **Generating and Publishing Documentation**

### Local Documentation

```bash
# Generate HTML documentation
cargo doc

# Open in default browser
cargo doc --open

# Generate without dependencies
cargo doc --no-deps
```

Generated documentation appears in `target/doc/`.

### Customizing Documentation

Create a `rustdoc.toml` or configure in `Cargo.toml`:

```toml
[package]
name = "my_crate"
version = "0.1.0"

[package.metadata.docs.rs]
all-features = true
rustdoc-args = ["--cfg", "docsrs"]
```

### Publishing to crates.io

Documentation is automatically built and hosted at `docs.rs` when you publish:

```bash
cargo publish
```

Once published, documentation becomes a versioned, public contract. Breaking changes to documented APIs should trigger a semver-major version bump.

---

## **Best Practices**

1. **Treat documentation as code:** Review it like code, version it, test it (via doctests)
2. **Keep examples minimal:** Show the happy path and key error cases; avoid exhaustive coverage
3. **Document invariants:** Explain what must remain true about data or state
4. **Link related items:** Use `[`Type`]` syntax to cross-reference other documented items
5. **Update documentation alongside code:** Outdated docs are worse than no docs
6. **Use `#[doc(hidden)]` for implementation details:** Exclude internal helper functions from public docs

---

## **Professional Applications and Implementation**

In professional Rust projects, documentation functions as both technical communication and contract definition. Clear documentation reduces onboarding time, prevents misuse, and improves API longevity. By leveraging executable examples, teams ensure that documentation evolves alongside code, maintaining correctness and trust in public interfaces.

---

## **Key Takeaways**

| Aspect | Details |
| -------- | --------- |
| **Purpose** | Explain intent, usage patterns, and non-obvious constraints beyond the type system |
| **Style** | Favor clarity and intent over verbosity or line-by-line narration |
| **Doc Comments** | `///` for items, `//!` for modules; Markdown-formatted and compiled by rustdoc |
| **Sections** | Examples, Panics, Errors, Safety, and custom headings organize information semantically |
| **Doctests** | Embedded examples compiled and tested; ensure documentation stays synchronized with code |
| **Tooling** | `cargo doc` builds, `cargo test --doc` runs tests, `docs.rs` publishes automatically |

**Core philosophy:** Documentation is a contract between implementor and user. It should explain *why* decisions were made and *how* the API should be used. The type system handles *what* exists; documentation handles intent, constraints, and design rationale.

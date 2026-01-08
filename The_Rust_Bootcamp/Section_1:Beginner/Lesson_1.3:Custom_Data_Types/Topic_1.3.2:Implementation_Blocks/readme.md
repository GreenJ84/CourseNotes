# **Topic 1.3.2: Implementation Blocks**

Implementation blocks define behavior for Rust types by associating functions and methods directly with structs, enums, and other user-defined types. They are central to Rust's approach to encapsulation, API design, and type-driven development. Through `impl` blocks, data and behavior remain tightly coupled while preserving safety, clarity, and maintainability.

## **Learning Objectives**

- Use `impl` blocks to define behavior for custom types
- Differentiate between methods and associated functions
- Understand `Self`, `self`, `&self`, and `&mut self` semantics
- Implement getters and setters idiomatically
- Apply derived implementations for common traits

---

## **Methods**

Methods are functions associated with a type that operate on an instance of that type. They enable object-oriented patterns while maintaining Rust's safety guarantees through explicit ownership and borrowing semantics in method signatures.

### `impl` Keyword

- The `impl` keyword defines an implementation block for a type
- Multiple `impl` blocks may exist for the same type (useful for organizing related functionality)
- Methods defined in `impl` blocks are invoked using dot syntax
- The compiler automatically dereferences and borrows as needed when calling methods

```rust
struct User {
  username: String,
  sign_in_count: u64,
}

// Instantiation
let user = User { username : "", sign_in_count: 1 }
```

```rust
impl User {
  fn username(&self) -> &str {
    &self.username
  }
}
// Invocation
user.username();
```

### `Self`, `self`, `&self`, and `&mut self`

- `self` represents the instance the method is called on and takes ownership
- `&self` borrows the instance immutably (read-only access)
- `&mut self` borrows the instance mutably (read and modify access)
- `Self` refers to the type itself and is often used in return types and constructors
- The choice between these determines what operations callers can perform afterward

```rust
impl User {
  fn reset(username: String) -> Self {
    Self {
      username,
      sign_in_count: 0,
    }
  }
}
```

---

## **Implementing Functionality for a Given Type**

- Methods encapsulate behavior related to the type
- Behavior evolves independently from field layout
- Methods enable polymorphic behavior without inheritance
- Well-designed methods prevent invalid state transitions

```rust
impl User {
  fn increment_sign_in_count(&mut self) {
    self.sign_in_count += 1;
  }
}
```

### Getters and Setters

- Fields are typically private to enforce encapsulation and invariants
- Public access is provided through methods
- Getters usually return references (`&T`) to avoid unnecessary cloning or ownership transfer
- Setters validate inputs before modifying state
- Not all fields require both getters and setters

```rust
impl User {
  fn sign_in_count(&self) -> u64 {
    self.sign_in_count
  }

  fn set_username(&mut self, username: String) {
    self.username = username;
  }
}
```

---

## **Associated Functions**

Associated functions are functions tied to a type but do not operate on a specific instance. They receive no implicit `self` parameter and represent type-level operations rather than instance-level operations.

- Do not take a `self` parameter (no access to instance data)
- Invoked using double-colon (`::`) syntax
- Commonly used for constructors, factory functions, and utility functions
- Enable separation of concerns and builder patterns

```rust
impl User {
  fn new(username: String) -> Self {
    Self {
      username,
      sign_in_count: 0,
    }
  }
}
```

Usage:

```rust
let user = User::new(String::from("alice"));
```

Associated functions:

- Are similar to static methods in other languages
- Help centralize construction and validation logic
- Can enforce invariants at creation time
- Support multiple constructors for different initialization patterns


---

## **Deriving Implementations**

Deriving implementations allows the compiler to automatically implement traits when possible, eliminating repetitive boilerplate while ensuring correctness.

- Rust can auto-generate implementations for common traits
- Reduces boilerplate and improves consistency
- Derived implementations follow predictable, idiomatic behavior
- The `#[derive(...)]` attribute must appear before the type definition

```rust
#[derive(Debug, Clone, PartialEq)]
struct Point {
  x: i32,
  y: i32,
}
```

### Common derived traits

- `Debug` — enables debug formatting with `{:?}`
- `Clone` — creates explicit deep copies
- `Copy` — automatically copies small values (types must be Copy-safe)
- `PartialEq`, `Eq` — enable equality comparisons
- `Hash` — enables use in hash-based collections
- `Default` — provides default value construction

```rust
#[derive(Debug, Default)]
struct Config {
  retries: u8,
  timeout_ms: u64,
}
```

Derived implementations:

- Are compile-time generated with zero runtime overhead
- Require all fields to also support the derived trait
- Encourage consistency and correctness across codebases
- Can be overridden with manual `impl` blocks for custom behavior

---

## **Professional Applications and Implementation**

Implementation blocks define the public API and behavior of Rust types. By using methods and associated functions, developers create clear abstractions that enforce invariants and reduce misuse. Derived implementations streamline development while ensuring correctness. Together, these patterns form the basis of idiomatic Rust libraries, services, and frameworks. Well-designed APIs guide users toward correct usage and prevent entire categories of bugs through the type system.

---

## **Key Takeaways**

| Concept              | Summary                                            |
| -------------------- | -------------------------------------------------- |
| `impl` Blocks        | Associate behavior directly with types.            |
| Methods              | Operate on instances using `self` semantics.       |
| Associated Functions | Provide type-level functionality and constructors. |
| Getters/Setters      | Control access to internal state safely.           |
| Derive               | Auto-generate trait implementations efficiently.   |

- Behavior and data are tightly coupled through `impl` blocks
- Mutability and ownership are explicit in method signatures
- Constructors and utilities belong in associated functions
- Deriving traits reduces boilerplate and improves reliability
- Method design is central to creating safe, ergonomic APIs

# **Topic 1.3.1: Structs**

Structs are Rust's primary mechanism for grouping related data into cohesive, named types. They enable clear domain modeling while enforcing ownership, borrowing, and visibility rules at compile time. Proper struct design is foundational to writing idiomatic, maintainable Rust and directly influences safety, encapsulation, and API clarity.

## **Learning Objectives**

- Define structs to group related data into coherent types
- Control access to struct fields using visibility modifiers
- Access struct fields safely and idiomatically
- Understand Rust's mutability rules as applied to structs
- Apply best practices for mutating struct data
- Recognize struct patterns and advanced initialization techniques

---

## **Struct Definitions**

Struct definitions allow multiple related values to be grouped into a single logical unit with named fields. Rust provides three struct variants: named-field structs, tuple structs, and unit structs.

### Grouping Data

- Structs bundle related values under a single type
- Fields can have different types
- Structs define ownership boundaries for their fields
- Each field must be explicitly named and typed

```rust
struct User {
  username: String,
  email: String,
  sign_in_count: u64,
}

// Tuple struct: lightweight grouping without field names
struct Color(u8, u8, u8);

// Unit struct: zero-sized type, useful for markers and generics
struct Marker;
```

---

## **Field Visibility**

- Fields are **private by default**
- Visibility is controlled using the `pub` keyword
- Visibility applies at the module boundary, not the file boundary
- Public structs with private fields require constructor functions

```rust
pub struct Account {
  pub id: u64,
  balance: f64,
}

impl Account {
  pub fn new(id: u64, balance: f64) -> Self {
    Account { id, balance }
  }
  
  pub fn balance(&self) -> f64 {
    self.balance
  }
}
```

In this example:

- `id` is accessible outside the module
- `balance` is private and cannot be accessed directly
- The constructor enforces invariants during initialization
- A getter method provides controlled read access

---

## **Accessing Fields**

- Field access uses dot notation
- Ownership rules apply when accessing fields
- Borrowed fields do not consume the struct

```rust
let user = User {
  username: String::from("alice"),
  email: String::from("alice@example.com"),
  sign_in_count: 1,
};

println!("{}", user.username);  // moves username
println!("{}", &user.email);     // borrows email
```

Accessing a field that owns heap data (such as `String`) may move or borrow the value depending on context. Understanding borrowing prevents unexpected moves.

---

## **Mutating Structs**

### Immutable by Default

- Struct instances are immutable unless declared `mut`
- Mutability applies to the entire struct, not individual fields
- Interior mutability patterns (`Cell`, `RefCell`) enable fine-grained mutation when needed

```rust
let mut user = User {
  username: String::from("alice"),
  email: String::from("alice@example.com"),
  sign_in_count: 1,
};

user.sign_in_count += 1;
```

### Direct Field Access Is Not Recommended

- Direct mutation exposes internal representation
- Changes to struct layout can break external code
- Encapsulation improves maintainability and correctness

A preferred approach is to expose behavior through methods:

```rust
impl User {
  fn increment_sign_in_count(&mut self) {
    self.sign_in_count += 1;
  }
  
  fn update_email(&mut self, new_email: String) -> Result<(), &str> {
    if new_email.contains('@') {
      self.email = new_email;
      Ok(())
    } else {
      Err("Invalid email")
    }
  }
}
```

This approach:

- Preserves invariants (validates email format)
- Allows validation and logging
- Prevents misuse of internal state
- Decouples the API from internal implementation

---

## **Advanced Patterns**

### Struct Update Syntax

Efficiently create new instances with partial updates:

```rust
let user2 = User {
  email: String::from("alice.new@example.com"),
  ..user
};
```

### Destructuring

Extract values from structs conveniently:

```rust
let User { username, email, .. } = user;
```

---

## **Professional Applications and Implementation**

Structs are the foundation of nearly all Rust systems, from configuration objects and database models to network messages and domain entities. Thoughtful struct design enables safe APIs, reduces invalid state representations, and improves long-term maintainability.

In production systems:

- Use private fields to enforce invariants
- Provide builder patterns for complex initialization
- Design methods to encapsulate state transitions
- Use type states to prevent invalid usage at compile time

---

## **Key Takeaways**

| Concept        | Summary                                                           |
| -------------- | ----------------------------------------------------------------- |
| Struct Purpose | Group related data into a single, named type.                     |
| Visibility     | Fields are private by default and controlled via `pub`.           |
| Field Access   | Uses dot notation and obeys ownership rules.                      |
| Mutability     | Structs must be mutable to allow field updates.                   |
| Encapsulation  | Prefer methods over direct field mutation for safety.             |
| Patterns       | Use struct update syntax and destructuring for ergonomic code.    |

- Structs define ownership and encapsulation boundaries
- Visibility is enforced at compile time, improving safety
- Mutability must be explicit and deliberate
- Method-based mutation enables robust, maintainable APIs
- Advanced patterns improve ergonomics and code clarity

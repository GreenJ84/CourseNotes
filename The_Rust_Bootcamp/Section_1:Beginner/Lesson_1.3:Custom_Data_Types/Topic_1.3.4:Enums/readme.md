# **Topic 1.3.4: Enums**

Enums (enumerations) allow a single type to represent one of several possible variants. They are a cornerstone of Rust's type system and enable expressive, safe modeling of state, options, and control flow. Unlike enums in many other languages, Rust enums can carry data and are commonly used to encode invariants directly into program structure.

## **Learning Objectives**

- Define enums with multiple variants and understand their memory representation
- Associate values and structured data with enum variants
- Implement methods and associated functions for enums
- Use pattern matching to handle all possible variants safely
- Apply enums to real-world problems like error handling and state machines

---

## **Defining Enum Variants**

Enums define a fixed set of possible values for a type.

- Each variant represents a distinct state or option
- Only one variant can be active at a time
- Variants are namespaced under the enum type
- Memory: enum stores a discriminant (tag) plus space for the largest variant

```rust
enum Direction {
  North,
  South,
  East,
  West,
}
```

### Value Mapping with Enum Variants

- Variants can be matched to values or behavior
- Prevents invalid states by construction

```rust
fn is_vertical(direction: Direction) -> bool {
  match direction {
    Direction::North | Direction::South => true,
    Direction::East | Direction::West => false,
  }
}
```

---

## **Associated Data**

Enum variants can carry data, enabling rich, expressive models. This is where Rust enums distinguish themselves from enums in languages like C or Java.

### Tuple-Like Variant Data

Variants can hold unnamed fields:

```rust
enum Message {
  Quit,
  Move(i32, i32),
  Write(String),
}
```

Each variant is effectively a different type. `Message::Move` contains two integers, while `Message::Write` contains a String.

### Struct-Like Variant Data

Variants can hold named fields for clarity:

```rust
enum Shape {
  Circle { radius: f64 },
  Rectangle { width: f64, height: f64 },
}
```

Using associated data:

```rust
let shape = Shape::Rectangle {
  width: 10.0,
  height: 5.0,
};
```

### Discriminant and Memory Layout

Rust automatically assigns each variant a discriminant. The enum's memory footprint equals the discriminant size plus the largest variant's size.

> **Advanced Insight (Beginner-Appropriate):**
> Enums with associated data act as *algebraic data types*, allowing entire state machines to be represented safely and exhaustively. This eliminates null pointer bugs and invalid state combinations.

---

## **Implementations for Enums**

Enums can have `impl` blocks just like structs, enabling encapsulation and code organization.

### Implementing Methods on Enums

- Methods can access associated data through pattern matching
- Behavior is encapsulated within the enum type
- `self` provides access to the active variant

```rust
impl Shape {
  fn area(&self) -> f64 {
    match self {
      Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
      Shape::Rectangle { width, height } => width * height,
    }
  }
}

let rect = Shape::Rectangle { width: 10.0, height: 5.0 };
println!("Area: {}", rect.area()); // Area: 50
```

### Associated Functions

- Associated functions are invoked using `::` syntax
- Often used as constructors or factory functions
- Do not take `self` as a parameter

```rust
impl Direction {
  fn all() -> [Direction; 4] {
    [
      Direction::North,
      Direction::South,
      Direction::East,
      Direction::West,
    ]
  }

  fn opposite(&self) -> Direction {
    match self {
      Direction::North => Direction::South,
      Direction::South => Direction::North,
      Direction::East => Direction::West,
      Direction::West => Direction::East,
    }
  }
}

let dirs = Direction::all();
let north = Direction::North;
println!("{:?}", north.opposite()); // South
```

---

## **Matching on Enums**

Pattern matching ensures all possible variants are handled exhaustively, preventing logic errors.

- `match` expressions must be exhaustive—all variants must be covered
- The compiler enforces correctness and warns about missing patterns
- Destructuring extracts associated data safely

```rust
fn process_message(message: Message) {
  match message {
    Message::Quit => println!("Quitting"),
    Message::Move(x, y) => println!("Moving to ({}, {})", x, y),
    Message::Write(text) => println!("Message: {}", text),
  }
}
```

Matching with references (borrowing data):

```rust
fn print_shape(shape: &Shape) {
  match shape {
    Shape::Circle { radius } => println!("Circle with radius {}", radius),
    Shape::Rectangle { width, height } => {
      println!("Rectangle {}x{}", width, height)
    }
  }
}
```

### Catch-All Patterns

For non-exhaustive matching scenarios, use `_`:

```rust
match message {
  Message::Quit => println!("Quitting"),
  _ => println!("Other message"),
}
```

> **Advanced Insight (Beginner-Appropriate):**
> Exhaustive matching is one of Rust's strongest safety guarantees, ensuring new variants cannot be added without updating all relevant logic. This eliminates the "forgot to handle case X" bug category entirely.

---

## **Professional Applications and Implementation**

Enums are ubiquitous in professional Rust code:

- **Error Handling:** The `Result<T, E>` type (success or failure) is an enum
- **Protocol Messages:** Network protocols often use enum variants for message types
- **State Machines:** Applications model workflows as enum states with transitions
- **Option Types:** The `Option<T>` enum (Some or None) replaces null pointers
- **Command Patterns:** CLI applications use enums to represent user commands

Example—simple error handling:

```rust
enum FileError {
  NotFound,
  PermissionDenied,
  ReadError(String),
}

fn read_config() -> Result<String, FileError> {
  // Implementation
}
```

---

## **Key Takeaways**

| Concept          | Summary                                         |
| ---------------- | ----------------------------------------------- |
| Enum Variants    | Represent mutually exclusive states or options. |
| Associated Data  | Attach rich data directly to variants.          |
| Enum Methods     | Encapsulate behavior alongside state.           |
| Pattern Matching | Safely handle all possible variants.            |
| Discriminant     | Internal tag identifying the active variant.    |

- Enums encode correctness directly into the type system
- Associated data enables expressive state modeling without null pointers
- `impl` blocks apply equally to enums and structs
- Exhaustive matching prevents unhandled states and missing logic
- Enums replace conditional logic with type-safe alternatives

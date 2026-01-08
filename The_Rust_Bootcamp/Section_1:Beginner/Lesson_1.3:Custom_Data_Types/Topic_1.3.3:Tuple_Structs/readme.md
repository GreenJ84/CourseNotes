# **Topic 1.3.3: Tuple Structs**

Tuple structs provide a concise way to group multiple values into a single type without naming individual fields. They are commonly used to create lightweight wrappers around existing types, improving type safety and intent while maintaining minimal syntactic overhead. Tuple structs sit between traditional structs and tuples, combining aspects of both.

## **Learning Objectives**

- Define tuple structs to group related values
- Understand how tuple structs differ from regular structs and tuples
- Use tuple structs to create lightweight, type-safe abstractions
- Recognize valid use cases for unit structs
- Apply the newtype pattern for domain-specific type safety

---

## **Tuple Structs**

Tuple structs group multiple values—potentially of different types—into a single named type.

- Fields are accessed by position rather than name
- The struct itself introduces a distinct type
- Commonly used for semantic wrappers and domain-specific types

```rust
struct Color(u8, u8, u8);
struct Point(i32, i32);
```

### Grouping Different Typed Data

- Each field may have a different type
- Ordering of fields is significant and immutable
- Type inference works with tuple structs like regular structs

```rust
struct UserId(u64);
struct Temperature(f32);
struct Coordinates(f64, f64, f64);
```

These wrappers prevent accidental misuse:

```rust
fn process_user(id: UserId) {
  println!("Processing user: {}", id.0);
}

let id = UserId(42);
// process_user(42);      // ❌ type mismatch—cannot pass u64 to UserId
process_user(id);         // ✅
```

---

## **Tuple Struct**

- Tuple structs are **not anonymous** like tuples; they have explicit names
- They are distinct types at compile time, unlike plain tuples
- They provide stronger type safety than tuples while remaining lightweight
- Tuple structs can implement traits, methods, and have visibility modifiers

```rust
struct Color(u8, u8, u8);
```

Accessing fields:

```rust
let color = Color(255, 0, 0);
println!("{}", color.0);  // Prints: 255

// Destructuring
let Color(r, g, b) = color;
println!("Red: {}, Green: {}, Blue: {}", r, g, b);
```

### The *NewType* Pattern

A common idiom using single-field tuple structs to create semantically distinct types:

```rust
struct Milliseconds(u64);
struct Seconds(u64);

fn wait(duration: Milliseconds) {
  // Cannot accidentally pass Seconds here
}

wait(Milliseconds(5000));  // ✅
// wait(Seconds(5));       // ❌ type mismatch
```

This pattern enforces domain-specific correctness without runtime overhead.

> **Advanced Insight (Beginner-Appropriate):**
> Tuple structs are frequently used to create *newtypes*, a pattern that enforces type distinctions at compile time without runtime overhead. The compiler erases these types entirely, so there is zero performance cost.

---

## **Unit Structs**

Unit structs have no fields and represent types with a single possible value.

- Rare but valid and intentional
- Zero-sized types (ZSTs)—occupy no memory at runtime
- Used for markers, configuration, trait implementations, or signaling type-level information

```rust
struct Logger;
struct Config;
```

### Use Cases

- **Marker types** for trait implementations without carrying data
- **Type tags** to distinguish behavior at compile time
- **Phantom data** in generic contexts (advanced)
- Configuration or behavior toggles without runtime state

```rust
impl Logger {
  fn log(&self, message: &str) {
    println!("LOG: {}", message);
  }
}

let logger = Logger;
logger.log("System started");
```

### Advanced Example: Marker Traits

```rust
trait Auditable {}

struct SensitiveOperation;
impl Auditable for SensitiveOperation {}

fn log_if_auditable<T: Auditable>(op: &T) {
  println!("Auditable operation performed");
}

log_if_auditable(&SensitiveOperation);
```

> **Advanced Insight (Beginner-Appropriate):**
> Unit structs occupy no memory at runtime, making them useful in generic programming and marker-pattern designs without performance cost. They enable *zero-cost abstractions*, a core Rust philosophy.

---

## **Professional Applications and Implementation**

Tuple structs and unit structs enable expressive, type-safe code patterns used extensively in production Rust:

- **API Design**: Use NewType tuple structs to make function signatures self-documenting and prevent parameter-order mistakes
- **Domain Modeling**: Create semantic types that represent business concepts (e.g., `UserId`, `EmailAddress`)
- **Performance**: Both patterns compile to the same machine code as primitives; they add only compile-time type checking
- **Library Design**: Use unit structs as marker types for type-level computation and trait implementations without memory overhead

---

## **Key Takeaways**

| Concept         | Summary                                                           |
| --------------- | ----------------------------------------------------------------- |
| Tuple Structs   | Group unnamed fields into a named, distinct type.                 |
| Type Safety     | Provide stronger guarantees than raw tuples; prevent misuse.      |
| NewYype Pattern | Single-field wrapper enforcing domain-specific meaning.           |
| Unit Structs    | Zero-sized marker or behavior types for compile-time signaling.   |
| Zero-Cost       | Both patterns compile away; no runtime performance penalty.       |

- Tuple structs combine conciseness with strong typing and clarity
- Field access is positional; destructuring is supported
- Unit structs enable zero-cost, type-level design patterns
- Both support expressive, safe Rust abstractions with no performance trade-off

# **Topic 1.2.5: Slices**

Slices are borrowed views into a contiguous sequence of elements within a collection. Rather than owning data, slices reference a portion (or the entirety) of an existing collection and provide safe, efficient access without copying. Slices are a cornerstone of Rust’s zero-cost abstraction model and play a critical role in API design, enabling flexible functions that operate over arrays, vectors, and strings while preserving ownership semantics.

Slices generalize the concept of borrowing to collections, ensuring that referenced data remains valid for the duration of the slice. This mechanism allows Rust to enforce memory safety guarantees at compile time, preventing common pitfalls such as dangling pointers and data races.

## **Learning Objectives**

- Understand slices as borrowed references to contiguous data
- Differentiate slices from owned collections
- Apply string and array slicing safely
- Reason about slice lifetimes and validity
- Use slices to design flexible, efficient APIs

---

## **What Is a Slice?**

- A slice is a **reference**, not an owner
- Points to a contiguous region of memory
- Contains:
  - A pointer to the first element
  - A length
- Enforced by the borrow checker
- Cannot outlive the data it references

Slices prevent dangling references and out-of-bounds access at compile time, ensuring that the data they reference remains valid throughout their lifetime.

---

## **String Slices**

### `&str`

- A string slice is an immutable view into UTF-8 string data
- Does not own the underlying string
- Can reference:
  - String literals
  - Heap-allocated `String` data

```rust
fn main() {
    let s = String::from("hello world");

    let hello = &s[0..5];
    let world = &s[6..11];

    println!("{hello} {world}");
}
```

### Coercion from `&String` to `&str`

Rust automatically coerces `&String` to `&str` when needed, allowing for seamless integration between owned and borrowed string types.

```rust
fn print_text(text: &str) {
    println!("{text}");
}

fn main() {
    let msg = String::from("Rust");
    print_text(&msg);
}
```

- No allocation occurs
- The slice borrows the `String` data, ensuring efficient memory usage.

⚠️ **Important Note on UTF-8**
String slicing uses **byte indices**, not character indices. Invalid slicing boundaries can lead to a runtime panic, emphasizing the importance of understanding UTF-8 encoding when working with string data.

---

## **Array and Vector Slices**

### Array Slices: `&[T]`

- Borrowed view into an array or vector
- Works for fixed-size arrays and dynamically sized vectors

```rust
fn main() {
    let numbers = [1, 2, 3, 4, 5];

    let slice = &numbers[1..4];

    println!("{:?}", slice);
}
```

### Vector Slices

```rust
fn sum(values: &[i32]) -> i32 {
    values.iter().sum()
}

fn main() {
    let v = vec![10, 20, 30, 40];
    let total = sum(&v);

    println!("{total}");
}
```

- Functions accept `&[T]` instead of `&Vec<T>`, promoting greater flexibility and reuse across different collection types.

---

## **Why Use Slices?**

- Avoids copying data, leading to performance improvements
- Preserves ownership, allowing for safe concurrent access
- Works across multiple collection types, enhancing code reusability
- Enables expressive and performant APIs that can handle various data structures

Slices are especially powerful in read-only contexts, where shared access is required without mutation, making them ideal for functional programming paradigms.

---

## **Professional Applications and Implementation**

Slices are heavily used in production Rust code to build generic, allocation-free APIs. They enable libraries to operate on caller-owned data while maintaining strict safety guarantees. String slices are foundational in text processing, configuration parsing, and web services, while array and vector slices are common in numerical computing, data pipelines, and systems programming.

By leveraging slices, developers can write code that is both ergonomic and performant without sacrificing clarity or safety. This capability is crucial in high-performance applications where efficiency and safety are paramount.

---

## **Key Takeaways**

| Concept   | Summary                                           |
| --------- | ------------------------------------------------- |
| Slices    | Borrowed views into contiguous memory regions.    |
| Ownership | Slices never own data; they borrow it.            |
| `&str`    | Immutable string slice referencing UTF-8 data.    |
| `&[T]`    | Generic slice over arrays and vectors.            |
| Safety    | Slice lifetimes and bounds are strictly enforced. |

- Slices enable zero-copy access to collections, enhancing performance.
- Ownership remains with the original collection, ensuring data integrity.
- String slicing operates on byte ranges, necessitating careful handling of UTF-8 data.
- Array and vector slices generalize collection access, promoting code reuse.
- Idiomatic Rust APIs prefer slices over concrete collection types, aligning with Rust's safety and performance goals.

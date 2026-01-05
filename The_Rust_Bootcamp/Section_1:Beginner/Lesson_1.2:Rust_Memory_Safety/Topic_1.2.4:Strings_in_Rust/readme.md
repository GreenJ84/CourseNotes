# **Topic 1.2.4: Strings in Rust**

Strings in Rust are a direct consequence of the language’s commitment to memory safety, correctness, and internationalization. Unlike many languages where strings are opaque byte sequences, Rust treats text explicitly as UTF-8–encoded data and exposes clear distinctions between owned and borrowed string types. This topic builds the conceptual and practical foundation needed to work safely and efficiently with textual data in Rust programs.

Understanding how strings relate to binary memory, encoding standards, and ownership is essential for API design, performance optimization, and avoiding subtle bugs. Rust's approach to strings not only enhances safety but also empowers developers to write more expressive and efficient code.

## **Learning Objectives**

- Understand how text is represented at the binary level
- Distinguish ASCII from UTF-8 encoding and their implications
- Explain why Rust enforces UTF-8 string validity
- Differentiate between `str`, `&str`, and `String`
- Work safely with owned and borrowed string data
- Apply idiomatic patterns for passing strings in Rust APIs

---

## **Binary Representation of Text**

- All memory is stored as **binary data** (bits and bytes)
- A byte (`u8`) represents 8 bits and can store integer values from `0–255`
- Higher-level concepts like characters and strings are built on top of raw bytes

```rust
let byte: u8 = 65;
println!("{byte}");
```

At this level, memory has no inherent meaning—it is interpretation that gives it structure. Understanding this representation is crucial for grasping how Rust manages memory and ensures safety.

---

## **ASCII (American Standard Code for Information Interchange)**

- Maps integers to characters
- Uses **7 bits** per character
- Supports **128 characters**

  - Letters, digits, punctuation, control characters
- Examples:

  - `65 → 'A'`
  - `97 → 'a'`

ASCII is simple but limited to English-centric text. Its simplicity makes it easy to use, but developers must be aware of its limitations when working with internationalization.

---

## **UTF-8 (Unicode Transformation Format – 8-bit)**

- Variable-width encoding
- Each character uses **1 to 4 bytes**
- Supports **1,112,064 Unicode code points**
- Fully **backwards compatible with ASCII**
- Multi-byte characters use recognizable leading-bit patterns

| Bytes | Pattern    |
| ----- | ---------- |
| 1     | `0xxxxxxx` |
| 2     | `110xxxxx` |
| 3     | `1110xxxx` |
| 4     | `11110xxx` |

Rust **guarantees all strings are valid UTF-8**, which prevents invalid text data from existing at runtime. This design choice significantly reduces the risk of runtime errors related to text processing.

---

## **`str` and `&str`**

### What Is `str`?

- Represents a **contiguous sequence of UTF-8 bytes**
- May live in:
  - Program binary (string literals)
  - Stack
  - Heap
- **Unsized type**
  - Its size is not known at compile time
- Cannot be used directly—only via references

### `&str`

- An immutable borrowed view into string data
- Does **not own** the data
- Very cheap to copy (pointer + length)

```rust
let s: &str = "hello";
```

Common sources of `&str`:

- String literals: `"hello"`
- Slices of `String`: `&my_string[..]`

```rust
let text = String::from("hello world");
let slice: &str = &text[0..5];

println!("{slice}");
```

### Working with `&str`

```rust
fn greet(name: &str) {
    println!("Hello, {name}");
}

fn main() {
    let owned = String::from("Rust");
    greet(&owned);
    greet("World");
}
```

- `&str` works with both string literals and `String`
- Encourages flexible, allocation-free APIs

⚠️ **Indexing strings by position is not allowed**:

```rust
// let c = text[0]; // compile-time error
```

Reason: UTF-8 characters may be multiple bytes. This restriction ensures that developers handle strings safely and correctly.

---

## **`String`**

### What Is `String`?

- Growable, mutable, **owned** UTF-8 string
- Always stored on the **heap**
- Manages its own memory
- Implements ownership semantics

Common constructors:

- `String::from("text")`
- `"text".to_string()`
- `"text".to_owned()`

```rust
let mut s = String::from("hello");
s.push_str(" world");
```

The `String` type is essential for scenarios where text needs to be modified or stored beyond its initial scope.

### Working with `String`

```rust
let mut s = String::new();
s.push('R');
s.push_str("ust");

println!("{s}");
```

Conversion between `String` and `&str`:

```rust
let s = String::from("hello");
let view: &str = &s;
```

- Borrowing a `String` as `&str` is cheap and idiomatic
- No allocation occurs during coercion, which enhances performance.

---

## **Idiomatic String API Design**

The common Rust pattern is:

- **Accept `&str`** when ownership is not required
- **Use `String`** when:

  - You must store the data
  - You must modify it
  - You must control its lifetime

```rust
fn process(input: &str) {
    println!("{input}");
}
```

This pattern:

- Maximizes flexibility
- Avoids unnecessary allocations
- Makes ownership expectations explicit

---

## **Professional Applications and Implementation**

Rust’s string model is critical for building correct, internationalized software. Enforcing UTF-8 validity at compile time eliminates entire categories of bugs related to invalid text encoding. The separation of owned and borrowed string types enables high-performance systems to manipulate text without unnecessary copying, which is essential in web servers, APIs, compilers, and data processing pipelines.

Clear string ownership semantics also improve API clarity and composability, particularly in large codebases and libraries intended for reuse. Understanding these principles is vital for any Rust developer aiming to create robust applications.

---

## **Key Takeaways**

| Concept        | Summary                                               |
| -------------- | ----------------------------------------------------- |
| Binary         | Text is ultimately represented as bytes in memory.    |
| ASCII          | Simple 7-bit encoding with limited character support. |
| UTF-8          | Variable-width Unicode encoding used by Rust.         |
| `str` / `&str` | Borrowed, immutable views into UTF-8 data.            |
| `String`       | Owned, heap-allocated, growable UTF-8 string.         |

- Rust enforces UTF-8 correctness by design
- `&str` provides efficient, borrowed access to string data
- `String` owns and manages heap-allocated text
- String slicing operates on byte ranges, not characters
- Idiomatic APIs favor `&str` unless ownership is required

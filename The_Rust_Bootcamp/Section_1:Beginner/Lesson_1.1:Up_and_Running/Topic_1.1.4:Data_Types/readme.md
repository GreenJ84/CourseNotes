# **Topic 1.1.4: Data Types**

This topic covers Rust's core data types and how they model values at compile time. Rust's type system is strict, explicit, and designed to eliminate entire classes of runtime errors by enforcing correctness during compilation. Understanding primitive, compound, and string-related types is essential for reasoning about memory layout, performance, and ownership throughout Rust programs.

## **Learning Objectives**

- Identify and use Rust's primitive data types
- Differentiate signed, unsigned, and platform-specific integers
- Understand floating-point behavior and precision
- Work with Unicode scalar values using `char`
- Distinguish between borrowed string slices and owned strings
- Use arrays and tuples for fixed-size data grouping
- Apply type aliases for readability and abstraction
- Reason about memory layout and performance implications

---

## **Boolean**

The boolean type represents logical truth values.

```rs
let is_active: bool = true;
let is_complete = false;
```

- Only two possible values: `true` and `false`
- Commonly used in conditionals and control flow
- Occupies one byte in memory
- Useful in bitwise operations and conditional expressions

---

## **Unsigned Integers (`u8` – `u64`)**

Unsigned integers represent non-negative whole numbers.

```rs
let small: u8 = 255;
let medium: u32 = 1_000;
let large: u64 = 10_000;
```

- Cannot represent negative values
- Useful for sizes, counts, and indexing
- Range: `u8` (0–255), `u16` (0–65,535), `u32` (0–4,294,967,295), `u64` (0–18,446,744,073,709,551,615)
- Overflow behavior differs between debug and release builds

> Advanced Insight:
> In debug builds, integer overflow causes a panic. In release builds, overflow wraps using two's complement arithmetic unless explicitly checked with methods like `checked_add()` or `saturating_add()`.

---

## **Signed Integers (`i8` – `i64`)**

Signed integers represent both positive and negative values.

```rs
let temperature: i32 = -10;
let delta: i64 = 42;
```

- Use two's complement representation internally
- Range: `i8` (–128–127), `i32` (–2,147,483,648–2,147,483,647)
- Default integer type is `i32`
- Suitable for values that can go below zero
- Performs symmetrically around zero with two's complement

---

## **Platform-Specific Integers (`usize`, `isize`)**

These types depend on the architecture of the target platform.

```rs
let index: usize = 0;
let offset: isize = -1;
```

- Size matches pointer width (32-bit on 32-bit platforms, 64-bit on 64-bit platforms)
- Commonly used for indexing collections and slice operations
- Required by many standard library APIs (`Vec::len()`, array indexing)
- Performance-aligned with system architecture

> Advanced Insight:
> Using `usize` for indexing ensures compatibility with pointer arithmetic and memory addressing on the target platform. This is why `Vec` and array indexing require `usize`.

---

## **Floating-Point Numbers (`f32`, `f64`)**

Floating-point types represent decimal values.

```rs
let x: f32 = 3.14;
let y: f64 = 2.71828;
```

- Follow IEEE-754 standard for binary representation
- `f64` is the default floating-point type (64-bit double precision)
- `f32` provides 32-bit single precision with lower memory footprint
- Floating-point comparisons require caution due to precision limitations
- Support special values: infinity, negative infinity, and NaN (Not a Number)

> Advanced Insight:
> Floating-point values should not be compared directly for equality in most cases; tolerance-based comparisons or epsilon methods are preferred. NaN has unique behavior: `NaN != NaN` evaluates to `true`.

---

## **Character (`char`)**

The `char` type represents a Unicode scalar value.

```rs
let letter: char = 'A';
let emoji: char = '🚀';
let newline: char = '\n';
```

- Always 4 bytes in size (32-bit)
- Can represent Unicode characters beyond ASCII (U+0000 to U+10FFFF)
- Not equivalent to a single byte; supports full Unicode range
- Useful for character manipulation and iteration

---

## **String Types (`&str`, `String`)**

Rust provides two primary string types with distinct ownership semantics.

### String Slices (`&str`)

```rs
let greeting: &str = "Hello";
let slice = &owned_string[0..5];
```

- Borrowed, immutable view into a string
- Stored in read-only memory for string literals
- Commonly used as function parameters due to flexibility
- Lightweight (two words: pointer and length)
- Cannot be modified directly

### Owned Strings (`String`)

```rs
let mut name = String::from("Rust");
name.push_str("acean");
```

- Heap-allocated and growable
- Owns and manages its data via RAII
- Required when modifying string contents or storing owned data
- Deref coerces to `&str` automatically in many contexts
- Supports methods like `push()`, `push_str()`, and `pop()`

> Advanced Insight:
> `String` and `&str` differ in ownership and mutability, not encoding. Both are UTF-8 encoded, but only `String` can be mutated and grown dynamically. `&str` derefs to `String` through `Deref` coercion.

---

## **Arrays**

Arrays store fixed-size collections of values of the same type.

```rs
let numbers: [i32; 3] = [1, 2, 3];
let zeros = [0; 5]; // Five zeros
```

- Size is known at compile time and cannot change
- Stored on the stack by default for efficient access
- Accessed via indexing with bounds checking
- Type signature includes both element type and length

```rs
let first = numbers[0];
// Bounds checking prevents out-of-bounds access
```

---

## **Tuples**

Tuples group values of different types with fixed structure.

```rs
let person: (&str, i32) = ("Alice", 30);
let point: (f64, f64, f64) = (1.0, 2.5, 3.7);
```

- Fixed size and ordered; each element has its own type
- Elements accessed by position using dot notation
- Can be destructured for convenient unpacking

```rs
let age = person.1;
let (name, years) = person;
```

- Commonly used for returning multiple values from functions
- Useful for pairing related data with different types

---

## **Type Aliasing**

Type aliases create alternative names for existing types.

```rs
type UserId = u64;
type Timestamp = u64;

let id: UserId = 42;
let time: Timestamp = 1_000_000;
```

- Improves readability and expresses intent
- Does not create a new distinct type (at compile time)
- Useful for domain-specific clarity and reducing repetition
- Aliased types are interchangeable with their underlying type

> Advanced Insight:
> Type aliases do not provide type safety because they are transparent at compile time. Newtypes (single-field tuple structs) are used when distinct, type-safe types are required.

---

## **Professional Applications and Implementation**

Choosing the correct data type is fundamental to writing efficient and safe Rust code. Integer selection impacts performance and correctness—`u32` often balances range and efficiency, while `usize` aligns with system architecture. String ownership determines memory behavior and API design, influencing whether functions accept owned data or references. Arrays and tuples support predictable memory layouts for stack efficiency, and type aliases improve code clarity in large systems without runtime overhead. These choices directly affect maintainability, safety, and interoperability in production Rust applications.

---

## **Key Takeaways**

| Type Category   | Summary                                                                      |
| --------------- | ---------------------------------------------------------------------------- |
| Booleans        | Represent logical conditions and control flow; one byte in size.             |
| Integers        | Signed, unsigned, and platform-specific types enforce correctness.           |
| Floats          | IEEE-754 compliant; use tolerance-based comparisons.                         |
| Characters      | Unicode scalar values with fixed 4-byte size.                                |
| Strings         | Ownership and mutability distinguish `String` from `&str`; both are UTF-8.   |
| Arrays & Tuples | Fixed-size, compile-time known structures for grouped data.                  |
| Aliases         | Improve readability without creating distinct types.                         |

- Rust's type system enforces correctness at compile time through explicit declarations
- Explicit type choices directly improve safety and performance optimization
- Ownership-aware string handling prevents common memory bugs and undefined behavior
- Strong typing and zero-cost abstractions provide the foundation for advanced Rust features


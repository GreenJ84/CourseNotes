# **Topic 2.4.2: Iterator Pattern**

The iterator pattern in Rust provides a unified, type-safe abstraction for traversing sequences of values. Iterators are a cornerstone of idiomatic Rust, enabling expressive, lazy, and highly optimized data processing pipelines. Rather than exposing indexing or raw loops, Rust models iteration through a trait-based interface that integrates tightly with ownership, borrowing, and zero-cost abstractions.

## **Learning Objectives**

- Understand the `Iterator` trait as Rust's core iteration abstraction
- Implement custom iterators using associated types and `next()`
- Differentiate between `Iterator` and `IntoIterator` responsibilities
- Apply correct mutability and ownership patterns during iteration
- Recognize how iterators enable lazy, performant data processing
- Master iterator combinators and understand their composition semantics
- Design custom types that integrate seamlessly with Rust's iteration ecosystem

---

## **The Iterator Trait**

The `Iterator` trait is Rust's primary abstraction for sequential data access. It defines a minimal but powerful interface that accommodates diverse iteration patterns while maintaining type safety and memory efficiency.

### Trait Definition and Fundamentals

```rust
trait Iterator {
  type Item;

  fn next(&mut self) -> Option<Self::Item>;
  
  // ... ~70 provided methods (map, filter, fold, etc.)
}
```

### Key Design Decisions

- **Associated Type Over Generic**: `type Item` is an associated type, not a generic parameter. This allows the iterator itself to determine what it yields, eliminating ambiguity in method signatures and improving type inference. The compiler can fully determine the yielded type without caller guidance.

- **Mutable Self**: `next(&mut self)` requires `&mut self`, enabling stateful iteration. The iterator maintains internal position or context that advances with each call. This design ensures thread-safety properties and clear ownership semantics.

- **Option<T> Return**: Returning `Option<Self::Item>` provides a natural termination signal. `None` indicates exhaustion without requiring additional sentinel values or error handling complexity.

**Core Characteristics:**

- Iteration ends when `next()` returns `None`
- Each iterator implementation has exactly one concrete `Item` type
- The iterator controls order of traversal, borrowing/ownership semantics, and termination behavior
- Most standard collections implement iteration support: `Vec`, `HashMap`, `BTreeMap`, slices, and custom types

### Practical Example: Stateful Iteration

```rust
struct Counter {
  current: u32,
  max: u32,
}

impl Iterator for Counter {
  type Item = u32;

  fn next(&mut self) -> Option<Self::Item> {
    if self.current < self.max {
      self.current += 1;
      Some(self.current)
    } else {
      None
    }
  }
}

fn main() {
  let counter = Counter { current: 0, max: 3 };
  
  for num in counter {
    println!("{}", num); // Prints: 1, 2, 3
  }
}
```

**Why This Matters**: The iterator's mutable state allows complex traversal patterns without external coordination. Each call to `next()` produces a consistent, predictable result based on internal state.

---

## **The IntoIterator Trait**

`IntoIterator` is the bridge between data structures and iteration. It defines how a type is converted into an iterator, enabling `for` loops and explicit `.into_iter()` calls.

### Trait Contract

```rust
trait IntoIterator {
  type Item;
  type IntoIter: Iterator<Item = Self::Item>;

  fn into_iter(self) -> Self::IntoIter;
}
```

**Key Insight**: `IntoIterator` consumes `self` by value, making it the mechanism for transfer of ownership. The trait enforces a bidirectional relationship: the iterator type must itself implement `Iterator` with matching `Item` types.

### Three Implementation Variants

```rust
struct Data {
  items: Vec<i32>,
}

// Variant 1: Immutable borrowing
impl<'a> IntoIterator for &'a Data {
  type Item = &'a i32;
  type IntoIter = std::slice::Iter<'a, i32>;

  fn into_iter(self) -> Self::IntoIter {
    self.items.iter()
  }
}

// Variant 2: Mutable borrowing
impl<'a> IntoIterator for &'a mut Data {
  type Item = &'a mut i32;
  type IntoIter = std::slice::IterMut<'a, i32>;

  fn into_iter(self) -> Self::IntoIter {
    self.items.iter_mut()
  }
}

// Variant 3: Consuming
impl IntoIterator for Data {
  type Item = i32;
  type IntoIter = std::vec::IntoIter<i32>;

  fn into_iter(self) -> Self::IntoIter {
    self.items.into_iter()
  }
}

fn main() {
  let data = Data { items: vec![1, 2, 3] };

  for x in &data {
    println!("immutable ref: {}", x);
  }

  for x in &data {
    println!("can iterate again: {}", x);
  }

  let mut data = data;
  for x in &mut data {
    *x *= 2;
  }

  for x in data {
    println!("owns value: {}", x); // Prints: 2, 4, 6
  }
  // data is consumed; cannot use after this
}
```

**Why This Pattern Matters**: By implementing `IntoIterator` for references and `&mut`, the same collection seamlessly supports all three iteration modes. The compiler automatically selects the correct variant based on context.

---

## **Implementing the Iterator Trait**

Creating custom iterators requires careful consideration of state management, ownership transfer, and performance implications.

### Strategy 1: Vector-Based Collection Iteration

```rust
struct MyCollection {
  items: Vec<String>,
}

struct MyCollectionIter {
  data: Vec<String>,
  index: usize,
}

impl Iterator for MyCollectionIter {
  type Item = String;

  fn next(&mut self) -> Option<Self::Item> {
    if self.index < self.data.len() {
      let result = Some(self.data[self.index].clone());
      self.index += 1;
      result
    } else {
      None
    }
  }
}

impl IntoIterator for MyCollection {
  type Item = String;
  type IntoIter = MyCollectionIter;

  fn into_iter(self) -> Self::IntoIter {
    MyCollectionIter {
      data: self.items,
      index: 0,
    }
  }
}
```

**Trade-offs**: This approach clones values. For non-`Copy` types, consider yielding references or using `std::vec::IntoIter` instead.

### Strategy 2: Reference-Based Iteration (Preferred)

```rust
struct MyCollection {
  items: Vec<String>,
}

struct MyCollectionIterRef<'a> {
  items: &'a [String],
}

impl<'a> Iterator for MyCollectionIterRef<'a> {
  type Item = &'a String;

  fn next(&mut self) -> Option<Self::Item> {
    if let Some((first, rest)) = self.items.split_first() {
      self.items = rest;
      Some(first)
    } else {
      None
    }
  }
}

impl MyCollection {
  fn iter(&self) -> MyCollectionIterRef {
    MyCollectionIterRef {
      items: &self.items,
    }
  }
}
```

**Advantages**: Zero clones, zero allocation. Lifetime parameters ensure references remain valid.

### Strategy 3: Using Standard Library Iterators (Best Practice)

```rust
struct MyCollection {
  items: Vec<String>,
}
impl MyCollection {
  fn iter(&self) -> std::slice::Iter<'_, String> {
    self.items.iter()
  }

  fn iter_mut(&mut self) -> std::slice::IterMut<'_, String> {
    self.items.iter_mut()
  }
}

impl IntoIterator for MyCollection {
  type Item = String;
  type IntoIter = std::vec::IntoIter<String>;

  fn into_iter(self) -> Self::IntoIter {
    self.items.into_iter()
  }
}
```

**Why This Wins**: Leverages battle-tested, highly-optimized implementations. The compiler inlines these extensively, producing tight machine code.

---

## **Mutability and Ownership in Iteration**

Rust's iteration model explicitly surfaces the ownership and mutability semantics of data access. Understanding these distinctions is critical for writing correct, idiomatic code.

### Immutable Iteration

Yields immutable references without transferring ownership.

```rust
let numbers = vec![1, 2, 3];

// All three are equivalent:
for x in &numbers { }
for x in numbers.iter() { }
for x in <&Vec<_> as IntoIterator>::into_iter(&numbers) { }

// x is &i32; cannot modify
```

**Use Case**: When you need to inspect data without modification and may need access afterward.

### Mutable Iteration

Yields mutable references, allowing in-place modification without ownership transfer.

```rust
let mut numbers = vec![1, 2, 3];

for x in &mut numbers {
  *x *= 2;
}

println!("{:?}", numbers); // [2, 4, 6]

// Collection still exists and is not consumed
```

**Use Case**: In-place transformations, state updates, or algorithmic mutations requiring the collection's continued existence.

### Consuming Iteration

Transfers ownership to the iterator, yielding owned values.

```rust
let strings = vec!["hello".to_string(), "world".to_string()];

for s in strings {
  println!("{}", s); // s is String, not &String
  // s is dropped at end of loop
}

// strings is consumed; cannot use afterward
```

**Use Case**: When the original collection is no longer needed, or when ownership transfer to consumer code is necessary.

---

## **Advanced Insights**

### Zero-Cost Abstractions

Iterator chains compile to machine code nearly identical to hand-written loops:

```rust
// High-level: iterator chain
let sum: i32 = (1..100)
  .filter(|x| x % 2 == 0)
  .map(|x| x * x)
  .sum();

// Low-level equivalent (what the compiler generates)
let mut sum = 0i32;
for x in 1..100 {
  if x % 2 == 0 {
    sum += x * x;
  }
}
```

Compiler optimizations like monomorphization specialize generic iterator code for each concrete type, eliminating abstraction overhead.

### Iterator Invalidation and Lifetimes

Rust's lifetime system prevents classic iterator invalidation bugs:

```rust
let mut numbers = vec![1, 2, 3];
let iter = numbers.iter();

// This would NOT compile:
// numbers.push(4); // ❌ Error: cannot borrow as mutable while immutable borrow exists
// The iterator holds a borrowed reference that remains active

for x in iter {
  println!("{}", x);
}

// Now safe to modify
numbers.push(4);
```

---

## **Professional Applications and Implementation**

Iterators are foundational in production Rust systems:

- Data transformation pipelines
- Stream processing and parsing
- File, network, and buffer traversal
- API design that exposes safe, composable access to internal data
- Performance-critical code requiring predictable memory behavior

Correct iterator design improves readability, testability, and runtime efficiency.

---

## **Key Takeaways**

| Concept | Summary |
| --- | --- |
| **Iterator Trait** | Defines unified, lazy iteration via `next()` and ~70 provided combinator methods. |
| **Associated Types** | Ensure one concrete `Item` type per iterator; improve inference and API clarity. |
| **IntoIterator** | Enables `for` loops, implements in three variants for `&T`, `&mut T`, `T`. |
| **Lazy Evaluation** | Combinators perform no work until consumed; enables efficient pipelines. |
| **Ownership Modes** | Three explicit patterns: immutable references, mutable references, value consumption. |
| **Zero-Cost** | Iterator chains compile to machine code equivalent to hand-written loops. |
| **Type Safety** | Ownership and lifetime rules prevent iterator invalidation at compile time. |

**Core Principles:**

- Iteration in Rust is trait-driven and statically type-safe
- Lazy evaluation avoids unnecessary computation
- Ownership and borrowing rules apply consistently
- Most functional patterns build directly on iterators
- Custom iterator implementations should prefer standard library types
- Mastery of iterators is essential for idiomatic Rust development

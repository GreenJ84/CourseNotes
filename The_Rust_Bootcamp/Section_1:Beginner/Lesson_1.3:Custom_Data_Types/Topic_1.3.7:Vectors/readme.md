# **Topic 1.3.7: Vectors**

Vectors (`Vec<T>`) are Rust's primary growable, heap-allocated collection type for storing sequences of elements of the same type. They provide efficient indexed access, dynamic resizing, and tight integration with Rust's ownership and borrowing rules. Mastery of vectors is essential for handling dynamic data in idiomatic Rust programs.

## **Learning Objectives**

- Define and initialize vectors using standard constructors and macros
- Understand memory layout, capacity, and growth strategies
- Insert, remove, and fetch elements safely with performance implications
- Iterate over vectors using consuming, shared, and mutable iterators
- Mutate vector contents using both indexing and iterator-based patterns
- Apply safe access patterns to avoid runtime panics and understand trade-offs

---

## **Vector Fundamentals**

Vectors represent ordered sequences of values of a single type, managed as a smart pointer wrapping heap-allocated data.

- Elements are stored contiguously in memory on the heap
- Allocation occurs on the heap; the stack holds metadata (pointer, length, capacity)
- Size can grow or shrink at runtime with automatic reallocation when capacity is exceeded
- Capacity grows exponentially (typically doubling) to amortize allocation costs

### Defining Vector Types

```rust
let mut numbers: Vec<i32> = Vec::new();
let letters = vec!['a', 'b', 'c'];
let with_capacity = Vec::with_capacity(10); // Preallocate for efficiency
```

Explicit type annotation may be required when the compiler cannot infer `T`:

```rust
let mut values = Vec::<String>::new();
values.push(String::from("hello"));
```

### Capacity vs. Length

```rust
let mut v = Vec::with_capacity(5);
v.push(1);
println!("len: {}, capacity: {}", v.len(), v.capacity()); // len: 1, capacity: 5
```

---

## **Inserting Elements**

### Pushing

- Appends an element to the end of the vector
- O(1) amortized time complexity

```rust
let mut v = vec![1, 2, 3];
v.push(4); // [1, 2, 3, 4]
```

### Inserting

- Inserts an element at a specific index
- Shifts subsequent elements to the right
- O(n) time complexity due to shifting

```rust
v.insert(1, 10); // [1, 10, 2, 3, 4]
```

### Extending

- Appends elements from another collection
- More efficient than repeated `push` calls for multiple elements

```rust
let mut v = vec![1, 2];
v.extend(vec![3, 4]); // [1, 2, 3, 4]
v.extend_from_slice(&[5, 6]); // Borrows instead of consuming
```

---

## **Removing Elements**

### Removing by Index

- Removes and returns an element at a given index
- Shifts remaining elements left
- O(n) time complexity; panics if out of bounds

```rust
let mut v = vec![1, 2, 3];
let removed = v.remove(1); // removes 2, returns it
// v is now [1, 3]
```

### Popping

- Removes and returns the last element
- O(1) time complexity
- Returns `Option<T>` to handle empty vectors

```rust
let mut v = vec![1, 2, 3];
let last = v.pop(); // Some(3)
let empty = v.pop(); // None if already empty
```

### Filtering

- Creates a new vector based on a condition
- Non-destructive; original remains unchanged

```rust
let v = vec![1, 2, 3, 4];
let even: Vec<i32> = v.into_iter().filter(|n| n % 2 == 0).collect();
```

> **Advanced Insight (Beginner-Appropriate):**
> Filtering with iterators avoids in-place mutation and aligns with Rust's preference for explicit data ownership. Consider using `retain()` for in-place filtering on owned vectors.

---

## **Fetching Elements**

### Indexing

- Uses square brackets
- Panics if the index is out of bounds
- Fast O(1) access

```rust
let v = vec![10, 20, 30];
let x = v[1]; // 20
// let oob = v[5]; // panics!
```

### Safe Access with `get` and `get_mut`

- Returns `Option` instead of panicking
- Preferred for user input or untrusted indices

```rust
if let Some(value) = v.get(1) {
  println!("{}", value);
}
```

Mutable access:

```rust
if let Some(value) = v.get_mut(1) {
  *value += 10;
}
```

### Slicing

- Borrows a contiguous range of elements
- Range syntax: `0..2` (exclusive), `0..=2` (inclusive)

```rust
let v = vec![10, 20, 30, 40];
let slice = &v[1..3]; // &[20, 30]
let first_two = &v[..2]; // &[10, 20]
```

---

## **Iterating**

### Consuming Iterator

- Takes ownership of the vector
- Vector cannot be used afterward

```rust
let v = vec![1, 2, 3];
for n in v {
  println!("{}", n);
}
// v is no longer accessible
```

### Reference Iterator

- Borrows elements immutably
- Vector remains available after the loop

```rust
let v = vec![1, 2, 3];
for n in &v {
  println!("{}", n);
}
// v is still usable
```

### Mutable Iterator

- Borrows elements mutably
- Allows modification during iteration

```rust
let mut v = vec![1, 2, 3];
for n in &mut v {
  *n *= 2; // [2, 4, 6]
}
```

---

## **Mutation**

### Via Iterators (Preferred)

- Functional-style transformations
- Avoid manual indexing and potential off-by-one errors
- Composable and expressive

```rust
let v = vec![1, 2, 3];
let doubled: Vec<i32> = v.iter().map(|n| n * 2).collect();
```

Zipping example:

```rust
let a = vec![1, 2];
let b = vec![3, 4];
let sum: Vec<i32> = a.iter().zip(b.iter()).map(|(x, y)| x + y).collect();
```

In-place mutation with `retain`:

```rust
let mut v = vec![1, 2, 3, 4];
v.retain(|n| n % 2 == 0); // Keep only even numbers: [2, 4]
```

### Mutable Indexing

- Direct mutation by index
- Requires mutable access and bounds checking
- Less composable than iterators

```rust
let mut v = vec![1, 2, 3];
v[0] = 10; // Panics if out of bounds
```

> **Advanced Insight (Beginner-Appropriate):**
> Iterator-based mutation is preferred in idiomatic Rust, as it minimizes borrowing conflicts, improves clarity, and reduces cognitive overhead when chaining operations.

---

## **Professional Applications and Implementation**

Vectors are used extensively in real-world Rust systems to manage dynamic datasets, buffers, message queues, task pools, and intermediate computation results. Choosing safe access patterns and iterator-based transformations ensures performance without sacrificing safety, making vectors suitable for both low-level systems programming and high-level application logic. Understanding capacity management is critical for performance-sensitive code.

---

## **Key Takeaways**

| Concept   | Summary                                                          |
| --------- | ---------------------------------------------------------------- |
| `Vec<T>`  | Growable, heap-allocated sequence of values.                     |
| Capacity  | Preallocate to reduce reallocations for known sizes.             |
| Insertion | `push` (O(1)), `insert` (O(n)), `extend` for bulk additions.     |
| Removal   | `pop` (O(1)), `remove` (O(n)), `retain` for in-place filtering.  |
| Fetching  | Use `get` for safe access; `[]` for trusted indices.             |
| Iteration | Consuming, shared, and mutable iterators control ownership.      |
| Mutation  | Prefer iterator-based transformations for clarity and safety.    |

- Vectors are the default dynamic collection in Rust
- Safe access prevents runtime panics and helps catch bugs early
- Iterators integrate ownership, performance, and expressiveness
- Preallocating capacity improves performance for predictable sizes
- Proper usage enables expressive and efficient data handling

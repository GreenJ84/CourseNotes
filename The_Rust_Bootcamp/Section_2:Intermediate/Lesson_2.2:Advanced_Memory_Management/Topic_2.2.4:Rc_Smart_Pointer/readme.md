# **Topic 2.2.4: `Rc<T>` Smart Pointer**

`Rc<T>` (Reference Counted) is a smart pointer that enables **shared ownership** of heap-allocated data in **single-threaded** contexts. Unlike `Box<T>`, which enforces a single owner, `Rc<T>` allows multiple parts of a program to hold ownership over the same value while ensuring the data is dropped only when the final owner goes out of scope.

## **Learning Objectives**

- Understand reference counting as an ownership strategy and its trade-offs
- Use `Rc<T>` to enable shared ownership safely in single-threaded contexts
- Distinguish cloning an `Rc` from cloning the underlying data and performance implications
- Reason about reference count increments, decrements, and lifecycle management
- Identify when `Rc<T>` is appropriate and recognize anti-patterns
- Pair `Rc<T>` with `RefCell<T>` for interior mutability patterns
- Recognize and prevent reference cycles using `Weak<T>`

---

## **What Is `Rc<T>`**

`Rc<T>`:

- Stores data on the heap with an associated reference count stored alongside
- Tracks the number of active owners using atomic-free reference counting
- Deallocates the value when the count reaches zero (deterministic)
- Is **not thread-safe** and must only be used in single-threaded scenarios
- Has a non-trivial runtime cost compared to single ownership (`Box<T>`)

Importing `Rc`:

```rust
use std::rc::Rc;
```

**Design Philosophy**: `Rc<T>` trades compile-time ownership clarity for runtime flexibility. The compiler relinquishes ownership enforcement in favor of runtime bookkeeping. For concurrent or async code, `Arc<T>` (atomic reference counting) must be used instead, accepting the overhead of atomic operations.

### Memory Layout

```rust
// Conceptually, Rc<T> allocates a control block on the heap:
// [strong_count | weak_count | drop_fn | T]
// Rc<T> holds a pointer to this allocation
```

---

## **Creating an `Rc<T>`**

An `Rc<T>` is created using `Rc::new`, which:

1. Allocates the value on the heap
2. Initializes the strong reference count to 1
3. Initializes the weak reference count to 0

```rust
let value = Rc::new(String::from("shared data"));
// Reference count: 1
// The value is now owned by this Rc<T>
```

At this point:

- One strong reference exists
- The value remains alive as long as at least one `Rc` points to it
- Memory is immediately reclaimed when `value` goes out of scope

### Advanced: Checking Reference Counts

```rust
use std::rc::Rc;

let a = Rc::new(vec![1, 2, 3]);
println!("Count after creation: {}", Rc::strong_count(&a)); // Output: 1

let b = Rc::clone(&a);
println!("Count after clone: {}", Rc::strong_count(&a)); // Output: 2

drop(b);
println!("Count after drop: {}", Rc::strong_count(&a)); // Output: 1
```

This introspection capability is invaluable for debugging shared ownership patterns in complex systems.

---

## **Sharing Data with `Rc::clone`**

Sharing ownership is done by cloning the `Rc`, **not** the underlying value. This is semantically different from calling `clone()` on the inner type.

```rust
use std::rc::Rc;

let a = Rc::new(10);
let b = Rc::clone(&a);  // Preferred: explicit that we're cloning the Rc
let c = a.clone();      // Also valid but less idiomatic for Rc

// All three variables point to the same heap allocation
assert_eq!(*a, *b);
assert_eq!(*b, *c);
```

### Key behaviors

- `Rc::clone(&rc)` increments the reference count **without** copying or cloning the inner value
- The inner value is accessed via `Deref` (calling `*a` dereferences automatically in most contexts)
- Dropping `b` or `c` decrements the count; the heap allocation persists
- The data is dropped only when the count reaches zero
- This makes `Rc<T>` efficient for read-heavy shared data with minimal copies

### Performance Consideration: Clone vs. Copy

```rust
use std::rc::Rc;

// Copying an Rc (cheap: just pointer arithmetic on stack)
let rc1 = Rc::new(String::from("expensive data"));
let rc2 = Rc::clone(&rc1);  // O(1) - only reference count incremented

// vs. Cloning the inner String (expensive: heap allocation)
let s1 = "expensive data".to_string();
let s2 = s1.clone();  // O(n) where n is string length

```

> **Senior insight:** Rc<T> amortizes the cost of shared ownership across all clones, unlike repeatedly cloning the inner value

---

## **Reference Count Lifecycle**

The lifecycle follows a deterministic pattern:

- **Initialization**: `Rc::new(value)` → count = 1
- **Clone**: `Rc::clone(&rc)` → count += 1
- **Drop**: Automatic when `Rc` goes out of scope → count -= 1
- **Deallocation**: When count reaches 0, `drop(T)` is called, then control block is freed

```rust
use std::rc::Rc;

{
  let a = Rc::new(String::from("data"));  // count: 1
  {
    let b = Rc::clone(&a);              // count: 2
    {
      let c = Rc::clone(&a);          // count: 3
    } // c dropped, count: 2
  } // b dropped, count: 1
} // a dropped, count: 0 → data is freed

// This is deterministic and predictable
```

The reference count is managed transparently and safely by Rust. However, **determinism is not guaranteed for the exact timing of deallocation** due to borrowing scope rules.

---

## **Shared Ownership with Immutability**

`Rc<T>` enforces that shared data is **immutable by default**. This is a critical design constraint:

```rust
use std::rc::Rc;

let shared = Rc::new(vec![1, 2, 3]);
let clone1 = Rc::clone(&shared);
let clone2 = Rc::clone(&shared);

// This CANNOT compile - immutable borrow rule
// shared.push(4);

// But reading is safe and encouraged across all owners
println!("{:?}", *shared);   // [1, 2, 3]
println!("{:?}", *clone1);   // [1, 2, 3]
println!("{:?}", *clone2);   // [1, 2, 3]
```

---

## **Enabling Mutation: `Rc<T>` with `RefCell<T>`**

To enable mutation through shared references, `Rc<T>` is paired with [`RefCell<T>`](../Topic_2.2.5:RefCell_Smart_Pointer/readme.md), which enforces borrowing rules at runtime.

> **Critical limitation:** `Rc<T>` can form **reference cycles** when combined with `RefCell<T>`, causing memory leaks even in safe Rust
>
>
> **Senior Insight**: `Rc<RefCell<T>>` is the idiomatic pattern for shared mutable state in single-threaded contexts. It defers borrow checking to runtime, accepting the performance and panic risk for the flexibility of shared mutability.

---

## **Advanced Insights**

### Single-threaded Reference Counting

`Rc<T>` uses **non-atomic operations** for incrementing and decrementing counts:

- Internally, Rc uses plain usize for counts, not AtomicUsize
  - This makes it fast but completely unsafe for concurrent use
- Even if Arc<T> exists, the decision to use Rc<T> must be intentional

### Performance Characteristics

| Operation | Cost |
| --------- | ---- |
| `Rc::new(T)` | One heap allocation + initialization |
| `Rc::clone(&rc)` | Non-atomic increment (negligible) |
| `drop(Rc)` | Non-atomic decrement + conditional deallocation |
| Dereference `*rc` | Pointer dereference (zero-cost) |

### When to Use `Rc<T>`

✓ Tree or DAG structures (ASTs, scene graphs, UI trees)
✓ Sharing read-only configuration or state
✓ Complex graph-like data structures
✓ Lazy evaluation with shared computations

✗ Hot loops where reference count changes frequently
✗ Scenarios requiring thread safety
✗ When `Box<T>` (single ownership) or borrowing suffices
✗ Performance-critical code paths where atomic operations are acceptable trade-off

### Relationship to [`Arc<T>`](../Topic_2.2.6:Arc_Smart_Pointer/readme.md)

`Arc<T>` is the atomic, thread-safe variant:

```rust
use std::sync::Arc;
use std::thread;

let shared = Arc::new(vec![1, 2, 3]);
let clone = Arc::clone(&shared);

thread::spawn(move || {
  println!("{:?}", *clone);  // Safe access from another thread
});

// Arc uses AtomicUsize for counts, accepting overhead for correctness
```

Understanding `Rc<T>` prepares you for concurrent ownership patterns using `Arc<T>` and higher-level abstractions.

---


## **Real-world Use Cases**

`Rc<T>` is commonly used in production Rust applications:

- **AST Representation**: Compiler implementations share subtrees across the AST
- **Scene Graphs**: Game engines use `Rc<RefCell<Node>>` for hierarchical structures
- **UI Frameworks**: Shared event listeners, state, and component trees
- **Graph Algorithms**: Representing node relationships without explicit ownership transfer
- **Configuration Management**: Sharing immutable config across application layers

### Example: Simple AST

```rust
use std::rc::Rc;

#[derive(Debug)]
enum Expr {
  Num(i32),
  Add(Rc<Expr>, Rc<Expr>),
  Mul(Rc<Expr>, Rc<Expr>),
}

let five = Rc::new(Expr::Num(5));
let three = Rc::new(Expr::Num(3));

// Reuse five in multiple places without moving
let add_expr = Expr::Add(Rc::clone(&five), Rc::clone(&three));
let mul_expr = Expr::Mul(Rc::clone(&five), Rc::new(Expr::Num(2)));

println!("{:?}", add_expr);  // Add(Num(5), Num(3))
println!("{:?}", mul_expr);  // Mul(Num(5), Num(2))
// five is shared between both expressions with zero additional allocations
```

### Communicating Intent

Using `Rc<T>` explicitly signals to code reviewers and future maintainers: *this value has multiple logical owners in a single-threaded context, and we've intentionally chosen shared ownership over single ownership or borrowing*.

---

## **Professional Applications and Implementation**

Rc<T> is commonly used in real-world Rust applications:

- Sharing immutable configuration or state
- Building ASTs, scene graphs, or UI trees
- Implementing graph-like data structures
- Managing shared read-only resources efficiently

Using Rc<T> communicates intent: this data has multiple owners in a single-threaded context.

---

## **Key Takeaways**

| Concept | Summary |
| ------- | ------- |
| `Rc<T>` | Enables shared ownership via reference counting in single-threaded contexts |
| `Rc::clone(&rc)` | Increments reference count; the inner value is not copied |
| Deref coercion | `*rc` automatically dereferences to access the inner value |
| `Rc<RefCell<T>>` | Idiomatic pattern for shared mutable state |
| Thread safety | Fundamentally not safe; use `Arc<T>` for concurrent code |
| Lifecycle | Deterministic and automatic; memory freed when count reaches zero |
| Reference cycles | Possible and memory-leaking; use `Weak<T>` to break them |

- `Rc<T>` allows multiple owners of the same heap-allocated value through reference counting
- Reference counting is automatic, deterministic, and transparent
- Suitable exclusively for single-threaded environments
- Pair with `RefCell<T>` to enable mutation; handle cycles with `Weak<T>`
- Forms the foundation for understanding concurrent ownership patterns (`Arc<T>`)
- Communicates clear intent about shared ownership semantics in code


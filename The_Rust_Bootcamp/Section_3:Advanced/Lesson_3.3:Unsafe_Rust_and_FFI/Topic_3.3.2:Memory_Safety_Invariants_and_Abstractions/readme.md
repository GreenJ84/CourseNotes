# **Topic 3.3.2: Memory Safety Invariants and Abstractions**

Memory safety in Rust is not a single rule. It is a set of invariants that must always hold for data layout, aliasing, lifetimes, and synchronization. In safe Rust, the compiler enforces these invariants. In unsafe Rust, you must enforce them manually and prove they hold through design, constraints, and careful API boundaries.

This topic focuses on what those invariants are, why they matter, and how senior Rust engineers build safe public interfaces over unsafe internals.

## **Learning Objectives**

- Identify the core invariants behind Rust memory safety
- Reason about validity, aliasing, and lifetimes as formal contracts
- Explain `Send` and `Sync` as thread-safety contracts, not "just traits"
- Understand why `UnsafeCell<T>` is required for interior mutability
- Recognize high-risk unsafe patterns that lead to Undefined Behavior (UB)
- Design safe abstractions that enforce invariants by construction

---

## **Core Memory Safety Invariants**

At a systems level, memory safety depends on three primary invariants:

1. **Validity**: values must be initialized, aligned, and bit-valid for their type
2. **Aliasing discipline**: mutable access must be exclusive, shared access must be non-mutating (unless interior mutability is used correctly)
3. **Lifetime correctness**: references must never outlive the memory they point to

If any of these break, UB is possible.

### 1. Validity

A value is valid only when all of the following are true:

- Memory is initialized for that type
- Alignment matches `align_of::<T>()`
- Bit pattern is legal for `T` (for example, not all bit patterns are valid for enums, bool, references)

```rust
use std::mem::MaybeUninit;

let x: i32 = unsafe {
  // UB: reading uninitialized memory as i32
  MaybeUninit::<i32>::uninit().assume_init()
};

println!("{}", x);
```

> **Senior insight**: Validity is broader than "does it compile". A value can have the right type syntactically and still be invalid semantically at runtime.

### 2. Aliasing Rules

Rust reference model:

- `&T`: many immutable references allowed
- `&mut T`: exactly one active mutable reference, exclusive access

```rust
let mut x = 5;
let r1 = &mut x;
// let r2 = &mut x; // ❌ compile-time error in safe Rust

*r1 += 1;
println!("{}", r1);
```

Unsafe code can bypass compiler checks, but not the underlying rule. Violating aliasing can cause:

- Incorrect optimizer assumptions
- Data races in concurrent code
- Silent memory corruption

### 3. Lifetime Correctness

References are only valid while their referent is alive.

```rust
let r: &i32;

{
  let x = 10;
  r = &x;
} // x dropped

// println!("{}", r); // ❌ would be dangling if allowed
```

> **Senior Insight:** Safe Rust prevents this statically. Unsafe abstractions must preserve this property manually.

---

## **Thread-Safety Contracts: `Send` and `Sync`**

`Send` and `Sync` encode concurrency safety at the type level.

### [`Send`](../../Lesson_3.1:Concurrency,_Async,_and_Await/Topic_3.1.2:Rust_Concurrency_Features/readme.md)

A type is `Send` if ownership can move safely to another thread.

### [`Sync`](../../Lesson_3.1:Concurrency,_Async,_and_Await/Topic_3.1.2:Rust_Concurrency_Features/readme.md)

A type is `Sync` if `&T` can be shared across threads safely.

Equivalent intuition:

- `T: Sync` if `&T: Send`

```rust
use std::thread;

let x = 5;
let handle = thread::spawn(move || {
  println!("{}", x); // requires i32: Send
});

handle.join().unwrap();
```

Most types get these auto-derived, but unsafe internals may require manual `unsafe impl Send/Sync`.

> **Senior insight**: Manual `Send`/`Sync` is a high-risk operation. You are asserting global thread-safety properties for all callers, not just your local test case.

---

## **Interior Mutability and `UnsafeCell<T>`**

Rust normally requires `&mut T` for mutation. Interior mutability is the deliberate exception where mutation is allowed through shared references under controlled rules.

`UnsafeCell<T>` is the only primitive that legally permits this at the language level.

```rust
use std::cell::UnsafeCell;

struct MyCell {
  value: UnsafeCell<i32>,
}
```

It underpins:

- `Cell<T>` (copy-based interior mutation)
- `RefCell<T>` (runtime borrow checking)
- `Mutex<T>`, `RwLock<T>` (synchronization-backed mutation)

Why this matters:

- Without `UnsafeCell`, mutating through `&T` violates aliasing assumptions
- With `UnsafeCell`, the type promises it will enforce safety by other means (runtime checks or synchronization)

---

## **Common Unsafe Pitfalls and Why They Happen**

### Dangling Pointers

Any pointer/reference to freed or moved-away storage is dangling. Dereferencing it is UB.

```rust
let b = Box::new(10);
let ptr = &*b as *const i32;

drop(b);

unsafe {
  println!("{}", *ptr); // UB: pointer now dangles
}
```

Root cause: lifetime contract broken after deallocation.

### Double Free

```rust
let b = Box::new(5);
let raw = Box::into_raw(b);

unsafe {
  let _a = Box::from_raw(raw);
  let _c = Box::from_raw(raw); // UB: same allocation reclaimed twice
}
```

Root cause: ownership contract broken; one allocation acquired by two owners.

### Data Races

Data race conditions:

- Same location accessed by multiple threads
- At least one access is a write
- No proper synchronization

Data races are UB in Rust.

---

## **Designing Safe Abstractions Over Unsafe Internals**

Core principle:

- **Unsafe internally, safe externally**

Design goals:

- Keep unsafe operations private
- Enforce invariants with API structure
- Make invalid states unrepresentable where possible

### Example: Raw Pointer Wrapper

```rust
pub struct SafeWrapper {
  ptr: *mut i32,
}

impl SafeWrapper {
  pub fn new(value: i32) -> Self {
    let boxed = Box::new(value);
    Self {
      ptr: Box::into_raw(boxed),
    }
  }

  pub fn get(&self) -> i32 {
    // Safety: ptr comes from Box::into_raw in new and remains owned by self.
    unsafe { *self.ptr }
  }

  pub fn set(&mut self, value: i32) {
    // Safety: &mut self guarantees exclusive access to ptr target.
    unsafe {
      *self.ptr = value;
    }
  }
}

impl Drop for SafeWrapper {
  fn drop(&mut self) {
    // Safety: ptr was created by Box::into_raw exactly once and
    // is converted back exactly once here.
    unsafe {
      drop(Box::from_raw(self.ptr));
    }
  }
}
```

Why this is better than a raw-pointer-only sketch:

- Defines ownership and cleanup explicitly via `Drop`
- Avoids leaks and double free under normal usage
- Documents each unsafe operation with local safety reasoning

---

## **Encapsulation Strategies**

1. Minimize unsafe surface area: keep blocks tiny and local
2. Document invariants at every unsafe boundary (`// Safety:` and `# Safety` docs)
3. Use type system constraints: newtypes, lifetimes, phantom markers, ownership flow
4. Prefer battle-tested primitives before writing custom unsafe logic
5. Audit unsafe code as if it were security-sensitive code
6. Add stress tests for edge conditions (boundary sizes, concurrency, panic paths)
7. Validate assumptions with tools such as Miri and sanitizers where applicable

> **Senior insight**: Unsafe correctness is mostly architecture, not syntax. If your API shape does not encode invariants, no amount of local comments will save it.

---

## **Professional Applications and Implementation**

Mastering these invariants is critical in:

- Allocators and custom memory arenas
- Lock-free queues and synchronization primitives
- Runtime and scheduler internals
- Zero-copy parsers and networking stacks
- Embedded and kernel-adjacent systems
- FFI bridges where ownership/lifetime models differ

The best unsafe code is usually invisible to consumers because the public API is safe, constrained, and hard to misuse.

---

## **Key Takeaways**

| Concept | Summary |
| ------- | ------- |
| Memory Invariants | Safety depends on validity, aliasing discipline, and correct lifetimes. |
| Validity | Values must be initialized, aligned, and bit-valid for their type. |
| Thread Safety | `Send` and `Sync` encode cross-thread ownership and sharing guarantees. |
| UnsafeCell | Foundation of legal interior mutability in Rust. |
| Common Failures | Use-after-free, double free, dangling pointers, and data races lead to UB. |
| Safe Abstractions | Keep unsafe internals private and enforce invariants through API design. |

- Unsafe Rust requires strict adherence to memory invariants
- Violations lead to undefined behavior with no guarantees
- `UnsafeCell` is central to controlled mutation through shared references
- Thread-safety must be explicitly reasoned about in unsafe contexts;  at the type and ownership levels
- Proper abstraction design is the key to safe and maintainable systems
- UB often comes from broken contracts, not obvious syntax errors
- High-quality abstractions make unsafe power usable without exposing unsafe risk

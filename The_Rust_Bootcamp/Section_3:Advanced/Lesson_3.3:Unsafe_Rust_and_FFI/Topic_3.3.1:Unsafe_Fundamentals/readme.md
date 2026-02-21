# **Topic 3.3.1: Unsafe Fundamentals**

Unsafe Rust defines the boundary where the compiler can no longer prove all memory and concurrency guarantees on your behalf. In safe Rust, the compiler enforces ownership, borrowing, lifetimes, and aliasing rules. In unsafe Rust, those rules still exist, but you are now responsible for upholding them manually where the compiler cannot reason precisely enough.

Unsafe is not a "turn off safety" switch. It is a contract boundary: the compiler allows certain powerful operations, and you promise the required invariants are true.

## **Learning Objectives**

- Define unsafe Rust as an explicit contract boundary in the language
- Explain what `unsafe` does and does not change about Rust's safety model
- Identify the unsafe capabilities and their required invariants
- Distinguish `unsafe fn`, `unsafe trait`, and `unsafe {}` blocks
- Recognize common sources of Undefined Behavior (UB) and how to avoid them
- Apply patterns for encapsulating unsafe internals behind safe APIs

---

## **Unsafe as a Contract, Not an Escape Hatch**

The most useful mental model is:

- **Safe Rust**: compiler proves your program respects Rust's safety rules
- **Unsafe Rust**: compiler cannot prove a small part, so you provide the proof by construction and discipline

### What `unsafe` does

- Permits specific operations that are otherwise rejected
- Marks locations that require manual reasoning and review
- Enables low-level systems programming, FFI, and some performance patterns

### What `unsafe` does not do

- It does not disable the borrow checker globally
- It does not disable type checking
- It does not make UB acceptable
- It does not remove all compiler diagnostics

> **Senior insight**: Think of each `unsafe` site as a mini API with preconditions. If those preconditions are wrong or undocumented, the bug may compile, pass tests, and fail only in production.

### Example: Declaring an Unsafe Block

```rust
let ptr = &10 as *const i32;

unsafe {
    println!("{}", *ptr); // Dereferencing raw pointer
}
```

- The compiler requires `unsafe` because it cannot guarantee:
  - The pointer is valid
  - The memory is still allocated
  - No aliasing violations exist

---

## **Rust's Safety Guarantees and Their Boundaries**

In safe Rust, you get strong guarantees:

- No data races on shared mutable state
- No use-after-free through references
- No dangling references in well-typed safe code
- No invalid reference aliasing patterns

These guarantees come from:

- Ownership and move semantics
- Borrowing (`&T`, `&mut T`)
- Lifetime constraints
- Type and trait checks

### Where compile-time proof stops

The compiler cannot fully verify:

- Raw pointer validity (`*const T`, `*mut T`)
- Correctness of external code (C/C++/OS APIs)
- Some low-level concurrency and atomics patterns
- Hardware interactions and inline assembly effects

`unsafe` marks the exact edge where proof shifts from compiler to developer.

---

## **The Unsafe Capabilities**

Rust restricts unsafe behavior to **specific, well-defined operations**:

### 1. Dereferencing Raw Pointers

```rust
let mut num = 5;
let r1 = &num as *const i32;
let r2 = &mut num as *mut i32;

unsafe {
  println!("r1 points to {}", *r1);
  *r2 = 10;
}

println!("num is now {}", num);
```

*Raw pointers are not references*. They can be:

- Null
- Dangling
- Misaligned
- Aliased in ways references are not allowed to be

Required invariants before dereference:

- Pointer is non-null and properly aligned for `T`
- Target memory is allocated and alive for the access duration
- Aliasing rules are respected for mutable access

### 2. Calling Unsafe Functions or Methods

```rust
unsafe fn dangerous_function(ptr: *const u8) -> u8 {
  // Caller must guarantee ptr is valid for reads of 1 byte.
  *ptr
}

let value = 7u8;
let ptr = &value as *const u8;

let out = unsafe { dangerous_function(ptr) };
println!("{}", out);
```

An `unsafe fn` means: the function has a contract the caller must satisfy.

> **Senior insight**: The most common failure in unsafe code is a missing or vague safety contract. Every `unsafe fn` should clearly document a `# Safety` section describing exact preconditions.

### 3. Accessing or Mutating `static mut`

```rust
static mut COUNTER: u64 = 0;

fn increment_counter() {
  unsafe {
    COUNTER += 1;
  }
}
```

`static mut` is globally mutable memory and is not synchronized.

Risks:

- Data races across threads (UB)
- Re-entrancy bugs

Preferred alternatives:

- `AtomicU64`
- `Mutex<T>`
- `OnceLock<T>` / `LazyLock<T>`

### 4. Implementing Unsafe Traits

```rust
unsafe trait MyUnsafeTrait {}

unsafe impl MyUnsafeTrait for u32 {}
```

Unsafe traits express invariants the compiler cannot verify. `Send` and `Sync` are canonical examples.

When you write `unsafe impl`, you assert:

- The type satisfies the trait's safety guarantees in all valid usage contexts

If wrong, downstream safe code may become unsound.

### 5. Accessing Fields of a `union`

```rust
union MyUnion {
    i: i32,
    f: f32,
}

let u = MyUnion { i: 42 };

unsafe {
  println!("union view: {}", u.i);
}
```

Unions share storage for all fields. The compiler cannot track which variant is currently valid.

You must guarantee:

- You only read fields in a representation-compatible, initialized state

### 6. Using Inline Assembly (`asm!`)

```rust
use std::arch::asm;

unsafe {
  asm!("nop");
}
```

Inline assembly can violate compiler assumptions about registers, memory, and control flow.

You must specify constraints and side effects correctly, or optimizations may miscompile your code.

---

## **`unsafe` Code vs `unsafe` Operations**

*Unsafe Code* (Block/Function):

- Declared with `unsafe {}` block or `unsafe fn`
  > `unsafe fn` does not automatically allow unsafe operations without explicit `unsafe {}` blocks
- Indicates permission to perform unsafe operations

*Unsafe Operations*:

- Specific actions that require unsafe context
- Cannot occur outside `unsafe`

```rust
unsafe fn get_first(ptr: *const i32) -> i32 {
  // Even inside unsafe fn, unsafe operations should be in a small block.
  unsafe { *ptr }
}
```

### Why keep explicit blocks inside `unsafe fn`?

- Improves auditability
- Narrows high-risk scope
- Forces local reasoning around each operation

> **Senior insight**: Keep unsafe blocks as small as possible. "Small unsafe surface area" is one of the strongest maintainability predictors in Rust systems code.

---

## **Undefined Behavior (UB)**

UB means the program violated Rust's abstract machine rules. Once UB occurs, the compiler may assume impossible states never happen and optimize based on that assumption.

*Possible outcomes*:

- Immediate crash
- Silent corruption
- Security vulnerability
- Different behavior by compiler version/optimization level/CPU

### Common UB causes

- Dereferencing null, dangling, or misaligned pointers
- Violating aliasing (`&mut T` must be exclusive)
- Reading uninitialized memory
- Data races with unsynchronized shared mutation
- FFI contract mismatches (wrong ABI, wrong lifetime, wrong ownership)

### Example: Null pointer dereference

```rust
let ptr: *const i32 = std::ptr::null();

unsafe {
  // UB: ptr does not point to a valid i32
  // pointer is null
  println!("{}", *ptr);
}
```

### Example: Why aliasing rules still matter

```rust
let mut x = 1;
let p1: *mut i32 = &mut x;
let p2: *mut i32 = &mut x;

unsafe {
  // Two mutable raw pointers can exist, but you must avoid
  // creating reference patterns that violate exclusivity.
  *p1 = 10;
  *p2 = 20;
}
```

This compiles, but careless conversion to references from these pointers can trigger UB.

---

## **Building Sound Safe Abstractions Around Unsafe**

Professional Rust code rarely exposes raw unsafe details directly. Instead:

1. Keep unsafe internals private
2. Expose a safe API with enforced invariants
3. Document safety assumptions clearly
4. Test edge cases and run tools like Miri when possible

### Example Pattern: Validate Once, Then Unsafe Internally

```rust
pub fn first<T>(slice: &[T]) -> Option<&T> {
  if slice.is_empty() {
    return None;
  }

  // Safety:
  // - slice is non-empty, so index 0 is in-bounds
  // - returned reference is tied to slice lifetime
  unsafe { Some(slice.get_unchecked(0)) }
}
```

Why this is a good pattern:

- Safety precondition is checked in safe code (`is_empty`)
- Unsafe block is tiny and local
- API remains safe for all callers

---

## **Senior-Level Unsafe Review Checklist**

Before approving unsafe Rust in production code, verify:

1. Is unsafe truly required, or can safe Rust express this now?
2. Is each unsafe block minimal and locally justified?
3. Are all invariants explicitly documented near the block/function?
4. Could aliasing, lifetime, or initialization assumptions be violated?
5. Are FFI boundaries clear about ownership and who frees memory?
6. Are there tests for edge cases: null, empty, boundary, concurrency?
7. Can this be validated with sanitizers, fuzzing, or Miri?

> **Senior insight**: In mature Rust codebases, unsafe is treated like cryptography code: small, heavily reviewed, and rarely modified without strong reason.

---

## **Professional Applications and Implementation**

Unsafe Rust is essential in areas where full abstraction is not feasible:

- Standard library internals (`Vec`, `String`, iterators)
- Memory allocators and arena systems
- Lock-free and wait-free concurrency primitives
- OS kernels, embedded runtimes, and device drivers
- High-performance parsing/network stacks
- FFI layers around C/C++ libraries

The engineering goal is not "avoid unsafe forever." The goal is "use unsafe precisely, prove invariants, and expose safe interfaces."

---

## **Key Takeaways**

| Concept | Summary |
| ------- | ------- |
| Unsafe Keyword | Grants permission for specific operations the compiler cannot prove safe. |
| Safety Model | `unsafe` does not remove Rust rules; it transfers proof obligations to the developer. |
| Six Capabilities | Rust limits unsafe power to explicit operations with known risk profiles. |
| `unsafe fn` vs Block | `unsafe fn` defines caller obligations; `unsafe {}` marks risky implementation points. |
| Undefined Behavior | UB is never acceptable; it can invalidate assumptions across the whole program. |
| Sound Design | Keep unsafe small, private, documented, and wrapped in safe APIs. |

- Unsafe Rust is about explicit contracts, not bypassing discipline
- Most unsafe bugs come from undocumented or violated invariants
- Small unsafe blocks are easier to reason about and review
- Prefer safe alternatives first; use unsafe only when necessary
- Production-quality unsafe code requires tests, tooling, and strict code review

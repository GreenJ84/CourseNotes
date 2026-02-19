# **Lesson 3.3: Unsafe Rust and FFI**

This lesson explores the boundaries of Rust’s safety guarantees and the mechanisms available for performing operations that the compiler cannot statically verify. It introduces the `unsafe` keyword as a controlled escape hatch, examines the invariants required to maintain memory safety manually, and extends into low-level system interaction through inline assembly and cross-language interoperability via FFI. Mastery of these topics enables the development of high-performance, low-level components while preserving safe abstractions at the API boundary.

## **Learning Objectives**

- Distinguish between safe and unsafe Rust and understand the guarantees each provides
- Identify and correctly use the five categories of unsafe operations
- Reason about memory safety invariants including aliasing, lifetimes, and data validity
- Design safe abstractions over unsafe implementations
- Utilize inline assembly for low-level hardware interaction when necessary
- Implement FFI bindings to interface Rust with external libraries and systems
- Maintain correctness and safety across language and abstraction boundaries

---

## **Topics**

### Topic 3.3.1: Unsafe Fundamentals

- Definition and purpose of the `unsafe` keyword and unsafe Rust
- Rust’s safety guarantees and the boundaries of compile-time verification
- The six unsafe capabilities:
  - Dereferencing raw pointers (`*const T`, `*mut T`)
  - Calling unsafe functions
  - Accessing or modifying mutable static variables
  - Implementing unsafe traits
  - Accessing union fields
  - Writing inline assembly
- Difference between “unsafe code” and “unsafe operations”
- Undefined behavior (UB) and its implications in Rust

### Topic 3.3.2: Memory Safety Invariants and Abstractions

- Core invariants required for safe memory usage:
  - Validity (initialized, properly aligned data)
  - Aliasing rules (`&T` vs `&mut T`)
  - Lifetime correctness
- Thread-safety contracts (`Send` and `Sync`)
- Interior mutability and the role of `UnsafeCell`
- Common unsafe pitfalls:
  - Use-after-free
  - Double free
  - Data races
  - Dangling pointers
- Designing safe public APIs backed by unsafe internals
- Encapsulation strategies to contain unsafe code

### Topic 3.3.3: Inline Assembly

- Purpose of inline assembly in systems programming
- The `asm!` macro and its structure
- Register constraints, inputs/outputs, and clobbers
- Interaction with CPU instructions and architecture-specific behavior
- Safety considerations and correctness guarantees
- When to prefer compiler intrinsics over manual assembly

### Topic 3.3.4: Foreign Function Interface (FFI)

- Concept of ABI (Application Binary Interface) and interoperability
- Using `extern [ABI]` for cross-language compatibility
- Linking external libraries and symbols
- Data layout guarantees with `#[repr(C)]`
- Passing data across language boundaries safely
- Ownership, memory allocation, and deallocation across FFI
- Building safe Rust wrappers around foreign code

---

## **Professional Applications and Implementation**

Unsafe Rust and FFI are critical for scenarios requiring direct control over memory, performance, and system boundaries:

- Developing high-performance libraries where abstraction overhead must be minimized
- Interfacing with existing C/C++ systems, operating system APIs, and hardware drivers
- Writing runtime components, allocators, and low-level infrastructure
- Implementing custom synchronization primitives and concurrency tools
- Extending Rust with domain-specific optimizations via assembly or foreign code
- Encapsulating unsafe behavior within safe, reusable abstractions for broader system use

---

## **Key Takeaways**

| Area | Summary |
| ---- | ------- |
| Unsafe Fundamentals | `unsafe` enables operations beyond compiler guarantees and must be used with explicit responsibility. |
| Memory Invariants | Correctness depends on maintaining strict rules around validity, aliasing, and lifetimes. |
| Inline Assembly | Provides direct hardware control but requires precise handling of registers and side effects. |
| FFI | Enables interoperability with external systems while requiring careful management of ABI and memory boundaries. |

- Unsafe Rust is a controlled capability, not a relaxation of correctness requirements
- Memory safety becomes the developer’s responsibility within unsafe blocks
- Safe abstractions are essential to prevent propagation of unsafe behavior
- Inline assembly and FFI enable low-level power but introduce significant risk if misused
- Proper design isolates unsafe code while preserving Rust’s guarantees at higher levels

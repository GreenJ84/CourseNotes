# **Topic 1.1.5: Constants & Statics**

This topic explains Rust’s mechanisms for defining global, immutable values using `const` and `static`. While both allow values to exist beyond local scopes, they serve distinct purposes and have different memory, lifetime, and safety implications. Understanding these differences is essential for configuration values, shared resources, and performance-sensitive systems programming.

## **Learning Objectives**

- Define and use compile-time constants with `const`
- Understand static variables and their memory characteristics
- Differentiate between `const` and `static` use cases
- Recognize safety considerations around global data
- Apply constants and statics appropriately in real-world Rust projects

---

## **Constants**

Constants are immutable values evaluated at compile time.

```rs
const MAX_USERS: u32 = 100;
const PI: f64 = 3.1415926535;
```

- Must have an explicit type
- Evaluated entirely at compile time
- Inlined wherever they are used
- Do not occupy a fixed memory location

Key characteristics:

- No runtime cost
- No ownership or borrowing concerns
- Can be used in pattern matching and array sizes

```rs
let values = [0; MAX_USERS as usize];
```

> Advanced Insight:
> Because `const` values are inlined, changing a constant requires recompilation of dependent crates to ensure consistency.

---

## **Statics**

Static variables define globally allocated values with a fixed memory address.

```rs
static APP_NAME: &str = "Rust App";
```

- Have a `'static` lifetime
- Stored in a single memory location
- Exist for the entire duration of the program

Unlike constants, statics are not inlined.

### Mutable Statics

Mutable statics are allowed but unsafe.

```rs
static mut COUNTER: u32 = 0;
```

- Accessing or modifying requires an `unsafe` block
- Not thread-safe by default
- Can introduce data races if misused

```rs
unsafe {
    COUNTER += 1;
}
```

> Advanced Insight:
> Direct use of `static mut` is discouraged. Safer alternatives include `lazy_static`, `once_cell`, or synchronization primitives such as `Mutex` or `Atomic*` types.

---

## **Const vs Static**

| Aspect     | `const`          | `static`                       |
| ---------- | ---------------- | ------------------------------ |
| Evaluation | Compile-time     | Program initialization         |
| Memory     | Inlined          | Single fixed location          |
| Lifetime   | N/A (no address) | `'static`                      |
| Mutability | Immutable only   | Immutable or mutable           |
| Safety     | Always safe      | `static mut` requires `unsafe` |

### When to Use Each

- Use **`const`** for:

  - Configuration values
  - Numeric limits
  - Compile-time expressions

- Use **`static`** for:

  - Global shared data
  - Large read-only resources
  - Values requiring a stable memory address

---

## **Professional Applications and Implementation**

Constants and statics are commonly used in systems programming, embedded development, and high-performance services. Constants provide zero-cost, compile-time guarantees, while statics enable controlled global access to shared data. Professional Rust codebases favor `const` whenever possible and employ safe abstractions over statics to maintain thread safety and correctness.

---

## **Key Takeaways**

| Concept       | Summary                                             |
| ------------- | --------------------------------------------------- |
| Constants     | Compile-time, inlined, immutable values.            |
| Statics       | Global values with a fixed memory address.          |
| Safety        | `static mut` introduces risk and requires `unsafe`. |
| Best Practice | Prefer `const` and safe global abstractions.        |

- Distinguishes compile-time values from global storage
- Encourages safe and explicit global state management
- Prevents misuse of unsafe shared data
- Supports predictable, performant Rust programs

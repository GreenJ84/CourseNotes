# **Topic 3.3.4: Foreign Function Interface (FFI)**

The Foreign Function Interface (FFI) is the boundary where Rust code interacts with code compiled under a different language model, usually C. FFI enables reuse of existing libraries, operating system APIs, and hardware-facing code, but Rust's safety guarantees do not cross this boundary automatically.

At FFI boundaries, you must manually uphold contracts for ABI compatibility, data layout, pointer validity, ownership, threading, and error semantics. High-quality FFI design means keeping this risk concentrated in small unsafe adapters while exposing safe, idiomatic Rust APIs.

## **Learning Objectives**

- Define ABI and explain why ABI mismatches are correctness bugs
- Use extern declarations and symbol linkage correctly
- Apply repr(C) and related layout rules to shared data structures
- Pass strings, buffers, and structs safely across language boundaries
- Manage ownership and allocator boundaries without leaks or double free
- Handle panics, errors, and callbacks safely across FFI boundaries
- Build safe Rust wrappers over inherently unsafe foreign interfaces

---

## **ABI and Interoperability Contracts**

ABI (Application Binary Interface) specifies binary-level agreements between caller and callee:

- Calling convention (argument passing, return values)
- Stack/register usage
- Symbol naming and linkage
- Data representation and alignment expectations

Important points:

- Rust default ABI is not for cross-language stability
- C ABI via extern C is the most common interop target
- ABI mismatch is not just a compile error risk, it can be runtime UB

> **Senior insight**: If types look correct but ABI is wrong, the failure mode is often silent memory corruption rather than immediate crash.

---

## **Declaring and Calling Foreign Functions**

Foreign functions are declared in extern blocks and called in unsafe contexts.

```rust
use std::ffi::CString;

unsafe extern "C" {
    fn puts(s: *const std::ffi::c_char) -> i32;
}

let msg = CString::new("Hello from Rust").unwrap();

unsafe {
    puts(msg.as_ptr());
}
```

Why this is unsafe:

- Rust cannot verify foreign implementation correctness
- Rust cannot prove pointer/lifetime/aliasing expectations on the C side

---

## **Linking, Symbols, and Name Stability**

FFI requires both declaration correctness and successful symbol resolution at link/load time.

### Linking External Libraries

```rust
#[link(name = "m")]
unsafe extern "C" {
    fn cos(x: f64) -> f64;
}
```

This requests linkage to the platform math library.

### Exporting Rust Functions to Other Languages

```rust
#[no_mangle]
pub extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

What matters:

- extern C gives C-compatible calling convention
- no_mangle preserves symbol name for foreign lookup

> **Senior insight**: Interop bugs are frequently build-system bugs. Correct Rust code still fails if library paths, symbol visibility, or runtime loader settings are wrong.

---

## **Data Layout and Representation Rules**

Rust layout is intentionally flexible unless explicitly constrained.

Use repr(C) for shared structs/enums intended for C interop.

```rust
#[repr(C)]
pub struct Point {
    pub x: i32,
    pub y: i32,
}
```

repr(C) helps preserve:

- Field order
- C-compatible alignment/padding behavior

Still your responsibility:

- Match signedness and width exactly on both sides
- Avoid Rust-only layout assumptions in foreign code

---

## **Passing Strings and Buffers Safely**

### Rust to C String

```rust
use std::ffi::CString;

let s = CString::new("ffi message").unwrap();
unsafe {
    puts(s.as_ptr());
}
```

Why CString:

- C expects null-terminated bytes
- Rust String is UTF-8 with length metadata, not C-compatible by default

### C to Rust String View

```rust
use std::ffi::CStr;

unsafe fn c_str_to_rust(ptr: *const std::ffi::c_char) -> String {
    // Caller must guarantee ptr is valid and NUL-terminated.
    CStr::from_ptr(ptr).to_string_lossy().into_owned()
}
```

### Slices/Buffers

Pass pointer plus length explicitly.

```rust
#[repr(C)]
pub struct Buffer {
    pub ptr: *const u8,
    pub len: usize,
}
```

Never pass Rust-only containers directly (Vec, String, references) unless both sides agree on exact ownership and lifetime contracts.

---

## **Ownership and Allocator Boundaries**

Core rule:

- Memory must be freed by the same allocator/domain that allocated it

Common failure patterns:

- Rust allocates, C frees with free
- C allocates, Rust frees with Box::from_raw

Both can cause UB.

### Safe Allocation Pair Pattern

```rust
#[no_mangle]
pub extern "C" fn create_value() -> *mut i32 {
    Box::into_raw(Box::new(42))
}

#[no_mangle]
pub extern "C" fn free_value(ptr: *mut i32) {
    if ptr.is_null() {
        return;
    }

    unsafe {
        // Reclaims exactly one allocation created by create_value.
        drop(Box::from_raw(ptr));
    }
}
```

> **Senior insight**: FFI memory APIs should be designed as explicit create/free pairs. Ambiguous ownership is the top source of production interop bugs.

---

## **Unwinding, Errors, and Panic Boundaries**

Panics must not unwind through foreign frames unless ABI and toolchain guarantees are explicitly compatible.

Practical guidance:

- Keep extern entry points panic-free
- Convert internal failures to error codes or nullable pointers
- Use Result internally, translate at the boundary

Example boundary style:

```rust
#[no_mangle]
pub extern "C" fn parse_number(input: *const std::ffi::c_char) -> i32 {
    if input.is_null() {
        return -1;
    }

    // In production, add full validation and error mapping.
    0
}
```

---

## **Callbacks and Re-entrancy Considerations**

When C calls back into Rust, your contracts become bidirectional.

You must reason about:

- Callback lifetime validity
- Threading model (which thread invokes callback)
- Re-entrancy and synchronization
- Whether callback may outlive Rust-owned captured state

Use opaque context pointers and explicit register/unregister lifecycle APIs to avoid dangling callback state.

---

## **Building Safe Wrappers Over Unsafe FFI**

Design principle:

- Unsafe FFI at the boundary, safe Rust in the public API

### Wrapper Goals

- Hide raw pointers from callers
- Encode ownership in types and Drop implementations
- Validate inputs before boundary crossing
- Make misuse difficult by construction

### Example Pattern: Owning Handle Wrapper

```rust
pub struct ForeignHandle {
    ptr: *mut i32,
}

impl ForeignHandle {
    pub fn new() -> Option<Self> {
        let ptr = create_value();
        if ptr.is_null() {
            None
        } else {
            Some(Self { ptr })
        }
    }

    pub fn get(&self) -> i32 {
        unsafe { *self.ptr }
    }
}

impl Drop for ForeignHandle {
    fn drop(&mut self) {
        free_value(self.ptr);
    }
}
```

This contains raw pointer handling and centralized cleanup in one place.

---

## **Professional FFI Engineering Checklist**

1. Confirm ABI and calling convention match exactly
2. Use repr(C) for shared layouts and verify field widths/signs
3. Document ownership rules for every pointer parameter/return
4. Pair allocations and deallocations explicitly
5. Prevent panics crossing FFI boundaries
6. Validate null pointers and lengths before dereference
7. Isolate unsafe FFI calls behind small safe wrappers
8. Test boundary behavior with invalid inputs and stress cases

---

## **Professional Applications and Implementation**

FFI is a core technique for integrating Rust into heterogeneous systems:

- Wrapping high-performance C/C++ libraries
- Calling OS and platform APIs
- Gradually replacing legacy modules with Rust
- Building SDKs used across multiple languages
- Embedded firmware and hardware-adjacent software

In mature codebases, FFI modules are treated as high-risk infrastructure: small, documented, and heavily tested.

---

## **Key Takeaways**

| Concept | Summary |
| ------- | ------- |
| ABI | Binary contract for calls, data layout, and linkage across language boundaries. |
| extern | Declares function ABI for importing/exporting symbols. |
| repr(C) | Required for predictable C-compatible layout of shared data structures. |
| Ownership | Allocation and deallocation responsibilities must be explicit and paired. |
| Boundary Safety | Unsafe FFI should be encapsulated behind safe, idiomatic Rust wrappers. |

- FFI enables interoperability but removes automatic Rust safety guarantees at the boundary
- ABI and layout mismatches can produce silent corruption, not just obvious failures
- Strings, buffers, and pointers require explicit validity and lifetime reasoning
- Memory ownership contracts must be clear, documented, and testable
- The best FFI design keeps unsafe boundary code minimal and exposes safe APIs

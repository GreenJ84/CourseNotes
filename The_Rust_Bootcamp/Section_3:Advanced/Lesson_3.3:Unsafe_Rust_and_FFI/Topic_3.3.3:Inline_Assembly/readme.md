# **Topic 3.3.3: Inline Assembly**

Inline assembly lets you emit raw machine-level instructions directly inside Rust code. It exists for cases where you need exact instruction selection, precise register behavior, or hardware interactions that higher-level Rust APIs cannot represent well.

This power comes with a strict cost: the compiler cannot validate most correctness properties of your assembly block. `asm!` is therefore always part of an `unsafe` boundary, and correctness depends on your understanding of architecture, ABI contracts, and optimizer assumptions.

## **Learning Objectives**

- Explain the purpose and appropriate use cases for inline assembly
- Understand `asm!` syntax: templates, operands, constraints, and options
- Model data flow between Rust values and CPU registers/memory
- Reason about clobbers, flags, stack behavior, and calling conventions
- Identify common unsound patterns that lead to UB or miscompilation
- Determine when compiler intrinsics or pure Rust alternatives are safer

---

## **Purpose of Inline Assembly**

Inline assembly is typically used for:

- Accessing instructions not exposed by stable Rust APIs
- Implementing extremely low-level runtime/boot/hardware routines
- Micro-optimizing critical hot paths after profiling
- Issuing CPU barriers, special register operations, or architecture-specific instructions

Common domains:

- Kernels, bootloaders, embedded runtimes
- Cryptography and constant-time primitives
- Context switch and interrupt entry/exit paths
- Performance-sensitive systems code where instruction exactness matters

> **Senior insight**: Reach for `asm!` last, not first. If a safe or intrinsic-based solution gives equivalent machine code, use that. You reduce maintenance and portability risk immediately.

---

## **The `asm!` Macro**

`asm!` is provided by `std::arch::asm` and consists of:

- Provided by `std::arch::asm`
- Allows embedding assembly instructions with structure operands
- Operand bindings (`in`, `out`, `inout`, `lateout`, explicit registers)
- Optional behavior flags (`options(...)`)

### Basic Example

```rust
use std::arch::asm;

unsafe {
  asm!("nop");
}
```

This emits a no-op instruction. It is simple, but still unsafe because inline assembly always bypasses normal compiler reasoning about side effects.

### With Inputs and Outputs

```rust
use std::arch::asm;

let mut x: u64 = 5;

unsafe {
  asm!(
    "add {value}, 1",
    value = inout(reg) x,
  );
}

println!("{}", x); // 6
```

What happens here:

- Compiler places `x` in a general-purpose register (`reg`)
- Assembly reads and updates that register
- Updated register value is written back to `x`

---

## **Operands, Constraints, and Clobbers**

Correct operand specification is where most inline assembly correctness issues are won or lost.

### Inputs (`in`)

Provide read-only values to assembly:

```rust
use std::arch::asm;

let x: u64 = 40;
let y: u64 = 2;
let sum: u64;

unsafe {
  asm!(
    "mov {tmp}, {a}",
    "add {tmp}, {b}",
    a = in(reg) x,
    b = in(reg) y,
    tmp = lateout(reg) sum,
  );
}

println!("{}", sum); // 42
```

### Outputs (`out`, `lateout`, `inout`)

- `out(reg) v`: write-only output
- `lateout(reg) v`: output written after all inputs are consumed
  - helps the allocator by allowing register reuse after inputs are read.
- `inout(reg) v`: read-modify-write operand

### Explicit Registers

You can bind to specific registers if required by instruction semantics:

```rust
use std::arch::asm;

let out: u64;
unsafe {
  asm!(
    "mov rax, 42",
    out("rax") out,
  );
}
```

Only do this when necessary. Over-constraining registers harms optimizer flexibility.

### Clobbers and Side Effects

Any register/flag/memory state modified by assembly must be declared, otherwise the compiler may optimize under false assumptions.

```rust
use std::arch::asm;

let mut x: u64 = 1;
unsafe {
  asm!(
    "add {v}, 1",
    v = inout(reg) x,
    options(nostack),
  );
}
```

If you modify condition flags or touch memory indirectly, declarations/options must reflect that behavior.

> **Senior insight**: Misdeclared clobbers are often "works in debug, fails in release" bugs because optimizer assumptions diverge at higher optimization levels.

---

## **`options(...)`: Compiler Contract Hints**

`options` tells rustc/LLVM what the asm block does not do.

Common options:

- `nostack`: asm does not touch stack pointer or stack memory
- `nomem`: asm does not read/write memory
- `pure`: output depends only on input operands (no side effects)
- `readonly`: reads memory but does not write it

Incorrect options are dangerous. For example, claiming `nomem` when memory is accessed can enable invalid reordering.

---

## **Architecture, ABI, and Calling Convention Reality**

Inline assembly is architecture-specific and ABI-sensitive.

You must reason about:

- ISA differences (x86_64 vs AArch64 vs others)
- Register conventions (caller-saved vs callee-saved)
- Stack alignment requirements
- Flag register semantics
- Platform ABI rules for calls/returns

Implications:

- Code is often non-portable by default
- Seemingly minor instruction changes can violate ABI contracts
- A correct x86_64 block is not automatically valid on ARM

> **Senior insight**: The hard part of inline asm is not writing instructions. It is preserving the compiler's model of the world before and after the block.

---

## **Safety and Correctness Requirements**

Inline assembly bypasses most language-level guarantees.

Key risk categories:

- Register corruption
- Stack corruption
- Memory model violations
- Incorrect optimizer assumptions
- UB via invalid pointer or lifetime usage

Developer obligations:

- Describe all operands and modified state accurately
- Preserve ABI and stack invariants
- Respect aliasing and lifetime rules for any referenced memory
- Keep blocks minimal and isolated
- Add comments explaining invariants and assumptions

### Example: Bad Pattern (Undeclared Effects)

```rust
use std::arch::asm;

unsafe {
  asm!(
    "mov rax, 0",
    // If this block changes state that the compiler relies on
    // without declaring it, behavior can become incorrect.
  );
}
```

The issue is not only register choice. The issue is incomplete contract declaration.

---

## **Intrinsics vs Inline Assembly**

Intrinsics are compiler-recognized low-level operations exposed as Rust functions.

Benefits over inline assembly:

- Better portability across CPUs and toolchains
- Better integration with optimizer and type system
- Lower maintenance burden
- Clearer code reviews

```rust
use std::arch::x86_64::_mm_add_epi32;
```

### Prefer Intrinsics When

- Equivalent operation exists in `std::arch` or stable Rust APIs
- Portability and maintainability matter
- You do not require exact instruction text control

### Use Inline Assembly When

- No suitable intrinsic exists
- You need strict instruction sequencing/control
- You are in kernel/embedded/runtime code with hardware-level constraints

---

## **Patterns for Maintainable `asm!`**

1. Keep asm blocks tiny and single-purpose
2. Encapsulate in small functions with narrow APIs
3. Gate by target architecture using `cfg(target_arch = "...")`
4. Prefer named operands for readability
5. Document invariants near each block (`// Safety:` assumptions)
6. Benchmark and profile before and after introducing asm
7. Keep a pure-Rust fallback when practical

---

## **Professional Applications and Implementation**

Inline assembly appears in advanced systems software where exact machine behavior matters:

- Interrupt handling and context switches
- CPU feature probing and control register interaction
- Cryptographic primitives using specialized instructions
- Embedded firmware with direct peripheral access
- High-frequency hot loops where instruction-level control is validated by profiling

In mature codebases, these blocks are scarce, heavily reviewed, and surrounded by strong tests.

---

## **Key Takeaways**

| Concept | Summary |
| ------- | ------- |
| Inline Assembly | Direct machine-level control when high-level Rust is insufficient. |
| `asm!` Macro | Structured interface with explicit operand and side-effect contracts. |
| Constraints | Define register/memory data flow between Rust and assembly. |
| Options/Clobbers | Critical for preserving compiler correctness assumptions. |
| Safety | Entirely manual; incorrect contracts can cause UB or miscompilation. |
| Intrinsics | Prefer first when available for portability and maintainability. |

- Inline assembly is powerful but should be rare and deliberate as it is inherently unsafe
- Correctness depends on ABI, architecture, and optimizer-aware contracts
- Most severe bugs come from incomplete side-effect declarations
- Intrinsics and safe abstractions are preferred whenever possible
- Isolate asm usage and document assumptions like security-critical code

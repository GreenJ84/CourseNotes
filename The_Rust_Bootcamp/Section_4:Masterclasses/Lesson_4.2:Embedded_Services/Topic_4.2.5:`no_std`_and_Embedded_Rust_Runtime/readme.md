# **Topic 4.2.5: `no_std` and Embedded Rust Runtime**

Embedded Rust operates in environments where the standard library (`std`) is often unavailable due to the absence of an operating system and limited hardware resources. Instead, programs rely on lower-level crates like `core` and optionally `alloc`, while providing their own runtime components such as entry points, memory initialization, and panic handling. This topic explores how Rust programs are structured in `no_std` environments, how the runtime is constructed manually, and how to design safe, efficient systems under strict constraints.

At this level, runtime design is part of application design. Decisions about memory layout, panic behavior, allocation strategy, and initialization order directly affect correctness, performance, and field reliability.

## **Learning Objectives**

- Differentiate between `std`, `core`, and `alloc` in Rust
- Understand why embedded systems typically use `no_std`
- Analyze runtime responsibilities in OS-less environments
- Configure custom runtime components including entry points and panic handlers
- Apply memory management strategies suitable for constrained systems
- Evaluate portability limitations across embedded targets
- Implement idiomatic embedded Rust patterns using conditional compilation and minimal binaries
- Reason about startup responsibilities normally handled by an operating system
- Choose runtime and allocation strategies based on determinism and failure behavior
- Structure code so hardware-specific details stay isolated from portable logic

---

## **`std`, `core`, and `alloc`**

The Rust ecosystem provides multiple layers of libraries to accommodate different environments:

### `std` (Standard Library)

- Provides:
  - File I/O
  - Networking
  - Threads and synchronization primitives
  - Heap allocation (`Vec`, `Box`, etc.)
- Depends on:
  - Operating system services
  - System calls

`std` is designed for hosted environments where OS services exist. In embedded bare-metal targets, those assumptions usually do not hold, which is why linking against `std` is often impossible or undesirable.

### `core`

- Minimal, platform-agnostic Rust library
- Available in all Rust environments

**Provides:**

- Primitive types and operations
- Traits (`Copy`, `Clone`, `Iterator`)
- Memory utilities (`Option`, `Result`)
- No heap allocation, no OS interaction

`core` gives you language fundamentals without platform services. Most embedded application logic should be expressed in terms of `core` so it stays portable and testable.

### `alloc`

- Optional crate enabling heap allocation in `no_std`

**Provides:**

- `Vec`, `Box`, `String`
- Requires:
  - A global allocator implementation

`alloc` sits between `core` and `std`: you get dynamic data structures, but you still do not get OS-backed services. Whether to enable it depends on your timing and memory guarantees.

> **Key Insight:**
> `core` is always available, `alloc` is optional, and `std` is typically unavailable in embedded systems.
>
> In practice, many robust embedded systems are built with `core` only, adding `alloc` only when its flexibility clearly outweighs determinism and memory-fragmentation concerns.

---

## **Why Embedded Targets Avoid `std`**

- No operating system to support system calls
- Limited memory and storage
- Need for deterministic execution
- Avoidance of hidden runtime costs
- Requirement for predictable startup and failure behavior

### Implication

Programs must explicitly manage:

- Memory
- Initialization
- Hardware interaction
- Error and panic policy
- Interrupt and concurrency boundaries

This explicitness is a major advantage when building high-reliability systems, because runtime behavior is visible and reviewable rather than hidden inside a large general-purpose runtime.

---

## **Runtime Without an Operating System**

Without an OS, the Rust runtime must be defined by the developer. This includes:

### Startup Sequence

In embedded systems, there is no OS loader. Instead:

1. CPU resets
2. Program counter jumps to a fixed memory address
3. Startup code initializes memory
4. Control transfers to application entry point

That startup path is part of your trusted computing base. If it is misconfigured, the application can fail before Rust code even begins to run.

### Entry Points

Instead of `fn main()`, embedded Rust uses custom entry points:

```rust
#![no_std]
#![no_main]

#[entry]
fn main() -> ! {
    loop {}
}
```

- `#[entry]` provided by runtime crates (e.g., Cortex-M ecosystem)
- Return type `!` (never) indicates non-returning function
- Entry wiring usually depends on target-specific runtime support and vector table setup

The non-returning signature is not cosmetic. Embedded firmware is expected to own the CPU for the program lifetime. If `main` were allowed to return, it would create undefined behavior since there is no OS to return to.

### Memory Initialization

- Initialize `.data` (initialized variables)
- Ensure `.bss` (zero-initialized variables) is cleared
- Set up stack pointer
- Configure vector table and interrupt handlers (target dependent)
- Optionally initialize clocks and low-level platform state before application logic

> **Advanced Insight:**
> This process is typically handled by startup assembly or runtime crates, but must be correctly configured.
>
> A subtle startup mismatch between linker configuration and runtime expectations can produce failures that look like random memory corruption.

### Panic Handlers

Define behavior when a panic occurs:

```rust
use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
```

#### Strategies

- Halt system (infinite loop)
- Trigger watchdog reset
- Log error (if output available)
- Enter a safe degraded mode where possible

Panic policy is a system-level decision. In development, verbose panic output is useful. In production, deterministic recovery behavior is often more important.

### Linker Scripts

- Define memory layout (flash, RAM regions)
- Control placement of code and data
- Reserve areas for stack, heap, and memory-mapped peripherals where required
- Ensure sections align with target boot and flash programming requirements

Example concepts:

- `.text` → program code
- `.data` → initialized variables
- `.bss` → zero-initialized variables

Linker configuration is part of runtime correctness. If sections overlap or exceed memory regions, the firmware may build but fail unpredictably at runtime.

#### Memory Layout Basics

- Flash: non-volatile program storage
- RAM: runtime data storage
- Stack: function call frames
- Heap (optional): dynamic allocation

Understanding this layout is essential for debugging hard faults, tuning stack size, and verifying that worst-case memory usage stays within hardware limits.

---

## **Memory Management Constraints**

In embedded systems, memory management is a critical design aspect. The choice between static allocation and heap usage has significant implications for predictability and reliability.

### Static Allocation

- Preferred approach in embedded systems
- Predictable memory usage
- No runtime allocation overhead
- Easier to verify in safety-critical and real-time systems

Static allocation trades flexibility for determinism. That trade-off is often desirable in firmware where bounded behavior matters more than dynamic structure growth.

#### Stack Discipline

- Limited stack size
- Avoid deep recursion
- Monitor stack usage carefully
- Watch interrupt nesting and large temporary values

> **Advanced Insight:**
> Stack overflows in embedded systems often result in silent corruption rather than explicit crashes.
>
> Because failure can be silent, stack budgeting and measurement should be part of validation, not an afterthought.

### Heap Usage with `alloc`

- Requires custom allocator
- Introduces:
  - Fragmentation risk
  - Non-deterministic behavior
  - Additional failure paths (allocation errors)

Heap use is not automatically wrong in embedded systems, but it should be intentional, bounded, and observable.

---

## **Portability and Limits**

The portability of embedded Rust code depends on how well it abstracts hardware differences while still respecting the realities of the target environment.

### Portability Advantages

- `core` enables cross-platform compatibility
- Hardware abstraction layers improve reuse
- Trait-based driver design can separate protocol logic from target specifics

### Portability Limits

- Hardware-specific registers and peripherals
- Architecture-specific toolchains
- Differences in memory layout and capabilities
- Different interrupt models and startup requirements

> **Advanced Insight:**
> True portability in embedded Rust requires abstraction at both the hardware and runtime levels.
>
> Portable code is usually built in layers: platform-independent logic at the top, target-specific board support at the boundary.

---

## **Practical Embedded Rust Patterns**

When building embedded Rust applications, certain patterns emerge as best practices for managing complexity while maintaining control over runtime behavior.

### Minimal Binaries

- Reduce code size and dependencies

```rust
#![no_std]
#![no_main]
```

- Avoid unnecessary features
- Keep binary behavior explicit and auditable

### Feature Flags

- Enable/disable functionality at compile time

```toml
[features]
default = []
logging = []
```

Feature flags are useful for building development and production variants from the same codebase while keeping runtime costs under control.

### Conditional Compilation

- Adapt code to different targets

```rust
#[cfg(target_arch = "arm")]
fn platform_specific() {}
```

Conditional compilation should be used to isolate platform details, not to fragment business logic across many target-specific branches.

### Separation of Concerns

- Isolate hardware-specific code
- Keep logic portable
- Separate startup/runtime glue from domain behavior

This separation makes testing easier: protocol and control logic can often be tested on host targets even when hardware access cannot.

### Safe Abstractions Over Unsafe Code

- Encapsulate unsafe runtime setup
- Provide clean, safe APIs
- Document invariants required for unsafe blocks to remain correct

Unsafe code is unavoidable at the hardware boundary, but its scope should remain small enough for careful review.

---

## **Professional Applications and Implementation**

Mastery of `no_std` and custom runtime configuration is essential for:

- Firmware development on micro-controllers
- Real-time systems without operating systems
- Safety-critical embedded applications
- Resource-constrained IoT devices
- High-performance, low-level system components

Rust enables:

- Precise control over memory and execution
- Elimination of runtime overhead
- Strong compile-time guarantees in unsafe environments
- Explicit failure behavior for panic and allocation paths
- Maintainable architecture as firmware complexity grows

In production embedded systems, runtime quality is visible in startup reliability, fault recovery behavior, and debuggability under constrained conditions.

---

## **Key Takeaways**

| Concept Area      | Summary                                                                         |
| ----------------- | ------------------------------------------------------------------------------- |
| Library Layers    | `core` provides fundamentals, `alloc` adds heap support, `std` requires an OS.  |
| `no_std`          | Enables Rust to run in OS-less, resource-constrained environments.              |
| Runtime           | Developers must define entry points, memory initialization, and panic behavior. |
| Memory Management | Static allocation preferred; heap usage is limited and controlled.              |
| Portability       | Achieved through abstraction but constrained by hardware differences.           |
| Patterns          | Minimal binaries, feature flags, and conditional compilation are essential.     |

- Embedded Rust replaces OS-provided runtime with explicit configuration
- `no_std` is fundamental for working in constrained environments
- Memory and execution must be tightly controlled and predictable
- Safe abstractions are critical when working close to hardware
- Rust provides a powerful foundation for building reliable embedded systems
- Runtime configuration is not boilerplate; it is part of system correctness
- Determinism depends on allocation policy, stack discipline, and panic strategy
- Well-layered design enables portability without hiding hardware realities

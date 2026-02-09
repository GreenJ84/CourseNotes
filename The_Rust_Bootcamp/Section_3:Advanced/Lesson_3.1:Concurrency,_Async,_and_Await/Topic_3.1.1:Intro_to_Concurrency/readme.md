# **Topic 3.1.1: Computer Fundamentals for Concurrency**

This topic establishes the foundational runtime model of programs, processes, and threads at the operating system level. Understanding these concepts is essential before diving into Rust's concurrency features.

## **Learning Objectives**

- Explain concurrency, distinguish it from parallelism, and understand their relationship
- Explain programs, processes, and threads at the operating system level
- Describe the memory model: shared heap vs. separate stacks
- Understand context switching, OS scheduling, and CPU core utilization
- Identify data races and understand why they occur

---

## **What is Concurrency?**

Concurrency is the structured coordination of multiple units of execution within a system. At its core, concurrency is about managing complexity when multiple tasks overlap in time—whether truly simultaneous (on separate cores) or interleaved (time-sliced on a single core).

### The Abstraction

Concurrency abstracts away the physical execution details, allowing you to reason about programs as collections of independent activities that coordinate through shared memory, message passing, or event-driven protocols. This abstraction is powerful but dangerous: it permits reasoning about program behavior as if all activities happen in some interleaved order, yet the actual hardware execution on modern multi-core systems creates genuine parallelism.

> **Senior Insight:** Concurrency is fundamentally about reasoning under partial information. You cannot know the exact interleaving at runtime; therefore, your code must be correct for *all possible interleavings*. This is why compile-time guarantees (which we'll see in Rust) are so valuable—they eliminate entire classes of interleaving bugs before execution.

### Parallelism

Parallelism refers to multiple computations executing simultaneously on distinct physical resources (CPU cores). A perfectly parallel program with no synchronization overhead scales linearly with core count, but this is rare. Real parallelism is constrained by:

- **Amdahl's Law**: If a program has a serial portion that must run single-threaded, the speedup from parallelization is bounded by the inverse of that serial fraction
- **Load imbalance**: Uneven work distribution causes threads to idle while others work
- **Synchronization overhead**: Locks, atomic operations, and memory barriers introduce latency and cache coherency costs

### Critical Distinction

| Term | Definition | Requires | Example | Guarantees |
| ---- | ---------- | -------- | ------- | ---------- |
| **Concurrency** | Multiple tasks make progress, interleaved or parallel | OS scheduler, language runtime | 100 tasks on a 4-core system | Tasks advance, but when/how unknown |
| **Parallelism** | Multiple tasks execute simultaneously on separate cores | Multiple CPU cores | 4 tasks on a 4-core system running simultaneously | True simultaneity on distinct hardware |

A system is **concurrent** if it can handle multiple tasks that may make progress independently, regardless of core count. A system is **parallel** only when tasks truly execute simultaneously on distinct physical resources.

> **Senior Insight:** A system can be concurrent without being parallel (single core, time-sliced threads), but parallelism always implies concurrency. A concurrent design can be deployed on a single core for correctness verification, then scaled to multiple cores for performance—provided the design avoids implicit timing assumptions.

---

## **Programs, Processes, and Threads**

Understanding the OS execution model is essential for reasoning about resource consumption, isolation guarantees, and performance characteristics.

### Definitions and Relationships

A **program** is a static binary stored on disk containing executable code (`.text` segment), initialized and uninitialized data (`.data` and `.bss` segments), and metadata (symbol tables, relocation information).

A **process** is a running instance of that program—a dynamic entity managed by the OS with its own:

- Virtual address space (isolated via page tables)
- File descriptor table
- Signal handlers
- Resource limits
- Process ID (PID)

A **thread** is the unit of execution within a process, a schedule-able entity with:

- Independent program counter (instruction pointer)
- Own stack
- Register state
- Thread-local storage (TLS)
- **Shared** virtual address space with sibling threads

### Process Isolation and Security

Each process operates in a separate virtual address space, enforced by the memory management unit (MMU) and operating system kernel. This isolation is fundamental to modern OS security:

- **Virtual memory translation**: Every memory access is translated from virtual to physical addresses using per-process page tables
- **Page table enforcement**: The MMU hardware enforces that a process can only access pages its page table maps
- **Kernel boundaries**: Any attempt to access another process's memory triggers a page fault, which the kernel handles as an exception
- **Fault containment**: A crash (segmentation fault, division by zero) in one process cannot directly corrupt another process's memory

#### Performance implication

Process isolation comes at a cost. Context switching between processes requires:

- Saving and restoring all CPU registers
- Flushing the TLB (translation lookaside buffer), which caches recent page table entries
- Invalidating the L1/L2 CPU caches (on some architectures)
- Potentially switching page tables in protected memory regions

A process context switch costs **~1-10 microseconds** on modern hardware, plus the cost of cache misses after the switch.

### Inter-Process Communication (IPC)

Processes cannot directly share memory (by design). Communication requires explicit OS-mediated mechanisms:

- **Pipes**: Unidirectional data flow, typically used between parent/child processes
- **Sockets**: Network-like endpoints for bidirectional communication (Unix domain sockets are fast; TCP/IP adds network overhead)
- **Shared memory segments**: OS-allocated regions explicitly mapped into multiple processes' address spaces (requires synchronization via semaphores)
- **Message queues**: OS kernel queues messages between processes

Each IPC mechanism involves kernel context switches and data copying (marshalling), adding latency. This is why processes are typically used for fault isolation in systems like browser tabs, not for fine-grained parallelism.

### The Threading Model

Within a process, threads are cheaper than processes:

- **Shared address space**: All threads within a process see the same memory; no virtual address translation differences (each thread has identical page tables)
- **Cheap context switching**: Switching between threads requires only saving/restoring CPU registers and the program counter; TLB and cache remain valid
- **Lightweight creation**: Creating a thread (~few microseconds) is much faster than creating a process (~milliseconds)
- **Simplified communication**: Threads access shared memory directly; no IPC overhead

A process always begins with a single **main thread**. Additional threads are spawned explicitly. All threads:

- Share the same virtual address space
- Share the same open file descriptors
- Share the same signal handlers
- Run the same code (though possibly different functions)
- Have independent execution state (registers, stack, program counter)

> **Senior Insight:** Threads are cheaper than processes in resource cost, but their shared address space means bugs in one thread (buffer overflows, use-after-free) can corrupt the entire process. This is where language-level memory safety guarantees become invaluable.

---

## **Memory Model: Shared Heap vs. Separate Stacks**

This distinction is the foundation for understanding what data requires synchronization in concurrent programs.

### Memory Layout in Multithreaded Processes

Understanding the memory layout of a multithreaded process is essential for reasoning about isolation, performance, and resource consumption.

#### Virtual Address Space Organization

A process's virtual address space is partitioned into distinct regions, each with different access patterns and sharing semantics:

```text
┌────────────────────────────────────────────────────┐
│           Process Virtual Address Space            │
│          (Same for all threads in process)         │
├────────────────────────────────────────────────────┤
│  [HIGH ADDRESS - typically 0xFFFFFFFF on 32-bit]   │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ Stack (Thread N) ← Grows downward            │  │
│  │ ┌─ Return addresses (call stack)             │  │
│  │ ├─ Local variables (automatic storage)       │  │
│  │ ├─ Function arguments (passed by value)      │  │
│  │ ├─ Register spill slots (compiler-managed)   │  │
│  │ └─ Alignment padding                         │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ─────────────────────────────────────────────     │
│      [Guard page - protection boundary]            │
│      Access causes stack overflow exception        │
│  ─────────────────────────────────────────────     │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ Stack (Thread 2) ← Grows downward            │  │
│  │ (Completely isolated from Thread 1's stack)  │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ─────────────────────────────────────────────     │
│      [Guard page - protection boundary]            │
│  ─────────────────────────────────────────────     │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ Stack (Thread 1) ← Grows downward            │  │
│  │ (Main thread's stack)                        │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ─────────────────────────────────────────────     │
│      [Guard page - protection boundary]            │
│  ─────────────────────────────────────────────     │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ [Heap - Grows upward →]                      │  │
│  │ (SHARED by all threads)                      │  │
│  │ ┌─ Thread 1 allocations (references, boxes)  │  │
│  │ ├─ Thread 2 allocations (mutexes, channels)  │  │
│  │ ├─ Thread 3 allocations (locks, data)        │  │
│  │ ├─ Fragmentation from freed allocations      │  │
│  │ └─ Unallocated heap space (available)        │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ Data Segment (initialized, writable)         │  │
│  │ ├─ Global variables (mutable statics)        │  │
│  │ ├─ Static const values                       │  │
│  │ └─ Lazily-initialized thread-local storage   │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ Code Segment (.text, read-only, executable)  │  │
│  │ ├─ Machine instructions (function code)      │  │
│  │ ├─ String literals and constants             │  │
│  │ ├─ Virtual table pointers (for trait objects)│  │
│  │ └─ Relocation metadata (linker info)         │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  [LOW ADDRESS - typically 0x00000000 on 32-bit]    │
│  (Unmapped, causes segmentation fault on access)   │
└────────────────────────────────────────────────────┘
```

#### Shared Heap: The Synchronization Requirement

The heap is the **only writable memory shared across threads**. All dynamic allocations live on the heap:

**Why synchronization is mandatory:**

- Multiple threads can hold pointers to the same heap allocation
- Any thread can write to heap memory it owns or borrows mutably
- Simultaneous reads and writes create data races
- The allocator itself must be thread-safe

#### Per-Thread Stacks: Automatic Isolation

Each thread receives its own dedicated stack, typically **1-2MB in size**. This stack is completely isolated from other threads' stacks:

**Stack isolation guarantees:**

- Local variables on Thread A's stack are physically unreachable from Thread B
- Stack memory is automatically freed when a function returns (no manual deallocation)
- Each thread has independent growth: one thread's deep recursion doesn't affect others
- Type systems can prevent sharing stack-local references across threads

#### Guard Pages: Stack Overflow Protection

Between each thread's stack region sits a **guard page**—a read-only memory page that immediately precedes the stack:

**How guard pages work:**

1. When a thread's stack grows beyond its allocated region, it accesses the guard page
2. The MMU (memory management unit) raises a page fault exception
3. The OS kernel catches this exception and terminates the thread with a stack overflow error
4. Other threads' stacks remain unaffected

**Guard page size:** Typically 4KB (one page on x86/x64), but configurable when creating threads.

#### Thread-Local Storage (TLS)

Beyond the stack, each thread can have thread-local storage for values that should be per-thread but not stack-allocated.

### Key Implications for Developers

| Region | Sharing | Access Speed | Synchronization Required |
| ------ | ------- | ------------ | ---------------------- |
| **Stack** | Per-thread | Ultra-fast (~1 cycle) | None |
| **Heap** | All threads | Fast (~10 cycles) | Yes |
| **TLS** | Per-thread | Fast (~2-3 cycles) | None |
| **Code** | All threads | N/A (read-only) | None |
| **Data** | All threads | Fast (~10 cycles) | Yes, if mutable |

- **Heap is shared:** All threads can allocate on and access the same heap. This enables sharing complex data structures (via pointers and references) but requires synchronization when multiple threads access the same allocation.
- **Each thread has its own stack:** Local variables are allocated on the thread's private stack, making them naturally isolated.
- **Stack overflow is thread-local:** If one thread exhausts its stack (via deep recursion or large stack allocations), it triggers a page fault in its guard page, causing that thread to panic. Other threads' stacks remain unaffected.
- **Performance insight:** Stack allocation is essentially free (increment stack pointer), while heap allocation requires coordination with the global allocator and potential locking.
- **Safety insight:** Type systems that prevent stack references from escaping threads ensure isolation. Only heap references can be safely shared (with proper synchronization).

---

## **Context Switching and OS Scheduling**

Modern operating systems use **pre-emptive multitasking**, where the OS kernel controls thread execution without cooperation from the application. This is essential for preventing a misbehaving thread from starving others but introduces non-deterministic scheduling behavior.

### Scheduling Mechanics

The OS kernel maintains a **run queue** of ready threads and a **scheduler** that selects which thread runs:

1. **Time slice allocation**: Each thread receives a time quantum (typically 10-100ms, depends on OS and configuration)
2. **Execution**: The thread runs until the time quantum expires or it blocks on I/O
3. **Preemption**: The OS's timer interrupt fires (e.g., every 10ms), triggering the scheduler
4. **Context switch**: The scheduler saves the current thread's state and loads the next thread's state
5. **Resume**: The next thread executes from where it was previously preempted

**Key point:** A preemption can occur at *any* instruction boundary, not just at explicit synchronization points. This is why unprotected shared memory access is dangerous—ANY interleaving is possible.

### Context Switch Overhead

Context switching involves several expensive operations:

```text
Save Current Thread State:
  ├─ Push 16+ general-purpose CPU registers
  ├─ Save instruction pointer (program counter)
  ├─ Save condition flags and other control registers
  └─ Flush CPU pipeline (cycles are lost)

TLB (Translation Lookaside Buffer) Flush:
  └─ On context switch, the TLB becomes invalid
   (contains cached translations for the previous process/context)

Load Next Thread State:
  ├─ Pop next thread's registers from kernel memory
  ├─ Load instruction pointer (jump to next instruction)
  ├─ Restore condition flags
  └─ Refill CPU pipeline

Cache Effects:
  ├─ CPU caches are NOT flushed (same process, same address space)
  ├─ However, if another process runs, caches become mostly useless
  └─ Cache cold start adds latency after switching back
```

**Measured overhead:** On modern x86 systems, a context switch costs **~1-10 microseconds** for lightweight operations (register save/restore) plus **~100-500 nanoseconds** per TLB entry flush. The real cost is indirect: the next thread likely experiences cache misses and must rebuild its working set in the CPU caches.

### The Cost of Lock Contention

When multiple threads compete for a lock, context switching overhead compounds. When a thread tries to acquire a locked mutex, it:

1. Checks if the lock is available (fast path, nanoseconds)
2. If locked, enters a spin loop (busy-waiting, wasting CPU cycles)
3. After spinning for a threshold, yields the CPU (context switch)
4. Blocks waiting for the lock holder to release it
5. When woken, competes with other waiting threads

At high contention, the scheduler constantly context switches between threads waiting on the lock and the thread holding it. Each context switch costs ~1-10µs, and modern locks spin before yielding (adding more CPU cost). This is why lock contention is a critical performance bottleneck.

> **Senior Insight:** The cost of a lock is not just the lock operation itself; it's the contention tax paid through context switches, cache misses, and CPU stalls. At scale, reducing lock contention by 10% can provide 2-3x throughput improvement.

---

## **CPU Cores and True Parallelism**

The number of physical CPU cores is the hard limit on true parallelism. Understanding this constraint is essential for performance reasoning.

### Single Core: Time-Slicing

On a single-core system, threads are multiplexed via time-slicing. The scheduler allocates each thread a time quantum (typically 10-100ms). When the quantum expires, a context switch occurs:

```text
Time ─────────────────────────────────────────────────────>

Thread A: [10ms execution] [preempted] ← Time slice expires
Thread B:                   [10ms execution] [preempted]
Thread C:                                     [10ms execution]
Thread A:                                                   [10ms execution]

Single core, interleaved execution
All threads appear to run concurrently, but only one executes at any instant
```

**Behavior:** Threads make progress, but slowly. Each context switch adds latency. Threading on a single core is primarily useful for structuring concurrent I/O (e.g., web server handling multiple clients); it provides no speedup for CPU-bound work.

### Multi-Core: True Parallelism

With N CPU cores, up to N threads can execute simultaneously:

```text
Core 1: [Thread A ────────────────────────────>]
Core 2: [Thread B ────────────────────────────>]
Core 3: [Thread C ────────────────────────────>]
Core 4: [Thread D ────────────────────────────>]

4 cores, 4 threads in parallel
If workload is evenly distributed, speedup ≈ 4x
```

If the number of runnable threads exceeds the core count, threads are time-sliced among available cores:

```text
Core 1: [Thread A ──] [C ──] [E ──] [A ──>
Core 2: [Thread B ──] [D ──] [F ──] [B ──>
Core 3: [Thread C ──] [E ──] [A ──] [C ──>
Core 4: [Thread D ──] [F ──] [B ──] [D ──>

4 cores, 8 threads
Threads interleave on available cores
Effective parallelism = 4x, but each thread gets 50% of a core's time
```

### Scaling Laws and Amdahl's Law

The speedup from parallelization is bounded by Amdahl's Law:

```text
Speedup = 1 / (S + (1 - S) / N)

Where:
  S = serial fraction (code that must run on one core)
  N = number of cores
```

If 10% of your code is serial and 90% is parallelizable:

```text
Speedup(4 cores) = 1 / (0.1 + 0.9 / 4) = 1 / 0.325 ≈ 3.08x (not 4x)
Speedup(16 cores) = 1 / (0.1 + 0.9 / 16) = 1 / 0.156 ≈ 6.4x (not 16x)
```

Even small serial bottlenecks (locks, synchronization, I/O serialization) limit speedup. This is why lock-free algorithms and message-passing are valuable in minimizing serialization points.

---

## **Data Races and Memory Safety**

A **data race** occurs when:

1. Two or more threads access the same memory location simultaneously
2. At least one access is a write
3. There is no synchronization preventing concurrent access

Data races cause undefined behavior: the program may crash, produce incorrect results, or exhibit arbitrary behavior.

### Why Data Races Are Dangerous

Without synchronization, the compiler and CPU can reorder memory operations for optimization. This means:

- **Compiler reordering**: The compiler may rearrange instructions if they appear independent
- **CPU out-of-order execution**: Modern CPUs execute instructions out of program order
- **Memory visibility**: Writes from one core may not be immediately visible to other cores
- **Torn reads/writes**: Non-atomic operations may be partially visible to other threads

These optimizations are safe in single-threaded code but create race conditions in multi-threaded code.

### Preventing Data Races

Data races can be prevented through:

1. **Mutual exclusion**: Locks (mutexes) ensure only one thread accesses data at a time
2. **Atomic operations**: CPU-level atomic instructions guarantee thread-safe access
3. **Message passing**: Threads communicate by sending data, not sharing memory
4. **Immutability**: Read-only data cannot race
5. **Thread confinement**: Data owned by a single thread

> In the next topic, we'll see how Rust enforces these patterns at compile time through its type system.

---

## **Professional Applications and Implementation**

### Real-World Concurrency Patterns

Concurrency concepts directly apply to practical systems:

- **Web servers**: Handle thousands of concurrent client connections using thread pools or async I/O, avoiding per-client process overhead
- **Database engines**: Use thread pools for query execution, with locks protecting shared buffer caches and transaction logs
- **Game engines**: Spawn threads for physics simulation, rendering, and I/O, coordinating via message passing or shared data with careful synchronization
- **System utilities**: Tools like `make`, `xargs`, and `cargo build` parallelize independent work across CPU cores to reduce total execution time

### Debugging Concurrency Issues

Concurrency bugs are notoriously hard to reproduce because they depend on scheduling timing:

- **Heisenbug**: Race condition disappears when you add logging or debugging code (changes timing)
- **Intermittent failures**: Tests pass locally on a 4-core machine but fail in CI on 16-core servers (different scheduling patterns)
- **Tools for detection**: ThreadSanitizer (tsan), Valgrind's Helgrind, and Rust's type system catch many race conditions
- **Testing strategy**: Use stress tests with high thread counts and deliberate delays to expose timing-sensitive bugs

### Performance Tuning in Practice

Understanding OS scheduling and memory models enables optimization:

- **Thread pool sizing**: Too few threads underutilize cores; too many cause context switch overhead. Optimal often equals core count for CPU-bound work
- **Lock-free data structures**: Replace mutex-protected shared data with atomic compare-and-swap operations for high-contention scenarios
- **NUMA awareness**: On multi-socket systems, threads accessing memory on remote sockets incur significant latency; pin threads to cores with local memory
- **CPU affinity**: Explicitly bind threads to cores to reduce cache misses and TLB thrashing

---

## **Key Takeaways**

| Concept | Essential Understanding |
| ------- | ---------------------- |
| **Concurrency vs Parallelism** | Concurrency structures independent tasks; parallelism executes them simultaneously |
| **Processes vs Threads** | Processes are isolated with separate memory; threads share memory within a process |
| **Memory Model** | Shared heap requires synchronization; separate stacks are naturally isolated |
| **Context Switching** | OS scheduler preempts threads; each switch costs ~1-10µs plus cache effects |
| **CPU Cores** | True parallelism limited by physical cores; Amdahl's Law bounds speedup |
| **Data Races** | Occur when multiple threads access shared data without synchronization; cause undefined behavior |
| **Lock Contention** | High contention causes context switches and cache misses; measurable performance impact |
| **Guard Pages** | Protect against stack overflow; one thread's overflow doesn't affect others |

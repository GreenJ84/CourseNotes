# **Topic 4.2.7: Real-Time and Concurrency in Embedded Systems**

Real-time embedded systems are defined not just by correctness of computation, but by correctness in *time*. Systems must produce results within strict, bounded deadlines while maintaining predictable behavior under varying conditions. This topic examines the principles of real-time execution, interrupt-driven design, scheduling strategies, and concurrency patterns in embedded Rust. Emphasis is placed on determinism, timing analysis, and safe coordination of shared resources.

At this level, performance is not measured only by how fast the system can be in the average case. What matters is whether the system can consistently meet its timing obligations under load, contention, and worst-case execution paths.

## **Learning Objectives**

- Define real-time system requirements and constraints
- Design interrupt service routines (ISRs) with proper prioritization and safety
- Compare cooperative and preemptive scheduling models
- Implement safe concurrency patterns in embedded Rust
- Analyze timing behavior including jitter and worst-case execution time
- Apply strategies to ensure deterministic and deadline-compliant execution
- Distinguish between functional correctness and temporal correctness
- Reason about interrupt latency, priority inversion, and schedulability
- Design concurrency boundaries that remain safe under timing pressure

---

## **Real-Time System Requirements**

In order to be classified as a real-time system, the following requirements must be met:

### Bounded Latency

Bounded latency is about guaranteeing a worst-case response window, not just a fast average response. A system that is usually quick but occasionally stalls can still be unacceptable in real-time work.

- Maximum time between event occurrence and system response must be known
- Critical for control systems (e.g., braking, motor control)

In practice, response time is the sum of several components:

- Interrupt latency
- ISR execution time
- Time waiting for the relevant task to run
- Task execution time on the critical path

If any part is unbounded, end-to-end latency is unbounded.

### Predictable Execution

Predictability comes from eliminating sources of nondeterminism that affect timing, not from simply optimizing code paths. A slightly slower but bounded design is often better than a faster but highly variable one.

- Execution time must be consistent across runs
- Avoid variability caused by:
  - Dynamic allocation
  - Blocking operations
  - Unbounded loops

Additional sources of timing variability that often get overlooked:

- Cache behavior and memory bus contention
- Interrupt bursts from multiple peripherals
- Shared resource contention (queues, buffers, drivers)
- Debug instrumentation that changes execution timing

Predictability is strongest when all time-critical paths are intentionally bounded and observable.

### Timing Guarantees

Real-time systems must provide guarantees that certain operations will complete within specified time frames. This often requires careful design of critical paths and separation of concerns.

Timing guarantees are usually expressed as explicit budgets, for example:

- Sensor sample to control output: max 2 ms
- Fault detect to actuator shutdown: max 5 ms
- Telemetry publish: best effort, no hard deadline

Budgets make architecture decisions concrete and testable.

> **Advanced Insight:**
> Real-time correctness = *functional correctness + temporal correctness*.
>
> A system that computes the right answer too late has still failed.

---

## **Interrupts and Interrupt Service Routines (ISR)**

Real-time systems rely heavily on interrupts to achieve low-latency responses to external events. Proper design of ISRs is critical to maintaining system responsiveness and predictability.

### Interrupts

Interrupts let hardware communicate urgency to the CPU. They are the standard tool for reducing reaction time without continuously polling every peripheral.

- Hardware-triggered signals that preempt normal execution
- Used for:
  - I/O events
  - Timers
  - External signals

Interrupts are powerful because they reduce waiting time, but they also introduce preemption points. Every preemption point increases the number of possible execution interleavings that must remain safe and deadline-compliant.

#### Avoiding Long-Running Interrupt Work

- Keep interrupts short and deterministic
- Defer heavy work to main loop or task queue
- Prefer deferring parsing, formatting, and complex control logic out of the interrupt context

Useful ISR pattern:

- Capture minimal data
- Acknowledge/clear interrupt source
- Signal a worker (flag, queue, task notification)
- Return quickly

> Blocking in an ISR can extend interrupt latency for the entire system, which means a local design choice can become a global timing failure.

### ISR

An ISR is the function that executes in response to an interrupt. It must be designed to execute quickly and safely, as it can preempt other critical work. An ISR should do the smallest amount of work necessary to preserve system state and unblock the next stage of processing.

#### Responsibilities

The ISR should usually capture the event, acknowledge the source, and move on. The main goal is to keep the interrupt path short so that other deadlines are not impacted.

- Handle time-critical events quickly
- Minimize latency between interrupt and response

An ISR should also preserve system integrity:

- Avoid partial updates to shared structures
- Avoid calling code with unknown timing behavior
- Keep side effects explicit and minimal

```rust
#[interrupt]
fn TIMER() {
    // minimal, time-critical logic
}
```

### Prioritization

Priority planning matters because not all interrupts are equally urgent. A high-frequency timer can starve lower-priority I/O if it is not designed carefully.

- Interrupts assigned priority levels
- Higher-priority interrupts preempt lower-priority ones

Priority assignment should follow system criticality, not developer convenience. If priorities are chosen ad hoc, low-value periodic work can accidentally starve high-value deadline work.

A practical rule is to assign priorities by deadline tightness and safety impact.


---

## **Scheduling Models**

When multiple tasks or threads of execution are present, the scheduling model determines how the system allocates CPU time. The choice between cooperative and preemptive scheduling has significant implications for responsiveness and complexity.

### Cooperative Execution

In cooperative scheduling, tasks yield control voluntarily. Each task is responsible for giving up the CPU to allow others to run.

```rust
loop {
    task1(); // must yield to allow task2 to run
    task2(); // must yield to allow task1 to run
}
```

**Pros:**

- Simple and predictable
- Easy to reason about when all tasks are well behaved

**Cons:**

- Misbehaving task can block the entire system
- No task can preempt a long-running peer

Cooperative scheduling works well when tasks are short, non-blocking, and disciplined. It becomes risky when one path can accidentally monopolize the CPU. They are often easiest to verify for small firmware because control flow is explicit. To scale safely, they usually require:

- Strict task time budgets
- No blocking in cooperative tasks
- Frequent yield points in non-critical work
- Bounded queues to prevent runaway backlog

### Preemptive RTOS Scheduling

In preemptive scheduling, the operating system can interrupt a running task to switch to another task based on priority or time-slicing.

**Pros:**

- Better responsiveness
- Supports prioritization
- Can isolate workloads into explicit priority classes

**Cons:**

- Increased complexity
- Risk of race conditions
- More difficult to reason about exact timing without measurement

Preemption improves responsiveness, but it also increases the amount of interleaving the system can experience. That makes synchronization and timing analysis more important.Preemptive systems are strong when workload classes differ significantly, but they require disciplined design around:

- Priority assignment and inversion handling
- Blocking primitives and timeout strategy
- Stack sizing per task
- Schedulability validation under worst-case load

### Priority-Based Work Separation

Separating work into priority levels is a common strategy used alongside either scheduling model. In real-time systems, it is best to keep control loops separate from non-critical processing.

- Critical tasks
  - are assigned higher priority for faster processing
  - often run in interrupt context or high-priority tasks
  - are responsible for meeting hard deadlines

- Non-critical work
  - are deferred to lower-priority task queues or background processing
  - non-blocking to avoid impacting critical paths
  - `It can wait, but not forever.`
    - Use queue limits, drop policies, rate limiting, or periodic servicing to avoid task starvation.

Common separation pattern in embedded systems:

- ISR/high-priority task: acquire and validate critical signal
- Mid-priority task: control decisions and actuator updates
- Low-priority task: diagnostics, logging, telemetry, UI

The key is that high-priority paths are short and bounded, while lower-priority paths are intentionally delay-tolerant. This separation is often the simplest way to protect hard real-time work from less urgent processing.

> **Advanced Insight:**
> Well-designed embedded systems separate *real-time critical paths* from *non-critical processing*.
>
> That boundary is one of the most important architectural decisions in the system.

---

## **Concurrency in Embedded Rust**

In embedded systems, concurrency arises from multiple sources: the main loop, ISRs, and potentially multiple tasks in an RTOS or async environment. Managing shared state across these contexts is a key challenge.

### Shared State Management

Shared state is safe only when the system makes ownership and synchronization explicit. The danger is not just corruption, but also subtle timing interactions that cause rare failures. Shared state can exist in various contexts:

- Main loop
- ISRs
- Tasks (RTOS or async)

Shared state failures can manifest as:

- Data races
- Inconsistent state

Failures in real systems are often timing-dependent and hard to reproduce. The design goal is to reduce shared mutable state and make ownership transfer explicit when sharing is unavoidable.

#### Ownership-Based Safety

Ownership helps encode resource ownership in the type system, which reduces the chance that two contexts will mutate the same peripheral state without coordination.

- Rust enforces:
  - Exclusive mutable access
  - Safe sharing via references

In embedded designs, ownership can map to execution domains:

- ISR owns capture buffer until handoff
- Worker task owns processing buffer after handoff
- Driver owns peripheral register interface

This mapping prevents accidental simultaneous mutation across contexts.

> **Advanced Insight:**
> Rust’s ownership model eliminates many concurrency bugs *at compile time*, which is especially valuable in interrupt-heavy systems.
>
> It does not remove timing problems, but it narrows the space of valid shared-state interactions.

### Critical Sections

Critical sections are useful for short, bounded operations. They are a tool for protecting tiny critical regions, not a substitute for good architecture.

- Temporarily disable interrupts to protect shared data

```rust
critical_section::with(|_| {
    // safe shared access
});
```

Critical sections should be short enough that they do not materially degrade interrupt latency. If critical sections become long, architecture should be revisited.

Good practice:

- Copy or swap minimal data inside critical section
- Do expensive work outside it

### Atomic Operations

Atomics allow lock-free synchronization for simple shared values, but they do not magically make all shared state safe. They are a tool for specific use cases, not a general solution.

Atomics are best when the shared state is small and the required operation maps cleanly to atomic read-modify-write behavior, ideal for flags, counters, and simple state transitions. They are usually a poor fit for complex multi-field invariants where lock-free correctness is difficult to reason about.

### Async Approaches

Async can reduce idle spinning and make event-driven code more readable, but it does not remove timing requirements. Async helps with composability, but deadline behavior still depends on wakers, executor configuration, task priorities (if supported), and interrupt integration. Async tasks should still have explicit time budgets

- Frameworks like `embassy` enable async execution in embedded contexts
- Async can improve responsiveness and code clarity for certain workloads

---

## **Timing Verification and Determinism**

There is a difference between writing code that *should* meet deadlines and writing code that is *proven* to meet deadlines. Timing verification is about ensuring that the system can meet its real-time requirements under all conditions.

### Jitter

Jitter matters because it creates uncertainty in when the system actually responds, even if the average response time looks fine.

- Variation in execution timing
- Must be minimized in real-time systems

Should be measured and analyzed to ensure that it does not cause deadline misses and does not get worse under load or contention.

```text
Jitter = Actual Response Time - Expected Response Time
```

Jitter analysis should include both normal operation and stress conditions:

- High interrupt activity
- Maximum communication load
- Worst-case task overlap

### Deadlines

Deadlines are time constraints for task completion, and the type influences architecture.Deadlines can be hard, firm, or soft:

- Hard deadlines must never be missed
  - Missing a hard deadline = system failure
- Firm deadlines lose value after the deadline passes
  - Missing a firm deadline may degrade performance but not cause total failure
- Soft deadlines still matter, but occasional misses may be tolerable
  - Missing a soft deadline may cause minor issues but is generally acceptable

Mixing deadline classes in one system is common. The architecture should ensure soft-deadline work cannot consume resources required by hard-deadline paths.

### Worst-Case Execution Time (WCET)

WCET analysis is only useful if it reflects realistic code paths, compiler settings, and platform behavior. Measured timing and theoretical analysis should inform each other.

- Maximum time a task can take
- Used to guarantee deadlines

WCET must be considered at system level, not only per-function level. A task can meet its own WCET and still miss end-to-end deadlines if queued behind higher-priority or long critical sections.

### Deterministic Design Strategies

When designing for determinism, the goal is to reduce variability in execution time. This often means:

- Avoid dynamic memory allocation
- Limit interrupt nesting
- Use fixed execution paths
- Measure and validate timing
- Prefer bounded queues and fixed-size buffers over unbounded data structures
- Keep unpredictable work out of deadline-sensitive paths
- Use fixed-rate control loops with explicit deadlines
- Bound retry counts in communication/recovery paths
- Avoid hidden blocking in middleware or drivers
- Profile with release builds on target hardware

> **Advanced Insight:**
> Determinism is often achieved by *reducing variability*, not just optimizing speed.
>
> Many real-time bugs come from a path that is usually cheap but occasionally expensive.

---

## **Timing Safety Considerations**

When keeping the timing safe, the system must be designed to handle worst-case scenarios gracefully. This includes accounting for interrupt latency, avoiding priority inversion, and managing resource contention.

### Interrupt Latency

Latency grows when higher-priority work or critical sections delay interrupt servicing. That delay must be accounted for in timing budgets.

- Time from event to ISR execution
- Affected by:
  - Interrupt masking
  - Current execution state

Latency budgeting should include rare but valid states, such as temporarily masked interrupts during critical sections.

### Priority Inversion

Priority inversion is especially dangerous when shared resources sit on the boundary between critical and non-critical work.

- Lower-priority task blocks higher-priority task
- Mitigated via priority inheritance

Priority inversion can also appear indirectly through shared queues, drivers, or long-held critical sections. Prevention depends on minimizing blocking and keeping shared-resource access brief.

### Resource Contention

The shared resource might be a buffer, a peripheral register block, or a queue. Contention is not only about locks; it also includes bus access and interrupt ownership.

- Multiple contexts competing for shared resources
- Requires careful synchronization

Contention management should include backpressure and overload behavior, not just mutual exclusion.

### Verification Techniques

Validation should combine design-time reasoning with measurement on real hardware, because timing failures often depend on target-specific effects.

- Static analysis
- Timing measurement tools
- Hardware tracing

Effective verification usually combines:

- Design-time schedulability reasoning
- On-target measurement in release mode
- Regression checks to catch timing drift over time

---

## **Professional Applications and Implementation**

Real-time and concurrency principles are critical in:

- Automotive control systems (ECUs, braking, steering)
- Industrial automation and robotics
- Aerospace and avionics systems
- Medical devices requiring precise timing
- High-performance embedded networking

Rust provides:

- Strong guarantees against data races
- Deterministic execution patterns
- Safe abstractions for concurrent systems

Those guarantees matter most when the software is interacting with hardware, interrupts, and deadlines at the same time.

In practice, the strongest real-time systems are designed so the critical path is short, measurable, and easy to audit.

---

## **Key Takeaways**

| Concept Area      | Summary                                                                |
| ----------------- | ---------------------------------------------------------------------- |
| Real-Time Systems | Require bounded latency, predictability, and strict timing guarantees. |
| Interrupts        | Enable fast response but must remain short and controlled.             |
| Scheduling        | Cooperative and preemptive models offer different trade-offs.          |
| Concurrency       | Managed through ownership, critical sections, and async patterns.      |
| Timing Analysis   | Jitter, deadlines, and WCET determine system correctness.              |
| Safety            | Deterministic design and careful synchronization are essential.        |

- Real-time systems depend on both correctness and timing guarantees
- Interrupts are essential but must be minimal and well-structured
- Scheduling models determine responsiveness and complexity
- Rust provides strong safety guarantees for concurrent execution
- Deterministic behavior is achieved through disciplined system design
- Real-time behavior should be validated on target hardware, not assumed from source code alone
- Synchronization choices affect both correctness and deadline compliance
- The architecture should separate deadline-critical work from everything else

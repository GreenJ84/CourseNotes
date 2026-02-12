# **Topic 3.1.4: async / .await**

The `async` and `.await` syntax provides structured asynchronous programming in Rust. Under the hood, `async` is syntactic sugar for generating state machines that implement the `Future` trait. These state machines are lazily evaluated and must be driven to completion by an executor.

This model enables zero-cost asynchronous abstractions with precise control over scheduling and execution, forming the backbone of modern Rust networked and I/O-bound systems.

## **Learning Objectives**

- Explain how `async fn` desugars into a `Future` and understand compiler transformations
- Understand the `Future` trait, the polling mechanism, and waker semantics
- Describe how `.await` suspends and resumes execution with precise control flow
- Recognize how the compiler transforms async functions into state machines with drop semantics
- Understand executor responsibilities, work-stealing schedulers, and Tokio's runtime model
- Differentiate Rust futures from JavaScript promises and understand performance implications
- Master advanced patterns: pinning, cancellation, backpressure, and fairness

---

## **The `Future` Trait**

A *Future* is a trait that helps represent a value that may not be available yet but will become available at some point in the future.
Rather than blocking a thread while waiting for a result, Futures allow for asynchronous computation where the result
can be polled, waited upon, when needed.

*Polling* is the mechanism by which a Future is advanced toward completion. When a Future is polled, it attempts to make
progress toward producing its final value. If the Future is not yet ready, the poll operation returns a status indicating
that the caller should try again later. Once the Future is ready, polling returns the computed value.

This pattern enables efficient handling of multiple asynchronous operations without requiring a thread per operation,
allowing for better resource utilization and scalability in concurrent systems.

```rust
pub trait Future {
  type Output;

  fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}

pub enum Poll<T> {
  Ready(T),
  Pending,
}
```

### Key concepts

- `Output` → result type of the async computation
- `poll()` → attempts to make progress; may be called multiple times
- `Poll::Ready(value)` → computation complete, `value` contained
- `Poll::Pending` → not ready yet; future must register a waker


### Polling Mechanism and Waker Protocol

**The polling contract:**

1. Once `Poll::Ready` is returned, the future must never be polled again.
2. A future may return `Poll::Pending` multiple times before becoming ready.
3. When returning `Poll::Pending`, the future **must** have registered a waker that will notify the executor of progress.

#### Execution cycle

1. Executor calls `poll()` on a future
2. Future returns `Poll::Ready(output)` or `Poll::Pending`
3. If `Poll::Ready`, computation is complete; future is dropped
4. If `Poll::Pending`, the future must call `cx.waker().wake()` when progress becomes available
5. `Waker` notifies executor to re-poll the future
6. Executor polls again at the appropriate time

This cooperative model avoids continuously spinning and enables thousands of concurrent tasks on a single thread.

> **Senior insight:** The waker callback is the mechanism preventing busy-waiting. Misunderstanding this leads to dropped futures and hung tasks:

### Custom Future Example with Complete Lifecycle

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll, Waker};
use std::sync::{Arc, Mutex}; // Thread Safe Pointers required
use std::thread;
use std::time::{Duration, Instant};
use std::io;

/// A future that completes after a specified duration.
/// Demonstrates proper waker integration and shared state.
struct DelayedFuture {
  duration: Duration,
  state: Arc<Mutex<DelayState>>,
}

struct DelayState {
  start_time: Option<Instant>,
  waker: Option<Waker>,
}

impl DelayedFuture {
  fn new(duration: Duration) -> Self {
    Self {
      duration,
      state: Arc::new(Mutex::new(DelayState {
        start_time: None,
        waker: None,
      })),
    }
  }

  /// Spawns a background thread to wake the executor when delay is complete
  fn spawn_timer_task(&self) {
    let state = Arc::clone(&self.state);
    let duration = self.duration;

    thread::spawn(move || {
      thread::sleep(duration);

      let mut guard = state.lock().unwrap();
      guard.start_time = Some(Instant::now()); // Mark completion
      
      // Wake the executor—critical step
      if let Some(waker) = guard.waker.take() {
        drop(guard); // Release lock before waking
        waker.wake();
      }
    });
  }
}

impl Future for DelayedFuture {
  type Output = Duration;

  fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
    let mut state = self.state.lock().unwrap();

    // First poll: spawn the background task
    if state.waker.is_none() {
      state.waker = Some(cx.waker().clone());
      drop(state); // Release lock before spawning
      self.spawn_timer_task();
      return Poll::Pending;
    }

    // Check if timer has fired
    if let Some(completion_time) = state.start_time {
      let elapsed = completion_time.elapsed();
      Poll::Ready(elapsed)
    } else {
      // Update waker in case executor changed
      state.waker = Some(cx.waker().clone());
      Poll::Pending
    }
  }
}
```

---

## **`async` Rust**

An `async fn` does **not** execute immediately. It is a function that returns a value implementing `Future`. This is a fundamental design principle that distinguishes Rust futures from eager evaluation models.

```rust
// These are equivalent:
async fn get_value() -> i32 {
  42
}

// Reduce down to:
fn get_value() -> impl std::future::Future<Output = i32> {
  // Returns a struct implementing Future with internal state
}
```

### Critical property: Laziness

Calling `get_value()` creates a future but does not execute it. Execution only progresses when the future is:

- `.await`ed
- Or manually polled via the `Future::poll()` method

Futures are **lazy by design**; this enables fine-grained control over scheduling and resource allocation.

> **Senior insight:** The laziness allows composing futures without memory allocation (unlike promises). Consider:

```rust
// No allocations, no spawning—just composition
async fn build_pipeline() -> Result<String, Error> {
  let step1 = fetch_user(1);  // Not executed
  let step2 = fetch_posts(1); // Not executed
  
  let user = step1.await; // Now users polled
  let posts = step2.await; // Now posts polled
  Ok(format!("{:?} has {} posts", user, posts.len()))
}

// Each component can be tested independently without runtime overhead
```

This laziness is critical for building modular, testable async systems without incurring executor overhead until needed.

---

## **Async Functions as State Machines**

Each `.await` point creates a suspension point where the async function can yield control. The compiler converts your async function into a state machine enum where each variant represents reaching a particular `.await` point.

```rust
async fn multi_step() -> i32 {
  let ftr1 = step_one(); // Future 1 creation
  let ftr2 = step_two(x); // Future 2 creation

  let x = ftr1.await;        // Suspension point 1
  let y = ftr2.await;       // Suspension point 2
  x + y
}

async fn step_one() -> i32 { 10 }
async fn step_two(prev: i32) -> i32 { prev * 2 }
```

### What the compiler generates

```rust
// The state machine enum
#[derive(Debug)]
enum MultiStepState {
  // Initial state before any future creation
  Start,

  // Initial state before any suspension
  AfterFutures {
    step_one_future: std::pin::Pin<Box<dyn std::future::Future<Output = i32>>>,
    step_two_future: std::pin::Pin<Box<dyn std::future::Future<Output = i32>>>,
  },
  
  // After step_one().await completes
  AfterStepOne {
    x: i32,
    step_two_future: std::pin::Pin<Box<dyn std::future::Future<Output = i32>>>,
  },
  
  // After step_two().await completes
  AfterStepTwo {
    x: i32,
    y: i32
  },
  
  // Terminal state (future completed)
  Done,
}
```

### Critical properties

- **No runtime interpreter** — state machine logic is compiled to native code
- **No hidden scheduler** — progress depends entirely on polling
- **Stack-based storage** — state lives on the stack (unless boxed); no heap allocation unless explicitly introduced via `Box<dyn Future>`
- **Zero overhead** — the state machine compiles to efficient machine code

> **Senior insight:** Understanding the generated state machine is crucial for diagnosing performance issues

---

## **Awaiting a Future and Control Flow**

`.await` is not merely syntactic sugar for unwrapping a `Poll` result. It's a suspension point that yields control to the executor and resumes when the awaited future becomes ready.

When you `.await` a future:

1. The current async function suspends
2. Control returns to the executor
3. The executor may poll other futures
4. When the awaited future becomes `Ready`, execution resumes at the next statement

### Example

```rust
use tokio::time::{sleep, Duration, Instant};

async fn io_example() {
  let timer_start = Instant::now();
  println!("T={:?} Before IO", timer_start.elapsed());
  
  let data = fetch_from_network().await;  // Suspension point
  // At this point, other tasks might have executed
  
  println!("T={:?} After IO: {:?}", timer_start.elapsed(), data);
}

async fn fetch_from_network() -> String {
  // Suspend for 1 second; executor can run other tasks
  sleep(Duration::from_secs(1)).await;
  "Response".to_string()
}

// Another task running concurrently
async fn background_task(id: u32) {
  for i in 0..5 {
    println!("Background task {} iteration {}", id, i);
    sleep(Duration::from_millis(400)).await;
  }
}

#[tokio::main]
async fn main() {
  // Run io_example and background tasks concurrently
  tokio::join!(
    io_example(),
    background_task(1),
    background_task(2)
  );
  
  // Output demonstrates interleaving:
  // T=0ms Before IO
  // Background task 1 iteration 0
  // Background task 2 iteration 0
  // Background task 1 iteration 1
  // Background task 2 iteration 1
  // ... (on similar timeline)
  // T≈1000ms After IO: "Response"
}
```

**Suspension is cooperative**, control is yielded explicitly. Unlike preemptive multitasking, the task must hit an `.await` point to yield. Long synchronous sections block the executor thread.

### Cancellation semantics

Dropping a future before completion cancels it. Rust's drop semantics ensure automatic cleanup, no callback chains or explicit abort handling required.

#### Timeout-based cancellation

```rust
use tokio::time::timeout;

let result = timeout(Duration::from_secs(5), fetch_data()).await;
match result {
  Ok(data) => println!("Completed: {:?}", data),
  Err(_) => println!("Exceeded 5 second limit"),
}
```

If `fetch_data()` doesn't complete within 5 seconds, the future is dropped and `Err` is returned. No manual cleanup needed.

#### Racing futures with `select!`

```rust
use tokio::select;

select! {
  data = fetch_from_server() => {
    println!("Server: {:?}", data);
  }
  _ = tokio::time::sleep(Duration::from_secs(1)) => {
    println!("Server took too long, proceeding");
  }
}
```

The loser branch is dropped and cancelled immediately. Other pending I/O is abandoned safely.

#### Aborting spawned task

```rust
let handle = tokio::spawn(background_worker());
tokio::time::sleep(Duration::from_millis(100)).await;
handle.abort(); // Cancel immediately

match handle.await {
  Err(e) if e.is_cancelled() => println!("Task was cancelled"),
  _ => {}
}
```

#### Drop implementations run on cancellation

```rust
struct Resource(String);

impl Drop for Resource {
  fn drop(&mut self) {
    println!("Cleaning up: {}", self.0);
  }
}

let future = async {
  let _res = Resource("file handle".into());
  tokio::time::sleep(Duration::from_secs(100)).await; // Never completes
};

tokio::spawn(future).abort(); // "Cleaning up: file handle" prints
```

This design eliminates callback hell and memory leaks common in promise-based systems.


---

## **Composing Futures**

### Sequential composition

enforces dependencies

```rust
  // Calling sequential() takes as long as task_a + task_b
async fn sequential() -> i32 {
  let a = task_a().await;      // Completes, result available
  let b = task_b(a).await;     // Depends on a
  a + b
}

async fn task_a() -> i32 { 10 }
async fn task_b(prev: i32) -> i32 { prev * 2 }
```

### Parallel composition

enables concurrent execution

```rust
use std::thread::sleep;
use std::time::Duration;

// Calling parallel() takes ≈ 1 second (not 2), both executed concurrently
async fn parallel() -> (i32, i32) {
  let future_a = task_a();  // Does not execute yet
  let future_b = task_b();  // Does not execute yet
  
  // join drives both to completion concurrently
  join(future_a, future_b).await
}

async fn task_a() -> i32 {
  sleep(Duration::from_secs(1)).await;
  10
}

async fn task_b() -> i32 {
  sleep(Duration::from_secs(1)).await;
  20
}
```

#### Multiple concurrent tasks

```rust
use futures::future::join_all;

async fn many_concurrent() -> Result<i32, String> {
  let tasks = vec![
    task_one(),
    task_two(),
    task_three(),
  ];

  // join_all waits for all futures; fails if any error
  let results: Result<Vec<i32>, String> = join_all(tasks)
    .await
    .into_iter()
    .collect();

  match results { // Prints "Task failed: Network error:
    Ok(values) => Ok(values.iter().sum()),
    Err(e) => Err(format!("Task failed: {}", e)),
  }
}

async fn task_one() -> Result<i32, String> {
  Ok(10)
}

async fn task_two() -> Result<i32, String> {
  Ok(20)
}

async fn task_three() -> Result<i32, String> {
  Err("Network error".to_string())
}
```

### Choosing between sequential and parallel composition impacts performance and resource usage

- Sequential: Low memory, forces ordering, latency is sum of task times
- Parallel: Higher resource usage, enables concurrency, latency is max of task times
- Mixed: Complex graphs require careful design (e.g., DAG task execution)

---

## **Executors and Runtimes**

A `Future` does nothing unless polled. An **executor** is a scheduler that:

- Maintains a queue of tasks (futures)
- Repeatedly polls futures via the `Future::poll()` method
- Reacts to waker notifications
- Manages thread pools for scaling

> **Real-world architectures use work-stealing schedulers:**
>
> - Thread pool with local task queues per thread
> - Idle threads steal tasks from busy threads
> - Lock-free data structures for performance
> - Cache-aware scheduling for locality

## Tokio: The Dominant Async Runtime

While Rust's async/await syntax is part of the language standard library, the `Future` trait alone is not enough, you need a runtime executor to make it run. **Tokio** is the de facto standard async runtime in the Rust ecosystem, used by the vast majority of production applications. It's not merely one option among many; it's the reference implementation that most projects depend on directly or indirectly.

Tokio offers several critical advantages:

- **Work-stealing scheduler** — Automatically distributes tasks across CPU cores for optimal parallelism
- **Efficient I/O multiplexing** — Uses OS-level primitives (epoll on Linux, kqueue on macOS, IOCP on Windows) to handle thousands of concurrent connections
- **Battery-included ecosystem** — Provides utilities for timers, channels, synchronization, testing, and more
- **Production-hardened** — Used by major companies and projects at massive scale
- **Flexible runtime flavors** — Single-threaded (minimal overhead) and multi-threaded (full parallelism) configurations
- **First-class cancellation support** — Through `tokio::select!` and task abortion
- **Transparent integration** — The `#[tokio::main]` macro hides runtime setup complexity

Detailed coverage of Tokio's architecture, configuration, and advanced patterns is provided in the dedicated **Topic 3.1.5: Tokio**. For now, understand that Tokio is your best choice executor, the bridge between your `async fn` definitions and actual execution on the CPU.

---

## **Futures vs JavaScript Promises**

| Aspect           | Rust Futures                    | JS Promises                      |
|------------------|---------------------------------|----------------------------------|
| **Laziness**     | Lazy (polling-based)            | Eager (execute immediately)      |
| **Execution**    | Requires explicit executor      | Runs immediately upon creation   |
| **Memory**       | Stack-based state machines      | Heap-allocated objects           |
| **Cancellation** | Drop cancels; cleanup via Drop  | RequiresAbortController (complex)|
| **Overhead**     | Zero-cost abstraction (compile) | Runtime overhead per promise     |
| **Error Model**  | Result<T, E> composable         | .catch() callback-based          |
| **Chaining**     | `.await` at suspension points   | `.then()` callbacks chain        |

### Laziness

Rust's lazy evaluation is a fundamental difference from how promises work in JavaScript. When you call an `async fn` in Rust, it does not immediately execute, it merely **constructs** a `Future` object. This means you have precise control over *when* (and *if*) the computation happens. This enables conditional and data-dependent execution patterns that would be inefficient in eager systems.

In JavaScript, calling an `async fn` **immediately starts the computation**, even if you never await the result. The promise is already executing in the background, consuming resources and performing I/O. Rust's laziness prevents wasted work:

```rust
// RUST: Lazy execution
async fn rust_lazy() {
  let fut = fetch_data(); // Not executed yet
  println!("Future created but not started");
  
  if should_execute() {
    let data = fut.await; // Now it executes
    println!("Data: {:?}", data);
  }
  // If never awaited, the future never runs
}

async fn fetch_data() -> String {
  println!("Fetching!"); // Only prints if awaited
  "data".to_string()
}

fn should_execute() -> bool { true }
```

Contrast this with JavaScript's eager model:

```javascript
// JAVASCRIPT: Eager execution
async function jsEager() {
  const promise = fetchData(); // FETCH STARTS IMMEDIATELY
  console.log("Promise created and executing");
  
  if (shouldExecute()) {
    const data = await promise; // Just waits for result
    console.log("Data:", data);
  }
  // Promise already executed even if not awaited
}

async function fetchData() {
  console.log("Fetching!"); // Logs immediately
  return "data";
}
```

In the JavaScript example, the network fetch starts **immediately upon calling `fetchData()`**, regardless of whether the result is ever used. In Rust, the future is inert until explicitly awaited. This difference has profound implications for resource utilization and composability.

### Performance implications

The practical impact of laziness becomes apparent when composing multiple futures. In Rust, you can construct an entire async pipeline *without any allocations*, since the futures are just state machine types being composed at compile time. There are no intermediate objects being created—only the final state machine structure exists.

JavaScript, by contrast, creates a new heap-allocated promise object **immediately** for each async function call. When building a pipeline with dependent async operations, you're forced to allocate memory for promise objects even if you don't care about their individual results. This is wasteful for data-dependent operations where later steps depend on earlier ones:

```rust
// Rust: Laziness allows composition without overhead
fn build_request_pipeline() -> impl Future<Output = Result<String, String>> {
  async {
    let user = fetch_user(1).await?;             // Single allocation
    let posts = fetch_posts(user.id).await?;     // No intermediate futures
    Ok(format!("{:?} posts", posts.len()))
  }
}

// JavaScript: Each promise allocated immediately
async function buildRequestPipeline() {
  // Already executing:
  const userPromise = fetchUser(1); // Allocation 1
  const postsPromise = fetchPosts(userPromise.id); // Allocation 2 (dependent)
  
  const user = await userPromise;
  const posts = await postsPromise;
  return `${posts.length} posts`;
}
```

The Rust version composes futures into a single state machine without heap allocations. The JavaScript version is forced to allocate multiple promise objects. This overhead becomes significant in data pipelines processing thousands of items sequentially.

### Memory efficiency for high concurrency

One of Rust's most powerful advantages in concurrent systems is the near-zero memory cost of spawning thousands of tasks. Because futures are compiled to stack-based state machines, each future occupies only the space needed for its local variables and state variant, often just a few bytes or tens of bytes per task. This makes it feasible to spawn tens of thousands (or more) of concurrent tasks on modest hardware.

JavaScript promises, by contrast, are heap-allocated objects with significant per-promise overhead. The V8 JavaScript engine (used in Chrome and Node.js) allocates approximately **200 bytes minimum per promise object**, plus additional memory for internal state management and microtask queue bookkeeping. When you scale to thousands of concurrent operations, this overhead becomes a critical bottleneck. Creating 10,000 promises consumes 2+ MB just for the promise objects themselves—before any user data. Rust's state machines incur no such penalty.

This difference is why Rust scales to high concurrency more gracefully:

```rust
// Rust: 10,000 lightweight futures on the stack
#[tokio::main]
async fn rust_highscale() {
  let tasks: Vec<_> = (0..10_000)
    .map(|i| {
      // Each future is tiny: just state machine variant + minimal data
      async move {
        process_request(i).await
      }
    })
    .collect();

  let results = futures::future::join_all(tasks).await;
  println!("Processed {} requests", results.len());
}

// JavaScript: Each promise is a heap-allocated object with overhead
// ~200 bytes per promise minimum (V8/Node.js)
// 10,000 promises = ~2MB+ overhead just for the objects
```

The memory efficiency compounds when combined with lazy execution: Rust futures don't execute until polled, so you can construct millions of task descriptions without consuming CPU or I/O resources. JavaScript promises start executing immediately, forcing resource allocation proportional to concurrency.

---

## **Fairness and Starvation Prevention**

Tasks must yield via `.await` to give other tasks a chance to run. Long synchronous sections can starve the executor:

```rust
#[tokio::main]
async fn fairness_example() {
  // BAD: CPU-bound work blocks executor
  let bad_task = tokio::spawn(async {
    for i in 0..1_000_000_000 { // Tight loop, no .await
      let _ = i * i;
    }
    "Done"
  });

  // This task might not run for a long time!
  let fair_task = tokio::spawn(async {
    println!("Fair task running");
  });

  tokio::join!(bad_task, fair_task);
}

#[tokio::main]
async fn fairness_solution() {
  // GOOD: Yield periodically in CPU-bound work
  let good_task = tokio::spawn(async {
    for i in 0..1_000_000_000 {
      if i % 100_000 == 0 {
        tokio::task::yield_now().await; // Yield to executor
      }
      let _ = i * i;
    }
    "Done"
  });

  // Or move to spawn_blocking for long CPU work
  let blocking_task = tokio::spawn_blocking(|| {
    for i in 0..1_000_000_000 {
      let _ = i * i;
    }
    "Done"
  });

  tokio::join!(good_task, blocking_task);
}
```

Understanding this prevents starvation and latency spikes in production systems.

---

## **Professional Applications and Implementation**

Async/await enables:

- **High-concurrency network servers** — handling thousands of connections
- **Web APIs and microservices** — with request multiplexing
- **Streaming systems** — efficient data pipeline processing
- **Event-driven architectures** — reactive systems
- **Efficient resource utilization under heavy I/O load** — thousands of concurrent tasks per CPU core

**Correct runtime configuration and usage determines scalability.** Misuse leads to:

- **Starvation** — Long CPU sections blocking other tasks
- **Deadlocks** — Incorrect locking within async contexts
- **Memory leaks** — Futures holding references longer than necessary
- **Degraded throughput** — Suboptimal task scheduling

---

## **Key Takeaways**

| Concept              | Summary                                                              |
|----------------------|----------------------------------------------------------------------|
| **Async/Await**      | Compile-time state machines implementing `Future`; purely syntactic. |
| **Futures**          | Lazy, polled abstractions requiring executors; zero-cost.            |
| **Polling Model**    | Cooperative scheduling via wakers; efficient, no busy-waiting.       |
| **State Machines**   | Each `.await` becomes a state; no heap allocation unless explicit.   |
| **Pinning**          | `Pin<&mut Self>` prevents moving self-referential futures.           |
| **Executors**        | Drive futures to completion; Tokio is the standard.                  |
| **Composition**      | Sequential (dependencies) vs concurrent (independent parallelism).   |
| **Cancellation**     | Drop the future; cleanup via Drop impl.                              |
| **Fairness**         | Yield via `.await` periodically to prevent starvation.               |

**Essential truths:**

- Async functions do not execute until awaited or polled—laziness is a feature
- Each `.await` introduces a suspension point with a state machine transition
- Futures are zero-cost, compile-time state machines with no runtime overhead
- Executors (especially Tokio with work-stealing) are mandatory for progress
- Model selection (single-threaded vs multi-threaded) and runtime design directly impact performance and correctness
- Pinning ensures memory safety for self-referential types in polling
- Understanding the `Future` trait and waker protocol is critical for writing correct async code
- Cancellation via drop is safe and automatic; cleanup is guaranteed
- Fairness requires periodic yields; long synchronous work causes starvation

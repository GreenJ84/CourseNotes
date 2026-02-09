# **Topic 3.1.2: Rust Concurrency Features**

Building on the computer fundamentals from the previous topic, this section explores how Rust's type system provides compile-time thread safety guarantees through ownership, borrowing, marker traits, and various concurrency models.

## **Learning Objectives**

- Apply ownership and borrowing principles in concurrent contexts
- Master Rust's `Send` and `Sync` marker traits for compile-time thread safety
- Compare and select appropriate concurrency models for different workloads
- Differentiate shared-state and message-passing concurrency paradigms
- Understand how Rust prevents data races at compile time
- Implement professional concurrent systems using Rust's safety guarantees

---

## **Ownership and Borrowing in Concurrent Contexts**

The same ownership and borrowing rules that ensure memory safety in single-threaded code extend naturally to concurrent code.

### Ownership Transfer: Move Semantics

Moving a value to another thread transfers ownership:

```rust
use std::thread;

fn ownership_transfer() {
  struct Data {
    values: Vec<i32>,
  }
  
  let data = Data { values: vec![1, 2, 3] };
  
  thread::spawn(move || {
    // Ownership of 'data' transferred to thread
    println!("Thread owns data: {:?}", data.values);
    // 'data' is dropped at end of thread
  });
  
  // ❌ Main thread cannot access 'data' (moved)
  // println!("{:?}", data.values);
}
```

### Borrowing: Scoped References

Standard threads require `'static` bound (no borrowed data). Scoped threads allow borrowing:

```rust
use std::thread;

fn scoped_borrowing() {
  let data = vec![1, 2, 3, 4, 5];
  
  thread::scope(|s| {
    // Threads can borrow from outer scope
    let handle1 = s.spawn(|| {
      println!("Thread 1: {:?}", &data[0..2]);
    });
    
    let handle2 = s.spawn(|| {
      println!("Thread 2: {:?}", &data[2..5]);
    });
    
    // Scope waits for all threads before continuing
    // Guarantees 'data' outlives all threads
  });
  
  // Safe to use 'data' after scope (all threads completed)
  println!("Final data: {:?}", data);
}
```

### Shared Mutable State

When multiple threads need to mutate shared data, use synchronization primitives:

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn shared_mutable_state() {
  let counter = Arc::new(Mutex::new(0));
  let mut handles = vec![];
  
  for _ in 0..4 {
    let counter = Arc::clone(&counter);
    handles.push(thread::spawn(move || {
      for _ in 0..1000 {
        let mut num = counter.lock().unwrap();
        *num += 1;
      }
    }));
  }
  
  for handle in handles {
    handle.join().unwrap();
  }
  
  println!("Final counter: {}", *counter.lock().unwrap());
}
```

### Stack References and Thread Boundaries

The isolation of stacks has critical implications for lifetime safety. A reference to a stack variable (`&T` where `T` is on the stack) is bound to the thread that owns that stack:

```rust
use std::thread;

fn stack_reference_limitation() {
  let local = 42;
  
  // ❌ This doesn't compile:
  // let handle = thread::spawn(|| {
  //     println!("{}", local); // Error: 'local' is on main thread's stack
  // });
  
  // ✅ Correct: Move the value into the thread (stack variable copied/moved)
  let local = 42;
  let handle = thread::spawn(move || {
    println!("{}", local); // `local` is now on spawned thread's stack
  });
  
  handle.join().unwrap();
}
```

This limitation is why `thread::spawn` requires a closure with the `'static` bound: any data passed to a thread must either be owned (moved in) or be in shared heap allocations. Scoped threads relax this by allowing borrowed stack references, provided the scope outlives all spawned threads:

```rust
use std::thread;

fn scoped_threads_allow_borrowing() {
  let local_vec = vec![1, 2, 3, 4, 5];
  
  thread::scope(|s| {
    // Spawning multiple threads that borrow the same data
    let handle1 = s.spawn(|| {
      println!("Thread 1: {:?}", &local_vec[0..2]);
    });
    
    let handle2 = s.spawn(|| {
      println!("Thread 2: {:?}", &local_vec[2..5]);
    });
    
    // No manual join needed; scope waits for all threads
  }); // Compiler verifies all threads completed before local_vec is dropped
  
  println!("All threads completed, local_vec can be safely dropped");
}
```

---

## **Send & Sync Traits**

`Send` and `Sync` are **marker traits** that encode compile-time thread-safety guarantees. They contain no methods; the Rust compiler uses them purely for static verification. Understanding them deeply is essential for Rust developers working with concurrency.

### Understanding Marker Traits

A marker trait is a zero-sized type that communicates semantic properties to the type system without enforcing any runtime behavior:

```rust
// Simplified definition (actual definition is in libcore)
pub unsafe auto trait Send {
  // No methods; purely a compile-time assertion
}

pub unsafe auto trait Sync {
  // No methods; purely a compile-time assertion
}
```

Key characteristics:

- **`unsafe`**: Implementing them unsafely violates memory safety; the compiler trusts your implementation
- **`auto`**: The compiler automatically derives them when conditions are met (field-wise composition)
- **Zero-sized**: They have no runtime representation; the compiler erases them after verification

The compiler enforces these rules:

1. A type is `Send` if it is safe to move it to another thread (transfer ownership across thread boundaries)
2. A type is `Sync` if it is safe for multiple threads to hold `&T` to the same value simultaneously
3. These traits are inferred recursively: `struct S { a: A, b: B }` is `Send` iff `A` and `B` are both `Send`

### Send: Safe Ownership Transfer

A type `T` is `Send` if you can safely move a value of type `T` into another thread. Formally: **If T is Send, then for any thread context, ownership transfer of T to that context is safe.**

#### What is Send?

**Primitives and owned types:**

- `i32`, `f64`, `bool`, `char` – fundamental types, copied, not tied to any thread
- `String` – owns its heap buffer; moving it to another thread transfers heap ownership safely
- `Vec<T>` where `T: Send` – owns its allocation and elements; safe to move if elements are safe
- `Box<T>` where `T: Send` – unique ownership transferred to new thread
- `Arc<T>` where `T: Send + Sync` – atomic reference count with synchronization guarantees

**Why Arc requires Send + Sync:**

```rust
use std::sync::Arc;
use std::thread;

fn arc_send_sync_requirement() {
  // Arc<T> is Send iff T is Send + Sync
  // This is because Arc clones might be sent to different threads
  // The inner T must be safe to access from any thread
  
  struct NonSync { rc: std::rc::Rc<i32> } // Not Sync
  // Arc<NonSync> would be unsound; Rc is not thread-safe
  
  struct ThreadSafe { data: i32 } // Send + Sync
  let arc = Arc::new(ThreadSafe { data: 42 });
  let clone = Arc::clone(&arc);
  
  thread::spawn(move || {
    println!("Cloned Arc in thread: {}", clone.data);
  });
}
```

#### What is NOT Send?

**Reference-counting and interior mutability:**

- `Rc<T>` – uses non-atomic reference counting (not thread-safe); moving to another thread could cause use-after-free
- `Cell<T>` – provides interior mutability without synchronization; undefined behavior if accessed from multiple threads
- `RefCell<T>` – runtime borrow checking is not thread-safe; multiple threads could panic or cause UB

**Raw pointers:**

- `*const T`, `*mut T` – unsafe by design; compiler cannot verify thread safety
- Dereferencing raw pointers is inherently unsafe; thread safety is programmer's responsibility

**Custom types containing non-Send fields:**

```rust
use std::rc::Rc;
use std::thread;

struct NotSend {
  counter: Rc<i32>,
}

fn non_send_struct_example() {
  let data = NotSend {
    counter: Rc::new(42),
  };
  
  // ❌ Compilation error: NotSend is not Send
  // error[E0277]: `Rc<i32>` cannot be sent between threads safely
  // thread::spawn(move || {
  //     println!("{}", *data.counter);
  // });
}
```

#### Send in Practice: Complete Example

```rust
use std::thread;
use std::rc::Rc;
use std::sync::Arc;

// Primitive types are Send
fn primitives_are_send() {
  let value = 42i32;
  thread::spawn(move || {
    println!("Primitive in thread: {}", value); // ✅
  }).join().unwrap();
}

// Owned heap types are Send if their contents are Send
fn owned_types_are_send() {
  let vec = vec![1, 2, 3, 4, 5];
  thread::spawn(move || {
    println!("Vec in thread: {:?}", vec); // ✅
  }).join().unwrap();
}

// Rc is not Send—it uses non-atomic refcount
fn rc_is_not_send() {
  let rc = Rc::new(vec![1, 2, 3]);
  // ❌ Cannot send Rc to another thread
  // thread::spawn(move || {
  //     println!("{:?}", rc);
  // });
  
  // ✅ Solution: Use Arc instead
  let arc = Arc::new(vec![1, 2, 3]);
  thread::spawn(move || {
    println!("Arc in thread: {:?}", arc);
  }).join().unwrap();
}

// Custom structs inherit Send-ness from fields
#[derive(Clone)]
struct ThreadSafeData {
  id: u32,
  message: String,
  counter: Arc<std::sync::atomic::AtomicUsize>,
}

impl ThreadSafeData {
  fn new(id: u32, msg: &str) -> Self {
    Self {
      id,
      message: msg.to_string(),
      counter: Arc::new(std::sync::atomic::AtomicUsize::new(0)),
    }
  }
}

fn custom_struct_send() {
  let data = ThreadSafeData::new(1, "Hello");
  thread::spawn(move || {
    println!("Custom struct in thread: {} - {}", data.id, data.message); // ✅
  }).join().unwrap();
}

// Understanding Send through complex types
fn complex_send_analysis() {
  // Vec<Box<dyn Fn() + Send>> is Send iff all closures are Send
  let callbacks: Vec<Box<dyn Fn() + Send>> = vec![
    Box::new(|| println!("Callback 1")),
    Box::new(|| println!("Callback 2")),
  ];
  
  thread::spawn(move || {
    for cb in callbacks {
      cb();
    }
  }).join().unwrap();
}
```

### Sync: Safe Shared Reference Access

A type `T` is `Sync` if it is safe for multiple threads to hold `&T` (shared references) to the same value. Formally: **T is Sync if &T is Send**.

This means that sending a shared reference across thread boundaries is safe—the referenced value can be safely accessed from multiple threads simultaneously.

#### What is Sync?

**Immutable types:**

- Primitives and immutable data – no mutations possible, hence thread-safe
- `&T` – a shared reference cannot mutate (borrow checker enforces this)

**Synchronization primitives:**

- `Mutex<T>` where `T: Send` – provides synchronized access; multiple threads can call `lock()` safely
- `RwLock<T>` – allows multiple readers or one writer; thread-safe
- `Arc<T>` where `T: Sync` – multiple threads can hold references to the same Arc

**Atomic types:**

- `AtomicUsize`, `AtomicBool`, etc. – use CPU atomic instructions; safe for concurrent access

#### What is NOT Sync?

**Interior mutability without synchronization:**

- `Cell<T>` – allows mutation through `&T` via copy/replace; not thread-safe (no synchronization)
- `RefCell<T>` – runtime borrow checking; panics on double mutable borrow; not thread-safe across threads

**Reference-counted interior mutability:**

- `Rc<T>` – uses non-atomic refcount; unsafe to share references across threads
- `RefCell<T>` combined with `Rc<T>` – doubly unsafe

**Raw pointers:**

- `*const T`, `*mut T` – no thread safety guarantees

#### Sync in Practice: Complete Example

```rust
use std::sync::{Arc, Mutex, RwLock};
use std::cell::{Cell, RefCell};
use std::rc::Rc;
use std::thread;

// Mutex is Sync—multiple threads can safely lock it
fn mutex_is_sync() {
  let counter = Arc::new(Mutex::new(0));
  let mut handles = vec![];
  
  for _ in 0..5 {
    let counter = Arc::clone(&counter);
    handles.push(thread::spawn(move || {
      for _ in 0..100 {
        let mut num = counter.lock().unwrap();
        *num += 1;
      }
    }));
  }
  
  for handle in handles {
    handle.join().unwrap();
  }
  
  println!("Final counter: {}", *counter.lock().unwrap());
}

// RefCell is not Sync—it's only for single-threaded use
fn refcell_is_not_sync() {
  // ❌ Cannot share RefCell across threads
  // let data = Arc::new(RefCell::new(vec![1, 2, 3]));
  // thread::spawn(move || {
  //     data.borrow_mut().push(4); // Runtime error or UB
  // });
  
  // ✅ Solution: Wrap RefCell in a synchronization primitive
  let data = Arc::new(Mutex::new(RefCell::new(vec![1, 2, 3])));
  let clone = Arc::clone(&data);
  thread::spawn(move || {
    let guard = clone.lock().unwrap();
    guard.borrow_mut().push(4); // ✅ Safe: Mutex provides outer synchronization
  }).join().unwrap();
}

// RwLock provides multiple concurrent readers
fn rwlock_multiple_readers() {
  let data = Arc::new(RwLock::new(vec![1, 2, 3, 4, 5]));
  let mut handles = vec![];
  
  // Spawn multiple reader threads
  for i in 0..3 {
    let data = Arc::clone(&data);
    handles.push(thread::spawn(move || {
      let vec = data.read().unwrap(); // ✅ Multiple threads can read concurrently
      println!("Reader {}: {:?}", i, *vec);
    }));
  }
  
  // Single writer thread
  let data = Arc::clone(&data);
  handles.push(thread::spawn(move || {
    thread::sleep(std::time::Duration::from_millis(10));
    let mut vec = data.write().unwrap(); // Exclusive access
    vec.push(6);
    println!("Writer modified vec");
  }));
  
  for handle in handles {
    handle.join().unwrap();
  }
}

// Atomic types are Sync—they use CPU instructions
fn atomic_is_sync() {
  use std::sync::atomic::{AtomicUsize, Ordering};
  
  let counter = Arc::new(AtomicUsize::new(0));
  let mut handles = vec![];
  
  for _ in 0..4 {
    let counter = Arc::clone(&counter);
    handles.push(thread::spawn(move || {
      for _ in 0..1_000_000 {
        counter.fetch_add(1, Ordering::SeqCst);
      }
    }));
  }
  
  for handle in handles {
    handle.join().unwrap();
  }
  
  println!("Atomic counter: {}", counter.load(Ordering::SeqCst));
}

// Custom structs derive Sync from fields
#[derive(Clone)]
struct ThreadSafeCounter {
  count: Arc<std::sync::atomic::AtomicUsize>,
}

impl ThreadSafeCounter {
  fn new() -> Self {
    Self {
      count: Arc::new(std::sync::atomic::AtomicUsize::new(0)),
    }
  }
  
  fn increment(&self) {
    self.count.fetch_add(1, std::sync::atomic::Ordering::SeqCst);
  }
  
  fn get(&self) -> usize {
    self.count.load(std::sync::atomic::Ordering::SeqCst)
  }
}

fn custom_sync_struct() {
  let counter = ThreadSafeCounter::new();
  let mut handles = vec![];
  
  for _ in 0..4 {
    let counter = counter.clone();
    handles.push(thread::spawn(move || {
      for _ in 0..100_000 {
        counter.increment();
      }
    }));
  }
  
  for handle in handles {
    handle.join().unwrap();
  }
  
  println!("Custom sync struct counter: {}", counter.get());
}
```

### Send + Sync Decision Tree

Use this decision tree when implementing custom types:

```text
Does T allow mutation through &T?
  ├─ No (fully immutable) → Sync (also Send if no pointers)
  └─ Yes (interior mutability) → Check synchronization mechanism
    ├─ None (Cell, RefCell) → Not Sync, Not Send
    ├─ Mutex/RwLock → Sync iff T: Send
    └─ Atomic operations → Sync

Is T owned or borrowed?
  ├─ Owned (Box, Vec, String) → Send iff contents are Send
  └─ Borrowed/Shared reference → Check pointee
    ├─ Rc → Not Send, Not Sync
    ├─ Arc → Send + Sync iff T: Send + Sync
    └─ Raw pointer → Assume Not Send, Not Sync
```

### Senior Insight: Variance and Marker Traits

Send and Sync are not affected by variance (unlike lifetime and type parameters). If `S { field: T }` is Send, it's Send regardless of `T`'s lifetime. This is important for understanding why the compiler rejects certain patterns:

```rust
// This is unsound without Send restriction
fn unsound_without_send() {
  struct NotSend(*const std::rc::Rc<i32>);
  // NotSend is Send if *const Rc<i32> were Send, but it's not
  // Raw pointers are always NotSend/NotSync to prevent this
}
```

---

## **Concurrency Models Overview**

Different concurrency models excel at different workload types. Selecting the wrong model causes 10-100x performance degradation.

### Model Selection Criteria

Before selecting a concurrency model, consider:

| Factor | Implication |
| ------ | ----------- |
| **Workload type** | CPU-bound vs. I/O-bound determines if parallelism or interleaving helps |
| **Concurrency scale** | Dozens of threads vs. thousands of concurrent operations affects resource overhead |
| **State management** | Isolated vs. shared state determines synchronization complexity |
| **Latency sensitivity** | Real-time constraints demand predictable scheduling |
| **Fault tolerance** | Fault isolation affects crash propagation |
| **Debuggability** | Determinism vs. non-determinism affects testing |

### OS Threads Model

Threads managed directly by the OS kernel using pre-emptive scheduling.

**Characteristics:**

- Each thread has its own stack (~1-2MB default)
- Scheduled by OS kernel at unpredictable times
- Context switch cost: ~1-10 microseconds
- Heavy resource consumption; creating 10,000 threads is prohibitively expensive
- Simple mental model: threads execute "in parallel" (true on multi-core, interleaved on single-core)

**Best for:**

- CPU-bound workloads that genuinely parallelize (independent calculations)
- Compute-intensive tasks where thread count ≤ core count
- Systems requiring fault isolation (process-level)

**Limitations:**

- Terrible scalability for I/O-bound work (one thread per I/O operation means thousands of threads)
- Lock contention degrades performance significantly
- Context switch overhead accumulates at high thread counts
- Debugging non-deterministic thread interleavings is difficult

**Rust example:**

```rust
use std::thread;
use std::time::Instant;

fn os_threads_cpu_bound() {
  let num_cores = num_cpus::get();
  let start = Instant::now();
  
  let mut handles = vec![];
  for i in 0..num_cores {
    handles.push(thread::spawn(move || {
      // CPU-bound work: compute sum of squares
      let sum: u64 = (0..100_000_000).map(|x| x * x).sum();
      println!("Thread {}: {}", i, sum);
    }));
  }
  
  for handle in handles {
    handle.join().unwrap();
  }
  
  println!("OS threads CPU-bound: {:?}", start.elapsed());
  // Scales well: roughly O(1/num_cores) time
}
```

### Asynchronous Programming (async/await)

Tasks managed by an application-level runtime using cooperative scheduling.

**Characteristics:**

- Tasks are lightweight (~50-200 bytes per spawned task)
- Scheduled cooperatively at `.await` points (deterministic)
- Minimal overhead compared to OS threads
- Single-threaded runtime or thread pool underneath
- Requires an async runtime (Tokio, async-std, Smol)

**Best for:**

- I/O-bound workloads (network requests, file operations, database queries)
- High-concurrency scenarios (thousands of concurrent operations)
- Applications that spend significant time waiting for external resources

**Limitations:**

- Blocking operations inside async tasks block the entire runtime
- Requires runtime selection and configuration
- Debugging can be complex (state machine transformations)
- CPU-intensive work starves other tasks
- Error handling is more complex (cancellation, timeouts)

**Rust example:**

```rust
use tokio::task;
use std::time::Instant;

#[tokio::main]
async fn async_io_bound() {
  let start = Instant::now();
  
  // Spawn 1000 concurrent I/O tasks
  let mut handles = vec![];
  for i in 0..1000 {
    handles.push(task::spawn(async move {
      // Simulate I/O operation
      tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
      println!("Task {} completed", i);
    }));
  }
  
  // Wait for all tasks
  for handle in handles {
    let _ = handle.await;
  }
  
  println!("Async I/O-bound 1000 tasks: {:?}", start.elapsed());
  // With 1000 tasks on a single async runtime: ~10ms
  // With 1000 OS threads: likely 100ms+ due to context switch overhead
}
```

### Blocking Operations in Async: The Gotcha

A critical limitation of async is that blocking operations block the entire runtime:

```rust
#[tokio::main]
async fn blocking_in_async_example() {
  use std::time::Instant;
  
  let start = Instant::now();
  
  // ❌ Bad: CPU-bound operation blocks the runtime
  let task1 = tokio::spawn(async {
    let sum: u64 = (0..1_000_000_000).sum(); // 1 second CPU work
    println!("Task 1 sum: {}", sum);
  });
  
  let task2 = tokio::spawn(async {
    tokio::time::sleep(std::time::Duration::from_secs(1)).await;
    println!("Task 2 waited 1 second");
  });
  
  // Task 1 blocks the runtime, preventing Task 2 from making progress
  tokio::join!(task1, task2);
  println!("Time: {:?}", start.elapsed()); // ~2 seconds (tasks ran sequentially)
}

#[tokio::main]
async fn blocking_offload_solution() {
  use std::time::Instant;
  
  let start = Instant::now();
  
  // ✅ Good: Offload blocking work to thread pool
  let task1 = tokio::task::spawn_blocking(|| {
    let sum: u64 = (0..1_000_000_000).sum();
    println!("Task 1 sum: {}", sum);
  });
  
  let task2 = tokio::spawn(async {
    tokio::time::sleep(std::time::Duration::from_secs(1)).await;
    println!("Task 2 waited 1 second");
  });
  
  // Task 1 runs in blocking thread pool; Task 2 makes progress concurrently
  let _ = tokio::join!(task1, task2);
  println!("Time: {:?}", start.elapsed()); // ~1 second (tasks run concurrently)
}
```

### Coroutines and Generators

Functions that suspend and resume, preserving internal state.

**Characteristics:**

- Rust's `async fn` is syntactic sugar for coroutines compiled into state machines
- Each `.await` point becomes a state variant
- Symmetric coroutines (any coroutine resumes any other) vs. asymmetric (caller/callee)
- Rust uses asymmetric coroutines (via `async/await`)

**Best for:**

- Custom iterators and generators
- Building domain-specific languages
- Complex control flow requiring state preservation
- Custom runtime implementations

**Rust example:**

```rust
async fn coroutine_example() {
  // Under the hood, this becomes a state machine
  let x = 1;
  some_io_operation().await; // State transition
  let y = 2;
  another_io().await; // Another state transition
  println!("Result: {}", x + y);
}

async fn some_io_operation() {
  tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
}

async fn another_io() {
  tokio::time::sleep(tokio::time::Duration::from_millis(10)).await;
}

// Simplified State representation:
// enum CoroutineState {
//     Start,
//     AfterFirstIO { x: i32 },
//     AfterSecondIO { x: i32, y: i32 },
//     Complete,
// }
```

### The Actor Model

Isolated units of computation communicating via asynchronous message passing.

**Characteristics:**

- Actors don't share memory; all communication is explicit messages
- Each actor has a mailbox (message queue)
- Actors process messages sequentially
- Natural fault tolerance through supervision
- Popularized by Erlang/Elixir; Rust implementations: `actix-actor`, `bastion`

**Best for:**

- Systems requiring fault isolation and crash resilience
- Distributed systems with independent components
- Complex request/response patterns
- Stateful services with encapsulated state

**Rust example (simplified):**

```rust
use tokio::sync::mpsc;

#[derive(Debug)]
enum ActorMessage {
  Increment,
  GetValue(tokio::sync::oneshot::Sender<u32>),
}

async fn actor_example() {
  let (tx, mut rx) = mpsc::channel::<ActorMessage>(100);
  
  // Actor task
  tokio::spawn(async move {
    let mut counter = 0u32;
    while let Some(msg) = rx.recv().await {
      match msg {
        ActorMessage::Increment => {
          counter += 1;
        }
        ActorMessage::GetValue(resp) => {
          let _ = resp.send(counter);
        }
      }
    }
  });
  
  // Send messages to actor
  tx.send(ActorMessage::Increment).await.unwrap();
  tx.send(ActorMessage::Increment).await.unwrap();
  
  let (resp_tx, resp_rx) = tokio::sync::oneshot::channel();
  tx.send(ActorMessage::GetValue(resp_tx)).await.unwrap();
  let value = resp_rx.await.unwrap();
  println!("Actor counter value: {}", value);
}
```

### Event-Driven Programming

Central event loop processes events sequentially.

**Characteristics:**

- Single event loop (or thread pool of event loops)
- Events processed in order (or with prioritization)
- Handlers respond asynchronously
- Dominant in GUI frameworks and async servers

**Best for:**

- GUI applications with user input
- Event streaming and pub/sub systems
- Real-time systems requiring ordered processing
- Reactive systems

**Rust example:**

```rust
use tokio::sync::broadcast;

async fn event_driven_example() {
  let (tx, mut rx) = broadcast::channel(100);
  
  // Event publishers
  tokio::spawn({
    let tx = tx.clone();
    async move {
      for i in 0..5 {
        tx.send(format!("Event {}", i)).unwrap();
        tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
      }
    }
  });
  
  // Event handler
  tokio::spawn(async move {
    while let Ok(event) = rx.recv().await {
      println!("Handler received: {}", event);
    }
  });
  
  tokio::time::sleep(std::time::Duration::from_secs(1)).await;
}
```

### Comparison Table

| Model | Overhead | Latency | Scalability | Best For | Debugging |
| ----- | --------- | ------- | ----------- | --------- | --------- |
| **OS Threads** | ~2MB stack | ~1-10µs switch | Hundreds | CPU-bound | Deterministic |
| **Async/await** | ~50B task | ~0µs (coop) | Thousands+ | I/O-bound | Complex state |
| **Actors** | Variable | Msg latency | Distributed | Isolation | Message tracing |
| **Events** | Variable | Ordered | Thousands | GUI/streams | Event logging |

---

- **Rust's superpower is compile-time thread safety**: Entire classes of data race bugs that plague C, C++, Java, and Go are eliminated before runtime
- **Variance doesn't apply to Send/Sync**: A generic type's Send-ness doesn't vary with its lifetime parameters
- **Async is not always better**: CPU-intensive work in async runtimes blocks other tasks; synchronous code is sometimes faster
- **Model selection is critical**: Choosing the wrong model causes 10-100x performance degradation; CPU-bound needs threads, I/O-bound needs async
- **Message-passing trades latency for safety**: Copying data costs time but simplifies reasoning and prevents data races
- **Deadlocks still exist in Rust**: The compiler prevents data races but not logical errors like circular lock dependencies
- **Interior mutability requires synchronization**: `Cell`/`RefCell` are not thread-safe; use `Mutex`/`RwLock` for concurrent mutation
- **Arc overhead**: Atomic operations are slower than non-atomic; use `Rc` in single-threaded code for better performance

---

## **Professional Applications and Implementation**

Rust's concurrency features are foundational to production systems:

- **Web servers and APIs** – Async runtimes handle thousands of concurrent connections efficiently
- **Data processing pipelines** – Message-passing prevents data races in multi-stage processing
- **Distributed systems** – Actor models provide fault isolation and resilience
- **Real-time systems** – Scoped threads with predictable timing for latency-sensitive work
- **Streaming and event processing** – Event-driven models handle high-throughput data flows
- **Database connection pools** – Arc + Mutex safely share connections across threads
- **Background job queues** – Channels enable safe work distribution without locks

These patterns support writing robust, testable concurrent code that scales from dozens to thousands of concurrent operations while maintaining Rust's memory safety guarantees data races are impossible, not just unlikely.

---

## **Key Takeaways**

| Concept | Essential Understanding |
| ------- | ---------------------- |
| **Rust's Safety** | Eliminates data races at compile time through ownership, borrowing, and type system |
| **Ownership Transfer** | Moving values to threads is safe; borrowing requires scoped threads or `'static` lifetime |
| **Send & Sync** | Compile-time guarantees preventing data races: `Send` for ownership transfer, `Sync` for shared references |
| **Scoped Threads** | Allow borrowing stack data; standard threads require `'static` |
| **Blocking in Async** | Blocking operations block the entire runtime; use `spawn_blocking` for CPU work |
| **Concurrency Models** | Threads for CPU-bound, async for I/O-bound, actors for isolation, events for reactivity |
| **Model Selection** | Wrong model causes 10-100x performance degradation; match model to workload type |
| **Atomic Types** | CPU-level atomic operations; `Sync` and lock-free |

# **Topic 3.1.5: Tokio**

Tokio is the production-grade async runtime for Rust, providing the executor, I/O multiplexing, task scheduling, and utility ecosystem necessary to run async code at scale. While `async/await` is language syntax, Tokio is the platform that brings futures to life, driving them to completion and managing all the complexity of concurrent task scheduling, I/O notification, and resource management.

This topic covers the runtime architecture, initialization patterns, executor configuration, and the ecosystem of utilities Tokio provides for building high-performance concurrent applications.

## **Learning Objectives**

- Understand Tokio's role as an executor and how it drives futures to completion
- Master runtime initialization and macro-based setup patterns
- Distinguish between single-threaded and multi-threaded runtime flavors and their tradeoffs
- Spawn and manage tasks with `tokio::spawn` and understand task lifetime semantics
- Leverage Tokio's work-stealing scheduler for optimal CPU utilization
- Use I/O primitives (`TcpListener`, `TcpStream`, etc.) for building networked systems
- Manage time-based operations with Tokio's hierarchical timing wheels
- Understand channel patterns (`mpsc`, `broadcast`, `watch`) for inter-task communication
- Apply synchronization primitives (`Mutex`, `RwLock`, `Semaphore`) safely within async contexts
- Configure and tune runtime behavior for specific workloads
- Write testable async code with `#[tokio::test]` and properly manage test runtime isolation

---

## **Tokio Architecture Overview**

Tokio's design centers on three core responsibilities:

1. **Task Execution** — Scheduling and polling futures via the executor
2. **Event Notification** — OS-level I/O multiplexing to notify tasks of I/O readiness
3. **Resource Management** — Thread pools, timers, memory, and shutdown coordination

The architecture is modular; you can configure runtime flavor, thread count, and subsystem behavior to match your workload. Most applications use the default multi-threaded flavor with `#[tokio::main]`, but custom configurations are available for specialized scenarios.

---

## **Runtime Initialization**

### The `#[tokio::main]` Macro

The `#[tokio::main]` attribute macro is the simplest way to set up a Tokio runtime. It automates boilerplate and initializes the executor:

```rust
#[tokio::main]
async fn main() {
  println!("Running on Tokio runtime");
  some_async_operation().await;
}

async fn some_async_operation() {
  println!("Async function executed");
}
```

This macro expands to code that creates a multi-threaded runtime, blocks the current thread until the async main function completes, and properly shuts down the executor. Behind the scenes, it's equivalent to:

```rust
fn main() {
  let rt = tokio::runtime::Runtime::new().unwrap();
  rt.block_on(async {
    println!("Running on Tokio runtime");
    some_async_operation().await;
  })
}

async fn some_async_operation() {
  println!("Async function executed");
}
```

The macro handles all the setup and cleanup automatically. For most applications, this is all you need. However, understanding the manual equivalent is crucial for advanced scenarios where you need fine-grained control over runtime configuration.

### Manual Runtime Construction

For applications requiring custom configuration, you can construct the runtime explicitly using `tokio::runtime::Builder`:

```rust
use tokio::runtime::Builder;
use std::num::NonZeroUsize;

fn main() {
  // Create a custom multi-threaded runtime with specific configuration
  let rt = Builder::new_multi_thread()
    .worker_threads(4)                          // Explicit thread count
    .thread_name("my-worker")                   // Custom thread naming
    .thread_stack_size(2 * 1024 * 1024)        // 2MB per thread
    .max_blocking_threads(256)                  // Limit blocking tasks
    .enable_all()                               // Enable all features
    .build()
    .expect("Failed to build runtime");

  // Block current thread until async work completes
  rt.block_on(async {
    expensive_operation().await;
  });
  
  // Graceful shutdown on scope exit
}

async fn expensive_operation() {
  println!("Running expensive operation");
}
```

The `Builder` API allows precise control over:

- **Thread count** — How many worker threads to spawn
- **Thread naming** — For debugging and observability
- **Stack size** — Memory allocated per worker thread
- **Feature flags** — Which Tokio subsystems to enable (I/O, timers, etc.)
- **Blocking thread limits** — Maximum threads for `spawn_blocking` tasks

This customization is essential for production deployments where you need to optimize resource allocation based on workload characteristics.

---

## **Runtime Flavors**

Tokio provides two runtime configurations optimized for different scenarios:

### Current-Thread Runtime

The current-thread runtime executes all tasks on a single thread without work-stealing or synchronization overhead. It's lightweight and deterministic, suitable for CPU-light, I/O-bound applications or testing:

```rust
use tokio::runtime::Builder;

#[tokio::main(flavor = "current_thread")]
async fn main() {
  // All tasks run on this single thread
  // No work-stealing, no synchronization overhead
  println!("Single-threaded runtime");
}
```

Or manually:

```rust
fn main() {
  let rt = Builder::new_current_thread()
    .enable_all()
    .build()
    .expect("Failed to build runtime");

  rt.block_on(async {
    task_one().await;
    task_two().await;
  });
}

async fn task_one() { println!("Task 1"); }
async fn task_two() { println!("Task 2"); }
```

#### Use current-thread when

- Building CLI tools or short-lived applications
- Writing tests where determinism matters
- Handling minimal concurrency with I/O operations
- Running embedded or resource-constrained environments

The trade-off: no true parallelism. Long-running tasks will block other tasks even if other CPU cores are idle.

### Multi-Thread Runtime

The multi-threaded runtime spawns a pool of worker threads (by default, equal to the number of CPU cores) with a work-stealing scheduler. This enables true parallelism and is the default configuration:

```rust
#[tokio::main]  // Defaults to multi-thread
async fn main() {
  // Runtime spawns worker threads equal to CPU count
  // Work-stealing scheduler distributes tasks
  println!("Multi-threaded runtime");
}
```

Or explicitly:

```rust
fn main() {
  let rt = Builder::new_multi_thread()
    .worker_threads(num_cpus::get())            // Auto-detect CPU count
    .enable_all()
    .build()
    .expect("Failed to build runtime");

  rt.block_on(async {
    let (tx, mut rx) = tokio::sync::mpsc::channel(100);
    
    // Spawn tasks that may run in parallel
    for i in 0..10 {
      let tx = tx.clone();
      tokio::spawn(async move {
        println!("Task {} running on worker thread", i);
        tx.send(i).await.ok();
      });
    }
    
    // Collect results
    for _ in 0..10 {
      if let Some(val) = rx.recv().await {
        println!("Received: {}", val);
      }
    }
  });
}
```

#### Use multi-thread when

- Building production web servers or microservices
- Handling high concurrency with mixed I/O and compute
- Leveraging multiple CPU cores for parallel work
- Need work-stealing for load balancing

#### Performance considerations

- Multi-threaded runtime has more overhead per spawn (atomic operations, queue interactions)
- Work-stealing ensures idle threads steal work from busy threads
- Better CPU utilization under varying load patterns
- Necessary for achieving true parallelism on multi-core systems

---

## **The Executor and Work-Stealing Scheduler**

Tokio's executor is the core that drives futures to completion. At a high level, the executor:

1. Maintains task queues (one per worker thread in multi-threaded mode)
2. Repeatedly wakes and polls ready tasks
3. Reacts to notifications from task wakers
4. Manages the transition of tasks between ready and pending states

### Work-Stealing Architecture

Tokio's multi-threaded executor uses a **work-stealing scheduler** to distribute work fairly across threads. Each worker thread maintains a local task queue and, when idle, attempts to steal tasks from neighboring threads' queues. This ensures even distribution and prevents starvation without requiring global synchronization:

```rust
use std::time::Duration;
use std::sync::{Arc, Mutex};

#[tokio::main]
async fn work_stealing_example() {
  let counter = Arc::new(Mutex::new(0));

  // Spawn many tasks; scheduler distributes across threads
  let mut handles = vec![];
  for i in 0..20 {
    let c = Arc::clone(&counter);
    let handle = tokio::spawn(async move {
      // Simulate variable-length tasks
      let duration = Duration::from_millis((i % 5 + 1) as u64 * 10);
      tokio::time::sleep(duration).await;
      
      let mut count = c.lock().unwrap();
      *count += 1;
      println!("Task {} completed", i);
    });
    handles.push(handle);
  }

  // Wait for all tasks
  for handle in handles {
    let _ = handle.await;
  }

  let final_count = *counter.lock().unwrap();
  println!("Total tasks completed: {}", final_count);
}
```

The work-stealing scheduler provides:

- **Load balancing** — Idle threads steal from busy threads
- **Minimal synchronization** — Lock-free queues for stealing
- **Cache locality** — Tasks prefer their local queue
- **Fairness** — No task is starved indefinitely

---

## **I/O and Async Operations**

Tokio provides async wrappers around OS I/O primitives, integrating with the system's event notification mechanism (epoll on Linux, kqueue on BSD/macOS, IOCP on Windows):

### TCP Networking

Network operations are among the most common async workloads. Tokio provides `TcpListener` and `TcpStream` for building networked applications:

```rust
use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[tokio::main]
async fn main() {
  // Bind to port; returns immediately
  let listener = TcpListener::bind("127.0.0.1:8080").await.unwrap();
  println!("Server listening on 127.0.0.1:8080");

  loop {
    // Accept returns when connection arrives
    let (mut socket, addr) = listener.accept().await.unwrap();
    println!("New connection from {}", addr);

    // Spawn a task per connection; executor handles concurrency
    tokio::spawn(async move {
      let mut buf = [0; 1024];
      
      loop {
        match socket.read(&mut buf).await {
          Ok(0) => break,  // Connection closed
          Ok(n) => {
            println!("Read {} bytes from {}", n, addr);
            // Echo response
            if socket.write_all(&buf[..n]).await.is_err() {
              break;
            }
          }
          Err(_) => break,
        }
      }
    });
  }
}
```

This pattern handles thousands of concurrent connections on a small number of threads. Each `.await` on a socket operation suspends the task, allowing other tasks to run. When the OS indicates the socket is ready, the waker notifies the executor to resume the task.

### File Operations

Dynamic file I/O uses `tokio::fs`:

```rust
use tokio::fs::File;
use tokio::io::AsyncReadExt;

async fn read_file_async(path: &str) -> tokio::io::Result<String> {
  let mut file = File::open(path).await?;
  let mut contents = String::new();
  file.read_to_string(&mut contents).await?;
  Ok(contents)
}

#[tokio::main]
async fn main() {
  match read_file_async("data.txt").await {
    Ok(contents) => println!("File contents: {}", contents),
    Err(e) => eprintln!("Error reading file: {}", e),
  }
}
```

### Blocking Operations

Some operations cannot be made asynchronous (CPU-bound work, legacy libraries). Tokio provides `spawn_blocking` to offload blocking work to a separate thread pool:

```rust
#[tokio::main]
async fn main() {
  // Offload blocking work to thread pool
  let result = tokio::task::spawn_blocking(|| {
    // This runs on a blocking thread, not the async runtime
    expensive_computation()
  })
  .await
  .unwrap();

  println!("Blocking result: {}", result);
}

fn expensive_computation() -> u64 {
  // CPU-intensive work that cannot yield
  (0..1_000_000_000).sum()
}
```

Using `spawn_blocking` is critical to prevent blocking the executor and starving other tasks. Never perform long-running synchronous work directly in async functions.

---

## **Time and Timer Management**

Tokio manages timers efficiently using hierarchical timing wheels, supporting many concurrent timeouts with minimal overhead:

### Sleep Operations

The most common time operation is `sleep`, which suspends a task until a deadline:

```rust
use tokio::time::{sleep, Duration, Instant};

async fn timeout_example() {
  let start = Instant::now();
  
  println!("Starting at {:?}", start.elapsed());
  
  // Sleep for 2 seconds
  sleep(Duration::from_secs(2)).await;
  
  println!("Elapsed: {:?}", start.elapsed());
}

#[tokio::main]
async fn main() {
  timeout_example().await;
}
```

### Timeouts

The `timeout` function wraps a future and returns an error if it doesn't complete within the deadline:

```rust
use tokio::time::timeout;
use std::time::Duration;

async fn slow_operation() -> String {
  tokio::time::sleep(Duration::from_secs(5)).await;
  "Completed".to_string()
}

#[tokio::main]
async fn main() {
  match timeout(Duration::from_secs(2), slow_operation()).await {
    Ok(result) => println!("Success: {}", result),
    Err(_) => println!("Operation timed out"),
  }
}
```

### Intervals

Repeated operations at fixed intervals use `interval`:

```rust
use tokio::time::{interval, Duration};

async fn periodic_task() {
  let mut interval = interval(Duration::from_secs(1));

  for i in 0..5 {
    interval.tick().await;
    println!("Tick {}", i);
  }
}

#[tokio::main]
async fn main() {
  periodic_task().await;
}
```

The timing wheel implementation ensures that creating thousands of timers has minimal impact on performance. Each timer is O(1) to register and unregister.

---

## **Task Spawning and Lifetime Management**

Tasks are the unit of concurrency in Tokio. Each spawned task is independent and driven to completion by the executor:

### Basic Task Spawning

`tokio::spawn` creates a new task and returns a `JoinHandle` for awaiting its completion:

```rust
#[tokio::main]
async fn main() {
  // Spawn task; returns immediately
  let handle = tokio::spawn(async {
    println!("Task running");
    42
  });

  // Do other work
  println!("Main continues");

  // Wait for task completion
  match handle.await {
    Ok(result) => println!("Task returned: {}", result),
    Err(e) => eprintln!("Task panicked: {}", e),
  }
}
```

### Multiple Concurrent Tasks

Spawning many tasks enables high concurrency with minimal resource usage:

```rust
#[tokio::main]
async fn main() {
  let mut handles = vec![];

  // Spawn 100 concurrent tasks
  for i in 0..100 {
    let handle = tokio::spawn(async move {
      println!("Task {} executing", i);
      tokio::time::sleep(std::time::Duration::from_millis(100)).await;
      i * 2
    });
    handles.push(handle);
  }

  // Collect results
  let mut results = vec![];
  for handle in handles {
    if let Ok(result) = handle.await {
      results.push(result);
    }
  }

  println!("All tasks completed. Results: {:?}", results);
}
```

This spawns 100 tasks concurrently, all running efficiently on the work-stealing scheduler. The tasks execute in arbitrary order, with the executor managing fairness and progress.

### Task Cancellation

Tasks can be cancelled by dropping them or using `abort()`:

```rust
#[tokio::main]
async fn main() {
  let handle = tokio::spawn(async {
    loop {
      tokio::time::sleep(std::time::Duration::from_secs(1)).await;
      println!("Still running");
    }
  });

  tokio::time::sleep(std::time::Duration::from_secs(3)).await;

  // Cancel the task
  handle.abort();

  // Task is now cancelled; await returns Cancelled error
  match handle.await {
    Err(e) if e.is_cancelled() => println!("Task was cancelled"),
    _ => {}
  }
}
```

Task cancellation triggers `Drop` implementations, ensuring cleanup occurs automatically.

---

## **Channels and Inter-Task Communication**

Channels enable safe communication between tasks without shared mutable state:

### MPSC (Multi-Producer, Single-Consumer)

The `mpsc` channel is for many tasks sending to one receiver:

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
  let (tx, mut rx) = mpsc::channel(100);  // Channel capacity: 100

  // Spawn producer tasks
  for i in 0..5 {
    let tx = tx.clone();
    tokio::spawn(async move {
      for j in 0..3 {
        let msg = format!("Producer {} message {}", i, j);
        tx.send(msg).await.ok();
      }
    });
  }

  // Drop original sender so receiver knows when all producers finish
  drop(tx);

  // Consumer task
  while let Some(msg) = rx.recv().await {
    println!("Received: {}", msg);
  }

  println!("All messages received");
}
```

### Broadcast Channel

For one-to-many publishing where all subscribers receive all messages:

```rust
use tokio::sync::broadcast;

#[tokio::main]
async fn main() {
  let (tx, _rx) = broadcast::channel(10);

  // Spawn subscriber tasks
  for i in 0..3 {
    let mut rx = tx.subscribe();
    tokio::spawn(async move {
      while let Ok(msg) = rx.recv().await {
        println!("Subscriber {} received: {}", i, msg);
      }
    });
  }

  // Publisher
  for i in 0..5 {
    let _ = tx.send(format!("Broadcast message {}", i));
  }

  tokio::time::sleep(std::time::Duration::from_millis(100)).await;
}
```

### Watch Channel

For sharing a single mutable state with multiple watchers:

```rust
use tokio::sync::watch;

#[tokio::main]
async fn main() {
  let (tx, mut rx) = watch::channel("initial");

  // Spawn watcher tasks
  for i in 0..3 {
    let mut rx = rx.clone();
    tokio::spawn(async move {
      while rx.changed().await.is_ok() {
        println!("Watcher {} sees: {}", i, *rx.borrow());
      }
    });
  }

  // Update state
  for i in 0..5 {
    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    tx.send(format!("Update {}", i)).ok();
  }
}
```

Channels are preferred over shared mutexes for avoiding contention and deadlocks.

---

## **Synchronization Primitives**

Tokio provides async-aware synchronization primitives that don't block the executor thread:

### Mutex

Async mutex for protecting shared state:

```rust
use tokio::sync::Mutex;
use std::sync::Arc;

#[tokio::main]
async fn main() {
  let counter = Arc::new(Mutex::new(0));

  let mut handles = vec![];
  for i in 0..10 {
    let c = Arc::clone(&counter);
    let handle = tokio::spawn(async move {
      let mut count = c.lock().await;
      *count += 1;
      println!("Task {} incremented counter", i);
    });
    handles.push(handle);
  }

  for handle in handles {
    let _ = handle.await;
  }

  let final_count = *counter.lock().await;
  println!("Final count: {}", final_count);
}
```

### RwLock

For read-heavy workloads where multiple readers can hold the lock simultaneously:

```rust
use tokio::sync::RwLock;
use std::sync::Arc;

#[tokio::main]
async fn main() {
  let data = Arc::new(RwLock::new(vec![1, 2, 3]));

  // Spawn reader tasks
  for i in 0..5 {
    let d = Arc::clone(&data);
    tokio::spawn(async move {
      let guard = d.read().await;
      println!("Reader {} sees: {:?}", i, *guard);
    });
  }

  // Spawn writer task
  tokio::time::sleep(std::time::Duration::from_millis(100)).await;
  let d = Arc::clone(&data);
  tokio::spawn(async move {
    let mut guard = d.write().await;
    guard.push(4);
    println!("Writer added element");
  });

  tokio::time::sleep(std::time::Duration::from_millis(200)).await;
}
```

### Semaphore

For rate-limiting or controlling concurrent access to a limited resource:

```rust
use tokio::sync::Semaphore;
use std::sync::Arc;

#[tokio::main]
async fn main() {
  let semaphore = Arc::new(Semaphore::new(3));  // Max 3 concurrent

  for i in 0..10 {
    let sem = Arc::clone(&semaphore);
    tokio::spawn(async move {
      let _permit = sem.acquire().await.unwrap();
      println!("Task {} acquired permit", i);
      tokio::time::sleep(std::time::Duration::from_millis(100)).await;
      println!("Task {} releasing permit", i);
    });
  }

  tokio::time::sleep(std::time::Duration::from_millis(500)).await;
}
```

These primitives are designed to avoid holding locks across `.await` points, preventing executor starvation.

---

## **Testing Async Code**

Tokio provides the `#[tokio::test]` macro for writing and running async tests:

### Basic Test

```rust
#[cfg(test)]
mod tests {
  use super::*;

  #[tokio::test]
  async fn test_async_operation() {
    let result = async_function().await;
    assert_eq!(result, 42);
  }

  async fn async_function() -> i32 {
    42
  }
}
```

Each test gets its own runtime instance, ensuring isolation:

```rust
#[tokio::test]
async fn test_concurrent_tasks() {
  let mut handles = vec![];

  for i in 0..5 {
    let handle = tokio::spawn(async move {
      assert!(i < 5);
      i * 2
    });
    handles.push(handle);
  }

  for handle in handles {
    let _ = handle.await;
  }
}
```

### Test Runtime Configuration

For tests requiring specific runtime behavior:

```rust
#[tokio::test(flavor = "current_thread")]
async fn test_single_threaded() {
  // Test runs on single thread
  let result = single_threaded_operation().await;
  assert_eq!(result, "success");
}

async fn single_threaded_operation() -> &'static str {
  "success"
}
```

---

## **Advanced Configuration and Tuning**

Production applications often require fine-tuned runtime behavior:

### Customizing Thread Count

The number of worker threads should match your workload. For I/O-bound applications, CPU count is typical; for CPU-bound mixed workloads, tune based on profiling:

```rust
use tokio::runtime::Builder;
use num_cpus;

fn main() {
  let worker_count = num_cpus::get();  // Or customize based on load

  let rt = Builder::new_multi_thread()
    .worker_threads(worker_count)
    .thread_name_fn(|| {
      static ATOMIC_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
      let id = ATOMIC_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst);
      format!("tokio-worker-{}", id)
    })
    .build()
    .unwrap();

  rt.block_on(async {
    println!("Runtime configured with {} workers", worker_count);
  });
}
```

### Maximum Blocking Threads

Control how many threads are allocated for `spawn_blocking` tasks:

```rust
use tokio::runtime::Builder;

fn main() {
  let rt = Builder::new_multi_thread()
    .max_blocking_threads(256)  // Limit blocking thread pool
    .build()
    .unwrap();

  rt.block_on(async {
    // Blocking tasks use separate thread pool
  });
}
```

### Enabling/Disabling Features

Tokio features can be selectively enabled for minimal overhead:

```rust
use tokio::runtime::Builder;

fn main() {
  let rt = Builder::new_multi_thread()
    .enable_io()        // I/O multiplexing
    .enable_time()      // Timer management
    .build()
    .unwrap();
  
  // If you don't need all features, disable for performance
}
```

---

## **Common Patterns and Best Practices**

### Server Loop Pattern

Accept connections and spawn a handler per connection:

```rust
use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[tokio::main]
async fn main() {
  let listener = TcpListener::bind("0.0.0.0:8080").await.unwrap();

  loop {
    let (mut socket, addr) = listener.accept().await.unwrap();

    // Each connection gets its own task
    tokio::spawn(async move {
      let mut buf = [0; 4096];
      loop {
        match socket.read(&mut buf).await {
          Ok(0) => break,
          Ok(n) => {
            let _ = socket.write_all(&buf[..n]).await;
          }
          Err(_) => break,
        }
      }
    });
  }
}
```

### Producer-Consumer Pattern

Multiple producers sending to a single consumer via channel:

```rust
use tokio::sync::mpsc;

async fn producer(id: usize, tx: mpsc::Sender<String>) {
  for i in 0..10 {
    let msg = format!("From producer {}: message {}", id, i);
    tx.send(msg).await.ok();
    tokio::time::sleep(std::time::Duration::from_millis(10)).await;
  }
}

async fn consumer(mut rx: mpsc::Receiver<String>) {
  while let Some(msg) = rx.recv().await {
    println!("Consumed: {}", msg);
  }
}

#[tokio::main]
async fn main() {
  let (tx, rx) = mpsc::channel(100);

  // Spawn producers
  for i in 0..3 {
    let tx_clone = tx.clone();
    tokio::spawn(async move {
      producer(i, tx_clone).await;
    });
  }

  drop(tx);  // Close original sender

  // Consumer
  consumer(rx).await;
}
```

### Rate Limiting with Semaphore

Limit concurrent resource access:

```rust
use tokio::sync::Semaphore;
use std::sync::Arc;

async fn worker(id: usize, sem: Arc<Semaphore>) {
  let _permit = sem.acquire().await.unwrap();
  println!("Worker {} running", id);
  tokio::time::sleep(std::time::Duration::from_secs(1)).await;
  println!("Worker {} done", id);
}

#[tokio::main]
async fn main() {
  let sem = Arc::new(Semaphore::new(3));  // Max 3 concurrent

  for i in 0..10 {
    let s = Arc::clone(&sem);
    tokio::spawn(async move {
      worker(i, s).await;
    });
  }

  tokio::time::sleep(std::time::Duration::from_secs(5)).await;
}
```

---

## **Performance Considerations**

### Spawn Overhead

While `tokio::spawn` is cheap, it's not free. Each spawn involves:

- Allocation of task metadata
- Queue insertion
- Potential context switch

For tight loops or very short-lived tasks, consider batching:

```rust
// Avoid: Many small spawns
for item in items {
  tokio::spawn(async move {
    process(item);
  });
}

// Better: Process in batches
for batch in items.chunks(100) {
  tokio::spawn(async move {
    for item in batch {
      process(item);
    }
  });
}
```

### Lock Contention

Synchronization primitives add overhead. Prefer channels for inter-task communication:

```rust
// Avoid: High contention mutex
let counter = Arc::new(Mutex::new(0));
for _ in 0..10000 {
  let c = Arc::clone(&counter);
  tokio::spawn(async move {
    *c.lock().await += 1;
  });
}

// Better: Channel with aggregation
let (tx, mut rx) = tokio::sync::mpsc::channel(100);
for i in 0..10000 {
  let tx = tx.clone();
  tokio::spawn(async move {
    tx.send(i).await.ok();
  });
}

let mut total = 0;
while let Some(_) = rx.recv().await {
  total += 1;
}
```

### Block-on Performance

Avoid calling `rt.block_on()` multiple times. Each call incurs overhead. Initialize once and reuse:

```rust
// Avoid: Multiple block_on calls
for i in 0..100 {
  let rt = tokio::runtime::Runtime::new().unwrap();
  rt.block_on(async { /* work */ });
}

// Better: Single runtime
let rt = tokio::runtime::Runtime::new().unwrap();
rt.block_on(async {
  for i in 0..100 {
    /* work */
  }
});
```

---

## **Key Takeaways**

| Concept              | Summary                                                                                  |
| -------------------- | ---------------------------------------------------------------------------------------- |
| **Runtime**          | Executor that drives futures via polling; initialized with `#[tokio::main]` or `Builder` |
| **Work-Stealing**    | Multi-threaded scheduler distributes tasks fairly across worker threads                  |
| **I/O Multiplexing** | OS-level integration (epoll/kqueue/IOCP) for efficient event notification                |
| **Task Spawning**    | `tokio::spawn` creates lightweight concurrent tasks; cheap but not free                  |
| **Channels**         | MPSC, broadcast, watch for safe inter-task communication                                 |
| **Synchronization**  | `Mutex`, `RwLock`, `Semaphore` for protecting shared state without blocking executor     |
| **Timers**           | Hierarchical timing wheels for efficient timeout and interval management                 |
| **Blocking Work**    | `spawn_blocking` offloads synchronous work to prevent starvation                         |
| **Testing**          | `#[tokio::test]` provides isolated async test environments                               |
| **Customization**    | `Builder` API enables fine-grained runtime configuration                                 |

- Use `#[tokio::main]` for most applications; custom configuration is rarely needed initially
- Prefer channels over mutexes for inter-task communication
- Always offload blocking work to `spawn_blocking` to prevent executor starvation
- Consider single-threaded runtime flavor for testing or minimal concurrency
- Tune thread count based on workload profiling, not guesses
- Never perform long CPU-bound work directly in async functions
- Monitor lock contention and channel throughput in production
- Understand that async does not guarantee parallelism; the runtime scheduler provides that
- For production systems, initialize runtime once and reuse; avoid repeated `block_on` calls

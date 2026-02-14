# **Topic 3.1.6: Advanced Concurrency**

Advanced concurrency patterns in Rust go beyond basic async/await mechanics and task spawning. Production systems require sophisticated strategies for managing unbounded data streams, handling mixed I/O and CPU workloads, implementing backpressure, coordinating complex task lifecycles, and ensuring graceful degradation under load. This topic explores the advanced patterns and architectural decisions that separate toy examples from production-ready concurrent systems.

These patterns form the foundation of high-performance network services, distributed systems, real-time data processing pipelines, and resilient microservices.

## **Learning Objectives**

- Master asynchronous streams for processing unbounded sequences of data
- Implement custom stream types with proper error handling and cancellation semantics
- Design backpressure mechanisms to prevent resource exhaustion under load
- Handle CPU-bound workloads in async contexts without executor starvation
- Apply select patterns for racing futures, timeouts, and graceful cancellation
- Build actor-like patterns for message-passing concurrency
- Implement circuit breakers and retry logic for fault-tolerant systems
- Understand structured concurrency and lifetime management of task hierarchies
- Design fair schedulers and resource allocation strategies
- Debug and profile concurrent systems to identify bottlenecks

---

## **Asynchronous Streams: Beyond Single-Value Futures**

While a `Future<Output = T>` represents a single asynchronous computation that eventually produces one value, a `Stream<Item = T>` represents an **asynchronous sequence** that produces multiple values over time. Streams are the async equivalent of iterators, enabling functional-style processing of unbounded data sequences with backpressure control.

### Working with Streams

Streams are essential for processing potentially infinite sequences of data—network packets, log lines, sensor readings, database result sets, or any scenario where data arrives over time rather than all at once. The `Stream` trait provides a unified interface for consuming these sequences with full async/await integration.

#### Basic Stream Consumption

```rust
use tokio_stream::{self as stream, StreamExt};

#[tokio::main]
async fn main() {
  // Create a stream from an iterator
  let mut stream = stream::iter(vec![1, 2, 3, 4, 5]);

  // Consume with next() - each call is an async operation
  while let Some(value) = stream.next().await {
    println!("Value: {}", value);
  }
}
```

The key difference from synchronous iterators: each `next()` call returns a `Future`, allowing the task to suspend if data isn't ready. This enables concurrent processing of multiple streams without blocking threads.

#### Stream Combinators and Functional Patterns

Streams support functional-style transformations similar to Rust's `Iterator` trait, but all operations are lazy and async-aware:

```rust
use tokio_stream::{self as stream, StreamExt};
use std::time::Duration;

#[tokio::main]
async fn main() {
  stream::iter(1..=10)
    .map(|x| x * 2)                    // Transform each item
    .filter(|x| x % 3 == 0)            // Filter by predicate
    .take(5)                           // Limit to first 5 items
    .throttle(Duration::from_millis(100)) // Rate limiting
    .for_each(|x| async move {
      println!("Processing: {}", x);
    })
    .await;
}
```

Combinators chain without intermediate allocations. The stream pipeline is fully lazy—no work happens until the terminal operation (like `for_each`) drives it.

#### Advanced Combinator Patterns

```rust
use tokio_stream::{self as stream, StreamExt};
use std::time::Duration;

#[tokio::main]
async fn main() {
  // Example: Processing HTTP request stream with error handling and batching
  stream::iter(1..=100)
    .map(|id| async move {
      // Simulate fetching data
      tokio::time::sleep(Duration::from_millis(10)).await;
      if id % 10 == 0 {
        Err(format!("Failed to fetch {}", id))
      } else {
        Ok(id)
      }
    })
    .buffer_unordered(10)              // Process up to 10 concurrently
    .filter_map(|result| match result {
      Ok(value) => Some(value),
      Err(e) => {
        eprintln!("Error: {}", e);
        None
      }
    })
    .chunks(5)                         // Batch into groups of 5
    .for_each(|batch| async move {
      println!("Processing batch: {:?}", batch);
    })
    .await;
}
```

The `buffer_unordered` combinator is particularly powerful: it runs multiple `Future`s concurrently (up to the specified limit) and yields results as they complete, regardless of order. This enables high-throughput parallel processing while maintaining backpressure.

### Implementing Custom Streams

Custom stream implementations are necessary when wrapping asynchronous data sources that don't already provide stream adapters. Understanding how to implement the `Stream` trait directly gives you complete control over data flow, error handling, and resource management.

#### Basic Custom Stream: Interval-Based Events

```rust
use futures::stream::{Stream, StreamExt};
use std::pin::Pin;
use std::task::{Context, Poll};
use tokio::time::{Instant, Interval};

/// A stream that emits events at regular intervals
struct IntervalStream {
  interval: Interval,
  count: u32,
  max: u32,
}

impl IntervalStream {
  fn new(duration: std::time::Duration, max: u32) -> Self {
    Self {
      interval: tokio::time::interval(duration),
      count: 0,
      max,
    }
  }
}

impl Stream for IntervalStream {
  type Item = (u32, Instant);

  fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
    if self.count >= self.max {
      return Poll::Ready(None); // Stream exhausted
    }

    // Poll the interval; it will register a waker if not ready
    match Pin::new(&mut self.interval).poll_tick(cx) {
      Poll::Ready(instant) => {
        self.count += 1;
        Poll::Ready(Some((self.count, instant)))
      }
      Poll::Pending => Poll::Pending,
    }
  }
}

#[tokio::main]
async fn main() {
  let mut stream = IntervalStream::new(std::time::Duration::from_millis(500), 10);
  
  while let Some((count, instant)) = stream.next().await {
    println!("Event {} at {:?}", count, instant);
  }
}
```

This demonstrates the critical pattern: delegate to an underlying async primitive (`Interval`) and properly forward the `Context` for waker registration.

#### Production Stream: Error-Handling HTTP Response Stream

```rust
use futures::stream::{Stream, StreamExt};
use std::pin::Pin;
use std::task::{Context, Poll};
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::net::TcpStream;

/// Stream that reads lines from a TCP connection with error handling
struct LineStream {
  reader: BufReader<TcpStream>,
  buffer: String,
}

impl LineStream {
  fn new(stream: TcpStream) -> Self {
    Self {
      reader: BufReader::new(stream),
      buffer: String::new(),
    }
  }
}

impl Stream for LineStream {
  type Item = Result<String, std::io::Error>;

  fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
    self.buffer.clear();
    
    // Pin projection to poll the async read_line operation
    let reader = &mut self.reader;
    let buffer = &mut self.buffer;
    
    // Create a future for the read operation and poll it
    let mut read_future = Box::pin(reader.read_line(buffer));
    
    match read_future.as_mut().poll(cx) {
      Poll::Ready(Ok(0)) => Poll::Ready(None), // EOF
      Poll::Ready(Ok(_)) => Poll::Ready(Some(Ok(self.buffer.clone()))),
      Poll::Ready(Err(e)) => Poll::Ready(Some(Err(e))),
      Poll::Pending => Poll::Pending,
    }
  }
}
```

This pattern handles errors gracefully by yielding `Result` items, allowing the consumer to decide whether to continue or abort on errors.

#### Production Stream: TCP Connection Listener with Graceful Shutdown

```rust
use tokio::net::{TcpListener, TcpStream};
use tokio_stream::wrappers::TcpListenerStream;
use tokio_stream::StreamExt;
use tokio::sync::broadcast;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
  let listener = TcpListener::bind("127.0.0.1:8080").await?;
  let listener_stream = TcpListenerStream::new(listener);
  
  // Broadcast channel for shutdown signal
  let (shutdown_tx, _) = broadcast::channel::<()>(1);
  
  listener_stream
    .take_while(|_| {
      // Could check shutdown signal here
      futures::future::ready(true)
    })
    .for_each_concurrent(100, |connection| {  // Handle 100 connections concurrently
      let mut shutdown_rx = shutdown_tx.subscribe();
      async move {
        match connection {
          Ok((socket, addr)) => {
            tokio::spawn(async move {
              tokio::select! {
                result = handle_connection(socket, addr) => {
                  if let Err(e) = result {
                    eprintln!("Connection error from {}: {}", addr, e);
                  }
                }
                _ = shutdown_rx.recv() => {
                  println!("Shutting down connection {}", addr);
                }
              }
            });
          }
          Err(e) => eprintln!("Accept error: {}", e),
        }
      }
    })
    .await;

  Ok(())
}

async fn handle_connection(
  socket: TcpStream,
  addr: std::net::SocketAddr,
) -> Result<(), Box<dyn std::error::Error>> {
  println!("Handling connection from: {}", addr);
  // Connection handling logic
  Ok(())
}
```

The `for_each_concurrent` combinator processes multiple stream items in parallel while respecting the concurrency limit, preventing resource exhaustion.

---

## **Backpressure and Flow Control**

Backpressure is one of the most critical concepts in production async systems. It prevents system collapse when consumers cannot keep pace with producers, ensuring graceful degradation instead of catastrophic failure. Without proper backpressure, systems experience unbounded memory growth, resource exhaustion, and cascading failures.

### Understanding Backpressure

Backpressure occurs when data arrives faster than it can be processed. In streaming systems, this creates a choice:

1. **Buffer** (accumulate data in memory until processing catches up)
2. **Block** (slow down the producer to match consumer speed)
3. **Drop** (shed excess load to protect system health)

Each strategy has different tradeoffs for latency, throughput, memory usage, and data loss tolerance.

#### The Problem: Unbounded Growth

```rust
// ❌ PROBLEMATIC: Unbounded channel growth
use tokio::sync::mpsc;
use std::time::Duration;

#[tokio::main]
async fn main() {
  let (tx, mut rx) = mpsc::unbounded_channel::<Vec<u8>>();

  // Fast producer: generates 1MB per millisecond
  tokio::spawn(async move {
    for i in 0..10_000 {
      let data = vec![0u8; 1_000_000]; // 1MB per item
      // This never blocks - channel grows indefinitely!
      let _ = tx.send(data);
      tokio::time::sleep(Duration::from_millis(1)).await;
    }
  });

  // Slow consumer: processes 1MB every 10ms
  while let Some(data) = rx.recv().await {
    // Processing takes 10x longer than production
    tokio::time::sleep(Duration::from_millis(10)).await;
    println!("Processed {} bytes", data.len());
  }
  
  // Result: Channel buffer grows to ~9GB before consumer catches up
  // System likely OOMs before completion
}
```

The unbounded channel allows the producer to continuously enqueue data without waiting, creating unbounded memory growth. In production, this leads to OOM kills and service downtime.

### Strategy 1: Bounded Channels with Blocking Backpressure

The simplest and most common backpressure mechanism is a bounded channel. When the buffer fills, `send()` suspends the producer until space becomes available:

```rust
use tokio::sync::mpsc;
use std::time::Duration;

#[tokio::main]
async fn main() {
  // Bounded channel creates natural backpressure
  let (tx, mut rx) = mpsc::channel::<String>(10);  // Buffer capacity: 10

  let producer = tokio::spawn(async move {
    for i in 0..100 {
      // This will block (yield) when buffer is full
      match tx.send(format!("Message {}", i)).await {
        Ok(_) => println!("Sent message {}", i),
        Err(_) => {
          eprintln!("Receiver closed, stopping producer");
          break;
        }
      }
      tokio::time::sleep(Duration::from_millis(1)).await;
    }
    println!("Producer finished");
  });

  let consumer = tokio::spawn(async move {
    while let Some(msg) = rx.recv().await {
      println!("Received: {}", msg);
      // Slower consumer creates backpressure
      tokio::time::sleep(Duration::from_millis(10)).await;
    }
    println!("Consumer finished");
  });

  let _ = tokio::join!(producer, consumer);
}
```

When the buffer fills (10 messages), the producer's `send().await` suspends, automatically slowing down to match the consumer's processing rate. This prevents unbounded memory growth.

### Strategy 2: Stream Buffering with `buffer_unordered`

For parallel processing with backpressure, `buffer_unordered` limits concurrent in-flight futures:

```rust
use tokio_stream::{self as stream, StreamExt};
use std::time::Duration;

async fn process_item(id: u64) -> Result<u64, String> {
  // Simulate variable processing time
  tokio::time::sleep(Duration::from_millis(10 + (id % 20))).await;
  
  if id % 50 == 0 {
    Err(format!("Failed to process {}", id))
  } else {
    Ok(id * 2)
  }
}

#[tokio::main]
async fn main() {
  let results: Vec<_> = stream::iter(1..=1000)
    .map(|id| async move {
      match process_item(id).await {
        Ok(result) => Some(result),
        Err(e) => {
          eprintln!("Error: {}", e);
          None
        }
      }
    })
    // Limit to 50 concurrent operations
    // If 50 futures are in-flight, stream pauses until one completes
    .buffer_unordered(50)
    .filter_map(|x| x)
    .collect()
    .await;

  println!("Processed {} items", results.len());
}
```

The `buffer_unordered(50)` combinator ensures at most 50 `process_item` futures run concurrently. When this limit is reached, the stream suspends production of new futures until existing ones complete, providing automatic backpressure.

---

## **Advanced Concurrency Patterns**

Beyond basic task spawning and stream processing, production systems require sophisticated coordination patterns for fault tolerance, resource management, and graceful degradation.

### Pattern 1: Select and Racing Futures

The `select!` macro enables racing multiple futures and acting on whichever completes first. This is essential for implementing timeouts, cancellation, and priority-based execution:

```rust
use tokio::select;
use tokio::time::{timeout, Duration, sleep};
use tokio::sync::mpsc;

async fn network_request(id: u64) -> Result<String, String> {
  sleep(Duration::from_millis(100 * id)).await;
  if id % 3 == 0 {
    Err(format!("Request {} failed", id))
  } else {
    Ok(format!("Response from {}", id))
  }
}

#[tokio::main]
async fn main() {
  // Pattern: Timeout with fallback
  select! {
    result = network_request(1) => {
      println!("Primary completed: {:?}", result);
    }
    _ = sleep(Duration::from_millis(50)) => {
      println!("Timeout - using cached response");
    }
  }
  
  // Pattern: Racing multiple backends
  select! {
    result = network_request(1) => {
      println!("Backend 1: {:?}", result);
    }
    result = network_request(2) => {
      println!("Backend 2: {:?}", result);
    }
    result = network_request(3) => {
      println!("Backend 3: {:?}", result);
    }
  }
  
  // Pattern: Graceful shutdown
  let (shutdown_tx, mut shutdown_rx) = mpsc::channel::<()>(1);
  
  tokio::spawn(async move {
    sleep(Duration::from_secs(2)).await;
    let _ = shutdown_tx.send(()).await;
  });
  
 loop {
    select! {
      _ = sleep(Duration::from_millis(100)) => {
        println!("Processing work...");
      }
      _ = shutdown_rx.recv() => {
        println!("Shutdown signal received");
        break;
      }
    }
  }
}
```

Critical insight: `select!` **cancels** all non-winning branches. Any resources held by those futures must be drop-safe.

### Pattern 2: Actor-Like Message Passing

The actor pattern encapsulates state within a task and communicates via message passing, eliminating shared mutability:

```rust
use tokio::sync::{mpsc, oneshot};
use std::collections::HashMap;

#[derive(Debug)]
enum CacheMessage {
  Get {
    key: String,
    respond_to: oneshot::Sender<Option<String>>,
  },
  Set {
    key: String,
    value: String,
  },
  Delete {
    key: String,
  },
}

struct CacheActor {
  receiver: mpsc::Receiver<CacheMessage>,
  storage: HashMap<String, String>,
}

impl CacheActor {
  fn new(receiver: mpsc::Receiver<CacheMessage>) -> Self {
    Self {
      receiver,
      storage: HashMap::new(),
    }
  }
  
  async fn run(mut self) {
    while let Some(msg) = self.receiver.recv().await {
      match msg {
        CacheMessage::Get { key, respond_to } => {
          let value = self.storage.get(&key).cloned();
          let _ = respond_to.send(value);
        }
        CacheMessage::Set { key, value } => {
          self.storage.insert(key, value);
        }
        CacheMessage::Delete { key } => {
          self.storage.remove(&key);
        }
      }
    }
  }
}

#[derive(Clone)]
struct CacheHandle {
  sender: mpsc::Sender<CacheMessage>,
}

impl CacheHandle {
  fn new() -> Self {
    let (sender, receiver) = mpsc::channel(100);
    let actor = CacheActor::new(receiver);
    
    tokio::spawn(async move {
      actor.run().await;
    });
    
    Self { sender }
  }
  
  async fn get(&self, key: String) -> Option<String> {
    let (tx, rx) = oneshot::channel();
    let msg = CacheMessage::Get {
      key,
      respond_to: tx,
    };
    
    let _ = self.sender.send(msg).await;
    rx.await.ok().flatten()
  }
  
  async fn set(&self, key: String, value: String) {
    let msg = CacheMessage::Set { key, value };
    let _ = self.sender.send(msg).await;
  }
}

#[tokio::main]
async fn main() {
  let cache = CacheHandle::new();
  
  // Multiple tasks can safely access the cache concurrently
  cache.set("key1".to_string(), "value1".to_string()).await;
  
  let value = cache.get("key1".to_string()).await;
  println!("Retrieved: {:?}", value);
}
```

This pattern provides:

- **Isolation**: State lives in one task, no shared mutability
- **Backpressure**: Bounded channel prevents unbounded message queues
- **Simplicity**: No mutex contention or deadlock potential

### Pattern 3: Circuit Breaker for Fault Tolerance

Circuit breakers prevent cascading failures by detecting failing services and temporarily stopping requests:

```rust
use tokio::sync::RwLock;
use tokio::time::{Duration, Instant};
use std::sync::Arc;

#[derive(Debug, Clone, Copy, PartialEq)]
enum CircuitState {
  Closed,      // Normal operation
  Open,        // Failing, rejecting requests
  HalfOpen,    // Testing if recovered
}

struct CircuitBreaker {
  state: Arc<RwLock<CircuitState>>,
  failure_count: Arc<RwLock<u32>>,
  last_failure_time: Arc<RwLock<Option<Instant>>>,
  failure_threshold: u32,
  timeout: Duration,
}

impl CircuitBreaker {
  fn new(failure_threshold: u32, timeout: Duration) -> Self {
    Self {
      state: Arc::new(RwLock::new(CircuitState::Closed)),
      failure_count: Arc::new(RwLock::new(0)),
      last_failure_time: Arc::new(RwLock::new(None)),
      failure_threshold,
      timeout,
    }
  }
  
  async fn call<F, T, E>(&self, f: F) -> Result<T, String>
  where
    F: std::future::Future<Output = Result<T, E>>,
    E: std::fmt::Display,
  {
    // Check circuit state
    let state = *self.state.read().await;
    
    match state {
      CircuitState::Open => {
        // Check if timeout expired
        if let Some(last_failure) = *self.last_failure_time.read().await {
          if last_failure.elapsed() > self.timeout {
            *self.state.write().await = CircuitState::HalfOpen;
          } else {
            return Err("Circuit breaker open".to_string());
          }
        }
      }
      _ => {}
    }
    
    // Execute the function
    match f.await {
      Ok(result) => {
        // Success - reset circuit
        *self.failure_count.write().await = 0;
        *self.state.write().await = CircuitState::Closed;
        Ok(result)
      }
      Err(e) => {
        // Failure - increment counter
        let mut count = self.failure_count.write().await;
        *count += 1;
        
        if *count >= self.failure_threshold {
          *self.state.write().await = CircuitState::Open;
          *self.last_failure_time.write().await = Some(Instant::now());
        }
        
        Err(format!("Operation failed: {}", e))
      }
    }
  }
}

async fn unreliable_service(id: u32) -> Result<String, String> {
  if id % 3 == 0 {
    Err("Service error".to_string())
  } else {
    Ok(format!("Success: {}", id))
  }
}

#[tokio::main]
async fn main() {
  let breaker = Arc::new(CircuitBreaker::new(3, Duration::from_secs(5)));
  
  for i in 0..10 {
    let breaker = Arc::clone(&breaker);
    tokio::spawn(async move {
      match breaker.call(unreliable_service(i)).await {
        Ok(result) => println!("{}", result),
        Err(e) => println!("Request {}: {}", i, e),
      }
    });
    
    tokio::time::sleep(Duration::from_millis(100)).await;
  }
  
  tokio::time::sleep(Duration::from_secs(2)).await;
}
```

### Pattern 4: Retry with Exponential Backoff

```rust
use tokio::time::{sleep, Duration};

async fn retry_with_backoff<F, T, E>(
  mut f: F,
  max_retries: u32,
  initial_delay: Duration,
) -> Result<T, E>
where
  F: FnMut() -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<T, E>> + Send>>,
{
  let mut delay = initial_delay;
  
  for attempt in 0..max_retries {
    match f().await {
      Ok(result) => return Ok(result),
      Err(e) if attempt == max_retries - 1 => return Err(e),
      Err(_) => {
        println!("Attempt {} failed, retrying in {:?}", attempt + 1, delay);
        sleep(delay).await;
        delay *= 2;  // Exponential backoff
      }
    }
  }
  
  unreachable!()
}

async fn flaky_operation(attempt: &mut u32) -> Result<String, String> {
  *attempt += 1;
  if *attempt < 3 {
    Err(format!("Attempt {} failed", attempt))
  } else {
    Ok("Success!".to_string())
  }
}

#[tokio::main]
async fn main() {
  let mut attempt = 0;
  
  let result = retry_with_backoff(
    || Box::pin(flaky_operation(&mut attempt)),
    5,
    Duration::from_millis(100),
  )
  .await;
  
  println!("Final result: {:?}", result);
}
```

---

## **CPU-Intensive Work in Async Contexts**

Async runtimes optimize for I/O-bound workloads where tasks spend most of their time waiting. CPU-intensive work requires different strategies to avoid starving the executor.

### The Problem: Blocking the Executor

```rust
// ❌ BAD: CPU-intensive work blocks the executor thread
#[tokio::main]
async fn main() {
  tokio::spawn(async {
    // This computation blocks the executor thread for seconds
    let result: u64 = (0..1_000_000_000).sum();
    println!("Result: {}", result);
  });
  
  // These tasks cannot run while the CPU-bound task monopolizes the thread
  for i in 0..10 {
    tokio::spawn(async move {
      println!("Task {} trying to run", i);
    });
  }
  
  tokio::time::sleep(std::time::Duration::from_secs(5)).await;
}
```

Without yield points, the CPU-bound task prevents other tasks from making progress, breaking the cooperative scheduling model.

### Solution 1: `spawn_blocking` for Isolation

Offload CPU-intensive work to a dedicated blocking thread pool:

```rust
use tokio::task;

#[tokio::main]
async fn main() {
  // Spawn blocking work in dedicated thread pool
  let handle = task::spawn_blocking(|| {
    println!("Starting expensive computation");
    let result: u64 = (0..1_000_000_000).sum();
    println!("Computation complete");
    result
  });

  // Other async tasks continue unblocked
  for i in 0..10 {
    tokio::spawn(async move {
      println!("Task {} running normally", i);
    });
  }

  match handle.await {
    Ok(result) => println!("Blocking result: {}", result),
    Err(e) => eprintln!("Task panicked: {}", e),
  }
}
```

The blocking thread pool (default: 512 threads) isolates CPU work from async tasks.

### Solution 2: Yielding in Long Computations

For compute-bound work that must stay async, manually yield periodically:

```rust
use tokio::task;

async fn cpu_intensive_with_yields() -> u64 {
  let mut sum = 0u64;
  
  for i in 0..1_000_000_000 {
    sum += i;
    
    // Yield every 100k iterations to give other tasks a chance
    if i % 100_000 == 0 {
      task::yield_now().await;
    }
  }
  
  sum
}

#[tokio::main]
async fn main() {
  tokio::spawn(cpu_intensive_with_yields());
  
  // These tasks get regular opportunities to run
  for i in 0..10 {
    tokio::spawn(async move {
      loop {
        println!("Task {} running", i);
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
      }
    });
  }
  
  tokio::time::sleep(std::time::Duration::from_secs(5)).await;
}
```

### Solution 3: Hybrid Approach with Rayon

For data-parallel workloads, combine Tokio with Rayon for true parallelism:

```rust
use rayon::prelude::*;
use tokio::task;

async fn parallel_computation(data: Vec<i32>) -> i32 {
  // Offload to blocking pool, then use Rayon for parallelism
  task::spawn_blocking(move || {
    data.par_iter()
      .map(|x| x * x)
      .sum()
  })
  .await
  .unwrap()
}

#[tokio::main]
async fn main() {
  let data: Vec<i32> = (0..1_000_000).collect();
  
  let result = parallel_computation(data).await;
  println!("Parallel result: {}", result);
}
```

This pattern leverages Rayon's work-stealing for CPU parallelism while keeping the async runtime responsive.

### Production Pattern: Chunked Processing

For streaming computations, process in chunks with backpressure:

```rust
use tokio::task;
use tokio_stream::{self as stream, StreamExt};

async fn process_chunk(chunk: Vec<i32>) -> Vec<i32> {
  task::spawn_blocking(move || {
    // Heavy computation on chunk
    chunk.iter().map(|x| x * x).collect()
  })
  .await
  .unwrap()
}

#[tokio::main]
async fn main() {
  let results: Vec<_> = stream::iter(0..10_000)
    .chunks(100)                        // Batch into chunks of 100
    .map(|chunk| process_chunk(chunk))
    .buffer_unordered(10)               // Process 10 chunks concurrently
    .collect()
    .await;

  println!("Processed {} chunks", results.len());
}
```

This balances throughput with resource usage by limiting concurrent CPU work while maintaining async responsiveness.

---

## **Professional Applications**

Advanced concurrency patterns enable production-grade systems:

- **High-Throughput Web Servers:**
  - Streams handle continuous HTTP request flows
  - Backpressure prevents overload under traffic spikes
  - Circuit breakers protect against cascading failures
  - Connection pooling with bounded concurrency
- **Real-Time Data Pipelines:**
  - Multi-stage stream processing with backpressure at each stage
  - `buffer_unordered` for parallel ETL operations
  - Error handling with retry and dead-letter queues
  - Monitoring with metrics streams
- **Distributed Systems:**
  - Actor pat for node coordination
  - Select patterns for leader election timeouts
  - Graceful shutdown with cancellation propagation
  - Health checks with circuit breakers
- **Message Brokers and Event Processing:**
  - Unbounded event streams with bounded resource usage
  - Consumer groups with fair work distribution
  - Offset tracking and at-least-once delivery
  - Backpressure to match consumer throughput
- **Microservices Architecture:**
  - Service-to-service communication with timeouts
  - Retry with exponential backoff for transient failures
  - Load shedding under sustained overload
  - Structured concurrency for request tracing

---

## **Key Takeaways**

| Concept | Application | Critical Insight |
| ------- | ----------- | ---------------- |
| **Streams** | Unbounded async sequences | Lazy evaluation with functional combinators |
| **Backpressure** | Flow control | Bounded channels prevent resource exhaustion |
| **buffer_unordered** | Parallel processing | Limits concurrent in-flight futures |
| **spawn_blocking** | CPU-intensive work | Isolates blocking operations from async runtime |
| **select!** | Racing futures | Automatic cancellation of non-winning branches |
| **Actor Pattern** | State encapsulation | Message passing eliminates shared mutability |
| **Circuit Breaker** | Fault tolerance | Prevents cascading failures |
| **Retry with Backoff** | Resilience | Exponential delays avoid overwhelming failing services |
| **Load Shedding** | Graceful degradation | Reject excess load to protect system health |

- **Never block async code without `spawn_blocking`** — Long synchronous operations starve the executor
- **Always apply backpressure** — Use bounded channels and stream buffering limits
- **Prefer streams over manual loops** — Declarative composition reduces bugs
- **Make cancellation explicit** — Use `select!` and timeouts for clean shutdown
- **Monitor blocking pool utilization** — Default 512 threads can be exhausted
- **Design for failure** — Circuit breakers, retries, and load shedding are essential
- **Test under load** — Concurrency bugs emerge under stress
- **Profile in production** — Understanding where tasks block is critical
- **Structured concurrency** — Parent tasks should manage child task lifetimes
- **Metrics and observability** — Track queue depths, task spawn rates, and blocking pool usage

**Essential Testing Strategies:**

- Use `tokio-test` for time-based test scenarios
- Inject delays to expose race conditions
- Test cancellation paths explicitly
- Verify backpressure behavior under load
- Property-based testing with `proptest` for concurrent invariants
- Chaos testing to verify resilience patterns

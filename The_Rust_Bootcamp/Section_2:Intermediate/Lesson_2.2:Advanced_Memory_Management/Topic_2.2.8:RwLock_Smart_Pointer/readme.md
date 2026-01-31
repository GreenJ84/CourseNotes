# **Topic 2.2.8: `RwLock<T>` Smart Pointer**

`RwLock<T>` (Read-Write Lock) provides synchronized access to shared data by allowing **multiple concurrent readers** or **a single exclusive writer**. It is a concurrency primitive designed to improve performance in read-heavy workloads while preserving Rust's guarantees of data race freedom. `RwLock<T>` is commonly paired with `Arc<T>` to enable shared, mutable state across threads.

## **Learning Objectives**

- Understand read–write locking semantics and performance tradeoffs versus mutual exclusion
- Use `RwLock<T>` to coordinate concurrent access to shared data
- Distinguish between read and write locks and their blocking semantics
- Identify appropriate use cases for `RwLock<T>` vs `Mutex<T>` vs lock-free alternatives
- Recognize and mitigate potential pitfalls such as writer starvation, deadlocks, and contention
- Apply advanced patterns including try-locking, poisoning recovery, and timeout handling

---

## **What Is `RwLock<T>`**

- Wraps data with a read–write synchronization mechanism that permits fine-grained concurrency
- Allows **multiple concurrent readers** or **one exclusive writer** at a time, never both simultaneously
- Enforces Rust's borrowing rules through runtime locking rather than compile-time analysis
- Blocks writers while readers are active (reader priority on most implementations) and blocks all access while a writer holds the lock
- Trades complexity and potential contention for better read scalability than `Mutex<T>`

### Importing `RwLock`

```rust
use std::sync::RwLock;
```

`RwLock<T>` is thread-safe and designed for multi-threaded contexts with blocking semantics. Async runtimes (tokio, async-std) provide non-blocking variants.

---

## **Creating an `RwLock<T>`**

An `RwLock<T>` is created using `RwLock::new()`.

```rust
use std::sync::RwLock;

let counter = RwLock::new(0);
let cache: RwLock<std::collections::HashMap<String, String>> = 
  RwLock::new(std::collections::HashMap::new());
```

### At creation

- No locks are held
- Both read and write access are immediately available
- The internal state is initialized but not locked

---

## **Reading Shared Data**

Read access is obtained using `read()`, which returns a `Result<RwLockReadGuard<T>, PoisonError>`. Multiple threads may acquire read locks concurrently.

```rust
use std::sync::RwLock;

let value = RwLock::new(42);

// Basic read
let guard = value.read().unwrap();
println!("Value: {}", *guard);
// guard is dropped here, releasing the read lock

// Concurrent readers
let v1 = RwLock::new(100);
let v2 = v1.clone(); // ❌ Won't work directly; use Arc for sharing

// Handling poisoning explicitly
match value.read() {
  Ok(guard) => println!("Read: {}", *guard),
  Err(poisoned) => {
    let guard = poisoned.into_inner();
    println!("Lock was poisoned, recovered value: {}", *guard);
  }
}
```

### Key behaviors

- **Multiple concurrent readers** may hold read locks simultaneously without blocking each other
- Read locks **block writers** from acquiring exclusive access
- A `RwLockReadGuard<T>` automatically releases the lock when dropped (RAII pattern)
- Read locks are non-exclusive; they do not prevent concurrent readers
- Attempting to acquire a read lock while a writer holds the lock will block the calling thread

This makes `RwLock<T>` well-suited for **read-heavy workloads** where contention is primarily among readers and writers, not between readers.

---

## **Writing Shared Data**

Write access is obtained using `write()`, which requires exclusive access and blocks all readers and writers.

```rust
use std::sync::RwLock;

let value = RwLock::new(42);

// Basic write
{
  let mut guard = value.write().unwrap();
  *guard += 1;
  println!("New value: {}", *guard);
} // guard is dropped here, releasing the write lock

// Non-blocking write attempt
match value.try_write() {
  Ok(mut guard) => {
    *guard *= 2;
    println!("Write succeeded");
  }
  Err(_) => println!("Lock is held by another thread; operation skipped"),
}

// Write with explicit poisoning handling
match value.write() {
  Ok(mut guard) => *guard = 100,
  Err(poisoned) => {
    let mut guard = poisoned.into_inner();
    *guard = 100;
  }
}
```

### Key behaviors

- **Only one writer** is allowed to hold a write lock at any time
- Writers **block both readers and other writers** from accessing the data
- A `RwLockWriteGuard<T>` provides mutable access and releases the lock when dropped
- Write access ensures safe, exclusive mutation across threads
- The thread holding a write lock has exclusive, mutable access to the inner data

---

## **Try-Locking Patterns**

For non-blocking scenarios, use `try_read()` and `try_write()`:

```rust
use std::sync::RwLock;

let value = RwLock::new(42);

// Non-blocking read
if let Ok(guard) = value.try_read() {
  println!("Read without blocking: {}", *guard);
} else {
  println!("Could not acquire read lock (writer present)");
}

// Non-blocking write
if let Ok(mut guard) = value.try_write() {
  *guard += 10;
  println!("Wrote successfully: {}", *guard);
} else {
  println!("Could not acquire write lock (readers or writer present)");
}
```

Try-locking is essential for:

- **Preventing deadlocks** in complex synchronization patterns
- **Non-blocking APIs** that fail fast rather than block
- **Timeout-based logic** with exponential backoff

---

## **Combining `Arc<T>` and `RwLock<T>`**

The standard pattern for shared, concurrently accessed mutable data across thread boundaries:

```rust
use std::sync::{Arc, RwLock};
use std::thread;
use std::time::Duration;

// Shared data structure
#[derive(Debug)]
struct DatabaseCache {
  entries: std::collections::HashMap<String, String>,
}

let shared_cache = Arc::new(RwLock::new(DatabaseCache {
  entries: std::collections::HashMap::new(),
}));

// Multiple reader threads
for id in 0..3 {
  let cache_clone = Arc::clone(&shared_cache);
  thread::spawn(move || {
    thread::sleep(Duration::from_millis(10 * id));
    let cache = cache_clone.read().unwrap();
    println!("Reader {}: {} entries", id, cache.entries.len());
  });
}

// Writer thread
{
  let cache_clone = Arc::clone(&shared_cache);
  thread::spawn(move || {
    thread::sleep(Duration::from_millis(15));
    let mut cache = cache_clone.write().unwrap();
    cache.entries.insert("key1".to_string(), "value1".to_string());
    println!("Writer: inserted entry");
  });
}

thread::sleep(Duration::from_millis(200));
```

### This pattern supports

- **Multiple concurrent readers** without blocking each other
- **Controlled, exclusive mutation** by writers
- **Clear ownership semantics** via `Arc` reference counting
- **Safe cross-thread sharing** enforced by Rust's type system

---

## **Poisoning and Failure Modes**

A `RwLock` becomes **poisoned** when a thread panics while holding a lock:

```rust
use std::sync::RwLock;
use std::panic;

let value = RwLock::new(42);

// Simulate a panic during write
let result = panic::catch_unwind(panic::AssertUnwindSafe(|| {
  let mut guard = value.write().unwrap();
  *guard = 100;
  panic!("Simulated panic during write");
}));

println!("Panic caught: {}", result.is_err());

// Subsequent operations will fail with PoisonError
match value.read() {
  Ok(guard) => println!("Read: {}", *guard),
  Err(e) => {
    println!("Lock is poisoned!");
    // Recover the value from the poisoned lock
    let guard = e.into_inner();
    println!("Recovered value: {}", *guard);
  }
}
```

### Poisoning behavior

- **Signals inconsistent state** that may have resulted from panic during critical section
- **Forces explicit handling** to acknowledge potential data inconsistency
- **Can be recovered** via `into_inner()` on `PoisonError`
- **Is a design choice** to promote safe failure semantics (mirrors `Mutex<T>`)

---

## **Performance Characteristics and Tradeoffs**

### Read-Heavy Workloads

`RwLock<T>` excels when reads vastly outnumber writes:

```rust
use std::sync::{Arc, RwLock};
use std::thread;

let counter = Arc::new(RwLock::new(0));

// 10 readers for every 1 writer
for _ in 0..10 {
  let c = Arc::clone(&counter);
  thread::spawn(move || {
    for _ in 0..1000 {
      let _val = *c.read().unwrap();
    }
  });
}

for _ in 0..1 {
  let c = Arc::clone(&counter);
  thread::spawn(move || {
    for _ in 0..100 {
      *c.write().unwrap() += 1;
    }
  });
}
```

> **Advantages:** Readers never block each other, improving scalability.

### Write-Heavy Workloads

`RwLock<T>` degrades under write contention:

```rust
// Anti-pattern: RwLock under heavy write contention
let counter = Arc::new(RwLock::new(0));
for _ in 0..10 {
  let c = Arc::clone(&counter);
  thread::spawn(move || {
    for _ in 0..1000 {
      *c.write().unwrap() += 1; // Heavy contention; use Mutex instead
    }
  });
}
```

> **Disadvantage:** Writers block readers and other writers; overhead of read-write lock management adds latency.

### Reader/Writer Starvation

Different OS schedulers may cause starvation:

```rust
use std::sync::{Arc, RwLock};
use std::thread;

let value = Arc::new(RwLock::new(0));

// Continuous writer may starve readers or vice versa
// depending on scheduler and system load
for _ in 0..4 {
  let v = Arc::clone(&value);
  thread::spawn(move || {
    loop {
      let mut guard = v.write().unwrap();
      *guard += 1;
      // Writer holds lock; readers blocked
    }
  });
}
```

> **Mitigation:** Use `try_write()` with backoff, or redesign with lock-free structures for extreme contention.

---

## **Advanced Insight**

- **`RwLock<T>` can outperform `Mutex<T>`** in read-heavy scenarios (3x+ on read-dominated workloads)
- **Write-heavy workloads suffer significantly** due to the overhead of managing multiple readers and lock state
- **Reader/writer starvation** is possible depending on OS scheduler and contention patterns; fairness is not guaranteed
- **Async runtimes** provide non-blocking `RwLock` variants (e.g., `tokio::sync::RwLock`) with `await` semantics
- **Fair variants** (e.g., `parking_lot::fair_rwlock`) prevent writer starvation at the cost of additional complexity
- **Lock-free alternatives** (e.g., `crossbeam::epoch` or concurrent hash maps) eliminate blocking entirely for specific patterns
- **Profiling is essential** to justify `RwLock` over `Mutex`; assumptions about read/write ratios must be validated
- **Nested locking** with `RwLock` requires careful deadlock avoidance; acquire locks in consistent order across all code paths

Choosing between `Mutex<T>`, `RwLock<T>`, and lock-free structures is a design decision based on access patterns, contention profiles, and latency requirements.

---

## **Professional Applications and Implementation**

`RwLock<T>` is commonly used in production systems:

- **Caches and configuration stores:** Frequent reads with occasional updates (e.g., feature flags, API credentials)
- **Shared read-mostly state:** Loaded once, read millions of times (e.g., in-memory indices, routing tables)
- **Concurrent services with infrequent writes:** Long-lived reader-heavy scenarios (e.g., DNS caches, session stores)
- **In-memory data structures accessed across threads:** Thread-safe collections with explicit locking semantics
- **Rate limiters and quota managers:** Multiple threads read current quotas frequently, updating infrequently

Its use signals intentional optimization for concurrent read access and acceptance of write contention tradeoffs.

---

## **Key Takeaways**

| Concept                | Summary                                                                           |
| ---------------------- | --------------------------------------------------------------------------------- |
| `RwLock<T>`            | Allows multiple concurrent readers or one exclusive writer.                       |
| Performance            | Optimized for read-heavy workloads; degrades under write contention.              |
| Safety                 | Enforces exclusive write access and prevents data races.                          |
| Pairing                | Commonly paired with `Arc<T>` for shared ownership across threads.                |
| Try-locking            | Use `try_read()` / `try_write()` to avoid blocking in complex scenarios.          |
| Poisoning              | Locks become poisoned on panic; recovery is possible via `into_inner()`.          |
| Async support          | Standard library `RwLock` blocks; use runtime-specific variants for async code.   |

- `RwLock<T>` enables scalable concurrent access patterns for read-dominated workloads
- Improves performance significantly when reads vastly outnumber writes
- Enforces strict, runtime-checked borrowing rules at the cost of blocking overhead
- Complements `Mutex<T>` in advanced concurrency design; profile before adopting
- Requires careful consideration of starvation, deadlock, and fair scheduling

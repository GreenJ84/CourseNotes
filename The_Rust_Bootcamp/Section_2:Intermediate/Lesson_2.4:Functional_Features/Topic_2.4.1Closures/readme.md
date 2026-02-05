# **Topic 2.4.1: ClosuresTopic 2.4.1: Closures**

Closures in Rust are anonymous functions that can capture values from their surrounding environment while preserving Rust's guarantees around ownership, borrowing, and lifetimes. They serve as a foundational building block for functional-style programming, enabling higher-order functions, iterator pipelines, callbacks, and flexible API design. Unlike traditional functions, closures carry explicit information about how they interact with captured variables, allowing the compiler to enforce safety without runtime overhead.

## **Learning Objectives**

- Understand closures as first-class, non-method functions
- Distinguish between `Fn`, `FnMut`, and `FnOnce` based on capture semantics
- Use closures as values that can be stored, passed, and returned
- Apply function pointers and closure coercion appropriately
- Design APIs that accept or return closures safely and efficiently
- Master advanced capture mechanisms and performance implications
- Leverage closures for zero-cost abstractions and idiomatic Rust patterns

---

## **Closures as First-Class Functions**

Closures are **non-method functions** defined inline without a name, representing one of Rust's most powerful features for abstraction. They are first-class values, meaning they can be assigned to variables, passed as arguments, returned from functions, and stored in data structures.

### Basic Syntax and Type Inference

```rust
// Type annotation is optional—the compiler infers types on first use
let is_even = |x: i32| x % 2 == 0;
assert!(is_even(4));
assert!(!is_even(3));

// With explicit type annotations
let add = |x: i32, y: i32| -> i32 { x + y };
assert_eq!(add(2, 3), 5);

// Type inference from usage context
let numbers = vec![1, 2, 3, 4, 5];
let filtered: Vec<_> = numbers.iter().filter(|&&n| n > 2).copied().collect();
// Compiler infers the closure parameter type from the iterator
```

### Key Distinctions from Regular Functions

| Feature | Regular Function | Closure |
| ------- | ---------------- | ------- |
| **Naming** | Must be named | Anonymous (inline) |
| **Scope** | Module-level | Lexically scoped |
| **Capture** | Cannot capture environment | Can capture variables |
| **Type** | `fn` (function pointer) | Unique, compiler-generated type |
| **Monomorphization** | One binary representation | Specialized per closure instance |

Closures automatically capture variables from their enclosing scope. The compiler determines capture mode based on how variables are used within the closure body:

```rust
let x = vec![1, 2, 3];
let y = String::from("hello");

// This closure captures x by immutable borrow and y by value
let process = || {
  println!("x len: {}", x.len());
  println!("y: {}", y);
};

process(); // Can call multiple times
// x is still accessible here (only borrowed)
// y is moved into the closure, not accessible here
```

---

## **Different Closure Traits and Capture Semantics**

The Rust compiler automatically assigns each closure to one of three trait categories based on how it interacts with captured variables. Understanding this hierarchy is critical for API design.

### `Fn` Trait: Immutable Borrow

`Fn` closures capture variables by **immutable borrow**, allowing multiple invocations without mutating captured state. This trait is most restrictive to implement but most flexible to use in APIs.

```rust
let multiplier = 5;

// This closure implements Fn because it only reads the captured variable
let multiply = |x: i32| x * multiplier;

assert_eq!(multiply(3), 15);
assert_eq!(multiply(4), 20);

// Can pass to functions expecting Fn
fn apply_twice<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 {
  f(f(x))
}

assert_eq!(apply_twice(multiply, 2), 50); // (2 * 5) * 5
```

**Advanced Example: Implementing Custom Behavior with `Fn`**

```rust
struct Calculator {
  cache: std::collections::HashMap<i32, i32>,
}

impl Calculator {
  fn new() -> Self {
    Calculator {
      cache: std::collections::HashMap::new(),
    }
  }

  // This function accepts any Fn closure
  fn compute_series<F: Fn(i32) -> i32>(&self, f: F, values: &[i32]) -> Vec<i32> {
    values.iter().map(|&v| f(v)).collect()
  }
}

let calc = Calculator::new();
let square = |x: i32| x * x;
let results = calc.compute_series(square, &[1, 2, 3, 4]);
assert_eq!(results, vec![1, 4, 9, 16]);
```

### `FnMut` Trait: Mutable Borrow

`FnMut` closures capture variables by **mutable borrow**, allowing mutation of captured state. They can be called multiple times, but the borrow must be exclusive between calls.

```rust
let mut count = 0;

// This closure implements FnMut because it mutates the captured variable
let mut increment = || {
  count += 1; // count captured, and mutated
  count
};

assert_eq!(increment(), 1);
assert_eq!(increment(), 2);
assert_eq!(increment(), 3);

// For functions accepting FnMut, we need mutable closure bindings
fn apply_multiple<F: FnMut(i32)>(mut f: F, times: usize, value: i32) {
  for _ in 0..times {
    f(value);
  }
}

let mut total = 0;
apply_multiple(|x| { total += x; }, 3, 5);
assert_eq!(total, 15);
```

**Advanced Example: Stateful Computation with `FnMut`**

```rust
struct Aggregator {
  sum: i32,
  count: i32,
}

impl Aggregator {
  fn new() -> Self {
    Aggregator { sum: 0, count: 0 }
  }

  // Takes FnMut to allow the closure to modify internal state
  fn process<F: FnMut(&mut Aggregator, i32)>(&mut self, mut callback: F, values: &[i32]) {
    for &value in values {
      callback(self, value);
    }
  }
}

let mut agg = Aggregator::new();
agg.process(|agg, value| {
  agg.sum += value;
  agg.count += 1;
}, &[10, 20, 30]);

assert_eq!(agg.sum, 60);
assert_eq!(agg.count, 3);
```

### `FnOnce` Trait: Ownership Transfer

`FnOnce` closures take **ownership** of captured variables and can only be called once. After invocation, owned values are moved out and no longer available. This is essential when the closure needs to consume values.

```rust
let data = String::from("important");

// This closure implements FnOnce because it moves data out (via drop)
let consume = move || {
  drop(data); // Takes ownership and consumes
};

consume();
// data is no longer accessible

// Attempting to call again would fail:
// consume(); // Error: value used after move
```

**Advanced Example: Resource Cleanup with `FnOnce`**

```rust
struct Guard<F: FnOnce()> {
  cleanup: Option<F>,
}

impl<F: FnOnce()> Guard<F> {
  fn new(cleanup: F) -> Self {
    Guard {
      cleanup: Some(cleanup),
    }
  }
}

impl<F: FnOnce()> Drop for Guard<F> {
  fn drop(&mut self) {
    if let Some(cleanup) = self.cleanup.take() {
      cleanup();
    }
  }
}

let file = std::fs::File::create("/tmp/test.txt").unwrap();
let guard = Guard::new(move || {
  let _ = std::fs::remove_file("/tmp/test.txt");
});
// When guard is dropped, the file is cleaned up
```

### Trait Hierarchy and Coercion

The trait hierarchy reflects substitutability: `Fn` is a subtype of `FnMut`, which is a subtype of `FnOnce`.

```text
Fn ⊂ FnMut ⊂ FnOnce
```

This means:

- Any `Fn` can be used where `FnMut` is expected
- Any `FnMut` can be used where `FnOnce` is expected
- But not vice versa

```rust
// Demonstrates coercion up the hierarchy
fn expect_once<F: FnOnce(i32) -> i32>(f: F) -> i32 {
  f(5)
}

fn expect_mut<F: FnMut(i32) -> i32>(mut f: F) -> i32 {
  f(5)
}

fn expect_fn<F: Fn(i32) -> i32>(f: F) -> i32 {
  f(5)
}

let x = 10;
let add_x = |y| x + y; // Implements Fn

// All these work due to coercion
assert_eq!(expect_fn(add_x), 15);
assert_eq!(expect_mut(add_x), 15);
assert_eq!(expect_once(add_x), 15);
```

---

## **Moving Environment Variables**

The `move` keyword **forces** the closure to take **ownership** of all captured variables, guaranteeing `FnOnce` semantics for moved values. This is critical for escaping scope boundaries and managing lifetimes explicitly.

### When and Why to Use `move`

```rust
// Without move: closure borrows x
let x = vec![1, 2, 3];
let borrow_closure = || println!("{:?}", x);
println!("x still available: {:?}", x); // OK

// With move: closure owns x
let y = vec![4, 5, 6];
let own_closure = move || println!("{:?}", y);
// println!("y: {:?}", y); // Error: value moved
```

### Spawning Threads with `move` Closures

The primary use case for `move` is thread spawning, where the closure must own values that outlive the spawning scope:

```rust
use std::thread;

fn process_data(data: Vec<i32>) {
  // move is required here, without it, data would be borrowed
  let thread1 = thread::spawn(move || {
    let sum: i32 = data.iter().sum();
    println!("Sum: {}", sum);
  });

  // but the thread might outlive the borrow scope
  thread1.join().unwrap();
}

process_data(vec![1, 2, 3, 4, 5]);
```

### Returning Closures with Owned Data

`move` is necessary when returning closures that need to own captured data:

```rust
fn create_multiplier(factor: i32) -> impl Fn(i32) -> i32 {
  // move is implicit here, the closure must own factor
  move |x| x * factor
}

let times_3 = create_multiplier(3);
assert_eq!(times_3(5), 15);
```

### Advanced Example: Building Closures Dynamically

```rust
fn build_transformer(operations: Vec<Box<dyn Fn(i32) -> i32>>)
  -> impl Fn(i32) -> i32 {
  move |mut x| {
    for op in &operations {
      x = op(x);
    }
    x
  }
}

let ops: Vec<Box<dyn Fn(i32) -> i32>> = vec![
  Box::new(|x| x + 10),
  Box::new(|x| x * 2),
  Box::new(|x| x - 3),
];

let transform = build_transformer(ops);
assert_eq!(transform(5), ((5 + 10) * 2) - 3); // 27
```

---

## **Function Pointers**

Function pointers use the concrete type `fn(...) -> ...` and represent a fixed entry point in the binary. Only **non-capturing closures** can coerce to function pointers, making them useful for scenarios requiring a stable ABI.

### Key Differences from Closures

| Aspect | Function Pointer | Closure |
| ------ | ---------------- | ------- |
| **Type** | Concrete `fn(i32) -> i32` | Unique per closure |
| **Capture** | Cannot capture | Can capture |
| **Size** | Fixed (pointer-sized) | Variable (depends on captures) |
| **Monomorphization** | Single binary code | Specialized per closure |
| **FFI Compatibility** | Yes | No (without wrapper) |

```rust
// Regular function can coerce to function pointer
fn add(x: i32, y: i32) -> i32 {
  x + y
}

// Non-capturing closure can coerce to function pointer
let multiply = |x: i32, y: i32| x * y;

// Both can be assigned to function pointers
let fp1: fn(i32, i32) -> i32 = add;
let fp2: fn(i32, i32) -> i32 = multiply;

assert_eq!(fp1(3, 4), 7);
assert_eq!(fp2(3, 4), 12);
```

### When to Use Function Pointers

Function pointers are useful for:

1. **C FFI boundaries** where stable ABI is required
2. **Avoiding generic monomorphization** in performance-critical contexts
3. **Simplifying type signatures** when capturing is not needed

```rust
// Useful in FFI contexts
extern "C" fn c_compatible_function(x: i32) -> i32 {
  x * 2
}

// Can pass through C libraries that expect fn pointers
fn call_from_c_library<F: Fn(i32) -> i32>(callback: F) -> i32 {
  callback(42)
}

// Non-capturing closure coerces to fn pointer
let result = call_from_c_library(|x| x + 1);
assert_eq!(result, 43);
```

### The Cost of Capturing: Why Coercion Fails

Capturing closures cannot coerce to `fn` pointers because they need to carry captured data:

```rust
let multiplier = 5;

// This cannot coerce to fn because it captures multiplier
let closure = |x: i32| x * multiplier;

// let fp: fn(i32) -> i32 = closure; // Error!
// error: mismatched types
//   expected fn pointer
//   found closure

// However, we can store it using the actual trait:
let f: &dyn Fn(i32) -> i32 = &closure;
assert_eq!(f(3), 15);
```

---

## **Defining Closures**

### Syntax Variations

```rust
// Minimal syntax: pipes with no type annotations
let simple = || 42;

// With parameter type annotations
let with_types = |x: i32, y: i32| x + y;

// With explicit return type
let explicit_return = |x: i32| -> i32 { x * 2 };

// Multi-line body (requires braces)
let multi_line = |x: i32| {
  let doubled = x * 2;
  let tripled = doubled + x;
  tripled
};

// Capturing from environment
let name = String::from("Rust");
let greet = |greeting: &str| format!("{}, {}!", greeting, name);
assert_eq!(greet("Hello"), "Hello, Rust!");
```

### Type Inference Behavior

The Rust compiler infers closure types on first use and locks them in:

```rust
let mut closure = |x| x + 1;
assert_eq!(closure(5), 6);

// Type is now inferred as i32
// closure(5.5); // Error: expected i32, found f64
```

### Return Type Inference

The return type is inferred from the closure body:

```rust
// Returns i32 (inferred from arithmetic)
let compute = |x: i32| x * 2 + 1;

// Returns String (inferred from String::from)
let format_data = |s: &str| String::from(s).to_uppercase();

// Returns bool (inferred from comparison)
let is_valid = |x: i32| x > 0 && x < 100;
```

---

## **Accepting Closures as Parameters**

Closures are accepted via **generic trait bounds**, enabling static dispatch and zero runtime cost. This is the idiomatic Rust pattern.

### Single Closure Parameter

```rust
fn execute_callback<F: Fn(i32) -> String>(f: F, value: i32) -> String {
  f(value)
}

let stringify = |x: i32| format!("Number: {}", x);
assert_eq!(execute_callback(stringify, 42), "Number: 42");
```

### Multiple Distinct Closures

When accepting multiple closures, each requires its own generic parameter:

```rust
fn pipeline<F, G, H>(input: i32, f: F, g: G, h: H) -> String
where
  F: Fn(i32) -> i32,
  G: Fn(i32) -> i32,
  H: Fn(i32) -> String,
{
  let step1 = f(input);
  let step2 = g(step1);
  h(step2)
}

let add_five = |x| x + 5;
let double = |x| x * 2;
let stringify = |x| format!("Result: {}", x);

let result = pipeline(10, add_five, double, stringify);
assert_eq!(result, "Result: 30");
```

### Flexible Trait Bounds

Different trait bounds serve different use cases:

```rust
// Accept Fn closures only (most restrictive, most reusable)
fn apply_fn<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 {
  f(x)
}

// Accept FnMut closures (allows mutation of captures)
fn apply_fn_mut<F: FnMut(i32) -> i32>(mut f: F, x: i32) -> i32 {
  f(x)
}

// Accept FnOnce closures (most flexible, but can only call once)
fn apply_once<F: FnOnce(i32) -> i32>(f: F, x: i32) -> i32 {
  f(x)
}

let x = 10;
let immutable_closure = |y| x + y; // Fn
let result = apply_fn(immutable_closure, 5); // OK
```

---

## **Returning Closures**

### Returning a Single Closure Type with `impl Trait`

When returning a single closure shape, use `impl Trait` for ergonomics:

```rust
fn create_adder(addend: i32) -> impl Fn(i32) -> i32 {
  move |x| x + addend
}

let add_ten = create_adder(10);
assert_eq!(add_ten(5), 15);
```

**Why `impl Trait` Works Here:**

- The compiler knows the concrete closure type at compile time
- Monomorphization occurs at call sites
- Zero runtime overhead

### Returning Multiple Possible Closures

When different code paths return different closure types, use **trait objects** with `dyn`:

```rust
fn create_operation(op_type: &str) -> Box<dyn Fn(i32, i32) -> i32> {
  match op_type {
    "add" => Box::new(|a, b| a + b),
    "multiply" => Box::new(|a, b| a * b),
    "subtract" => Box::new(|a, b| a - b),
    _ => Box::new(|a, _| a),
  }
}

let add = create_operation("add");
let multiply = create_operation("multiply");

assert_eq!(add(5, 3), 8);
assert_eq!(multiply(5, 3), 15);
```

### Closures with Mutable Captures in Return Types

Returning `FnMut` closures requires special handling:

```rust
fn create_counter() -> Box<dyn FnMut() -> i32> {
  let mut count = 0;
  Box::new(move || {
    count += 1;
    count
  })
}

let mut counter = create_counter();
assert_eq!(counter(), 1);
assert_eq!(counter(), 2);
assert_eq!(counter(), 3);
```

---

## **Closures in Structs**

Closures stored in struct fields must use generics or trait objects. Generic storage is preferred when possible for performance.

### Generic Closure Storage (Static Dispatch)

```rust
struct EventHandler<F: Fn(&str) -> bool> {
  callback: F,
}

impl<F: Fn(&str) -> bool> EventHandler<F> {
  fn new(callback: F) -> Self {
    EventHandler { callback }
  }

  fn handle(&self, event: &str) -> bool {
    (self.callback)(event)
  }
}

let handler = EventHandler::new(|event| event.contains("error"));
assert!(handler.handle("database error"));
assert!(!handler.handle("info message"));
```

### Trait Object Storage (Dynamic Dispatch)

Use trait objects when the closure type varies:

```rust
struct EventBus {
  handlers: Vec<Box<dyn Fn(&str)>>,
}

impl EventBus {
  fn new() -> Self {
    EventBus {
      handlers: Vec::new(),
    }
  }

  fn subscribe<F: Fn(&str) + 'static>(&mut self, handler: F) {
    self.handlers.push(Box::new(handler));
  }

  fn emit(&self, event: &str) {
    for handler in &self.handlers {
      handler(event);
    }
  }
}

let mut bus = EventBus::new();
bus.subscribe(|event| println!("Handler 1: {}", event));
bus.subscribe(|event| println!("Handler 2: {}", event));
bus.emit("test event");
```

### Advanced: Builder Pattern with Closures

```rust
struct ConfigBuilder<F: Fn() -> i32 = fn() -> i32> {
  validator: F,
}

impl ConfigBuilder<fn() -> i32> {
  fn new() -> Self {
    ConfigBuilder {
      validator: || 0,
    }
  }
}

impl<F: Fn() -> i32> ConfigBuilder<F> {
  fn with_validator<G: Fn() -> i32>(self, validator: G) -> ConfigBuilder<G> {
    ConfigBuilder { validator }
  }

  fn build(&self) -> i32 {
    (self.validator)()
  }
}

let config = ConfigBuilder::new()
  .with_validator(|| 42)
  .build();
assert_eq!(config, 42);
```

---

## **Performance Considerations**

### Zero-Cost Abstractions

```rust
// Generic closures are monomorphized—no runtime cost
fn with_generic<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 {
  f(x)
}

// Trait objects incur one extra pointer indirection per call
fn with_dyn(f: &dyn Fn(i32) -> i32, x: i32) -> i32 {
  f(x)
}

// Function pointers: one indirection (stable size)
fn with_fn(f: fn(i32) -> i32, x: i32) -> i32 {
  f(x)
}
```

### Minimizing Capture Overhead

```rust
// Bad: Captures entire vector
let large_vec = vec![1; 10000];
let closure1 = || large_vec.len(); // Captures entire vector

// Better: Capture only what's needed
let len = large_vec.len();
let closure2 = || len; // Captures single usize

// Best: Don't capture at all
let compute = || 42; // No captures
```

---

## **Professional Applications and Implementation**

Closures are heavily used across idiomatic Rust:

- Iterator adapters (map, filter, fold)
- Callback-based APIs
- Custom control flow abstractions
- Threading and async execution (move closures)
- Dependency injection and configuration patterns

Correct selection of Fn, FnMut, or FnOnce improves API clarity, correctness, and performance.

---

## **Key Takeaways**

| Concept           | Summary                                                        |
| ----------------- | -------------------------------------------------------------- |
| Closures          | Anonymous functions that can capture their environment safely. |
| Closure Traits    | `Fn`, `FnMut`, and `FnOnce` define how values are captured.    |
| Move Semantics    | `move` forces ownership transfer into closures.                |
| Function Pointers | Concrete types usable with non-capturing closures.             |
| API Design        | Generics enable zero-cost closure-based abstractions.          |
| Return Types      | Use `impl Trait` for single types, `Box<dyn>` for multiple.    |
| Performance       | Generic closures monomorphize; trait objects add indirection.  |

- **Prefer `Fn` bounds** in APIs—they're most restrictive and most reusable
- **Use `impl Trait`** for returning closures when the type is concrete
- **Employ `move`** explicitly when closures must own captured data
- **Leverage trait objects** only when multiple closure types need coexistence
- **Minimize captures** to reduce closure size and improve performance
- **Chain operations** idiomatically using iterator adapters
- **Master closures** to unlock Rust's functional programming capabilities

Closures are central to idiomatic Rust programming and are essential for writing clean, expressive, zero-cost abstractions.

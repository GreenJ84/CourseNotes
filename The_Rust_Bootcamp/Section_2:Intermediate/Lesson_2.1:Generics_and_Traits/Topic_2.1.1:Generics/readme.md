# **Topic 2.1.1: Generics**

Generics are a foundational feature in Rust that enable writing flexible, reusable, and type-safe code without sacrificing performance. By parameterizing types and functions over one or more placeholder types, Rust allows developers to express general behavior once while preserving strong compile-time guarantees. Generics are central to Rust's zero-cost abstraction philosophy, making them a core tool for both library authors and application developers.

## **Learning Objectives**

- Explain why generics are used and what problems they solve
- Understand how Rust implements generics without runtime overhead through monomorphization
- Define generic structs, enums, and functions with proper trait bounds
- Apply conventions and best practices for naming generic parameters
- Distinguish between generic definitions and their concrete instantiations
- Recognize performance implications, binary size tradeoffs, and compile-time costs
- Apply generics effectively in real-world architectural patterns and library design
- Master advanced patterns including HRTB, associated types, and phantom data
- Balance flexibility with practical compilation and runtime considerations

---

## **Why Use Generics**

Generics solve several critical problems in software design:

- Enable the same code to work with multiple concrete types without duplication
- Reduce boilerplate and maintenance burden by centralizing logic
- Improve type safety by preserving compile-time guarantees across abstractions
- Preserve performance through compile-time specialization (zero-cost abstraction)
- Enable impossible states to become un-representable through the type system

Rust generics do not introduce runtime polymorphism by default. Instead, they rely on **static dispatch**, meaning all type decisions are resolved at compile time. This contrasts with trait objects (`dyn Trait`), which use dynamic dispatch at runtime with both memory and CPU overhead. For performance-critical code, generics are the preferred approach. However, dynamic dispatch enables flexibility when the number of type instantiations would cause excessive binary bloat.

### Generics vs. Trait Objects: Deep Dive

The choice between generics and trait objects represents a fundamental architectural decision:

```rust
// STATIC DISPATCH - monomorphic at compile time
// Each call site generates a specialized function
fn process_generic<T: std::fmt::Debug>(item: T) {
  println!("{:?}", item);
}

// DYNAMIC DISPATCH - Runtime cost via vtable
// Single function with runtime type information
fn process_dynamic(item: &dyn std::fmt::Debug) {
  println!("{:?}", item);
}

// DEMONSTRATION: Performance and behavior differences
fn main() {
  // Generic version - compiler generates:
  // process_generic::<i32>, process_generic::<String>, process_generic::<Vec<i32>>
  process_generic(42i32);
  process_generic(String::from("hello"));
  process_generic(vec![1, 2, 3]);
  
  // Trait object version - single function + vtable lookups
  let items: Vec<&dyn std::fmt::Debug> = vec![
    &42i32,
    &String::from("hello"),
    &vec![1, 2, 3],
  ];
  
  for item in items {
    process_dynamic(item); // Vtable lookup for each iteration
  }
}

// WHEN TO USE EACH:
// - Generics: Fixed set of types, performance critical, known at compile time
// - Trait objects: Unknown/variable number of types, collections of mixed types,
//   willingness to pay small performance cost for flexibility
```

**Performance comparison** (conceptual):

- Generic: Inline opportunities, branch prediction, zero indirection
- Trait objects: One extra pointer dereference per method call, indirect branch prediction

### Naming Conventions and Semantic Intent

Generic parameter naming is not cosmetic—it communicates design intent:

```rust
// POOR: Single letters without context
struct Cache<T, U, V> {
  data: T,
  meta: U,
  temp: V,
}

// GOOD: Descriptive names that document semantics

```rust
// Anti-pattern: Generic implementation with many instantiations
impl<T: Clone> Vec<T> {
  pub fn extend_from_slice(&mut self, slice: &[T]) {
    // Duplicated for every concrete T
  }
}

// Better pattern: Extract common logic to non-generic code
impl<T> Vec<T> {
  pub fn extend_from_slice(&mut self, slice: &[T]) 
  where 
    T: Clone,
  {
    // Trait bounds limit monomorphization scope
    for item in slice {
      self.push(item.clone());
    }
  }
}

// Best pattern: Use trait objects for hot paths with many types
fn process_debug(item: &dyn std::fmt::Debug) {
  println!("{:?}", item);
}
// Single copy of code, dispatch resolved at runtime
```

---

## **Generic Types**

Generics can be applied to user-defined types to make them flexible across different data representations.

### Key Capabilities

- Multiple generic parameters can be declared and are independent  
- Each parameter can represent a different type  
- Generics are supported on:
  - Structs  
  - Enums  
  - Methods and implementations
  - Associated types

### Defining Generic Structs

Generic parameters are declared immediately after the type name.

```rust
// Single generic parameter
struct Container<T> {
  inner: T,
}

// Single generic, multiple fields with same type
struct Pair<T> {
  first: T,
  second: T,
}

// Multiple independent generic parameters
struct Tuple<T, U> {
  left: T,
  right: U,
}

// Multiple parameters with same semantics
struct Pair<T, T> { // ERROR: Duplicate type parameter name
  first: T,
  second: T,
}

// Correct way
struct Pair<T> {
  first: T,
  second: T,
}

// For different types
struct Pair<T, U> {
  first: T,
  second: U,
}

// Generics in enums - each variant can use generics independently
enum Result<T, E> {
  Ok(T),
  Err(E),
}

enum LinkedList<T> {
  Empty,
  Node { value: T, next: Box<LinkedList<T>> },
}
```

Each instantiation with concrete types (e.g., `Container<i32>`) results in a distinct compiled type with its own vtable (if applicable).

### Generic Type Constraints and Variance

```rust
// This struct is generic over T - what constraints exist?
struct Wrapper<T> {
  item: T,
}

// Can be instantiated with ANY type
let w1: Wrapper<i32> = Wrapper { item: 42 };
let w2: Wrapper<String> = Wrapper { item: "hello".to_string() };
let w3: Wrapper<Vec<()>> = Wrapper { item: vec![] };

// Unconstrained generics offer maximum flexibility
// but prevent method implementation without trait bounds
```

---

## **Generic Implementation Blocks**

Generic types require generic `impl` blocks to define methods. This is where trait bounds become essential.

```rust
struct Stack<T> {
  items: Vec<T>,
}

// Methods for ALL types T
impl<T> Stack<T> {
  fn new() -> Self {
    Self { items: Vec::new() }
  }
  
  fn push(&mut self, item: T) {
    self.items.push(item);
  }
  
  fn pop(&mut self) -> Option<T> {
    self.items.pop()
  }
  
  fn is_empty(&self) -> bool {
    self.items.is_empty()
  }
}

// Methods only for types that implement Clone
impl<T: Clone> Stack<T> {
  fn peek(&self) -> Option<T> {
    self.items.last().cloned()
  }
}

// Methods only for types that implement Display
impl<T: std::fmt::Display> Stack<T> {
  fn print_all(&self) {
    for item in &self.items {
      println!("{}", item);
    }
  }
}

// Specialized implementation for specific types
impl Stack<i32> {
  fn sum(&self) -> i32 {
    self.items.iter().sum()
  }
}

// Usage
fn main() {
  let mut s: Stack<String> = Stack::new();
  s.push("hello".to_string());
  s.push("world".to_string());
  
  if let Some(top) = s.peek() {
    println!("Top: {}", top);
  }
  
  let mut nums: Stack<i32> = Stack::new();
  nums.push(1);
  nums.push(2);
  nums.push(3);
  println!("Sum: {}", nums.sum()); // Only available for i32
}
```

**Key implementation patterns:**

- Generic parameters must be redeclared on `impl` blocks  
- Methods can operate on the generic type directly
- Trait bounds restrict what operations are available for certain generic parameters
- Multiple `impl` blocks can define different method sets based on constraints
- Concrete type specialization allows optimized implementations for specific types

---

## **Generic Functions**

Functions can be parameterized over types independently of struct or enum definitions.

```rust
// Simple generic function
fn identity<T>(item: T) -> T {
  item
}

// Generic with trait bounds
fn print_it<T: std::fmt::Display>(item: T) {
  println!("{}", item);
}

// Multiple generic parameters
fn combine<T, U>(first: T, second: U) -> (T, U) {
  (first, second)
}

// Generic with constraints on multiple parameters
fn compare_and_swap<T: PartialOrd>(a: T, b: T) -> (T, T) {
  if a > b {
    (b, a)
  } else {
    (a, b)
  }
}

// Complex example: Find max in collection
fn find_max<T: PartialOrd + Copy>(items: &[T]) -> Option<T> {
  items.iter().copied().max_by(|a, b| {
    a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal)
  })
}

// Lifetime parameters interact with generics
fn longest<'a, T: std::fmt::Debug>(x: &'a T, y: &'a T) -> &'a T {
  println!("{:?}, {:?}", x, y);
  x
}

fn main() {
  // Type inference from context
  let num = identity(42);           // T = i32
  let text = identity("hello");     // T = &str
  
  // Explicit type annotation (rarely needed)
  let num: i32 = identity(42);
  
  print_it(42);
  print_it("hello");
  print_it(3.14);
  
  let result = combine(42, "hello");
  println!("{:?}", result);
  
  let arr = [3, 1, 4, 1, 5, 9];
  if let Some(max) = find_max(&arr) {
    println!("Max: {}", max);
  }
}
```

**Characteristics of generic functions:**

- Type inference from context: compiler deduces `T` at call site
- Type annotations only required when ambiguous
- Trait bounds enable meaningful operations on generic types
- Lifetime parameters can be combined with type generics
- Generic functions are monomorphic identically to generic types

---

## **Advanced Generic Patterns**

### Higher-Ranked Trait Bounds (HRTB)

```rust
// Accept closures for any lifetime reference
fn do_something<F>(f: F) 
where 
  F: for<'a> Fn(&'a str) -> usize,
{
  println!("{}", f("test"));
}

// This is more flexible than:
fn do_something_limited<'a, F>(f: F) 
where 
  F: Fn(&'a str) -> usize,
{
  // Only works for a specific lifetime
}
```

### Associated Types vs. Generic Parameters

```rust
// Generic parameter - type is chosen at call site
trait Iterator<T> {
  fn next(&mut self) -> Option<T>;
}

// Associated type - type is chosen at implementation time
trait IteratorAssoc {
  type Item;
  fn next(&mut self) -> Option<Self::Item>;
}

// Associated types are preferred in Rust because:
// - A type can only implement a trait once for each associated type
// - Reduces impl ambiguity
// - More ergonomic syntax at call sites
```

### Phantom Data for Zero-Sized Generics

```rust
use std::marker::PhantomData;

struct Container<T, U> {
  data: Vec<T>,
  // U is never actually stored, but we need it for type safety
  _phantom: PhantomData<U>,
}

impl<T, U> Container<T, U> {
  fn new() -> Self {
    Self {
      data: Vec::new(),
      _phantom: PhantomData,
    }
  }
}

// Common use case: Type-state pattern
struct Uninitialized;
struct Initialized;

struct Config<State> {
  values: Vec<i32>,
  _state: PhantomData<State>,
}

impl Config<Uninitialized> {
  fn new() -> Self {
    Self {
      values: Vec::new(),
      _state: PhantomData,
    }
  }
  
  fn init(mut self) -> Config<Initialized> {
    self.values.push(0);
    Config {
      values: self.values,
      _state: PhantomData,
    }
  }
}

impl Config<Initialized> {
  fn use_config(&self) {
    println!("Config is ready: {:?}", self.values);
  }
}

fn main() {
  let cfg = Config::<Uninitialized>::new();
  // cfg.use_config(); // ERROR: Config<Uninitialized> doesn't have this method
  
  let cfg = cfg.init();
  cfg.use_config(); // OK
}
```

---

## **Professional Applications and Implementation**

Generics are pervasive in real-world Rust codebases and architectural patterns:

### Standard Library Usage

```rust
// Vec<T> - homogeneous collections
let numbers: Vec<i32> = vec![1, 2, 3];

// Option<T> - optional values with type safety
let maybe_value: Option<String> = Some("hello".to_string());

// Result<T, E> - error handling with typed values
fn parse_number(s: &str) -> Result<i32, std::num::ParseIntError> {
  s.parse()
}

// HashMap<K, V> - key-value storage
use std::collections::HashMap;
let mut map: HashMap<String, i32> = HashMap::new();
```

### Real-World Architectural Patterns

```rust
// Builder pattern with generics for type safety
struct Builder<T, U> {
  name: Option<String>,
  value: Option<T>,
  callback: Option<U>,
}

impl<T, U> Builder<T, U> {
  fn new() -> Builder<T, U> {
    Builder {
      name: None,
      value: None,
      callback: None,
    }
  }
  
  fn with_name(mut self, name: String) -> Self {
    self.name = Some(name);
    self
  }
  
  fn build(self) -> Result<(String, T), &'static str> {
    match (self.name, self.value) {
      (Some(n), Some(v)) => Ok((n, v)),
      _ => Err("Missing required fields"),
    }
  }
}

// Repository pattern with generics
trait Repository<T: Clone> {
  fn get(&self, id: u32) -> Option<T>;
  fn save(&mut self, item: T) -> Result<(), String>;
}

struct InMemoryRepository<T: Clone> {
  items: std::collections::HashMap<u32, T>,
}

impl<T: Clone> Repository<T> for InMemoryRepository<T> {
  fn get(&self, id: u32) -> Option<T> {
    self.items.get(&id).cloned()
  }
  
  fn save(&mut self, item: T) -> Result<(), String> {
    self.items.insert(0, item);
    Ok(())
  }
}

// Middleware/Pipeline pattern
fn pipeline<T, F1, F2>(value: T, f1: F1, f2: F2) -> String
where
  F1: Fn(T) -> String,
  F2: Fn(String) -> String,
{
  f2(f1(value))
}

fn main() {
  let result = pipeline(42, |n| n.to_string(), |s| format!("Value: {}", s));
  println!("{}", result);
}
```

---

## **Performance Considerations**

```rust
// Good: Generic function allows inlining for each type
fn fast_operation<T: Copy + Default>(items: &[T]) -> T {
  items.iter().fold(T::default(), |acc, _| acc)
}

// Problematic: Many distinct monomorphizations
// If this function is called with 100 different types,
// the compiler generates 100 versions of this code
fn slow_with_many_types<T>(item: T) {
  println!("{:?}", std::mem::size_of::<T>());
}

// Solution: Use trait objects when you have many types
fn better_with_many_types(item: &dyn std::fmt::Debug) {
  println!("{:?}", item);
}
```

Understanding generics is essential before progressing to traits, trait bounds, and async abstractions. Senior developers use generics strategically, balancing flexibility, compile time, and binary size.

---

## **Key Takeaways**

| Aspect           | Summary                                                                |
|------------------|----------------------------------------------------------------------- |
| Purpose          | Reusable, type-safe code across multiple types without runtime cost    |
| Performance      | Monomorphization guarantees zero overhead; binary size is the tradeoff |
| Syntax           | Declared with angle brackets; prefer descriptive names in production   |
| Scope            | Structs, enums, functions, methods, and trait implementations          |
| Type Safety      | Compile-time verification; impossible states become unrepresentable    |
| Constraints      | Trait bounds enable meaningful operations on generic types             |

**Core principles for effective generic design:**

- Generics are compile-time constructs resolved via static dispatch
- Monomorphization eliminates runtime overhead while increasing binary size
- Trait bounds are the mechanism for expressing required capabilities
- Prefer descriptive naming for clarity in complex generic contexts
- Balance flexibility with compile time and binary size concerns
- Use trait objects strategically when many types are instantiated
- Generics form the foundation for traits, trait objects, and advanced abstractions


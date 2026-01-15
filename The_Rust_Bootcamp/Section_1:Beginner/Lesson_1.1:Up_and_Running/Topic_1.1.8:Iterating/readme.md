# **Topic 1.1.8: Iterations**

This topic examines Rust's iteration constructs, focusing on safe looping patterns, ownership-aware iteration, and expression-based loop results. Rust provides multiple looping mechanisms, each designed for specific use cases, with strong compile-time guarantees around correctness and safety. Understanding when and how to use each construct is essential for writing idiomatic, performant Rust code.

## **Learning Objectives**

- Use Rust's looping constructs effectively and idiomatically
- Select the appropriate loop type for each scenario based on performance and safety requirements
- Understand ownership and borrowing semantics during iteration
- Control nested loops using labels and recognize when they indicate design issues
- Return values from loops using `break` and recognize loop expressions as control flow primitives
- Leverage the `Iterator` trait and its adapters for composable, zero-cost abstractions
- Recognize and avoid common iteration pitfalls related to borrowing and mutability

---

## **`loop` — Unbounded Iteration**

Creates an infinite loop that runs until explicitly terminated. Unlike `while` and `for`, `loop` has no built-in termination condition, making its control flow explicit in the code.

```rs
// Basic loop with explicit break
loop {
  println!("Running...");
  break;
}

// Loop with conditional break
let mut attempts = 0;
loop {
  attempts += 1;
  println!("Attempt {}", attempts);
  if attempts >= 3 {
    break;
  }
}

// Loop returning a computed value
let result = loop {
  let value = expensive_computation();
  if is_valid(value) {
    break value; // Break with expression
  }
};
```

**Use cases:**

- Event loops and message processing systems
- Retry mechanisms with exponential backoff
- Polling systems where termination is data-dependent
- State machines with complex transition logic

**Senior insights:**

- `loop` is preferred over `while true` for clarity and to signal infinite iteration intent
- Bare `loop` expressions have type `!` (never) unless broken with a value
- In async contexts, prefer structured concurrency patterns over bare `loop` blocks

---

## **`while` Loop — Condition-Driven Iteration**

Executes while a condition remains true. The condition is evaluated before each iteration, making it suitable for bounded scenarios with explicit termination logic.

```rs
// Basic while loop with mutable counter
let mut count = 3;
while count > 0 {
  println!("Count: {}", count);
  count -= 1;
}

// While with pattern matching (more idiomatic)
let mut items = vec![1, 2, 3, 4, 5];
while let Some(item) = items.pop() {
  println!("Popped: {}", item);
}

// While loop with multiple conditions
let mut retries = 0;
let max_retries = 5;
while retries < max_retries && !success {
  match attempt_operation() {
    Ok(result) => { 
      success = true;
      final_result = result;
    },
    Err(_) => retries += 1,
  }
}

// Demonstrating ownership with while
struct Resource {
  data: String,
}

let mut resources = vec![
  Resource { data: "A".to_string() },
  Resource { data: "B".to_string() },
];

while let Some(resource) = resources.pop() {
  println!("Processing: {}", resource.data);
  // `resource` is moved here; ownership transferred
}
// `resources` is now empty and moved items are dropped
```

**Characteristics:**

- Condition evaluated before each iteration (fails immediately if false)
- Requires mutable bindings for state changes, which can hide bugs
- Less safe for collection iteration due to manual index management
- Pattern matching with `while let` provides ergonomic destructuring

**Senior insights:**

- Avoid `while` loops for collection iteration; `for` loops provide better safety and performance
- `while let` is idiomatic for destructuring patterns that may fail
- The condition is evaluated as a boolean; complex conditions can impact readability
- Consider whether state mutation is truly necessary; sometimes `Iterator` adapters are clearer

---

## **`for` Loop — Safe Iterator-Based Iteration**

Iterates over iterators safely and idiomatically. This is the preferred looping mechanism for most scenarios, leveraging Rust's trait system to provide zero-cost abstractions.

```rs
// Range iteration (exclusive end)
for i in 0..3 {
  println!("Index: {}", i);  // Prints 0, 1, 2
}

// Range iteration (inclusive)
for i in 0..=3 {
  println!("Index: {}", i);  // Prints 0, 1, 2, 3
}

// Borrowing from a vector (shared reference)
let vec = vec![10, 20, 30];
for item in &vec {
  println!("Item: {}", item);
  // `item` is &i32; vec remains accessible after loop
}
println!("Vec still accessible: {:?}", vec);

// Taking ownership of vector items
let vec = vec![10, 20, 30];
for item in vec {
  println!("Owned item: {}", item);
  // `item` is i32; ownership transferred
}
// vec is now moved and cannot be accessed

// Mutable borrowing for modification
let mut vec = vec![1, 2, 3];
for item in &mut vec {
  *item *= 2;  // Dereference and modify
}
println!("Doubled: {:?}", vec);

// Destructuring in for loops
let pairs = vec![(1, 'a'), (2, 'b'), (3, 'c')];
for (num, letter) in pairs {
  println!("{}: {}", num, letter);
}

// Iterator adapter chaining (idiomatic Rust)
let numbers = vec![1, 2, 3, 4, 5];
for result in numbers.iter().filter(|x| x % 2 == 0).map(|x| x * x) {
  println!("Even squared: {}", result);
}

// Enumerating with indices
let items = vec!["a", "b", "c"];
for (index, item) in items.iter().enumerate() {
  println!("Index {}: {}", index, item);
}
```

**Key properties:**

- Preferred and most idiomatic for collections
- Prevents indexing errors and off-by-one bugs
- Honors ownership and borrowing semantics strictly
- Composable with iterator adapters (`map`, `filter`, `fold`, etc.)
- Zero-cost abstraction: compiles to equivalent loop assembly

**Ownership semantics:**

| Pattern | Ownership | Usage |
| --- | --- | --- |
| `for x in collection` | Takes ownership | Use when consuming collection |
| `for x in &collection` | Borrows immutably | Use for read-only access |
| `for x in &mut collection` | Borrows mutably | Use to modify items in-place |

**Senior insights:**

- `for` loops are syntactic sugar over the `IntoIterator` trait
- The compiler automatically calls `.into_iter()`, `.iter()`, or `.iter_mut()` based on context
- Iterator adapters are lazy and only execute when consumed
- For performance-critical code, iterator chains often outperform explicit loops due to LLVM optimization
- Avoid `.collect()` unless you need the intermediate collection; streaming evaluation is more efficient

---

## **Loop Labels — Precise Control Over Nested Loops**

Labels allow targeting `break` and `continue` statements to specific loops in nested contexts, providing a way to escape or skip multiple nesting levels.

```rs
// Breaking out of outer loop from inner loop
'outer: loop {
  for i in 0..3 {
    println!("Outer iteration, inner: {}", i);
    if i == 1 {
      break 'outer;  // Exits the labeled loop
    }
  }
}

// Continuing the outer loop
'outer: for outer in 0..3 {
  for inner in 0..3 {
    if inner == 1 {
      continue 'outer;  // Skips to next outer iteration
    }
    println!("Outer: {}, Inner: {}", outer, inner);
  }
}

// Labels with searching logic
'search: for (index, item) in vec.iter().enumerate() {
  for checker in &validators {
    if !checker.validate(item) {
      println!("Failed at index: {}", index);
      break 'search;
    }
  }
}

// Returning values with labeled breaks
let result = 'search: {
  for row in matrix {
    for (col, &value) in row.iter().enumerate() {
      if value == target {
        break 'search Some((row_idx, col));
      }
    }
  }
  None
};
```

**Rules:**

- Labels begin with `'` followed by an identifier (e.g., `'outer`)
- Labels must precede a `loop`, `while`, or `for` construct
- `break 'label` exits the labeled loop; `continue 'label` skips to the next iteration
- Labels have block scope; they're scoped to their declaration

**Senior insights:**

- Labeled breaks are sometimes a code smell; they often indicate complex logic that should be extracted
- Consider extracting labeled loop logic into functions or using iterator adapters instead
- For complex state machines, labeled loops may indicate a design that would benefit from explicit state management
- Use labels judiciously; excessive nesting suggests refactoring is needed

---

## **Returning Values from Loops — Loops as Expressions**

Loops are expressions in Rust and can yield values via `break`. This enables clean, mutation-free control flows and is a powerful tool for writing declarative code.

```rs
// Simple loop returning a value
let result = loop {
  let value = 10;
  break value * 2;  // Break with expression
};
println!("Result: {}", result);  // Result: 20

// Loop searching for a value
let items = vec![1, 2, 3, 4, 5];
let found = loop {
  for &item in &items {
    if item == 3 {
      break Some(item);
    }
  }
  break None;
};

// More idiomatic search pattern
let found = 'search: {
  for &item in &items {
    if item == 3 {
      break 'search Some(item);
    }
  }
  None
};

// Using labeled blocks for complex conditionals
let status = 'check: {
  if user.is_admin() {
    break 'check "admin";
  }
  if user.is_authenticated() {
    break 'check "user";
  }
  "guest"
};

// Loop with early termination and result
let max_value = loop {
  let candidate = compute_candidate();
  if is_optimal(candidate) {
    break candidate;
  }
  if attempts >= max_attempts {
    break default_value;
  }
};

// For loops returning values (via labeled blocks)
let doubled: Vec<i32> = {
  let mut result = Vec::new();
  for item in 0..5 {
    result.push(item * 2);
  }
  result
};
```

**Constraints and type semantics:**

- The loop must eventually `break` with a value (or the code is unreachable)
- Bare `loop` without `break` has type `!` (never type)
- Type inference determines the return type from the first `break` statement
- All `break` expressions must return compatible types
- The final expression in the loop block becomes the value if no `break` occurs

**Senior insights:**

- Loop expressions eliminate sentinel variables and conditional guards
- Combining labeled blocks with `break` provides a functional style without explicit mutation
- Type inference works across all `break` paths; the compiler ensures type consistency
- This pattern is superior to setting mutable variables in loops for clarity and safety
- Consider whether you're trying to force loop syntax for problems better solved with `Iterator` methods

---

## **Iterator Adapters — Functional Composition**

While not a looping construct per se, iterator adapters are the idiomatic way to chain transformations in Rust. They leverage lazy evaluation and are often more performant than explicit loops.

```rs
// Map, filter, and collect
let numbers = vec![1, 2, 3, 4, 5];
let result: Vec<i32> = numbers
  .iter()
  .filter(|x| x % 2 == 0)
  .map(|x| x * x)
  .collect();

// Fold/reduce for aggregation
let sum = numbers.iter().fold(0, |acc, x| acc + x);

// Find first matching element
let first_even = numbers.iter().find(|x| x % 2 == 0);

// Take and skip for pagination
let page = numbers.iter().skip(10).take(5).collect::<Vec<_>>();

// Zip for parallel iteration
let letters = vec!['a', 'b', 'c'];
for (num, letter) in numbers.iter().zip(letters.iter()) {
  println!("{}: {}", num, letter);
}

// Chain multiple iterables
let combined = numbers.iter().chain(vec![6, 7, 8].iter());

// Partition based on predicate
let (evens, odds): (Vec<_>, Vec<_>) = numbers.iter().partition(|x| x % 2 == 0);
```

---

## **Professional Applications and Implementation**

Rust iteration patterns are heavily used in:

- **Backend services**: HTTP servers use `loop` for event processing; database drivers iterate over result sets with `for`
- **Async runtimes**: Tokio and async-await rely on `loop` for task scheduling and event dispatch
- **Search algorithms**: Binary search, graph traversal, and pathfinding use labeled breaks and loop expressions
- **Systems infrastructure**: OS kernels and embedded systems leverage safe iteration to prevent memory corruption
- **Data processing**: Stream processing pipelines use iterator adapters for composable transformations

Ownership-aware iteration prevents use-after-free and data races at compile time. Loop expressions enable concise, correct control flows without mutable sentinel values, reducing subtle bugs in complex algorithms.

---

## **Key Takeaways**

| Construct | Best For | Characteristics |
| --- | --- | --- |
| `loop` | Unbounded iteration, event loops | Infinite until `break`; explicit termination |
| `while` | Condition-driven iteration | Condition checked before each iteration |
| `for` | Collection and range iteration | Idiomatic; ownership-aware; composable |
| Labels | Nested loop control | Precise `break`/`continue` targeting |
| Loop returns | Declarative control flow | Loops yield values; reduces mutation |
| Adapters | Composable transformations | Lazy evaluation; zero-cost abstraction |

**Best practices:**

- Prefer `for` loops for collections; avoid `while` with manual indexing
- Use `while let` for pattern-based termination
- Leverage iterator adapters (`map`, `filter`, `fold`) for readable, efficient transformations
- Use labeled breaks sparingly; they often indicate overly complex logic
- Avoid loop expressions for complex state machines; extract into functions
- Think in terms of `Iterator` trait operations; it's the most idiomatic Rust approach

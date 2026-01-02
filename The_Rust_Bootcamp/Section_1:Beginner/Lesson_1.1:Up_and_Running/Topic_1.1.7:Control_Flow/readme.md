# **Topic 1.1.7: Control Flow**

This topic explains how Rust controls execution flow using expressions rather than statements. Conditional branching and iteration are designed to be explicit, exhaustive, and type-safe, allowing logic to be expressed clearly while remaining fully verifiable at compile time. Rust's control flow model reinforces predictability, correctness, and composability.

## **Learning Objectives**

- Apply conditional logic using `if`, `else`, and `match`
- Understand exhaustive pattern matching and its compile-time guarantees
- Return values from conditional expressions and loops
- Iterate using Rust's looping constructs with proper ownership semantics
- Label loops and control nested execution with precision
- Return values from loops using `break` for complex search and retry patterns

---

## **Conditions**

### `if / else if / else`

Conditional execution in Rust uses `if` expressions, not statements. This distinction is critical: expressions return values.

```rs
let number = 10;

if number > 0 {
  println!("Positive");
} else if number < 0 {
  println!("Negative");
} else {
  println!("Zero");
}
```

**Key Points:**

- Conditions must evaluate to `bool` (no implicit truthy/falsy conversions)
- Blocks are required, even for single expressions
- The last expression in each branch is implicitly returned if used in assignment
- Type checking ensures all branches return compatible types

**Compile-Time Safety:**

Non-boolean conditions raise compile errors, preventing logic bugs common in dynamic languages.

### `match`

`match` provides exhaustive pattern matching, enforcing that all possible values are handled.

```rs
let value = 3;

match value {
  1 => println!("One"),
  2 => println!("Two"),
  3 => println!("Three"),
  _ => println!("Other"),
}
```

**Key Points:**

- All possible cases must be handled (compiler enforces this)
- `_` is a catch-all pattern that matches any remaining value
- `match` arms are evaluated top-to-bottom; first matching arm executes
- Arms can span multiple expressions using blocks `{}`
- Prevents unreachable code and missing case logic

**Advanced Insight:**

`match` is frequently optimized into jump tables by LLVM, making it both expressive and performant. Exhaustiveness checking at compile time eliminates entire classes of runtime errors.

### Returning a Value from a Conditional

`if` and `match` are expressions and can return values without requiring explicit `return` statements.

```rs
let sign = if number >= 0 {
  "positive"
} else {
  "negative"
};

let category = match value {
  0..=5 => "low",
  6..=10 => "medium",
  _ => "high",
};
```

**Key Points:**

- Both branches must return the same type
- The last expression in each branch is the return value (no semicolon)
- Eliminates temporary mutable variables and intermediate assignments
- Supports range patterns for concise matching

---

## **Iterations**

### `loop`

`loop` creates an infinite loop that runs until explicitly broken with `break`.

```rs
loop {
  println!("Running...");
  break;
}
```

**Use Cases:**

- Event loops and message handlers
- Retry logic with backoff
- Polling for state changes
- Continues indefinitely; requires explicit exit condition

### `while` Loop

`while` repeats execution while a condition remains true, checking the condition before each iteration.

```rs
let mut count = 3;

while count > 0 {
  println!("{}", count);
  count -= 1;
}
```

**Key Points:**

- Condition evaluated before each iteration (skips loop if false initially)
- Requires mutable binding if state changes inside loop
- Useful for conditional iteration tied to external state
- Less safe than `for` for collection iteration (no bounds protection)

### `for` Loop

`for` iterates over iterators, providing safe, bounds-checked iteration without manual indexing.

```rs
for i in 0..3 {
  println!("{}", i);  // Prints 0, 1, 2
}

for item in &vec {
  println!("{}", item);  // Borrows vec immutably
}

for item in vec {
  println!("{}", item);  // Consumes vec
}
```

**Key Points:**

- Preferred for collection iteration (prevents off-by-one errors)
- Works with ranges (`0..3`), arrays, vectors, and any `Iterator` implementor
- Ownership rules apply: iteration consumes or borrows based on the type
- Prevents indexing bugs and doesn't require manual mutation

**Advanced Insight:**

`for` loops are syntactic sugar over the `Iterator` trait, enabling zero-cost abstraction. The compiler optimizes them as effectively as manual loops while providing safety guarantees.

### Tagging a Loop

Loops can be labeled to control nested execution precisely, allowing `break` and `continue` to target specific loops.

```rs
'outer: loop {
  for i in 0..3 {
    if i == 1 {
      break 'outer;  // Breaks the outer loop
    }
  }
}

'search: for row in matrix {
  for col in row {
    if col == target {
      break 'search;
    }
  }
}
```

**Key Points:**

- Labels precede loops with a leading apostrophe `'`
- `break 'label` exits the labeled loop immediately
- `continue 'label` skips to the next iteration of the labeled loop
- Essential for multi-level loop control without complex flag variables

### Returning a Value from a Loop

Loops can return values using `break`, transforming loops into expressions that yield results.

```rs
let result = loop {
  let value = 10;
  break value * 2;  // Loop evaluates to 20
};

let mut search_result = None;
'search: loop {
  for item in items {
    if item.matches(predicate) {
      search_result = Some(item);
      break 'search;
    }
  }
  break;
}
```

**Key Points:**

- The value after `break` becomes the loop's result
- Eliminates need for mutable variables to capture loop results
- Useful for search patterns, retries with final values, and event loop results
- Type-checked: all `break` statements in a loop must return the same type

---

## **Professional Applications and Implementation**

Rust's control flow constructs are fundamental to production systems:

- **State Machines:** `match` expressions elegantly encode state transitions with exhaustiveness guarantees
- **Request Handling:** Conditional expressions reduce intermediate mutable state, improving clarity
- **Retry Logic:** Loop returns and labeled breaks enable clean retry patterns without sentinel values
- **Event Loops:** Infinite loops with break conditions serve as core infrastructure in async runtimes
- **Search Algorithms:** Labeled breaks allow early exit from nested iterations without flags or exceptions
- **Backend Services:** Expression-based conditionals and pattern matching ensure correctness in complex decision trees

Expression-based control flow and exhaustive matching shift error prevention from runtime to compile time, reducing bugs in critical systems.

---

## **Key Takeaways**

| Concept        | Summary                                                                   |
| -------------- | ------------------------------------------------------------------------- |
| Conditionals   | `if` and `match` are expressions; all branches must return the same type. |
| Matching       | `match` enforces exhaustive, type-safe branching at compile time.         |
| Iteration      | `loop`, `while`, and `for` serve distinct iteration patterns.             |
| `for` Loops    | Preferred for collections; safe from indexing errors.                     |
| Loop Labels    | Labeled loops control nested flow and enable targeted breaks.             |
| Return Values  | Conditionals and loops yield values; eliminates mutable intermediates.    |

**Best Practices:**

- Prefer `match` for exhaustive logic; let the compiler guide correctness
- Use `for` loops over `while` for collections to prevent indexing bugs
- Leverage expression returns to reduce mutable state
- Label loops only when necessary to keep code readable
- Exploit pattern ranges (`0..5`, `x..=y`) to reduce match arms

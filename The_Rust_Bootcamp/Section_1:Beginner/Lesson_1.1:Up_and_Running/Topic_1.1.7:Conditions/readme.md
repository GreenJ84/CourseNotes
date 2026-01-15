# **Topic 1.1.7: Conditionals**

This topic explores Rust's conditional control flow constructs, emphasizing their expression-based nature, strict type safety, and compile-time exhaustiveness guarantees. Rust conditionals eliminate implicit truthiness and require explicit logic, enabling the compiler to verify correctness and prevent entire classes of runtime errors. Unlike imperative languages where conditionals are statements, Rust treats conditionals as expressions, allowing them to produce and return values directly. This fundamental distinction shapes idiomatic Rust code and encourages declarative, side-effect-free logic.

## **Learning Objectives**

- Apply conditional logic using `if`, `else if`, and `else` with full type safety
- Master `match` expressions for exhaustive, pattern-based branching
- Understand advanced pattern matching including guards, destructuring, and ranges
- Return values from conditional expressions while maintaining type consistency
- Leverage compile-time exhaustiveness guarantees to prevent logic gaps and unreachable code
- Design state machines and complex control flow using conditional expressions
- Recognize performance implications of conditional expression optimization

---

## **`if / else if / else` Expressions**

### Fundamental Concepts

In Rust, `if` is an expression, not a statement. This means it evaluates to a value that can be assigned, returned, or used in further computations. Every branch must be reachable and type-safe.

```rs
fn classify_number(number: i32) -> &'static str {
  if number > 0 {
    "positive"
  } else if number < 0 {
    "negative"
  } else {
    "zero"
  }
}

let result = classify_number(42);
println!("{}", result); // "positive"
```

### Key Characteristics

- **Boolean Conditions Required**: Conditions must explicitly evaluate to `bool`. Unlike C or JavaScript, `if 1` is a compile error—no implicit truthiness.
- **Type Safety Across Branches**: All branches must return compatible types. The compiler unifies branch types to determine the overall expression type.
- **Mandatory Blocks**: Braces are required; single-line conditionals without blocks are not permitted.
- **Early Return Semantics**: Branches are evaluated top-to-bottom; the first matching condition executes.

```rs
// ❌ Compile error: expected `bool`, found `i32`
if 5 {
  println!("Truthy");
}

// ✓ Correct
if 5 != 0 {
  println!("Non-zero");
}
```

### Expression Return Values

Since `if` is an expression, the final statement in each branch (without a semicolon) becomes the return value. This eliminates unnecessary mutable state.

```rs
let sign = if number >= 0 { "positive" } else { "negative" };

// More complex example with multiple branches
let message = if temperature < 0 {
  "Freezing"
} else if temperature < 15 {
  "Cold"
} else if temperature < 25 {
  "Comfortable"
} else {
  "Hot"
};

// All branches must return the same type
let value = if condition {
  42      // i32, no semicolon
} else {
  100     // i32, no semicolon
};
// ❌ Error: if and else have incompatible types
// let value = if condition { 42 } else { "string" };
```

### Semantic Insight

Expression-based conditionals eliminate temporary mutable variables, improving correctness and readability. Rather than:

```rs
let mut result = String::new();
if condition {
  result = "true branch".to_string();
} else {
  result = "false branch".to_string();
}
```

Write declaratively:

```rs
let result = if condition {
  "true branch"
} else {
  "false branch"
};
```

---

## **`match` Expressions: Exhaustive Pattern Matching**

`match` is Rust's most powerful conditional construct. It provides pattern-based branching with compile-time exhaustiveness checking, ensuring all possible cases are handled. The compiler prevents unreachable code and logic gaps—properties critical in production systems.

### Basic Structure

```rs
match value {
  pattern1 => { /* arm body */ },
  pattern2 => { /* arm body */ },
  _ => { /* catch-all */ },
}
```

```rs
fn describe_color(color: u8) -> &'static str {
  match color {
    0 => "red",
    1 => "green",
    2 => "blue",
    _ => "unknown",
  }
}

println!("{}", describe_color(1)); // "green"
```

### Key Properties

- **Exhaustiveness Enforced**: The compiler requires all possible values to be handled. Missing cases produce compile errors.
- **`_` Wildcard Pattern**: Matches any remaining cases; useful as a catch-all.
- **Top-Down Evaluation**: Arms are evaluated in order; the first matching pattern executes.
- **Scoped Variable Binding**: Patterns can bind variables used only within their arm.
- **Expression Returns**: Like `if`, match arms return values; all branches must have compatible types.

---

## **Patterns: Advanced Matching Semantics**

### Range Patterns

Match against inclusive (`..=`) or exclusive (`..`) ranges of values.

```rs
fn grade_score(score: u32) -> &'static str {
  match score {
    0..=50 => "F",
    51..=60 => "D",
    61..=70 => "C",
    71..=80 => "B",
    81..=100 => "A",
    _ => "Invalid score",
  }
}

println!("{}", grade_score(85)); // "A"

// Exclusive range (less common)
match value {
  0..10 => println!("Single digit"),
  10..100 => println!("Double digit"),
  _ => println!("Larger"),
}
```

**Advanced Insight**: The compiler generates efficient code for ranges—often jump tables or binary search depending on density.

### Guard Conditions (`if` Guards)

Add conditional logic to patterns for finer-grained matching.

```rs
fn categorize_number(number: i32) -> &'static str {
  match number {
    x if x < 0 => "negative",
    x if x == 0 => "zero",
    x if x % 2 == 0 => "even positive",
    x if x % 2 != 0 => "odd positive",
    _ => unreachable!(), // Compiler knows all cases covered
  }
}

println!("{}", categorize_number(7)); // "odd positive"

// Guards can reference multiple variables
match (x, y) {
  (a, b) if a + b > 10 => println!("Sum exceeds 10"),
  (a, b) if a == b => println!("Equal"),
  _ => println!("Other"),
}
```

**Performance Note**: Guards are evaluated at runtime. Complex guard conditions may reduce optimization opportunities compared to simpler patterns.

### Multi-Pattern Arms

Match multiple patterns in a single arm using the `|` operator.

```rs
fn is_vowel(character: char) -> bool {
  match character.to_ascii_lowercase() {
    'a' | 'e' | 'i' | 'o' | 'u' => true,
    _ => false,
  }
}

println!("{}", is_vowel('E')); // true

// Combining with ranges
match response {
  "yes" | "y" | "true" | "1" => println!("Affirmative"),
  "no" | "n" | "false" | "0" => println!("Negative"),
  _ => println!("Unknown"),
}
```

### Destructuring: Extracting Values

Decompose composite types (tuples, structs, enums) to extract and bind inner values.

#### Tuple Destructuring

```rs
fn describe_point(point: (i32, i32)) -> &'static str {
  match point {
    (0, 0) => "origin",
    (x, 0) => "on x-axis",
    (0, y) => "on y-axis",
    (x, y) => "general point",
  }
}

println!("{}", describe_point((3, 0))); // "on x-axis"

// Extracting and using values
match (10, 20) {
  (x, y) if x > y => println!("First is larger: {}", x),
  (x, y) => println!("Second is larger or equal: {}", y),
}
```

#### Struct Destructuring

```rs
struct Person {
  name: String,
  age: u32,
}

let person = Person {
  name: "Alice".to_string(),
  age: 30,
};

match person {
  Person { name, age: 30 } => println!("Found 30-year-old: {}", name),
  Person { name, age } => println!("{} is {} years old", name, age),
}

// Shorthand for binding all fields
match person {
  Person { name, age } => println!("{}, {}", name, age),
}
```

#### Enum Destructuring

```rs
enum Result<T, E> {
  Ok(T),
  Err(E),
}

enum Status {
  Active(String),
  Inactive,
  Suspended { reason: String },
}

let status = Status::Active("Running".to_string());

match status {
  Status::Active(task) => println!("Task: {}", task),
  Status::Inactive => println!("No task"),
  Status::Suspended { reason } => println!("Suspended: {}", reason),
}
```

#### Nested Destructuring

```rs
match (1, (2, 3)) {
  (a, (b, c)) => println!("a={}, b={}, c={}", a, b, c),
}

// Complex nested enum
enum Message {
  Text(String),
  Move { x: i32, y: i32 },
  Color(u8, u8, u8),
}

match message {
  Message::Text(s) => println!("Text: {}", s),
  Message::Move { x, y } => println!("Move to ({}, {})", x, y),
  Message::Color(r, g, b) => println!("RGB: {},{},{}", r, g, b),
}
```

#### Ignoring Values with `_`

```rs
match (1, 2, 3) {
  (a, _, c) => println!("a={}, c={}", a, c), // Ignore middle value
  _ => {},
}

// Binding with `..` (rest pattern)
match (1, 2, 3, 4, 5) {
  (first, .., last) => println!("First: {}, Last: {}", first, last),
}
```

### Key Pattern Matching Properties

- **Exhaustiveness enforced by compiler**: Missing cases are caught at compile time
- **Patterns bind scoped variables**: Bound variables exist only within the arm
- **Arms evaluated top-to-bottom**: First match wins
- **Guards evaluated at runtime**: Complex conditions may reduce optimization
- **Type safety throughout**: Pattern types are verified against the match expression

---

## **Returning Values from Conditionals**

Both `if` and `match` return values, enabling declarative, expression-oriented code.

```rs
// Simple match expression returning a value
let category = match value {
  0..=5 => "low",
  6..=10 => "medium",
  _ => "high",
};

// Complex match with computation
let result = match operation {
  '+' => {
    let sum = a + b;
    format!("Sum: {}", sum)
  },
  '-' => {
    let diff = a - b;
    format!("Difference: {}", diff)
  },
  _ => "Unknown operation".to_string(),
};

// Nested conditionals
let message = if user.is_admin {
  match user.permissions {
    Permissions::Full => "Full access",
    Permissions::Limited => "Limited access",
    Permissions::None => "No access",
  }
} else {
  "Guest access"
};
```

### Type Consistency Rules

All branches must return the same type. The compiler infers the unified type:

```rs
let x = if condition {
  42          // i32
} else {
  100         // i32
};

// ❌ Error: mismatched types
// let y = if condition { 42 } else { "string" };

// ✓ Correct: both return String
let message = if condition {
  "success".to_string()
} else {
  "failure".to_string()
};

// ✓ Correct: match with computed values
let value = match n {
  1..=10 => n * 2,
  11..=20 => n * 3,
  _ => 0,
};
```

---

## **Professional Applications and Implementation**

Conditional expressions and pattern matching are foundational to Rust systems design. They are widely used in state machines, protocol handling, request routing, and domain modeling. Exhaustive matching ensures future changes surface compile-time errors instead of runtime bugs, a critical property for long-lived and safety-critical systems. Rust's control flow constructs are fundamental to production systems:

- **State Machines:** `match` expressions elegantly encode state transitions with exhaustiveness guarantees
- **Request Handling:** Conditional expressions reduce intermediate mutable state, improving clarity
- **Backend Services:** Expression-based conditionals and pattern matching ensure correctness in complex decision trees

### State Machines

Conditional expressions excel at modeling finite state machines, a cornerstone of systems programming.

```rs
#[derive(Clone, Copy)]
enum State {
  Idle,
  Running,
  Paused,
  Stopped,
}

fn next_state(current: State, event: char) -> State {
  match (current, event) {
    (State::Idle, 's') => State::Running,
    (State::Running, 'p') => State::Paused,
    (State::Paused, 'r') => State::Running,
    (State::Paused, 's') => State::Stopped,
    (State::Stopped, 'r') => State::Idle,
    (s, _) => s, // No transition
  }
}
```

### Request Routing and Protocol Handling

```rs
enum HttpMethod {
  Get,
  Post,
  Put,
  Delete,
}

fn route(method: HttpMethod, path: &str) -> &'static str {
  match (method, path) {
    (HttpMethod::Get, "/users") => "list users",
    (HttpMethod::Get, "/users/:id") => "get user",
    (HttpMethod::Post, "/users") => "create user",
    (HttpMethod::Put, "/users/:id") => "update user",
    (HttpMethod::Delete, "/users/:id") => "delete user",
    _ => "not found",
  }
}
```

### Domain Modeling

Exhaustive matching ensures all cases are handled, preventing bugs when domain models evolve.

```rs
enum PaymentStatus {
  Pending,
  Authorized(TransactionId),
  Captured(TransactionId),
  Failed(String),
  Refunded(TransactionId),
}

fn process_status(status: PaymentStatus) -> bool {
  match status {
    PaymentStatus::Pending => false,
    PaymentStatus::Authorized(_) => false,
    PaymentStatus::Captured(_) => true,
    PaymentStatus::Failed(reason) => {
      eprintln!("Payment failed: {}", reason);
      false
    },
    PaymentStatus::Refunded(_) => true,
  }
}
// Adding a new variant forces compilation to fail until all matches are updated
```

### Performance: Compiler Optimization

The Rust compiler and LLVM optimize `match` expressions aggressively:

- **Jump Tables**: Sparse ranges often become jump tables for O(1) dispatch
- **Binary Search**: Dense integer ranges use binary search
- **Inlining**: Simple arms inline readily
- **Dead Code Elimination**: Unreachable arms compile away

---

## **Key Takeaways**

| Concept                    | Summary                                                             |
| -------------------------- | ----------------------------------------------------------          |
| `if` Expressions           | Explicit boolean logic with value returns; eliminates mutable state |
| `match` Expressions        | Exhaustive, pattern-driven branching with compile-time safety       |
| Guard Conditions           | Runtime logic for fine-grained pattern matching                     |
| Destructuring              | Extract and bind values from tuples, structs, enums                 |
| Type Safety                | Compiler-enforced type consistency across all branches              |
| Exhaustiveness             | Missing cases caught at compile time, preventing logic gaps         |
| Performance                | LLVM optimizes match to jump tables or binary search                |
| Expression-Based Logic     | Returns values; reduces mutation and improves correctness           |

- **Prefer `match` when all cases must be handled**: Exhaustiveness checking provides compile-time safety.
- **Use expression returns to avoid mutable intermediates**: Declare values rather than mutate them.
- **Leverage guards for complex conditions**: But prefer simple patterns when possible for optimization.
- **Destructure to extract values**: Reduces temporary bindings and improves readability.
- **Let the compiler enforce correctness**: Missing matches are errors, not runtime surprises.
- **Organize patterns from specific to general**: More specific patterns should appear before general ones.


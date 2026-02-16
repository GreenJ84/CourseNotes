# **Practical Examples: From Simple to Advanced**

## Example 1: Simple Empty Matcher

A minimal declarative macro with no arguments:

```rust
#[macro_export]
macro_rules! hello {
    () => {
        println!("Hello World!");
    };
}

// Invocation
hello!();
```

**Expansion:**

```rust
println!("Hello World!");
```

**Use case**: Zero-cost shorthand for common operations.

---

## Example 2: Single Argument Matcher

Capturing and using one argument:

```rust
macro_rules! say {
    ($message:expr) => {
        println!("Message: {}", $message);
    };
}

say!("Hello, Rust!");
say!(format!("Value: {}", 42));
```

**Expansion:**

```rust
println!("Message: {}", "Hello, Rust!");
println!("Message: {}", format!("Value: {}", 42));
```

**Note**: The argument can be any expression, including function calls.

---

## Example 3: Multiple Arguments with Different Types

```rust
macro_rules! describe {
    ($name:expr, $age:expr, $active:expr) => {
        println!("Name: {}, Age: {}, Active: {}", $name, $age, $active);
    };
}

describe!("Alice", 30, true);
```

**Expansion:**

```rust
println!("Name: {}, Age: {}, Active: {}", "Alice", 30, true);
```

---

## Example 4: Multi-Rule HashMap Builder

A more complex example demonstrating multiple matchers and repetition:

```rust
#[macro_export]
macro_rules! map {
    // Rule 1: Empty map with type annotations
    // Usage: map!(String => i32)
    ($key:ty => $val:ty) => {{
        HashMap::<$key, $val>::new()
    }};

    // Rule 2: Map with initial key-value pairs
    // Usage: map!{ "key1" => 1, "key2" => 2 }
    ($($key:expr => $val:expr),* $(,)?) => {{
        let mut map = HashMap::new();
        $(
            map.insert($key, $val);
        )*
        map
    }};
}

// Usage examples
let empty: HashMap<String, i32> = map!(String => i32);

let scores = map! {
    "Alice" => 95,
    "Bob" => 87,
    "Charlie" => 92,
};
```

**Expansion (Rule 2):**

```rust
{
    let mut map = HashMap::new();
    map.insert("Alice", 95);
    map.insert("Bob", 87);
    map.insert("Charlie", 92);
    map
}
```

**Key features:**

- Multiple rules for different use cases
- Type parameters (`:ty`)
- Expression repetition (`$(...)*`)
- Optional trailing comma (`$(,)?`)
- Block expression (`{{ }}`) to prevent variable leakage

---

## Example 5: Variadic Function Simulator

Simulating variadic functions (impossible with standard functions):

```rust
macro_rules! sum {
    // Base case: no arguments
    () => { 0 };
    
    // Recursive case: add first, recur on rest
    ($first:expr $(, $rest:expr)*) => {
        $first + sum!($($rest),*)
    };
}

let total = sum!(1, 2, 3, 4, 5); // 15
```

**Expansion trace:**

```rust
sum!(1, 2, 3, 4, 5)
→ 1 + sum!(2, 3, 4, 5)
→ 1 + (2 + sum!(3, 4, 5))
→ 1 + (2 + (3 + sum!(4, 5)))
→ 1 + (2 + (3 + (4 + sum!(5))))
→ 1 + (2 + (3 + (4 + (5 + sum!()))))
→ 1 + (2 + (3 + (4 + (5 + 0))))
→ 15
```

**Senior insight**: Recursive macros compile to non-recursive code. The recursion happens during expansion, not at runtime.

---

## Example 6: Trailing Comma Support

Professional macros should accept trailing commas:

```rust
macro_rules! vec_of_strings {
    ($($item:expr),* $(,)?) => {
        vec![$($item.to_string()),*]
    };
}

// Both work
vec_of_strings!["a", "b", "c"];     // No trailing comma
vec_of_strings!["a", "b", "c",];    // Trailing comma
```

The `$(,)?` pattern means "optionally match a comma."

---

## Example 7: DSL for Unit Tests

Creating a mini-DSL for test generation:

```rust
macro_rules! test_cases {
    ($test_name:ident: $($input:expr => $expected:expr),+ $(,)?) => {
        #[test]
        fn $test_name() {
            $(
                assert_eq!(process($input), $expected);
            )+
        }
    };
}

// Usage
test_cases! {
    test_process_values:
    1 => 2,
    2 => 4,
    3 => 6,
    4 => 8,
}

// Expands to:
// #[test]
// fn test_process_values() {
//     assert_eq!(process(1), 2);
//     assert_eq!(process(2), 4);
//     assert_eq!(process(3), 6);
//     assert_eq!(process(4), 8);
// }
```

This eliminates test boilerplate and makes test cases more readable.

---

## Example 8: Compile-Time Configuration

Conditional code generation based on features:

```rust
macro_rules! log {
    ($($arg:tt)*) => {
        #[cfg(feature = "logging")]
        {
            eprintln!($($arg)*);
        }
        #[cfg(not(feature = "logging"))]
        {
            // No-op in production
        }
    };
}

log!("Debug: x = {}", x);
// Compiles to nothing if "logging" feature is disabled
```

**Senior insight**: This is zero-cost abstraction—when logging is disabled, the compiler eliminates the entire branch.

---

## Example 9: Implementing `dbg!`-like Macro

Understanding how `dbg!` works:

```rust
macro_rules! my_dbg {
    () => {
        eprintln!("[{}:{}]", file!(), line!());
    };
    ($val:expr) => {
        match $val {
            tmp => {
                eprintln!("[{}:{}] {} = {:#?}",
                    file!(), line!(), stringify!($val), &tmp);
                tmp
            }
        }
    };
}

let x = 5;
let y = my_dbg!(x + 1);
// Prints: [src/main.rs:42] x + 1 = 6
// y = 6 (value passes through)
```

**Key techniques:**

- `file!()` and `line!()` provide call-site location
- `stringify!($val)` converts syntax to string
- `match` binding ensures single evaluation
- Return value passes through

---

## Example 10: Builder Pattern Generator

Generating builder methods for structs:

```rust
macro_rules! builder_methods {
    ($($field:ident: $type:ty),* $(,)?) => {
        $(
            pub fn $field(mut self, $field: $type) -> Self {
                self.$field = $field;
                self
            }
        )*
    };
}

struct ConfigBuilder {
    host: String,
    port: u16,
    timeout: u64,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        Self {
            host: String::from("localhost"),
            port: 8080,
            timeout: 30,
        }
    }
    
    builder_methods! {
        host: String,
        port: u16,
        timeout: u64,
    }
}

// Usage
let config = ConfigBuilder::new()
    .host("example.com".into())
    .port(443)
    .timeout(60);
```

**Expansion:**

```rust
pub fn host(mut self, host: String) -> Self {
    self.host = host;
    self
}
pub fn port(mut self, port: u16) -> Self {
    self.port = port;
    self
}
pub fn timeout(mut self, timeout: u64) -> Self {
    self.timeout = timeout;
    self
}
```

---

## Example 11: Enum Variant Generator

```rust
macro_rules! define_handlers {
    ($($variant:ident => $handler:expr),* $(,)?) => {
        enum Message {
            $($variant),*
        }
        
        impl Message {
            fn handle(&self) {
                match self {
                    $(Message::$variant => $handler,)*
                }
            }
        }
    };
}

define_handlers! {
    Start => println!("Starting..."),
    Stop => println!("Stopping..."),
    Restart => println!("Restarting..."),
}

// Expands to complete enum and impl
```

---

## Example 12: SQL-like Query DSL

Building a mini query language:

```rust
macro_rules! query {
    (SELECT $($field:ident),+ FROM $table:ident WHERE $condition:expr) => {{
        let mut results = Vec::new();
        for row in $table.iter() {
            if $condition(row) {
                results.push(($(row.$field),+));
            }
        }
        results
    }};
}

// Usage (hypothetical)
let results = query! {
    SELECT name, age
    FROM users
    WHERE |u| u.age > 18
};
```

This demonstrates how macros enable domain-specific syntax that looks nothing like normal Rust.

# **Topic 3.2.2: Declarative Macros**

Declarative macros, often referred to as “macros by example,” provide pattern-based compile-time code generation using structural matching. They allow Rust developers to define syntactic transformations by matching input token patterns and rewriting them into expanded Rust code. Unlike procedural macros, declarative macros rely on rule-based token matching rather than programmatic AST manipulation.

Declarative macros are defined using `macro_rules!` and are evaluated during compilation. They operate purely at the syntactic level and expand before semantic analysis, making them a powerful mechanism for reducing boilerplate, implementing DSL-like constructs, and enforcing consistent code patterns.

## **Learning Objectives**

- Define declarative macros and their role in Rust’s macro system
- Explain how pattern matching drives macro expansion
- Understand the structure of a `macro_rules!` definition
- Identify how matchers and transcribers interact
- Recognize repetition patterns and fragment specifiers

---

## **Pattern-Based Code Generation**

Declarative macros are defined by matching against code patterns in a manner conceptually similar to `match` expressions, but operating on token trees instead of runtime values. They represent Rust's original macro system and remain the most common form of macro due to their simplicity and power.

### The Mental Model: Match on Syntax

Think of declarative macros as a `match` expression that operates during compilation:

```rust
// Runtime match (on values)
match value {
    Pattern1 => code1,
    Pattern2 => code2,
}

// Compile-time match (on syntax)
macro_rules! my_macro {
    (Pattern1) => { code1 };
    (Pattern2) => { code2 };
}
```

The key difference: runtime `match` operates on typed values, while macros operate on **untyped token streams** before type checking occurs.

### General Structure

```rust
macro_rules! macro_name {
    // Rule 1: matches pattern1, expands to code1
    (pattern1) => { expansion1 };
    
    // Rule 2: matches pattern2, expands to code2
    (pattern2) => { expansion2 };
    
    // More rules...
    (patternN) => { expansionN };
}
```

Each rule consists of two parts:

1. **Matcher (Pattern)** — Describes the acceptable token structure using fragment specifiers and repetition patterns
2. **Transcriber (Expansion)** — Code emitted when the matcher succeeds, with captured fragments interpolated

### Rule Evaluation Order

Rules are evaluated **sequentially** in definition order. The **first** matching rule wins:

```rust
macro_rules! ambiguous {
    ($x:expr) => { println!("Expression: {}", $x) };
    ($x:ident) => { println!("Identifier: {}", stringify!($x)) };
}

ambiguous!(foo);
// Matches first rule ($x:expr) because identifiers are also expressions
// Prints: "Expression: foo" (not "Identifier: foo")
```

> **Senior Insight**: Place more specific patterns before more general patterns. An identifier is always an expression, so `ident` patterns should come before `expr` patterns if you want distinct behavior.

### Correct Pattern Ordering

```rust
macro_rules! better {
    // More specific first
    ($x:ident) => { println!("Identifier: {}", stringify!($x)) };
    
    // More general last
    ($x:expr) => { println!("Expression: {}", $x) };
}

better!(foo);        // Matches ident: "Identifier: 3"
better!(1 + 2);      // Matches expr: "Expression: 3"
```

### Macro Expansion Process

When the compiler encounters a macro invocation:

1. **Parse invocation tokens** into a token tree
2. **Try each rule** in order against the token tree
3. **First match wins**—capture matched fragments
4. **Expand transcriber**—substitute captured fragments
5. **Replace invocation** with expanded tokens
6. **Recursively expand** any macros in the result

**Example trace:**

```rust
macro_rules! double {
    ($x:expr) => { $x * 2 };
}

let result = double!(5 + 3);

// Step 1: Parse "5 + 3" into token tree
// Step 2: Try rule ($x:expr) => { $x * 2 }
// Step 3: Match succeeds, capture $x = "5 + 3"
// Step 4: Expand to "(5 + 3) * 2"
// Step 5: Replace invocation with expansion
// Step 6: No nested macros, done
// Result: let result = (5 + 3) * 2;
```

### Hygiene in Declarative Macros

Declarative macros are **hygienic by default**, meaning identifiers declared inside the macro don't clash with identifiers in the calling code:

```rust
macro_rules! declare_variable {
    () => {
        let x = 42; // Hygienic: unique identifier generated
    };
}

fn test() {
    let x = 10;
    declare_variable!(); // Doesn't overwrite outer x
    println!("Outer x: {}", x); // Still 10
    
    // Macro's x is in its own scope
}
```

The compiler generates a unique identifier for the macro's `x`, preventing collision.

### Exception: Intentional capture

Macros can explicitly introduce identifiers into the caller's scope by using them in patterns:

```rust
macro_rules! create_var {
    ($name:ident = $value:expr) => {
        let $name = $value; // $name captured from caller, not hygienic
    };
}

create_var!(my_var = 42);
println!("{}", my_var); // ✅ my_var is visible
```

This is intentional—the caller provided the identifier, so it should be accessible.

> **Senior Insight**: Hygiene prevents most macro bugs, but understanding when capture is intentional vs accidental is crucial. If your macro should introduce a variable into the caller's scope, use a captured identifier. If it's internal to the macro logic, let hygiene protect you.

---

## **`macro_rules!`**

`macro_rules!` is itself a macro (a "macro-defining macro") used to define new declarative macros. Understanding its mechanics is essential for writing robust, production-quality macros.

### Basic Syntax and Components

```rust
#[macro_export]              // Optional: export from crate
macro_rules! macro_name {
    // Rule with matcher and transcriber
    (matcher_pattern) => {
        expansion_code
    };
    
    // Multiple rules allowed
    (another_pattern) => {
        different_expansion
    };
}
```

#### Components

- **`#[macro_export]`**: Makes the macro available to external crates at the crate root
- **`macro_name`**: Identifier for invoking the macro
- **Matcher pattern**: Token pattern with fragment specifiers and repetitions
- **Transcriber**: Code template with captured fragment interpolations

### Fragment Specifiers: The Building Blocks

Fragment specifiers define what kind of syntax element to capture. They're prefixed with `:` in patterns:

| Specifier | Matches | Example | Use Case |
| --------- | ------- | ------- | -------- |
| `:item` | Item (function, struct, impl, etc.) | `fn foo() {}` | Generating complete items |
| `:block` | Brace-delimited block | `{ stmt; expr }` | Capturing code blocks |
| `:stmt` | Statement | `let x = 5;` | Statement manipulation |
| `:expr` | Expression | `1 + 2`, `foo()` | Most common; any expression |
| `:pat` | Pattern | `Some(x)`, `(a, b)` | Match arm patterns |
| `:ty` | Type | `Vec<i32>`, `&str` | Type annotations |
| `:ident` | Identifier | `foo`, `MyStruct` | Names and labels |
| `:path` | Path | `std::collections::HashMap` | Module paths |
| `:tt` | Token tree | Any single token or group | Most flexible; any syntax |
| `:meta` | Attribute contents | `derive(Debug)` | Attribute processing |
| `:lifetime` | Lifetime | `'a`, `'static` | Lifetime parameters |
| `:vis` | Visibility | `pub`, `pub(crate)` | Visibility modifiers |
| `:literal` | Literal | `42`, `"hello"`, `true` | Literal values only |

**Senior insight on specificity:**

- **`:tt`** (token tree) is the most permissive—matches anything
- **`:expr`** matches any expression, including identifiers
- **`:ident`** matches only identifiers (names)
- **`:literal`** matches only literal values

Order from most to least permissive: `:tt` > `:expr` > `:ident` > `:literal`

### Fragment Specifier Examples

```rust
macro_rules! demonstrate_fragments {
    // :expr - matches any expression
    (expr: $e:expr) => {
        println!("Expression result: {}", $e);
    };
    
    // :ident - matches only identifiers
    (ident: $i:ident) => {
        let $i = 42;
        println!("Created variable {}", stringify!($i));
    };
    
    // :ty - matches types
    (ty: $t:ty) => {
        let value: $t = Default::default();
    };
    
    // :pat - matches patterns
    (pat: $p:pat) => {
        match (1, 2) {
            $p => println!("Pattern matched!"),
            _ => println!("No match"),
        }
    };
    
    // :block - matches code blocks
    (block: $b:block) => {
        println!("Before block");
        $b
        println!("After block");
    };
    
    // :tt - matches any token tree (most flexible)
    (tt: $($t:tt)*) => {
        // Can be any sequence of tokens
        $($t)*
    };
}

// Usage examples
demonstrate_fragments!(expr: 1 + 2 * 3);
demonstrate_fragments!(ident: my_var);
demonstrate_fragments!(ty: Vec<String>);
demonstrate_fragments!(pat: (x, y));
demonstrate_fragments!(block: {
    let x = 10;
    x * 2
});
demonstrate_fragments!(tt: anything goes here! [even, weird, syntax]);
```

### Repetition Patterns

Repetition is one of the most powerful macro features, allowing variable-length argument lists:

**Syntax:**

```rust
$( pattern )*      // Zero or more repetitions
$( pattern )+      // One or more repetitions
$( pattern )?      // Zero or one (optional)
```

**With separators:**

```rust
$( pattern ),*     // Comma-separated, zero or more
$( pattern ),+     // Comma-separated, one or more
$( pattern );*     // Semicolon-separated
$( pattern ),* ,   // Trailing separator allowed
```

**Comprehensive repetition example:**

```rust
macro_rules! create_functions {
    // Matches: create_functions!(fn_name1, fn_name2, fn_name3)
    ($($name:ident),* $(,)?) => {
        $(
            fn $name() {
                println!("Function {} called", stringify!($name));
            }
        )*
    };
}

create_functions!(foo, bar, baz);

// Expands to:
// fn foo() { println!("Function foo called"); }
// fn bar() { println!("Function bar called"); }
// fn baz() { println!("Function baz called"); }

// Usage
foo(); // "Function foo called"
bar(); // "Function bar called"
```

### Nested Repetitions

Repetitions can be nested for complex patterns:

```rust
macro_rules! matrix {
    // Matches: matrix![[1, 2], [3, 4], [5, 6]]
    ($([$($x:expr),* $(,)?]),* $(,)?) => {
        vec![
            $(
                vec![$($x),*]
            ),*
        ]
    };
}

let m = matrix![
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
];

// Expands to:
// vec![
//     vec![1, 2, 3],
//     vec![4, 5, 6],
//     vec![7, 8, 9]
// ]
```

> **Senior Insight**: Nested repetitions must correspond, each captured repetition in the matcher must have exactly one repetition in the transcriber. This is enforced by the compiler:

```rust
macro_rules! broken {
    ($($x:expr),*) => {
        $($x),* $($x),* // ❌ Error: $x used twice in transcriber
    };
}
```

### Counting and Indexing

Macros cannot directly count or index, but you can use patterns:

```rust
// Count elements using recursive expansion
macro_rules! count {
    () => { 0 };
    ($one:tt) => { 1 };
    ($first:tt, $($rest:tt),+) => { 1 + count!($($rest),+) };
}

const N: usize = count!(a, b, c, d, e); // 5
```

### The `stringify!` Built-in

Useful for converting syntax to strings:

```rust
macro_rules! debug_value {
    ($val:expr) => {
        println!("{} = {:?}", stringify!($val), $val);
    };
}

let x = 42;
debug_value!(x + 10); // Prints: "x + 10 = 52"
```

### Macro Visibility and Export

**By default**, macros are scoped to the module where they're defined:

```rust
mod inner {
    macro_rules! local_macro {
        () => { println!("Local") };
    }
    
    pub(crate) fn use_it() {
        local_macro!(); // ✅ Works
    }
}

// outer module
// local_macro!(); // ❌ Error: macro not visible
```

#### `#[macro_export]`

This makes the macro available at the crate root:

```rust
#[macro_export]
macro_rules! exported_macro {
    () => { println!("Exported") };
}

// In another module or crate
use my_crate::exported_macro;
exported_macro!(); // ✅ Works
```

#### `#[macro_use]`

This imports all macros from a crate or module

```rust
#[macro_use]
extern crate my_crate;

// All exported macros from my_crate now available
```

> **Senior Insight**: Use `#[macro_export]` sparingly. Exported macros are public API and cannot be changed without breaking semver. For internal macros, keep them module-scoped.

---

## **Advanced Pattern: Token Tree Munching**

"Munching" is a pattern-matching recursion technique for processing token sequences:

```rust
macro_rules! munch {
    // Base case: no tokens left
    () => {
        println!("Done munching");
    };
    
    // Recursive case: process one token, recur on rest
    ($first:tt $($rest:tt)*) => {
        println!("Munched: {}", stringify!($first));
        munch!($($rest)*);
    };
}

munch!(a b c d);
// Prints:
// Munched: a
// Munched: b
// Munched: c
// Munched: d
// Done munching
```

This technique is useful for processing complex syntax element by element.

### Incremental TT Munchers

For complex parsing, process tokens incrementally:

```rust
macro_rules! parse_key_value {
    // Finished parsing all pairs
    (@inner [$($result:tt)*]) => {
        { $($result)* }
    };
    
    // Parse "key = value" and continue
    (@inner [$($result:tt)*] $key:ident = $val:expr, $($rest:tt)*) => {
        parse_key_value!(
            @inner [
                $($result)*
                map.insert(stringify!($key), $val);
            ]
            $($rest)*
        )
    };
    
    // Entry point
    ($($input:tt)*) => {{
        let mut map = std::collections::HashMap::new();
        parse_key_value!(@inner [] $($input)*);
        map
    }};
}

let config = parse_key_value!(
    host = "localhost",
    port = 8080,
    timeout = 30,
);
```

> **Senior Insight**: The `@inner` pattern is a convention for internal recursive rules. The `@` prefix signals "this is not part of the public API."

---

## **Common Pitfalls and Debugging Strategies**

### Pitfall 1: Multiple Evaluation Bug

**The problem**: Expressions captured in patterns are re-evaluated each time they appear in the expansion:

```rust
macro_rules! double {
    ($x:expr) => { $x + $x };
}

let mut counter = 0;
let result = double!({
    counter += 1;
    counter
});

// Expands to: { counter += 1; counter } + { counter += 1; counter }
// counter is incremented TWICE
// Result: 1 + 2 = 3 (not 2!)
```

**The solution**: Bind to a temporary variable:

```rust
macro_rules! double {
    ($x:expr) => {{
        let temp = $x;
        temp + temp
    }};
}

let mut counter = 0;
let result = double!({
    counter += 1;
    counter
});

// Expands to:
// {
//     let temp = { counter += 1; counter };
//     temp + temp
// }
// counter incremented ONCE
// Result: 2 (correct!)
```

> **Senior Insight**: "Always bind macro expression arguments to variables before using them more than once."

### Pitfall 2: Pattern Ambiguity and Ordering

**The problem**: More general patterns shadow specific ones:

```rust
macro_rules! process {
    ($x:expr) => { println!("Expression: {}", $x) };
    ($x:ident) => { println!("Identifier: {}", stringify!($x)) };
}

process!(foo); // Always matches first rule (expr) not (ident)
```

**The solution**: Put specific patterns first:

```rust
macro_rules! process {
    ($x:ident) => { println!("Identifier: {}", stringify!($x)) };
    ($x:expr) => { println!("Expression: {}", $x) };
}
```

> **Specificity hierarchy**: `:literal` < `:ident` < `:path` < `:expr` < `:tt`

### Pitfall 3: Forgetting Optional Trailing Comma

**The problem**: Macros fail when users add trailing commas:

```rust
macro_rules! items {
    ($($x:expr),*) => { vec![$($x),*] };
}

items![1, 2, 3];   // ✅ Works
items![1, 2, 3,];  // ❌ Error: no rules expected this token
```

**The solution**: Always support trailing commas:

```rust
macro_rules! items {
    ($($x:expr),* $(,)?) => { vec![$($x),*] };
}

// Both work now
items![1, 2, 3];
items![1, 2, 3,];
```

> **Senior Insight**: "Every repetition with a separator should have `$(,)?` after it."

### Pitfall 4: Hygiene Confusion

**The problem**: Not understanding when variables are captured vs hygienic:

```rust
macro_rules! confusing {
    ($name:ident) => {
        let x = 10;          // Hygienic (unique identifier)
        let $name = 20;      // Captured (visible to caller)
    };
}

confusing!(y);
println!("{}", y);  // ✅ Works (y captured)
println!("{}", x);  // ❌ Error (x is hygienic)
```

> **The principle**: Identifiers from patterns are captured; identifiers created in expansions are hygienic.

### Pitfall 5: Recursion Limit

**The problem**: Deep macro recursion hits compiler limits:

```rust
macro_rules! countdown {
    (0) => { 0 };
    ($n:expr) => { 1 + countdown!($n - 1) };
}

countdown!(200); // ❌ Error: recursion limit reached
```

**The solution**: Increase the limit or restructure:

```rust
#![recursion_limit = "256"]

// Or use iterative token munching instead of deep recursion
```

### Pitfall 6: Mismatched Repetition Depths

**The problem**: Nested repetitions don't align:

```rust
macro_rules! broken {
    ($($x:expr),* , $($y:expr),*) => {
        $(
            println!("{} {}", $x, $y); // ❌ Which pairing?
        )*
    };
}
```

**The solution**: Nested repetitions must correspond structurally:

```rust
macro_rules! pairs {
    ($(($x:expr, $y:expr)),* $(,)?) => {
        $(
            println!("{} {}", $x, $y);
        )*
    };
}

pairs![(1, "a"), (2, "b"), (3, "c")];
```

---

## **Debugging Techniques**


### 1. Test with `stringify!`

Inspect what tokens are captured:

```rust
macro_rules! debug_macro {
    ($($t:tt)*) => {
        println!("{}", stringify!($($t)*));
    };
}

debug_macro!(foo bar baz); // Prints: "foo bar baz"
```

### 2. Incremental testing

Test each rule independently:

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_empty() {
        let v = my_macro![];
        assert_eq!(v.len(), 0);
    }

    #[test]
    fn test_single() {
        let v = my_macro![1];
        assert_eq!(v, vec![1]);
    }

    #[test]
    fn test_multiple() {
        let v = my_macro![1, 2, 3];
        assert_eq!(v, vec![1, 2, 3]);
    }
}
```


### 3. Simplify and isolate

When debugging fails, create a minimal reproduction:

```rust
// Instead of complex macro
macro_rules! simple_test {
    ($x:expr) => {
        println!("{}", $x);
    };
}
```

---

## **Declarative Macro Usage**

Declarative macros are widely used in production Rust codebases to solve problems that cannot be addressed with functions, generics, or traits. Understanding when and how to use them professionally is critical for senior developers.

### When to Use Declarative Macros

1. **Variable argument counts with different types** (e.g., `println!`, `vec!`)
2. **Syntactic patterns that repeat with minor variations** (e.g., test definitions)
3. **Code generation based on compile-time patterns** (e.g., match arms)
4. **Domain-specific mini-languages** (e.g., configuration DSLs)
5. **Zero-cost conditional compilation** (e.g., feature-gated code)

#### Architectural Best Practices

1. **Document expansion behavior**
2. **Provide function alternatives when possible**
3. **Namespace internal rules with `@`**
4. **Test thoroughly**
5. **Consider compilation impact**
6. **Version carefully**: Exported macros are public API

Changes to exported macros require major version bumps.

### Avoid declarative macros when

1. **Functions or generics work** (always prefer these)
2. **The abstraction only saves 2-3 lines** (cognitive overhead not worth it)
3. **Complex logic is required** (procedural macros are better)
4. **Type safety is critical** (macros bypass type checking until after expansion)
5. **Debugging clarity matters more than brevity**

### When to Upgrade to Procedural Macros

Consider procedural macros when:

1. **Complex token manipulation** beyond pattern matching
2. **Custom syntax parsing** (not just patterns)
3. **Extensive error diagnostics** with spans
4. **Stateful expansion** (tracking context across invocations)
5. **Integration with external tools** (code generation from files, etc.)

**Example**: Serde uses procedural derive macros because it needs to:

- Parse struct fields with attributes
- Generate complex serialization logic
- Provide detailed error messages
- Handle edge cases (lifetimes, generics, etc.)

This complexity exceeds what declarative macros can handle elegantly.

### Real-World Use Case: Testing Utilities

**Problem**: Test setup is repetitive across many tests.

```rust
// Without macros: repetitive test code
#[test]
fn test_feature_a() {
    let db = setup_database();
    let user = create_test_user(&db);
    // ... test logic
    cleanup(&db);
}

#[test]
fn test_feature_b() {
    let db = setup_database();
    let user = create_test_user(&db);
    // ... different test logic
    cleanup(&db);
}

// 50 more tests with same setup...
```

**Solution**: Macro-based test harness:

```rust
macro_rules! db_test {
    ($name:ident, $user:ident, $body:block) => {
        #[test]
        fn $name() {
            let db = setup_database();
            let $user = create_test_user(&db);
            
            // Test body
            $body
            
            cleanup(&db);
        }
    };
}

// Usage: concise and clear
db_test!(test_feature_a, user, {
    assert_eq!(user.name, "Test User");
    // ... test logic
});

db_test!(test_feature_b, user, {
    assert!(user.is_active);
    // ... different test logic
});
```

**Benefits**: Eliminates 4-5 lines per test; 50 tests save 200+ lines.

---

## **Professional Applications and Implementation**

Declarative macros are widely used in Rust libraries to:

- Reduce repetitive boilerplate
- Implement collection builders
- Provide ergonomic API wrappers
- Create internal domain-specific patterns
- Enforce consistent code generation patterns

They are especially effective when abstraction needs exceed what generics and traits can express syntactically but do not require full procedural macro power.

Proper macro design prioritizes:

- Readability of invocation syntax
- Minimal surprise in expansion behavior
- Clear documentation of accepted patterns

---

## **Key Takeaways**

| Concept | Summary |
| ------- | ------- |
| Declarative Macros | Pattern-based compile-time code generation using `macro_rules!`; operate on token trees, not typed values. |
| Rule Structure | Each rule contains a matcher (pattern) and transcriber (expansion); first matching rule wins. |
| Evaluation Order | Rules are checked sequentially; more specific patterns should come before general ones. |
| Fragment Specifiers | Define syntax categories (`:expr`, `:ident`, `:ty`, etc.); specificity ranges from `:literal` to `:tt`. |
| Repetition Patterns | Support variable arguments with `$(...)*`, `$(...)+`, `$(...)?` and separators like `,` or `;`. |
| Hygiene | Identifiers created in expansions are hygienic (unique); captured identifiers are visible to caller. |
| Multiple Evaluation | Expression arguments evaluate each time they appear; bind to variables to avoid side effects. |
| Primary Benefit | Reduces boilerplate while preserving zero-cost abstractions and type safety after expansion. |
| Common Pitfalls | Multiple evaluation, pattern ambiguity, forgetting trailing commas, recursion limits, mismatched repetitions. |
| Debugging | Use `cargo expand`, `stringify!`, incremental testing, and pattern-specific error recognition. |
| Professional Use | Testing utilities, error handling, bitflags, dispatch tables, configuration validation, compile-time constants. |
| When to Use | Variable arguments, significant boilerplate, compile-time patterns, DSLs, zero-cost conditional compilation. |
| When to Avoid | Functions/generics work, minimal savings, complex logic, priority on debugging clarity. |
| Architectural Best Practices | Document expansions, provide function alternatives, namespace internal rules, test thoroughly, version carefully. |

**Essential Principles:**

- Declarative macros operate on token patterns during compilation before type checking
- The first matching rule determines expansion behavior—order patterns by specificity
- Fragment specifiers define accepted syntactic forms (`:expr`, `:ty`, `:ident`, `:tt`, etc.)
- Repetition syntax enables flexible argument handling with `$(pattern)*`, `$(pattern)+`, `$(pattern)?`
- Always bind expression arguments to variables before using them multiple times (avoid multiple evaluation bug)
- Support trailing commas with `$(,)?` for ergonomic invocation matching Rust conventions
- Hygiene prevents variable capture bugs—identifiers in expansions are unique unless explicitly captured
- Use `cargo expand` to debug macro expansions and verify generated code
- Test macro edge cases: empty, single element, multiple elements, trailing commas, complex expressions
- Prefer functions and generics over macros when both can solve the problem
- Document macro behavior with examples showing both invocation and expansion
- Exported macros are public API—changes require semver major version bumps
- Consider procedural macros when complexity exceeds pattern matching capabilities
- Real-world applications include testing harnesses, error handling, DSLs, lookup tables, and configuration

**Senior Insights:**

- Pattern specificity hierarchy: `:literal` < `:ident` < `:path` < `:expr` < `:tt`
- Internal recursive rules use `@` prefix convention to signal non-public API
- Macro recursion is compile-time only—generates iterative code, not runtime recursion
- Nested repetitions must correspond structurally in matchers and transcribers
- Most macro bugs are pattern matching errors caught during expansion, not runtime errors
- Heavy macro usage increases compilation time—balance abstraction benefit against compile cost
- Provide function alternatives alongside macros for explicit API and easier testing
- Understanding token trees vs AST is critical—macros see structure without semantics

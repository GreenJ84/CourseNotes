# **Topic 3.2.3: Procedural Macros**

Procedural macros provide programmatic compile-time code generation by transforming token streams into new token streams. Unlike declarative macros, which rely on pattern matching, procedural macros operate as Rust functions that receive structured input and emit generated Rust code. They enable advanced abstraction, framework-level ergonomics, and custom language extensions.

Procedural macros must be defined in a dedicated crate configured specifically for macro expansion. They execute during compilation and must signal errors using `panic!`, as they do not return `Result` types. Understanding procedural macros is essential for senior Rust developers, as they form the backbone of modern Rust frameworks and libraries like `serde`, `tokio`, and `actix`.

## **Learning Objectives**

- Define procedural macros and distinguish them from declarative macros with architectural trade-offs
- Understand crate requirements, compilation setup, and hygiene considerations
- Explain the role of `TokenStream` in macro input and output with token manipulation strategies
- Differentiate function-like, derive, and attribute procedural macros with use case patterns
- Interpret procedural macro implementations using `syn` and `quote` for production code
- Design error handling strategies and macro expansion diagnostics

---

## **Core Characteristics**

- Defined as functions that take `TokenStream` input and return `TokenStream` output
- *Perform transformations programmatically*, rather than through pattern rules
- Must be declared in a *dedicated crate* with special configuration (`proc-macro = true`)
- Signal compilation errors using `panic!` or the `proc_macro_error` crate for structured diagnostics

---

## **Setting Up a Procedural Macro Crate**

Procedural macros require careful project structure separation.

### Utilizing in Project Structure

Start by creating the two crates you will need:

```bash
cargo new my_framework # Your project binary
cargo new my_framework_macros --lib # Dedicated procedural macro crate
```


In the project's Root `Cargo.toml`, you will need to add your procedurals macros crate as a dependency:

```toml
[workspace]
members = ["my_framework", "my_framework_macros"]

[package]
name = "my_framework"
version = "0.1.0"

[dependencies]
my_framework_macros = { path = "./my_framework_macros" }
```

### Macro Crate Configuration

In the procedural macros Root `Cargo.toml` (`my_framework_macros/`), you will need to configure to be allowed to create macros:

```toml
[package]
name = "my_framework_macros"
version = "0.1.0"

[lib]
proc-macro = true # Allows Procedural Macros

[dependencies]
proc-macro2 = "1.0"

# Additional common dependencies
quote = "1.0" # converts Rust syntax into TokenStream output
syn = { version = "2.0", features = ["full"] } # parses input TokenStream into structured syntax trees
proc-macro-error = "1.0" # Simplifies error reporting within procedural macros
```

### `lib.rs` Setup

```rust
// Requires proc_macro crate
extern crate proc_macro;
use proc_macro::TokenStream;
use proc_macro_error::proc_macro_error;

// Re-export macros for ergonomic access
pub use crate::macros::*;

mod macros {
  use super::*;
  // Macro implementations follow below
}
```

### Advanced Configuration: Span Tracking

For production macros, track source locations with precise span information:

```rust
use proc_macro::Span;
use syn::spanned::Spanned;

// In your macro implementation:
let span = input_tokens.span();
let diagnostics = match some_validation {
  Err(e) => {
    let msg = format!("Validation failed: {}", e);
    // Use span to pinpoint error location in original source
    TokenStream::from(quote::quote_spanned! { span =>
      compile_error!(#msg);
    })
  }
  Ok(_) => TokenStream::new(),
};
```

---

## **Understanding TokenStream and Macro Hygiene**

The `TokenStream` type is central to writing procedural macros and represents a sequence of tokens stripped of semantic meaning. The most effective way to handle TokenStream is by using the community crates syn for parsing input code and quote for generating output code, as directly manipulating tokens can be tedious

> This is *critical*: procedural macros operate on raw syntax without type information.

A `TokenStream` is:

- an opaque
- a clone-able sequence of TokenTree objects
- the input and output type for all procedural macros

### Token Inspection and Manipulation

```rust
extern crate proc_macro;
use proc_macro::TokenStream;

#[proc_macro]
pub fn inspect_tokens(input: TokenStream) -> TokenStream {
  // Iterating over tokens demonstrates low-level access
  for token in input.clone() {
    eprintln!("Token: {:?}", token);
  }

  // Reconstruct TokenStream from tokens
  input
}
```

### Macro Hygiene Considerations

Procedural macros can create hygiene violations if identifiers are not carefully managed:

```rust
extern crate proc_macro;
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

#[proc_macro_derive(Problematic)]
pub fn problematic(input: TokenStream) -> TokenStream {
  let input = parse_macro_input!(input as DeriveInput);
  let name = &input.ident;

  // ❌ HYGIENE VIOLATION: 'x' might collide with user's variable
  quote! {
    impl #name {
      pub fn get_value(&self) -> i32 {
        let x = 42;  // Unqualified identifier
        x
      }
    }
  }.into()
}

#[proc_macro_derive(Hygienic)]
pub fn hygienic(input: TokenStream) -> TokenStream {
  let input = parse_macro_input!(input as DeriveInput);
  let name = &input.ident;

  // ✓ BETTER: Use qualified paths and avoid simple names
  quote! {
    impl #name {
      pub fn get_value(&self) -> i32 {
        const MACRO_INTERNAL_VALUE: i32 = 42;
        MACRO_INTERNAL_VALUE
      }
    }
  }.into()
}
```

---

## **Macro Types**

Procedural macros come in three distinct varieties, each serving different use cases and operating on different syntactic contexts. Understanding the differences is essential for choosing the right macro type for your problem.

### **Function-Like** Macros

Function-like procedural macros provide a bridge between the simplicity of declarative macros and the programmatic power of procedural ones. Unlike declarative macros that use pattern matching, function-like procedural macros execute arbitrary Rust code to transform their input, making them ideal for scenarios requiring complex parsing or conditional logic.

**Creation**:

```rust
#[proc_macro] // Required annotation
pub fn my_macro(input: TokenStream) -> TokenStream{
  ...
}
```

**Invocation**:

```rust
my_macro!(...);
```


#### Key characteristics

- Invoked with `!` syntax, resembling function calls
- Accept arbitrary token streams as input
- Useful for custom domain-specific languages (DSLs), compile-time computations, and syntax sugar
- Less commonly used than derive macros in typical Rust codebases

#### When to use

- Custom DSLs with non-standard syntax
- Compile-time calculations
- Transforming unstructured token patterns into generated code

### **Custom Derive** Macros

Derive macros are the most prevalent macro type in production Rust. They attach to the `#[derive(...)]` attribute on structs, enums, and unions to automatically implement specified traits. This eliminates boilerplate and ensures trait implementations stay synchronized with type definitions.

**Creation**:

```rust
#[proc_macro_derive(MyTrait)] // Required annotation
pub fn my_derive_macro(input: TokenStream) -> TokenStream{
  ...
}
```

**Invocation**:

```rust
#[derive(MyTrait)]
struct MYStruct{
  ...
};
```

#### Key characteristics

- Attached to `#[derive(...)]` annotations
- Generate trait implementations automatically
- Can be paired with custom attributes (like `#[serde(skip)]`) for fine-grained control
- Commonly used in frameworks and libraries to reduce repetitive code

#### How they work

When you add `#[derive(MyTrait)]` to a type, the compiler invokes your procedural macro with the type's abstract syntax tree (AST). Your macro examines the fields, variants, and structure, then generates the appropriate trait implementation code.

**Real-world examples:**

- `serde::Serialize` and `serde::Deserialize` for serialization
- `thiserror::Error` for error types
- `derive_builder::Builder` for fluent construction patterns

#### Deriving Complex Traits: Serialization Example

A practical serialization macro demonstrates the pattern. The macro examines struct fields, respects custom attributes to skip certain fields, and generates a `HashMap`-based serialization method. This approach shows how macros can provide framework-like ergonomics:

```rust
extern crate proc_macro;
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput, Data, Fields, Meta};

#[proc_macro_derive(Serialize, attributes(serde))]
pub fn serialize_derive(input: TokenStream) -> TokenStream {
  let input = parse_macro_input!(input as DeriveInput);
  let name = &input.ident;
  
  let serialize_impl = match &input.data {
    Data::Struct(data) => {
      match &data.fields {
        Fields::Named(fields) => {
          let field_serializations = fields.named.iter().map(|f| {
            let field_name = &f.ident;
            let field_str = field_name.as_ref().unwrap().to_string();
            
            // Check for #[serde(skip)] attribute
            let should_skip = f.attrs.iter().any(|attr| {
              if let Meta::Path(path) = &attr.meta {
                path.is_ident("skip")
              } else {
                false
              }
            });

            if should_skip {
              quote! { /* skip */ }
            } else {
              quote! {
                map.insert(#field_str.to_string(), 
                  format!("{:?}", self.#field_name));
              }
            }
          });

          quote! {
            {
              let mut map = std::collections::HashMap::new();
              #(#field_serializations)*
              map
            }
          }
        },
        _ => quote! { compile_error!("Serialize only supports named fields"); }
      }
    },
    _ => quote! { compile_error!("Serialize only works on structs"); }
  };

  let expanded = quote! {
    impl Serialize for #name {
      fn to_map(&self) -> std::collections::HashMap<String, String> {
        #serialize_impl
      }
    }
  };

  TokenStream::from(expanded)
}

// Required trait definition
pub trait Serialize {
  fn to_map(&self) -> std::collections::HashMap<String, String>;
}
```

**Usage in practice:**

```rust
#[derive(Debug, Serialize)]
pub struct User {
  id: u32,
  name: String,
  email: String,
  #[serde(skip)]
  password_hash: String,  // Not serialized
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_serialization() {
    let user = User {
      id: 1,
      name: "Alice".to_string(),
      email: "alice@example.com".to_string(),
      password_hash: "hashed".to_string(),
    };

    let map = user.to_map();
    assert!(map.contains_key("id"));
    assert!(map.contains_key("name"));
    assert!(!map.contains_key("password_hash"));
  }
}
```

#### Working with Generic Types

Derive macros frequently encounter generic parameters. The `syn` crate provides `split_for_impl()`, which properly fragments generics into their impl, type, and where-clause components:

```rust
#[proc_macro_derive(Display)]
pub fn display_derive(input: TokenStream) -> TokenStream {
  let input = parse_macro_input!(input as DeriveInput);
  let name = &input.ident;
  let (impl_generics, ty_generics, where_clause) = input.generics.split_for_impl();

  let expanded = quote! {
    impl #impl_generics std::fmt::Display for #name #ty_generics #where_clause {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self)
      }
    }
  };

  TokenStream::from(expanded)
}
```

This ensures the generated code respects trait bounds and lifetime parameters, preventing compilation errors in generic contexts.

### Attribute-Like Macros

Attribute-like macros differ fundamentally from derive macros. Rather than implementing traits, they transform entire items, functions, structs, modules, or other declarations, with custom behavior. They provide full visibility into item internals and can rewrite their structure entirely. *See [Topic 3.2.4: Attribute-Like Macros](../Topic_3.2.4:Attribute-Like_Macros/readme.md) for comprehensive coverage*.


---

## **Error Handling and Diagnostics**

Error handling in procedural macros differs significantly from typical Rust code. Since procedural macros are compile-time constructs that cannot return `Result` types, they must communicate failures differently. The standard approach involves using `panic!` to abort compilation, but production-quality macros require more sophisticated strategies that provide clear, actionable error messages to users.

### Error Reporting Strategies

When a procedural macro encounters invalid input, it has two primary mechanisms for signaling errors:

1. **Panic-based errors**: Calling `panic!` halts compilation immediately but produces unhelpful error messages that expose macro internals rather than user-facing problems.

2. **Structured diagnostics**: The `proc_macro_error` crate provides a superior alternative through the `emit_error!` and `abort!` macros, which integrate with Rust's compiler infrastructure to generate error messages that properly pinpoint the source location in user code.

### Source Location Tracking with Spans

Every token in a `TokenStream` carries span information—a reference to its location in the source file. Procedural macros should use these spans when reporting errors to guide developers to the exact problematic code. The `syn` crate's `Spanned` trait provides access to span information:

```rust
use syn::spanned::Spanned;

let span = input.span();  // Get span from parsed input
```

When errors lack proper span information, developers must hunt through their code to find the issue. Accurate spans make debugging trivial.

### Using `proc_macro_error` for Production Quality

The `proc_macro_error` crate enables structured error reporting that feels native to Rust's compiler. Apply the `#[proc_macro_error]` attribute to your macro function, then use `emit_error!` to report non-fatal issues or `abort!` to halt compilation with a fatal error:

```rust
use proc_macro_error::{proc_macro_error, emit_error, abort};
use syn::{parse_macro_input, DeriveInput, Data};

#[proc_macro_derive(Validate)]
#[proc_macro_error]
pub fn validate_derive(input: TokenStream) -> TokenStream {
  let input = parse_macro_input!(input as DeriveInput);
  
  // Fatal error: abort immediately with clear message
  match &input.data {
    Data::Struct(data) => {
      if data.fields.is_empty() {
        abort!(input.span(), "Validate requires at least one field");
      }
    }
    _ => {
      // Non-fatal error: report but continue processing
      emit_error!(input.span(), "Validate only works on structs");
      return TokenStream::new();
    }
  }

  // Implementation continues...
  TokenStream::new()
}
```

The distinction between `emit_error!` and `abort!` is important: `emit_error!` records the issue and allows the macro to return an empty token stream (the compilation will still fail, but other errors may be reported first), while `abort!` immediately stops execution without returning a value.

### Validation Patterns

Effective procedural macros validate their input early and comprehensively. Common validation scenarios include:

- **Structural constraints**: Ensuring the decorated item is a struct, not an enum or union
- **Field requirements**: Verifying fields meet specific criteria (non-empty, specific types, required attributes)
- **Attribute correctness**: Validating that custom attributes like `#[serde(skip)]` are properly formed
- **Type compatibility**: Checking that generic parameters or associated types align with macro expectations

By validating upfront with clear error messages, procedural macros prevent cryptic downstream compilation errors in the generated code itself.

---

## **Advanced Patterns**

### 1. Framework Routing Macros

Used in web frameworks like `axum` and `actix`:

```rust
#[proc_macro_attribute]
pub fn route(args: TokenStream, input: TokenStream) -> TokenStream {
  // Parse route definition (e.g., "GET /api/users/:id")
  // Generate handler registration and routing logic
  TokenStream::new()
}
```

### 2. Compile-Time Validation

```rust
#[proc_macro_derive(ValidateEmail)]
pub fn validate_email(input: TokenStream) -> TokenStream {
  // Validate string literals meet email format at compile time
  TokenStream::new()
}
```

### 3. SQL Query Building

```rust
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
  // Parse SQL at compile time, validate schema, generate type-safe query
  TokenStream::new()
}
```

---

## **Performance Considerations**

- **Compilation time**: Complex macros with heavy parsing impact build times
- **Token stream size**: Large generated code increases final binary size
- **Recursion limits**: Deep macro expansions may hit compiler limits

Optimization strategies:

```rust
// ✓ Cache expensive parse operations
lazy_static::lazy_static! {
  static ref SCHEMA: Schema = parse_schema();
}

// ✓ Generate minimal code, delegate work to runtime
#[proc_macro_derive(Heavy)]
pub fn heavy(input: TokenStream) -> TokenStream {
  let metadata = extract_metadata(input);
  // Generate lightweight struct containing metadata
  // Logic implemented at runtime, not compile time
  TokenStream::new()
}
```

---

## **Professional Applications and Implementation**

Procedural macros power many advanced Rust ecosystem features:

- Automatic trait derivation (serde, thiserror)
- Web framework routing (actix, axum)
- Custom logging and instrumentation
- Compile-time validation and code generation
- Reducing repetitive trait implementations

They are especially valuable in library and framework development, where ergonomics and compile-time guarantees are critical.

---

## **Key Takeaways**

| Concept            | Summary                                                                    |
| ------------------ | -------------------------------------------------------------------------- |
| Procedural Macro   | Function transforming `TokenStream` input into generated Rust code         |
| Crate Requirement  | Must be defined in dedicated `proc-macro = true` crate                     |
| Macro Hygiene      | Avoid identifier collisions; use qualified paths for generated code        |
| Macro Types        | Function-like, derive, and attribute macros with distinct use patterns     |
| Core Tools         | `proc_macro`, `syn`, `quote`, and `proc_macro_error` for production code   |
| Error Handling     | Use `proc_macro_error` crate for structured diagnostics vs `panic!`        |
| Primary Strength   | Enables meta-programming and complex compile-time abstraction              |
| Performance Impact | Monitor compilation time; minimize generated code bloat                    |

- Maintain macro hygiene through careful identifier management
- Provide clear error messages with precise source spans
- Test macros thoroughly with diverse input patterns
- Document expansion behavior with examples
- Prefer simple, focused macros over complex feature-packed implementations
- Consider compile-time cost vs. runtime benefit trade-offs
- Use `proc_macro_error` instead of `panic!` for production quality

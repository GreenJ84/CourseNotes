# **Topic 3.2.4: Attribute-Like Macros**

Attribute-like procedural macros represent one of the most powerful abstractions in Rust's compile-time meta-programming arsenal. They allow developers to declaratively modify code behavior without runtime overhead or performance penalties. They operate on items annotated with a custom attribute. They enable compile-time transformation or augmentation of functions, structs, modules, or other annotated constructs.

Attribute macros are commonly used to inject behavior without modifying the original function logic. This separation preserves clean architecture by keeping cross-cutting concerns outside core business logic. At the senior level, understanding attribute macros requires mastery of token stream manipulation, AST traversal, error handling across compilation stages, and the ability to generate code that integrates seamlessly with existing type systems and trait bounds.

## **Learning Objectives**

- Define attribute-like procedural macros and their purpose within the broader macro ecosystem
- Understand how attribute arguments and annotated items are parsed and transformed at compile time
- Explain how attribute macros modify function bodies while preserving type safety and ownership semantics
- Recognize supporting crates (`syn`, `quote`, `darling`) and their respective roles in macro development
- Evaluate architectural benefits and trade-offs of attribute-driven code generation
- Design attribute macros that handle edge cases, generics, async functions, and complex trait bounds
- Implement proper error handling and diagnostic messages for macro users

---

## **What are Attribute-Like Macros?**

Attribute-like macros represent one of the most powerful abstractions in Rust's compile-time metaprogramming arsenal. They allow developers to declaratively modify code behavior without runtime overhead or performance penalties. Unlike derive macros (which operate on structs, enums, and unions via `#[derive(...)]`), attribute macros can be applied to any item and have direct access to modify their internals.

> Attribute-like macros are Procedural Macro and crate setup is exactly the same as [Crate Setup](../Topic_3.2.3:Procedural_Macros/readme.md)

### Key Characteristics

- Are declared using `#[proc_macro_attribute]` within a dedicated procedural macro crate
- Accept two `TokenStream` parameters:
  - **Attribute arguments**: User-provided configuration passed as `#[macro_name(args)]`
  - **Annotated item**: The complete token stream of the item being decorated
- Parse and transform the annotated item using structured AST representations
- Return a modified `TokenStream` representing the updated code, which the compiler then processes
- Execute during compilation, providing zero-cost abstractions at runtime

They are particularly effective for implementing cross-cutting concerns such as:

- **Logging and tracing**: Automatic instrumentation without manual log calls
- **Metrics and observability**: Counter injection, latency tracking
- **Authentication/Authorization**: Guard clauses and permission validation
- **Async runtime integration**: Task scheduling, cancellation tokens
- **Testing frameworks**: Test discovery, setup/teardown automation
- **API routing**: Framework-specific route definition and validation

### Architectural Distinction from Alternatives

Unlike runtime reflection or trait objects, attribute macros operate at compile time, enabling:

- **Zero-cost abstractions**: No runtime dispatch overhead
- **Compile-time validation**: Catch configuration errors before deployment
- **Type-safe transformations**: Leverage Rust's type system during code generation
- **Optimizable code**: Generated code is eligible for inlining and other compiler optimizations

### Example: Structured Logging Without Boilerplate

*Goal:* Automatically log function calls with parameter values, return values, and execution time without embedding logging logic directly in the function body.

*Implementation:*

```rust
#[log_call(level = "debug", include_result = true)]
fn purchase_product(customer: &Customer, product: &Product, quantity: u32) -> Result<String, String> {
    // Business logic only — no inner logging boilerplate
}

// Calling the function
let customer = Customer { ... };
let product = Product { ... };
let _ = purchase_product(&customer, &product, 2);
```

The attribute macro injects logging behavior at compile time, resulting in generated code that:

1. Logs the function entry with parameter values
2. Measures execution time
3. Logs the function exit with the result
4. All without modifying the original function body

---

## **Entry Point**

The Entry Point is where you first receive the raw `TokenStream`s

```rust
use proc_macro::TokenStream;
use syn::{parse_macro_input, ItemFn};
use quote::quote;

#[proc_macro_attribute]
pub fn log_call(args: TokenStream, input: TokenStream) -> TokenStream {
    let attr_args = parse_macro_input!(args as syn::LitStr);
    let mut input_fn = parse_macro_input!(input as ItemFn);
    
    // Transformation logic here
    
    quote! { #input_fn }.into()
}
```

### Key details

- `args`:
  - token stream of content inside `#[log_call(...)]`. This is the raw token stream passed by the user, such as `level = "debug", include_result = true`. It must be parsed into a structured type to extract configuration values.
- `input`:
  - token stream representing the entire annotated function, including its signature, generics, body, and attributes. It contains all syntactic information about the function being decorated.
- Both require explicit parsing via `parse_macro_input!` macro or manual `syn::parse` calls. The `parse_macro_input!` helper automatically converts parsing errors into compile errors that point to the user's code.
- The return type is always `TokenStream` destined for the compiler. This token stream represents the transformed function code that will replace the original annotated function in the compilation process.

---

## **Advanced Attribute Arguments Parsing with darling**

For complex attribute arguments, `darling` provides a derive-based approach that's more ergonomic than manual token stream parsing:

```rust
use darling::FromMeta;

#[derive(FromMeta, Debug)]
struct LogCallArgs {
    #[darling(default)]
    level: Option<String>,
    
    #[darling(default)]
    include_result: bool,
    
    #[darling(default)]
    include_time: bool,
}

#[proc_macro_attribute]
pub fn log_call(args: TokenStream, input: TokenStream) -> TokenStream {
    let attr_args = match darling::ast::NestedMeta::parse_meta_list(args.clone()) {
        Ok(v) => v,
        Err(e) => return TokenStream::from(e.write_errors()),
    };
    
    let args = match LogCallArgs::from_list(&attr_args) {
        Ok(v) => v,
        Err(e) => return TokenStream::from(e.write_errors()),
    };
    
    let mut input_fn = parse_macro_input!(input as ItemFn);
    
    impl_log_call(&args, &mut input_fn)
        .unwrap_or_else(|err| err.to_compile_error().into())
}
```

### Usage examples

```rust
// Minimal usage with defaults
#[log_call]
fn simple_operation() { }

// With specific log level
#[log_call(level = "debug")]
fn debug_operation() { }

// Multiple arguments
#[log_call(level = "warn", include_result = true, include_time = true)]
fn complex_operation() -> Result<String, String> { Ok("done".into()) }
```

### Advantages of darling

- Type-safe attribute parsing with compile-time validation. Each field in the struct corresponds to an attribute parameter, and `FromMeta` enforces that provided values match expected types (e.g., string literals for `String` fields, boolean literals for `bool` fields).
- Derives support nested structures, defaults, and custom containers. You can define defaults via `#[darling(default)]`, allowing optional parameters that become `None` or use default values when omitted by the user.
- Error messages originate from the macro usage site (user's code), not the macro implementation. This makes debugging significantly easier for macro consumers.
- Integrates seamlessly with procedural macro error handling. Errors convert directly to compiler diagnostics that point users to the exact location in their code where they misused the macro.

---

## **Parsing the Annotated Function**

```rust
use syn::{ItemFn, FnArg, Pat, Ident, Error, Result as SynResult};

let mut input_fn = parse_macro_input!(input as ItemFn);

// Access function components
let fn_name = &input_fn.sig.ident;
let fn_visibility = &input_fn.vis;
let fn_generics = &input_fn.sig.generics;
let fn_inputs = &input_fn.sig.inputs;
let fn_output = &input_fn.sig.output;
let fn_asyncness = input_fn.sig.asyncness;
let fn_body = &mut input_fn.block;
```

### `syn::ItemFn`

This structure provides structured access to all function components:

- **Signature** (`sig`): Contains visibility, asyncness, generics, trait bounds, parameters, return type. You extract the function's public/private visibility, whether it's `async`, its generic type parameters `<T>`, any `where` clauses, and the return type (`-> ReturnType` or omitted for unit return).
- **Body** (`block`): The statements composing the function implementation. This is a `Block` containing a `Vec<Stmt>`, allowing you to insert logging statements, wrap expressions, or completely restructure the function body while preserving the original logic.
- **Attributes** (`attrs`): Outer attributes applied to the function, such as `#[doc = "..."]` or other decorators. These are preserved automatically when you return the modified `ItemFn`.

This enables safe, ergonomic manipulation without string-based code generation. Instead of parsing raw tokens or manipulating source code strings, you work with strongly-typed AST nodes that guarantee syntactic correctness and offer compile-time safety.

---

## **Advanced Argument Extraction with Generics**

When working with functions containing generic type parameters and trait bounds, attribute macros must carefully preserve these during transformation to maintain type safety and correctness.

### Extracting Generic Parameters

Generic parameters appear in the function signature and must be carried through to the transformed output:

```rust
fn extract_generic_params(func: &ItemFn) -> Vec<syn::GenericParam> {
    func.sig.generics.params.iter().cloned().collect()
}
```

This retrieves all generic parameters (type parameters, lifetime parameters, and const generics) defined on the function.

### Extracting Where Clauses

Where clauses impose additional trait bounds on generic parameters. They must be preserved to ensure the transformed code maintains the same constraints:

```rust
fn extract_where_predicates(func: &ItemFn) -> Vec<syn::WherePredicate> {
    func.sig
        .generics
        .where_clause
        .as_ref()
        .map(|wc| wc.predicates.iter().cloned().collect())
        .unwrap_or_default()
}
```

### Practical Example: Preserving Generics in Transformation

Consider a function with generic type parameters and trait bounds:

```rust
#[log_call(level = "debug")]
fn process_data<T: Clone + Debug>(item: T) -> T
where
    T: Sized,
{
    let result = item.clone();
    result
}
```

The macro must preserve `<T: Clone + Debug>` and the `where T: Sized` clause, or the transformed code will fail compilation. The transformation mechanism passes generics into the `quote!` invocation:

```rust
let generics = &input_fn.sig.generics;
let fn_output = &input_fn.sig.output;
let transformed_body = &input_fn.block;

// Generics are inserted into the quoted output
let generated = quote! {
    fn #fn_name #generics -> #fn_output {
        // logging statements...
        #transformed_body
    }
};
```

This approach ensures that generic parameters, their bounds, and where clauses are reproduced identically in the generated code, maintaining full type safety and compiler-enforced correctness.


---

## **Core Transformation Logic**

Once the entry point has parsed the attribute arguments (via `darling`) and the annotated function (via `syn`), both are handed off to `impl_log_call`. This is where the actual AST transformation happens — `impl_log_call` is not required by the compiler, but it is the conventional pattern for separating concerns: the `#[proc_macro_attribute]` entry point handles parsing and error propagation, while `impl_log_call` owns the transformation logic.

### Full Execution Flow

```text
User writes:  #[log_call(level = "debug", include_result = true)]
                         fn purchase_product(...) -> Result<...> { ... }

Entry point:  pub fn log_call(args, input)
              │
              ├─ darling parses args     →  LogCallArgs { level: "debug", include_result: true }
              ├─ syn parses input        →  ItemFn (structured AST of the function)
              │
              └─ calls impl_log_call(&args, &mut input_fn)
                         │
                         ├─ Step 1: extract_arg_idents()     →  [customer, product, quantity]
                         ├─ Step 2: generate_entry_log()     →  log::debug!("Entering purchase_product...")
                         ├─ Step 3: insert into block.stmts  →  injected as first statement in function body
                         └─ Step 4: wrap_return_statements() →  every `return` rewritten to log before exiting

Compiler receives the modified TokenStream and compiles it as if you had written the logging by hand
```

> Each step in transformation logic (commonly) corresponds to an independent helper function

### Transformation impl for log_call

`impl_log_call` receives the already-parsed, strongly-typed data — it never sees raw `TokenStream`s. Its job is purely to read the config (`LogCallArgs`) and mutate the function AST (`ItemFn`) by calling helpers in sequence:

```rust
fn impl_log_call(
    attr_args: &LogCallArgs,
    input: &mut ItemFn,       // the function AST, passed as mutable so we can modify it in place
) -> syn::Result<TokenStream> {
    let fn_name = &input.sig.ident;
    let fn_name_str = fn_name.to_string();
    let is_async = input.sig.asyncness.is_some();
    
    // Resolve the log level from the attribute args, defaulting to "info"
    let level = attr_args.level.as_deref().unwrap_or("info");

    // Step 1 — collect the function's parameter names so we can log their values
    let arg_names = extract_arg_idents(input)?;

    // Step 2 — generate the entry log statement (e.g. log::debug!("Entering purchase_product..."))
    let entry_log = generate_entry_log(&fn_name_str, level, &arg_names);

    // Step 3 — inject the entry log as the very first statement in the function body
    input.block.stmts.insert(0, entry_log);

    // Step 4 — if include_result = true, rewrite every `return` to log the value before it exits
    if attr_args.include_result {
        wrap_return_statements(input, level)?;
    }

    // Return the modified function as a TokenStream — this replaces the original in the binary
    Ok(quote! { #input }.into())
}
```

#### Step 1 — `extract_arg_idents`: Collect Parameter Names

Before generating any log statements, we need the names of the function's parameters so we can print their values. You might think you could just use the parameter list directly — but Rust function parameters are *patterns*, not plain names. A parameter like `(a, b): (i32, i32)` is valid syntax. This helper filters to only simple identifier patterns and returns an error for anything more complex:

```rust
fn extract_arg_idents(func: &ItemFn) -> syn::Result<Vec<Ident>> {
    func.sig
        .inputs           // the list of parameters
        .iter()
        .filter_map(|arg| {
            if let FnArg::Typed(pat_type) = arg {       // skip `self`
                match &*pat_type.pat {
                    Pat::Ident(pat_ident) => Some(Ok(pat_ident.ident.clone())),  // simple name → keep
                    _ => Some(Err(Error::new_spanned(                            // complex pattern → error
                        arg,
                        "Only simple identifiers are supported in log_call macro",
                    ))),
                }
            } else {
                None  // `self` → skip
            }
        })
        .collect()  // Vec<Ident> if all Ok, or the first Err bubbled up via ?
}
```

The `?` operator in `impl_log_call` propagates any error as a compile-time diagnostic pointing at the offending parameter in the user's code.

---

### Step 2 — `generate_entry_log`: Build the Log Statement

With the parameter names collected, this function generates the actual `log::debug!(...)` or `log::info!(...)` statement as a `syn::Stmt` (an AST node, not a string). The generated code uses `stringify!` to embed the parameter name and `{:?}` to print its value at runtime:

```rust
fn generate_entry_log(fn_name: &str, level: &str, args: &[Ident]) -> syn::Stmt {
    // For each parameter, generate: format!("customer={:?}", &customer)
    let args_debug = args.iter().map(|arg| {
        quote! {
            format!("{}={:?}", stringify!(#arg), &#arg)
        }
    });
    
    // Select the correct log macro based on the configured level
    let log_statement = match level {
        "debug" => quote! {
            log::debug!(
                "Entering {} with args: [{}]",
                #fn_name,
                vec![#(#args_debug),*].join(", ")
            );
        },
        "info" => quote! {
            log::info!(
                "Entering {} with args: [{}]",
                #fn_name,
                vec![#(#args_debug),*].join(", ")
            );
        },
        _ => quote! {
            println!(
                "[{}] Entering {} with args: [{}]",
                #level,
                #fn_name,
                vec![#(#args_debug),*].join(", ")
            );
        },
    };
    
    // parse_quote! converts the token stream into a syn::Stmt that can be inserted into the AST
    syn::parse_quote! { #log_statement }
}
```

> The return type `syn::Stmt` is important: it means `impl_log_call` can insert this directly into `input.block.stmts` (the function's statement list) as a typed AST node.

---

### Step 3 — Inject into the Function Body

This happens directly inside `impl_log_call` (not a separate helper function). It is not a separate function. `input.block.stmts` is a `Vec<Stmt>` representing every statement in the function body. Inserting at index `0` places the log call before any existing code:

```rust
input.block.stmts.insert(0, entry_log);
```

After this line, the user's function body effectively becomes:

```rust
fn purchase_product(customer: &Customer, product: &Product, quantity: u32) -> Result<String, String> {
    log::debug!("Entering purchase_product with args: [customer={:?}, product={:?}, quantity={:?}]", ...);
    // original body follows...
}
```

### Step 4 — Handle Exit Logging

Logging on entry is straightforward. Logging on exit is harder, because a function can `return` from multiple places, and an `async` function's body must be handled differently from a synchronous one.


#### `wrap_async_body`

**For async functions**, the entire original body is replaced with a wrapper that awaits it and captures the result:

```rust
fn wrap_async_body(
    func: &mut ItemFn,
    fn_name: &str,
    level: &str,
) -> syn::Result<()> {
    if func.sig.asyncness.is_none() {
        return Ok(());  // nothing to do for sync functions
    }
    
    // Pull out the original body and replace it with an empty block temporarily
    let original_body = Box::new(
        std::mem::replace(&mut *func.block, syn::parse_quote! { {} })
    );
    
    // Rebuild the body: log entry → await original → log exit → return result
    func.block = syn::parse_quote! {
        {
            log::#level!("Entering async {}", #fn_name);
            let result = async {
                #original_body
            }.await;
            log::#level!("Exiting async {} with result: {:?}", #fn_name, result);
            result
        }
    };
    
    Ok(())
}
```

#### `ReturnStatementWrapper`

**For synchronous functions with `include_result = true`**, `ReturnStatementWrapper` walks the entire AST using `syn::fold::Fold` (a visitor pattern) and rewrites every `return expr` it finds. This is necessary because a function may have many early return points, and simply appending to the end would miss them:

```rust
use syn::fold::Fold;

struct ReturnStatementWrapper {
    fn_name: String,
    level: String,
}

impl Fold for ReturnStatementWrapper {
    fn fold_stmt(&mut self, node: syn::Stmt) -> syn::Stmt {
        // Check if this statement is a `return <expr>` expression
        if let syn::Stmt::Expr(syn::Expr::Return(ret), _) = &node {
            let fn_name = self.fn_name.as_str();
            let level_ident: syn::Ident = syn::parse_str(&self.level).unwrap();
            
            if let Some(expr) = &ret.expr {
                // Rewrite `return expr` → capture value, log it, then return it
                return syn::parse_quote! {
                    {
                        let __result = #expr;
                        log::#level_ident!("Exiting {} with result: {:?}", #fn_name, __result);
                        return __result;
                    }
                };
            }
        }
        
        // For all other statements, recurse into them unchanged
        syn::fold::fold_stmt(self, node)
    }
}
```

The `Fold` trait recursively visits every node in the AST. `fold_stmt` is called for each statement and if it is a `return`, it gets rewritten; everything else is passed through by the default `syn::fold::fold_stmt` call at the bottom.

---

## **Supporting Crates and Their Roles**

### syn: Structured Token Stream Parsing

`syn` provides an extensible parser for Rust syntax, converting untyped `TokenStream`s into strongly-typed AST nodes:

```rust
// Without syn (manual token parsing—error-prone and verbose)
let tokens = input.into_iter().collect::<Vec<_>>();
// ... hundreds of lines of manual token matching

// With syn (type-safe and concise)
let parsed: ItemFn = syn::parse2(input)?;
// or
let mut input_fn = parse_macro_input!(parsed as ItemFn);
```

#### Key types for attribute macro development

- `ItemFn`: Function definitions with signature and body
- `FnArg`: Function parameters (typed or `self` variants)
- `Generics`: Type parameters and where clauses
- `Ident`: Identifiers (function/variable names)
- `Stmt`: Statements (expressions, declarations, items)
- `Expr`: Expressions of all varieties

#### Features Configuration

- Default features are minimal but sufficient for most macros
- Use `features = ["full"]` to enable parsing of all Rust syntax
- Parsing specific items (e.g., only `ItemStruct`) doesn't require `"full"`

### quote: Type-Safe Code Generation

`quote!` macro generates Rust code programmatically while maintaining type safety and hygiene:

```rust
use quote::quote;

let fn_name = syn::parse_str::<syn::Ident>("my_function")?;
let param_count = 3;

// Variable interpolation with #identifier
let generated = quote! {
    fn #fn_name() {
        println!("This function has {} parameters", #param_count);
    }
};

// Produces: fn my_function() { println!("This function has {} parameters", 3); }
```

#### Advanced usage patterns

```rust
// Iterating over collections
let fields = vec!["a", "b", "c"];
let quoted = quote! {
    struct MyStruct {
        #(#fields: i32,)*
    }
};

// Conditional code generation
let add_doc = true;
let doc_comment = add_doc
    .then(|| quote! { #[doc = "Auto-generated"] })
    .unwrap_or_default();

let result = quote! {
    #doc_comment
    fn generated() {}
};

// Generic type parameter preservation
let generics = &input_fn.sig.generics;
let output = quote! {
    fn wrapper #generics() { }
};
```

> **Hygiene considerations:** `quote!` automatically generates unique identifiers for generated code to avoid name collisions. For intentional name reuse, explicit identifier construction is required using `syn::Ident::new()`.

### darling: Declarative Attribute Parsing

`darling` uses derive macros to parse procedural macro attributes declaratively:

```rust
use darling::FromMeta;

#[derive(FromMeta)]
#[darling(default)]
struct MacroArgs {
    level: Option<String>,
    
    #[darling(default)]
    include_result: bool,
    
    #[darling(rename = "skip_args")]
    skip_arguments: bool,
}

// Supports nested structures
#[derive(FromMeta)]
struct LoggingConfig {
    level: String,
    format: String,
}

#[derive(FromMeta)]
struct AdvancedArgs {
    logging: LoggingConfig,
    
    #[darling(default)]
    enabled: bool,
}
```

*Usage:*

```rust
#[log_call(level = "debug", include_result = true)]
fn my_function() { }

#[log_call(
    logging(level = "info", format = "json"),
    enabled = true
)]
fn another_function() { }
```

---

## **Professional Applications and Real-World Patterns**

Attribute-like macros are heavily used in:

- Web frameworks for route definitions
- Async runtimes for task annotations
- Logging and tracing instrumentation
- Validation layers
- Authorization and authentication wrappers
- Testing frameworks

They enable separation of concerns by injecting behavior without polluting core logic, supporting cleaner architecture and improved maintainability

---

## **Key Takeaways**

| Concept              | Summary                                                                        |
| -------------------- | ------------------------------------------------------------------------------ |
| Attribute Macro      | Procedural macro applied via `#[attribute]` syntax to any Rust item.           |
| Compile-Time Power   | Transforms code during compilation; zero-cost at runtime.                      |
| Token Stream Flow    | Args and item both provided as token streams; requires explicit parsing.       |
| Transformation       | Use `syn` for parsing, modify AST, use `quote!` to generate updated code.      |
| Argument Parsing     | `darling` enables declarative, type-safe attribute argument extraction.        |
| Error Handling       | Return compile errors via `Error::to_compile_error()` for user diagnostics.    |
| Generics Support     | Preserve generic parameters and where clauses during transformation.           |
| Async Compatibility  | Handle `async` functions specially; wrap bodies appropriately.                 |
| Real-World Usage     | Prevalent in frameworks (web, async, testing) for cross-cutting concerns.      |
| Best Practices       | Keep transformation logic pure; emit clear diagnostics; test thoroughly.       |

- Attribute macros are compile-time transformations that inject behavior without modifying function source
- Proper error handling at the macro boundary ensures excellent user experience
- Advanced patterns require careful handling of generics, async code, and complex patterns
- `syn` + `quote` + `darling` form the canonical macro development stack
- Understanding token stream manipulation is essential for senior-level macro development
- Attribute macros enable architectural patterns impossible at runtime without performance costs

# **Topic 1.4.1: Project Structure**

This topic explains the foundational building blocks of Rust project organization: packages, crates, and modules. It establishes how Cargo structures projects, how executables and libraries are produced, and how modular boundaries are defined. These concepts form the backbone of scalable Rust development and are critical for understanding dependency management, compilation units, and code reuse.

## **Learning Objectives**

- Distinguish between packages, crates, and modules and understand their hierarchical relationships
- Understand how Cargo organizes Rust projects and manages compilation boundaries
- Identify differences between binary and library crates and their compilation implications
- Create and structure projects using Cargo commands with intentional architectural patterns
- Apply module organization principles that scale to enterprise-level codebases
- Implement visibility controls and encapsulation through modules and re-exports
- Design crate boundaries for optimal dependency management and code reusability

---

## **Packages**

A **package** is a top-level Cargo concept that groups one or more crates together to provide a cohesive set of functionality. Packages are defined and managed through Cargo and serve as the unit for building, testing, and sharing Rust code.

### Key characteristics

- Contains **one or more crates**
- Defined by a `Cargo.toml` file (the package manifest)
- Must contain **at least one crate**
  - At most **one library crate** (prevents diamond dependency issues and maintains clear ownership)
  - Any number of **binary crates** (enables tools and CLIs)
- Defines dependencies, metadata, and build configuration
- Compilation targets are scoped at the package level

### Creating a new package

```bash
cargo new my_project
```

This creates a binary package by default with the following structure:

```text
my_project/
├── Cargo.toml
├── Cargo.lock (generated after first build)
└── src/
    └── main.rs
```

### `Cargo.toml` file

- defines package metadata, dependencies, and build configuration:

```toml
[package]
name = "my_project"
version = "0.1.0"
edition = "2021"
rust-version = "1.70"
authors = ["Your Name"]
description = "A brief description"
license = "MIT"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }

[dev-dependencies]
criterion = "0.5"

[build-dependencies]
cc = "1.0"
```

### Advanced package patterns

Packages scale from simple single-crate projects to complex monorepos. Understanding package boundaries prevents compilation unit bloat and enables parallel compilation.

**Module Directory Example (Package Level):**

```text
my_project/
├── Cargo.toml
├── Cargo.lock
├── build.rs                    # Build script executed before compilation
├── src/
│   ├── main.rs                # Binary entrypoint
│   ├── lib.rs                 # Library root (optional in binary packages)
│   ├── config.rs              # Top-level module
│   ├── utils/
│   │   ├── mod.rs             # Module declaration and re-exports
│   │   ├── helpers.rs
│   │   └── formatting.rs
│   └── data/
│       ├── mod.rs
│       ├── models.rs
│       └── serialization.rs
├── tests/
│   └── integration_test.rs    # Integration tests
└── examples/
    └── basic_usage.rs         # Runnable examples
```

---

## **Crates**

A **crate** is a compilation unit in Rust and represents a tree of modules that produces either:

- **Binary crate**: Produces an **executable** (binary)
- **Library crate**: Provides functionality for other programs to use (rlib, staticlib, cdylib, or dylib)


### Rust Crates vs Rust Packages

| Feature | Crate | Package |
| --------- | ------- | --------- |
| **Definition** | Unit of compilation | Collection of crates |
| **File** | Root module file | `Cargo.toml` manifest |
| **Quantity** | One per crate | Can contain multiple crates |
| **Purpose** | Reusable code unit | Project management structure |
| **Example** | `lib.rs` or `main.rs` | A Cargo project directory |

A package can contain multiple crates. By default, a package contains:

- One **library crate** (optional, defined by `src/lib.rs`)
- One or more **binary crates** (optional, defined by `src/main.rs` or files in `src/bin/`)

### Crate visibility and privacy rules

- Private items are visible only within the crate
- Public items (`pub`) are visible to dependent crates
- Module-level visibility (`pub(crate)`, `pub(super)`) provides fine-grained control
- The crate root (`lib.rs` or `main.rs`) defines what's publicly exported

---

## **Binary Crates**

A **binary crate** produces an executable program.

### Characteristics

- Produces a runnable executable (platform-specific)
- Requires a `main.rs` file at `src/main.rs`
- Must define a `fn main()` with no parameters or return type
- Created by default with `cargo new`
- Cannot be depended on by other crates (no public API surface)
- Panic behavior and unwinding are controlled at the binary level

### Creating a Binary package

```bash
cargo new my_bin
```

**Example `src/main.rs`:**

```rust
fn main() {
    println!("Hello, Rust!");
}
```

**Resulting structure:**

```text
my_bin/
├── Cargo.toml
├── Cargo.lock
├── src/
│   ├── main.rs
...
```


### Multiple binary crates in a single package

```text
src/
├── main.rs              # Creates executable named after package
└── bin/
    ├── admin.rs         # Creates executable "admin"
    ├── worker.rs        # Creates executable "worker"
    └── migrator.rs      # Creates executable "migrator"
```

Build and run specific binaries:

```bash
cargo build --bin admin
cargo run --bin worker
cargo build --release --bin migrator
```

### Advanced binary crate example

```rust
// src/bin/cli_tool.rs
use std::env;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    
    if args.len() < 2 {
        eprintln!("Usage: cli_tool <command>");
        process::exit(1);
    }
    
    match args[1].as_str() {
        "init" => initialize(),
        "run" => execute(),
        _ => {
            eprintln!("Unknown command: {}", args[1]);
            process::exit(1);
        }
    }
}

fn initialize() {
    println!("Initializing...");
}

fn execute() {
    println!("Executing...");
}
```

---

## **Library Crates**

A **library crate** produces reusable functionality intended to be consumed by other Rust code (both internal and external crates).

### Characteristics

- Produces a library artifact (not an executable)
- Requires a `lib.rs` file at `src/lib.rs`
- Can be depended on by other crates (defines public API)
- Created with `cargo new --lib`
- Compiled once per dependency graph (reduces binary size and compile time)
- Public APIs form explicit contracts with consumers
- Panic and unwinding behavior can be controlled at library level

### Creating a library package

```bash
cargo new my_library --lib
```

**Example `src/lib.rs`:**

```rust
// Public API
pub mod models;
pub mod api;
mod internal;  // Private module

/// Public function in the library's root
pub fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}
```

**Resulting structure:**

```text
my_library/
├── Cargo.toml
├── Cargo.lock
├── src/
│   ├── lib.rs               # Library root and public API
└── tests/
    └── lib_test.rs
```

---

## **Using a library in a binary**

```rust
// In a dependent crate or src/main.rs
use my_library::{greet, validate_email, User, Client};

fn main() -> Result<(), String> {
    println!("{}", greet("World"));
    
    validate_email("user@example.com")?;
    
    let user = User::new(1, "Alice".to_string(), "alice@example.com")?;
    println!("Created: {:?}", user);
    
    let client = Client::new("https://api.example.com".to_string());
    let fetched_user = client.get_user(1)?;
    println!("Fetched: {:?}", fetched_user);
    
    Ok(())
}
```

### Mixed packages

```text
src/
├── lib.rs                   # Library API
├── main.rs                  # Binary using lib
├── models.rs
└── handlers.rs
```

The binary can depend on the library's public API:

```rust
// src/main.rs
use my_package::models::User;

fn main() {
    let user = User::new(1, "Bob".to_string(), "bob@example.com")
        .expect("Failed to create user");
    println!("{:?}", user);
}
```

---

## **Professional Applications and Implementation**

Understanding Rust's project structure is essential for real-world development. Packages define distribution and organizational boundaries, crates define compilation units and expose public APIs, and modules enforce architectural clarity and enforce encapsulation.

**Enterprise patterns:**

1. **Monorepo workspaces** - Multiple packages sharing dependencies and build configuration
2. **Layered architecture** - Separating API, domain, and infrastructure concerns
3. **Feature flags** - Conditional compilation for optional functionality
4. **Public API surface** - Careful re-exports and visibility to maintain stable contracts
5. **Dependency management** - Clear crate boundaries prevent circular dependencies

**Performance considerations:**

- Compilation time scales with crate count; merge micro-crates when possible
- Library crates are compiled once per project; binary crates can be expensive to rebuild
- The crate graph determines parallelization during compilation
- Visibility controls allow incremental rebuilds of dependent code

These concepts enable teams to build maintainable systems, share reusable libraries internally or publicly, scale projects without sacrificing readability or safety, and manage complexity in enterprise codebases.

---

## **Key Takeaways**

| Concept        | Summary                                                                          |
| -------------- | -------------------------------------------------------------------------------- |
| Packages       | Top-level units managed by Cargo that group crates and metadata.                 |
| Crates         | Compilation units that produce executables or libraries with defined APIs.       |
| Binary Crates  | Runnable programs requiring `main.rs` and `fn main`; cannot be depended on.      |
| Library Crates | Reusable code units defined in `lib.rs` with public API surface.                 |
| Modules        | Organizational tools controlling scope, structure, visibility, and privacy.      |

- Cargo enforces consistent project conventions and manages compilation
- Packages may contain multiple binary crates but only one library crate per package
- Crates are the unit of compilation; minimizing count improves build times
- Modules enable scalable, maintainable code organization and enforce encapsulation
- Visibility controls (`pub`, `pub(crate)`, `pub(super)`) are critical to API design
- Re-exports via `pub use` create clean public APIs while hiding internal structure
- Proper project structure is foundational for professional Rust development at scale
- Clear module boundaries prevent circular dependencies and enable parallel compilation

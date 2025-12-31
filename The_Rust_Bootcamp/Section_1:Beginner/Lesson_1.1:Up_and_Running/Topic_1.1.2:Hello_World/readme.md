# **Topic 1.1.2: Hello World**

This topic introduces the fundamental structure and execution model of a Rust application using Cargo. By creating and running a minimal program you see the base from which Rust projects are scaffolded, how source code is organized, and how compilation and execution are managed through the build system. This serves as the first concrete interaction with Rust’s tooling and reinforces the language’s explicit, compile-first workflow.

## **Learning Objectives**

- Create a new Rust project using Cargo
- Understand the default project layout and file responsibilities
- Examine the `Cargo.toml` manifest and its role in dependency management
- Write and execute a minimal Rust program
- Differentiate between building and running Rust binaries

---

## **Project Creation and Navigation**

Rust projects are created and managed using Cargo.

### Creating a Binary Crate

Binary crates produce executable programs.

```bash
cd [intended_directory]
cargo new hello_world # Creates new rust binary
cd hello_world # Change directory into new binary source
code . # Open in default IDE
```

- `cargo new hello_world`
  - Creates a new binary crate named `hello_world`
  - Initializes a Git repository (unless disabled)
  - Generates a standard Rust project structure

- Opening the directory in an editor exposes the project scaffold.

### Creating a Library Crate

Library crates provide reusable code that other projects can depend on. Libraries are created similarly to binaries but use the `--lib` flag.

```bash
cd [intended_directory]
cargo new --lib math_lib # Creates new rust library
cd math_lib
code .
```

- `cargo new --lib math_lib`
  - Creates a new library crate named `math_lib`
  - Generates `src/lib.rs` instead of `src/main.rs`
  - No executable entry point

### Key Differences: Binaries v Libraries

| Aspect        | Binary (`main.rs`)      | Library (`lib.rs`)           |
| ------------- | ----------------------- | ---------------------------- |
| Entry Point   | `main()` function       | Public functions and types   |
| Execution     | Runs as standalone app  | Used as a dependency         |
| Creation      | `cargo new <name>`      | `cargo new --lib <name>`     |
| Output        | Executable binary       | Compiled library (`.rlib`)   |


---

## **Cargo.toml**

`Cargo.toml` is the project’s manifest file and defines metadata, dependencies, and build configuration.

```toml
[package] # metadata
name = "hello_world"
version = "0.1.0"
edition = "2021"

[dependencies]
```

- **Package metadata**

  - `name`: Crate identifier
  - `version`: Semantic versioning
  - `edition`: Rust language edition (e.g., 2018, 2021)

- **Dependencies section**

  - External crates are declared here
  - Cargo resolves and fetches them automatically

> Advanced Insight:
> The Rust edition controls language features and defaults without breaking backward compatibility. Most modern projects use the 2021 edition.

---

## **Source Directory Structure**

All Rust source code resides in the `src` directory. This is the standard location for binary and library code in Cargo projects.

- **`src/` directory**
  - Contains all source files for the crate
  - Cargo expects `main.rs` or `lib.rs` (library crate) at this level
  - Subdirectories organize modules and additional code

Common configurations:

- **`src/main.rs`** – Entry point for binary crates
- **`src/lib.rs`** – Entry point for library crates (alternative to `main.rs`)
- **`src/bin/`** – Multiple binary targets in a single project
- **`src/modules/`** – Organized module files (optional, project-dependent)

---

## **The `main.rs` File**

`main.rs` is the entry point for executable (binary) Rust projects. It contains the `main` function where program execution begins.

Default contents:

```rs
fn main() {
    println!("Hello, world!");
}
```

- `fn main()`
  - Program entry point
  - Executes when the binary is run
  - Takes no parameters and returns nothing

- `println!`
  - A macro (not a function) for printing to standard output
  - Macros are invoked with `!`
  - Outputs text followed by a newline

> Advanced Insight:
> Macros operate on syntax rather than values and are expanded at compile time, enabling capabilities not possible with functions alone.

---

## **The `lib.rs` file**

Library crates expose public functions and types for external consumption:

```rs
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

- `pub` keyword makes items publicly accessible
- Library code is compiled as a dependency, not executed directly
- Other projects import and use library functions via `Cargo.toml`

---

## **Execution and Build Workflow**

Cargo provides multiple ways to compile and run Rust programs.

### Running the Program

```bash
cargo run
```

- Compiles the project (if needed)
- Executes the resulting binary
- Combines build and run into a single command

### Building the Program (development)

```bash
cargo build
```

- Compiles the project without running it
- Output binary is placed in `target/debug/`

### Building the Program (production)

```bash
cargo build --release
```

- Produces optimized binaries in `target/release/`

> Advanced Insight:
> Cargo caches compiled dependencies, significantly reducing build times as projects grow. This design enables fast iteration even in large codebases.

---

## **Professional Applications and Implementation**

Understanding Cargo’s project structure and execution model is essential for all Rust development. Whether building command-line tools, services, or libraries, developers rely on Cargo for reproducible builds, dependency management, and automation. Mastery of these fundamentals enables seamless transitions into testing, documentation, benchmarking, and multi-crate systems.

---

## **Key Takeaways**

| Area             | Summary                                                            |
| ---------------- | ------------------------------------------------------------------ |
| Project Creation | Cargo scaffolds Rust projects with a standard, predictable layout. |
| Manifest         | `Cargo.toml` defines metadata, dependencies, and configuration.    |
| Entry Point      | `main.rs` contains the program’s execution starting point.         |
| Execution        | `cargo run` builds and runs binaries in one step.                  |
| Builds           | Debug and release profiles support development and production use. |

- Introduces Cargo-driven Rust workflows
- Demonstrates the structure of a minimal Rust application
- Establishes compilation-first development habits
- Forms the basis for all future Rust projects in the course

# **Lesson 1.1: Up and Running**

This lesson introduces the foundational mechanics of working with Rust, covering environment setup, basic program structure, and the core language constructs required to write and reason about simple Rust programs. It establishes familiarity with Rust’s syntax, compilation model, and strictness around types and mutability, setting expectations for how Rust code is written, compiled, and executed. These fundamentals serve as the entry point for understanding Rust’s safety guarantees and explicit design philosophy.

## **Learning Objectives**

- Install and configure the Rust toolchain using `rustup`
- Understand the structure and compilation flow of a Rust program
- Define and use variables with explicit mutability and shadowing
- Work with Rust’s primitive and compound data types
- Differentiate between constants, statics, and variables
- Write functions and apply basic control flow constructs
- Use comments effectively for clarity and maintainability

---

## **Topics**

### Topic 1.1.1: Setup

- Rust toolchain components (`rustc`, `cargo`, `rustup`)
- Stable vs nightly channels and update management
- Creating and running projects with Cargo
- Build artifacts, compilation targets, and profiles

### Topic 1.1.2: Hello World

- Minimal Rust program structure
- The `main` function as the program entry point
- Compilation vs execution
- Standard output using macros

### Topic 1.1.3: Variables

- Immutable-by-default variable bindings
- Mutability with `mut`
- Shadowing vs reassignment
- Scope-based lifetime of variables

### Topic 1.1.4: Data Types

- Scalar types (integers, floats, booleans, characters)
- Compound types (tuples, arrays)
- Type inference and explicit annotations
- Compile-time type checking

### Topic 1.1.5: Constants and Statics

- `const` values and compile-time evaluation
- `static` variables and global data
- Immutability guarantees and memory placement
- Use cases and restrictions

### Topic 1.1.6: Functions

- Function definitions and signatures
- Parameters and return values
- Expression-based returns
- Function scope and visibility basics

### Topic 1.1.7: Control Flow

- Conditional execution with `if` expressions
- Looping constructs (`loop`, `while`, `for`)
- Pattern-based iteration
- Control flow as expressions

### Topic 1.1.8: Comments

- Line comments and documentation comments
- Code readability and intent
- Rust documentation tooling integration

---

## **Professional Applications and Implementation**

The concepts in this lesson are directly applicable to everyday Rust development, including building command-line utilities, scripts, and foundational services. Mastery of variables, functions, and control flow enables developers to translate business logic into safe, performant Rust code. Understanding constants, statics, and data types is essential for configuration management, performance-sensitive code, and systems-level development.

---

## **Key Takeaways**

| Concept Area | Summary |
| -------------- | --------- |
| Tooling | Rust uses a unified toolchain for compilation, dependency management, and builds. |
| Program Structure | Rust programs are explicit, compiled, and entry-point driven. |
| Variables & Types | Immutability and strong typing are core design principles. |
| Constants | `const` and `static` support safe, explicit global values. |
| Control Flow | Rust treats control flow constructs as expressions. |
| Code Clarity | Comments and structure support maintainable, self-documenting code. |

- Establishes a working Rust development environment
- Introduces Rust’s explicit and safety-focused syntax
- Builds confidence in writing and executing simple Rust programs
- Lays the groundwork for ownership and memory safety concepts

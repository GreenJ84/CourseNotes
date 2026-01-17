# **Lesson 1.4: Rust Project Structure**

This lesson introduces the structural conventions and organizational mechanisms that underpin maintainable Rust codebases. It focuses on how Rust projects are laid out on disk, how code is modularized and encapsulated, how external dependencies are managed through Cargo, and how reusable libraries are prepared and published. Understanding Rust’s project structure is essential for writing scalable applications, collaborating in teams, and participating in the Rust ecosystem.

## **Learning Objectives**

- Understand the default layout of Rust projects created with Cargo
- Organize code using modules, files, and directories
- Control visibility and encapsulation with Rust’s module system
- Manage third-party dependencies using Cargo
- Prepare and publish reusable Rust packages (crates)

---

## **Topics**

### Topic 1.4.1: Project Structure

- Cargo-generated project layout (`src`, `Cargo.toml`, `Cargo.lock`)
- Binary crates vs library crates
- Entry points (`main.rs` and `lib.rs`)
- Conventional directory organization
- Separation of concerns through file and folder structure

### Topic 1.4.2: Modules

- The Rust module system and namespace hierarchy
- Declaring modules with `mod`
- File-based and inline module definitions
- `use` statements and path resolution
- Visibility control with `pub` and privacy defaults

### Topic 1.4.3: External Dependencies

- Declaring dependencies in `Cargo.toml`
- Semantic versioning and dependency resolution
- Using crates from `crates.io`
- Importing external APIs with `use`
- Managing dependency updates and lockfiles

### Topic 1.4.4: Publishing Your Package

- Preparing a crate for publication
- Required metadata in `Cargo.toml`
- Versioning and documentation requirements
- Publishing to `crates.io`
- Maintaining and updating published crates

---

## **Professional Applications and Implementation**

Effective project structure is critical for professional Rust development. Proper modularization improves readability, testability, and long-term maintainability. Dependency management enables rapid development while maintaining reproducibility and security. Publishing crates supports code reuse, internal tooling, and open-source collaboration, all of which are common in production Rust environments.

---

## **Key Takeaways**

| Area | Summary |
| ------ | --------- |
| Project Layout | Cargo enforces a conventional structure that supports clarity and scalability. |
| Modules | Rust’s module system provides strong encapsulation and explicit visibility control. |
| Dependencies | Cargo simplifies dependency management while ensuring reproducible builds. |
| Publishing | Crates can be shared and reused through structured metadata and versioning. |

- Rust projects follow predictable, convention-driven layouts
- Modules enable clean separation of logic and controlled visibility
- Cargo is central to dependency management and builds
- Publishing crates integrates projects into the broader Rust ecosystem

# **Topic 1.1.8: Comments**

This topic explains how Rust uses comments not only for human-readable explanations but also as an integral part of documentation and tooling. Comments in Rust support code clarity, maintainability, and automated documentation generation. Understanding when and how to use each type of comment is essential for writing professional, collaborative Rust code.

## **Learning Objectives**

- Use line and block comments to explain code behavior
- Apply documentation comments for public APIs
- Understand how Rust documentation is generated and tested
- Write comments that improve clarity without redundancy
- Leverage documentation tests to maintain code-comment synchronization

---

## **Line Comments**

Line comments begin with `//` and extend to the end of the line.

```rs
// This is a line comment
let x = 5; // Inline comment
```

**Use Cases:**

- Short explanations or clarifications of non-obvious logic
- Inline documentation of complex expressions
- Temporary notes during development and debugging

**Best Practices:**

- Explain *why* code exists, not *what* it does (the "why" is rarely apparent from syntax alone)
- Avoid redundant comments that restate obvious behavior
- Keep comments concise and focused
- Update comments when modifying adjacent code

---

## **Block Comments**

Block comments are enclosed using `/* */` and support nesting.

```rs
/*
This is a block comment.
It can span multiple lines.
*/
```

**Characteristics:**

- Useful for temporarily disabling code segments during development
- Suitable for longer, multi-paragraph explanations
- Support nesting, allowing comments within comments

```rs
/*
Outer comment
  /* Nested comment */
Still in outer comment
*/
```

**Production Considerations:**

Block comments are less common in production Rust code; line comments are generally preferred because they integrate better with version control diffs and are easier to manage in collaborative settings.

---

## **Documentation Comments**

Documentation comments generate API documentation and support embedded examples with testing.

### Outer Doc Comments (`///`)

Apply to the item immediately following the comment.

```rs
/// Adds two numbers together.
///
/// # Arguments
/// * `a` - First number
/// * `b` - Second number
///
/// # Returns
/// The sum of `a` and `b`.
///
/// # Example
/// ```
/// assert_eq!(add(2, 3), 5);
/// ```
fn add(a: i32, b: i32) -> i32 {
  a + b
}
```

**Applications:**

- Document functions, structs, enums, traits, and modules
- Written in Markdown, supporting headers, code blocks, and lists
- Automatically appear in generated HTML documentation
- Support standard sections: `# Arguments`, `# Returns`, `# Errors`, `# Panics`, `# Example`, `# Safety`

### Inner Doc Comments (`//!`)

Apply to the enclosing module or crate.

```rs
//! This module provides mathematical utility functions.
//!
//! # Example
//! ```
//! use my_math::add;
//! assert_eq!(add(5, 3), 8);
//! ```
```

**Common Locations:**

- Top of `lib.rs` to describe the entire crate
- Top of `mod.rs` to describe module purpose and usage
- Provide high-level context for the containing item

### Generating and Testing Documentation

Rust provides built-in tooling for documentation generation and validation.

```bash
cargo doc --open
```

**Features:**

- Generates searchable, cross-linked HTML documentation
- Automatically links types, functions, and modules
- Includes all code examples from doc comments

**Documentation Tests (Doctests):**

Code examples in doc comments are compiled and executed during `cargo test`:

```bash
cargo test --doc
```

This ensures documentation examples remain correct and synchronized with your code, catching outdated examples before they reach users.

---

## **Professional Applications and Implementation**

Effective commenting is critical in collaborative Rust codebases. Clear comments reduce onboarding time for new developers, support long-term maintainability, and improve API usability. Documentation comments are especially important for libraries and public interfaces, enabling automatic generation of high-quality reference material that remains synchronized with the code through doctest validation.

---

## **Key Takeaways**

| Comment Type | Purpose | Best For |
| ------------ | ------- | -------- |
| Line (`//`) | Short, targeted explanations within code | Inline clarifications and development notes |
| Block (`/* */`) | Multi-line or temporary commentary | Disabling code blocks; supporting nesting |
| Outer Doc (`///`) | Generate API documentation for items | Functions, structs, enums, traits, modules |
| Inner Doc (`//!`) | Document modules and crates | Library and crate-level documentation |
| Doctests | Validate examples in documentation | Ensuring docs remain accurate with code |

**Impact on Code Quality:**

- Improves readability and maintainability for collaborative teams
- Integrates directly with Rust's tooling ecosystem
- Enables self-documenting codebases through automated generation
- Supports professional, open-source, and enterprise workflows
- Reduces technical debt through documentation-as-code practices


# **Lesson 1.3: Custom Data Types**

This lesson introduces Rust’s core data modeling constructs used to represent structured, variant, and dynamic data. Custom data types form the backbone of idiomatic Rust design, enabling developers to express domain concepts clearly while preserving memory safety and performance guarantees. The lesson progresses from basic struct definitions to enums and standard library abstractions that encode correctness into the type system.

## **Learning Objectives**

- Define and instantiate structs to model structured data
- Use implementation blocks to associate behavior with data
- Differentiate between classic structs and tuple structs
- Model variant data using enums and exhaustive pattern matching
- Use `Option` to represent the presence or absence of values safely
- Use `Result` to model recoverable errors explicitly
- Work with vectors as growable, heap-allocated collections

---

## **Topics**

### Topic 1: Structs

- Defining named-field data structures
- Ownership and borrowing of struct fields
- Mutability rules at the struct and field level
- Struct update syntax and field init shorthand

### Topic 2: Implementation Blocks

- Associating methods with types using `impl`
- `self`, `&self`, and `&mut self` semantics
- Associated functions vs instance methods
- Constructor patterns and encapsulation

### Topic 3: Tuple Structs

- Structs with unnamed fields
- Use cases for lightweight, type-safe wrappers
- Distinguishing tuple structs from tuples

### Topic 4: Enums

- Defining variants with and without associated data
- Memory layout and discriminants
- Exhaustive pattern matching with `match`
- Enums as algebraic data types

### Topic 5: Option

- Representing nullable values without `null`
- `Some` and `None` semantics
- Pattern matching and combinator methods
- Preventing invalid states through type design

### Topic 6: Result

- Modeling recoverable errors explicitly
- `Ok` and `Err` variants
- Error propagation fundamentals
- Integrating results into control flow

### Topic 7: Vectors

- Heap-allocated, growable collections
- Ownership and borrowing rules for elements
- Indexing vs safe access methods
- Iteration patterns and mutation

---

## **Professional Applications and Implementation**

Custom data types are central to professional Rust development. Structs and enums enable precise domain modeling, reducing runtime errors by shifting correctness checks to compile time. `Option` and `Result` eliminate entire classes of bugs related to null values and unchecked failures. Vectors support dynamic workloads while preserving safety guarantees. Together, these tools allow developers to build expressive APIs, maintain invariants, and create resilient systems across CLI tools, services, and libraries.

---

## **Key Takeaways**

| Concept | Purpose |
| ------- | --------- |
| Structs | Model structured data with clear ownership semantics. |
| Impl Blocks | Attach behavior and enforce encapsulation. |
| Tuple Structs | Provide lightweight, type-safe wrappers. |
| Enums | Represent variant data and state machines safely. |
| Option | Encode absence explicitly and safely. |
| Result | Represent recoverable errors as part of the type system. |
| Vectors | Manage dynamic collections with safety and performance. |

- Rust data types encode correctness directly into program structure
- Enums and pattern matching enable expressive and safe control flow
- `Option` and `Result` replace unsafe nulls and implicit errors
- Mastery of these constructs is essential for idiomatic Rust design

# **Lesson 2.4: Functional Features in Rust**

This lesson examines Rust’s functional programming capabilities and how they integrate with the language’s ownership model, type system, and performance guarantees. Functional features in Rust emphasize composability, immutability, and expressiveness without sacrificing control over memory or runtime behavior. Through closures, iterators, and combinators, Rust enables concise yet highly optimized data transformations that compile down to efficient machine code.

## **Learning Objectives**

- Understand closures as first-class values and their interaction with ownership and borrowing
- Apply the iterator pattern to process collections lazily and efficiently
- Use combinators to compose complex behavior from simple functional building blocks
- Recognize how Rust achieves functional expressiveness without runtime overhead
- Balance functional style with readability, performance, and safety

---

## **Topics**

### Topic 2.4.1: Closures

- Closure syntax and type inference
- Capture modes: by reference, mutable reference, and by value
- The `Fn`, `FnMut`, and `FnOnce` traits
- Ownership transfer and borrowing rules in closures
- Use cases for closures in APIs, callbacks, and iterator pipelines

### Topic 2.4.2: Iterator Pattern

- The `Iterator` trait and the `next` method
- Lazy evaluation and zero-cost abstractions
- Consuming vs non-consuming iterators
- Iterator adapters and iterator chaining
- Relationship between iterators and ownership

### Topic 2.4.3: Combinators

- Functional combinators for `Option` and `Result`
- Iterator combinators (`map`, `filter`, `take`, `zip`)
- Composing transformations without intermediate collections
- Error-aware composition patterns
- Readability and maintainability considerations

---

## **Professional Applications and Implementation**

Functional features are central to idiomatic Rust development and appear throughout production codebases:

- Building expressive data-processing pipelines with minimal overhead
- Writing concise business logic using composable transformations
- Avoiding mutable state while maintaining performance
- Simplifying error handling and control flow through combinators
- Designing APIs that accept behavior as parameters

---

## **Key Takeaways**

| Feature | Summary |
| ------- | ------- |
| Closures | Encapsulate behavior with precise ownership semantics. |
| Iterators | Enable lazy, efficient data traversal and transformation. |
| Combinators | Allow complex logic to be built from simple, reusable operations. |

- Rust supports functional programming without garbage collection
- Functional abstractions compile to highly optimized code
- Ownership and borrowing rules apply consistently across functional constructs
- These features prepare codebases for safe concurrency and async workflows

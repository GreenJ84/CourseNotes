# **Topic 1.6.1: Testing**

Testing in Rust is a core part of the language and tooling rather than an external add-on. Rust's testing model emphasizes correctness, clarity of intent, and maintainability, complementing compile-time guarantees with structured runtime validation. This topic covers what to test, how Rust organizes tests, how assertions work, and how to handle edge cases, panics, and error-based validation. It also establishes the conceptual boundary between unit and integration testing.

## **Learning Objectives**

- Identify which parts of a Rust codebase should be tested and understand the cost-benefit analysis of test coverage
- Write and organize test modules and test functions using idiomatic Rust conventions
- Use Rust's assertion macros effectively and understand their performance implications
- Validate edge cases and boundary conditions with strategic test selection
- Test functions that return `Result` values using ergonomic patterns
- Verify panic behavior intentionally and document panic contracts
- Distinguish between unit tests and integration tests, and know when to use each
- Apply advanced testing patterns including test fixtures, parameterized testing, and custom test runners

---

## **What to Test: Strategic Considerations**

Testing every line of code is neither practical nor necessary. Senior developers adopt a risk-based approach to test coverage:

### High-Priority Testing Areas

- **Public APIs and externally observable behavior** — These form the contract with consumers; breaking changes here affect downstream code
- **Core business logic and invariants** — The algorithms and state transitions that define your system's correctness
- **Panic contracts** — Any documented panic scenarios must be tested to prevent silent failures
- **Error paths and failure handling** — Where users interact with `Result` types and error recovery logic
- **Complex conditional logic** — Particularly when conditions interact or have non-obvious implications
- **Unsafe blocks and FFI boundaries** — Where Rust's guarantees may not hold; these require exhaustive testing
- **Assumptions not enforced by the type system** — Invariants like "this vector is sorted" or "this reference outlives that one"

### Lower-Priority Testing Areas

- **Internal helper functions** — Unless they encapsulate genuinely complex logic worth isolating
- **Type system constraints** — The compiler already validates these
- **Trivial accessors** — Direct field access via getters rarely benefits from tests
- **Third-party library integration** — Trust the library's own tests unless you're using it in an unusual way

### The Testing Pyramid

Structure your test suite as a pyramid:

- **Many unit tests** (fast, focused, cheap to maintain)
- **Some integration tests** (slower, broader coverage)
- **Few end-to-end tests** (slowest, highest value for critical paths)

Testing should focus on *behavior*, not implementation details. A unit test that breaks whenever you refactor internal code is a maintenance burden. Tests should validate *what* happens, not *how* it happens.

---

## **Test Modules and Test Functions**

Rust tests are enabled through conditional compilation using the `#[cfg(test)]` attribute. This ensures test code is never included in release binaries.

### Organizing Tests

- **Inline test modules** — Defined in the same file using `#[cfg(test)] mod tests { ... }`
- **Separate test files** — For integration tests, place files in the `tests/` directory
- **Doc tests** — Written inside documentation comments
- **Test organization by feature** — Group related tests in nested modules that mirror your public API structure

### Test Function Fundamentals

Test functions are annotated with `#[test]` and can optionally return `Result<(), E>`:

```rust
#[test]
fn simple_assertion() {
  assert_eq!(2 + 2, 4);
}

#[test]
fn test_with_result() -> Result<(), String> {
  Ok(())
}
```

### Access and Scoping

When tests are defined inline in the same module:

- `use super::*;` imports the parent module's public items
- **Private functions are fully accessible** — This is a key feature of inline tests; you can test internal behavior directly
- Tests are compiled separately only when running `cargo test`

### Comprehensive Inline Test Example

```rust
pub struct Calculator {
  history: Vec<i32>,
}

impl Calculator {
  pub fn new() -> Self {
    Calculator {
      history: Vec::new(),
    }
  }

  pub fn add(&mut self, a: i32, b: i32) -> i32 {
    let result = a.saturating_add(b);
    self.history.push(result);
    result
  }

  pub fn last_result(&self) -> Option<i32> {
    self.history.last().copied()
  }

  // Private helper that validates numeric state
  fn is_valid_state(&self) -> bool {
    !self.history.is_empty() && self.history.len() < 1000
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_calculator_addition() {
    let mut calc = Calculator::new();
    assert_eq!(calc.add(5, 3), 8);
    assert_eq!(calc.add(10, 20), 30);
  }

  #[test]
  fn test_history_tracking() {
    let mut calc = Calculator::new();
    calc.add(5, 3);
    calc.add(10, 20);
    
    assert_eq!(calc.last_result(), Some(30));
    assert_eq!(calc.history.len(), 2);
  }

  #[test]
  fn test_private_state_validation() {
    let mut calc = Calculator::new();
    assert!(!calc.is_valid_state()); // Empty state is invalid
    
    calc.add(1, 1);
    assert!(calc.is_valid_state()); // Now valid
  }

  #[test]
  fn test_saturating_behavior() {
    let mut calc = Calculator::new();
    let result = calc.add(i32::MAX, 100);
    
    // saturating_add caps at i32::MAX
    assert_eq!(result, i32::MAX);
  }
}
```

---

## **Doc Tests: Executable Documentation**

Doc tests are tests embedded in documentation comments. They serve dual purposes: they document usage and ensure examples don't rot.

```rust
/// Computes the sum of two numbers.
///
/// # Examples
///
/// ```
/// assert_eq!(add(2, 3), 5);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
  a + b
}

/// Returns the first element of a slice, or an error if empty.
///
/// # Examples
///
/// ```
/// let nums = vec![1, 2, 3];
/// assert_eq!(first(&nums), Some(&1));
/// ```
///
/// # Panics
///
/// ```should_panic
/// first(&vec![]);
/// ```
pub fn first<T>(slice: &[T]) -> Option<&T> {
  slice.first()
}
```

**Key points about doc tests:**

- Each code block is compiled as a separate crate
- `// ignore` prevents compilation; `// no_run` compiles but doesn't run
- They're validated by `cargo test --doc`
- Use them to document *typical* usage, not edge cases
- Overly complex doc tests hurt readability; reserve detailed testing for unit tests

---

## **Asserting: The Foundation of Test Validation**

Rust provides a carefully designed family of assertion macros. Understanding their performance characteristics and appropriate use cases is essential for writing maintainable tests.

### Core Assertion Macros

```rust
#[test]
fn assertion_fundamentals() {
  // assert! — Validates a boolean condition
  // Best for: Binary checks, custom predicates
  let value = 42;
  assert!(value > 0);
  assert!(value % 2 == 0);

  // assert_eq! — Validates equality using PartialEq and Debug
  // Best for: Comparing values when you want both actual and expected in output
  assert_eq!(2 + 2, 4);
  assert_eq!("hello", "hello");

  // assert_ne! — Validates inequality
  // Best for: Ensuring values diverged as expected
  assert_ne!(2 + 2, 5);
  assert_ne!("foo", "bar");
}
```

### Custom Failure Messages

Messages are lazily evaluated and dramatically improve diagnostics:

```rust
#[test]
fn validation_with_context() {
  let user_age = 15;
  let min_age = 18;

  assert!(
    user_age >= min_age,
    "user age {} is below minimum {}; rejecting registration",
    user_age,
    min_age
  );
}
```

When this assertion fails, the output includes your custom message, making debugging significantly easier. **Never skip custom messages in complex assertions** — future maintainers (including yourself) will be grateful.

### Advanced Assertion Patterns

For complex validations, custom predicates improve readability:

```rust
#[test]
fn testing_with_predicates() {
  let numbers = vec![1, 2, 3, 4, 5];
  
  // Using closures for complex conditions
  assert!(
    numbers.iter().all(|&n| n > 0),
    "expected all positive numbers, got {:?}",
    numbers
  );

  // For repeated assertions, extract into a helper
  fn is_sorted<T: Ord>(slice: &[T]) -> bool {
    slice.windows(2).all(|w| w[0] <= w[1])
  }

  let sorted = vec![1, 2, 3, 4, 5];
  assert!(is_sorted(&sorted));

  let unsorted = vec![5, 2, 3, 1, 4];
  assert!(!is_sorted(&unsorted));
}
```

---

## **Edge Cases and Boundary Conditions**

Edge cases represent the inflection points where systems most often fail. Strategic edge case testing catches latent bugs before they reach production.

### Categories of Edge Cases

```rust
#[cfg(test)]
mod edge_case_examples {
  use super::*;

  // Empty/zero collections
  #[test]
  fn handles_empty_collections() {
    let empty_vec: Vec<i32> = Vec::new();
    assert_eq!(empty_vec.first(), None);
    assert_eq!(empty_vec.len(), 0);
    assert!(empty_vec.is_empty());
  }

  // Numeric boundaries
  #[test]
  fn numeric_extremes() {
    assert_eq!(i32::MAX.saturating_add(1), i32::MAX);
    assert_eq!(i32::MIN.saturating_sub(1), i32::MIN);
    assert_eq!(u32::MAX as u64 + 1, 4_294_967_296);
  }

  // Single-element collections
  #[test]
  fn single_element_edge_case() {
    let single = vec![42];
    assert_eq!(single.first(), Some(&42));
    assert_eq!(single.last(), single.first());
  }

  // Off-by-one errors
  #[test]
  fn boundary_conditions() {
    let slice = &[1, 2, 3, 4, 5];
    
    // First and last are special
    assert_eq!(slice.first(), Some(&1));
    assert_eq!(slice.last(), Some(&5));
    
    // Length boundaries
    assert_eq!(slice.len(), 5);
    assert!(slice.get(4).is_some()); // Last valid index
    assert!(slice.get(5).is_none());  // First invalid index
  }

  // Malformed/invalid input
  #[test]
  fn invalid_input_handling() {
    let malformed_json = r#"{"incomplete": "#;
    // In real code, validate parsing behavior
    assert!(malformed_json.len() > 0);
  }

  // Rare state combinations
  #[test]
  fn concurrent_state_edge_cases() {
    // Testing state transitions under unusual conditions
    use std::sync::{Arc, Mutex};

    let counter = Arc::new(Mutex::new(0));
    let c1 = Arc::clone(&counter);
    
    let handle = std::thread::spawn(move || {
      for _ in 0..100 {
        let mut num = c1.lock().unwrap();
        *num += 1;
      }
    });

    for _ in 0..100 {
      let mut num = counter.lock().unwrap();
      *num += 1;
    }

    handle.join().unwrap();
    assert_eq!(*counter.lock().unwrap(), 200);
  }
}
```

---

## **Testing Functions Returning `Result`**

Error handling is a first-class concern in Rust. Tests for fallible functions should validate both success and failure paths.

### The `Result<(), E>` Test Pattern

```rust
#[test]
fn result_based_test() -> Result<(), String> {
  let value = 5;

  if value % 2 == 1 {
    Ok(())
  } else {
    Err("value was not odd".into())
  }
}
```

### Comprehensive Error Testing

```rust
fn parse_positive_integer(s: &str) -> Result<u32, String> {
  s.parse::<u32>()
    .map_err(|_| format!("'{}' is not a valid positive integer", s))
}

#[cfg(test)]
mod result_tests {
  use super::*;

  // Success path
  #[test]
  fn valid_integer_parses() -> Result<(), String> {
    let result = parse_positive_integer("42")?;
    assert_eq!(result, 42);
    Ok(())
  }

  // Failure path with specific error validation
  #[test]
  fn invalid_input_returns_error() {
    let result = parse_positive_integer("not_a_number");
    assert!(result.is_err());
    
    match result {
      Err(e) => assert!(e.contains("not a valid positive integer")),
      Ok(_) => panic!("expected error"),
    }
  }

  // Using the ? operator for cleaner failure testing
  #[test]
  fn multiple_fallible_operations() -> Result<(), Box<dyn std::error::Error>> {
    let num1 = parse_positive_integer("10")?;
    let num2 = parse_positive_integer("20")?;
    
    assert_eq!(num1 + num2, 30);
    Ok(())
  }

  // Testing error propagation
  #[test]
  fn error_propagates_correctly() {
    fn chained_operation(s: &str) -> Result<u32, String> {
      let num = parse_positive_integer(s)?;
      Ok(num * 2)
    }

    let err = chained_operation("invalid");
    assert!(err.is_err());
  }

  // Traditional panic-based assertions still work with Results
  #[test]
  #[should_panic(expected = "called `Result::unwrap()` on an `Err` value")]
  fn unwrap_panics_on_error() {
    parse_positive_integer("bad").unwrap();
  }
}
```

This pattern is superior to traditional panic-based tests when:

- Testing code that naturally returns `Result`
- Chaining multiple fallible operations
- Avoiding deeply nested error handling
- Maintaining clear error semantics

---

## **Testing Panic Behavior**

Panics represent unrecoverable errors. Some functions are designed to panic under invalid conditions. Document these contracts clearly and test them explicitly.

### Basic Panic Testing

```rust
fn divide(a: i32, b: i32) -> i32 {
  if b == 0 {
    panic!("division by zero");
  }
  a / b
}

#[cfg(test)]
mod panic_tests {
  use super::*;

  #[test]
  #[should_panic]
  fn panics_on_zero_divisor() {
    divide(10, 0);
  }

  #[test]
  #[should_panic(expected = "division by zero")]
  fn panics_with_correct_message() {
    divide(10, 0);
  }

  #[test]
  fn normal_operation_succeeds() {
    assert_eq!(divide(10, 2), 5);
  }
}
```

### Advanced Panic Testing Patterns

```rust
#[cfg(test)]
mod advanced_panic_tests {
  use super::*;

  // Testing that panic occurs at the right time
  #[test]
  #[should_panic(expected = "out of bounds")]
  fn panics_before_completion() {
    let items = vec![1, 2, 3];
    let _ = items[10]; // Panics; code after never executes
  }

  // Verifying panic messages contain specific information
  #[test]
  #[should_panic(expected = "invalid state")]
  fn panic_message_contains_context() {
    panic!("invalid state: counter negative");
  }

  // When you need more control, catch panics explicitly
  #[test]
  fn catching_panics_with_catch_unwind() {
    use std::panic;
    
    let result = panic::catch_unwind(|| {
      divide(10, 0)
    });

    assert!(result.is_err());
  }
}
```

**Best practices for panic testing:**

- Document which functions panic and under what conditions
- Test panic messages specifically; generic panics are hard to debug
- Prefer `Result` for error handling over panics when possible
- Only use `#[should_panic]` for functions where panic is the expected behavior

---

## **Unit Tests: Deep Dives Into Implementation**

Unit tests validate small, focused pieces of functionality in isolation. They're the workhorse of your test suite.

### Characteristics of Effective Unit Tests

- **Fast execution** — Milliseconds, not seconds
- **Focused scope** — Test one thing per test function
- **Independence** — No shared state between tests
- **High maintainability** — Easy to update when code changes

### Comprehensive Unit Test Example

```rust
pub struct BankAccount {
  balance: i64, // in cents to avoid floating-point issues
}

#[derive(Debug, PartialEq)]
pub enum WithdrawalError {
  InsufficientFunds { available: i64, requested: i64 },
  InvalidAmount,
}

impl BankAccount {
  pub fn new(initial_balance: i64) -> Self {
    BankAccount {
      balance: initial_balance,
    }
  }

  pub fn balance(&self) -> i64 {
    self.balance
  }

  pub fn deposit(&mut self, amount: i64) -> Result<(), WithdrawalError> {
    if amount <= 0 {
      return Err(WithdrawalError::InvalidAmount);
    }
    self.balance = self.balance.saturating_add(amount);
    Ok(())
  }

  pub fn withdraw(&mut self, amount: i64) -> Result<(), WithdrawalError> {
    if amount <= 0 {
      return Err(WithdrawalError::InvalidAmount);
    }
    if amount > self.balance {
      return Err(WithdrawalError::InsufficientFunds {
        available: self.balance,
        requested: amount,
      });
    }
    self.balance -= amount;
    Ok(())
  }
}

#[cfg(test)]
mod bank_account_tests {
  use super::*;

  // Test creation
  #[test]
  fn new_account_has_correct_balance() {
    let account = BankAccount::new(10000); // $100.00
    assert_eq!(account.balance(), 10000);
  }

  // Test happy path operations
  #[test]
  fn deposit_increases_balance() -> Result<(), WithdrawalError> {
    let mut account = BankAccount::new(0);
    account.deposit(5000)?; // $50.00
    assert_eq!(account.balance(), 5000);
    Ok(())
  }

  #[test]
  fn withdrawal_decreases_balance() -> Result<(), WithdrawalError> {
    let mut account = BankAccount::new(10000);
    account.withdraw(3000)?; // $30.00
    assert_eq!(account.balance(), 7000);
    Ok(())
  }

  // Test error conditions
  #[test]
  fn withdrawal_fails_on_insufficient_funds() {
    let mut account = BankAccount::new(5000); // $50.00
    
    let error = account.withdraw(10000).unwrap_err();
    assert_eq!(
      error,
      WithdrawalError::InsufficientFunds {
        available: 5000,
        requested: 10000
      }
    );
    
    // Verify balance unchanged after failed withdrawal
    assert_eq!(account.balance(), 5000);
  }

  #[test]
  fn invalid_deposit_amount_rejected() {
    let mut account = BankAccount::new(10000);
    
    assert_eq!(account.deposit(0), Err(WithdrawalError::InvalidAmount));
    assert_eq!(account.deposit(-100), Err(WithdrawalError::InvalidAmount));
    
    // Balance should be unchanged
    assert_eq!(account.balance(), 10000);
  }

  #[test]
  fn invalid_withdrawal_amount_rejected() {
    let mut account = BankAccount::new(10000);
    
    assert_eq!(account.withdraw(0), Err(WithdrawalError::InvalidAmount));
    assert_eq!(account.withdraw(-100), Err(WithdrawalError::InvalidAmount));
  }

  // Test edge cases
  #[test]
  fn zero_balance_prevents_any_withdrawal() {
    let mut account = BankAccount::new(0);
    
    assert!(account.withdraw(1).is_err());
  }

  #[test]
  fn exact_balance_withdrawal_succeeds() {
    let mut account = BankAccount::new(5000);
    assert!(account.withdraw(5000).is_ok());
    assert_eq!(account.balance(), 0);
  }

  #[test]
  fn large_deposits_dont_overflow() -> Result<(), WithdrawalError> {
    let mut account = BankAccount::new(i64::MAX - 1000);
    
    // saturating_add prevents overflow
    account.deposit(5000)?;
    assert_eq!(account.balance(), i64::MAX);
    
    Ok(())
  }

  // Test state transitions
  #[test]
  fn multiple_operations_maintain_invariant() -> Result<(), WithdrawalError> {
    let mut account = BankAccount::new(10000);
    
    account.deposit(5000)?;
    assert_eq!(account.balance(), 15000);
    
    account.withdraw(3000)?;
    assert_eq!(account.balance(), 12000);
    
    account.deposit(2000)?;
    assert_eq!(account.balance(), 14000);
    
    Ok(())
  }
}
```

---

## **Integration Tests: Testing from the Outside**

Integration tests validate your public API from a consumer's perspective. They test how components work together and ensure the contract with external code is upheld.

### Characteristics of Integration Tests

- **Public API focus** — Only test through public interfaces
- **No access to private items** — Tests are external to your crate
- **Separate compilation** — Each test file is its own crate
- **Real-world scenarios** — Test typical usage patterns

### Project Structure for Integration Tests

```text
my_project/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── models.rs
│   └── operations.rs
└── tests/
  ├── integration_tests.rs
  └── common/
    └── mod.rs
```

### Integration Test Example

**File: `tests/integration_tests.rs`**

```rust
use my_project::{BankAccount, WithdrawalError};

#[test]
fn complete_workflow() -> Result<(), WithdrawalError> {
  // Set up: Create accounts
  let mut alice = BankAccount::new(50000); // $500.00
  let mut bob = BankAccount::new(30000);   // $300.00

  // Operation: Alice sends money to Bob
  alice.withdraw(20000)?; // Alice withdraws $200
  bob.deposit(20000)?;    // Bob deposits $200

  // Verify final state
  assert_eq!(alice.balance(), 30000);
  assert_eq!(bob.balance(), 50000);

  Ok(())
}

#[test]
fn error_handling_in_realistic_scenario() {
  let mut account = BankAccount::new(10000);
  
  // User tries to withdraw more than they have
  match account.withdraw(15000) {
    Err(WithdrawalError::InsufficientFunds { available, requested }) => {
      assert_eq!(available, 10000);
      assert_eq!(requested, 15000);
    }
    _ => panic!("expected InsufficientFunds error"),
  }
}
```

### Shared Test Utilities

**File: `tests/common/mod.rs`**

```rust
pub fn create_test_account(balance: i64) -> crate::BankAccount {
  crate::BankAccount::new(balance)
}

pub struct TestContext {
  pub account1: crate::BankAccount,
  pub account2: crate::BankAccount,
}

impl TestContext {
  pub fn new() -> Self {
    TestContext {
      account1: create_test_account(50000),
      account2: create_test_account(30000),
    }
  }
}
```

**File: `tests/another_test.rs`**

```rust
mod common;

use common::TestContext;
use my_project::WithdrawalError;

#[test]
fn using_shared_test_utilities() -> Result<(), WithdrawalError> {
  let mut ctx = TestContext::new();
  
  ctx.account1.withdraw(10000)?;
  ctx.account2.deposit(10000)?;
  
  assert_eq!(ctx.account1.balance(), 40000);
  assert_eq!(ctx.account2.balance(), 40000);
  
  Ok(())
}
```

---

## **Testing in Development**

Effective testing practices directly correlate with system reliability, maintainability, and the speed at which teams can confidently refactor and extend codebases.

### Test-Driven Development (TDD) in Rust

Many teams follow the red-green-refactor cycle:

1. **Red** — Write a failing test for desired behavior
2. **Green** — Write minimal code to make the test pass
3. **Refactor** — Improve the implementation without changing behavior

This approach leverages Rust's compile-time guarantees and ensures every feature has test coverage before deployment.

### Continuous Integration and Testing

```yaml
# Example: .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - uses: actions-rs/toolchain@v1
    with:
      toolchain: stable
    - run: cargo test --all
    - run: cargo test --all --doc
    - run: cargo test --all -- --ignored  # Run slow tests
```

### Coverage and Risk Assessment

Use tools like `tarpaulin` or `llvm-cov` to measure coverage:

```bash
cargo tarpaulin --out Html
```

Focus on:

- **Critical path coverage** — Ensure core business logic is extensively tested
- **Error path coverage** — Every documented error condition should be tested
- **Regression prevention** — Every bug fix should include a test that would have caught it

### Moving Forward

As you grow in Rust expertise:

- Learn property-based testing frameworks like `proptest` and `quickcheck`
- Explore benchmarking with `criterion` to prevent performance regressions
- Adopt fuzzing to discover edge cases automatically
- Study how mature Rust projects organize their test suites

---

## **Professional Applications and Implementation**

Effective testing practices support long-term maintainability and safe refactoring. Unit tests catch regressions early, while integration tests ensure public APIs behave correctly under realistic usage. Panic and edge-case testing strengthen system resilience, and result-based tests integrate naturally with Rust’s error-handling model. Together, these techniques enable confident iteration in production Rust codebases.

---

## **Key Takeaways**

| Concept               | Core Principle                                                                                 |
| ------------------    | ---------------------------------------------------------------------------------------        |
| **Test Scope**        | Focus on behavior and invariants; avoid testing implementation details or the compiler.        |
| **Assertions**        | Use `assert!`, `assert_eq!`, and `assert_ne!` appropriately; always include messages.          |
| **Edge Cases**        | Explicitly test boundaries, empty states, and numeric extremes to prevent production failures. |
| **Result Tests**      | Returning `Result` from tests enables cleaner error handling and `?` operator usage.           |
| **Panic Testing**     | Use `#[should_panic]` to validate intentional failure scenarios; document panic contracts.     |
| **Unit Tests**        | Test internal logic; they're fast, focused, and have full module access.                       |
| **Integration Tests** | Test public APIs from external perspective; they validate component interaction.               |
| **Test Fixtures**     | Create helper functions and shared test utilities to reduce duplication.                       |

- Rust integrates testing directly into the language, compiler, and tooling ecosystem
- Clear test structure, organization, and naming dramatically improve maintainability
- Testing reinforces Rust's compile-time guarantees with runtime validation of behavior
- A well-designed test suite enables confident refactoring and safe concurrent development
- Strong testing discipline is foundational for production-quality Rust systems

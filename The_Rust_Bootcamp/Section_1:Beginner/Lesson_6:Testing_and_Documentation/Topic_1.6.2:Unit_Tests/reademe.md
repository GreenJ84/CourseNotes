# **Topic 1.6.2: Unit Tests**

Unit tests in Rust are designed to validate small, well-defined units of behavior in isolation. They serve as the primary mechanism for verifying correctness at the function and module level, complementing Rust's compile-time safety guarantees with runtime validation. This topic explores how unit tests are structured, how they interact with module privacy, and how to design effective, maintainable tests that provide fast feedback during development.

## **Learning Objectives**

- Understand the role of unit tests in Rust's development workflow and their relationship to compile-time guarantees
- Organize unit tests using test modules and conditional compilation (`#[cfg(test)]`)
- Write effective `#[test]` functions with clear intent and proper assertion strategies
- Interpret assertion failures, test diagnostics, and leverage debug output for root-cause analysis
- Test both private and public functionality appropriately, understanding visibility boundaries
- Design unit tests that are fast, focused, and maintainable while avoiding common pitfalls
- Apply advanced testing patterns including test fixtures, parameterization, and trait-based testing

---

## **Purpose of Unit Testing in Rust**

Unit testing in Rust focuses on verifying *individual pieces of logic* rather than full system behavior. Unlike many languages where unit testing supplements compile-time checks, Rust's philosophy positions unit tests as runtime validators of *logical correctness* where compile-time guarantees end.

### Key goals

- **Validating logical correctness and invariants**: Rust's type system prevents entire categories of bugs, but unit tests validate business logic, state transitions, and domain invariants
- **Detecting regressions during refactoring**: Safe refactoring confidence depends on comprehensive unit tests
- **Providing executable documentation**: Tests clarify intended behavior more precisely than comments
- **Enabling confident iteration in evolving codebases**: Quick feedback loops accelerate development velocity
- **Defining the contract between components**: Tests encode assumptions about function behavior and edge cases

Because Rust enforces many guarantees at compile time, unit tests typically concentrate on:

- **Logical correctness**: Does the algorithm produce the expected output?
- **Boundary conditions**: How does the function behave at limits (empty collections, zero, negative values)?
- **Error handling and assumptions**: Are error cases properly handled? Are preconditions validated?
- **State mutations**: In stateful code, do side effects occur as expected?

### Example

compile-time guarantees and unit tests work together:

```rust
// Rust's type system prevents use-after-free, null dereferences, and data races
// Unit tests validate that the algorithm is correct

pub fn find_first_even(nums: &[i32]) -> Option<i32> {
  nums.iter().find(|&&n| n % 2 == 0).copied()
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn empty_slice_returns_none() {
    assert_eq!(find_first_even(&[]), None);
  }

  #[test]
  fn all_odd_returns_none() {
    assert_eq!(find_first_even(&[1, 3, 5]), None);
  }

  #[test]
  fn finds_first_even_in_sequence() {
    assert_eq!(find_first_even(&[1, 3, 4, 5]), Some(4));
  }

  #[test]
  fn returns_first_not_last_even() {
    assert_eq!(find_first_even(&[2, 4, 6]), Some(2));
  }
}
```

---

## **Test Modules and the `#[cfg(test)]` Attribute**

Unit tests are commonly placed in the same file as the code they test, within a test-only module. This colocation strategy offers significant advantages in maintainability and discoverability.

### Understanding `#[cfg(test)]`

- `#[cfg(test)]` is a conditional compilation attribute that includes code only when running `cargo test`
- Prevents test logic from being included in production binaries, reducing binary size
- Keeps implementation and validation closely aligned, improving code review and navigation
- Allows test modules to access private implementation details without exposing them publicly

---

## **Module Organization Patterns**

### Pattern 1: Single inline test module (common for small libraries)

```rust
pub fn calculate_discount(price: f64, discount_percent: f64) -> f64 {
  price * (1.0 - discount_percent / 100.0)
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn applies_discount_correctly() {
    assert!((calculate_discount(100.0, 10.0) - 90.0).abs() < 0.001);
  }

  #[test]
  fn handles_zero_discount() {
    assert_eq!(calculate_discount(100.0, 0.0), 100.0);
  }

  #[test]
  fn handles_full_discount() {
    assert_eq!(calculate_discount(100.0, 100.0), 0.0);
  }
}
```

### Pattern 2: Multiple test submodules (for complex behavior)

```rust
pub struct ShoppingCart {
  items: Vec<(String, f64, usize)>, // (name, price, quantity)
}

impl ShoppingCart {
  pub fn new() -> Self {
    Self { items: Vec::new() }
  }

  pub fn add_item(&mut self, name: String, price: f64, quantity: usize) {
    self.items.push((name, price, quantity));
  }

  pub fn total(&self) -> f64 {
    self.items.iter().map(|(_, price, qty)| price * qty as f64).sum()
  }

  pub fn item_count(&self) -> usize {
    self.items.iter().map(|(_, _, qty)| qty).sum()
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  mod initialization {
    use super::*;

    #[test]
    fn new_cart_is_empty() {
      let cart = ShoppingCart::new();
      assert_eq!(cart.item_count(), 0);
      assert_eq!(cart.total(), 0.0);
    }
  }

  mod addition {
    use super::*;

    #[test]
    fn single_item_updates_count() {
      let mut cart = ShoppingCart::new();
      cart.add_item("Book".to_string(), 15.0, 1);
      assert_eq!(cart.item_count(), 1);
    }

    #[test]
    fn multiple_quantities_sum_correctly() {
      let mut cart = ShoppingCart::new();
      cart.add_item("Pen".to_string(), 2.0, 5);
      assert_eq!(cart.item_count(), 5);
    }
  }

  mod totals {
    use super::*;

    #[test]
    fn single_item_total() {
      let mut cart = ShoppingCart::new();
      cart.add_item("Notebook".to_string(), 10.0, 1);
      assert!((cart.total() - 10.0).abs() < 0.001);
    }

    #[test]
    fn multiple_items_total() {
      let mut cart = ShoppingCart::new();
      cart.add_item("Item A".to_string(), 10.0, 2);
      cart.add_item("Item B".to_string(), 5.0, 3);
      // (10 * 2) + (5 * 3) = 35
      assert!((cart.total() - 35.0).abs() < 0.001);
    }
  }
}
```

> This submodule pattern improves organization and makes test intent clearer through grouping.

---

## **Writing Tests Using `#[test]` Functions**

Each unit test is a standalone function marked with the `#[test]` attribute. The Rust test framework discovers these functions at compile time and executes them in parallel by default.

### Test Function Requirements

- Must take no arguments (or use dependency injection patterns)
- Can have any return type (traditionally `()`, but `Result<T, E>` is increasingly common)
- A test passes if it completes without panicking
- A test fails if it panics or the test framework detects a failure condition

### Best Practices for Test Design

- Use descriptive test names that document behavior

```rust
pub fn validate_email(email: &str) -> bool {
  email.contains('@') && email.contains('.')
}

#[cfg(test)]
mod tests {
  use super::*;

  // ✓ Good: Clear what is being tested and expected outcome
  #[test]
  fn valid_email_with_standard_format_returns_true() {
    assert!(validate_email("user@example.com"));
  }

  // ✗ Poor: Vague intent
  #[test]
  fn test_email() {
    assert!(validate_email("user@example.com"));
  }

  // ✓ Good: Explicit about the edge case
  #[test]
  fn email_without_domain_extension_returns_false() {
    assert!(!validate_email("user@localhost"));
  }

  // ✓ Good: Tests the specific error condition
  #[test]
  fn email_missing_at_symbol_returns_false() {
    assert!(!validate_email("user.example.com"));
  }
}
```

- Test one behavior per function

```rust
pub fn parse_config(input: &str) -> Result<(String, i32), String> {
  let parts: Vec<&str> = input.split('=').collect();
  if parts.len() != 2 {
    return Err("Invalid format".to_string());
  }
  let value = parts[1].parse::<i32>()
    .map_err(|_| "Invalid number".to_string())?;
  Ok((parts[0].to_string(), value))
}

#[cfg(test)]
mod tests {
  use super::*;

  // ✓ Each test verifies exactly one behavior
  #[test]
  fn valid_config_parses_correctly() {
    let result = parse_config("timeout=30");
    assert_eq!(result, Ok(("timeout".to_string(), 30)));
  }

  #[test]
  fn missing_equals_sign_returns_error() {
    let result = parse_config("invalid_format");
    assert!(result.is_err());
  }

  #[test]
  fn non_numeric_value_returns_error() {
    let result = parse_config("count=abc");
    assert!(result.is_err());
  }
}
```

- Keep tests short and focused

```rust
// ✓ Good: Focused, readable, fast
#[test]
fn fibonacci_fifth_number_is_five() {
  assert_eq!(fibonacci(5), 5);
}

// ✗ Poor: Tests multiple behaviors, harder to debug failures
#[test]
fn fibonacci_comprehensive_test() {
  assert_eq!(fibonacci(0), 0);
  assert_eq!(fibonacci(1), 1);
  assert_eq!(fibonacci(2), 1);
  assert_eq!(fibonacci(5), 5);
  assert_eq!(fibonacci(10), 55);
}
```

---

## **Assertions and Test Failure Diagnostics**

Assertions are the mechanism by which tests communicate success or failure. Rust provides several assertion macros with different levels of detail and expressiveness.

### Core Assertion Macros

```rust
#[cfg(test)]
mod assertion_examples {
  #[test]
  fn assert_boolean_condition() {
    let value = 5;
    assert!(value > 0, "value must be positive, got {}", value);
  }

  #[test]
  fn assert_equality() {
    let result = 2 + 2;
    assert_eq!(result, 4, "arithmetic failed");
  }

  #[test]
  fn assert_inequality() {
    let a = 5;
    let b = 10;
    assert_ne!(a, b);
  }

  #[test]
  #[should_panic(expected = "divide by zero")]
  fn panics_on_division_by_zero() {
    let _result = 10 / 0; // This will panic
  }
}
```

### Interpreting Failure Output

When an assertion fails, Rust's test framework provides rich diagnostic information:

```text
thread 'tests::subtraction_fails' panicked at 'assertion failed: `(left == right)`
  left: `7`,
 right: `5`', src/lib.rs:15:5

The test shows:
- Exact line number (src/lib.rs:15:5)
- Expected vs actual values
- Which assertion macro failed
```

**Example with custom assertions for better diagnostics:**

```rust
pub struct User {
  id: u32,
  name: String,
  age: u32,
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn user_age_validation() {
    let user = User {
      id: 1,
      name: "Alice".to_string(),
      age: 150,
    };

    // ✓ Good: Clear message on failure
    assert!(
      user.age < 130,
      "User age {} exceeds biological maximum",
      user.age
    );
  }
}
```

### Advanced: Using `Result` in Tests

Modern Rust testing supports returning `Result<T, E>` from tests, enabling the `?` operator:

```rust
pub fn divide(a: f64, b: f64) -> Result<f64, String> {
  if b == 0.0 {
    Err("Division by zero".to_string())
  } else {
    Ok(a / b)
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn division_succeeds() -> Result<(), String> {
    let result = divide(10.0, 2.0)?;
    assert_eq!(result, 5.0);
    Ok(())
  }

  #[test]
  fn division_by_zero_fails() -> Result<(), String> {
    let result = divide(10.0, 0.0);
    assert!(result.is_err());
    Ok(())
  }
}
```

---

## **Testing Private vs Public Functionality**

One of Rust's distinctive testing features is that unit tests have unrestricted access to private items in the same module. This design choice profoundly impacts testing strategy.

### Why Access to Private Items Matters

```rust
// Consider a data structure with internal invariants
pub struct BankAccount {
  // Private: Implementation detail, intentionally not exposed
  balance: f64,
}

impl BankAccount {
  pub fn new(initial_balance: f64) -> Self {
    Self { balance: initial_balance }
  }

  pub fn deposit(&mut self, amount: f64) -> Result<(), String> {
    if amount <= 0.0 {
      return Err("Deposit must be positive".to_string());
    }
    self.balance += amount;
    Ok(())
  }

  pub fn withdraw(&mut self, amount: f64) -> Result<(), String> {
    if amount <= 0.0 {
      return Err("Withdrawal must be positive".to_string());
    }
    if amount > self.balance {
      return Err("Insufficient funds".to_string());
    }
    self.balance -= amount;
    Ok(())
  }

  // Private helper: Encapsulates complex validation
  fn is_valid_state(&self) -> bool {
    self.balance >= 0.0
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn account_maintains_positive_invariant_after_operations() {
    let mut account = BankAccount::new(100.0);
    account.deposit(50.0).unwrap();
    account.withdraw(30.0).unwrap();

    // We can access private field to verify invariant
    assert!(account.is_valid_state());
    assert!(account.balance >= 0.0);
  }

  #[test]
  fn failed_withdrawal_preserves_balance() {
    let mut account = BankAccount::new(50.0);
    let original_balance = account.balance;

    let result = account.withdraw(100.0);
    assert!(result.is_err());
    assert_eq!(account.balance, original_balance);
  }
}
```

### Testing Strategy: Public Contract vs Private Validation

**Test the public contract** (what users of your API should verify):

```rust
#[test]
fn public_api_behavior_is_correct() {
  let mut account = BankAccount::new(100.0);
  assert!(account.deposit(50.0).is_ok());
}
```

**Test private invariants** (only when encapsulating complex logic):

```rust
#[test]
fn private_invariant_is_maintained() {
  let mut account = BankAccount::new(100.0);
  account.withdraw(50.0).unwrap();

  // Verify internal consistency
  assert_eq!(account.balance, 50.0); // Access private field in tests only
}
```

### When to Expose Internal Testing Helpers

```rust
pub fn process_data(input: &[u8]) -> Vec<u8> {
  let mut result = Vec::new();

  // Internal complex logic that benefits from direct testing
  for chunk in input.chunks(4) {
    let processed = transform_chunk(chunk);
    result.extend_from_slice(&processed);
  }

  result
}

// Don't expose transform_chunk publicly if it's only used internally
fn transform_chunk(chunk: &[u8]) -> Vec<u8> {
  // Complex transformation logic
  chunk.iter().map(|b| b.wrapping_add(1)).collect()
}

#[cfg(test)]
mod tests {
  use super::*;

  // Test through public API (preferred)
  #[test]
  fn process_data_handles_multiple_chunks() {
    let input = &[1, 2, 3, 4, 5, 6, 7, 8];
    let output = process_data(input);
    assert_eq!(output.len(), 8);
  }

  // Test private function directly (only if the logic is critical)
  #[test]
  fn transform_chunk_increments_bytes() {
    let input = &[1, 2, 3, 4];
    let output = transform_chunk(input);
    assert_eq!(output, vec![2, 3, 4, 5]);
  }
}
```

---

## **Characteristics of Effective Unit Tests**

Effective unit tests in Rust share several defining traits that maximize their utility while minimizing maintenance burden:

| Characteristic | Description | Example |
| --- | --- | --- |
| **Focused** | Test one behavior or edge case | Test "empty string returns error" not "all string validations" |
| **Fast** | Execute in microseconds to milliseconds | Avoid I/O, external calls, heavy computation |
| **Deterministic** | Always produce same result | Avoid random data, time-dependent assertions |
| **Readable** | Clear intent without reading implementation | Descriptive names, minimal setup, linear flow |
| **Independent** | No dependencies on other tests | Each test should run standalone |
| **Maintainable** | Easy to modify when requirements change | DRY principles, common fixtures, clear structure |

### Example: Effective vs Ineffective Tests

```rust
pub fn find_user_by_name(users: &[User], name: &str) -> Option<&User> {
  users.iter().find(|u| u.name == name)
}

#[cfg(test)]
mod tests {
  use super::*;

  // Setup helper (DRY principle)
  fn create_test_users() -> Vec<User> {
    vec![
      User { id: 1, name: "Alice".to_string() },
      User { id: 2, name: "Bob".to_string() },
    ]
  }

  // ✓ Effective: Focused, readable, maintainable
  #[test]
  fn finds_user_by_exact_name() {
    let users = create_test_users();
    assert_eq!(find_user_by_name(&users, "Alice").map(|u| u.id), Some(1));
  }

  // ✓ Effective: Tests failure case explicitly
  #[test]
  fn returns_none_for_nonexistent_user() {
    let users = create_test_users();
    assert!(find_user_by_name(&users, "Charlie").is_none());
  }

  // ✗ Ineffective: Too broad, hard to debug if it fails
  #[test]
  fn comprehensive_user_search() {
    let users = create_test_users();
    assert_eq!(find_user_by_name(&users, "Alice").unwrap().id, 1);
    assert_eq!(find_user_by_name(&users, "Bob").unwrap().id, 2);
    assert!(find_user_by_name(&users, "Charlie").is_none());
    assert!(find_user_by_name(&users, "Dave").is_none());
  }
}

pub struct User {
  id: u32,
  name: String,
}
```

---

## **Ideal Use Cases for Unit Tests**

Unit tests are best suited for scenarios where behavior can be validated in isolation with minimal setup:

### ✓ Excellent Use Cases

```rust
// 1. Mathematical and algorithmic logic
pub fn gcd(mut a: u32, mut b: u32) -> u32 {
  while b != 0 {
    let temp = b;
    b = a % b;
    a = temp;
  }
  a
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn gcd_of_12_and_8_is_4() {
    assert_eq!(gcd(12, 8), 4);
  }
}

// 2. Parsing and validation
pub fn parse_ipv4(s: &str) -> Result<[u8; 4], String> {
  let parts: Vec<&str> = s.split('.').collect();
  if parts.len() != 4 {
    return Err("Expected 4 octets".to_string());
  }
  let octets: Result<Vec<u8>, _> = parts.iter()
    .map(|p| p.parse::<u8>().map_err(|_| "Invalid octet".to_string()))
    .collect();
  
  match octets {
    Ok(v) if v.len() == 4 => Ok([v[0], v[1], v[2], v[3]]),
    Ok(_) => Err("Expected 4 octets".to_string()),
    Err(e) => Err(e),
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn valid_ipv4_parses_correctly() {
    assert_eq!(parse_ipv4("192.168.1.1"), Ok([192, 168, 1, 1]));
  }

  #[test]
  fn invalid_octet_returns_error() {
    assert!(parse_ipv4("256.1.1.1").is_err());
  }
}

// 3. State machines and complex conditionals
pub enum State {
  Idle,
  Running,
  Paused,
  Stopped,
}

impl State {
  pub fn transition(&self, event: &str) -> Result<State, String> {
    match (self, event) {
      (State::Idle, "start") => Ok(State::Running),
      (State::Running, "pause") => Ok(State::Paused),
      (State::Paused, "resume") => Ok(State::Running),
      (State::Running, "stop") | (State::Paused, "stop") => Ok(State::Stopped),
      _ => Err(format!("Invalid transition from {:?}", self)),
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn valid_state_transitions_succeed() {
    let state = State::Idle;
    let running = state.transition("start").unwrap();
    
    if let State::Running = running {
      let paused = running.transition("pause").unwrap();
      assert!(matches!(paused, State::Paused));
    }
  }

  #[test]
  fn invalid_transition_returns_error() {
    let state = State::Idle;
    assert!(state.transition("pause").is_err());
  }
}
```

### ✗ Poor Use Cases (Better Suited for Integration Tests)

```rust
// Don't unit test:
// - Full HTTP request/response cycles
// - Database operations
// - File I/O
// - External API calls
// - Complex workflows spanning multiple components

// These require integration tests with proper test infrastructure
```

---

## **Common Unit Testing Pitfalls and How to Avoid Them**

### Pitfall 1: Over-Testing Implementation Details

```rust
// ✗ Bad: Tests the implementation, not the contract
#[test]
fn uses_btreemap_internally() {
  // This couples the test to implementation choice
  let data = some_structure();
  // Can't actually verify BTreeMap is used in unit test
}

// ✓ Good: Tests the observable behavior
#[test]
fn returns_elements_in_sorted_order() {
  let mut data = some_structure();
  data.insert(3);
  data.insert(1);
  data.insert(2);
  
  let elements: Vec<_> = data.iter().copied().collect();
  assert_eq!(elements, vec![1, 2, 3]);
}
```

### Pitfall 2: Test Interdependencies

```rust
// ✗ Bad: Tests depend on execution order
#[cfg(test)]
mod tests {
  static mut COUNTER: i32 = 0;

  #[test]
  fn first_test() {
    unsafe { COUNTER = 5; }
  }

  #[test]
  fn second_test() {
    // FAILS if second_test runs first!
    unsafe { assert_eq!(COUNTER, 5); }
  }
}

// ✓ Good: Each test is independent
#[cfg(test)]
mod tests {
  #[test]
  fn first_test() {
    let mut counter = 5;
    assert_eq!(counter, 5);
  }

  #[test]
  fn second_test() {
    let mut counter = 5;
    assert_eq!(counter, 5);
  }
}
```

### Pitfall 3: Insufficient Edge Case Coverage

```rust
pub fn calculate_percentage(part: f64, whole: f64) -> Result<f64, String> {
  if whole == 0.0 {
    Err("Whole cannot be zero".to_string())
  } else {
    Ok((part / whole) * 100.0)
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn basic_percentage() {
    assert_eq!(calculate_percentage(25.0, 100.0).unwrap(), 25.0);
  }

  // ✓ Good: Test edge cases
  #[test]
  fn zero_part_returns_zero_percent() {
    assert_eq!(calculate_percentage(0.0, 100.0).unwrap(), 0.0);
  }

  #[test]
  fn zero_whole_returns_error() {
    assert!(calculate_percentage(50.0, 0.0).is_err());
  }

  #[test]
  fn negative_values() {
    assert_eq!(calculate_percentage(-50.0, 100.0).unwrap(), -50.0);
  }

  #[test]
  fn handles_very_small_numbers() {
    let result = calculate_percentage(1e-10, 1e-9);
    assert!((result.unwrap() - 10.0).abs() < 0.0001);
  }
}
```

---

## **Test Coverage and Continuous Integration**

In production Rust codebases, unit tests are written *during* implementation, not after. This test-driven development (TDD) or test-first approach shapes the design of the code itself, making APIs more testable and maintainable.

### Test Coverage Strategy

Professional codebases typically aim for:

- **100% coverage of critical paths**: Business logic, error handling, invariant-maintaining code
- **High coverage of utility/helper functions**: These enable other tests
- **Moderate coverage of infrastructure**: Heavy integration test focus rather than unit tests

```rust
// Example: Prioritized test coverage
pub struct PaymentProcessor {
  // Critical: 100% unit test coverage
  fn validate_card(&self, card: &CreditCard) -> Result<(), Error>;
  fn calculate_total(&self, items: &[Item]) -> f64;
  
  // Moderate: Covered by integration tests
  fn process_payment(&mut self, card: &CreditCard, amount: f64) -> Result<TransactionId, Error>;
}
```

### Continuous Integration and Test Performance

Tests must run quickly in CI pipelines. Professional projects often:

- Run unit tests on every commit (< 1 minute total)
- Run integration tests on pull requests (< 5 minutes)
- Run full system tests nightly (< 30 minutes)

```rust
// Run all tests: cargo test
// Run only unit tests: cargo test --lib
// Run specific test: cargo test --lib test_name
// Run with output: cargo test -- --nocapture
// Run tests in parallel: cargo test -- --test-threads=4 (or --test-threads=1 if tests interfere)
```

---

## **Professional Applications and Implementation**

In professional Rust codebases, unit tests are written alongside implementation code to ensure correctness during rapid iteration. Their speed and precision make them ideal for continuous integration pipelines, local development, and safe refactoring. By leveraging access to private functionality, developers can validate invariants without compromising encapsulation or API design.

---

## **Key Takeaways**

| Area | Summary |
| ------ | --------- |
| **Purpose** | Unit tests verify small, isolated pieces of logic with fast feedback. They validate logical correctness where compile-time guarantees end. |
| **Structure** | Inline test modules use `#[cfg(test)]` and `#[test]` for organization. Submodules improve clarity for complex behavior. |
| **Assertions** | Failures provide detailed diagnostics. Use `assert!`, `assert_eq!`, `assert_ne!` and custom messages for clarity. Modern tests return `Result<T, E>`. |
| **Privacy** | Unit tests can access private functions and data safely. Test the public contract primarily; verify private invariants when they encapsulate critical logic. |
| **Use Cases** | Best for algorithms, parsing, validation, state machines, and complex conditionals. Avoid I/O, external calls, and multi-component workflows. |
| **Pitfalls** | Avoid testing implementation details, interdependent tests, and insufficient edge case coverage. |
| **Professional Practice** | Write tests during development, prioritize critical paths, and ensure fast execution for CI pipelines. |

- Unit tests are the foundation of Rust's testing strategy and critical to development velocity
- Close proximity to code improves clarity, maintainability, and encourages testing alongside implementation
- Fast execution enables confident refactoring, safe iteration, and rapid CI feedback
- Properly scoped unit tests reinforce Rust's safety guarantees by validating logical correctness
- Test design is as important as test coverage; well-designed tests clarify intent and prevent future regressions

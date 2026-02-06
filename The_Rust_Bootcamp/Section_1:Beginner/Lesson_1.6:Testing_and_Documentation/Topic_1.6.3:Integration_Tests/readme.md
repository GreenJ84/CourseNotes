# **Topic 1.6.3: Integration Tests**

Integration tests in Rust validate how components of a crate work together when used as a whole. Unlike unit tests, which focus on isolated pieces of logic, integration tests exercise the public surface area of a crate from the perspective of an external consumer. This topic examines how integration tests are structured, how they are executed, and how to design them to reflect real-world usage patterns while maintaining semantic stability across versions.

## **Learning Objectives**

- Distinguish clearly between unit tests and integration tests, understanding their complementary roles in a comprehensive testing strategy
- Understand the `tests/` directory structure, crate boundaries, and how Rust's module system enforces visibility constraints
- Write integration tests that validate public APIs, error propagation, and contract fulfillment
- Run and manage integration tests using Cargo, including test filtering, parallel execution, and custom test harnesses
- Design integration tests that mirror realistic consumer behavior, edge cases, and long-term API stability
- Apply advanced patterns such as shared test utilities, fixtures, and test isolation techniques

---

## **Difference Between Unit and Integration Tests**

Unit and integration tests serve complementary but distinct roles in a robust testing strategy.

### Unit tests

- Validate small, isolated pieces of functionality in isolation
- Placed inline with source code (typically in the same module)
- Have access to private implementation details
- Execute quickly and provide tight feedback loops
- Focus on correctness of algorithms and business logic

### Integration tests

- Validate how publicly exposed components interact as a cohesive system
- Located in the dedicated `tests/` directory outside `src/`
- Access only public APIs, simulating external consumer behavior
- Execute slower due to compilation and linking overhead
- Focus on contract fulfillment and API stability

### Key distinctions

| Aspect | Unit Tests | Integration Tests |
| -------- | ----------- | ------------------- |
| **Scope** | Individual functions/methods | Multiple modules/components |
| **Visibility** | Access to private code | Access only to `pub` items |
| **Purpose** | Implementation correctness | API contracts and behavior |
| **Execution** | Fast, fine-grained feedback | Slower, system-level validation |
| **Refactoring Impact** | May require updates to implementation changes | Resilient to internal refactors |
| **Consumer Perspective** | Internal developer view | External user view |

This separation enforces clean API design, proper encapsulation, and prevents integration tests from becoming brittle due to implementation details.

---

## **The `tests/` Directory Structure**

Rust uses a convention-based approach for integration tests that creates strong boundaries between public and private code.

**Key structural principles:**

- Integration tests are placed in a top-level `tests/` directory adjacent to `src/`
- Each `.rs` file in `tests/` is compiled as a **separate, independent crate**
- The tested crate is imported as an external dependency via `Cargo.toml`
- Each test file can have its own `main` function (implicit test harness)
- Shared test utilities can be organized in `tests/common/mod.rs`

**Example project layout:**

```text
my_math_lib/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── arithmetic.rs
│   └── geometry.rs
├── tests/
│   ├── common/
│   │   ├── mod.rs
│   │   └── fixtures.rs
│   ├── arithmetic_integration.rs
│   ├── geometry_integration.rs
│   └── error_handling.rs
└── benches/
  └── arithmetic_bench.rs
```

### Important nuance

Each test file in `tests/` compiles independently. This means:

- Each file gets its own binary and implicit test runner
- Files cannot directly reference each other
- Shared code must live in `tests/common/mod.rs` and be imported explicitly
- Dependencies are resolved through the crate's public `lib.rs` interface

This structure perfectly simulates how external consumers interact with the crate through its public interface.

---

## **Testing Public APIs and Crate Boundaries**

Integration tests are strictly limited to public interfaces, enforcing strong API boundaries and contract validation.

### Visibility constraints

- Only items marked with `pub` (and appropriate visibility modifiers) are accessible
- Private functions, fields, and modules are intentionally hidden
- Tests validate **documented behavior and contracts**, not implementation
- Re-exports through the public API are naturally available

### Comprehensive example

```rust
// src/lib.rs - The public API surface
pub mod calculation {
  pub struct Calculator {
    precision: u32,
  }

  impl Calculator {
    pub fn new(precision: u32) -> Self {
      Self { precision }
    }

    pub fn divide(&self, a: f64, b: f64) -> Result<f64, DivisionError> {
      if b.abs() < 1e-10 {
        Err(DivisionError::DivideByZero)
      } else {
        Ok(a / b)
      }
    }

    // Private helper - not accessible to integration tests
    fn round_result(&self, value: f64) -> f64 {
      let multiplier = 10_f64.powi(self.precision as i32);
      (value * multiplier).round() / multiplier
    }
  }

  #[derive(Debug, PartialEq)]
  pub enum DivisionError {
    DivideByZero,
    InvalidPrecision,
  }
}

pub use calculation::{Calculator, DivisionError};
```

### Integration test (`tests/api_contract.rs`)

```rust
use my_math_lib::{Calculator, DivisionError};

#[test]
fn calculator_division_success() {
  let calc = Calculator::new(2);
  assert_eq!(calc.divide(10.0, 2.0).unwrap(), 5.0);
}

#[test]
fn calculator_handles_division_by_zero() {
  let calc = Calculator::new(2);
  assert_eq!(calc.divide(5.0, 0.0), Err(DivisionError::DivideByZero));
}

#[test]
fn calculator_propagates_errors_correctly() {
  let calc = Calculator::new(2);
  
  // Can test error handling paths
  match calc.divide(1.0, 0.0) {
    Err(DivisionError::DivideByZero) => {
      // Correctly propagated
    }
    _ => panic!("Expected DivideByZero"),
  }
}

// This would NOT compile - private methods are inaccessible:
// #[test]
// fn invalid_access_to_private() {
//     let calc = Calculator::new(2);
//     calc.round_result(3.14159); // ERROR: method `round_result` is private
// }
```

### Why this matters

- Tests validate **observable behavior**, not internal mechanics
- Internal refactoring (e.g., changing `round_result` implementation) doesn't break integration tests
- API changes are caught immediately by test compilation failures
- Contract violations are detected at the integration boundary

---

## **Running Integration Tests with Cargo**

Cargo provides sophisticated tooling for executing, filtering, and managing integration tests with fine-grained control.

### Basic execution

```bash
# Run all tests (unit and integration)
cargo test

# Run only integration tests
cargo test --test '*'

# Run a specific test file
cargo test --test arithmetic_integration

# Run tests matching a pattern
cargo test divide
```

### Advanced filtering

```bash
# Run integration tests excluding a pattern
cargo test --test '*' -- --exclude-should-panic

# Run tests with output printed
cargo test --test error_handling -- --nocapture

# Run tests serially (useful for tests with shared state)
cargo test -- --test-threads=1

# Show test names without running them
cargo test --test api_contract -- --list

# Run with backtrace on panic
RUST_BACKTRACE=1 cargo test --test geometry_integration
```

### Cargo's automation

- Each `tests/*.rs` file is compiled as a separate binary crate
- The target crate is automatically linked as a dependency
- Test binaries are placed in `target/debug/deps/`
- Results are aggregated and reported consistently
- Parallel execution (default: number of CPU cores)

### Example with multiple test files

```bash
$ cargo test --test '*'
   Compiling my_math_lib v0.1.0
  Finished test [unoptimized + debuginfo] target(s) in 2.45s
   Running target/debug/deps/arithmetic_integration-a1b2c3d4
running 3 tests
test calculator_division_success ... ok
test calculator_handles_division_by_zero ... ok
test calculator_propagates_errors_correctly ... ok

test result: ok. 3 passed; 0 failed; 0 ignored

   Running target/debug/deps/geometry_integration-e5f6g7h8
running 2 tests
test circle_area_calculation ... ok
test polygon_perimeter ... ok

test result: ok. 2 passed; 0 failed; 0 ignored
```

---

## **Designing Tests That Reflect Real-World Usage**

Senior Rust developers design integration tests to mirror authentic consumer workflows, capturing edge cases and ensuring resilience to internal changes.

### Best practices

1. **Test Common Usage Scenarios**
   - Happy paths that represent typical usage
   - Workflows combining multiple public functions
   - State transitions and interactions

2. **Validate Error Handling Comprehensively**
   - All `Result` variants and error types
   - Recovery paths after errors
   - Error propagation through call chains

3. **Avoid Implementation Coupling**
   - Never rely on private internals
   - Don't test implementation details
   - Focus on observable behavior and contracts

4. **Design Resilient Tests**
   - Minimize test interdependencies
   - Use proper test isolation
   - Avoid hardcoded state assumptions

---

## **Advanced Integration Testing Patterns**

### Test Organization and Fixtures

```rust
// tests/fixtures.rs - Reusable test data
pub struct TestFixture {
  pub valid_input: String,
  pub invalid_input: String,
}

impl Default for TestFixture {
  fn default() -> Self {
    Self {
      valid_input: "test_data".to_string(),
      invalid_input: "".to_string(),
    }
  }
}
```

### Testing Error Propagation

```rust
#[test]
fn error_propagation_with_question_mark() {
  fn operation() -> Result<String, Box<dyn std::error::Error>> {
    let processor = FileProcessor::new(1024);
    let result = processor.process_file("nonexistent.txt")?;
    Ok(result)
  }

  assert!(operation().is_err());
}
```

### Conditional Test Compilation

```rust
#[test]
#[cfg(feature = "heavy_integration_tests")]
fn expensive_integration_test() {
  // Only runs when feature is enabled
}
```

---

## **Characteristics of Integration Tests**

Integration tests in Rust share the following characteristics:

- **Validate public APIs and real usage patterns** - Focus on contracts and behavior from a consumer's perspective
- **Located in a dedicated `tests/` directory** - Separate from source code, at the crate root
- **Each file compiled as a separate crate** - Enforces independence and simulates external consumer relationships
- **Limited strictly to public interfaces** - Only `pub` items are accessible
- **No access to private functions or variables** - Prevents coupling to implementation details
- **Encourage testing from a consumer's perspective** - Mirrors how real users interact with the crate
- **Resilient to internal refactoring** - Tests remain valid when implementation changes

These constraints promote robust API design, long-term maintainability, and semantic stability.

---

## **Integration Testing Objectives**

In professional Rust projects, integration tests serve as critical safeguards for API stability and consumer trust. They accomplish several strategic objectives:

### API Contract Enforcement

- Integration tests document implicit and explicit API contracts
- Changes to public signatures trigger test failures, preventing silent breaking changes
- Contract violations are caught before releases

### Regression Prevention

- Ensure that bug fixes don't reintroduce previous issues
- Validate that optimizations maintain correctness
- Protect against accidental behavior changes during refactoring

### Version Compatibility

- For libraries distributed to external users, integration tests verify that public APIs remain stable
- Enable confident semantic versioning (SemVer) adherence
- Support safe evolution across major versions

### Consumer Confidence

- External users can review integration tests to understand correct API usage
- Tests serve as executable documentation
- Demonstrate commitment to reliability

### Organizational Scalability

- Multiple teams can rely on integration tests to understand crate boundaries
- Enable safe concurrent development
- Reduce coupling between internal teams and external consumers

---

## **Professional Applications and Implementation**

In professional Rust projects, integration tests safeguard API stability and consumer trust. They ensure that refactors, optimizations, or internal redesigns do not introduce breaking changes. Integration tests are especially valuable for libraries, services, and tools distributed to external users, where public contracts must remain reliable across versions.

---

## **Key Takeaways**

| Aspect | Detail |
| -------- | -------- |
| **Purpose** | Integration tests validate crate-level behavior and API contracts from external consumer perspective |
| **Structure** | Tests live in `tests/` directory; each `.rs` file compiles as independent crate |
| **Visibility** | Only `pub` interfaces are accessible; enforces clean API boundaries |
| **Tooling** | Cargo compiles, links, and executes tests with fine-grained filtering and parallel execution |
| **Design** | Tests should mirror real usage patterns, comprehensively handle errors, and remain resilient to internal changes |
| **Scope** | Validate observable behavior and contract fulfillment, not implementation details |
| **Resilience** | Internal refactoring should not break integration tests |

**Strategic principles:**

- Integration tests complement unit tests by validating system-level behavior
- Public APIs are treated as stable, contractual commitments
- Realistic test design improves confidence and enables safe evolution
- Proper integration testing is foundational for professional Rust libraries and services
- Tests should be independent, isolated, and focused on consumer-facing behavior
- Integration tests serve as executable documentation of correct API usage

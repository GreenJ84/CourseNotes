# **Topic 1.6.5: Benchmarking**

Benchmarking in Rust provides a disciplined approach to measuring performance characteristics and detecting regressions over time. Rather than relying on intuition or ad-hoc timing, Rust's benchmarking ecosystem encourages statistically sound measurement, repeatability, and clear interpretation. This topic focuses on using Criterion as a development-time benchmarking tool, selecting meaningful code paths to measure, and structuring benchmarks correctly within a Rust project.

## **Learning Objectives**

- Understand the purpose and scope of benchmarking in Rust
- Configure a project for benchmarking using Criterion
- Select code paths that are meaningful to benchmark
- Write reliable benchmarks using Criterion primitives
- Execute and interpret benchmarks using Cargo
- Master advanced Criterion techniques for realistic measurements
- Avoid common benchmarking pitfalls and anti-patterns

---

## **Why Benchmarking Matters**

Benchmarking answers questions that testing cannot:

- How fast is this code under realistic conditions?
- Did a change improve or regress performance?
- Where are the actual bottlenecks?

Benchmarking is not about micro-optimizing prematurely. It is about:

- Validating performance-critical assumptions
- Comparing alternative implementations
- Preventing unintended slowdowns over time
- Establishing performance baselines for CI/CD pipelines
- Informing architectural decisions with empirical data

---

### The Cost of Ignoring Benchmarking

Without systematic benchmarking:

- Performance regressions slip into production undetected
- Optimizations are attempted on non-bottleneck code
- Teams make architectural decisions based on assumption rather than data
- Technical debt compounds as small slowdowns accumulate

Senior Rust developers recognize that benchmarking is not optional for performance-critical systems—it is a cornerstone of professional development practice.

---

## **Benchmarking Tooling Overview**

Rust's standard library once provided unstable benchmarking support, but the ecosystem has matured toward external, robust tooling.

- **Criterion** is the industry-standard benchmarking framework  
- Provides statistical analysis, noise reduction, and regression detection  
- Produces reproducible results across runs and environments
- Integrates seamlessly with CI/CD pipelines
- Supports custom measurement overhead accounting

Criterion is added as a *development dependency*.

```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }
```

The `html_reports` feature generates visual comparisons across benchmark runs, invaluable for tracking performance trends.

---

## **Project Structure for Benchmarks**

Benchmarks follow a convention-based layout that isolates them from unit tests.

- Benchmarks live in a top-level `benches/` directory
- Each benchmark file is compiled as a separate binary crate
- Cargo configuration explicitly enables benchmarks
- Separation prevents benchmark code from inflating binary size

Example structure:

```text
my_crate/
├── src/
│   ├── lib.rs
│   └── algorithms/
│       └── sorting.rs
├── benches/
│   ├── sort_algorithms.rs
│   └── common/
│       └── mod.rs
├── Cargo.toml
└── .gitignore
```

Cargo configuration in `Cargo.toml`:

```toml
[[bench]]
name = "sort_algorithms"
harness = false

[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }
my_crate = { path = ".", default-features = false }
```

Setting `harness = false` tells Cargo to skip its built-in test harness and let Criterion manage execution entirely. This is essential for accurate measurements.

---

## **Selecting Bench-able Code**

Strategic selection of benchmarks is as important as the benchmarking process itself.

### Good candidates

- Hot paths executed millions of times in production
- Core algorithms with multiple implementations (e.g., sorting, hashing)
- Serialization, deserialization, parsing, or cryptographic operations
- Performance-sensitive loops, especially those processing large datasets
- Async workloads and concurrency primitives
- Lock-free data structures where contention is a concern

### Poor candidates

- One-time initialization or setup code
- I/O-bound operations without deterministic isolation (network, disk)
- Code dominated by external system behavior
- UI rendering or user-facing latency-sensitive code (profile instead)

### Profiling vs. Benchmarking

- Use profiling tools (flamegraph, perf) to *identify* bottlenecks
- Use benchmarks to *verify* fixes and prevent regressions
- Profile first; benchmark second

Benchmark what actually matters to end-user performance and business metrics.

---

## **Setting Up Benchmarks with Criterion**

### Minimal Criterion Setup

A minimal Criterion benchmark includes:

- A `Criterion` context
- One or more benchmark functions
- Registration macros

Example benchmark file (`benches/algorithm_bench.rs`):

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};

// Hypothetical function from the library being benchmarked
fn fibonacci_recursive(n: u64) -> u64 {
  match n {
    0 => 0,
    1 => 1,
    n => fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2),
  }
}

fn fibonacci_iterative(n: u64) -> u64 {
  let mut a = 0u64;
  let mut b = 1u64;
  for _ in 0..n {
    let temp = a + b;
    a = b;
    b = temp;
  }
  a
}

fn bench_fibonacci(c: &mut Criterion) {
  c.bench_function("fibonacci_recursive_20", |b| {
    b.iter(|| fibonacci_recursive(black_box(20)))
  });

  c.bench_function("fibonacci_iterative_20", |b| {
    b.iter(|| fibonacci_iterative(black_box(20)))
  });
}

criterion_group!(benches, bench_fibonacci);
criterion_main!(benches);
```

### Advanced: Parametrized Benchmarks

For comprehensive coverage, parametrize benchmarks across realistic input ranges:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};

fn bench_fibonacci_parametrized(c: &mut Criterion) {
  let mut group = c.benchmark_group("fibonacci_parametrized");
  
  for n in [10, 15, 20, 25].iter() {
    group.bench_with_input(BenchmarkId::from_parameter(n), n, |b, &n| {
      b.iter(|| fibonacci_iterative(black_box(n)))
    });
  }
  
  group.finish();
}

criterion_group!(benches, bench_fibonacci_parametrized);
criterion_main!(benches);
```

This reveals how performance scales with input size—critical for identifying algorithmic complexity issues.

### Advanced: Custom Measurement and Baseline Comparison

For production code, establish baselines and detect regressions:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};

fn bench_with_baseline(c: &mut Criterion) {
  let mut group = c.benchmark_group("sorting");
  
  // Set comparison baseline for regression detection
  group.bench_function("quicksort_1000", |b| {
    let data = vec![/* 1000 elements */];
    b.iter(|| {
      let mut sorted = black_box(data.clone());
      quicksort(&mut sorted);
      sorted
    })
  });

  // Compare against alternative
  group.bench_function("heapsort_1000", |b| {
    let data = vec![/* 1000 elements */];
    b.iter(|| {
      let mut sorted = black_box(data.clone());
      heapsort(&mut sorted);
      sorted
    })
  });
  
  group.finish();
}

criterion_group!(benches, bench_with_baseline);
criterion_main!(benches);
```

### Key Components Explained

- **`Criterion`**
  - Manages measurement configuration, statistical analysis, and regression detection
  - Automatically warms up the CPU, accounts for noise, and runs multiple iterations
  - Generates HTML reports and JSON data for trending analysis

- **`criterion_group!`**
  - Groups related benchmarks for logical organization
  - Allows applying configuration to multiple benchmarks at once
  - Essential for managing test runs in CI environments

- **`criterion_main!`**
  - Defines the benchmark entry point
  - Must be called exactly once per binary
  - Parses command-line arguments for filtering and verbosity

- **`black_box()`**
  - Prevents compiler optimizations (constant folding, dead code elimination) from removing or simplifying benchmarked code
  - Ensures measurements reflect real-world execution, not compile-time optimizations
  - Critical: forgetting `black_box()` on inputs often produces misleading sub-nanosecond results

- **`BenchmarkId`**
  - Parameterizes benchmarks with meaningful identifiers
  - Supports complex input shapes: `BenchmarkId::new("algorithm", format!("{} elements", n))`
  - Enables trend analysis as inputs scale

---

## **Running Benchmarks**

Benchmarks are executed using Cargo:

```bash
# Run all benchmarks in release mode
cargo bench

# Run a specific benchmark by name
cargo bench fibonacci

# Run with verbose output
cargo bench -- --verbose

# Run with custom number of samples
cargo bench -- --sample-size 100
```

Cargo will:

- Compile benchmarks in release mode (aggressive optimizations enabled)
- Execute Criterion-managed runs with statistical sampling
- Produce detailed timing and statistical output
- Generate HTML reports in `target/criterion/`

Results can be compared across runs to detect regressions or improvements. Criterion stores historical data automatically.

---

## **Interpreting Benchmark Results**

### Understanding Statistical Output

Criterion displays:

- **Mean**: Average execution time across all samples
- **Median**: Middle value, more robust to outliers than mean
- **Std Dev**: Spread in measurements; low std dev indicates stable code
- **Outliers**: Measurements that deviate significantly (often detected and excluded)

Example output:

```text
fibonacci_20                time:   [2.3456 ms 2.3489 ms 2.3526 ms]
              change: [-1.2% -0.8% -0.3%] (within noise)
```

### Regression Detection

Criterion automatically flags regressions:

- `+5.3%` change is typically considered significant
- Multiple test runs reduce false positives
- HTML reports visualize trends across commits

### Avoiding Misinterpretation

- Focus on trends and statistical significance, not single-run numbers
- Tiny differences (< 1-2%) are within measurement noise
- Absolute numbers depend on hardware; relative comparisons are meaningful

- High variance may indicate:
  - CPU throttling or thermal changes
  - Background system activity
  - Input-dependent performance (e.g., branch mis-predictions)
  - Need for additional samples or noise filtering

Benchmarks inform decisions; they do not replace sound engineering judgment.

---

## **Common Benchmarking Pitfalls**

### 1. Forgetting `black_box()`

```rust
// WRONG: Compiler optimizes away the computation
c.bench_function("bad", |b| b.iter(|| fibonacci(20)));

// CORRECT: Forces evaluation
c.bench_function("good", |b| b.iter(|| fibonacci(black_box(20))));
```

### 2. Allocating Inside the Benchmark

```rust
// WRONG: Measures allocation overhead, not algorithm
c.bench_function("bad_vec", |b| {
  b.iter(|| vec![1, 2, 3, 4, 5])
});

// CORRECT: Pre-allocate, benchmark the computation
c.bench_function("good_sort", |b| {
  let mut data = vec![3, 1, 4, 1, 5];
  b.iter(|| {
    let mut sorted = black_box(data.clone());
    sorted.sort();
  })
});
```

### 3. Not Accounting for Setup Overhead

Use `b.iter_batched()` to separate setup from measurement:

```rust
c.bench_function("parse_json", |b| {
  b.iter_batched(
    || r#"{"key":"value"}"#.to_string(),  // Setup (not measured)
    |json| serde_json::from_str::<Value>(&json),  // Measured
    criterion::BatchSize::SmallInput,
  )
});
```

### 4. Not Isolating from External Factors

- Run on idle systems with minimal background processes
- Disable CPU frequency scaling and power management for consistent results
- Use consistent environments across CI runs
- Be aware of Turbo Boost and thermal throttling effects

### 5. Measuring the Wrong Thing

- Benchmark the operation users care about, not micro-optimizations
- Realistic input sizes and patterns matter
- A 10% improvement on an operation that takes 1% of runtime is irrelevant

---

## **Integrating Benchmarks into CI/CD**

When integrated with version control and CI, benchmarks become a guardrail against accidental regressions. Teams should:

1. Run benchmarks on every pull request
2. Fail CI if regressions exceed acceptable thresholds (e.g., 5%)
3. Archive benchmark results for long-term trend analysis
4. Share benchmark results with stakeholders to validate business decisions


### Example GitHub Actions workflow

```yaml
name: Benchmarks

on: [pull_request]

jobs:
  benchmark:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - uses: dtolnay/rust-toolchain@stable
    - run: cargo bench --no-run
    - run: cargo bench -- --output-format bencher | tee output.txt
    - uses: benchmark-action/github-action@v1
    with:
      tool: 'cargo'
      output-file-path: output.txt
```

---

## **Professional Applications and Implementation**

In production Rust systems, benchmarking supports performance-sensitive development in areas such as:

- **Backend Services**: HTTP handler throughput, database query latency
- **Systems Tooling**: File processing speed, command-line tool responsiveness
- **Data Processing**: ETL pipeline throughput, analytics query latency
- **Embedded Applications**: Real-time constraint validation, resource utilization
- **Cryptography & Security**: Constant-time operations (via statistical stability analysis)

Criterion-based benchmarks enable teams to:

- Validate optimizations with statistical rigor
- Justify architectural decisions with empirical evidence
- Ensure performance stability across releases
- Prevent accidental regressions via CI integration
- Track performance trends over months and years

---

## **Key Takeaways**

| Area        | Summary                                                                                    |
| ---------   | ---------------------------------------------------------------------------                |
| Purpose     | Benchmarking measures performance and detects regressions with statistical rigor.          |
| Tooling     | Criterion provides statistically robust benchmarks with regression detection.              |
| Structure   | Benchmarks live in `benches/` and compile as separate binaries.                            |
| Setup       | `criterion_group!`, `criterion_main!`, `black_box()`, and `BenchmarkId` form the core API. |
| Execution   | `cargo bench` runs benchmarks in optimized mode with statistical sampling.                 |
| Integration | CI/CD pipelines enforce performance baselines across commits.                              |

- Benchmark only performance-critical code paths identified through profiling
- Use Criterion for reliable, repeatable results with automatic regression detection
- Prevent compiler optimizations from skewing measurements via `black_box()`
- Parametrize benchmarks to understand performance scaling across input ranges
- Treat benchmarks as long-term performance safeguards, not one-time checks
- Integrate benchmarks into CI pipelines to enforce performance standards
- Analyze trends, not individual runs; statistical significance matters
- Separate setup overhead from measured operations using `iter_batched()`
- Run benchmarks on isolated systems; control for hardware variability

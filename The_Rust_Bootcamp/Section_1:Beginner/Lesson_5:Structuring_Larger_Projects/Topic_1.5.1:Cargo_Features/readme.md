# **Topic 1.5.1: Cargo Features**

Cargo features provide a compile-time mechanism for conditionally including code and dependencies in a Rust project. They enable developers to tailor functionality, reduce binary size, and support multiple use cases—such as client versus server builds—without maintaining separate codebases. Features are resolved at compile time and integrate directly with Rust's conditional compilation system, making them a core tool for scalable and configurable Rust applications.

## **Learning Objectives**

- Understand how Cargo features control conditional compilation and interact with the resolver
- Define optional functionality and dependencies using feature flags with proper naming conventions
- Use features to support multiple build variants within a single crate while avoiding feature flag hell
- Apply inline `cfg` attributes strategically to selectively compile code paths without runtime overhead
- Enable and manage features through Cargo configuration, CLI workflows, and dependency resolution
- Design features that compose well across dependency graphs and avoid common pitfalls

---

## **Conditional Compilation with Cargo Features**

Cargo features define named compile-time flags that control which code is included in a build. Unlike runtime configuration, feature resolution happens during dependency resolution and affects which code paths are even compiled into the binary.

### Key distinctions from runtime configuration

- Features are resolved once per dependency graph and cannot be changed at runtime
- Disabled features result in dead code elimination at compile time, not runtime conditionals
- Feature combinations must be unifiable across all transitive dependencies
- The feature resolver ensures consistency; conflicting requirements cause build failures

### Feature Resolution and Unification

When multiple crates depend on the same library with different feature requirements, Cargo applies feature unification: the union of all requested features is enabled. This design choice prevents subtle bugs where different parts of your application see different behavior.

```toml
# Dependency A requests
my_lib = { version = "1.0", features = ["logging"] }

# Dependency B requests
my_lib = { version = "1.0", features = ["metrics"] }

# Result: my_lib compiles with both "logging" and "metrics" enabled
```

> **Critical implication:** Features must be additive and compose safely. A feature should not disable or contradict another feature's behavior.

### Use Case Taxonomy

**1. Platform-Specific Logic:**

```rust
#[cfg(feature = "use_native_tls")]
use native_tls::TlsConnector;

#[cfg(not(feature = "use_native_tls"))]
use rustls::ClientConfig;
```

**2. Optional Heavy Dependencies:**

- Database drivers (postgres, mysql, sqlite)
- Serialization formats (serde, bincode, protobuf)
- Async runtimes (tokio, async-std)

**3. Build Variants:**

- Development vs. production optimizations
- Client vs. server functionality
- Experimental or unstable APIs

**4. Compile-Time Optimizations:**

- Including SIMD accelerations
- Platform-specific optimizations
- Feature-specific inlining hints

---

## **Defining Features in `Cargo.toml`**

Features are declared under the `[features]` section as key-value pairs. The value is a list of feature names that this feature depends upon, or optional dependencies it activates.

```toml
[package]
name = "my_app"
version = "0.1.0"

[features]
# Empty feature (acts as a compile-time flag)
client = []
server = []

# Feature that depends on other features
full = ["client", "server", "advanced-metrics"]

# Default features (enabled unless --no-default-features is used)
default = ["client", "std"]

# Marker features for advanced use cases
std = []
alloc = []

[dependencies]
tokio = "1.0"
serde = { version = "1.0", optional = true }
reqwest = { version = "0.11", optional = true }
sqlx = { version = "0.7", optional = true }
tracing = "0.1"

[dev-dependencies]
criterion = "0.5"
```

### Feature Naming Conventions

Senior Rust developers follow these conventions for maintainability:

- **Positive framing:** `"use_native_tls"` instead of `"no_rustls"` (easier to reason about what's enabled)
- **Descriptive names:** `"async_runtime_tokio"` is clearer than `"async"` when multiple async runtimes are possible
- **Consistency across ecosystem:** Follow patterns established by popular crates in your domain
- **Avoid abbreviations:** `"database_connection_pooling"` > `"db_pool"`

### Optional Dependencies

Optional dependencies are not included by default but can be activated when a feature requests them:

```toml
[dependencies]
# Mandatory dependency
log = "0.4"

# Optional dependencies
serde = { version = "1.0", optional = true }
serde_json = { version = "1.0", optional = true }
postgres = { version = "0.19", optional = true }
sqlite = { version = "0.29", optional = true }

[features]
# Serialization features
serialization = ["serde", "serde_json"]

# Database features
db_postgres = ["postgres"]
db_sqlite = ["sqlite"]

# Comprehensive feature
database = ["db_postgres", "db_sqlite"]
```

### The `dep:` prefix pattern

Use the `dep:` syntax to have more control over feature names and preventing accidental enablement

- **Namespacing**: It explicitly namespaces a feature to an underlying dependency, letting you define features like my_lib_with_serde = ["dep:serde"] even if the dependency is just named serde.
- **Prevents implicit features**: Without dep:, any optional dependency automatically creates a feature with the same name (e.g., [dependencies] my-dep = {..., optional = true} creates an implicit my-dep feature).
- **Control over enablement**: Using dep: allows you to enable an optional dependency's feature only if other features (that rely on it) are active, preventing the dependency from being pulled in unnecessarily.

#### Example

```toml
[dependencies]
tokio = { version = "1.0", optional = true }

[features]
# Good: explicit about which dependency is activated
runtime = ["dep:tokio"]

# Without dep: prefix, creates a feature named "tokio" that might conflict
# with other uses of the name
```

### Dependency Sub-Features

Forward-enable features of optional dependencies using the `dependency?/sub_feature` syntax:

```toml
[dependencies]
tokio = { version = "1.0", optional = true, features = ["sync"] }
reqwest = { version = "0.11", optional = true }

[features]
# Enable reqwest only if client feature is requested
client = ["dep:reqwest", "reqwest?/json", "reqwest?/cookies"]

# Conditionally enable tokio features
async_runtime = ["dep:tokio", "tokio?/full"]
```

**Why this matters:**

- The `?` indicates "only enable if the dependency is active"
- Without `?`, a compilation error occurs if the dependency is not enabled
- This pattern prevents accidental feature gaps in dependency combinations

---

## **Inline Feature Flags in Code**

### Attribute-Based Gating

The `#[cfg(feature = "...")]` attribute controls compilation at multiple levels:

```rust
// Module-level gating (entire module excluded if feature disabled)
#[cfg(feature = "async_runtime")]
pub mod async_executor;

// Function-level gating
#[cfg(feature = "client")]
pub async fn connect(addr: &str) -> Result<Connection> {
  reqwest::Client::new()
    .get(addr)
    .send()
    .await
}

// Struct field gating (useful for conditional fields)
pub struct Config {
  pub host: String,
  
  #[cfg(feature = "tls")]
  pub tls_config: TlsConfig,
}

// Trait implementation gating
#[cfg(feature = "serialization")]
impl serde::Serialize for MyData {
  fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error> {
    // implementation
  }
}
```

### Conditional Compilation Logic

Combine multiple conditions for complex scenarios:

```rust
// Require multiple features
#[cfg(all(feature = "database", feature = "async_runtime"))]
pub async fn query_database(conn: &Pool) -> Result<Vec<Row>> {
  conn.execute("SELECT * FROM users").await
}

// Disjunctive conditions (any feature)
#[cfg(any(
  feature = "db_postgres",
  feature = "db_sqlite",
  feature = "db_mysql"
))]
pub mod database;

// Negation (feature disabled)
#[cfg(not(feature = "std"))]
extern crate alloc;
use alloc::vec::Vec;

// Platform + feature combinations
#[cfg(all(target_os = "windows", feature = "native_tls"))]
fn setup_tls() { /* Windows-specific TLS setup */ }
```

### Compile Error Guidance

Provide helpful compile-time errors when features are misused:

```rust
// Example: Ensure at least one serialization format is enabled
const _: () = {
  #[cfg(not(any(
    feature = "serialize_json",
    feature = "serialize_bincode",
    feature = "serialize_protobuf"
  )))]
  compile_error!(
    "At least one serialization feature must be enabled: \
     serialize_json, serialize_bincode, or serialize_protobuf"
  );
};
```

### Performance Implications

Feature gates have zero runtime cost:

- Disabled code is entirely eliminated during compilation
- No branching or runtime checks
- Binary size reduction matches disabled feature scope
- Compiler can optimize more aggressively with fewer code paths

---

## **Enabling Features During Builds**

### CLI-Based Feature Selection

Features are enabled through Cargo command-line arguments:

```bash
# Enable single feature
cargo build --features client

# Enable multiple features
cargo build --features "client,serialization,metrics"

# Disable all defaults and enable specific features
cargo build --no-default-features --features "server,database"

# Release builds with features
cargo build --release --features "full"

# Test with specific features
cargo test --features "client" --lib
cargo test --no-default-features --features "server" --test integration_tests
```

#### Advanced CLI patterns

```bash
# Build and list what features are active (using cargo tree)
cargo tree --features "client,metrics" --depth 1

# Check feature combinations compile (useful in CI)
cargo check --all-features
cargo check --no-default-features
```

### Feature Configuration in Cargo.toml

Crates that depend on your library can specify which features to use:

```toml
[dependencies]
my_lib = { version = "0.5", features = ["client", "serialization"] }

# For optional use of your library
my_lib = { version = "0.5", optional = true, features = ["minimal"] }
```

### Workspace-level feature coordination

```toml
# In workspace root Cargo.toml
[workspace]
members = ["server", "client", "shared"]

# Workspace packages can reference each other with features
[dependencies]
shared = { path = "./shared", features = ["serialization"] }
```

### Feature Unification and Dependency Graphs

Understanding how Cargo resolves features across the dependency graph prevents subtle bugs:

```text
Your App
├── Database Crate (requests "async")
│   └── Connection Pool (requests "logging")
├── Web Server (requests "async" + "compression")
│   └── TLS Library (requests "native_tls")
└── Logger (requests "async")

Result: All dependencies compile with:
- async (unified from multiple requests)
- logging (from connection pool)
- compression (from web server)
- native_tls (from TLS library)
```

If two crates request incompatible features (which should never happen by design), Cargo fails the build with a clear error.

---

## **Feature Patterns and Anti-Patterns**

### The Minimal Build Pattern

Create a feature set for the absolute minimum:

```toml
[features]
default = ["std", "logging"]

# Minimal feature for embedded systems
minimal = []

# Standard feature set
std = ["dep:std"]

# Comprehensive feature set
full = ["std", "logging", "metrics", "tracing", "serialization"]

# Development features (not published)
dev = ["full", "criterion"]
```

### Mutually Exclusive Features (Anti-Pattern)

Features should NOT be designed as mutually exclusive (choose one or the other). This breaks feature unification:

```toml
# ❌ BAD: These should never be used together
[features]
use_native_tls = []
use_rustls = []
```

Instead, design features that compose:

```toml
# ✅ GOOD: Each can be enabled independently
[features]
tls_native = ["dep:native-tls"]
tls_rustls = ["dep:rustls"]
tls = ["tls_native"]  # default to native, but can be changed

# Allows: --no-default-features --features tls_rustls
```

### The "All Features" Anti-Pattern

Avoid a catch-all feature that enables everything unsuitably:

```toml
# ❌ PROBLEMATIC: Enables conflicting combinations
[features]
all = ["tls_native", "tls_rustls", "async_tokio", "async_async_std"]

# ✅ BETTER: Define specific useful combinations
[features]
default = ["std"]
async_http = ["dep:tokio", "dep:reqwest"]
database = ["dep:sqlx"]
full = ["std", "async_http", "database"]
```

---

## **Real-World Use Cases**

Cargo features are essential in large-scale Rust systems for managing the complexity-vs-capability tradeoff:

**1. Library Ecosystems**
Major libraries like `tokio`, `hyper`, and `serde` use extensive feature flags to allow consumers to pay only for what they use. `tokio` has features for each runtime component, allowing users to include only `sync` primitives without the full scheduler.

**2. Embedded and no_std Systems**
Features manage dependencies on `std` and `alloc`:

```rust
#[cfg(not(feature = "std"))]
extern crate core;

#[cfg(feature = "alloc")]
extern crate alloc;
```

**3. Database Access Layers**
Different database backends are optional features, preventing unnecessary dependency bloat:

```toml
[features]
db_postgresql = ["dep:sqlx", "sqlx?/postgres"]
db_mysql = ["dep:sqlx", "sqlx?/mysql"]
db_sqlite = ["dep:sqlx", "sqlx?/sqlite"]
```

**4. Compile-Time Optimization**
Enable SIMD or platform-specific optimizations conditionally:

```rust
#[cfg(all(target_arch = "x86_64", feature = "simd"))]
mod simd_impl;

#[cfg(not(all(target_arch = "x86_64", feature = "simd")))]
mod portable_impl;
```

**5. Testing and Benchmarking**
Development features include heavy test utilities:

```toml
[features]
default = []
with_test_utils = ["tempfile", "criterion"]

[dev-dependencies]
# Only available when running tests with --features with_test_utils
```

---

## **Professional Applications and Implementation**

Cargo features are widely used in production Rust systems to manage complexity without fragmenting codebases. They enable configurable builds for different environments, optional integrations (such as databases or network clients), and experimental functionality guarded behind flags. Proper feature design improves compile times, reduces binary size, and allows libraries to remain flexible while maintaining stable public APIs.

---

## **Key Takeaways**

| Concept               | Summary                                                                                        |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| Cargo Features        | Compile-time flags controlling conditional code inclusion; resolved once per dependency graph. |
| Feature Unification   | Union of all requested features across dependencies; requires additive, composable design.     |
| Optional Dependencies | Dependencies activated only when required by a feature; use `dep:` prefix to disambiguate.     |
| `cfg` Attributes      | Gate code at compile time (zero runtime cost); support negation, conjunction, and disjunction. |
| Build-Time Control    | Features selected via CLI (`--features`), `Cargo.toml`, or workspace configuration.            |
| Naming Conventions    | Use positive framing, descriptive names, and consistency with ecosystem patterns.              |

- Design features to be orthogonal and composable; avoid mutually exclusive feature sets
- Use `#[cfg(...)]` at appropriate granularity (module, struct, function, field)
- Understand feature resolution and unification to prevent subtle dependency bugs
- Provide compile-time errors when invalid feature combinations are attempted
- Document which features are required for different use cases
- Test feature combinations in CI to catch integration issues early
- Remember that all-features builds should remain compilable and sensible

# **Topic 1.4.4: Publishing Your Package**

This topic explains how Rust packages are published for reuse by other developers. It covers the role of crates.io as the default public registry, the metadata required for publication, the publishing workflow, and post-publication version management. Publishing crates is a core part of participating in the Rust ecosystem and sharing reusable, well-engineered components.

## **Learning Objectives**

- Understand the purpose and benefits of publishing Rust packages
- Identify crates.io as Rust's default public registry
- Configure required project metadata for publication
- Execute the publishing workflow safely and correctly
- Manage versions and yanked releases after publication
- Recognize advanced publishing patterns and best practices
- Apply semantic versioning discipline to maintain API stability

---

## **Publishing Overview**

Publishing a package allows other developers to:

- Depend on your code in their own projects
- Reuse well-tested, documented functionality
- Contribute improvements and fixes
- Build upon battle-tested abstractions

By default, Rust packages are published to **crates.io**, the official public registry maintained by the Rust community.

### Ecosystem Considerations

As a senior developer, understand that publishing is not merely uploading code—it's entering a social contract with downstream users. Once a crate reaches 1.0.0, users depend on your stability guarantees, security practices, and responsiveness to issues. Public crates should demonstrate:

- Comprehensive documentation with real-world examples
- Thorough test coverage (including edge cases)
- Clear deprecation paths for API changes
- Active maintenance and security response protocols

### Supply Chain Security

Publishing crates makes you part of the Rust supply chain:

- Dependencies should be well-maintained and trustworthy
- Avoid unnecessary dependencies (weight vs. benefit)
- Regularly update dependencies and audit for vulnerabilities
- Use tools like `cargo-audit` and `cargo-deny` in CI/CD

```bash
cargo install cargo-audit
cargo audit  # Detect known vulnerabilities
```

### Documentation as a Quality Metric

Documentation completeness correlates with crate reliability:

- Every public item should have documentation
- Examples should compile and demonstrate real use
- Maintain a comprehensive README with setup, usage, and examples
- Document failure modes and error handling clearly

```bash
cargo doc --open --no-deps --all-features
```

Generate and review local documentation before publishing

---

## **Crates.io**

crates.io is the central repository for public Rust crates and the de facto package manager for the Rust ecosystem.

### Key Characteristics

- Authentication currently occurs through **GitHub OAuth**
- Publishing uses an **API token** generated from the crates.io account
- Publicly hosts versioned crate releases, metadata, and documentation
- Automatically generates and hosts documentation on docs.rs
- Enforces immutability of released versions

### Authentication

Authentication is configured locally with:

```bash
cargo login <API_TOKEN>
```

The token is stored in `~/.cargo/credentials.toml` and grants permission to publish and manage crates associated with the account.

### Security Best Practices

- Tokens should be treated as sensitive credentials; never commit them to version control
- Use scoped tokens with limited permissions when available
- Rotate tokens periodically, especially if exposed
- Consider using `cargo:// protocol for CI/CD environments with token-based authentication

### Registry Alternatives

While crates.io is the default, enterprise organizations may use private registries:

```toml
[registries.internal]
index = "https://internal-registry.company.com/git/index"

[net]
default-auth = "cargo-credential"
```

---

## **Project Metadata**

Before a package can be published, required metadata must be defined in `Cargo.toml`. This metadata serves multiple purposes: uniqueness guarantees, dependency resolution, documentation generation, and discoverability.

### Required Fields

- `name` — must be globally unique on crates.io; follows kebab-case convention
- `version` — follows semantic versioning (MAJOR.MINOR.PATCH)
- `edition` — Rust language edition (e.g., 2021)
- `description` — short summary of crate purpose (max 256 characters)
- `license` or `license-file` — SPDX identifier or path to license file

### Recommended Fields

- `authors` — author names and/or emails
- `repository` — Git repository URL for source code
- `homepage` — project website or documentation URL
- `documentation` — custom documentation URL (defaults to docs.rs)
- `readme` — path to README file (defaults to `README.md`)
- `keywords` — up to 5 searchable keywords
- `categories` — up to 5 categories from crates.io taxonomy
- `license-file` — explicit license file location for custom licenses

### Example Comprehensive Cargo.toml

```toml
[package]
name = "async-request-handler"
version = "0.3.2"
edition = "2021"
rust-version = "1.70"
authors = ["Jane Doe <jane@example.com>"]
description = "High-performance async HTTP request handling with built-in rate limiting and circuit breaker patterns"
license = "MIT OR Apache-2.0"
repository = "https://github.com/example/async-request-handler"
documentation = "https://docs.rs/async-request-handler"
homepage = "https://github.com/example/async-request-handler"
readme = "README.md"
keywords = ["async", "http", "rate-limiting", "circuit-breaker"]
categories = ["network-programming", "asynchronous"]

[lib]
name = "async_request_handler"
path = "src/lib.rs"

[dependencies]
tokio = { version = "1.35", features = ["full"] }
hyper = "1.0"
serde = { version = "1.0", features = ["derive"] }

[dev-dependencies]
tokio-test = "0.4"
```

### Cargo Validation

Cargo will refuse to publish if:

- Required metadata is missing or invalid
- The package name is already taken
- There are uncommitted or modified files in the Git repository
- The crate version already exists for that package
- The crate contains or links to unacceptable content per community guidelines

**Advanced Consideration:** The `publish` field in `Cargo.toml` can restrict publishing:

```toml
[package]
publish = ["crates-io"]  # Only allow publishing to crates.io
# or
publish = false  # Prevent publishing entirely (useful for private/workspace crates)
```

---

## **Publishing Process**

Publishing is handled entirely through Cargo and involves multiple safety checks to prevent accidents.

### Pre-Publication Quality Assurance

Before publishing any crate, senior developers should execute:

```bash
# Format code consistently
cargo fmt --check

# Lint for common mistakes and style improvements
cargo clippy --all-targets --all-features -- -D warnings

# Compile with all features and targets
cargo build --all-features --all-targets

# Run comprehensive test suite
cargo test --all-features --lib
cargo test --all-features --doc
cargo test --all-features --test '*'

# Check documentation compiles and examples work
cargo test --doc --all-features

# Verify your README parses correctly
cargo readme --check
```

### Documentation Quality

High-quality crates include:

**Crate-level documentation** (`src/lib.rs`):

```rust
//! # async-request-handler
//!
//! High-performance async HTTP request handling with built-in rate limiting.
//!
//! ## Quick Start
//!
//! ```rust
//! use async_request_handler::RequestHandler;
//!
//! #[tokio::main]
//! async fn main() {
//!     let handler = RequestHandler::new();
//!     // Use handler...
//! }
//! ```
//!
//! ## Features
//!
//! - Asynchronous request processing
//! - Built-in rate limiting and circuit breaker
//! - Full observability with tracing support
```

**Module documentation** with examples:

```rust
/// Handles concurrent HTTP requests with rate limiting.
///
/// # Examples
///
/// ```
/// use async_request_handler::RateLimiter;
/// use std::time::Duration;
///
/// #[tokio::main]
/// async fn main() {
///     let limiter = RateLimiter::new(10, Duration::from_secs(1));
///     for _ in 0..10 {
///         limiter.acquire().await;
///     }
/// }
/// ```
pub struct RateLimiter { /* ... */ }
```

### Dry Run Publication

A dry run is **strongly recommended** and mimics the full publishing process without uploading:

```bash
cargo publish --dry-run --all-features
```

This validates:

- All metadata is present and correct
- The crate compiles in release mode
- Documentation builds successfully
- No uncommitted files exist
- Package contents are as expected

### Actual Publication

Once satisfied with the dry run:

```bash
cargo publish --all-features
```

Cargo performs these steps:

1. Validates crate metadata completeness
2. Checks Git working directory is clean
3. Builds the crate in release mode with all features
4. Generates and validates documentation
5. Packages source code, stripping unnecessary files
6. Uploads tarball and metadata to crates.io
7. Indexes the crate for discoverability

**Important:** This process is irreversible for that specific version.

---

## **After Publishing**

Once published, a crate version becomes immutable on crates.io. This immutability is intentional—it ensures reproducible builds and prevents supply chain attacks.

### Version Bumping and Semantic Versioning

Semantic versioning (SEMVER) communicates API stability to downstream users:

```toml
MAJOR.MINOR.PATCH[-prerelease][+metadata]
```

**Patch** — bug fixes, internal improvements:

```toml
# 0.1.0 → 0.1.1
# Backward compatible; existing code continues working
```

Example: Fixing a performance regression or a subtle correctness bug without changing public API.

**Minor** — backward-compatible feature additions:

```toml
# 0.1.0 → 0.2.0
# New functionality; existing code continues working
```

Example: Adding new public methods or optional parameters with defaults.

**Major** — breaking changes:

```toml
# 0.1.0 → 1.0.0
# API incompatible; requires user code updates
```

Example: Changing function signatures, removing public types, or altering error types.

**Advanced Versioning Considerations:**

Pre-release versions signal instability:

```toml
version = "0.3.0-alpha.1"  # Internal testing phase
version = "0.3.0-beta.2"   # Feature complete, bug fixing
version = "0.3.0-rc.1"     # Release candidate
```

### Yanking Versions

Yanking marks a version as unavailable for new dependencies without deleting it from the registry:

```bash
cargo yank --vers 0.1.0
cargo yank --vers 0.1.0 --undo  # Restore a yanked version
```

**Yanked versions:**

- Cannot be newly added as dependencies by other crates
- Remain available in existing `Cargo.lock` files (reproducibility)
- Preserve historical build chains and transitive dependencies

**Appropriate Use Cases:**

- **Critical bugs**: A subtle data corruption bug discovered post-publication
- **Security issues**: A dependency vulnerability or unsafe code path
- **Accidental releases**: Publishing to the wrong crate or malformed metadata
- **API stability**: Yanking pre-1.0 experimental releases before stabilization

**Senior Developer Perspective:** Yanking should be rare if pre-publication processes are robust. It signals process failures and erodes user confidence. Instead, invest in pre-release testing and CI/CD validation.

### Deprecation Paths

For breaking changes, provide deprecation warnings before major version bumps:

```rust
#[deprecated(since = "0.5.0", note = "Use `new_function` instead")]
pub fn old_function() {
  // ...
}
```

This guides users while maintaining compatibility across multiple releases.

---

## **Professional Applications and Implementation**

Real-World Publishing Scenarios:

### Scenario 1: Publishing an Internal Library Publicly

An organization decides to open-source an internal async runtime wrapper. Consider:

- Feature flags to expose implementation details optional to users
- Comprehensive benchmarks in documentation
- Clear governance and maintenance policy
- Security policy for reporting vulnerabilities
- Compatibility matrix (Rust versions, platforms)

```toml
[features]
default = ["runtime"]
runtime = ["tokio"]
internal-diagnostics = []  # Internal use, unstable API
```

### Scenario 2: Iterating Through Pre-1.0 Releases

A crate is in active design phase (0.x versions):

- Each minor version bump signals potential breaking changes
- Users understand 0.5 → 0.6 may break their code
- Clear CHANGELOG documents rationale for breaks
- Consider pre-1.0 API stability guarantees

### Scenario 3: Long-Term Maintenance

A stable 1.0+ crate requires:

- Strict semantic versioning discipline
- Deprecation warnings two minor releases before removal
- Clear upgrade guides
- Proactive security scanning (RUSTSEC advisory tracking)
- Responsibility to downstream ecosystem

---

## **Key Takeaways**

| Concept    | Summary                                                                             |
| ---------- | ----------------------------------------------------------------------------------  |
| Publishing | Integrates your crate into the Rust ecosystem; signals professionalism and trust.   |
| Crates.io  | Official public registry with GitHub OAuth authentication and immutable versions.   |
| Metadata   | Required fields ensure discoverability, licensing clarity, and compatibility.       |
| Workflow   | Dry runs, quality checks, and comprehensive testing prevent publishing errors.      |
| Versioning | Semantic versioning governs compatibility expectations and breaking changes.        |
| Yanking    | Rare but necessary mechanism to protect users from broken or unsafe releases.       |
| Maintenance| Publishing creates long-term responsibilities to downstream users and the ecosystem.|

**Core Principles:**

- Publishing is a commitment to the Rust ecosystem—maintain quality and stability
- Cargo enforces metadata completeness and repository cleanliness to prevent mistakes
- Pre-publish checks (formatting, linting, testing, documentation) establish professional standards
- Versions are immutable once published; plan carefully and use dry runs
- Semantic versioning discipline prevents downstream surprises and maintains trust
- Yanking is a safety valve, not a solution; invest in preventing the need for it
- Documentation quality is inseparable from code quality—treat them equally
- Long-term crate maintenance requires proactive dependency management and security awareness

# **Topic 1.4.2: Modules**

This topic explains Rust's module system as the primary mechanism for organizing code, controlling visibility, and managing namespaces within a crate. Modules define logical boundaries, enable reuse, and enforce encapsulation through explicit declarations and privacy rules. Mastery of modules is essential for building readable, maintainable, and scalable Rust applications.

## **Learning Objectives**

- Understand the purpose and structure of Rust modules and the module tree
- Declare modules explicitly using the `mod` keyword and understand path resolution
- Control visibility and privacy with `pub` and scoped modifiers at varying granularities
- Import items into scope using absolute and relative paths with proper conventions
- Re-export items strategically to create clean, stable, and maintainable public APIs
- Organize modules across multiple files and directories for scalable architecture
- Apply advanced patterns including visibility scoping, prelude design, and API boundaries
- Recognize common pitfalls and anti-patterns in module organization

---

## **Module Fundamentals**

Modules are the fundamental building block of Rust's organizational system. They provide a mechanism to control:

- **Code organization** - Logical grouping of related functionality, including:
  - Functions
  - Structs
  - Enums
  - Type aliases
  - Traits
  - Constants and statics
  - Nested modules
- **Scope** - Namespace boundaries preventing naming conflicts and establishing clear ownership
- **Visibility and privacy** - Explicit control over what's exposed vs. internal, enforced at compile-time
- **Encapsulation** - Hiding implementation details and exposing clean, versioned interfaces

### Key characteristics

- Modules are **explicitly defined** using the `mod` keyword (not inferred from filesystem layout)
- Logical structure is **not automatically inferred from the filesystem** — the developer must declare module relationships
- Modules form a **hierarchical namespace tree** within a crate with a single root
- The module tree is separate from the filesystem structure, providing flexibility in organization
- Privacy rules apply at the module level and cascade through the hierarchy

### Understanding the Module Tree

Every crate has a single implicit root module. For binary crates, this is `main` (from `main.rs`); for libraries, it's `lib` (from `lib.rs`). The module tree is built through explicit declarations:

```rust
// In lib.rs or main.rs
mod network;           // declares the network module
mod utils;             // declares the utils module
mod database {         // inline module declaration
    pub mod connection;
}
```

This creates a tree structure:

```text
crate (root)
├── network
├── utils
└── database
    └── connection
```

### Basic inline module example

```rust
mod math {
    pub fn add(a: i32, b: i32) -> i32 {
        a + b
    }

    pub fn multiply(a: i32, b: i32) -> i32 {
        a * b
    }
}

fn main() {
    let sum = math::add(2, 3);
    let product = math::multiply(4, 5);
    println!("Sum: {}, Product: {}", sum, product);
}
```

When declaring `mod math`, Rust looks for either:

1. An inline module block (as shown above)
2. A file named `math.rs` in the same directory
3. A directory named `math/` with a `mod.rs` file

---

## **Module file structure**

These three organizational patterns represent different scalability approaches. The choice depends on your module's complexity and anticipated growth.

### Option 1: Inline Module

- Module is defined directly within another file using curly braces
- Simple structure suitable for very small, single-use utilities
- Keeps related code together without additional files
- Becomes unwieldy as the module grows

```rust
// main.rs or lib.rs
mod utils {
    pub fn format_output(data: &str) -> String {
        format!("Output: {}", data)
    }
}

fn main() {
    println!("{}", utils::format_output("Hello"));
}
```

**File Structure:**

```text
src/
├── main.rs
```

**When to use:** Single small utility or temporary code; prototyping


### Option 2: Single File Module

- `utils.rs` is a standalone module file
- The module declaration `mod utils;` in `main.rs` or `lib.rs` points to this file
- Simple structure suitable for small to medium utilities without sub-modules
- The module is directly importable as `mod utils;`

**File Structure:**

```text
src/
├── main.rs
└── utils.rs
```

**In main.rs:**

```rust
mod utils;

fn main() {
    utils::format_output("test");
}
```

**In utils.rs:**

```rust
pub fn format_output(data: &str) -> String {
    format!("Output: {}", data)
}
```

> Use when your utility functions are simple, stable, and don't require further subdivision into logical sub-modules.

### Option 3: Module Directory (Recommended for larger modules)

- `utils/` is a directory containing `mod.rs`
- `mod.rs` declares and organizes sub-modules within the namespace
- Better for organizing larger, more complex functionality
- Enables hierarchical structure: `utils/mod.rs` can declare sub-modules like `utils/logger.rs`, `utils/parser.rs`

**File Structure:**

```text
src/
├── main.rs
└── utils/
    ├── mod.rs
    ├── logger.rs
    └── parser.rs
```

**In main.rs:**

```rust
mod utils;

fn main() {
    utils::logger::info("Application started");
    let result = utils::parser::parse("data");
}
```

**In utils/mod.rs:**

```rust
pub mod logger;
pub mod parser;
```

**In utils/logger.rs:**

```rust
pub fn info(msg: &str) {
    println!("[INFO] {}", msg);
}

pub fn warn(msg: &str) {
    println!("[WARN] {}", msg);
}
```

**In utils/parser.rs:**

```rust
pub fn parse(input: &str) -> Result<String, String> {
    if input.is_empty() {
        Err("Empty input".to_string())
    } else {
        Ok(format!("Parsed: {}", input))
    }
}
```

> Use when you have multiple related utilities that benefit from being grouped together, or when you anticipate needing to split utilities into sub-modules. This is the standard pattern in professional projects.

---

## **Visibility and Privacy**

Rust uses **privacy by default**. Items are inaccessible outside their module unless explicitly marked as public. This is enforced at compile-time and forms the foundation of encapsulation.

### Visibility Modifiers

- **default (private)** — accessible only within the declaring module and its children
- **`pub`** — visible to all external modules and crates
- **`pub(crate)`** — visible only within the current crate (not to external consumers)
- **`pub(super)`** — visible to the parent module only
- **`pub(in path)`** — visible only within a specified module path

### Privacy Rules

1. A public item in a private module is still inaccessible to external code
2. Private items can access public items (no privacy violation)
3. Children can access private items in their parent module
4. Sibling modules cannot access each other's private items

### Comprehensive Example

```rust
mod database {
    // Private struct — internal implementation detail
    struct Connection {
        url: String,
    }

    impl Connection {
        fn new(url: &str) -> Self {
            Connection { url: url.to_string() }
        }
    }

    // Public module that controls access to database internals
    pub mod client {
        use super::Connection;

        // Public interface
        pub struct Database {
            connection: super::Connection,
        }

        impl Database {
            pub fn connect(url: &str) -> Self {
                Database {
                    connection: super::Connection::new(url),
                }
            }

            pub fn query(&self, sql: &str) -> Result<String, String> {
                println!("Executing: {}", sql);
                Ok("Results".to_string())
            }
        }
    }

    // Crate-visible utility — useful internally but not exposed to outside crates
    pub(crate) fn internal_migration() {
        println!("Running internal migration");
    }
}

// External code
fn main() {
    let db = database::client::Database::connect("postgres://localhost");
    // ✓ Allowed: Database is public
    
    let _ = db.query("SELECT * FROM users");
    // ✓ Allowed: query is public
    
    // database::Connection::new("url");
    // ✗ Error: Connection is private
    
    // database::internal_migration();
    // ✗ Error: internal_migration is pub(crate) only
}
```

### Strategic Visibility Design

Experienced Rust developers use visibility as an architectural tool:

- **Expose only stable interfaces** — Keep implementation details private to allow refactoring
- **Use `pub(crate)` for internal helpers** — Share within your crate without committing to a public API
- **Design module boundaries** — Visibility rules reinforce logical separations
- **Version your APIs** — Keep public APIs minimal and well-documented

---

## **Importing**

Importing brings names into scope, reducing path verbosity and improving readability. Rust supports absolute paths, relative paths, and `use` declarations.

### Absolute Paths

Start from the crate root using the `crate::` keyword:

```rust
fn main() {
    crate::utils::logger::log("Message");
}
```

Absolute paths are unambiguous and preferred in complex module hierarchies.

### Relative Paths

Navigate using `super::` to access parent modules or use implicit relative paths:

```rust
// In utils/logger.rs
pub fn log(msg: &str) {
    println!("[LOG] {}", msg);
}

// In utils/parser.rs (sibling module)
pub fn parse(input: &str) {
    super::logger::log("Parsing started");
    // ... parsing logic
}
```

The `super::` keyword refers to the parent module. For deeply nested modules, `super::super::` traverses multiple levels.

### `use` Declarations

`use` statements bring items into scope without needing the full path:

```rust
use crate::utils::logger;
use crate::database::client::Database;

fn main() {
    logger::log("Application started");
    let db = Database::connect("url");
}
```

#### Importing specific items

```rust
use crate::utils::logger::log;
use crate::database::client::Database;

fn main() {
    log("Started");  // Direct function call, no module prefix
    let db = Database::connect("url");
}
```

#### Renaming imports with `as`

```rust
use crate::utils::logger as log_module;
use crate::database::client::Database as DB;

fn main() {
    log_module::log("Message");
    let _db = DB::connect("url");
}
```

#### Grouping imports

```rust
use crate::utils::{logger, parser};
use crate::database::client::{Database, Pool, Transaction};

fn main() {
    logger::log("Starting");
    parser::parse("data");
}
```

#### Self and super in use statements

```rust
// In nested modules
use super::logger;          // Import from parent
use super::super::config;   // Import from grandparent
use self::helpers;          // Import from current module
```

### Wildcard imports (use with caution)

```rust
use crate::utils::logger::*;  // Import all public items from logger
```

Wildcard imports should be used sparingly:

- ✓ Acceptable in preludes (see Re-exporting section)
- ✓ Acceptable in tests
- ✗ Avoid in public APIs and module boundaries

### Import Guidelines for Professional Code

- **Prefer explicit imports** — `use crate::db::Database;` is clearer than `use crate::db::*;`
- **Group related imports** — Organize by module, internal vs. external
- **Use absolute paths at module boundaries** — Clarity for readers unfamiliar with the module
- **Keep scope clean** — Don't import items you don't use
- **Organize imports** — Follow conventional ordering (standard library, external crates, internal modules)

```rust
// Professional style
use std::collections::HashMap;
use std::fs;

use serde::{Deserialize, Serialize};

use crate::config::Config;
use crate::utils::{logger, parser};
use self::helpers::validate;
```

---

## **Re-exporting**

Re-exporting strategically exposes internal items as part of a public API. This decouples API design from internal structure, enabling safe refactoring without breaking users.

### Benefits of Re-exporting

1. **Cleaner public interfaces** — Users import from logical locations, not internal structures
2. **API stability** — Refactor internals without changing the public API
3. **Semantic organization** — API structure reflects domain concepts, not implementation
4. **Backward compatibility** — Move items between internal modules without breaking dependent code

### Using `pub use`

`pub use` brings an item into the current module's scope and re-exports it:

```rust
// In lib.rs
mod internal {
    pub struct Service {
        name: String,
    }

    impl Service {
        pub fn new(name: &str) -> Self {
            Service {
                name: name.to_string(),
            }
        }
    }
}

// Re-export at the crate root for clean public API
pub use internal::Service;

// Internal helper not exposed
mod helpers {
    pub fn validate(input: &str) -> bool {
        !input.is_empty()
    }
}
```

**Using the crate:**

```rust
// Users can write the clean import:
use my_crate::Service;

// Instead of digging into internals:
use my_crate::internal::Service;

fn main() {
    let svc = Service::new("MyService");
}
```

### Advanced Re-exporting Patterns

#### Aggregating related items

```rust
// lib.rs
pub mod api {
    pub mod handlers { /* ... */ }
    pub mod routes { /* ... */ }
}

pub mod errors {
    pub struct ApiError;
    pub struct ParseError;
}

// Re-export at root for convenient access
pub use api::handlers::Handler;
pub use api::routes::Route;
pub use errors::{ApiError, ParseError};
```

Users get a clear mental model:

```rust
use my_crate::{Handler, Route, ApiError};
```

#### Prelude modules

A prelude is a convention module that re-exports commonly used types:

```rust
// lib.rs
pub mod prelude {
    pub use crate::api::{Handler, Request, Response};
    pub use crate::errors::Error;
    pub use crate::utils::Logger;
    pub use crate::config::Config;
}
```

Consumers can opt into the prelude:

```rust
use my_crate::prelude::*;

fn main() {
    let handler = Handler::new();
    let config = Config::load();
}
```

Preludes are standard in:

- Major libraries (`tokio::prelude::*`, `serde::prelude::*`)
- Frameworks
- Domain-specific libraries

---

## **Multi-file Projects**

Professional Rust projects organize modules across files and directories to scale beyond a few hundred lines.

### Typical project structure

```text
src/
├── main.rs              # Binary entry point
├── lib.rs               # Library root (optional)
├── config/
│   ├── mod.rs
│   └── parser.rs
├── database/
│   ├── mod.rs
│   ├── connection.rs
│   ├── query.rs
│   └── migration/
│       ├── mod.rs
│       └── v001_init.rs
├── api/
│   ├── mod.rs
│   ├── handlers.rs
│   └── middleware.rs
└── utils/
    ├── mod.rs
    ├── logger.rs
    └── validation.rs
```

### Declaration structure

```rust
// lib.rs
pub mod config;
pub mod database;
pub mod api;
pub mod utils;

// Re-export key types for ergonomic API
pub use config::Config;
pub use database::Database;
pub use api::Server;
```

```rust
// api/mod.rs
pub mod handlers;
pub mod middleware;

pub struct Server {
    // ...
}

impl Server {
    pub fn new() -> Self {
        // ...
    }
}
```

```rust
// api/handlers.rs
pub fn health_check() -> String {
    "OK".to_string()
}

pub fn users_list() -> Vec<String> {
    vec!["user1".to_string()]
}
```

```rust
// main.rs
use my_crate::prelude::*;

#[tokio::main]
async fn main() {
    let config = Config::load().expect("Failed to load config");
    let db = Database::connect(&config.db_url).await.expect("Failed to connect");
    let server = Server::new();
    
    server.run().await;
}
```

### Best practices for module organization

1. **One responsibility per module** — A module should have a clear, focused purpose
2. **Limit nesting depth** — 3-4 levels is typical; deeper suggests poor organization
3. **Use `mod.rs` as an index** — Declare public sub-modules and aggregate exports
4. **Keep modules under 500 lines** — Split if it exceeds reasonable size
5. **Name modules after their primary type/concept** — `database::`, `api::`, not `stuff/` or `misc/`

---

## **Common Pitfalls and Anti-Patterns**

### ✗ Exposing internal types

```rust
// Bad: leaks internal implementation
pub use internal::Connection;

// Good: expose only stable public API
pub struct Client {
    // Connection is hidden
}
```

### ✗ Overly deep nesting

```rust
// Bad: company::department::team::project::subsystem::util
use crate::company::department::team::project::subsystem::util;

// Better: flat organization with clear names
use crate::subsystem::util;
```

### ✗ Wildcard imports in public APIs

```rust
// Bad: in a public module
pub use internal::*;

// Good: explicit re-exports
pub use internal::{Type1, Type2, Type3};
```

### ✗ Inconsistent module organization

```rust
// Bad: mixing inline and file-based modules inconsistently
mod inline_module {
    // ...
}
// Then separately:
// mod file_module;  (points to file_module.rs)

// Good: consistent structure, typically file-based for anything non-trivial
```

---

## **Professional Applications and Implementation**

Modules define the architectural backbone of Rust applications. They enforce clear ownership boundaries, support long-term maintainability, and enable clean public APIs. Effective module design:

- **Enforces architectural boundaries** — Module visibility rules prevent violation of layering
- **Facilitates testing** — Private helpers and test modules can be co-located
- **Enables safe refactoring** — Changing internals doesn't affect public APIs
- **Documents intent** — Module structure communicates system design
- **Supports team development** — Clear ownership and boundaries reduce merge conflicts

A well-designed module system allows teams to:

- Scale to millions of lines of code (as seen in Linux kernel ports, Rust compiler)
- Refactor safely with confidence
- Onboard new developers through clear structure
- Maintain backward compatibility through stable APIs

---

## **Key Takeaways**

| Concept                    | Summary                                                                        |
| -------------------------- | ------------------------------------------------------------------------------ |
| Module tree                | Explicit, hierarchical namespace structure rooted at crate level.              |
| Module declaration         | `mod` keyword establishes module relationships; file structure follows design. |
| Visibility                 | Privacy is default; fine-grained modifiers control access at module level.     |
| Imports (`use`)            | Bring items into scope; prefer explicit imports for clarity.                   |
| Re-exporting (`pub use`)   | Decouples public API from internal structure; enables refactoring.             |
| Multi-file organization    | Use directories with `mod.rs` for scalable, professional projects.             |
| Prelude pattern            | Standard way to expose commonly used items in libraries.                       |
| Sealed traits              | Advanced pattern for API stability and preventing unwanted implementations.    |


- Modules must be **explicitly declared** and intentionally organized
- Privacy is a **core design principle** enforced at compile-time
- Imports and re-exports **shape API ergonomics** and influence how code is used
- File-based module layouts **scale** to large systems better than inline definitions
- **Thoughtful module design** improves safety, maintainability, and enables fearless refactoring
- Visibility boundaries act as **architectural guardrails** preventing layering violations
- A well-structured module system is **self-documenting** and reduces cognitive load


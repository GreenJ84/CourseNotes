# **Topic 4.1.2: Communication with REST**

Representational State Transfer (REST) is an architectural style for designing networked applications using stateless, client-server communication over HTTP. It remains the default choice for web APIs and many microservice entry points because it is widely understood, tooling-friendly, and operationally predictable.

REST is not just about routes and JSON. It is about designing durable contracts under change:

- Correct HTTP semantics (method meaning, status codes, caching)
- Safe behavior under retries, timeouts, and partial failures
- Evolvable API contracts that avoid breaking clients
- Observable request flows for debugging distributed systems

## **Learning Objectives**

- Define REST and its architectural principles in distributed systems
- Understand stateless communication and its impact on scalability and reliability
- Apply HTTP methods and status codes correctly in API design
- Compare REST with alternative communication patterns (gRPC, messaging, pub/sub, WebSockets)
- Identify appropriate use cases for REST in microservice architectures
- Implement RESTful services and clients in Rust using modern frameworks and libraries
- Design APIs for idempotency, versioning, and failure-aware behavior
- Apply practical production patterns for observability and resilience

---

## **REST Architecture Fundamentals**

- REST is not a protocol but an **architectural style** built on top of HTTP
- Core abstraction: **resources** (entities exposed via URIs)
- Communication is performed using standard HTTP methods and status codes
- JSON is common, but media format is a contract decision (JSON, HAL, etc.)

Think in nouns, not verbs:

- Good: `/users/42/orders`
- Avoid: `/getUserOrders`

### Core Constraints

- **Client-Server Separation**
  - UI and backend evolve independently
  - Enables multiple clients (web, mobile, partner integrations)

- **Statelessness**
  - Each request contains all necessary context
  - Simplifies horizontal scaling and failover

- **Uniform Interface**
  - Consistent, predictable API structure
  - Strongly reduces client complexity over time

- **Cacheability**
  - Responses can be cached to improve performance
  - Use `Cache-Control`, `ETag`, and conditional requests where appropriate

- **Layered System**
  - Intermediaries (proxies, gateways) can exist transparently
  - Supports edge caching, auth gateways, and observability middleware

> Senior Insight: REST is most valuable when teams consistently apply its constraints. Inconsistent status codes, route naming, and payload shapes create operational and integration drag.

---

## **Statelessness**

Statelessness is a defining characteristic of REST systems.

- Each request is **independent** and self-contained
- Server does not retain client session state between requests

### Implications

- **Scalability**
  - Any server instance can handle any request
  - Enables horizontal scaling behind load balancers

- **Reliability**
  - Failure of one node does not affect session continuity

- **Simplicity**
  - Reduced server-side complexity (no session management)

### Trade-offs

- Increased **payload size** (must include all context, e.g., auth tokens)
- Client must manage state (pagination cursors, retries, request correlation)

### Practical Guidance

- Treat auth context as request data (JWT or token-based identity)
- Propagate `x-request-id` or trace headers for distributed tracing
- Keep server-side state only for durable business data, not per-client sessions

---

## **REST Methods (HTTP Verbs)**

REST leverages HTTP methods to define operation semantics on resources.

| Method | Purpose | Idempotent | Safe | Typical REST API Use | Rarity |
| ------ | ------- | ---------- | ---- | -------------------- | ------ |
| GET | Retrieve resource representation | Yes | Yes | Fetch user/profile/order data | Common |
| POST | Create resource or trigger non-idempotent operation | Usually No | No | Create user, submit order, trigger workflow | Common |
| PUT | Replace full resource at a known URI | Yes | No | Replace entire user record | Common |
| PATCH | Partially update resource fields | Usually No | No | Update one user field (for example, email) | Common |
| DELETE | Remove resource | Yes | No | Delete user/session/token | Common |
| HEAD | Same as GET but headers only (no body) | Yes | Yes | Check existence, metadata, cache headers | Uncommon |
| OPTIONS | Return communication options/allowed methods | Yes | Yes | CORS preflight, inspect allowed methods | Uncommon |
| TRACE | Diagnostic loop-back of request path | Yes | Yes | HTTP path diagnostics (usually disabled) | Rare |
| CONNECT | Establish tunnel to target server | No | No | Proxy TLS tunneling (not typical REST endpoint) | Rare |

Key distinctions:

- **Safe**: does not modify server state (for example, `GET`)
- **Idempotent**: repeating request produces same final state (`PUT`, `DELETE`)
- Idempotency is critical for retry behavior in distributed systems
- `HEAD` and `OPTIONS` are valid and useful but are not explicit business handlers
- `TRACE` and `CONNECT` are protocol-level methods and are rarely exposed in application REST APIs

### Example (Rust REST Service with Meaningful Semantics)

```rust
use std::{collections::HashMap, net::SocketAddr, sync::Arc};

use axum::{
  extract::{Path, State},
  http::{HeaderMap, StatusCode},
  response::IntoResponse,
  routing::{get, post, put},
  Json, Router,
};
use serde::{Deserialize, Serialize};
use tokio::sync::RwLock;

#[derive(Serialize, Deserialize)]
struct User {
    id: u32,
    name: String,
}

#[derive(Deserialize)]
struct CreateUser {
  name: String,
}

#[derive(Clone, Default)]
struct AppState {
  users: Arc<RwLock<HashMap<u32, User>>>,
}

async fn get_user(
  State(state): State<AppState>,
  Path(id): Path<u32>,
) -> impl IntoResponse {
  let users = state.users.read().await;
  match users.get(&id) {
    Some(user) => (StatusCode::OK, Json(user.clone())).into_response(),
    None => (StatusCode::NOT_FOUND, "user not found").into_response(),
  }
}

async fn create_user(
  State(state): State<AppState>,
  headers: HeaderMap,
  Json(payload): Json<CreateUser>,
) -> impl IntoResponse {
  // Simplified idempotency approach for teaching purposes.
  // In production, persist idempotency keys in durable storage.
  if headers.get("idempotency-key").is_none() {
    return (StatusCode::BAD_REQUEST, "missing idempotency-key").into_response();
  }

  if payload.name.trim().is_empty() {
    return (StatusCode::BAD_REQUEST, "name is required").into_response();
  }

  let mut users = state.users.write().await;
  let new_id = (users.len() as u32) + 1;
  let user = User {
    id: new_id,
    name: payload.name,
  };
  users.insert(new_id, user.clone());

  (StatusCode::CREATED, Json(user)).into_response()
}

async fn replace_user(
  State(state): State<AppState>,
  Path(id): Path<u32>,
  Json(payload): Json<CreateUser>,
) -> impl IntoResponse {
  // PUT is idempotent: same payload can be safely retried.
  let mut users = state.users.write().await;
  let user = User {
    id,
    name: payload.name,
  };
  users.insert(id, user.clone());
  (StatusCode::OK, Json(user))
}

#[tokio::main]
async fn main() {
  let state = AppState::default();

  let app = Router::new()
    .route("/users/:id", get(get_user).put(replace_user))
    .route("/users", post(create_user))
    .with_state(state);

  let addr: SocketAddr = "0.0.0.0:3000".parse().unwrap();
  println!("listening on {addr}");

  axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

### Why This Example Matters

- Uses **resource-oriented routes** (`/users`, `/users/:id`)
- Demonstrates **status code intent** (`201`, `404`, `400`)
- Shows **idempotency awareness** via key/header concept for `POST`
- Shows why `PUT` semantics are retry-friendly in distributed systems

---

## **HTTP Status Codes**

HTTP status codes communicate the result of a request.

| Range   | Category     | Meaning                           |
| ------- | ------------ | --------------------------------- |
| 200-299 | Success      | Request processed successfully    |
| 300-399 | Redirection  | Further action required           |
| 400-499 | Client Error | Invalid request or input          |
| 500-599 | Server Error | Server failed to process request  |

### Common Codes

- **200 OK** → Successful request
- **201 Created** → Resource successfully created
- **204 No Content** → Successful with no response body
- **202 Accepted** → Request accepted for asynchronous processing
- **400 Bad Request** → Invalid input
- **401 Unauthorized / 403 Forbidden** → Authentication/authorization issues
- **404 Not Found** → Resource does not exist
- **409 Conflict** → State conflict (for example, duplicate unique value)
- **422 Unprocessable Content** → Syntactically valid request, semantically invalid domain data
- **429 Too Many Requests** → Rate limited
- **500 Internal Server Error** → Unexpected server failure

### Example (Explicit Status Handling)

```rust
use axum::{http::StatusCode, response::IntoResponse};

async fn create_result(ok: bool) -> impl IntoResponse {
  if ok {
    (StatusCode::CREATED, "created")
  } else {
    (StatusCode::CONFLICT, "duplicate resource")
  }
}
```

> Senior Insight: Status codes are part of your API contract. Inconsistent status behavior is a major source of client bugs and retry storms.

---

## **REST vs Other Communication Patterns**

REST is one of several communication strategies in distributed systems.

### gRPC

- Binary protocol using Protocol Buffers
- Strong typing and contract-first design
- High performance, low latency
- Requires schema management and tooling
- Better fit for high-QPS internal service calls with strict latency budgets

### Message Queues (e.g., SQS)

- Asynchronous communication
- Decouples producers and consumers
- Supports retry and durability
- Introduces eventual consistency
- Best when producer and consumer should not be temporally coupled

### Publish/Subscribe (e.g., Kafka)

- Event-driven architecture
- One-to-many communication
- High throughput and streaming capabilities
- Operational complexity (cluster management, partitioning)
- Strong for event histories, stream processing, and analytics pipelines

### WebSockets

- Persistent, bidirectional connection
- Real-time communication (chat, live updates)
- Requires connection lifecycle management
- Not a replacement for standard request/response APIs

> Rule of Thumb
>
> - External/public APIs: REST first
> - Internal low-latency synchronous calls: often gRPC
> - Domain events and asynchronous workflows: queues/pub-sub
> - Live interactive streams: WebSockets or SSE
>
> Hybrid architectures are normal: REST at boundaries, gRPC/streaming internally.

---

## **When to Use REST**

REST is most effective when:

- Designing **public-facing APIs**
- Implementing **simple request/response interactions**
- Leveraging existing **HTTP infrastructure (load balancers, proxies)**
- Prioritizing **developer experience and maintainability**
- Requiring **high observability and debuggability**

REST is usually the right default when protocol simplicity and broad interoperability matter more than absolute transport efficiency.

### Anti-Patterns

- High-frequency, low-latency internal service calls (consider gRPC)
- Event-driven architectures requiring loose coupling (consider pub/sub)
- Real-time streaming systems (consider WebSockets or Kafka)
- Modeling every backend operation as a generic `POST /do-something`
- Returning `200 OK` for errors with failure details in payload only

---

## **REST in Rust Microservices**

Rust provides a mature ecosystem for building RESTful services.

For most teams, `axum + tower + tokio + serde` is a modern and productive default stack.

### Common Frameworks

- **`axum`**
  - Modern, async-first, built on `tower` ecosystem
- **`actix-web`**
  - High-performance actor-based framework
- **`rocket`**
  - Ergonomic, developer-friendly (less flexible for async-heavy workloads)

### Serialization

- **`serde`**
  - Core serialization/deserialization framework
- **`serde_json`**
  - JSON encoding/decoding

### HTTP Clients

- **`reqwest`**
  - High-level, ergonomic HTTP client
- **`hyper`**
  - Low-level, high-performance HTTP implementation

### Typical Middleware

- Request ID generation/propagation
- Structured logging
- Timeout and concurrency limits
- Compression and decompression
- Authentication/authorization
- Tracing instrumentation

This keeps the client simple while still handling real distributed-system concerns: bounded latency, status-aware behavior, and trace propagation.

---

## **Advanced Insights: Designing Robust REST APIs**

- **Idempotency Design**
  - Ensure `PUT` and `DELETE` can be safely retried
  - Critical for distributed systems with retries

- **Versioning Strategies**
  - URI versioning (`/v1/resource`) or header-based versioning
  - Prevents breaking clients during evolution

- **Rate Limiting & Throttling**
  - Protect services from overload
  - Typically enforced via API gateways

- **Observability**
  - Structured logging, tracing (OpenTelemetry), metrics
  - Essential for debugging distributed systems

- **API Gateway Pattern**
  - Centralized entry point for routing, auth, rate limiting

- **Pagination Strategy**
  - Prefer cursor-based pagination for large, changing datasets
  - Offset pagination is simpler but less stable under concurrent writes

- **Backward Compatibility Discipline**
  - Add fields without removing old ones abruptly
  - Avoid changing field meaning; deprecate with migration windows

- **Error Contract Consistency**
  - Return a stable error schema with code, message, and trace/request id
  - Makes client behavior and support workflows much more predictable

### Minimal Error Envelope Example

```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User 42 does not exist",
    "request_id": "req-abc-123"
  }
}
```

> Senior Insight: Most API incidents are not from missing endpoints. They come from inconsistent semantics under failure and change.

---

## **Professional Applications and Implementation**

REST is widely used in production systems:

- Public APIs for web/mobile applications
- Internal service communication (when simplicity is preferred)
- Integration layers between heterogeneous systems
- Backend-for-frontend (BFF) architectures
- Admin and operations APIs requiring explicit, inspectable workflows

In Rust-based systems:

- REST endpoints serve as **entry points to high-performance services**
- Often combined with async runtimes (`tokio`) for concurrency
- Used alongside other patterns (e.g., REST externally, gRPC internally)

### Migration and Adoption Strategy

1. Start with a strict API style guide (naming, status codes, error schema).
2. Add automated contract tests and schema checks in CI.
3. Add request tracing and latency SLO dashboards before scale issues appear.
4. Introduce gRPC or messaging only where measured constraints require it.

---

## **Key Takeaways**

| Concept Area | Summary |
| ------------ | ------- |
| REST Architecture | Stateless, resource-oriented communication over HTTP with strong contract semantics. |
| Statelessness | Enables scalability and resilience by eliminating server-side session coupling. |
| HTTP Semantics | Methods and status codes define retry behavior, correctness, and client expectations. |
| Communication Trade-offs | REST optimizes simplicity and interoperability over raw transport efficiency. |
| Rust Ecosystem | Rust provides high-performance, type-safe tooling for resilient REST APIs. |
| Production Robustness | Idempotency, observability, rate limits, and compatibility discipline are critical. |

- REST remains the default communication model for web and microservices
- Stateless design is critical for scalable distributed systems
- Proper use of HTTP semantics improves API clarity and reliability
- Alternative communication models should be chosen based on system requirements
- Rust enables building fast, safe, and maintainable REST services with minimal runtime overhead
- Robust API design is mostly about consistency under retries, failures, and long-term evolution

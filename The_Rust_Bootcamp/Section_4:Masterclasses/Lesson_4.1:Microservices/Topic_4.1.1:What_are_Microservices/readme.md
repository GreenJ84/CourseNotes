# **Topic 4.1.1: What are Microservices**

Microservices represent a distributed systems architecture where an application is decomposed into a collection of small, autonomous services. Each service encapsulates a specific business capability, operates independently, and communicates with other services over well-defined interfaces.

## **Learning Objectives**

- Define microservices architecture and its role in modern software systems
- Compare monolithic and microservices architectures across performance, scalability, and development workflows
- Analyze trade-offs between simplicity and distributed system complexity
- Understand core principles of service independence and inter-service communication
- Evaluate when microservices are appropriate versus over-engineering
- Assess Rust’s strengths and limitations within microservice ecosystems
- Identify production concerns (timeouts, retries, idempotency, observability, failure isolation)
- Apply practical design heuristics for defining service boundaries

---

## **Monolithic Architectures**

- Single, unified codebase containing all application components (UI, business logic, data access)
- Typically deployed as one unit (single binary or service)

Monoliths are often underestimated. A well-structured modular monolith can serve a product for years with excellent performance and low operational burden.

### Strengths

- **Simplicity**
  - Centralized codebase simplifies development and debugging
  - Minimal infrastructure requirements

- **Performance**
  - No network overhead between components (in-process calls)
  - Shared memory and libraries reduce duplication

- **Ease of Setup**
  - Faster initial development lifecycle
  - Ideal for MVPs, prototypes, and small-scale applications

- **Transactional Simplicity**
  - Strong consistency is easier with a single database transaction boundary
  - Debugging a request is simpler when everything executes in one process

### Limitations

- **Scalability Constraints**
  - Entire application must scale as a unit (horizontal scaling inefficiency)
  - Resource-heavy components cannot scale independently

- **Tight Coupling**
  - Changes in one component may impact others
  - Reduced flexibility in adopting new technologies

- **Slower Development at Scale**
  - Difficult to parallelize across large teams
  - Merge conflicts and integration overhead increase

- **Single Point of Failure**
  - Failure in one module can cascade and bring down the entire system

- **Release Coupling**
  - One deployment artifact means unrelated changes ship together
  - High-risk release windows can emerge as the codebase grows

### Example Monolithic Service Interaction

```rust
// Conceptual monolithic request path.
// Everything happens in one process, often sharing one database transaction scope.
fn handle_checkout_request(user_id: u64) {
    let cart = load_cart_from_db(user_id);          // data access
    let priced = apply_pricing_rules(cart);         // business logic
    let confirmed = reserve_inventory(priced);      // business logic + persistence
    write_order_to_db(confirmed);                   // persistence
    send_response("order created");                 // response
}
```

All logic exists within a single runtime and process boundary. Function calls are in-process, so latency is typically microseconds to low milliseconds instead of network round trips.

> Senior Insight: The Modular Monolith Pattern
>
> Before splitting into microservices, utilize a modular monolith:
>
> - Enforce domain boundaries at the code level (separate crates/modules)
> - Use clear interfaces between domains
> - Keep one deployable unit while deferring distributed-system complexity

---

## **Microservices Architecture**

- Application is decomposed into **independent, loosely coupled services**
- Each service:
  - Owns its own data and logic
  - Is independently deployable and scalable
  - Communicates via network protocols (HTTP, gRPC, messaging systems)

In practice, this means each service should represent a **bounded business capability** (for example: identity, billing, catalog, or notifications), not just an arbitrary technical layer.

### Core Principles

- **Service Autonomy**: Independent lifecycle (build, deploy, scale)
- **Bounded Contexts**: Domain-driven service boundaries
- **Decentralization**: Distributed data and logic ownership
- **Inter-Service Communication**: Explicit APIs over network boundaries
- **Observability by Default**: Logs, metrics, and traces are part of design, not an afterthought
- **Failure-Aware Design**: Timeouts, retries, and circuit-breaker behavior are planned up front

### Strengths

- **Scalability**
  - Scale only the services under load
  - Efficient resource utilization

- **Flexibility**
  - Services can use different technologies (polyglot architecture)
  - Easier incremental evolution of systems

- **Faster Development**
  - Teams can work independently on separate services
  - Reduced merge conflicts and deployment bottlenecks

- **Higher Reliability**
  - Failures are isolated to individual services
  - Supports fault-tolerant design patterns

- **Independent Delivery Cadence**
  - Teams can deploy service changes without coordinating full-system releases
  - Smaller blast radius per deployment when ownership is clear

### Limitations

- **Increased Complexity**
  - Distributed system challenges (network failures, latency, retries)
  - Service discovery, orchestration, and monitoring required

- **Data Consistency Challenges**
  - No shared database; requires eventual consistency strategies
  - Complex transaction management (e.g., Saga patterns)

- **Performance Overhead**
  - Network calls introduce latency
  - Serialization/deserialization costs

- **Higher Initial Setup Cost**
  - Infrastructure (containers, orchestration, CI/CD pipelines) required
  - Requires mature platform engineering and operational practices

> Senior Insight: The Real Cost
>
> The major cost of microservices is rarely code. It is:
>
> - Operational ownership (on-call, incident response, SLOs)
> - Platform complexity (service mesh, deployment tooling, secret management)
> - Cross-service coordination (versioning, compatibility, distributed debugging)
>
> If an organization is not prepared for these costs, microservices can reduce delivery speed instead of improving it.

### Example Microservices Interaction

```rust
use std::time::Duration;

use reqwest::{Client, StatusCode};
use tokio::time::timeout;

// Service A calling Service B with production-minded basics:
// 1) explicit timeout, 2) status handling, 3) typed error surface.
async fn fetch_profile(client: &Client, user_id: u64) -> Result<String, String> {
    let url = format!("http://service-b/api/profile/{user_id}");

    let request = client.get(url).header("x-request-id", "req-123");

    let response = timeout(Duration::from_millis(300), request.send())
        .await
        .map_err(|_| "service-b timeout".to_string())?
        .map_err(|e| format!("network error: {e}"))?;

    match response.status() {
        StatusCode::OK => response
            .text()
            .await
            .map_err(|e| format!("decode error: {e}")),
        StatusCode::NOT_FOUND => Err("profile not found".to_string()),
        s if s.is_server_error() => Err("service-b unavailable".to_string()),
        s => Err(format!("unexpected status: {s}")),
    }
}
```

Here, communication occurs over the network rather than in-process, so error handling must account for latency, partial failures, and non-200 responses.

### Why This Example Matters

- **Timeouts prevent request pileups** during downstream slowness
- **Explicit status mapping** avoids leaking transport details to business logic
- **Typed/structured error paths** make retries and fallback behavior safer

In production, this is typically combined with retry policies, backoff, and idempotency protections.

### Common Communication Patterns

- **Synchronous request/response (HTTP or gRPC)**
  - Best when immediate response is required
  - Risk: upstream latency couples with downstream availability
- **Asynchronous messaging (queues/event streams)**
  - Better decoupling and resilience to burst traffic
  - Requires idempotency and eventual consistency handling

---

## Supporting Technologies in Microservices

Microservices rely heavily on an ecosystem of supporting infrastructure:

- Communication
  - **REST**
    - Simple, human-readable APIs using JSON
    - Ubiquitous and language-agnostic
    - Higher latency and less efficient than binary protocols
  - **gRPC**
    - High-performance, strongly typed communication using Protocol Buffers
    - Efficient binary serialization
    - Strong contract evolution patterns with protobuf versioning

- **Docker**
  - Containerization for consistent runtime environments
  - Encapsulates application and dependencies

- **Kubernetes**
  - Orchestration of containerized services
  - Handles scaling, load balancing, and self-healing
  - Enables declarative rollouts, health probes, and resource governance

- **GitHub Actions (CI/CD)**
  - Automates testing, building, and deployment pipelines
  - Enables continuous delivery of independent services

- **Observability Stack (OpenTelemetry + Prometheus + Grafana + central logging)**
  - Correlates logs, metrics, and traces across service boundaries
  - Essential for diagnosing latency and failure propagation

### Production Capabilities You Eventually Need

- Service discovery and configuration management
- Secrets management and key rotation
- Traffic policies (rate limiting, retries, mTLS)
- Progressive delivery (canary, blue/green)
- SLO-based alerting and incident response workflows

---

## **Rust for Microservices**

Rust is increasingly used in microservice architectures due to its performance characteristics and safety guarantees.

Senior teams often choose Rust for specific workloads first, such as high-throughput APIs, low-latency gateways, stream processors, or reliability-critical control-plane services.

### Advantages

- **Performance and Memory Safety**
  - Zero-cost abstractions enable high-performance services
  - Ownership model eliminates common memory errors (e.g., leaks, use-after-free)

- **Scalability Efficiency**
  - Low runtime overhead reduces infrastructure cost
  - Efficient CPU and memory utilization

- **Reliability**
  - Strong type system enforces correctness at compile time
  - Thread safety guarantees reduce concurrency bugs

- **Deployment Simplicity**
  - Compiles to a single static binary
  - Minimal runtime dependencies (ideal for containers)
  - Cross-compilation support for multiple targets

- **Strong Concurrency Model**
  - `Send`/`Sync` guarantees reduce data-race risk in async and multithreaded systems
  - Predictable behavior under load with fewer runtime surprises

- **Resource Predictability**
  - Fine control over allocations and memory layout
  - Helpful for cost-sensitive cloud deployments and tight SLOs

#### Example: Minimal HTTP Service in Rust

```rust
use std::net::SocketAddr;

use axum::{extract::State, routing::get, Json, Router};
use serde::Serialize;

#[derive(Clone)]
struct AppState {
  service_name: &'static str,
}

#[derive(Serialize)]
struct HealthResponse {
  service: &'static str,
  status: &'static str,
}

async fn health_check(State(state): State<AppState>) -> Json<HealthResponse> {
  Json(HealthResponse {
    service: state.service_name,
    status: "ok",
  })
}

#[tokio::main]
async fn main() {
  let state = AppState {
    service_name: "user-service",
  };

  let app = Router::new()
    .route("/health", get(health_check))
    .with_state(state);

  let addr: SocketAddr = "0.0.0.0:3000".parse().unwrap();
  println!("listening on {addr}");

  axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

This example stays simple while demonstrating real concepts:

- **Shared immutable service state** (`AppState`) injected safely
- **Typed JSON contract** (`HealthResponse`) for clear API behavior
- **Async runtime integration** via Tokio and Axum

In production you would add graceful shutdown, structured logging, tracing middleware, and readiness/liveness separation.

### Limitations

- **Steeper Learning Curve**

  - Ownership, borrowing, and lifetimes increase onboarding time

- **Development Velocity**

  - Compile-time guarantees can slow iteration initially
  - Ecosystem maturity varies compared to older languages

- **Hiring and Onboarding Constraints**

  - Rust expertise is growing but still less common than Java/Go/Node ecosystems
  - Team-level productivity depends on tooling standards and mentorship

> Senior Insight: Where Rust Shines Most
>
> Rust is a strong choice when your constraints are strict:
>
> - High throughput with low tail latency
> - Reliability under concurrency pressure
> - Memory safety and predictable resource usage are non-negotiable
>
> If a service is primarily CRUD with modest traffic and fast iteration needs, other languages may provide faster team throughput. Architecture success comes from matching language choice to business constraints.

---

## **Designing Good Service Boundaries**

Poor boundaries create chatty, tightly coupled distributed systems. Good boundaries align to domain ownership.

### Practical Heuristics

- One team should be able to own one service end-to-end
- Services should change for one primary business reason
- Avoid splitting by technical layer (controller service, repository service)
- Minimize synchronous cross-service hops on critical request paths
- Keep data ownership explicit: one write owner per core entity

### When Boundaries Are Wrong

- Frequent cross-service transactions for one user action
- Large volume of tiny synchronous calls between the same two services
- Teams cannot deploy without coordinating with several other teams
- Duplicate business rules spread across multiple services

---

## **Reliability Patterns in Practice**

Microservices require defensive design against partial failures.

- **Timeouts**: Every outbound call needs a deadline
- **Retries with backoff**: Retry only safe/idempotent operations
- **Circuit breaking**: Fail fast when dependency health degrades
- **Bulkheads**: Isolate resource pools to prevent cascading exhaustion
- **Idempotency keys**: Prevent duplicate side effects in retried requests

### Example (Simple Retry with Backoff)

```rust
use std::time::Duration;
use tokio::time::sleep;

async fn call_with_retry<F, Fut, T, E>(mut op: F) -> Result<T, E>
where
  F: FnMut() -> Fut,
  Fut: std::future::Future<Output = Result<T, E>>,
{
  let mut delay_ms = 50;

  for attempt in 1..=3 {
    match op().await {
      Ok(value) => return Ok(value),
      Err(err) if attempt < 3 => {
        sleep(Duration::from_millis(delay_ms)).await;
        delay_ms *= 2; // exponential backoff: 50, 100
        let _ = err; // optionally log structured error here
      }
      Err(err) => return Err(err),
    }
  }

  unreachable!()
}
```

This pattern is intentionally minimal. In production, add jitter, max elapsed time, and retry classification rules.

---

## **Data Consistency and Distributed Transactions**

Once services own separate databases, classic ACID transactions across all services are usually not practical.

Common approach:

- Keep local transactions strong inside each service
- Use asynchronous domain events between services
- Design for eventual consistency where business-safe
- Implement compensating actions (Saga pattern) for multi-step workflows

Senior guidance: consistency is a **business decision**, not only a technical one. Some domains require immediate consistency (payments), others tolerate eventual consistency (analytics dashboards).

---

## **Professional Applications and Implementation**

Microservices architecture is foundational in modern distributed systems:

- Backend platforms (e.g., APIs, SaaS products)
- Cloud-native applications and infrastructure services
- High-availability systems requiring fault isolation
- Large engineering organizations with multiple teams
- Edge and hybrid systems combining cloud and embedded services

Rust enhances these systems by providing:

- Predictable performance under load
- Strong safety guarantees in concurrent environments
- Reduced runtime failures in production systems

Key idea: **microservices do not remove complexity, they *relocate* it.**

- In a monolith, complexity is mostly internal (module boundaries, dependency management, deployment coupling).
- In microservices, complexity is mostly external (network reliability, observability, distributed consistency, operational maturity).

Microservices are therefore not just a code organization choice. They are a **system design and operational strategy**. Teams adopt them to gain independent scaling, faster team autonomy, and deployment flexibility, while accepting the hard realities of distributed systems.

### Decision Framework: Monolith or Microservices?

Choose a monolith (or modular monolith) when:

- Team is small and product scope is evolving rapidly
- Operational platform maturity is low
- Domain boundaries are still unclear

Choose microservices when:

- Team structure supports clear service ownership
- You need independent scaling and release cadence
- You can invest in observability, platform tooling, and SRE practices

The most practical path is often incremental:

1. Start with a modular monolith.
2. Measure hotspots (scaling pain, deployment bottlenecks, team contention).
3. Extract one bounded context at a time.
4. Keep interfaces stable and observable from day one.

---

## **Key Takeaways**

| Concept Area               | Summary                                                                                                            |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Monolithic Architecture    | Simple, performant, and ideal for small-scale applications but limited in scalability and flexibility.             |
| Microservices Architecture | Decomposes systems into independent services enabling scalability, resilience, and parallel development.           |
| Trade-offs                 | Microservices introduce operational and distributed system complexity in exchange for flexibility and scalability. |
| Supporting Technologies    | gRPC, Docker, Kubernetes, and CI/CD pipelines are essential for managing microservices.                            |
| Rust in Microservices      | Provides high performance, memory safety, and efficient deployment with some learning curve trade-offs.            |
| Boundary Design            | Good service boundaries follow domain ownership and reduce chatty cross-service coupling.                          |
| Reliability Patterns       | Timeouts, retries, backoff, idempotency, and observability are non-optional in production systems.                 |

- Microservices shift complexity from code structure to system architecture
- Network boundaries introduce both flexibility and failure modes
- Proper tooling and infrastructure are essential for successful adoption
- Rust is well-suited for performance-critical, reliable microservice systems
- Architectural choice should align with system scale, team size, and operational maturity
- Start simple, measure real constraints, and extract services intentionally rather than prematurely

# **Topic 4.1.4: Containerization with Docker**

Containerization packages an application and everything it needs to run into a portable artifact. In microservice systems, this is the operational baseline for reliable deployments, scaling, and repeatable environments. Docker is the dominant container platform, and Rust is an especially strong fit because many services compile to efficient standalone binaries.

## **Learning Objectives**

- Define containerization and its role in distributed systems
- Compare containers and virtual machines across isolation, performance, and operations
- Understand Docker architecture and runtime model
- Build, run, inspect, and troubleshoot Docker images and containers
- Apply practical Rust container workflows, including multi-stage builds and image hardening
- Use Docker Compose for local multi-service development
- Evaluate container alternatives and orchestration extensions

---

## **Containerization Fundamentals**

Containerization encapsulates an application into a self-contained execution unit that can run consistently across environments.

### What Is Actually Packaged

- Application binary (for Rust, usually one executable)
- Runtime filesystem and libraries (if dynamically linked)
- Startup command and environment configuration
- Metadata such as exposed ports and labels

### Why It Matters in Microservices

- **Consistency**: the same artifact runs in local, CI, and production
- **Isolation**: failures and dependency conflicts are constrained per service
- **Portability**: container images run on laptops, VMs, and cloud nodes
- **Scalability**: services can scale independently by replica count

### Core Operational Principle

Container images are immutable build outputs. Runtime configuration should be injected at deploy time via environment variables, secrets, and platform settings.

---

## **Containers vs Virtual Machines**

| Dimension | Containers | Virtual Machines |
| --------- | ---------- | ---------------- |
| Isolation Boundary | Process and namespace isolation | Full guest OS isolation |
| Kernel Model | Shared host kernel | Separate guest kernel |
| Startup Latency | Milliseconds to seconds | Seconds to minutes |
| Resource Overhead | Low | Higher |
| Image/Artifact Size | Usually smaller | Usually larger |
| Security Posture | Good with hardening | Stronger default isolation |

### Practical Interpretation

Containers optimize density and startup speed, which makes them ideal for microservices. VMs still matter when strict OS-level isolation is required.

---

## **Docker Architecture**

Docker manages the full image and container lifecycle.

### Main Components

- **Docker daemon (`dockerd`)**: builds images and runs containers
- **Docker CLI (`docker`)**: user-facing command interface
- **Registry**: stores and distributes images (Docker Hub, GHCR, ECR, ACR)
- **Container runtime**: low-level execution layer (commonly `containerd`)

### Image and Container Relationship

- **Image**: immutable template
- **Container**: runtime instance of an image

One image can create many containers with different runtime configuration.

---

## **Dockerfile for Rust Services**

A Dockerfile is a build recipe. For Rust, a high-quality Dockerfile is mostly about build caching, small runtime footprint, and secure defaults.

### Most Important Instructions

- `FROM`: define a base image
- `WORKDIR`: define the working directory
- `COPY`: move source or artifacts into the image
- `RUN`: execute build or install steps
- `ENV`: define default environment values
- `EXPOSE`: document listening port
- `ENTRYPOINT` / `CMD`: runtime startup behavior

### Example: Multi-Stage Build with Better Caching

```dockerfile
# Stage 1: Build stage with Rust toolchain
## 1) Use official Rust image with build tools
FROM rust:1.77-bookworm AS builder
WORKDIR /app

## 2) Copy manifest files first to maximize layer caching.
COPY Cargo.toml Cargo.lock ./
## If this is a workspace, copy member Cargo.toml files as needed.
COPY crates/my_service/Cargo.toml crates/my_service/Cargo.toml

## 3) Create a temporary main file so dependencies can build and cache.
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release && rm -rf src

## 4) Copy source code
COPY . .

## 5) Build the actual application binary.
RUN cargo build --release

# Stage 2: Runtime stage
## 1) Use a minimal base image for runtime
FROM debian:bookworm-slim AS runtime

## 2) Set working directory
WORKDIR /app

# 3) Install only necessary runtime dependencies (if dynamically linked)
# CA certificates is common for services that make outbound HTTPS calls.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 4) Create non-root user for safer runtime defaults.
RUN useradd --system --uid 10001 appuser

# 5) Copy the built binary from the builder stage
COPY --from=builder /app/target/release/my_service /usr/local/bin/my_service

# 6) Set ownership to non-root user
USER 10001

# 7) Expose the service port
EXPOSE 3000

# 8) Define the entrypoint
ENTRYPOINT ["/usr/local/bin/my_service"]
```

### Why This Dockerfile Structure is Good

- Dependency layers are cached when source changes but manifests do not
- Runtime image excludes Rust toolchain and build artifacts
- Container runs as non-root
- Runtime has only minimal required packages

---

## **Rust Binary Strategy in Containers**

Rust supports two common container approaches:

### 1. Dynamic Linking + Slim Base

- Build for GNU target (default)
- Run in slim Debian/Ubuntu base
- Easiest compatibility path

This is usually the best starting point for teams because it is predictable and easy to debug.

- You keep compatibility with common Linux runtime libraries.
- You can shell into the container and inspect issues more easily.
- TLS certificates and native libraries are straightforward to manage.

Example snippet:

```dockerfile
# Build stage
FROM rust:1.77-bookworm AS builder
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim
COPY --from=builder /app/target/release/my_service /usr/local/bin/my_service
ENTRYPOINT ["/usr/local/bin/my_service"]
```

### 2. Static Linking + Minimal Base

- Build Rust code with MUSL target
- Run in `scratch` or distro-less static image
- Smaller image and reduced runtime dependencies

This is a good fit when image size and startup speed are critical, and your team is comfortable with lean runtime environments.

- Fewer runtime dependencies reduce attack surface.
- Startup can be very fast in autoscaling environments.
- Debugging is harder because minimal images often lack shell and utilities.

Example minimal runtime:

```dockerfile
# Build stage
FROM rust:1.77-bookworm AS builder
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target x86_64-unknown-linux-musl

# Runtime stage
FROM scratch
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/my_service /my_service
ENTRYPOINT ["/my_service"]
```

> Trade-off: `scratch` images are tiny, but troubleshooting is harder because shell/debug tools are absent.

### Quick Decision Rule

- Choose **dynamic linking + slim base** when reliability and easier operations are the priority.
- Choose **static linking + minimal base** when footprint and startup performance are the priority.
- If unsure, start dynamic, measure, then optimize to static where it provides clear value.

---

## **Running and Inspecting Containers**

### Basic Workflow

```bash
docker build -t rust-api:dev .
docker run --rm -p 3000:3000 --name rust-api rust-api:dev
```

### Useful Inspection Commands

```bash
docker ps
docker logs rust-api
docker exec -it rust-api sh
docker inspect rust-api
docker stats
```

### Health Checks

When services expose `/health`, add a health check in the image or orchestrator to avoid routing traffic to unhealthy containers.

---

## **Docker Compose for Local Multi-Service Development**

Compose is ideal for reproducing a production-like topology locally (API, database, cache, queue).

### Example Compose File Structure

Rust API + Postgres with Health Checks

```yaml
# Docker compose version
version: "3.9"

# Define services
services:
  api: # Name of the service
    build: . # Build from current directory (Dockerfile)
    ports: # Map container port to(:) host port
      - "3000:3000"
    environment: # Environment variables for the container
      DATABASE_URL: postgres://postgres:example@db:5432/app
    depends_on: # Dependency
      db:
        condition: service_healthy # Set expected health condition for dependency

  db: # Name of Second (database) service
    image: postgres:15 # Uses official Postgres image
    environment: # Environment variables to configure
      POSTGRES_DB: app
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: example
    ports: # Map container port to(:) host port
      - "5432:5432"
    healthcheck: # Define health check for the database
      test: ["CMD-SHELL", "pg_isready -U postgres -d app"]
      interval: 5s
      timeout: 3s
      retries: 10
```

### Key Words

- `build`: context for building a services image (Dockerfile location)
- `image`: tag for the built image (optional if `build` is used)
- `ports`: map container ports to host ports for access
- `environment`: set environment variables for the container
- `depends_on`: define service dependencies and health conditions

### Compose Concepts to Know

- `depends_on` with health conditions improves startup reliability
- Service names become DNS names on the Compose network (for example `db`)
- `.env` files can centralize local config values

---

## **Image Distribution and Registry Workflow**

Registries store versioned images that deployments consume. Common registries include Docker Hub, GitHub Container Registry, AWS ECR, and Azure ACR.

### Standard Flow

The standard flow of distributing images involves building, tagging, pushing to a registry, and pulling from the registry for production.

```bash
# Development build, test, tag, and register
docker build -t my-service:1.0.0 .
docker tag my-service:1.0.0 username/my-service:1.0.0
docker push username/my-service:1.0.0

# Production pull
docker pull username/my-service:1.0.0
```

### Tagging Practices

- Use immutable version tags (`1.0.0`, git SHA)
- Avoid deploying by `latest` alone
- Optionally publish both `1.0.0` and short SHA for traceability

---

## **Security and Hardening**

Container security is mostly about narrowing runtime privileges and reducing attack surface. Best practices include:

### Practical Baseline

- Use minimal runtime images
- Run as non-root user
- Avoid baking secrets into images
- Pin base image versions
- Scan images for CVEs in CI

### Rust-Specific Notes

- A single binary reduces dependency footprint
- Memory safety reduces certain runtime vulnerability classes
- Still requires dependency and supply-chain hygiene (`cargo audit`, signed images, provenance)

---

## **Performance and Build Efficiency**

### Faster Builds

- Structure Dockerfile to maximize layer cache reuse
- Keep `.dockerignore` strict to avoid sending large contexts
- Cache `target` or use BuildKit cache mounts in CI

### Smaller and Faster Runtime

- Strip debug symbols when appropriate
- Use static linking if operationally beneficial
- Keep startup path simple (fast readiness under autoscaling)

---

## **Alternatives**

- **Podman**: daemonless engine, strong rootless workflows
- **Buildah**: focused image build tooling
- **LXD**: system containers with VM-like characteristics

Tool choice is less important than consistent image standards, security policy, and deployment discipline.

---

## **Professional Applications and Implementation**

Containerization is central to modern service delivery:

- Deploying Rust microservices with repeatable runtime behavior
- Standardizing CI/CD artifact generation
- Enabling blue/green and canary rollout workflows
- Supporting hybrid topologies across cloud, on-prem, and edge

Rust strengthens this model by producing:

- Lightweight runtime artifacts
- Predictable performance characteristics
- Efficient resource usage under high concurrency

---

## **Key Takeaways**

| Concept Area | Summary |
| ------------ | ------- |
| Containerization | Packages application runtime into a consistent, portable unit. |
| Docker Model | Images are immutable templates; containers are runtime instances. |
| Rust + Docker | Rust binaries pair well with minimal images and fast startup needs. |
| Multi-Stage Builds | Separate build and runtime stages for smaller, safer images. |
| Compose Workflows | Compose enables realistic local multi-service development. |
| Production Readiness | Security hardening, observability, and versioned image distribution are essential. |

- Containers make deployment behavior more predictable across environments
- Dockerfile quality directly affects security, build speed, and runtime cost
- Rust services benefit from small, efficient container footprints
- Multi-stage builds and non-root runtime defaults should be standard practice
- Containerization is foundational for scalable microservice operations

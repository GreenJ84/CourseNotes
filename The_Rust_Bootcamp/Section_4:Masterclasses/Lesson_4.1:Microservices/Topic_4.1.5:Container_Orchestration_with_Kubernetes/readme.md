# **Topic 4.1.5: Container Orchestration with Kubernetes**

Kubernetes is an open-source container orchestration platform that automates deployment, scaling, networking, and recovery for containerized applications. In a microservices architecture, it acts as the coordination layer that keeps many independent services running as a system rather than as isolated containers. For Rust services, Kubernetes is a strong fit because Rust binaries are typically small, fast to start, and memory-efficient, which makes scheduling, scaling, and rolling updates more predictable.

The important idea is not that Kubernetes is a container runtime. It is a control system. You describe the state you want, and Kubernetes continuously works to make the real cluster match that desired state.

## **Learning Objectives**

- Explain why orchestration becomes necessary once a system grows beyond a few containers
- Describe the Kubernetes control plane and worker node responsibilities
- Use Pods, Deployments, Services, ConfigMaps, Secrets, and HPAs correctly
- Connect Rust service behavior to readiness, liveness, scaling, and resource tuning
- Build a simple but production-minded Kubernetes deployment for a Rust API
- Evaluate when Kubernetes is the right tool and when a simpler platform is better
- Apply practical security, observability, and operations patterns in Kubernetes

---

## **Why Orchestration is Required**

Running containers manually works for a demo, but it breaks down quickly in production. Once you have multiple services, multiple replicas, and shared dependencies, you need a system that can keep everything coordinated.

### Problems Without Orchestration

- You must start, stop, restart, and update containers by hand
- Scaling requires manual intervention and extra scripting
- Service discovery becomes brittle because container IPs change
- Failures are not automatically corrected
- Resource usage is harder to measure and control
- Deployments become risky because there is no standard rollout mechanism

### What Orchestration Solves

- Schedules workloads onto healthy nodes automatically
- Replaces failed containers without human intervention
- Adds and removes replicas based on demand
- Provides stable networking and name resolution
- Centralizes configuration, secrets, and rollout strategy
- Gives operators a declarative way to manage the whole system

In practice, orchestration is what lets a set of Rust services behave like one resilient application instead of a collection of processes.

---

## **Kubernetes Architecture**

Kubernetes uses a **control plane + worker node** architecture. The control plane decides what should happen. Worker nodes execute the actual workloads.

### Control Plane Components

The control plane consists of several components that work together to manage the cluster state.

#### API Server

The API server is the front door to the cluster. Every request from `kubectl`, CI pipelines, operators, and controllers goes through it.

- Validates and stores cluster changes
- Exposes the Kubernetes API
- Acts as the central coordination point for the system

#### Scheduler

The scheduler decides which node should run each Pod.

- Checks available CPU, memory, taints, toleration, and affinity rules
- Tries to place Pods where they can run successfully
- Avoids overloading a node when possible

#### Controller Manager

Controllers are reconciliation loops. They compare the desired state to the current state and make changes until the two match.

- ReplicaSet controller ensures the right number of Pods exists
- Deployment controller coordinates rollouts and rollbacks
- Node controller reacts when nodes become unhealthy

#### etcd

etcd is the cluster state store.

- Stores configuration and object metadata
- Must be reliable because the whole control plane depends on it
- In production, loss of etcd can affect the entire cluster

### Worker Node Components

Worker nodes run the actual application containers.

#### kubelet

The kubelet runs on each node and makes sure the containers assigned to that node are actually running.

- Watches Pod specs from the API server
- Starts and stops containers through the runtime
- Reports node and container health back to the control plane

#### Container Runtime

This is the software that actually runs containers.

- Common examples: containerd, CRI-O
- Kubernetes talks to it through the Container Runtime Interface

#### kube-proxy

The kube-proxy handles networking rules that allow traffic to reach the right Pods.

- Helps Services route traffic to healthy backends
- Participates in the Service abstraction

### How the Pieces Work Together

1. You submit a Deployment to the API server
2. The Deployment controller creates or updates a ReplicaSet
3. The scheduler assigns Pods to worker nodes
4. The kubelet starts the container runtime on those nodes
5. Services and networking rules make the Pods reachable
6. Controllers continue reconciling the desired state over time

This loop is what gives Kubernetes its reliability.

---

## **Core Kubernetes Primitives**

### Pods

A Pod is the smallest deployable unit in Kubernetes.

- A Pod can contain one container or a small group of tightly coupled containers
- Containers in the same Pod share network space and storage volumes
- Pods are ephemeral; they can be replaced at any time

For Rust microservices, the most common pattern is still simple:

> one service = one container = one Pod

That keeps debugging and scaling easy. Use multi-container Pods only when the sidecar truly belongs with the main process, such as a log shipper or proxy.

### Deployments

Deployments manage Pods declaratively.

- Keep a target replica count
- Perform rolling updates
- Support rollbacks when a new version misbehaves
- Separate the application template from the runtime state

#### Example Deployment for a Rust API

```yaml
apiVersion: apps/v1 # The API version for Deployments
kind: Deployment # The type of Kubernetes object
metadata: # Metadata about the Deployment
  name: rust-api
spec: # The desired state of the Deployment
  replicas: 3 # Number of desired Pods
  selector: # How to identify which Pods belong to this Deployment
    matchLabels:
      app: rust-api
  template: # The template for the Pods that will be created
    metadata:
      labels:
        app: rust-api
    spec: # The specification for the Pod's contents
      containers: # The list of containers in the Pod
        - name: rust-api # The name of the container
          image: myrepo/rust-api:1.0.0
          ports: # The ports the container exposes
            - containerPort: 3000
          env: # Environment variables for the container
            - name: RUST_LOG
              value: info
          readinessProbe: # Check if the service is ready to receive traffic
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe: # Check if the service is still alive
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          resources: # Resource requests and limits for the container
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
```

#### Why This Example Matters

- `replicas: 3` gives basic availability if a Pod or node fails
- `readinessProbe` keeps traffic away until the service is actually ready
- `livenessProbe` allows Kubernetes to restart a stuck process
- `resources` makes scheduling and capacity planning predictable

For Rust, probes are especially useful because a binary can start quickly, but the service may still need time to connect to databases, warm caches, or load configuration.

### Services

A Service gives Pods a stable network identity.

- Pod IPs change over time
- A Service gives clients one stable endpoint
- Traffic is distributed across matching Pods

#### Service Types

- **ClusterIP**: internal-only access inside the cluster
- **NodePort**: exposes the service on every node at a fixed port
- **LoadBalancer**: asks the cloud provider for an external load balancer

#### Example Service

```yaml
apiVersion: v1 # The API version for Services
kind: Service # The type of Kubernetes object
metadata: # Metadata about the Service
  name: rust-api
spec: # The desired state of the Service
  selector: # How to find the Pods that belong to this Service
    app: rust-api
  ports: # The ports that the Service exposes
    - port: 80
      targetPort: 3000
  type: ClusterIP
```

This says, “send traffic to Pods labeled `app: rust-api` on port 3000, and expose them internally as port 80.”

### ConfigMaps and Secrets

Applications should not bake configuration directly into the image and Kubernetes provides two primitives to keep configuration separate from code: ConfigMaps for non-sensitive data and Secrets for sensitive data. Both can be injected into Pods as environment variables or mounted as files.

> The important distinction is operational, not just technical. ConfigMaps are meant for values you are comfortable seeing in cluster metadata. Secrets should still be treated carefully, even though they are not plaintext configuration files.

#### ConfigMap

Use for non-sensitive settings:

- log level
- feature flags
- service URLs
- environment names

```yaml
apiVersion: v1 # The API version for ConfigMaps
kind: ConfigMap # The type of Kubernetes object
metadata: # Metadata about the ConfigMap
  name: rust-api-config
data: # Key-value pairs for configuration
  RUST_LOG: info
  APP_ENV: production
  DATABASE_HOST: postgres.default.svc.cluster.local
```

#### Secret

Use for sensitive values:

- database passwords
- API tokens
- TLS certificates
- signing keys

```yaml
apiVersion: v1 # The API version for Secrets
kind: Secret # The type of Kubernetes object
metadata: # Metadata about the Secret
  name: rust-api-secret
type: Opaque # The type of Secret (Opaque is the default)
stringData: # Key-value pairs for secrets (stringData allows plaintext input)
  DATABASE_PASSWORD: super-secret-value
```

### Horizontal Pod Autoscaler (HPA)

The HPA adjusts replica counts based on metrics.

- CPU usage is common because it is simple and available
- Memory usage can help if the service is memory-bound
- Custom metrics are useful when request rate or queue depth matters more than CPU

Types of metrics to considers:

- **Resource metrics**: CPU and memory usage
- **Container metrics**: metrics from individual containers within a Pod
- **Pod metrics**: Custom metrics averaged across all pods (request rate, latency, queue length)
- **External metrics**: cloud provider metrics, third-party monitoring data
- **Object metrics**: metrics from Kubernetes objects like Pods or Services

```yaml
apiVersion: autoscaling/v2 # The API version for HPAs
kind: HorizontalPodAutoscaler # The type of Kubernetes object
metadata: # Metadata about the HPA
  name: rust-api
spec: # The desired state of the HPA
  scaleTargetRef: # The target to scale
    apiVersion: apps/v1
    kind: Deployment
    name: rust-api
  minReplicas: 2 # Minimum number of replicas
  maxReplicas: 6 # Maximum number of replicas
  metrics: # Metrics to base scaling on (can be a list of multiple metrics)
    - type: Resource # Type of metric (Resource is built-in)
      resource: # Resource-specific configuration
        name: cpu
        target: # Target average utilization across all Pods
          type: Utilization
          averageUtilization: 70
```

For Rust services, HPA works well when the service is stateless and can be scaled horizontally without coordination.

### Ingress Controllers

Ingress is used when you want HTTP or HTTPS traffic from outside the cluster to reach internal Services.

- Handles host-based routing
- Often terminates TLS
- Can support path-based routing like `/api` and `/admin`

#### Simple Ingress Example

```yaml
apiVersion: networking.k8s.io/v1 # The API version for Ingress
kind: Ingress # The type of Kubernetes object
metadata: # Metadata about the Ingress
  name: rust-api-ingress
spec: # The desired state of the Ingress
  rules: # Routing rules for incoming traffic (list of rules for different hosts)
    - host: api.example.com
      http:
        paths: # List of paths to route for this host
          - path: /
            pathType: Prefix
            backend: # The backend to route to when this path is matched
              service: # The Service to route to
                name: rust-api
                port:
                  number: 80
```

This keeps external traffic policy separate from the application itself, which is a useful design boundary in real systems.

---

## **Kubernetes + Rust Microservices**

Rust services map cleanly onto Kubernetes because they are often small, deterministic, and easy to containerize.

### Why Rust Fits Well

- **Fast startup time**
  - Helps with deployments, scaling events, and restarts

- **Low memory usage**
  - Lets you run more Pods per node

- **Single binary deployment**
  - Simplifies the container image and reduces runtime dependencies

- **Predictable performance**
  - No garbage collector means latency is usually more stable

### Operational Insight

Rust’s strengths help most when Kubernetes is under pressure:

- A small binary reduces image pull time
- Fast startup shortens rollout time
- Lower memory use improves scheduling density
- Stable runtime behavior makes probe tuning easier

That said, Rust does not remove the need for good Kubernetes hygiene. You still need health checks, resource limits, and graceful shutdown handling.

### Example Workflow

Do not just copy the example YAML and hope for the best. Instead, think through the production behavior of your service and how it interacts with Kubernetes features.

1. Build the Rust binary in release mode
2. Package it into a Docker image
3. Push the image to a registry
4. Apply Kubernetes manifests (Deployment, Service, ConfigMap, etc.)
5. Expose the service with a Service or Ingress
6. Monitor health, logs, and scaling behavior

### Graceful Shutdown Matters

When Kubernetes stops a Pod, your service gets a termination signal. Rust services should respond cleanly by:

- stopping new requests
- finishing in-flight work
- closing database connections
- exiting before the grace period ends

This is one of the places where production behavior matters more than the code example itself. A service that does not shut down cleanly can drop requests during rolling deployments.

---

## **Networking and Service Discovery**

Every Pod gets its own IP address, but those IPs are not stable enough for clients to use directly. Services solve that problem.

### Internal DNS

Kubernetes creates DNS records for Services, which allows one service to reach another by name.

```text
http://rust-api.default.svc.cluster.local
```

That name means:

- `rust-api`: Service name
- `default`: Namespace
- `svc.cluster.local`: Cluster DNS suffix

### Load Balancing

When several Pods match a Service selector, traffic is distributed across them.

- This is how scale-out actually works
- If one Pod fails, traffic can continue flowing to the others
- Readiness checks help ensure only healthy Pods receive traffic

---

## **Advanced Concepts**

### Declarative Infrastructure

Kubernetes is declarative, not imperative.

- You describe the desired outcome
- Controllers handle the step-by-step reconciliation
- The system keeps working toward that state over time

This matters because it changes how you think about deployment. You are not telling Kubernetes how to do each action. You are telling it what the final state should be.

### Rolling Deployments

Rolling updates replace Pods gradually.

- Avoids full downtime in many cases
- Allows health checks to gate progress
- Helps catch bad releases before every replica is replaced

For Rust services, rolling deployment tends to be straightforward because startup is fast. The bigger risk is usually application readiness, not binary startup.

### Self-Healing

Self-healing is a core feature of Kubernetes.

- Restarts containers that crash
- Recreates Pods when nodes fail
- Keeps desired replica counts intact

This is useful, but it should not be used as a substitute for fixing a broken application. If a process crash loops, Kubernetes will keep trying until you correct the root cause.

### Resource Management

Resource requests and limits are critical for predictable scheduling.

Example resource configuration:

```yaml

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

#### How to Think About It

- **Requests** are what the scheduler uses to place the Pod
- **Limits** are the maximum the container should use
- A request that is too low can cause poor placement decisions
- A limit that is too low can cause throttling or out-of-memory kills

For Rust services, the right numbers depend on workload shape:

- lightweight JSON API: small CPU and memory footprint
- database-heavy service: higher memory and connection pool tuning
- streaming or queue worker: may need more CPU for batch processing

### Probes and Health Semantics

The terms readiness and liveness are easy to mix up, but they do different jobs.

- **Readiness probe**: should this Pod receive traffic?
- **Liveness probe**: is this Pod still healthy enough to keep running?

For a Rust API, readiness should usually verify dependencies that matter to serving requests, such as database connectivity or cache initialization. Liveness should stay lighter and only detect whether the process is stuck or irrecoverably unhealthy.

### Observability

You cannot operate a cluster well if you cannot see what it is doing.

- **Metrics**: Prometheus and Grafana for resource and request behavior
- **Logging**: Fluent Bit, Loki, or cloud-native logging systems
- **Tracing**: OpenTelemetry for request flow across services

For Rust, structured logging is especially helpful because it produces compact, machine-friendly output that works well with centralized log pipelines.

### Security

Security should be built into cluster design rather than added later.

- **RBAC** controls who can do what in the cluster
- **Network Policies** restrict which Pods can talk to each other
- **Pod Security Standards** reduce risky runtime behavior
- **Image scanning** helps catch vulnerable dependencies early

Practical Rust note: if your application does not need to run as root, it should not run as root in the container image or the Pod.

### Example Production Concerns

- Use `terminationGracePeriodSeconds` so services can shut down cleanly
- Keep image tags immutable instead of deploying `latest`
- Make probes reflect real readiness, not just process liveness
- Set CPU and memory requests based on measurements, not guesses
- Keep configuration outside the image so changes do not require rebuilds

---

## **Kubernetes Alternatives**

Kubernetes is the default choice for many teams, but it is not the only option.

### Docker Swarm

- Native Docker orchestration
- Easier to start with than Kubernetes
- Smaller ecosystem and fewer advanced features

### Nomad (HashiCorp)

- Lightweight orchestrator
- Supports containers and non-container workloads
- Pairs well with Consul for discovery and Vault for secrets

### Amazon ECS

- Managed orchestration on AWS
- Simpler operational model than Kubernetes
- Strong if you are already standardized on AWS

### Azure Container Apps / Google Cloud Run

- Managed container platforms
- Good for smaller services or event-driven workloads
- Reduce cluster management overhead significantly

### Podman + Systemd

- Useful for simpler host-based deployments
- Works well when you want fewer moving parts
- Does not provide the same multi-node orchestration layer

---

## **When to Use Kubernetes**

Kubernetes is a powerful platform, but it comes with operational complexity. It is not the right choice for every project.

### Good Fits

- Large-scale microservices systems
- Teams that need deployment automation and rollout control
- Systems requiring strong availability and self-healing
- Workloads with multiple services, dependencies, and environments
- Environments where infrastructure must be declared and reproduced consistently

### When to Choose Something Simpler

- Small applications with only a few services
- Teams still building operational maturity
- Projects that do not justify the extra platform complexity
- Systems where managed platform products are enough

A useful rule is this: choose Kubernetes when the operational value exceeds the platform cost. If you are spending more time on the cluster than on the product, the platform may be too heavy for the problem.

---

## **Professional Applications and Implementation**

Kubernetes is widely used in modern infrastructure because it standardizes how distributed systems are deployed and operated.

- Cloud-native application deployment
- Backend platforms serving large user bases
- High-availability systems with strict uptime needs
- CI/CD pipelines that promote the same artifact through multiple environments
- Infrastructure-as-code workflows with repeatable cluster state

For Rust systems, Kubernetes is a strong operational match:

- Rust binaries are compact and easy to package
- Start times are usually fast enough for responsive rollouts
- Memory efficiency improves cluster density
- The runtime profile tends to be predictable under load

### A Simple Production Mindset

If you are deploying a Rust service to Kubernetes, think about these questions before you apply the manifest:

1. What does healthy mean for this service?
2. What should happen if the database is slow?
3. How long should the service be allowed to shut down?
4. What happens when traffic spikes?
5. How will you observe failures when they happen?

Those questions are what turn a container into a dependable service.

---

## **Key Takeaways**

| Concept Area | Summary |
| --- | --- |
| Orchestration | Automates deployment, scaling, scheduling, and recovery for containers. |
| Kubernetes | Provides the control plane that keeps distributed systems aligned with desired state. |
| Core Primitives | Pods, Deployments, Services, ConfigMaps, Secrets, and HPAs form the basic toolkit. |
| Rust Integration | Rust services benefit from fast startup, low memory use, and predictable runtime behavior. |
| Probes and Resources | Readiness, liveness, requests, and limits are essential for stable operations. |
| Alternatives | Simpler managed platforms may be a better fit when complexity is not justified. |

- Kubernetes reduces the coordination burden of running many containers
- Declarative configuration is the foundation of reliable cluster operations
- Rust services fit Kubernetes well, but they still need probes, limits, and graceful shutdown
- Observability and security are part of the design, not optional extras
- Choose the simplest platform that satisfies the real operational requirements


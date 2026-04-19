# Orchestration — Container Management & Multi-Service Deployment

> **When to use this file:** Only for microservices or multi-service architectures
> that need container orchestration. Monolith projects with simple deployment skip
> this file. If you deploy a single Docker container to a PaaS, skip this file.

---

## Container Strategy Decision

| Project Size          | Recommended                          | Why                                |
|-----------------------|--------------------------------------|------------------------------------|
| 1 service             | Docker + PaaS (Railway, Fly, Render) | Simplest, no orchestration needed  |
| 2-3 services          | Docker Compose (dev) + managed K8s   | Manageable complexity              |
| 4-10 services         | Kubernetes (EKS, GKE, AKS)          | Service discovery, scaling, health |
| 10+ services          | Kubernetes + Service Mesh (Istio)    | Traffic management, observability  |
| Event-heavy           | Kubernetes + KEDA                    | Event-driven autoscaling           |

---

## 1. Docker — Service Containerization

### Dockerfile Standard (Production-Grade)

Every service MUST have a multi-stage Dockerfile:

```dockerfile
# ============================================
# Stage 1: Dependencies
# ============================================
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

# ============================================
# Stage 2: Build
# ============================================
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ============================================
# Stage 3: Production
# ============================================
FROM node:20-alpine AS production
WORKDIR /app

# Security: non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copy only what's needed
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./

# Environment
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Non-root execution
USER appuser

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### Dockerfile Rules

- **ALWAYS** use multi-stage builds (smaller images, no dev dependencies)
- **ALWAYS** run as non-root user
- **ALWAYS** include HEALTHCHECK
- **ALWAYS** use specific base image tags (not `latest`)
- **ALWAYS** use `.dockerignore` to exclude `node_modules`, `.git`, `.env`
- **NEVER** copy `.env` files into images
- **NEVER** store secrets in image layers
- Keep images under 200MB (prefer Alpine base)

### .dockerignore Standard

```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.*
*.md
tests/
coverage/
.vscode/
.idea/
docker-compose*.yml
Dockerfile
```

---

## 2. Docker Compose — Local Development

### Multi-Service Development Stack

```yaml
# docker-compose.yml — Local development
version: "3.9"

services:
  # ---- API Gateway ----
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./infrastructure/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      auth-service:
        condition: service_healthy
      core-service:
        condition: service_healthy

  # ---- Auth Service ----
  auth-service:
    build:
      context: ./services/auth-service
      dockerfile: Dockerfile
      target: production
    ports:
      - "3001:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://postgres:postgres@auth-db:5432/auth_db
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=dev-secret-change-in-prod
      - MESSAGE_BROKER_URL=amqp://rabbitmq:5672
    depends_on:
      auth-db:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

  # ---- Core Service ----
  core-service:
    build:
      context: ./services/core-service
      dockerfile: Dockerfile
      target: production
    ports:
      - "3002:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://postgres:postgres@core-db:5432/core_db
      - AUTH_SERVICE_URL=http://auth-service:3000
      - MESSAGE_BROKER_URL=amqp://rabbitmq:5672
    depends_on:
      core-db:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  # ---- Notification Service ----
  notification-service:
    build:
      context: ./services/notification-service
      dockerfile: Dockerfile
      target: production
    ports:
      - "3003:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://postgres:postgres@notify-db:5432/notify_db
      - MESSAGE_BROKER_URL=amqp://rabbitmq:5672
    depends_on:
      notify-db:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  # ---- Databases (one per service) ----
  auth-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: auth_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - auth-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  core-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: core_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - core-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  notify-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: notify_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - notify-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  # ---- Shared Infrastructure ----
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"   # Management UI
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "-q", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  auth-db-data:
  core-db-data:
  notify-db-data:
```

### Docker Compose Commands Reference

```bash
# Start all services
docker compose up -d

# Start specific service with dependencies
docker compose up -d core-service

# Rebuild after code change
docker compose up -d --build auth-service

# View logs (follow mode)
docker compose logs -f auth-service

# View all service health
docker compose ps

# Stop all
docker compose down

# Stop and remove volumes (CAUTION: deletes data)
docker compose down -v

# Run one-off command in service
docker compose exec auth-service npm run migrate
```

---

## 3. Kubernetes — Production Orchestration

### Namespace Strategy

```
├── production/
│   ├── auth-service
│   ├── core-service
│   ├── notification-service
│   └── payment-service
├── staging/
│   └── (mirrors production)
├── monitoring/
│   ├── prometheus
│   ├── grafana
│   └── jaeger
└── infrastructure/
    ├── ingress-controller
    ├── cert-manager
    └── external-secrets
```

### Deployment Manifest (Standard)

```yaml
# k8s/auth-service/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: production
  labels:
    app: auth-service
    version: v1.2.3
    team: core
spec:
  replicas: 3
  selector:
    matchLabels:
      app: auth-service
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # Max pods above desired during update
      maxUnavailable: 0     # Zero downtime
  template:
    metadata:
      labels:
        app: auth-service
        version: v1.2.3
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: auth-service
      terminationGracePeriodSeconds: 30
      containers:
        - name: auth-service
          image: registry.example.com/auth-service:v1.2.3
          ports:
            - containerPort: 3000
              protocol: TCP
          envFrom:
            - configMapRef:
                name: auth-service-config
            - secretRef:
                name: auth-service-secrets
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          # Startup: is the app ready to receive probes?
          startupProbe:
            httpGet:
              path: /health/startup
              port: 3000
            failureThreshold: 30
            periodSeconds: 2
          # Liveness: should K8s restart this pod?
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 0
            periodSeconds: 10
            failureThreshold: 3
          # Readiness: should traffic be routed here?
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 0
            periodSeconds: 5
            failureThreshold: 3
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - auth-service
                topologyKey: kubernetes.io/hostname
```

### Service Manifest

```yaml
# k8s/auth-service/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: production
spec:
  selector:
    app: auth-service
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
  type: ClusterIP
```

### ConfigMap & Secrets

```yaml
# k8s/auth-service/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: auth-service-config
  namespace: production
data:
  NODE_ENV: "production"
  PORT: "3000"
  LOG_LEVEL: "info"
  AUTH_SERVICE_URL: "http://auth-service.production.svc.cluster.local"
  CORE_SERVICE_URL: "http://core-service.production.svc.cluster.local"
  REDIS_HOST: "redis.infrastructure.svc.cluster.local"
  REDIS_PORT: "6379"
```

```yaml
# k8s/auth-service/external-secret.yaml (using External Secrets Operator)
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: auth-service-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: auth-service-secrets
  data:
    - secretKey: DATABASE_URL
      remoteRef:
        key: production/auth-service
        property: database_url
    - secretKey: JWT_SECRET
      remoteRef:
        key: production/auth-service
        property: jwt_secret
```

### Ingress (API Gateway)

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway
  namespace: production
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /auth
            pathType: Prefix
            backend:
              service:
                name: auth-service
                port:
                  number: 80
          - path: /api/v1
            pathType: Prefix
            backend:
              service:
                name: core-service
                port:
                  number: 80
          - path: /notifications
            pathType: Prefix
            backend:
              service:
                name: notification-service
                port:
                  number: 80
```

---

## 4. Helm Charts — Templated Deployment

### Chart Structure

```
helm/
├── charts/
│   ├── service/                  ← Reusable base chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── configmap.yaml
│   │       ├── hpa.yaml
│   │       ├── pdb.yaml
│   │       └── _helpers.tpl
│   └── infrastructure/           ← Shared infra chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── redis.yaml
│           ├── rabbitmq.yaml
│           └── ingress.yaml
├── environments/
│   ├── production.yaml
│   ├── staging.yaml
│   └── development.yaml
└── helmfile.yaml                 ← Orchestrates all charts
```

### Base Service Values

```yaml
# helm/charts/service/values.yaml
replicaCount: 2

image:
  repository: ""      # Set per service
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  port: 80
  targetPort: 3000

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilization: 70
  targetMemoryUtilization: 80

probes:
  startup:
    path: /health/startup
    failureThreshold: 30
    periodSeconds: 2
  liveness:
    path: /health/live
    periodSeconds: 10
  readiness:
    path: /health/ready
    periodSeconds: 5

podDisruptionBudget:
  minAvailable: 1

env: {}
secrets: {}
```

### Helmfile — Multi-Service Orchestration

```yaml
# helmfile.yaml
environments:
  production:
    values:
      - environments/production.yaml
  staging:
    values:
      - environments/staging.yaml

releases:
  - name: auth-service
    chart: ./charts/service
    namespace: production
    values:
      - image:
          repository: registry.example.com/auth-service
          tag: {{ requiredEnv "AUTH_VERSION" }}
      - replicaCount: 3
      - env:
          NODE_ENV: production
          LOG_LEVEL: info

  - name: core-service
    chart: ./charts/service
    namespace: production
    values:
      - image:
          repository: registry.example.com/core-service
          tag: {{ requiredEnv "CORE_VERSION" }}
      - replicaCount: 3

  - name: notification-service
    chart: ./charts/service
    namespace: production
    values:
      - image:
          repository: registry.example.com/notification-service
          tag: {{ requiredEnv "NOTIFY_VERSION" }}
      - replicaCount: 2

  - name: infrastructure
    chart: ./charts/infrastructure
    namespace: infrastructure
```

### Helm Commands Reference

```bash
# Install / upgrade a service
helm upgrade --install auth-service ./charts/service \
  -f environments/production.yaml \
  --set image.tag=v1.2.3 \
  --namespace production

# Deploy all services via helmfile
helmfile -e production apply

# Diff before applying (see what changes)
helmfile -e production diff

# Rollback to previous release
helm rollback auth-service 1 --namespace production

# View release history
helm history auth-service --namespace production
```

---

## 5. Scaling Policies

### Horizontal Pod Autoscaler (HPA)

```yaml
# k8s/auth-service/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: auth-service
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: auth-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
    # Scale on CPU
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    # Scale on memory
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    # Scale on custom metric (requests per second)
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: 100
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60    # Wait 1 min before scaling up more
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60             # Add max 2 pods per minute
    scaleDown:
      stabilizationWindowSeconds: 300   # Wait 5 min before scaling down
      policies:
        - type: Pods
          value: 1
          periodSeconds: 120            # Remove max 1 pod every 2 minutes
```

### Pod Disruption Budget (PDB)

Ensures minimum availability during voluntary disruptions (node drain, updates):

```yaml
# k8s/auth-service/pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: auth-service
  namespace: production
spec:
  minAvailable: 1        # At least 1 pod must always be running
  selector:
    matchLabels:
      app: auth-service
```

### Scaling Guidelines

| Service Type          | Min Replicas | Max Replicas | Scale Metric            |
|-----------------------|--------------|--------------|-------------------------|
| API Gateway           | 2            | 20           | Requests/second         |
| Auth Service          | 2            | 10           | CPU + requests/s        |
| Core Service          | 2            | 15           | CPU + custom business   |
| Notification Service  | 1            | 5            | Queue depth (KEDA)      |
| Background Workers    | 1            | 10           | Queue depth (KEDA)      |

---

## 6. Deployment Strategies

### Rolling Update (Default — Recommended)

Zero-downtime update. Old pods replaced one-by-one with new pods.

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1          # 1 extra pod during update
    maxUnavailable: 0     # Never remove a pod before new one is ready
```

**Use when:** Most deployments. Safe, automatic rollback on crash.

### Canary Deployment

Route a small percentage of traffic to the new version. Monitor. Then promote.

```yaml
# Using Argo Rollouts
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: core-service
spec:
  replicas: 5
  strategy:
    canary:
      steps:
        - setWeight: 10         # 10% traffic to canary
        - pause: { duration: 5m }
        - setWeight: 30         # 30% traffic
        - pause: { duration: 5m }
        - setWeight: 60         # 60% traffic
        - pause: { duration: 5m }
        # Implicit: promote to 100%
      canaryMetadata:
        labels:
          deployment: canary
      stableMetadata:
        labels:
          deployment: stable
      analysis:
        templates:
          - templateName: success-rate
        startingStep: 1
        args:
          - name: service-name
            value: core-service
---
# Auto-rollback if error rate > 5%
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
    - name: service-name
  metrics:
    - name: success-rate
      interval: 60s
      successCondition: result[0] >= 0.95
      provider:
        prometheus:
          address: http://prometheus.monitoring:9090
          query: |
            sum(rate(http_requests_total{service="{{args.service-name}}",status=~"2.."}[2m]))
            /
            sum(rate(http_requests_total{service="{{args.service-name}}"}[2m]))
```

**Use when:** Critical services, major version bumps, high-risk changes.

### Blue-Green Deployment

Run two identical environments. Switch traffic instantly.

```
Blue (current) ← traffic
Green (new)    ← idle, being tested

After verification:
Blue (old)     ← idle (keep for rollback)
Green (new)    ← traffic
```

**Use when:** Need instant rollback capability. Requires 2x resources.

### Strategy Decision

| Factor                    | Rolling Update | Canary      | Blue-Green    |
|---------------------------|----------------|-------------|---------------|
| Downtime                  | Zero           | Zero        | Zero          |
| Rollback speed            | Slow (re-deploy)| Fast (shift weight)| Instant (switch)|
| Resource cost             | Low (+1 pod)   | Medium      | High (2x)     |
| Risk                      | Medium         | Low         | Low           |
| Complexity                | Low            | Medium      | Medium        |
| **Recommended for**       | Most services  | Critical API| Database migrations |

---

## 7. CI/CD Pipeline for Microservices

### Pipeline per Service

```yaml
# .github/workflows/auth-service.yml
name: auth-service CI/CD

on:
  push:
    paths:
      - "services/auth-service/**"
      - ".github/workflows/auth-service.yml"

env:
  SERVICE: auth-service
  REGISTRY: registry.example.com

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run unit tests
        run: cd services/${{ env.SERVICE }} && npm ci && npm test
      - name: Run contract tests
        run: cd services/${{ env.SERVICE }} && npm run test:contracts

  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        id: meta
        run: |
          VERSION=$(git rev-parse --short HEAD)
          docker build -t $REGISTRY/$SERVICE:$VERSION services/$SERVICE
          docker push $REGISTRY/$SERVICE:$VERSION
          echo "version=$VERSION" >> $GITHUB_OUTPUT

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          helm upgrade --install $SERVICE ./helm/charts/service \
            -f helm/environments/staging.yaml \
            --set image.tag=${{ needs.build.outputs.image-tag }} \
            --namespace staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production    # Requires manual approval
    steps:
      - name: Deploy to production
        run: |
          helm upgrade --install $SERVICE ./helm/charts/service \
            -f helm/environments/production.yaml \
            --set image.tag=${{ needs.build.outputs.image-tag }} \
            --namespace production
```

### Changed-Service Detection (Monorepo)

Only build/deploy services that actually changed:

```yaml
# .github/workflows/detect-changes.yml
jobs:
  detect:
    outputs:
      auth: ${{ steps.changes.outputs.auth }}
      core: ${{ steps.changes.outputs.core }}
      notify: ${{ steps.changes.outputs.notify }}
    steps:
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            auth:
              - 'services/auth-service/**'
            core:
              - 'services/core-service/**'
            notify:
              - 'services/notification-service/**'

  deploy-auth:
    needs: detect
    if: needs.detect.outputs.auth == 'true'
    uses: ./.github/workflows/auth-service.yml

  deploy-core:
    needs: detect
    if: needs.detect.outputs.core == 'true'
    uses: ./.github/workflows/core-service.yml
```

---

## 8. Service Mesh (Advanced)

### When You Need It

| Symptom                                        | Service Mesh Feature    |
|------------------------------------------------|-------------------------|
| Need mTLS between all services automatically   | Automatic mTLS          |
| Need traffic splitting for canary deployments  | Traffic management      |
| Need retry/timeout policies without code changes| Resilience policies    |
| Need observability without instrumenting code  | Auto-injection tracing  |
| More than 10 services with complex routing     | Traffic routing rules   |

### Istio Setup (Most Popular)

```yaml
# Enable sidecar injection for namespace
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    istio-injection: enabled
---
# Traffic routing (canary)
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: core-service
spec:
  hosts:
    - core-service
  http:
    - route:
        - destination:
            host: core-service
            subset: stable
          weight: 90
        - destination:
            host: core-service
            subset: canary
          weight: 10
---
# Retry policy (no code changes needed)
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: auth-service
spec:
  hosts:
    - auth-service
  http:
    - route:
        - destination:
            host: auth-service
      retries:
        attempts: 3
        perTryTimeout: 2s
        retryOn: 5xx,reset,connect-failure
      timeout: 10s
```

---

## 9. Development Orchestration — All Services Running

### The Problem

In microservices development, a common failure mode:

```
Developer works on auth-service frontend
  → Frontend calls auth-service API → works ✅
  → auth-service publishes event → nobody listening ❌
  → core-service never creates default resources ❌
  → Developer thinks everything works — it doesn't
```

**Rule: During development, ALL services MUST be running simultaneously.**
Partial infrastructure produces partial results. Mock services hide real bugs.

### The Solution: services-check.sh

Every microservices project MUST use the services health check script at session start:

```bash
# Check if all services are running
bash scripts/services-check.sh

# Start all services + verify health
bash scripts/services-check.sh --start

# Wait until all services are healthy (CI/CD friendly)
bash scripts/services-check.sh --wait

# Restart everything (after config changes)
bash scripts/services-check.sh --restart
```

### Integration with Session Protocol

When architecture = microservices, `/session-start` MUST include:

```
STEP 0.5: Verify all microservices are running
  $ bash scripts/services-check.sh
  - If ALL HEALTHY → continue normally
  - If ANY DOWN → ask user: "X services are down. Start all? [Y/n]"
    - If yes → $ bash scripts/services-check.sh --start
    - If no → WARN: "Working against partial infrastructure. Test results unreliable."
  - If ANY UNHEALTHY → show logs, propose fix before continuing
```

### Agent Integration Rules

| Agent                | Requirement                                                    |
|----------------------|----------------------------------------------------------------|
| **Test Engineer**    | MUST verify all services running before integration tests      |
| **Debugger**         | MUST verify all services running before cross-service debugging|
| **Deploy Guardian**  | MUST verify all services healthy before deployment approval    |
| **Architect**        | Should verify service dependencies match SERVICE_MAP.md        |
| **Reality Auditor**  | MUST verify services are running to detect mock vs real APIs   |
| **Code Reviewer**    | Should flag tests that only work with partial infrastructure   |

### Development Workflow

```
1. Start session
   $ /session-start
   → services-check.sh runs automatically
   → All 5 services healthy ✅

2. Develop on one service
   $ # Edit auth-service code
   $ # Docker hot-reload picks up changes
   $ # OR rebuild just one service:
   $ docker compose up -d --build auth-service

3. Test across services
   $ # Integration tests run against REAL services
   $ # Events flow through REAL message broker
   $ # API calls hit REAL endpoints

4. Before committing
   $ bash scripts/services-check.sh
   → Verify nothing broke during development

5. End session
   $ /session-end
   → Optionally: docker compose down (or leave running)
```

### Hot-Reload for Development

Add volume mounts for dev mode so code changes are picked up without rebuilding:

```yaml
# docker-compose.override.yml (dev only, auto-loaded by Docker Compose)
services:
  auth-service:
    build:
      target: build          # Use build stage (has dev deps)
    volumes:
      - ./services/auth-service/src:/app/src    # Hot reload
    command: npm run dev     # nodemon / tsx watch
    environment:
      - NODE_ENV=development

  core-service:
    build:
      target: build
    volumes:
      - ./services/core-service/src:/app/src
    command: npm run dev
    environment:
      - NODE_ENV=development
```

### Common Issues

| Symptom                              | Cause                                | Fix                                    |
|--------------------------------------|--------------------------------------|----------------------------------------|
| Service starts then immediately dies | Missing env vars or bad config       | Check `docker compose logs [service]`  |
| Health check fails but container runs| App crashed inside container         | Check `docker compose logs [service]`  |
| Port already in use                  | Another process on that port         | `lsof -i :[port]` → kill or change port|
| Database connection refused          | DB not ready when app starts         | Add `depends_on: condition: service_healthy` |
| Services can't find each other       | Wrong service names in URLs          | Use Docker DNS: `http://service-name:port` |
| Events not flowing                   | Broker not running or misconfigured  | Check RabbitMQ management: `localhost:15672` |

---

## Orchestration Checklist

### For Every Service

- [ ] Multi-stage Dockerfile (deps → build → production)
- [ ] Non-root user in container
- [ ] HEALTHCHECK in Dockerfile
- [ ] `.dockerignore` present
- [ ] Image size < 200MB
- [ ] No secrets baked into image
- [ ] Resource requests and limits defined

### For Local Development

- [ ] `docker-compose.yml` starts all services + dependencies
- [ ] Health checks for all services in compose
- [ ] Separate database per service
- [ ] Hot-reload / volume mounts for dev
- [ ] Documented startup procedure (`docker compose up -d`)

### For Kubernetes Production

- [ ] Deployment manifests with rolling update strategy
- [ ] Service + Ingress configured
- [ ] ConfigMap for environment variables
- [ ] ExternalSecret for sensitive values (not plain K8s secrets)
- [ ] HPA with CPU + custom metrics
- [ ] PDB with `minAvailable: 1`
- [ ] Pod anti-affinity (spread across nodes)
- [ ] Startup, liveness, and readiness probes
- [ ] Prometheus annotations for metrics scraping
- [ ] Namespace isolation (production, staging, monitoring)

### For CI/CD

- [ ] Per-service pipeline (only build what changed)
- [ ] Contract tests run before deployment
- [ ] Staging environment with manual promotion to production
- [ ] Helm charts or Kustomize for templated deployments
- [ ] Rollback procedure documented and tested
- [ ] Canary deployment for critical services

---

## Tools Reference

| Tool                | Purpose                               | When to Use                    |
|---------------------|---------------------------------------|--------------------------------|
| **Docker**          | Container runtime                     | Always                         |
| **Docker Compose**  | Local multi-service development       | Development                    |
| **Kubernetes**      | Container orchestration               | Production (4+ services)       |
| **Helm**            | Kubernetes package manager            | Templated K8s deployments      |
| **Helmfile**        | Multi-chart orchestration             | Deploy multiple services       |
| **Argo Rollouts**   | Canary / blue-green deployments       | Critical services              |
| **Istio / Linkerd** | Service mesh                          | 10+ services, mTLS, traffic mgmt |
| **KEDA**            | Event-driven autoscaling              | Queue-based workers            |
| **Kustomize**       | K8s manifest patching                 | Simpler alternative to Helm    |
| **Skaffold**        | Local K8s development                 | Dev-loop with K8s              |

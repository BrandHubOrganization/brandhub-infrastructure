# Architecture Decision Records (`docs/adr/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [System Architecture →](../architecture/README.md) · [API Contracts →](../api/README.md) · [Database Design →](../database/README.md)

Architecture Decision Records (ADRs) document the foundational, cross-cutting engineering decisions governing **BrandHub**. Each ADR captures the real constraints faced by the engineering team, the alternatives evaluated and rejected, the exact runtime classes and infrastructure configurations implementing the decision, and the operational trade-offs accepted in production.

---

## 1. ADR Governance & Structure

Every ADR in this directory follows a five-part engineering format:
1. **Context & Problem Statement**: Functional scale (`141` FRs across `9` domains and `6` canonical roles: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), team topology, latency/consistency SLAs, and AWS `ap-southeast-1` cost constraints.
2. **Evaluated Options**: Concrete architectural alternatives weighed before committing.
3. **Decision Architecture**: The chosen boundary, protocol, or persistence contract.
4. **Codebase & Infrastructure Grounding**: Exact Java/Python packages, Spring WebFlux/Boot filters, RabbitMQ exchanges, Docker Compose fragments, and Terraform resources enforcing the decision today.
5. **Trade-offs & Operational Impact**: Positive outcomes, accepted complexity, and compensating guardrails.

---

## 2. Decision Log

| ADR | Title | Status | Core Scope & Cross-References |
| :--- | :--- | :---: | :--- |
| [ADR-001](./adr-001-polyrepo.md) | **Polyrepo Architecture Across 7 Independent Repositories** | Accepted | Isolates Java 21 Spring Boot/WebFlux, Python 3.11+ FastAPI, React 19 Vite 8, Expo 58 React Native 0.88, and Terraform/Compose IaC into independent repositories under `BrandHubOrganization` ([Polyrepo Visualizer](/view?file=architecture/polyrepo-structure.html), [Local Run Architecture](../architecture/local-run-architecture.md)) |
| [ADR-002](./adr-002-database-split.md) | **5-Engine Polyglot Persistence Split** | Accepted | Assigns ACID identity, 2-tier RBAC, SePay (VietQR) billing, and AI credit/storage ledgers to **PostgreSQL 17 (`97` tables)**; nested Tasks/Posts/Chat/Repository/Video to **MongoDB 7.0 (`52` collections)**; ephemeral auth/rate-limits/trends to **Redis 7.2**; Brand RAG embeddings to **ChromaDB 1.5.9**; and Trend Knowledge Graph to **Neo4j 5.26** ([Database Hub](../database/README.md), [DB Ownership Diagram](/view?file=architecture/db-ownership-diagram.html)) |
| [ADR-003](./adr-003-rabbitmq.md) | **RabbitMQ Direct & TTL-Retry Topology for Social Publishing** | Accepted | Decouples `brandhub-business-service` from external API latency across **Facebook, Instagram, TikTok, and Threads** via `publisher.job.exchange`, tiered TTL retry queues (`1m`/`5m`/`15m`), `publisher.job.dlq`, and Redis per-platform locks (`processingPostIds:{postId}:{platform}`) ([RabbitMQ Contract](/view?file=architecture/rabbitmq-publisher-contract.html), [Service Boundaries](../architecture/service-boundaries.md)) |
| [ADR-004](./adr-004-spring-cloud-gateway.md) | **Spring Cloud Gateway Perimeter, RS256 Auth & Zero-Trust Re-Verification** | Accepted | Centralizes ingress at `brandhub-api-gateway` (`InboundSecurityWebFilter`, RS256 `JWT_PUBLIC_KEY` verification, Redis `jwt:blacklist:{jti}`, Lua sliding-minute rate limiting, STOMP `/ws/*` routing) while enforcing 2-tier RBAC inside `brandhub-business-service` ([RS256 JWT Flow](../api/rs256-jwt-flow.md), [Rate Limiting](../api/redis-rate-limiting-filter.md)) |

---

## 3. Architectural Invariants Enforced Across All ADRs

- **Single Source of Truth per Entity**: No table or collection is written directly by two microservices ([Database Access Rules](../database/redis-cache/database-access-rules.md)).
- **Asymmetric Cryptographic Perimeter**: `JWT_PRIVATE_KEY`, `AES_SECRET_KEY`, and `REPOSITORY_ENCRYPTION_KEY_V1` never reside on the public edge gateway.
- **Strict Scope Alignment**: Only the **4 supported social platforms** (Facebook, Instagram, TikTok, Threads) and **SePay (VietQR)** upgrade-only / credit-pack billing flows are implemented across service contracts.

# ADR-001 — Polyrepo Architecture (7 Independent Repositories)

> Navigation: [← Knowledge Base Hub](../index.md) · [← ADR Index](./README.md) · [Polyrepo Structure](/view?file=architecture/polyrepo-structure.html) · [Local Run Architecture](../architecture/local-run-architecture.md)

- **Status:** Accepted
- **Owners:** Platform & Service Leads (`BrandHubOrganization`)
- **Related Docs:** [Technical Overview](../architecture/technical-overview.md) · [Deployment Runbook](../operations/deployment-acct134.md) · [Feature Workflow](../rule/feature-workflow.md)

---

## 1. Context & Problem Statement

BrandHub spans four distinct runtime ecosystems and deployment targets:
1. **Reactive & Servlet JVM Microservices (Java 21, Spring Boot 3 / Spring Cloud Gateway WebFlux)** for perimeter routing, core business orchestration, SePay (VietQR) billing, and social publishing.
2. **Python AI & Headless Browser Pipelines (Python 3.11+, FastAPI, PyTorch/SentenceTransformers, Playwright/Camoufox)** for Brand Hybrid GraphRAG, trend crawling, compliance checks, and remote Vast.ai GPU orchestration.
3. **Browser SPA & Static SEO Edge (TypeScript 6, React 19, Vite 8, Tailwind CSS 4)** deployed to AWS S3 + CloudFront (`brandhub.id.vn`).
4. **Native Mobile Client (Expo SDK 58, React Native 0.88)** built for Android/iOS devices with native camera, biometrics, and push notifications.
5. **Cloud Infrastructure & Polyglot DDL (Terraform `~> 6.0`, Docker Compose v2, SQL/Mongosh/Cypher, ComfyUI GPU bundles)**.

The 5-member engineering team needed to choose between a single multi-language monorepo and an independent polyrepo model with centralized architecture/infrastructure governance.

---

## 2. Evaluated Options

| Option | Pros | Cons / Why Rejected or Selected |
| :--- | :--- | :--- |
| **Option A: Single Monorepo** (`Nx` / `Turborepo` + Maven + Poetry + Expo) | Atomic cross-service commits; single PR for full-stack features | Severe CI matrix bloat; Metro/Expo workspace hoisting conflicts with Vite 8; heavy Python ML dependencies (`torch`, `chromadb`) slow down unrelated frontend/Java builds; noisy git history across 5 concurrent developers |
| **Option B: Frontend vs Backend Split** (2 repositories) | Separates UI from server code | Still couples Java 21 Maven builds (`business`, `gateway`, `publisher`) with Python FastAPI/Playwright containers and AWS Terraform state |
| **Option C: Service-Aligned Polyrepo (7 Core Repositories)** *(Selected)* | Clean runtime/build toolchains; independent ECR images & S3 deploys; clear ownership per squad member | Requires explicit cross-repo API/message contracts and workspace sync automation (`scripts/workspace/clone-all.bat`) |

---

## 3. Decision Architecture

Adopt a **7-repository Polyrepo** under GitHub Organization `BrandHubOrganization`, using `brandhub-infrastructure` as the single source of truth for cross-service contracts, database schemas, local Docker stacks, GPU worker bundles, and AWS production IaC:

| Repository | Tech Stack | Runtime Target & Port | Primary Responsibility |
| :--- | :--- | :--- | :--- |
| `brandhub-api-gateway` | Java 21, Spring Cloud Gateway (WebFlux) | `gateway` EC2 (`:8080` behind Nginx `:443`) | RS256 JWT verification, header sanitization, Redis rate limiting, HTTP & STOMP routing |
| `brandhub-business-service` | Java 21, Spring Boot 3, JPA + JDBC + Spring Data Mongo | `core` EC2 (`172.31.24.149:8081`) | Core 9-domain business logic (`141` FRs), 2-tier RBAC, SePay ACID billing, AI credit & S3 envelope crypto |
| `brandhub-ai-service` | Python 3.11+, FastAPI, ChromaDB, Neo4j, PhoBERT | `ai` EC2 (`172.31.20.60:8082`) | Brand Hybrid GraphRAG, caption/image/ambassador/video generation, BM25 + Graph trend scoring |
| `brandhub-publisher-service` | Java 21, Spring Boot 3, Spring AMQP, Redis | `core` EC2 (`172.31.24.149:8083`) | RabbitMQ consumer & OAuth lifecycle for **Facebook, Instagram, TikTok, and Threads** |
| `brandhub-web` | React 19.2, Vite 8.3, Tailwind 4.3, Yjs, TipTap | S3 `brandhub-web-prd-134875421878` + CloudFront (`:3000` local) | Bilingual (`vi`/`en`) Web SPA, collaborative editor, Video Space, analytics & Admin console |
| `brandhub-mobile-app` | Expo 58, React Native 0.88, React 19.3 | EAS / Android & iOS (`:8090` Metro local) | Mobile task approvals, content requests, push notifications, QR login & realtime chat |
| `brandhub-infrastructure` | Terraform, Docker Compose, SQL/JS/Cypher, VitePress | GitHub Pages + AWS `134875421878` + Vast.ai | Schemas, migrations, local Compose stacks, `prod/` Terraform & host configs, `gpu-workers/`, and `docs/` |

*(Auxiliary runtime repositories such as `brandhub-crawl` on `172.31.20.50:8084` and the `run-brandhub` local desktop runner follow the same sibling-directory convention.)*

---

## 4. Real Codebase & CI/CD Grounding

- **Sibling Workspace Bootstrap**: `scripts/workspace/clone-all.bat` clones or pulls all 7 repositories side-by-side in the parent workspace directory so relative build contexts (`../../../../brandhub-*` in `docker/compose/shared/apps.yaml`) resolve identically on every developer machine.
- **Scoped OIDC CI/CD (`prod/terraform/01-iam/github-actions-role.tf`)**: AWS IAM role `brandhub-github-actions` trusts `repo:BrandHubOrganization/brandhub-*:ref:refs/heads/{main,develop}`. Each service repository builds its own immutable ECR image (`brandhub/<service>:sha-<commit>`) and rolls out only its target EC2 container over AWS SSM (`AWS-RunShellScript`).
- **Centralized Schema & Contract Governance**: All DDL changes (`database/init/init-postgres-v2.sql`, `database/init/init-mongo.js`, `database/migrations/`), REST envelopes ([API Response Format](../api/api-response-format.md)), and RabbitMQ schemas live in `brandhub-infrastructure` before implementation PRs land in application repos.

---

## 5. Trade-offs & Operational Impact

### Positive Outcomes
- **Zero Build Contamination**: Updating `brandhub-publisher-service` builds in < 60s and deploys only to `brandhub-publisher-service` on `core` EC2 without rebuilding `brandhub-web` or re-downloading Python ML wheels.
- **Least-Privilege Secret Segregation**: Repository and host `.env` scopes remain isolated (`gateway` never sees `JWT_PRIVATE_KEY`; `ai` never sees PostgreSQL or SePay credentials).
- **Parallel Team Velocity**: Frontend, Mobile, Core Backend, and AI/Data engineers merge and deploy independently with minimal rebase churn.

### Accepted Costs & Mitigations
- **Coordinated Multi-Repo Changes**: Modifying an internal DTO (such as `PublishJobMessage` or `/api/v1/ai/*` payloads) requires sequenced PRs across producer and consumer repos, mitigated by backwards-compatible JSON fields and contract docs ([Business–AI REST Contract](../architecture/business-ai-rest-contract.md)).
- **Local Multi-Repo Sync**: Developers running full containerized integration (`docker/compose/shared/apps.yaml`) must pull sibling repos via `scripts/workspace/clone-all.bat`; day-to-day development avoids this by running only `docker/run_dev.bat` (`postgres`, `mongodb`, `redis`, `rabbitmq`) in Docker and starting target app repos on the host.

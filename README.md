# BrandHub Infrastructure & Knowledge Base Hub

Central infrastructure-as-code, polyglot database baselines & migrations, local Docker Compose stacks, AWS `ap-southeast-1` production manifests & Terraform modules, Vast.ai Wan 2.2 VACE GPU worker bundles, security/automation tooling, and the VitePress engineering knowledge base for **BrandHub**.

---

## Navigation

| Subsystem | Authoritative Entry Point | Scope |
| :--- | :--- | :--- |
| **Security & Secret Policy** | [`SECURITY.md`](SECURITY.md) | Gitleaks `8.30.1` + `check_sensitive_paths.py`, `.githooks`, RS256 key split, `AES-256-GCM` social tokens, and KMS `RepositoryEnvelopeCrypto` |
| **Operational Databases** | [`database/README.md`](database/README.md) | PostgreSQL 17 (`97` tables) & MongoDB 7.0 (`52` collections) init baselines, [`database/migrations/README.md`](database/migrations/README.md) (`25` PG + `8` Mongo + `1` Neo4j), [`database/backups/README.md`](database/backups/README.md), and SQL maintenance patches |
| **Local Docker Stacks** | [`docker/README.md`](docker/README.md) | `dev` & `dev-ai` Compose stacks, all 6 `compose/shared/*.yaml` fragments, [`docker/compose/seed-guide.md`](docker/compose/seed-guide.md), and local `mongo:7.0` vs. Atlas `mongosh` guide |
| **AWS Production (`ap-southeast-1`)** | [`prod/README.md`](prod/README.md) | 5-EC2 host configurations ([`prod/hosts/README.md`](prod/hosts/README.md), [`db-backup`](prod/hosts/core/db-backup/README.md)), Terraform stacks `01-iam`–`04-storage` ([`prod/terraform/README.md`](prod/terraform/README.md)), and `k6` load tests ([`prod/loadtest/README.md`](prod/loadtest/README.md)) |
| **GPU Workers (Vast.ai)** | [`gpu-workers/README.md`](gpu-workers/README.md) | ComfyUI + **Wan 2.2 Fun VACE 14B + Wan 2.2 S2V 14B + Qwen Image 2.1** worker bundle ([`gpu-workers/wan-vace/README.md`](gpu-workers/wan-vace/README.md)) & flow templates ([`flows/README.md`](gpu-workers/wan-vace/flows/README.md)) |
| **Operational Scripts** | [`scripts/README.md`](scripts/README.md) | Polyrepo cloning, database baseline checks, [`scripts/jira/README.md`](scripts/jira/README.md) workload export, [`scripts/repository-encryption/README.md`](scripts/repository-encryption/README.md), and sensitive-path guard |
| **Docs Site (VitePress)** | [`docs-site/README.md`](docs-site/README.md) | VitePress static documentation portal & interactive Jira workload dashboard |
| **Engineering Knowledge Base** | [`docs/index.md`](docs/index.md) | ADRs, System Architecture, 698-endpoint API Contracts, Database ERDs, 141-FR BA & SRS Feature Specs, AI Models, Wireframes, Screenshots, and Ops Runbooks |

---

## Consolidated Repository Structure

```text
brandhub-infrastructure/
├── .github/workflows/            # CI/CD: secret-scanning.yml, docs-site-deploy.yml, prod-db-backup-image.yml
├── .githooks/                    # Local pre-commit & pre-push hooks (Gitleaks + check_sensitive_paths.py)
├── database/                     # Operational database manual (database/README.md)
│   ├── init/                     # init-postgres-v2.sql (97 PG tables), init-mongo.js (52 Mongo collections), pgAdmin config
│   ├── migrations/               # Ordered migrations + database/migrations/README.md (postgres/, mongodb/, neo4j/)
│   ├── backups/                  # Restore scripts (restore-postgres.*, restore-mongodb.*); binary dumps gitignored
│   └── scripts/                  # Administrative SQL maintenance & demo-user reduction scripts
├── docker/                       # Local Docker manual & MongoDB CLI guide (docker/README.md)
│   ├── compose/                  # dev/, dev-ai/, shared/*.yaml (6 fragments), .env.example, run-compose.bat, seed-guide.md
│   ├── run_dev.bat               # Starts dev stack (PostgreSQL 17, MongoDB 7.0, Redis 7.2, RabbitMQ 3.12)
│   ├── run_dev_ai.bat            # Starts dev-ai stack (dev + ChromaDB 1.5.9)
│   └── clear_brandhub.bat        # Interactive cleanup of local BrandHub containers, volumes, and networks
├── prod/                         # AWS production infrastructure (Account 134875421878, ap-southeast-1)
│   ├── hosts/                    # 5-host manual (prod/hosts/README.md): gateway/, core/ (+ db-backup/), ai/, crawl/, edit-video/, shared/
│   ├── terraform/                # IaC stacks (prod/terraform/README.md): 01-iam -> 02-frontend -> 03-backend -> 04-storage
│   └── loadtest/                 # k6 read-API load/stress/soak suite (prod/loadtest/README.md)
├── gpu-workers/                  # External Vast.ai GPU worker architecture (gpu-workers/README.md)
│   └── wan-vace/                 # Wan 2.2 Fun VACE 14B & S2V bundle, flows/, tests/, and package_vace.py
├── scripts/                      # Automation manual (scripts/README.md): workspace/, database/, jira/, repository-encryption/, security/
├── docs-site/                    # VitePress static portal & Jira dashboard app
└── docs/                         # Master Knowledge Base (docs/index.md): adr/, architecture/, api/, database/, ba/,
                                  # feature/, ai-models/, operations/, wireframe/, screenshots/, plan/, guides/, rule/, archive/
```

---

## Quick Start (Local Infrastructure)

### 1. Prerequisites

- **Docker Desktop** (Docker Compose v2.20+ supporting `include:`)
- **Git** & **Python 3.11+** (security hooks, `brandhub-ai-service`, and `wan-vace` worker tooling)
- **Java 21** & **Node.js 20+** (`brandhub-api-gateway`, `brandhub-business-service`, `brandhub-publisher-service`, `brandhub-web`, `docs-site`)
- **Gitleaks `8.30.1`** (local secret-scanning hooks — see [`SECURITY.md`](SECURITY.md))

### 2. Enable Local Security Hooks

```bash
git config --local core.hooksPath .githooks
```

### 3. Configure & Launch Docker Compose

```powershell
cd docker
Copy-Item compose\.env.example compose\.env   # Fill local passwords, RS256 keys, AES_SECRET_KEY, SePay/AI keys
.\run_dev.bat                                 # Core infra: PostgreSQL 17, MongoDB 7.0, Redis 7.2, RabbitMQ 3.12
.\run_dev_ai.bat                              # Core infra + ChromaDB 1.5.9 (for brandhub-ai-service)
```

Optional Compose fragments under `docker/compose/shared/` (`neo4j.yaml` for Neo4j `5.26`, `pgadmin.yaml` for pgAdmin 4 v9 on `127.0.0.1:5050`, and `apps.yaml` for containerized microservices) are documented in [`docker/README.md`](docker/README.md) and [`docs/architecture/local-run-architecture.md`](docs/architecture/local-run-architecture.md).

---

## Local Service & Port Matrix

| Component | Runtime / Image | Default Host Port | Notes |
| :--- | :--- | :---: | :--- |
| **PostgreSQL** | `postgres:17-alpine` | `5432` | Auto-runs [`database/init/init-postgres-v2.sql`](database/init/init-postgres-v2.sql) (`97` tables) on empty volume |
| **MongoDB** | `mongo:7.0` | `27017` | Auto-runs [`database/init/init-mongo.js`](database/init/init-mongo.js) (`52` collections) on empty volume |
| **Redis** | `redis:7.2-alpine` | `6379` | Append-only persistence + password auth |
| **RabbitMQ** | `rabbitmq:3.12-management-alpine` | `5672` / `15672` | AMQP broker (`5672`) + Management UI (`http://localhost:15672`) |
| **ChromaDB** | `chromadb/chroma:1.5.9` | `127.0.0.1:8000` | Included in `dev-ai` (`:8001` when running containerized `apps.yaml`) |
| **Neo4j** *(optional)* | `neo4j:5.26-community` | `7474` / `7687` | Add-on via `docker/compose/shared/neo4j.yaml` |
| **pgAdmin 4** *(optional)* | `dpage/pgadmin4:9` | `127.0.0.1:5050` | Add-on via `docker/compose/shared/pgadmin.yaml` |
| **API Gateway** | Java 21 (Spring Cloud Gateway WebFlux) | `8080` | Perimeter security, RS256 JWT validation & Redis rate limiting |
| **Business Service** | Java 21 (Spring Boot 3) | `8081` | `124` controllers: core domain, **SePay (VietQR)** billing, workflow, vault & moderation |
| **AI Service** | Python 3.11+ (FastAPI) | `8082` | `18` routers: PhoBERT/Burst/Neo4j trends, Brand GraphRAG, Caption/Image/Ambassador & VACE Director |
| **Publisher Service** | Java 21 (Spring Boot 3) | `8083` | RabbitMQ async publishing across **Facebook, Instagram, TikTok, Threads** |
| **Crawl Service** | Python (Playwright / Camoufox) | `8084` | Multi-platform social trend crawler |
| **Edit-Video Worker** | Python / FFmpeg (`brandhub-edit-video`) | `8095` | Server-side Video Studio timeline rendering |
| **Web Dashboard** | React `19.2` / Vite `8.3` (`brandhub-web`) | `5173` | Served via S3 + CloudFront (`brandhub.id.vn`) in production |
| **Mobile Companion** | Expo SDK `58` / RN `0.88` (`brandhub-mobile-app`) | `8090` | iOS & Android companion app |

---

## Database Schema & Governance Baseline

Operational assets reside in [`database/`](database/README.md); entity/ERD specifications reside in [`docs/database/README.md`](docs/database/README.md):

- **PostgreSQL 17 ([`database/init/init-postgres-v2.sql`](database/init/init-postgres-v2.sql))**: **97 unique tables** and **6 seeded plans** (`STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO` + `BASIC`, `PLUS`, `ENTERPRISE`) settled exclusively via **SePay (VietQR)** (upgrade-only).
- **MongoDB 7.0 ([`database/init/init-mongo.js`](database/init/init-mongo.js))**: **52 collections** with `$jsonSchema` validators and compound/TTL/partial unique indexes across **Facebook, Instagram, TikTok, and Threads**.
- **Seed & Snapshot Restore**: Synthetic seeding (`SEED_ENABLED=true`) and local dump restoration (`restore-postgres.*` / `restore-mongodb.*`) are documented in [`docker/compose/seed-guide.md`](docker/compose/seed-guide.md) and [`database/backups/README.md`](database/backups/README.md).
- **Ordered Incremental Migrations**: All **25 PostgreSQL**, **8 MongoDB**, and **1 Neo4j** migrations—including same-day dependency orderings—are cataloged in [`database/migrations/README.md`](database/migrations/README.md).

---

## CI/CD Workflows (`.github/workflows/`)

| Workflow | File | Trigger | Description |
| :--- | :--- | :--- | :--- |
| **Secret Scanning** | [`.github/workflows/secret-scanning.yml`](.github/workflows/secret-scanning.yml) | Push & PR to `main`, `develop` | Executes `check_sensitive_paths.py` and Gitleaks `8.30.1` across tracked files and PR commit ranges |
| **Deploy Docs Site** | [`.github/workflows/docs-site-deploy.yml`](.github/workflows/docs-site-deploy.yml) | Push affecting `docs/**` or `docs-site/**` | Builds `docs-site` with VitePress (`npm ci && npm run build`) and deploys to `gh-pages` |
| **DB Backup Image** | [`.github/workflows/prod-db-backup-image.yml`](.github/workflows/prod-db-backup-image.yml) | Push affecting `prod/hosts/core/db-backup/**` | Runs `pytest` suite and builds/pushes `brandhub/db-backup` to AWS ECR |

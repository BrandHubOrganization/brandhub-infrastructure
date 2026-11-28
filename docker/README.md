# Local Docker Environments & Compose Architecture (`docker/`)

Authoritative operational guide for BrandHub's modular Docker Compose v2.20+ stacks, shared infrastructure fragments, lifecycle scripts, destructive cleanup utilities, and containerized MongoDB CLI workflows.

- Back to [Infrastructure Hub](../README.md)
- Operational database schemas, migrations & backups: [`../database/README.md`](../database/README.md) · [`../database/migrations/README.md`](../database/migrations/README.md)
- Database seeding (`DataSeeder`) & snapshot restoration: [`compose/seed-guide.md`](compose/seed-guide.md)
- Local service dependency & port topology: [`../docs/architecture/local-run-architecture.md`](../docs/architecture/local-run-architecture.md)
- AWS `ap-southeast-1` production deployment: [`../prod/README.md`](../prod/README.md)

---

## 1. Directory Layout

```text
docker/
├── README.md                           # Complete Docker & Compose manual (this file)
├── run_dev.bat                         # CLI & run-brandhub GUI launcher -> compose/run-compose.bat dev
├── run_dev_ai.bat                      # CLI & run-brandhub GUI launcher -> compose/run-compose.bat dev-ai
├── clear_brandhub.bat                  # Scoped teardown of BrandHub containers, volumes, networks & image tags
└── compose/
    ├── .env.example                    # Tracked 121-line environment template copied to .env on first run
    ├── run-compose.bat                 # Shared Compose validator & runner (dev | dev-ai × up | down | config)
    ├── seed-guide.md                   # DataSeeder (SEED_ENABLED=true) & local .dump/.ejson restore guide
    ├── dev/
    │   └── compose.yaml                # Core stack: includes shared/databases.yaml + shared/cache-broker.yaml
    ├── dev-ai/
    │   └── compose.yaml                # AI stack: includes ../dev/compose.yaml + shared/chroma.yaml
    └── shared/
        ├── databases.yaml              # PostgreSQL 17 (:5432) + MongoDB 7.0 (:27017) + init bind-mounts
        ├── cache-broker.yaml           # Redis 7.2 (:6379, AOF) + RabbitMQ 3.12 Management (:5672 / :15672)
        ├── chroma.yaml                 # ChromaDB 1.5.9 (127.0.0.1:8000) for Brand RAG & Trend vectors
        ├── neo4j.yaml                  # Optional add-on: Neo4j 5.26 Community (:7474 HTTP / :7687 Bolt)
        ├── pgadmin.yaml                # Optional add-on: pgAdmin 4 v9 (127.0.0.1:5050)
        └── apps.yaml                   # Optional add-on: containerized gateway, business, ai, crawl, publisher
```

> **AWS Production Note**: Self-hosted production Compose manifests live under [`../prod/hosts/`](../prod/hosts/README.md) (5 dedicated `ap-southeast-1` EC2 hosts), not under `docker/compose/`. Invoking `compose/run-compose.bat production` intentionally exits with status `1` and points operators to [`../prod/README.md`](../prod/README.md).

---

## 2. Entrypoint Modes (`dev` vs `dev-ai`)

Both `.bat` launchers in `docker/` set the Compose project name to `-p brandhub`, share the bridge network `brandhub-network`, and are invoked directly by developers and by the sibling `run-brandhub` desktop controller:

| Mode | Launcher | Compose Entrypoint | Included Fragments & Active Containers |
| :--- | :--- | :--- | :--- |
| **`dev`** | `.\run_dev.bat` | [`compose/dev/compose.yaml`](compose/dev/compose.yaml) | `shared/databases.yaml` (`brandhub-postgres`, `brandhub-mongodb`) + `shared/cache-broker.yaml` (`brandhub-redis`, `brandhub-rabbitmq`) — everything needed by `brandhub-api-gateway`, `brandhub-business-service`, and `brandhub-publisher-service` |
| **`dev-ai`** | `.\run_dev_ai.bat` | [`compose/dev-ai/compose.yaml`](compose/dev-ai/compose.yaml) | Inherits `dev/compose.yaml` + `shared/chroma.yaml` (`brandhub-chromadb`) — required by `brandhub-ai-service` (also called by `brandhub-ai-service/scripts/start-shared-ai-deps.bat`) |

---

## 3. Shared Compose Fragments Reference (`compose/shared/*.yaml`)

All 6 reusable fragments attach to `brandhub-network` (`bridge`) and fail fast (`:?is required`) if mandatory variables in `compose/.env` are blank:

| Fragment | Container Name(s) | Pinned Image / Build Context | Host Port Binding | Named Volumes & Key Runtime Config |
| :--- | :--- | :--- | :--- | :--- |
| [`compose/shared/databases.yaml`](compose/shared/databases.yaml) | `brandhub-postgres`<br>`brandhub-mongodb` | `postgres:17-alpine`<br>`mongo:7.0` | `${POSTGRES_HOST_PORT}` (`5432`)<br>`${MONGODB_HOST_PORT}` (`27017`) | Volumes: `brandhub-postgres-v2-data`, `brandhub-mongodb-data`. Read-only bind mounts to `database/init/init-postgres-v2.sql` and `database/init/init-mongo.js` (`create_host_path: false`). Healthchecks via `pg_isready` and `mongosh db.adminCommand('ping')` (10s interval). |
| [`compose/shared/cache-broker.yaml`](compose/shared/cache-broker.yaml) | `brandhub-redis`<br>`brandhub-rabbitmq` | `redis:7.2-alpine`<br>`rabbitmq:3.12-management-alpine` | `${REDIS_HOST_PORT}` (`6379`)<br>`${RABBITMQ_AMQP_HOST_PORT}` (`5672`), `${RABBITMQ_MANAGEMENT_HOST_PORT}` (`15672`) | Volumes: `brandhub-redis-data`, `brandhub-rabbitmq-data`. Redis runs `--requirepass`, `--appendonly yes`, `--maxmemory ${REDIS_MAXMEMORY}` (`256mb`), `--maxmemory-policy ${REDIS_MAXMEMORY_POLICY}` (`allkeys-lru`). |
| [`compose/shared/chroma.yaml`](compose/shared/chroma.yaml) | `brandhub-chromadb` | `chromadb/chroma:1.5.9` | `127.0.0.1:${CHROMADB_HOST_PORT}` (`8000`) | Volume: `brandhub-chroma-data`. Pinned to `1.5.9` to match `chromadb-client==1.5.9` in `brandhub-ai-service`. `ANONYMIZED_TELEMETRY=FALSE`; bash `/dev/tcp` healthcheck on `/api/v2/heartbeat`. |
| [`compose/shared/neo4j.yaml`](compose/shared/neo4j.yaml) | `brandhub-neo4j` | `neo4j:5.26-community` | `${NEO4J_HOST_PORT_HTTP}` (`7474`), `${NEO4J_HOST_PORT_BOLT}` (`7687`) | Volumes: `brandhub-neo4j-data`, `brandhub-neo4j-logs`. Used for local GraphRAG & Trend Virality graph development (`NEO4J_AUTH=neo4j/<password>`). |
| [`compose/shared/pgadmin.yaml`](compose/shared/pgadmin.yaml) | `brandhub-pgadmin` | `dpage/pgadmin4:9` | `127.0.0.1:${PGADMIN_HOST_PORT}` (`5050` → `:80`) | Volume: `brandhub-pgadmin-data`. Server mode + master password enabled; pair with [`../database/init/pgadmin-servers.json`](../database/init/pgadmin-servers.json). |
| [`compose/shared/apps.yaml`](compose/shared/apps.yaml) | `brandhub-api-gateway`<br>`brandhub-business-service`<br>`brandhub-ai-service`<br>`brandhub-publisher-service`<br>`crawl-service` | Builds sibling repos:<br>`../../../../brandhub-*` | Gateway: `${API_GATEWAY_HOST_PORT}` (`8080`)<br>Internal (`127.0.0.1`): `8081` (business), `8082` (ai), `8083` (publisher); `8084` (crawl, internal only) | Volume: `crawl-data:/app/data` (`shm_size: 256mb`, `init: true` for headless Chromium). Injects RS256 keys, `AES_SECRET_KEY`, `INTERNAL_SERVICE_KEY`, 4 social OAuth redirect URIs (Facebook, Instagram, TikTok, Threads), S3, SMTP, and Gateway rate limits. |

---

## 4. Lifecycle Runner (`compose/run-compose.bat`) & Environment Setup

### Step 1: Initialize `compose/.env`

`run-compose.bat` always resolves `docker/compose/.env` relative to `%~dp0` regardless of your current working directory. On first run, if `compose/.env` is missing, `run-compose.bat` automatically copies [`compose/.env.example`](compose/.env.example) to `compose/.env` and exits with status `1` so you can populate required secrets:

- **Database & Broker Credentials**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `RABBITMQ_USERNAME`, `RABBITMQ_PASSWORD`
- **Cryptographic Keys**: `JWT_PRIVATE_KEY` & `JWT_PUBLIC_KEY` (RS256 keypair), `AES_SECRET_KEY` (`AES-256-GCM`), `INTERNAL_SERVICE_KEY`
- **External Integrations** *(needed when layering `apps.yaml`)*: AI provider keys (`GROQ_API_KEY`, `GEMINI_API_KEY`), Meta/TikTok/Threads/Google OAuth credentials, SePay (`SEPAY_*`), AWS S3 (`brandhub-media` in `ap-southeast-1`), and SMTP settings

### Step 2: Validate, Start, or Stop Containers

```powershell
cd docker

# Validate merged Compose YAML & required .env interpolations without starting containers
.\run_dev.bat config
.\run_dev_ai.bat config

# Start in detached mode (--remove-orphans) and print container health table
.\run_dev.bat up
.\run_dev_ai.bat up

# Stop and remove containers while preserving named database volumes
.\run_dev.bat down
```

### Step 3: Layering Optional Fragments (`neo4j`, `pgadmin`, `apps`)

To run optional services alongside `dev` or `dev-ai`, invoke `docker compose` from `docker/`:

```powershell
docker compose -p brandhub --env-file compose/.env `
  -f compose/dev-ai/compose.yaml `
  -f compose/shared/neo4j.yaml `
  -f compose/shared/pgadmin.yaml up -d
```

---

## 5. Scoped Full Reset (`clear_brandhub.bat`)

When switching branches after incompatible volume experiments or clearing stale container names, [`clear_brandhub.bat`](clear_brandhub.bat) embeds a PowerShell inspector that enumerates **only** Docker resources owned by BrandHub (`^brandhub($|[-_])` by name or `com.docker.compose.project` label — containers, networks, named volumes, BrandHub image tags, and dangling BrandHub app builds) without touching unrelated local Docker projects or upstream base images:

```powershell
cd docker

# Preview every container, volume, network, and image tag that would be removed
.\clear_brandhub.bat -DryRun

# Interactive destructive reset (prompts you to type DELETE in uppercase)
.\clear_brandhub.bat
```

---

## 6. MongoDB Local Container vs Remote MongoDB Atlas (`mongosh` via Docker)

- **Default Local Mode**: `compose/.env.example` sets `MONGODB_URI=mongodb://localhost:27017/brandhub` (for host-run services) and `MONGODB_DOCKER_URI=mongodb://mongodb:27017/brandhub` (for containerized `business-service`).
- **Switching to MongoDB Atlas**: Set `MONGODB_URI` to your `mongodb+srv://...` Atlas URI and leave `MONGODB_DOCKER_URI` empty.

### Ephemeral Dockerized `mongosh` for Remote MongoDB Atlas

To inspect a remote Atlas cluster or apply scripts without installing `mongosh` on your workstation, run `mongo:7.0` from the **`brandhub-infrastructure` repository root**:

```powershell
# PowerShell — mount migrations read-only for existing Atlas clusters
docker run --rm -it `
  --mount "type=bind,source=${PWD}\database\migrations\mongodb,target=/migrations,readonly" `
  mongo:7.0 mongosh `
  "mongodb+srv://<cluster>.mongodb.net/?appName=brandhub" `
  --username <db_username> `
  --authenticationDatabase admin
```

```bash
# Bash — mount init/ ONLY when bootstrapping a brand-new empty Atlas cluster
docker run --rm -it \
  --mount "type=bind,source=$(pwd)/database/init,target=/scripts,readonly" \
  mongo:7.0 mongosh \
  "mongodb+srv://<cluster>.mongodb.net/?appName=brandhub" \
  --username <db_username> \
  --authenticationDatabase admin
```

Inside `mongosh`:
- **Existing cluster**: inspect collections with `db.getSiblingDB("brandhub").getCollectionNames();` and apply incremental scripts from `/migrations/<script>` (see [`../database/migrations/README.md`](../database/migrations/README.md)).
- **Brand-new empty cluster only**: run `load("/scripts/init-mongo.js");` once to create all 52 collections, `$jsonSchema` validators, and indexes.

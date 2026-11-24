# Local Run Architecture (`docker/compose/` + Host Services)

> Navigation: [← Knowledge Base Hub](../index.md) · [← Architecture Index](./README.md) · [Technical Overview](./technical-overview.md) · [Production Deployment](../operations/deployment-acct134.md)

Describes how BrandHub's local Docker Compose v2 infrastructure stacks (`docker/`) integrate with host-run microservices, web SPA, and Expo mobile clients during daily development and full-stack integration testing.

---

## 1. Modular Docker Compose `include:` Graph

Located in `brandhub-infrastructure/docker/`, the local stack uses Docker Compose v2.20+ `include:` composition across two primary launchers (`docker/run_dev.bat` and `docker/run_dev_ai.bat`, also driven by the `run-brandhub` desktop GUI) and **6 reusable fragments** in `docker/compose/shared/`:

```text
docker/
├── run_dev.bat ─────────► compose/run-compose.bat dev    ──► compose/dev/compose.yaml
│                                                               ├── shared/databases.yaml
│                                                               └── shared/cache-broker.yaml
├── run_dev_ai.bat ──────► compose/run-compose.bat dev-ai ──► compose/dev-ai/compose.yaml
│                                                               ├── ../dev/compose.yaml
│                                                               └── shared/chroma.yaml
├── clear_brandhub.bat   (Label-scoped teardown of brandhub* containers, volumes, networks & images)
└── compose/
    ├── .env.example     (121-line tracked template copied to gitignored compose/.env on first run)
    ├── seed-guide.md    (DataSeeder SEED_ENABLED=true & database/backups/restore-* workflow)
    └── shared/
        ├── databases.yaml      # postgres:17-alpine (:5432) + mongo:7.0 (:27017) + init bind-mounts
        ├── cache-broker.yaml   # redis:7.2-alpine (:6379, 256mb AOF) + rabbitmq:3.12-management-alpine (:5672/:15672)
        ├── chroma.yaml         # chromadb/chroma:1.5.9 (127.0.0.1:8000, pinned with brandhub-ai-service)
        ├── neo4j.yaml          # Optional (-f): neo4j:5.26-community (:7474 HTTP / :7687 Bolt)
        ├── pgadmin.yaml        # Optional (-f): dpage/pgadmin4:9 (127.0.0.1:5050)
        └── apps.yaml           # Optional (-f): builds gateway, business, ai, publisher, crawl from sibling repos
```

### Why Infrastructure and App Containers Are Split

During active coding, engineers run `.\run_dev.bat up` (or `.\run_dev_ai.bat up` when working on AI/RAG) so stateful data stores run reliably in Docker while Java (`./mvnw spring-boot:run`), Python (`uvicorn app.main:app --reload --port 8082`), and React (`npm run dev`) run directly on the host with sub-second hot reload. Layering `-f compose/shared/apps.yaml` builds all 5 backend containers onto `brandhub-network` for staging-parity verification.

---

## 2. Container Port, Volume & Bootstrap Matrix

All containers join the fixed bridge network **`brandhub-network`**:

| Container | Pinned Image | Host Port(s) | Named Docker Volume | First-Boot / Runtime Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `brandhub-postgres` | `postgres:17-alpine` | `5432` | `brandhub-postgres-v2-data` | Mounts `database/init/init-postgres-v2.sql` read-only (`97` tables + `6` Studio/Agency SePay plans) when volume is empty |
| `brandhub-mongodb` | `mongo:7.0` | `27017` | `brandhub-mongodb-data` | Mounts `database/init/init-mongo.js` read-only (`52` collections + `$jsonSchema` validators + indexes) when volume is empty |
| `brandhub-redis` | `redis:7.2-alpine` | `6379` | `brandhub-redis-data` | Runs `--requirepass`, `--appendonly yes`, `--maxmemory 256mb`, `--maxmemory-policy allkeys-lru` |
| `brandhub-rabbitmq` | `rabbitmq:3.12-management-alpine` | `5672`, `15672` | `brandhub-rabbitmq-data` | AMQP broker (`:5672`) + Management UI (`http://localhost:15672`) |
| `brandhub-chromadb` | `chromadb/chroma:1.5.9` | `127.0.0.1:8000` | `brandhub-chroma-data` | Telemetry disabled; `/api/v2/heartbeat` TCP healthcheck |
| `brandhub-neo4j` *(opt)* | `neo4j:5.26-community` | `7474`, `7687` | `brandhub-neo4j-data` | Local Trend Knowledge Graph (`database/migrations/neo4j/` indexes) |
| `brandhub-pgadmin` *(opt)* | `dpage/pgadmin4:9` | `127.0.0.1:5050` | `brandhub-pgadmin-data` | Import `database/init/pgadmin-servers.json` to connect to `postgres:5432` |

> **Existing Volume Catch-Up**: Docker `/docker-entrypoint-initdb.d/*` scripts run **only** on empty volumes. On an older local volume, apply ordered scripts from `database/migrations/` (or `database/scripts/patch-update-running-db.sql`), or run `docker\clear_brandhub.bat` for a clean slate (see [Team Workflow Guide](../guides/team-workflow-guide.md)).

---

## 3. Host Application Port & Dependency Topology

```text
brandhub-web (Vite 8 :3000)  &  brandhub-mobile-app (Expo 58 Metro :8090)
        │
        │ HTTP /api/v1/**  +  WebSocket STOMP /ws/chat & /ws/tasks
        ▼
brandhub-api-gateway (:8080) ──► Redis (:6379, JWT blacklist + rate limit)
        │
        ├──► brandhub-business-service (:8081)
        │       ├──► PostgreSQL (:5432) + MongoDB (:27017) + Redis (:6379)
        │       ├──► RabbitMQ (:5672, publisher.job.exchange) ──► brandhub-publisher-service (:8083)
        │       └──► brandhub-ai-service (:8082, X-Internal-Key)
        │               ├──► ChromaDB (:8000) + Neo4j (:7687) + Redis (:6379)
        │               └──► brandhub-crawl (:8084) / Vast.ai GPU Worker (:10200)
        │
        └──► brandhub-publisher-service (:8083, GET /api/v1/social/{fb,ig,tiktok,threads}/{authorize,callback})
```

### Mobile Client Networking (`brandhub-mobile-app`)

- **Metro Bundler Port (`8090`)**: Moved off Expo's default `8081` so it never collides with `brandhub-business-service` (`:8081`).
- **Gateway Endpoint (`EXPO_PUBLIC_API_BASE_URL`)**:
  - **Android Emulator (AVD)**: `http://10.0.2.2:8080`
  - **iOS Simulator**: `http://localhost:8080`
  - **Physical Device (Expo Go / Dev Client)**: `http://<host-lan-ipv4>:8080` (ensure Windows Firewall allows inbound TCP `8080` and `8090` on Private networks).

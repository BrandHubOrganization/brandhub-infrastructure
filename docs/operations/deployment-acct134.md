# Deployment Runbook — AWS Account `134875421878` (5-EC2 + S3 KMS + Vast.ai GPU)

> Navigation: [← Knowledge Base Hub](../index.md) · [← Operations Hub](./README.md) · [Wake-on-Request Architecture](./wake-on-request.md)

Authoritative production deployment state and operational log for BrandHub in **AWS `ap-southeast-1` (Singapore)** under Account `134875421878`. Infrastructure-as-code and host manifests live at `prod/terraform/` (`01-iam` → `04-storage`) and `prod/hosts/` (`prod/hosts/README.md`).

---

## 1. Five-Host EC2 Compute Inventory

| Host Role | Instance ID | Private IP | Compose Manifests (`prod/hosts/`) | Running Containers & Services |
| :--- | :--- | :--- | :--- | :--- |
| **`gateway`** | `i-05f5bfca4452b0f83` | `172.31.27.199` | `prod/hosts/gateway/gateway.compose.json`, `gateway-wake.compose.yaml` (`~/brandhub/ecr`) | **Nginx** (`80/443`, Let's Encrypt TLS for `api.brandhub.id.vn` via `brandhub-certificate-renew.timer`), **`brandhub-api-gateway`** (`:8080`), **`brandhub-waker`** (`:8099` for `edit-video`) |
| **`core`** | `i-01cba58d9f08be748` | `172.31.24.149` | `prod/hosts/core/core.compose.json`, `core-wake.compose.yaml` (`~/brandhub/ecr`) | **`brandhub-business-service`** (`:8081`), **`brandhub-publisher-service`** (`:8083`), **PostgreSQL 17** (`:5432`), **Redis 7** (`:6379`), **RabbitMQ 3.13** (`:5672`), **ChromaDB** (`:8000`), **`db-backup`** (`:8090`, 00:00 ICT S3 dumps), **`crawl-gate`** (`172.31.24.149:8084`) + **`brandhub-waker`** |
| **`ai`** | `i-0f7857edf71b6bb3f` | `172.31.20.60` | `prod/hosts/ai/ai.compose.json` (`~/brandhub/ecr`) | **`brandhub-ai-service`** (`:8082`, `c7i-flex.large`, `3 GiB` memory limit; connects to `core` Redis/RabbitMQ/Chroma via `extra_hosts` and `brandhub-ai-sg`) |
| **`crawl`** | `i-0288d396a5d5b9b06` | `172.31.20.50` | `prod/hosts/crawl/crawl.compose.yaml` (`~/brandhub/crawl`) | **`crawl-service`** (`:8084`, Playwright/Camoufox; auto-sleeps when idle via `brandhub-idle-sleep.timer`) |
| **`edit-video`** | `i-0ec7bf59c53fb7d0b` | `172.31.20.80` | `prod/hosts/edit-video/edit-video.compose.yaml` (`~/brandhub/edit-video`) | **`brandhub-edit-video`** (`:8095`, FFmpeg server timeline renderer; auto-sleeps when idle, wakes on HTTP request) |

---

## 2. Image Pinning, Secret Delivery & IAM Credentials

- **Immutable ECR Digests/Tags**: Image tags (`BUSINESS_IMAGE`, `PUBLISHER_IMAGE`, `AI_IMAGE`, `GATEWAY_IMAGE`, `CRAWLER_IMAGE`, `DB_BACKUP_IMAGE`) sit in each host directory's `.env` alongside the Compose manifest (`sha-<commit>-acct134`), allowing deterministic `docker compose -f <file> up -d` rollouts and instant rollbacks.
- **Instance Role Authentication (`01-iam`)**: All static AWS IAM access keys were stripped from EC2 `env/*.env` (`chmod 0600`). `brandhub-business-service` (`DefaultCredentialsProvider`), `brandhub-ai-service` (`boto3`), and `db-backup` authenticate exclusively through the `brandhub-ec2-ecr-pull` EC2 Instance Profile over IMDSv2. Environment files are staged via short-lived encrypted S3 objects deleted immediately after pull—never passed in plaintext SSM command arguments.
- **TLS Automation**: `api.brandhub.id.vn` certificates are renewed automatically on `gateway` via `prod/hosts/gateway/certbot/brandhub-certificate-renew.{service,timer}` (`nginx -s reload` post-hook).

---

## 3. Storage, KMS Repository Vault & Database State (`02-frontend` & `04-storage`)

- **Unified Media, Repository & Client Vault Bucket (`brandhub-media-134875421878`)**:
  - `brandhub-business-service` stores `repository/` and `repository-staging/` objects encrypted with SSE-KMS (`alias/brandhub-repository-media-prod`) plus application-layer envelope encryption (`RepositoryEnvelopeCrypto`, `REPOSITORY_STORAGE_SYSTEMS3_BUCKET`, `REPOSITORY_SYSTEM_S3_KMS_KEY_ID`). Bucket policy enforces strict least privilege so console admin users cannot read raw tenant vault objects directly.
  - Public `image/*` deliverables (avatars, workspace/agency/client logos, banners) and `ai/*` outputs are served from the same consolidated `brandhub-media-134875421878` bucket (`AWS_S3_BUCKET=brandhub-media-134875421878`, `AWS_S3_LOCAL_FALLBACK_ENABLED=false`).
- **Frontend Edge (`brandhub-web-prd-134875421878` + CloudFront)**: Serves the `brandhub-web` Vite SPA (`VITE_API_BASE_URL=https://api.brandhub.id.vn`) behind CloudFront Function `prod/terraform/02-frontend/functions/brandhub-public-routes.js`.
- **PostgreSQL & Nightly Backups (`brandhub-db-backup-prd-134875421878`)**:
  - `core.compose.json` runs against the restored production volume and applies incremental SQL migrations from `database/migrations/postgres/` (`97` tables in current baseline).
  - Nightly `00:00` ICT backups (`pg_dump -Fc` + `mongodump --archive --gzip`) are uploaded to `s3://brandhub-db-backup-prd-134875421878/` by the FastAPI `db-backup` container (`prod/hosts/core/db-backup/README.md`).

---

## 4. Dedicated AI Host & External Vast.ai GPU Worker

1. **AI Host Isolation (`brandhub-ai` — `172.31.20.60`)**:
   - Separated from `core` onto a dedicated `c7i-flex.large` (`40 GiB` `gp3`, Security Group `brandhub-ai-sg`).
   - `business-service` and `crawl` route to `AI_SERVICE_URL=http://172.31.20.60:8082`; `ai-service` routes crawl triggers through `CRAWLER_API_URL=http://172.31.24.149:8084` (`crawl-gate` on `core`).
   - Enrolled in infrastructure health monitoring (`FR 3.10.3`) as `brandhub-ai`.
2. **Vast.ai GPU Synthesis Worker (`gpu-workers/wan-vace/`)**:
   - Runs ComfyUI + **Qwen Image 2.1** (commercial ad image & 4-angle product turnarounds) + **Wan 2.2 Fun VACE 14B** (`FLF2V` & seam-chained product videos) + **Wan 2.2 S2V 14B** (lip-synced UGC) + local **Ollama `qwen2.5vl:7b`** (`VLM_URL=http://127.0.0.1:11434`, models cached under `/workspace/ollama-models`) for visual pose/product description.
   - Uploads rendered assets directly to S3 using scoped IAM user `brandhub-worker-s3-uploader`.

---

## 5. Production Health Verification Checklist

- `GET https://api.brandhub.id.vn/actuator/health` → `200 UP` (`HTTP :80` → `308` HTTPS redirect; CORS allows `https://brandhub.id.vn`; unauthenticated protected routes return `401`).
- `core`: all core containers (`business`, `publisher`, `postgres`, `redis`, `rabbitmq`, `chromadb`, `db-backup`, `crawl-gate`, `waker`) report `healthy`.
- `ai`: reports Redis, RabbitMQ, ChromaDB heartbeat, and S3 connected; reaches `crawl-gate:8084` (`200` when awake, `503 STARTING` + auto-boot when `crawl` is stopped).
- `gateway` → `/edit-video/health`: returns `503 {"status":"STARTING"}` + `Retry-After: 60` when `edit-video` is stopped and transitions EC2 instance `i-0ec7bf59c53fb7d0b` to `running`.

---

## 6. Operational Caveats & Maintenance Notes

- **Crawler Ephemeral Auth Sessions**: By security design, authenticated Facebook/Threads browser cookies on `crawl` reside in RAM only and must be re-uploaded via the crawler management API after a cold EC2 boot; proxy and TikTok configurations persist on encrypted disk when `CRAWLER_SECRET_KEY_FILE` is mounted.
- **Historical Pre-Cutover Logs**: For earlier `2026-10-29` and `2026-11-03` migration and RAM profiling logs, see [2026-10-29 ECR Deploy](./history/2026-10-29-ecr-deploy.md), [2026-11-03 Rebalance AI](./history/2026-11-03-rebalance-ai.md), and [2026-11-03 Crawl RAM Check](./history/2026-11-03-crawl-ram-check.md).

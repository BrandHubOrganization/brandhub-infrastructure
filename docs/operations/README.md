# Production Operations & AWS Infrastructure Runbooks (`docs/operations/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [System Architecture](../architecture/README.md) · [Database Architecture](../database/README.md)

Authoritative operational runbooks for BrandHub's **AWS `ap-southeast-1` (Singapore) Production Environment** (Account `134875421878`) and **Vast.ai GPU Synthesis Workers**. Executable Terraform stacks (`01-iam` → `04-storage`), per-host Docker Compose manifests, Nginx reverse-proxy rules, and systemd units reside at the repository root under `prod/` (`prod/README.md`, `prod/hosts/README.md`, `prod/terraform/README.md`) and `gpu-workers/` (`gpu-workers/README.md`).

---

## 1. Live Production Topology (`ap-southeast-1`, Account `134875421878`)

### 1.1 Five-Host EC2 Compute Fleet & CloudFront Edge

| Host Role | EC2 Instance ID | Private IP | Instance Type | Key Containers & Systemd Units (`prod/hosts/`) |
| :--- | :--- | :--- | :--- | :--- |
| **`gateway`** | `i-05f5bfca4452b0f83` | `172.31.27.199` | `t3.small` | Host/container **Nginx** (`80/443`, Let's Encrypt TLS for `api.brandhub.id.vn` via `brandhub-certificate-renew.timer`), **`brandhub-api-gateway`** (`:8080`), **`edit-video` waker** (`:8099`) |
| **`core`** | `i-01cba58d9f08be748` | `172.31.24.149` | `m7i-flex.large` | **`brandhub-business-service`** (`:8081`), **`brandhub-publisher-service`** (`:8083`), **PostgreSQL 17**, **Redis 7**, **RabbitMQ 3.13**, **ChromaDB**, **`db-backup`** (`:8090`, 00:00 ICT S3 dumps), **`crawl-gate`** (`:8084`) + **`crawl` waker** |
| **`ai`** | `i-0f7857edf71b6bb3f` | `172.31.20.60` | `c7i-flex.large` | Dedicated **`brandhub-ai-service`** (`:8082`, `3 GiB` container limit) connected to `core` stores via VPC security-group rules (`brandhub-ai-sg`) and MongoDB Atlas |
| **`crawl`** | `i-0288d396a5d5b9b06` | `172.31.20.50` | `c7i-flex.large` | **`crawl-service`** (`:8084`, Playwright/Camoufox). Auto-sleeps via `brandhub-idle-sleep.timer`; wakes on demand via `crawl-gate` or EventBridge `07:00`/`19:00` ICT schedule (`crawl-kick.sh`) |
| **`edit-video`** | `i-0ec7bf59c53fb7d0b` | `172.31.20.80` | `m7i-flex.large` | **`brandhub-edit-video`** (`:8095`, FFmpeg server timeline renderer). Auto-sleeps after 30 idle minutes; wakes on HTTP request via `gateway` Nginx `502/504 -> 503 STARTING` |

### 1.2 Storage, CDN, IAM & GPU Inference Tiers
- **Frontend Edge (`02-frontend`)**: S3 bucket `brandhub-web-prd-134875421878` fronted by CloudFront (`brandhub.id.vn`) with CloudFront Function `brandhub-public-routes.js` rewriting SPA routes while preserving public `/s/:token` share links.
- **Media & KMS Vault Storage (`04-storage`)**:
  - `brandhub-media-134875421878` — private repository & Client Vault bucket encrypted with KMS key `alias/brandhub-repository-media-prod` + `RepositoryEnvelopeCrypto`.
  - `brandhubmedia-134875421878` — rendered public social/image delivery bucket.
  - `brandhub-db-backup-prd-134875421878` — encrypted nightly PostgreSQL (`pg_dump -Fc`) and MongoDB (`mongodump --archive --gzip`) backups written by `prod/hosts/core/db-backup/`.
- **Zero Static AWS Keys on EC2 (`01-iam`)**: Services authenticate exclusively via EC2 Instance Profile `brandhub-ec2-ecr-pull` (`DefaultCredentialsProvider` in Java, `boto3` IMDSv2 role credentials in Python); only external Vast.ai GPU workers use scoped IAM user `brandhub-worker-s3-uploader`.
- **External GPU Synthesis (`gpu-workers/wan-vace/`)**: Vast.ai GPU nodes running ComfyUI + **Wan 2.2 Fun VACE 14B + Wan 2.2 S2V 14B + Qwen Image 2.1** + Ollama `qwen2.5vl:7b`.

---

## 2. Active Runbooks

| Runbook | Scope |
| :--- | :--- |
| [deployment-acct134.md](./deployment-acct134.md) | **Primary Production Runbook**: 5-EC2 inventory, ECR `sha-<commit>-acct134` image pinning, S3 KMS repository setup, PostgreSQL restore log, AI host isolation, and Vast.ai worker deployment notes |
| [wake-on-request.md](./wake-on-request.md) | **Auto-Sleep & Wake-on-Request Architecture**: Zero-dependency `waker.py` (SigV4 + IMDSv2), Nginx `error_page 502 504 = @wake` fallback (`503 {"status":"STARTING"}` + `Retry-After: 60`), EventBridge `07:00/19:00` ICT crawl schedule, and `brandhub-idle-sleep.timer` |

---

## 3. Chronological Migration & Profiling History (`history/`)

Historical deployment and capacity engineering logs leading up to the current 5-host topology:

| Date | Log Document | Engineering Summary |
| :--- | :--- | :--- |
| `2026-10-29` | [history/2026-10-29-ecr-deploy.md](./history/2026-10-29-ecr-deploy.md) | Initial immutable ECR deployment baseline, Let's Encrypt certificate renewal systemd timer, and Meta/TikTok/Threads OAuth callback verification |
| `2026-11-03` | [history/2026-11-03-rebalance-ai.md](./history/2026-11-03-rebalance-ai.md) | Zero-data-loss migration of `brandhub-ai-service` and HuggingFace/PhoBERT model cache volumes onto a dedicated compute host |
| `2026-11-03` | [history/2026-11-03-crawl-ram-check.md](./history/2026-11-03-crawl-ram-check.md) | Post-migration Linux cgroup memory profiling during authenticated Playwright Facebook & Threads crawler runs |

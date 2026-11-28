# BrandHub AWS Production Infrastructure (`prod/`)

Production Infrastructure-as-Code, per-EC2 Docker Compose manifests, wake-on-request micro-services, systemd timers, and `k6` capacity test suites for AWS Account **`134875421878`** in **`ap-southeast-1` (Singapore)**.

- Back to [Infrastructure Hub](../README.md)
- EC2 Host Manifests & Systemd Units: [`hosts/README.md`](hosts/README.md)
- Automated Nightly Backup & Restore Service: [`hosts/core/db-backup/README.md`](hosts/core/db-backup/README.md)
- Terraform Stacks (`01-iam` → `04-storage`): [`terraform/README.md`](terraform/README.md)
- API Load, Stress & Soak Testing (`k6`): [`loadtest/README.md`](loadtest/README.md)
- Production Runbooks & Incident History: [`../docs/operations/README.md`](../docs/operations/README.md) · [`../docs/operations/deployment-acct134.md`](../docs/operations/deployment-acct134.md) · [`../docs/operations/wake-on-request.md`](../docs/operations/wake-on-request.md)

---

## 1. Directory Layout

```text
prod/
├── README.md                           # Production overview & topology (this file)
├── .gitignore                          # Blocks *.tfstate, *.tfvars, per-host .env, and loadtest/users.json
├── hosts/
│   ├── README.md                       # Complete reference for all 5 EC2 hosts, Nginx, Certbot, Waker & Idle-Sleep
│   ├── gateway/                        # brandhub-api-gateway (172.31.27.199): nginx.conf, gateway.compose.json, certbot/
│   ├── core/                           # brandhub-core-services (172.31.24.149): core.compose.json, crawl-gate, db-backup/
│   │   └── db-backup/README.md         # FastAPI + APScheduler nightly S3 backup & point-in-time restore service
│   ├── ai/                             # brandhub-ai (172.31.20.60): ai.compose.json
│   ├── crawl/                          # brandhub-crawl (172.31.20.50, wakeable): crawl.compose.yaml, crawl-kick.sh
│   ├── edit-video/                     # brandhub-edit-video (172.31.20.80, wakeable): edit-video.compose.yaml
│   └── shared/                         # Reusable wake/waker.py (SigV4 IMDSv2) & idle-sleep/ systemd units
├── terraform/
│   ├── README.md                       # Multi-stack apply order & state governance
│   ├── 01-iam/README.md                # GitHub OIDC, brandhub-github-actions role, brandhub-ec2-ecr-pull profile
│   ├── 02-frontend/README.md           # Route 53 brandhub.id.vn, ACM (us-east-1), S3 + CloudFront + edge function
│   ├── 03-backend/README.md            # 5 EC2 instances, 5 Security Groups, 7 ECR repos, DB backup S3, EventBridge wake
│   └── 04-storage/README.md            # brandhub-media-134875421878, KMS CMK, crawler bucket, Vast.ai worker IAM user
└── loadtest/
    ├── README.md                       # k6 execution profiles, thresholds & bottleneck telemetry
    └── brandhub-api.k6.js              # Multi-account ramping-VU read benchmark
```

---

## 2. Production Compute Fleet (`ap-southeast-1`)

All 5 active production EC2 instances are managed in [`terraform/03-backend/`](terraform/03-backend/README.md) with `instance_initiated_shutdown_behavior = "stop"`, IMDSv2 required (`http_tokens = "required"`, `http_put_response_hop_limit = 2`), and shared instance profile `brandhub-ec2-ecr-pull`:

| Host Role | EC2 Name & Instance ID | Instance Type | Private IP | Lifecycle | Host Workdir | Primary Containers |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **API Edge** | `brandhub-api-gateway`<br>`i-05f5bfca4452b0f83` | `t3.small` (2 vCPU, 2 GiB) | `172.31.27.199` | Always-on | `~/brandhub/ecr` | `nginx` (`:80`/`:443`), `brandhub-api-gateway` (`:8080`), `brandhub-waker` (`edit-video`) |
| **Core Services & Data** | `brandhub-core-services`<br>`i-01cba58d9f08be748` | `m7i-flex.large` (2 vCPU, 8 GiB) | `172.31.24.149` | Always-on | `~/brandhub/ecr` | `business-service` (`:8081`), `publisher-service` (`:8083`), `postgres` (`17`), `redis` (`7.2`), `rabbitmq` (`3.12`), `chromadb` (`1.5.9`), `db-backup` (`:8090`), `crawl-gate` (`:8084`) + `waker` |
| **AI Inference & RAG** | `brandhub-ai`<br>`i-0f7857edf71b6bb3f` | `c7i-flex.large` (2 vCPU, 4 GiB) | `172.31.20.60` | Always-on | `~/brandhub/ecr` | `brandhub-ai-service` (`:8082`, `3g` RAM cap) |
| **Social Trend Crawler** | `brandhub-crawl`<br>`i-0288d396a5d5b9b06` | `c7i-flex.large` (2 vCPU, 4 GiB) | `172.31.20.50` | **Wakeable** (`Wakeable=true`) | `~/brandhub/crawl` | `brandhub-crawl-service` (`:8084`, `3200m` RAM cap, Playwright/Camoufox) |
| **Video Rendering** | `brandhub-edit-video`<br>`i-0ec7bf59c53fb7d0b` | `m7i-flex.large` (2 vCPU, 8 GiB) | `172.31.20.80` | **Wakeable** (`Wakeable=true`) | `~/brandhub/edit-video` | `brandhub-edit-video` (`:8095`, `6500m` RAM cap, read-only rootfs) |

> **Out-of-Band CI Instance**: `brandhub-ci-runner` (`i-017dbae8f6110e50c`, `172.31.25.47`) is a stopped self-hosted GitHub Actions runner kept outside Terraform state. Managed cloud databases (**MongoDB Atlas** for document workloads and **Neo4j Aura** for the trend graph) and on-demand **Vast.ai GPU workers** ([`../gpu-workers/README.md`](../gpu-workers/README.md)) connect over TLS.

---

## 3. Production Traffic & Security Architecture

```text
Internet Clients (Web SPA / Mobile App / SePay & OAuth Webhooks)
  ├── HTTPS brandhub.id.vn ───────► CloudFront (+ Viewer Function) ──► Private S3 (brandhub-web-prd-134875421878)
  └── HTTPS api.brandhub.id.vn ───► gateway EC2 (172.31.27.199, Nginx TLS 1.2/1.3)
                                      ├── /edit-video/* ──► edit-video EC2 (172.31.20.80:8095) [502/504 -> waker :8099]
                                      └── /* ─────────────► api-gateway (:8080, RS256 JWT + Redis Rate Limit)
                                                              ├──► core EC2 (172.31.24.149): business (:8081), publisher (:8083), redis (:6379)
                                                              └──► ai EC2 (172.31.20.60:8082)
                                                                     ├──► core EC2: redis (:6379), rabbitmq (:5672), chromadb (:8000)
                                                                     └──► core crawl-gate (:8084) ──► crawl EC2 (172.31.20.50:8084) [502/504 -> waker :8099]
```

- **Zero Public Backend Ports Except Gateway**: Only `brandhub-core-sg` (attached to `brandhub-api-gateway`) exposes TCP `80`/`443` to `0.0.0.0/0` and `::/0`. Every internal service port (`5672`, `6379`, `8000`, `8081`, `8082`, `8083`, `8084`, `8095`) binds to the host's private VPC IP and restricts ingress by Security Group ID. PostgreSQL (`5432`) and `db-backup` (`8090`) are not published on any host interface at all (reachable strictly inside `core`'s Docker bridge `brandhub-network`).
- **SSM-First Operations**: Routine administration and CI/CD rolling updates (`AWS-RunShellScript` from GitHub Actions OIDC role `brandhub-github-actions`) execute over **AWS Systems Manager (SSM)** without distributing SSH private keys.
- **Secret Storage**: Live `.env` image tags and `0600` `env/*.env` service files reside exclusively on the target EC2 instances (and `/brandhub/edit-video/*` in SSM Parameter Store) — never in Git.

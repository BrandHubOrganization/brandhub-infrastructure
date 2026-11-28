# Production EC2 Host Manifests & Wake-on-Request Units (`prod/hosts/`)

Complete operational specification for all 5 BrandHub EC2 hosts in `ap-southeast-1`, including Docker Compose manifests, container memory budgets, Nginx TLS & wake-proxy rules, Let's Encrypt renewal timers, IMDSv2 SigV4 EC2 wake micro-servers, and idle-shutdown systemd units.

- Back to [Production Hub](../README.md) · [Infrastructure Hub](../../README.md)
- Nightly S3 Backup & Point-in-Time Restore Service (`db-backup`): [`core/db-backup/README.md`](core/db-backup/README.md)
- Backend Compute & Security Groups Terraform: [`../terraform/03-backend/README.md`](../terraform/03-backend/README.md)
- Operational Runbooks: [`../../docs/operations/deployment-acct134.md`](../../docs/operations/deployment-acct134.md) · [`../../docs/operations/wake-on-request.md`](../../docs/operations/wake-on-request.md)

---

## 1. Host Directory Tree

```text
prod/hosts/
├── README.md                                           # Unified EC2 host & wake/sleep manual (this file)
├── gateway/                                            # EC2: brandhub-api-gateway (172.31.27.199, t3.small)
│   ├── gateway.compose.json                            # api-gateway (:8080, 640m) + nginx (:80/:443)
│   ├── gateway-wake.compose.yaml                       # brandhub-waker (:8099, 64m) waking edit-video
│   ├── nginx.conf                                      # TLS termination, WS upgrade, /edit-video/ -> @wake_edit_video
│   └── certbot/
│       ├── renew-certificate.sh                        # Certbot webroot renew + nginx -t + nginx -s reload
│       ├── brandhub-certificate-renew.service          # oneshot systemd unit
│       └── brandhub-certificate-renew.timer            # Twice-daily timer (03:00 & 15:00 + 1h random jitter)
├── core/                                               # EC2: brandhub-core-services (172.31.24.149, m7i-flex.large)
│   ├── core.compose.json                               # business, publisher, postgres, redis, rabbitmq, chromadb, db-backup
│   ├── core-wake.compose.yaml                          # crawl-gate (:8084, 64m) + brandhub-waker (:8099, 64m) waking crawl
│   ├── crawl-gate.nginx.conf                           # Proxies 172.31.24.149:8084 -> 172.31.20.50:8084 or @wake
│   └── db-backup/                                      # Standalone FastAPI S3 backup/restore container (see db-backup/README.md)
├── ai/                                                 # EC2: brandhub-ai (172.31.20.60, c7i-flex.large)
│   └── ai.compose.json                                 # brandhub-ai-service (:8082, 3g RAM, 1.8 CPUs)
├── crawl/                                              # EC2: brandhub-crawl (172.31.20.50, c7i-flex.large, wakeable)
│   ├── crawl.compose.yaml                              # brandhub-crawl-service (:8084, 3200m RAM, 256m shm)
│   ├── crawler-connections.compose.yaml                # Optional overlay mounting /run/secrets/crawler-master.key
│   └── crawl-kick.sh                                   # SSM script invoked by EventBridge Scheduler after pre-wake
├── edit-video/                                         # EC2: brandhub-edit-video (172.31.20.80, m7i-flex.large, wakeable)
│   └── edit-video.compose.yaml                         # brandhub-edit-video (:8095, 6500m RAM, 1.9 CPUs, read-only rootfs)
└── shared/
    ├── wake/
    │   └── waker.py                                    # Zero-dep Python 3.12 IMDSv2 SigV4 EC2 starter (:8099)
    └── idle-sleep/
        ├── idle-sleep.sh                               # Activity & job inspector issuing shutdown -h now when idle
        ├── brandhub-idle-sleep.service                 # oneshot systemd unit loading /etc/brandhub/idle-sleep.env
        └── brandhub-idle-sleep.timer                   # Runs 10m after boot and every 5m thereafter
```

---

## 2. Host 1: `gateway` (`brandhub-api-gateway` — `172.31.27.199`, `t3.small`)

- **Instance ID**: `i-05f5bfca4452b0f83` · **Host Directory**: `/home/ec2-user/brandhub/ecr` (`~/brandhub/ecr`) · **Security Group**: `brandhub-core-sg`
- **Role**: Sole internet-facing backend edge (`api.brandhub.id.vn` on TCP `80`/`443`).

### Containers & Nginx Edge Routing

| Manifest | Container | Image | Memory | Port Binding & Behavior |
| :--- | :--- | :--- | :---: | :--- |
| [`gateway/gateway.compose.json`](gateway/gateway.compose.json) | `brandhub-api-gateway` | `${GATEWAY_IMAGE}` | `640m` | Internal `:8080` on `brandhub-network` (Compose project `brandhub-backend`); loads `./env/api-gateway.env` |
| [`gateway/gateway.compose.json`](gateway/gateway.compose.json) | `nginx` | `nginx:stable-alpine` | — | Publishes `0.0.0.0:80` and `0.0.0.0:443`; mounts [`gateway/nginx.conf`](gateway/nginx.conf), `./acme-webroot`, and `./letsencrypt` read-only |
| [`gateway/gateway-wake.compose.yaml`](gateway/gateway-wake.compose.yaml) | `brandhub-waker` | `python:3.12-alpine` | `64m` | Runs `./wake/waker.py` (`WAKE_TARGETS=edit-video=${EDIT_VIDEO_INSTANCE_ID}`) on `brandhub-network` |

**Key rules in [`gateway/nginx.conf`](gateway/nginx.conf)**:
- Serves `/.well-known/acme-challenge/` from `/var/www/certbot` on HTTP `:80` and issues `308 Permanent Redirect` to HTTPS for all other paths.
- Enforces `TLSv1.2` / `TLSv1.3`, `server_tokens off`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, and `Referrer-Policy: strict-origin-when-cross-origin`.
- **`location /`**: `client_max_body_size 205m`, `proxy_read_timeout 1260s`, unbuffered HTTP/1.1 + WebSocket `Upgrade` forwarding to `http://api-gateway:8080`.
- **`location /edit-video/`**: `client_max_body_size 1024m`, `proxy_connect_timeout 3s`, `proxy_read_timeout 600s` → `http://172.31.20.80:8095/`. Intercepts `502`/`504` when `brandhub-edit-video` is stopped and rewrites internally to `@wake_edit_video` (`http://waker:8099/wake/edit-video` resolved dynamically via Docker DNS `127.0.0.11`).

### Let's Encrypt Automated Renewal (`gateway/certbot/`)

| File | Target Path on `gateway` EC2 | Schedule / Behavior |
| :--- | :--- | :--- |
| [`gateway/certbot/renew-certificate.sh`](gateway/certbot/renew-certificate.sh) | `/usr/local/sbin/brandhub-renew-certificate` (`0755`) | Runs `certbot/certbot renew --quiet`, verifies `nginx -t`, and reloads Nginx (`nginx -s reload`) |
| [`gateway/certbot/brandhub-certificate-renew.service`](gateway/certbot/brandhub-certificate-renew.service) | `/etc/systemd/system/brandhub-certificate-renew.service` | `Type=oneshot` unit after `docker.service` |
| [`gateway/certbot/brandhub-certificate-renew.timer`](gateway/certbot/brandhub-certificate-renew.timer) | `/etc/systemd/system/brandhub-certificate-renew.timer` | `OnCalendar=*-*-* 03,15:00:00` + `RandomizedDelaySec=3600` (`Persistent=true`) |

```bash
# Deploy / refresh gateway stack & certbot timer
cd ~/brandhub/ecr
cp shared-wake/waker.py ./wake/waker.py   # from prod/hosts/shared/wake/waker.py
docker compose -f gateway.compose.json up -d
docker compose -f gateway-wake.compose.yaml up -d

sudo install -m 0755 certbot/renew-certificate.sh /usr/local/sbin/brandhub-renew-certificate
sudo install -m 0644 certbot/brandhub-certificate-renew.service certbot/brandhub-certificate-renew.timer /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now brandhub-certificate-renew.timer
```

> **Legacy Filename Note**: If `/home/ec2-user/brandhub/ecr` on an older host still uses `backend.compose.json`, rename or symlink it to `gateway.compose.json` so `renew-certificate.sh` locates the Nginx service.

---

## 3. Host 2: `core` (`brandhub-core-services` — `172.31.24.149`, `m7i-flex.large`)

- **Instance ID**: `i-01cba58d9f08be748` · **Host Directory**: `~/brandhub/ecr` · **Security Group**: `brandhub-service-sg`
- **Role**: Core domain services, relational/cache/broker/vector persistence, nightly S3 backup runner, and crawler wake proxy (`~4.38 GiB` total container memory caps on an `8 GiB` host).

| Manifest | Container | Image | Memory | Bound VPC Port & Volumes |
| :--- | :--- | :--- | :---: | :--- |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-business-service` | `${BUSINESS_IMAGE}` | `1100m` | `172.31.24.149:8081`; sets `AI_SERVICE_URL=http://172.31.20.60:8082` |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-publisher-service` | `${PUBLISHER_IMAGE}` | `600m` | `172.31.24.149:8083` (4 social adapters: Facebook, Instagram, TikTok, Threads) |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-postgres` | `postgres:17-alpine` | `640m` | Internal `brandhub-network` only (`:5432` not published on host); volume `brandhub-postgres-v2-data` |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-redis` | `redis:7.2-alpine` | `384m` | `172.31.24.149:6379` (AOF + password auth); volume `brandhub-redis-data` |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-rabbitmq` | `rabbitmq:3.12-management-alpine` | `512m` | `172.31.24.149:5672` (AMQP only; `:15672` not published); volume `brandhub-rabbitmq-data` |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-chromadb` | `chromadb/chroma:1.5.9` | `512m` | `172.31.24.149:8000`; volume `brandhub-chroma-data` |
| [`core/core.compose.json`](core/core.compose.json) | `brandhub-db-backup` | `${DB_BACKUP_IMAGE}` | `512m` | Internal `:8090` (`X-Backup-Token`); mounts `/chroma` & `brandhub-db-backup-state` — see [`core/db-backup/README.md`](core/db-backup/README.md) |
| [`core/core-wake.compose.yaml`](core/core-wake.compose.yaml) | `brandhub-crawl-gate` + `brandhub-waker` | `nginx:stable-alpine` + `python:3.12-alpine` | `64m` + `64m` | Publishes `172.31.24.149:8084` ([`core/crawl-gate.nginx.conf`](core/crawl-gate.nginx.conf)) → `172.31.20.50:8084` (`3s` connect timeout) or `@wake` → `waker:8099/wake/crawl` |

```bash
cd ~/brandhub/ecr
docker compose -f core.compose.json up -d
docker compose -f core-wake.compose.yaml up -d
```

---

## 4. Host 3: `ai` (`brandhub-ai` — `172.31.20.60`, `c7i-flex.large`)

- **Instance ID**: `i-0f7857edf71b6bb3f` · **Host Directory**: `~/brandhub/ecr` · **Security Group**: `brandhub-ai-sg`
- **Role**: Dedicated FastAPI AI inference, Brand RAG, BM25 + Graph Virality trend scoring, compliance moderation, and remote Vast.ai GPU orchestration, isolated from `core` so embedding/CPU bursts never starve PostgreSQL or `business-service`.
- **Manifest ([`ai/ai.compose.json`](ai/ai.compose.json))**:
  - Publishes `172.31.20.60:8082` (`mem_limit: 3g`, `memswap_limit: 3g`, `cpus: 1.8`, `init: true`).
  - Maps `redis`, `rabbitmq`, and `chromadb` to `172.31.24.149` via `extra_hosts` and sets `CRAWLER_API_URL=http://172.31.24.149:8084` (`crawl-gate` on `core`).
  - Persists `brandhub-ai-data` (`/app/data`) and `brandhub-ai-model-cache` (`/home/appuser/.cache` for HuggingFace / SentenceTransformers weights).

```bash
cd ~/brandhub/ecr && docker compose -f ai.compose.json up -d
```

---

## 5. Host 4: `crawl` (`brandhub-crawl` — `172.31.20.50`, `c7i-flex.large`, Wakeable)

- **Instance ID**: `i-0288d396a5d5b9b06` · **Host Directory**: `~/brandhub/crawl` · **Security Group**: `brandhub-crawl-sg` · **Tag**: `Wakeable=true`
- **Role**: Headless Playwright/Camoufox social trend collector. Sleeps (`stopped`) when idle to save EC2 compute hours; woken either on demand via `crawl-gate` on `core` or on schedule via EventBridge Scheduler (`03-backend/wake.tf`).
- **Files**:
  - [`crawl/crawl.compose.yaml`](crawl/crawl.compose.yaml): Runs `brandhub-crawl-service` on `172.31.20.50:8084` (`mem_limit: 3200m`, `shm_size: 256mb`, `/dev/shm/crawler` scratch, `CRAWLER_SCHEDULER_ENABLED="false"` because EventBridge owns scheduling, `AI_SERVICE_URL=http://172.31.20.60:8082`, `extra_hosts` for `redis`/`rabbitmq` → `172.31.24.149`, volume `brandhub-crawl-data`). Note: login sessions live in process RAM and must be re-uploaded by `Admin` after container restarts.
  - [`crawl/crawler-connections.compose.yaml`](crawl/crawler-connections.compose.yaml): Optional overlay (`-f crawler-connections.compose.yaml`) bind-mounting `./secrets/crawler-master.key` read-only to `/run/secrets/crawler-master.key` for encrypted proxy/TikTok credentials.
  - [`crawl/crawl-kick.sh`](crawl/crawl-kick.sh): Installed at `/usr/local/bin/brandhub-crawl-kick.sh` (`0755`). Invoked via SSM `AWS-RunShellScript` a few minutes after EventBridge pre-wakes the instance; polls `/health` for up to 10 minutes, reads `INTERNAL_SERVICE_KEY` from inside the running container (so secrets never appear in EventBridge/SSM payloads), and posts to `/api/v1/ai/trends/pipeline/management/scheduled` (`202` or `409` accepted).

---

## 6. Host 5: `edit-video` (`brandhub-edit-video` — `172.31.20.80`, `m7i-flex.large`, Wakeable)

- **Instance ID**: `i-0ec7bf59c53fb7d0b` · **Host Directory**: `~/brandhub/edit-video` · **Security Group**: `brandhub-edit-video-sg` · **Tag**: `Wakeable=true`
- **Role**: Server-side automated video editing & rendering engine (`Edit_Video` API), exposed publicly only via `https://api.brandhub.id.vn/edit-video/*` (authenticated by `X-API-Key`).
- **Manifest ([`edit-video/edit-video.compose.yaml`](edit-video/edit-video.compose.yaml))**:
  - Publishes `172.31.20.80:8095` (`mem_limit: 6500m`, `memswap_limit: 6500m`, `cpus: 1.9`, `pids_limit: 512`, `init: true`).
  - Hardened with `read_only: true` root filesystem, bounded `tmpfs` mounts (`/tmp:1g`, `/home/worker/.npm:256m`, fontconfig/claude caches `64m`), and persistent volumes `brandhub-edit-video-data`, `brandhub-edit-video-claude`, and `brandhub-edit-video-cache`.

```bash
cd ~/brandhub/edit-video && docker compose -f edit-video.compose.yaml up -d --wait
```

---

## 7. Shared Wake-on-Request & Idle-Sleep Subsystem (`shared/`)

### A. IMDSv2 SigV4 EC2 Waker ([`shared/wake/waker.py`](shared/wake/waker.py))

A zero-dependency Python 3.12 standard-library HTTP server (`ThreadingHTTPServer` on `:8099`) running on `python:3.12-alpine` (`64m` RAM) on `gateway` and `core`:
1. Receives `GET/POST /wake/<target>` from Nginx `error_page 502 504` fallback locations.
2. Fetches temporary IAM role credentials (`brandhub-ec2-ecr-pull`) over IMDSv2 (`PUT /latest/api/token`, `http_put_response_hop_limit = 2`) and caches them until 5 minutes before expiry.
3. Calls signed EC2 Query API `DescribeInstances` (`AWS4-HMAC-SHA256`). If the target instance is `stopped` (with a 20-second per-target debounce), invokes `StartInstances` (permitted by IAM **only** when `aws:ResourceTag/Wakeable == "true"`).
4. Responds `503 Service Unavailable` (`Cache-Control: no-store`, `Retry-After: 60`) with `{"status": "STARTING", "target": "<name>", "instanceState": "<state>"}` without leaking internal AWS error messages.

### B. Automated Idle Shutdown ([`shared/idle-sleep/`](shared/idle-sleep/idle-sleep.sh))

Installed on both wakeable hosts (`crawl` and `edit-video`) so woken instances stop themselves automatically after work finishes:
1. [`shared/idle-sleep/brandhub-idle-sleep.timer`](shared/idle-sleep/brandhub-idle-sleep.timer) triggers [`brandhub-idle-sleep.service`](shared/idle-sleep/brandhub-idle-sleep.service) `10min` after boot and every `5min` thereafter, loading `/etc/brandhub/idle-sleep.env` (`IDLE_MODE=crawl` or `IDLE_MODE=edit-video`, `IDLE_MINUTES=30`).
2. [`shared/idle-sleep/idle-sleep.sh`](shared/idle-sleep/idle-sleep.sh) keeps the host awake if:
   - System uptime is `< IDLE_MINUTES` (default `30` minutes, giving incoming wake callers time to submit jobs);
   - Active job files exist (`QUEUED`/`RUNNING` in `brandhub-edit-video-data/_data/jobs/*/job.json`, or `starting.json` / `RUNNING`/`STARTING` in `brandhub-crawl-data/_data/crawler/control/runs/*.json`, or live `chrom|camoufox|firefox` processes inside `brandhub-crawl-service`);
   - Any file in the service's job/control directory was modified within the last `IDLE_MINUTES` minutes.
3. Once all checks confirm inactivity, executes `shutdown -h now` (which stops — never terminates — the EC2 instance and halts compute billing while preserving EBS volumes).

```bash
# Install idle-sleep units on crawl or edit-video EC2
sudo install -m 0755 idle-sleep.sh /usr/local/bin/brandhub-idle-sleep.sh
sudo install -m 0644 brandhub-idle-sleep.service brandhub-idle-sleep.timer /etc/systemd/system/
sudo mkdir -p /etc/brandhub
printf "IDLE_MODE=crawl\nIDLE_MINUTES=30\n" | sudo tee /etc/brandhub/idle-sleep.env >/dev/null
sudo systemctl daemon-reload && sudo systemctl enable --now brandhub-idle-sleep.timer
```

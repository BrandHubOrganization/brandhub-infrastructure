# BrandHub production (AWS 134875421878, ap-southeast-1)

```
prod/
├── hosts/            # what runs on each EC2, one folder per host (mirrors ~/brandhub/<dir> on the host)
│   ├── gateway/      # Nginx (TLS) + API Gateway + edit-video waker
│   ├── core/         # Business, Publisher, PostgreSQL, Redis, RabbitMQ, ChromaDB, crawl waker/gate, backups
│   ├── ai/           # AI service
│   ├── crawl/        # crawl-service
│   ├── edit-video/   # Edit_Video API (sleeps when idle)
│   └── _shared/      # files copied to several hosts (waker.py, idle-sleep)
├── terraform/        # 1-iam → 2-frontend → 3-backend → 4-storage
├── docs/             # current deployment notes, wake-on-request; docs/history = old layouts
└── loadtest/         # k6 script
```

## Hosts

| Folder | EC2 | Type | Private IP | Host dir | Compose | Env files (`env/`, 0600) |
| --- | --- | --- | --- | --- | --- | --- |
| `gateway` | brandhub-api-gateway `i-05f5bfca4452b0f83` | t3.small | 172.31.27.199 | `~/brandhub/ecr` | `backend.compose.json`, `gateway-wake.compose.yaml` | `api-gateway.env` |
| `core` | brandhub-core-services `i-01cba58d9f08be748` | m7i-flex.large | 172.31.24.149 | `~/brandhub/ecr` | `core.compose.json`, `core-wake.compose.yaml` | `business-service`, `publisher-service`, `postgres`, `redis`, `rabbitmq`, `db-backup` |
| `ai` | brandhub-ai `i-0f7857edf71b6bb3f` | c7i-flex.large | 172.31.20.60 | `~/brandhub/ecr` | `ai.compose.json` | `ai-service.env` |
| `crawl` | brandhub-crawl `i-0288d396a5d5b9b06` | c7i-flex.large | 172.31.20.50 | `~/brandhub/crawl` | `crawl.compose.yaml` | `crawl-service.env` |
| `edit-video` | brandhub-edit-video `i-0ec7bf59c53fb7d0b` (stopped, wakes on request) | m7i-flex.large | 172.31.20.80 | `~/brandhub/edit-video` | `compose.prod.yml` | `edit-video.env` |

`brandhub-ci-runner` (`i-017dbae8f6110e50c`, 172.31.25.47, stopped) has no files here.

Each host folder also holds a `.env` with the image tags (`*_IMAGE`) and waker instance IDs, so
`docker compose -f <file> up -d` works without exporting anything. `env/` and `.env` are gitignored; the
copies here are local only. The host is the source of truth.

Waker files: copy `_shared/wake/waker.py` (and `core/crawl-gate.nginx.conf` on core) to `./wake/` on the host.
Idle sleep (crawl, edit-video): see [docs/wake-on-request.md](docs/wake-on-request.md).

## Traffic

Only the gateway is public (80/443, `api.brandhub.id.vn`). Gateway → Business 8081, Publisher 8083, Redis 6379 on core.
Business/crawl → AI `172.31.20.60:8082`. AI → Redis/RabbitMQ/Chroma on core (`extra_hosts`) and crawl via
`crawl-gate` at `172.31.24.149:8084`. Frontend: S3 + CloudFront (`brandhub.id.vn`).

Admin access: SSM Session Manager only. No instance has an SSH key pair.

## Known gaps

- `brandhub-ai` and `brandhub-ci-runner` are not in Terraform state (`terraform/3-backend` manages gateway, core, crawl, edit-video).
- Core still has a leftover `env/ai-service.env` from before AI moved to its own host.

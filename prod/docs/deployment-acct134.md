# Deployment on account 134875421878 (2026-11-18)

| Host | Instance | Private IP | Compose (dir) | Containers |
| --- | --- | --- | --- | --- |
| gateway | i-05f5bfca4452b0f83 | 172.31.27.199 | `backend.compose.json`, `gateway-wake.compose.yaml` (`~/brandhub/ecr`) | Nginx (TLS), API Gateway, waker |
| core | i-01cba58d9f08be748 | 172.31.24.149 | `core.compose.json`, `core-wake.compose.yaml` (`~/brandhub/ecr`) | Business, Publisher, PostgreSQL 17, Redis, RabbitMQ, ChromaDB, db-backup (00:00 VN dumps to S3, see `../hosts/core/db-backup/README.md`), waker, crawl-gate (published on `172.31.24.149:8084`) |
| ai | i-0f7857edf71b6bb3f | 172.31.20.60 | `ai.compose.json` (`~/brandhub/ecr`) | AI (c7i-flex.large, 3 GiB limit; Redis/RabbitMQ/Chroma via `extra_hosts` to core) |
| crawl | i-0288d396a5d5b9b06 | 172.31.20.50 | `crawl.compose.yaml` (`~/brandhub/crawl`) | crawl-service (sleeps when idle) |
| edit-video | i-0ec7bf59c53fb7d0b | 172.31.20.80 | Edit_Video `compose.prod.yml` (`~/brandhub/edit-video`) | not deployed: no image yet (sleeps when idle) |

Image tags live in each directory's `.env` (`BUSINESS_IMAGE`, `PUBLISHER_IMAGE`, `AI_IMAGE`, `GATEWAY_IMAGE`,
`CRAWLER_IMAGE`, `DB_BACKUP_IMAGE`) next to the compose file, so `docker compose -f <file> up -d` works without exporting anything.
First images: `sha-<commit>-acct134`, built from `origin/develop` (crawl: `origin/main`) on 2026-11-18.

Runtime env files (`env/*.env`, 0600) come from the 2026-10-29 files with the old account's static AWS keys
removed: Business (`DefaultCredentialsProvider`) and AI (boto3) use the EC2 instance role. Buckets point at
`brandhubmedia-134875421878`. Local copies: `keep-local-only/acct134/env/` (gitignored). Files reached the hosts
through a temporary S3 prefix deleted right after, never as SSM command text.

PostgreSQL was restored from `docs/database/backups/brandhub_postgres_full_20261112.dump` (93 tables, 1099 users,
857 workspaces), then replaced on 2026-11-19 by `brandhub_full_dump_2026-11-19.sql` (`brandhub` only: 90 tables, 1265 users; pre-restore dump at `s3://brandhub-db-backup-prd-134875421878/postgres/brandhub-before-restore-20261119T144845Z.dump`). `core.compose.json` does not mount `init/schema.sql`: the dump already contains the schema.

TLS: Let's Encrypt for `api.brandhub.id.vn` (standalone on first issue), renewed by
`brandhub-certificate-renew.timer` on the gateway.

## AI host (2026-11-19)

AI moved off core onto `brandhub-ai` (SG `brandhub-ai-sg`, profile `brandhub-ec2-ecr-pull`, 40 GiB gp3).
Business and crawl use `AI_SERVICE_URL=http://172.31.20.60:8082`; AI uses `CRAWLER_API_URL=http://172.31.24.149:8084`
(core SG allows 8084 from `brandhub-ai-sg`). Core keeps the `brandhub-ai-data`/`brandhub-ai-model-cache` volumes and
`~/brandhub/ecr/rebalance-ai-20261119/` (compose + volume tarballs) for rollback. Monitoring agent enrolled as
`brandhub-ai`; the `AI Service Health` target points at its server id.

## Verified

- `https://api.brandhub.id.vn/actuator/health` 200 UP; HTTP -> 308; login with `{}` 400; protected route 401;
  CORS allows `https://brandhub.id.vn`.
- Core: all 8 containers healthy. AI (own host) reports Redis, RabbitMQ and S3 connected; Chroma heartbeat and crawl-gate 200 from the AI container; Business container reaches AI health.
- `https://api.brandhub.id.vn/edit-video/health` with edit-video stopped -> `503 STARTING`, instance started.
- AI -> `crawl-gate` with crawl stopped -> `503 STARTING`, instance started; once up, crawl management health
  reports collector, browser, proxy, broker, worker, tracking, chroma OK.

## Known gaps

- No Neo4j: AI and crawl report `neo4j` BLOCKED (the AI env points at `bolt://neo4j:7687`).
- Crawl: Facebook/Threads sessions must be uploaded after every wake; TikTok not configured;
  `CRAWLER_SECRET_KEY_FILE` not set, so encrypted connection storage is off (`secretStorageReady=false`).
- Frontend not deployed (`brandhub-web-prd-134875421878` is empty); the CloudFront alias waits on AWS Support.
- CI workflows of the five services still push to account 821014378805.

## Repository storage (2026-11-19)

Business stores `repository/`, `repository-staging/` objects in `brandhub-media-134875421878` with SSE-KMS
(`alias/brandhub-repository-media-prod`) via `REPOSITORY_STORAGE_SYSTEMS3_BUCKET` and `REPOSITORY_SYSTEM_S3_KMS_KEY_ID`
in `env/business-service.env` (previous file: `.bak-20261119`). Existing objects were copied by the core instance role;
admin users cannot read or write them by design. `brandhubmedia-134875421878` serves `image/*` publicly; the rest stays private.

## Post templates (2026-11-19)

- DB: `hosts/core/migrations/20261119-workspace-post-templates.sql` (table + 5 FPTU templates for workspace `b47477c4-…`).
- Business: `sha-7913c1b-acct134` (`origin/develop`, includes post-template API), set in `core.compose.json`
  (previous: `sha-d7fa38a-205`, backup `core.compose.json.bak-20261119-business`).
- Web: `origin/develop` (81f5ccae) + uncommitted template fix, built locally with `VITE_API_BASE_URL=https://api.brandhub.id.vn`;
  previous bucket contents at `s3://brandhub-db-backup-prd-134875421878/web-rollback-20261119/`.

## Ad image: AI-written prompt, no style presets (2026-11-20)

- Worker (Vast `82.76.166.173:45207`): new `app.py` copied over SSH (`app.py.bak-20261120` kept), uvicorn restarted.
- AI service: `sha-3f4a04e-nopreset-acct134` (prod commit + preset removal) via `AI_IMAGE` in `.env` on the AI host (`.env.bak-20261120-nopreset`).
- Web: `origin/main` + template fix + style removal, built locally; previous bucket at `s3://brandhub-db-backup-prd-134875421878/web-rollback-20261120/`.
- None of these changes are committed yet: the next CI deploy of web, AI service or worker will overwrite them.
- Follow-up (same day): web vs direct worker quality gap. The Vast instance had no Ollama, so the VLM
  (`VLM_URL=http://127.0.0.1:11434`, `qwen2.5vl:7b`) never described the images. Installed Ollama
  (models in `/workspace/ollama-models`, log `/workspace/ollama.log`) and pulled `qwen2.5vl:7b`; the deploy
  workflow now does this too (worker PR #5). Web defaults to aspect `auto` ("Theo pose"): AI service
  `sha-3f4a04e-autosize-acct134` sends no size, so the worker sizes the output from `<image3>`.

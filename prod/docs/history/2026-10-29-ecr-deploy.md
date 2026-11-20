# Three-EC2 deployment with ECR

## Target topology (planned 2026-11-13, not yet applied)

| Host | Type | Containers | Compose |
| --- | --- | --- | --- |
| brandhub-api-gateway, 172.31.27.199 | t3.small (2 GiB) | Nginx, API Gateway | `backend.compose.json` |
| brandhub-core-services, 172.31.24.149 | m7i-flex.large (8 GiB) | AI (8082), Business (8081), Publisher (8083), PostgreSQL, Redis, RabbitMQ, ChromaDB | `service.compose.json` |
| brandhub-crawl, 172.31.20.50 | m7i-flex.large (8 GiB) | crawl-service (8084, private) | `crawl.compose.yaml` |

Only the gateway is public (80/443). Gateway reaches Business, Publisher and Redis. Crawl reaches AI 8082, RabbitMQ 5672 and Redis 6379 on core; AI reaches crawl 8084. Business calls AI on the shared Docker network.

Private IPs are pinned in `terraform.tfvars`. AI drops from a 5 GiB to a 3 GiB budget because the browser crawler no longer runs inside it. Cutover: apply Terraform, move the AI volumes/env from gateway to core, start crawl, then deploy the AI CI change that targets the core instance.

## Previous two-EC2 layout (2026-11-03, historical)

## Production rebalance (applied 2026-11-03)

The checked-in Compose files describe the deployed topology below. The original deployment inventory further down is historical. See the [migration runbook and verified result](./rebalance-ai.md).

| Host | Containers | AI budget |
| --- | --- | --- |
| Backend / gateway, 172.31.27.199 | Nginx, API Gateway, AI API/crawler/consumer | 5 GiB RAM, 1.5 CPUs |
| Service, 172.31.24.149 | Business, Publisher, PostgreSQL, Redis, RabbitMQ, ChromaDB | AI removed |

AI data and model cache use named volumes on backend. Its runtime env file moves to backend as well. Business calls `http://172.31.27.199:8082`; AI calls Redis, RabbitMQ and ChromaDB at `172.31.24.149`. Ports 8082, 5672 and 8000 bind only to private IPs and are restricted to the corresponding peer security group. Redis reuses the existing private 6379 binding/rule. Host aliases preserve existing `redis`/`rabbitmq`/`chromadb` names in credential-bearing URLs without copying credentials into Compose.

The local, ignored `terraform.tfvars` sets both root disks to 20 GiB: gateway grows from 10 GiB; service stays at its current 20 GiB. Copy this sizing into the environment-specific Terraform inputs when deploying elsewhere. EC2 types remain `m7i-flex.large`.

AI and gateway CI acquire the same host lock, `/var/lock/brandhub-backend-compose.lock`, before modifying the shared backend manifest. GitHub concurrency groups alone do not serialize deployments across repositories. Deploy the workflow changes together with the host migration; leave CI paused until cutover verification finishes.

The 5 GiB limit is an initial budget, not proof that crawl OOM is fixed. AI dependencies, Business connectivity, public HTTPS and an actual browser launch/render/close smoke passed after cutover; the new AI cgroup recorded no OOM or restarts during these checks. Validate an actual bounded crawl after session re-upload. Facebook/Threads sessions are missing, TikTok is not configured, and secret-file storage remains unconfigured; these are separate from the successfully verified service connections.

## Original deployment baseline

Deployment on 2026-10-29 uses immutable ECR tag `deploy-20261029` in account 821014378805, region ap-southeast-1.

| Host | Address | Containers |
| --- | --- | --- |
| Backend | 13.213.39.126 / 172.31.27.199 | Nginx, API Gateway |
| Service | 13.213.70.48 / 172.31.24.149 | Business, Publisher, AI, PostgreSQL, Redis, RabbitMQ, ChromaDB |

Public API: https://api.brandhub.id.vn. Frontend origin: https://brandhub.id.vn.

Each server runs from `/home/ec2-user/brandhub/ecr`. Backend uses `backend.compose.json`, service uses `service.compose.json`. JSON files are accepted by Docker Compose. Each host receives only its own Compose and env files.

## Environment and storage

Private runtime environment files are in `env/` on each host, mode 0600; directories are 0700. Local deployment env/JWT material is retained outside tracked source under `keep-local-only/ecr-deploy-20261029/private/`. Do not commit or bake these files into images.

Backend needs `env/api-gateway.env`. Service needs separate env files for business-service, publisher-service, ai-service, postgres, redis and rabbitmq (MongoDB Atlas and Neo4j AuraDB are hosted externally). Missing runtime env files intentionally prevent Compose startup.

PostgreSQL uses the complete exported schema at `init/schema.sql`. The SQL file must be readable by the container's postgres user (0644). Initialization runs only for an empty data volume. The database has schema only; old data was not restored after the explicitly authorized EC2 replacement. Never use `down -v` during application updates.

Gateway reaches Business (8081), Publisher (8083) and Redis (6379) through the service host's private IP. Terraform permits these ports only from the backend Security Group. Other infrastructure ports have no host bindings. Only backend ports 80 and 443 are public.

## Updating application images

Build linux/amd64 images locally or in CI, tag each with a new unique release/commit tag, then push to `821014378805.dkr.ecr.ap-southeast-1.amazonaws.com/brandhub/<service>`. ECR tags are immutable; never overwrite `deploy-20261029`.

Authenticate the build machine:

```powershell
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 821014378805.dkr.ecr.ap-southeast-1.amazonaws.com
```

Update the image tag in the appropriate Compose file, copy that file to the matching host, then run on that host:

```bash
cd /home/ec2-user/brandhub/ecr
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 821014378805.dkr.ecr.ap-southeast-1.amazonaws.com
docker compose -f service.compose.json config -q
docker compose -f service.compose.json pull
docker compose -f service.compose.json up -d --no-build --wait --wait-timeout 240
docker compose -f service.compose.json ps
```

Use `backend.compose.json` on backend. EC2 authenticates ECR through its instance role, not stored AWS credentials. Existing application S3 credentials remain in the corresponding application env files.

Rollback: set the application image back to its previous immutable tag and repeat pull/up. Database migrations require a separate compatibility and rollback plan.

## HTTPS and external integrations

Let's Encrypt files are under `letsencrypt/` on backend; renewal uses `acme-webroot/`. `brandhub-certificate-renew.timer` checks twice daily and reloads Nginx after successful renewal. Inspect with `systemctl list-timers brandhub-certificate-renew.timer` and `journalctl -u brandhub-certificate-renew.service`.

OAuth callbacks configured in runtime env:

- Google: `https://api.brandhub.id.vn/api/v1/auth/oauth/google/callback`
- Facebook: `https://api.brandhub.id.vn/api/v1/social/facebook/callback`
- Instagram: `https://api.brandhub.id.vn/api/v1/social/instagram/callback`
- TikTok: `https://api.brandhub.id.vn/api/v1/social/tiktok/callback`
- Threads: `https://api.brandhub.id.vn/api/v1/social/threads/callback`

These same callback URLs must be registered in the respective provider consoles. Frontend must be built with `VITE_API_BASE_URL=https://api.brandhub.id.vn`; this deployment does not rebuild the S3/CloudFront frontend. Provider keys absent from the supplied env (e.g. image/video generation keys) remain unconfigured.

Infrastructure resources and DNS are managed in `brandhub-deloy/terraform/ec2-prod`. Update both runtime endpoints and DNS if replacing EC2 again, since private/public addresses are currently tied to these instances.

## Deployment verification (2026-10-29)

- All four custom application images were built for linux/amd64, pushed to ECR and pulled on EC2. AI module import passed inside the image.
- All application and database/cache/broker containers report healthy. AI health reports Redis, RabbitMQ and S3 clients connected; this is not an end-to-end check of paid providers or S3 operations.
- Public HTTPS health returns `{"status":"UP"}`. HTTP redirects to HTTPS (308).
- CORS preflight from `https://brandhub.id.vn` returns 200 and the matching allowed origin.
- Login with an empty JSON body reaches Business through Nginx/Gateway and returns the expected validation response (400). Protected unauthenticated endpoint returns 401.
- Let's Encrypt renewal dry-run succeeded. Renewal timer is active.
- Runtime env files are mode 0600. Compose manifests passed a scan against the supplied secret values.
- Final Terraform plan reports no changes. No existing EC2 was destroyed during this deployment.

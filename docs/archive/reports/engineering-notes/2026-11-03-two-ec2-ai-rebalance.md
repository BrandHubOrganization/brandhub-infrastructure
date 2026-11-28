# Two-EC2 AI rebalance implementation plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move the existing AI API/crawler/consumer to the gateway EC2 without adding or resizing EC2 instances.

**Architecture:** Gateway EC2 (172.31.27.199) runs Nginx, gateway and AI; service EC2 (172.31.24.149) retains Business, Publisher, PostgreSQL, Redis, RabbitMQ and ChromaDB. AI has a 5 GiB hard RAM limit and 1.5 CPU limit. Preserve the current immutable AI image, runtime secrets, crawler data and model cache. Increase gateway root EBS from 10 to 20 GiB for the 3.78 GiB image and 1.5 GiB model cache.

**Tech Stack:** Docker Compose JSON, Terraform AWS provider, SSH/SSM, GitHub Actions.

**Spec:** User selected the proposed reuse of the two existing machines in this chat.

## Global constraints

- No EC2 replacement, no database volume removal, no duplicate active scheduler.
- Secrets remain in mode-0600 runtime env files and travel only over encrypted transport.
- TCP 8082: service SG to gateway SG; TCP 5672/8000: gateway SG to service SG. Bind published ports to private addresses only; reuse existing Redis rule.
- Preserve running image tags when changing live manifests; repository baseline tags are not deployment inputs.
- Keep old AI container/volume and manifest/env backups for rollback; do not remove volumes.

## Review focus

- Cross-host dependencies must use reachable private endpoints, including REDIS_URL.
- Crawler files outside the data volume and model cache must be checked before cutover.
- Starting a second AI instance before stopping the old scheduler is forbidden.
- CI must deploy AI to the new host/manifest and serialize updates on that host.
- Health checks are necessary but cannot prove the original crawl OOM resolved; verify a bounded actual crawl separately.

## Tasks

- [x] Inspect live image, mounts, endpoint variable names and disk capacity; snapshot current manifests and env files remotely.
- [x] Move AI definition/data volume to backend.compose.json, add persistent model cache, set cross-host dependencies and limits; publish RabbitMQ/Chroma on service private IP and update Business AI URL.
- [x] Add only three SG ingress rules and configure gateway root volume at 20 GiB in Terraform; inspect plan for replacements/unrelated drift before applying. Plan reviewed and applied after explicit production authorization; final plan reports no changes. Corrected local ignored service disk input from 22 to actual 20 GiB to avoid unrelated growth; gateway input was 8 GiB and is now 20 GiB rather than attempting a shrink from actual 10 GiB.
- [x] Update AI CI target to gateway instance/backend.compose.json and document topology, migration and rollback. Add shared host-level flock to AI and gateway workflows because both mutate the backend manifest.
- [x] Validate JSON, Compose, Terraform and workflow changes; review diff. Compose validation without env resolution, Terraform validate/fmt, placement/network/volume contracts, workflow YAML/lock assertions and Amazon Linux bash -n all passed. Independent review found no remaining actionable issue. Production env/dependency and crawl checks remain pending.
- [x] Stage latest running AI image/cache and manifests on gateway. Stop source AI, transfer consistent data, start destination, verify dependencies and Business connectivity. Recreate only affected services; retain stopped source AI for rollback.
- [x] Verify private port bindings, public HTTPS health, RAM limits and singleton crawler. Remove temporary transfer access. Record any incomplete workload verification. Actual browser smoke passed with zero new OOM/restarts; full authenticated crawl requires user session re-upload. All CI deploy workflows re-enabled after AI/gateway remote workflow updates.

## Approval boundary discovered during preparation

User explicitly authorized production changes after disclosure of the maintenance window, RAM-only session loss and irreversible EBS expansion. Applied on 2026-11-03. Full result and remaining authenticated-crawl verification are recorded in `prod/ec2-ecr/rebalance-ai.md`.

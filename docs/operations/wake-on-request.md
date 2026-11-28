# Auto-Sleep & Wake-on-Request Architecture (`crawl` & `edit-video`)

> Navigation: [← Knowledge Base Hub](../index.md) · [← Operations Hub](./README.md) · [Production Deployment Runbook](./deployment-acct134.md)

To minimize AWS EC2 compute spend without sacrificing on-demand availability, the two bursty worker hosts—**`brandhub-crawl`** (`i-0288d396a5d5b9b06`, `172.31.20.50`) and **`brandhub-edit-video`** (`i-0ec7bf59c53fb7d0b`, `172.31.20.80`)—automatically stop themselves after 30 idle minutes and wake automatically via EC2 `StartInstances` when HTTP traffic or a scheduled cron arrives.

Infrastructure & source files live in `prod/terraform/03-backend/wake.tf` (`wake_on_request = true` → tag `Wakeable=true`), `prod/hosts/shared/wake/`, and `prod/hosts/shared/idle-sleep/`.

---

## 1. End-to-End Request & Scheduler Flow

```text
Browser / Client ──HTTPS──► gateway Nginx (/edit-video/*) ──:8095──► brandhub-edit-video (when running)
                                   │
                                   └── 502 / 504 (stopped) ──► gateway waker (:8099)
                                                                 ├─► EC2 StartInstances (SigV4 + IMDSv2)
                                                                 └─► HTTP 503 {"status":"STARTING"} + Retry-After: 60

brandhub-ai (172.31.20.60) ──HTTP──► core crawl-gate (:8084) ──:8084──► brandhub-crawl (when running)
                                          │
                                          └── 502 / 504 (stopped) ──► core waker (:8099) ──► EC2 StartInstances + 503 STARTING

EventBridge Scheduler (07:00 & 19:00 Asia/Ho_Chi_Minh):
  T+0 min: ec2:StartInstances on brandhub-crawl
  T+5 min: SSM RunCommand (AWS-RunShellScript) executes /usr/local/bin/brandhub-crawl-kick.sh ──► POST /management/scheduled
```

---

## 2. Component & File Inventory (`prod/hosts/`)

| Source Path in Repo | Deployed Host(s) | Runtime Role |
| :--- | :--- | :--- |
| `prod/hosts/shared/wake/waker.py` | `gateway`, `core` | Zero-dependency Python `3.12-alpine` HTTP daemon (`POST/GET /wake/<target>`). Fetches temporary role credentials via **EC2 IMDSv2** and signs `ec2:StartInstances` with **AWS SigV4** using Python stdlib only. |
| `prod/hosts/gateway/gateway-wake.compose.yaml` & `nginx.conf` | `gateway` | Runs `waker` for `edit-video`; Nginx routes `error_page 502 504 = @edit_video_wake` to `waker:8099`. |
| `prod/hosts/core/core-wake.compose.yaml` & `crawl-gate.nginx.conf` | `core` | Publishes `crawl-gate` (`:8084`) and `waker` for `crawl`; `brandhub-ai` calls `CRAWLER_API_URL=http://172.31.24.149:8084`. |
| `prod/hosts/shared/idle-sleep/idle-sleep.sh` + `brandhub-idle-sleep.{service,timer}` | `crawl`, `edit-video` | Systemd timer firing every **5 minutes**; powers off the host cleanly once all idle conditions hold for `IDLE_MINUTES=30`. |
| `prod/hosts/crawl/crawl-kick.sh` | `crawl` | Invoked by EventBridge + SSM 5 minutes after scheduled boot; extracts `INTERNAL_API_KEY` from the running container and triggers `/management/scheduled`. |

---

## 3. Idle Detection, Client Retry Contract & IAM Guardrails

1. **Strict Idle Predicate (`idle-sleep.sh`)**:
   - An instance only stops itself when **all three** conditions hold simultaneously:
     1. System uptime is **≥ 30 minutes** (prevents boot-loop flapping right after wake).
     2. Zero active jobs (`QUEUED`/`RUNNING` video renders on `:8095`, or `STARTING`/`RUNNING` crawl jobs / active Chromium/Camoufox processes on `:8084`).
     3. Zero file modifications inside the service working volume for **30 minutes** (`/etc/brandhub/idle-sleep.env`: `IDLE_MODE`, `IDLE_MINUTES`).
   - Maintenance override on a host: `sudo systemctl disable --now brandhub-idle-sleep.timer`.
2. **Caller `503 STARTING` Contract**:
   - Callers (`brandhub-web` Video Studio and `brandhub-ai-service` crawler client) treat HTTP `503` with JSON body `{"status":"STARTING"}` as an asynchronous cold-start signal and poll after `Retry-After` (`60s`; typical EC2 + Docker healthy boot time is `60–110s`).
   - `WAKE_FAILED` indicates an AWS API failure—inspect `docker logs brandhub-waker`.
3. **Least-Privilege Tag-Scoped IAM (`prod/terraform/03-backend/wake.tf`)**:
   - The EC2 instance role is permitted `ec2:StartInstances` **strictly** on instances carrying tag `Wakeable=true` (`gateway`, `core`, and `ai` cannot be stopped/started via waker).
   - The EventBridge Scheduler IAM role is scoped exclusively to `StartInstances` and `ssm:SendCommand` (`AWS-RunShellScript`) on the `brandhub-crawl` instance ARN. Schedule times are configured via `crawl_schedule_times` (`Asia/Ho_Chi_Minh`) in `prod/terraform/03-backend/`.

---

## 4. Host Installation & Rollout Commands

- **On `crawl` and `edit-video` (via AWS SSM)**:
  1. Copy `prod/hosts/shared/idle-sleep/idle-sleep.sh` → `/usr/local/bin/brandhub-idle-sleep.sh` (`chmod 0755`) and `brandhub-idle-sleep.{service,timer}` → `/etc/systemd/system/`.
  2. Write `/etc/brandhub/idle-sleep.env` (`IDLE_MODE=crawl` or `IDLE_MODE=edit-video`, `IDLE_MINUTES=30`) and run `sudo systemctl daemon-reload && sudo systemctl enable --now brandhub-idle-sleep.timer`.
  3. On `crawl`, also install `prod/hosts/crawl/crawl-kick.sh` → `/usr/local/bin/brandhub-crawl-kick.sh`.
- **On `gateway`**:
  ```bash
  cp prod/hosts/shared/wake/waker.py ~/brandhub/ecr/wake/waker.py
  EDIT_VIDEO_INSTANCE_ID=i-0ec7bf59c53fb7d0b docker compose -f gateway-wake.compose.yaml up -d
  sudo nginx -t && sudo systemctl reload nginx
  ```
- **On `core`**:
  ```bash
  cp prod/hosts/shared/wake/waker.py ~/brandhub/ecr/wake/waker.py
  cp prod/hosts/core/crawl-gate.nginx.conf ~/brandhub/ecr/wake/crawl-gate.nginx.conf
  CRAWL_INSTANCE_ID=i-0288d396a5d5b9b06 docker compose -f core-wake.compose.yaml up -d
  ```

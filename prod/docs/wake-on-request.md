# Sleep when idle, wake on request (crawl, edit-video)

`brandhub-crawl` (i-0288d396a5d5b9b06, 172.31.20.50) and `brandhub-edit-video` (i-0ec7bf59c53fb7d0b, 172.31.20.80)
stop themselves when idle and start again when work arrives. Terraform: `3. backend-prod/wake.tf`, instances with
`wake_on_request = true` (tag `Wakeable=true`).

```
client --https--> gateway Nginx /edit-video/ --8095--> edit-video     (up: proxied)
                        | 502/504 (stopped)
                        +--> waker:8099 --StartInstances--> 503 {"status":"STARTING"} + Retry-After: 60

AI (core) --> crawl-gate:8084 --8084--> crawl                       (same fallback to the core waker)
EventBridge Scheduler: 07:00/19:00 VN start crawl, +5 min SSM runs crawl-kick.sh -> /management/scheduled
```

| File | Where | Role |
| --- | --- | --- |
| `waker.py` | gateway, core | `/wake/<target>` starts the instance (stdlib only: SigV4 + IMDSv2, runs on `python:3.12-alpine`) |
| `gateway-wake.compose.yaml` | gateway | waker for `edit-video`; `../nginx.conf` falls back to it |
| `core-wake.compose.yaml`, `crawl-gate.nginx.conf` | core | waker + gate for `crawl`; AI uses `CRAWLER_API_URL=http://crawl-gate:8084` |
| `idle-sleep.sh` + `brandhub-idle-sleep.{service,timer}` | crawl, edit-video | every 5 min: stop the host when idle |
| `crawl-kick.sh` | crawl | started by the schedule; reads the internal key from the running container |

**Idle** = up at least 30 min, no QUEUED/RUNNING edit job (or RUNNING/STARTING crawl run, or a running browser),
and no file change in the service data for 30 min. Settings: `/etc/brandhub/idle-sleep.env`
(`IDLE_MODE`, `IDLE_MINUTES`). Disable on a host: `systemctl disable --now brandhub-idle-sleep.timer`.

**Clients** treat `503` with `{"status":"STARTING"}` as "retry after `Retry-After` seconds". A cold start takes
about 1–2 minutes (EC2 boot plus container health). `WAKE_FAILED` means the start call failed; check `docker logs brandhub-waker`.

**IAM**: the shared EC2 role may `ec2:StartInstances` only on `Wakeable=true` instances (verified: dry-run allowed
on edit-video, `UnauthorizedOperation` on gateway and core). The scheduler role may start only crawl and run
`AWS-RunShellScript` only on crawl.

**Crawl caveat**: Facebook/Threads sessions are RAM-only by design. After every wake they must be uploaded again
through the management API. Proxy and TikTok connections are stored encrypted on disk and survive.

**Change crawl times**: `crawl_schedule_times` in `3. backend-prod` (HH:MM, Asia/Ho_Chi_Minh), then apply.

## Install

- crawl, edit-video: done over SSM on 2026-11-18 (scratchpad `ssm_install.py` mirrors the steps: copy
  `idle-sleep.sh` to `/usr/local/bin/brandhub-idle-sleep.sh`, units to `/etc/systemd/system`, write
  `/etc/brandhub/idle-sleep.env`, `systemctl enable --now brandhub-idle-sleep.timer`; crawl also gets
  `crawl-kick.sh` at `/usr/local/bin/brandhub-crawl-kick.sh`).
- gateway: copy `waker.py` to `./wake/`, then
  `EDIT_VIDEO_INSTANCE_ID=i-0ec7bf59c53fb7d0b docker compose -f gateway-wake.compose.yaml up -d` and reload Nginx.
- core: copy `waker.py` and `crawl-gate.nginx.conf` to `./wake/`, then
  `CRAWL_INSTANCE_ID=i-0288d396a5d5b9b06 docker compose -f core-wake.compose.yaml up -d`.

## Verified 2026-11-18

- edit-video stopped itself after 30 idle minutes (`stopped`, private IP kept).
- A real `POST /wake/edit-video` from an EC2 container returned `503 STARTING` and the instance went `running`.
- Unknown targets return `404 UNKNOWN_TARGET`.
- Both Nginx configs pass `nginx -t`; locally the gate turned a dead upstream into the waker's 503.
- Not yet run: the full path through the gateway and core Nginx (those hosts have no containers yet) and a
  scheduled crawl (no crawl image in ECR yet).

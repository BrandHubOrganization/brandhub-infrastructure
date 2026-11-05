# AI migration between the existing EC2 instances

Status: applied to production on 2026-11-03 with user authorization. The procedure below is retained as a migration/rollback reference.

## Deployment result

- Existing EC2 instances retained; gateway EBS expanded from 10 to 20 GiB and XFS grown online. Service EBS remains 20 GiB.
- Terraform applied three private ingress rules and two in-place resource updates. Final `terraform plan -detailed-exitcode` returned 0: **No changes**.
- AI runs only on gateway with 5 GiB RAM and 1.5 CPUs. Source AI container is stopped and retained. Both live manifests preserve the original running image tags; checked-in Compose image tags now reflect this deployment snapshot too.
- Source and destination crawler data matched by file count and aggregate content hashes (302 files). Model cache (about 1.5 GiB) transferred to its persistent named volume over compressed SSH. Private backups are under `/home/ec2-user/brandhub/ecr/rebalance-20261103/` on each host; never publish their env files.
- Verified authenticated Redis/RabbitMQ connections, private Chroma heartbeat, Neo4j/tracking/worker/scheduler checks, appuser data/cache permissions and Business-container access to the new AI private endpoint.
- Verified public HTTPS health 200/UP, login validation 400 through Business, and protected unauthenticated request 401.
- Real crawler browser launch/render/close smoke passed on a self-contained data URL. New AI cgroup OOM counters remained zero and restart count was zero. A first synthetic `set_content` smoke timed out waiting for a load event; the self-contained navigation test passed without application changes.
- Idle RAM available after migration was about 5.7 GiB on gateway and 5.8 GiB on service. Gateway disk usage was about 9/20 GiB. These are idle snapshots, not peak-crawl measurements.
- AI/gateway deploy workflows updated on GitHub `develop` and read back successfully. Their `main` branches had no corresponding deployment workflow file, so none was created there. AI commit: `b7a4f9e7c03ac89e1c21a051719c05285b5cf6b2`; gateway commit: `ddbc03f912d52aa9413e9634ac006160400964e8`.
- All four application deploy workflows re-enabled. Temporary administrator-IP-only SSH rules removed. No database volumes or rollback data deleted.
- Full crawl validation remains pending session re-upload. Management reports Facebook/Threads `SESSION_MISSING`, TikTok `TIKTOK_NOT_CONFIGURED`, and `secretStorageReady=false`. Proxy and runtime dependencies report OK. Do not claim the original full-crawl OOM is resolved from these smoke checks alone.

## Preconditions and approval boundary

- Source: `i-07283e8467a059e5a`, private IP `172.31.24.149`.
- Destination: `i-0761e3bd96ca5d4de`, private IP `172.31.27.199`.
- Working directory on both: `/home/ec2-user/brandhub/ecr`.
- Confirm a short maintenance window and that the operator can re-upload Facebook/Threads sessions. `CrawlerSecrets` holds these sessions only in API process RAM; restarting or moving the process loses them. A volume backup does not preserve them.
- Approve gateway EBS growth from 10 to 20 GiB. This incurs additional EBS storage cost and cannot be rolled back by shrinking the volume. No EC2 type change or additional EC2 is needed.
- Pause application CI while copying/changing manifests. Merge/release the AI target change and both host-lock changes together with cutover, before resuming CI. Unchanged AI CI targets the old host.
- AWS SSM is online on both machines. Direct administrator SSH currently times out because its configured admin CIDR differs from the current network. Use an authenticated SSM SSH tunnel or a temporary administrator-IP-only SSH rule; verify host keys through SSM, and remove temporary access after transfer. Never open SSH globally.

## 1. Prepare and inspect the infrastructure plan

From `prod/terraform/3. backend-prod`, use the existing production inputs, with `instances.api_gateway.root_volume_size = 20` and `instances.core_services.root_volume_size = 20`.

```text
terraform fmt -check
terraform validate
terraform plan -out=<private-local-plan-path>
```

Expected: three SG ingress resources added; gateway root volume 10 -> 20 GiB. Existing configuration also reconciles EC2/volume Name and Service tags and renamed outputs. No AMI/instance type/IP changes, deletions or replacements are expected. Service root stays 20 GiB. If the plan proposes shrinking a disk, stop. Recheck the saved plan immediately before applying it; do not reuse a stale plan after production changes.

After approved apply, inspect `lsblk -f` and `df -h /` on gateway. If the filesystem has not expanded, identify its actual partition/filesystem first, then use the matching `growpart` and `xfs_growfs`/`resize2fs` commands. Do not assume device names or format a filesystem.

## 2. Stage without starting another scheduler

1. Make private, timestamped backups of both live Compose files and affected env files on their own hosts. Keep the original source AI container and `brandhub-ai-data` volume for rollback.
2. Record the actual running image tags from Docker inspect. At inspection AI used `sha-a42b445-36`, Business `sha-d9a0bbe-113`, Publisher `sha-819bf14-32`. Re-read these values at deployment time. The repo's `deploy-20261029` images are historical baselines: **do not copy repo manifests wholesale over production**.
3. Patch copies of the live manifests with only the placement/limits/network/volume changes in the checked-in Compose diff. Preserve all current image tags and unrelated settings. Destination AI definition comes from the live source AI, with its old `depends_on` removed, plus the checked-in backend AI resource limits, private binding, environment overrides, host aliases and model-cache mount.
4. Transfer `env/ai-service.env` over encrypted transport directly into destination `env/` (0700 directory, 0600 file). Do not print its contents or send them as SSM command text. Inspect configured file paths without printing their contents; copy any referenced secret-key/session files outside `/app/data` to equivalent private paths and preserve their permissions/mounts. RAM-only sessions still need re-upload.
5. Check `REDIS_URL` hostname only, without logging credentials. Existing `redis` host is resolved by `extra_hosts`; if it uses another host, make an explicit private-endpoint adjustment in the runtime file. Set `REDIS_HOST`, `RABBITMQ_HOST`, `CHROMADB_HOST` via Compose as checked in.
6. Authenticate ECR with the EC2 role and pull the **current source AI tag** on gateway. Check free disk before and after. Do not start AI yet.
7. Create destination named volumes `brandhub-ai-data` and `brandhub-ai-model-cache`. Inspect them first; stop if they already contain unrelated data. Copy the source `/home/appuser/.cache` tree from the AI container into the cache volume using Docker copy/tar over encrypted transport. Preserve ownership, symlinks and mode bits; the inspected cache was about 1.5 GiB. It currently resides in the container writable layer.
8. Validate both staged manifests on their intended hosts with `docker compose -f <file> config -q`. Do not print resolved Compose config because it can contain credentials.

## 3. Cut over

1. Wait for the active crawl to finish; inspect crawler state using the existing management API. Stop if a run is still active. Keep CI paused.
2. Stop source `ai-service` gracefully. Confirm all source scheduler/browser/consumer processes have exited before starting destination AI.
3. Transfer the now-consistent `brandhub-ai-data` volume to destination over encrypted transport, preserving ownership and mode bits. Compare file counts and hashes without printing file contents. Do not transfer a live, changing state directory.
4. Install patched service manifest. Recreate **only** `rabbitmq` and `chromadb` to publish 5672/8000 on the source private IP. Their named data volumes remain unchanged. Wait for health; broker reconnections may briefly affect Business/Publisher. Redis already has a private 6379 binding and need not be recreated.
5. Install patched backend manifest and start only `ai-service`, using `docker compose -f backend.compose.json up -d --no-deps --no-build --wait --wait-timeout 240 ai-service`. Confirm the original source AI remains stopped.
6. Verify from destination AI that Redis authenticates, RabbitMQ connects and Chroma responds. Probe `/health` and `/api/v2/heartbeat` on Chroma through its private binding as applicable. Verify the named cache volume is readable/writable by appuser.
7. Install the Business `AI_SERVICE_URL=http://172.31.27.199:8082` override and recreate only Business. Verify Business can reach AI and public HTTPS requests still reach Business through gateway. Expect a short Business interruption with one replica.
8. Re-upload Facebook/Threads sessions through the existing authenticated UI. Run one bounded crawl with the intended worker processing enabled. Record memory peak and OOM counters on the new AI cgroup, container restarts, RAM available on both hosts, gateway health and response latency. A passing `/health` alone is insufficient.
9. Resume CI only after workflow changes point AI at destination and both workflows use the shared host lock. Confirm there is exactly one AI scheduler/consumer deployment. Keep rollback assets until the crawl is verified. Remove temporary transfer access, if any.

## 4. Roll back on connectivity, health or resource failure

1. Stop destination AI first, to avoid two schedulers/consumers. Keep CI paused and prevent scheduled jobs during rollback.
2. If destination accepted writes or completed jobs, preserve its data and reconcile queue/state with source before restart; do not blindly replace current state with a stale source copy.
3. Restore the source live Compose/env backup, keeping its original image tag and AI memory limit. Restore Business's old `AI_SERVICE_URL`. Start source AI and recreate Business, then verify internal dependencies and public health. Sessions may need re-upload here too.
4. Restore backend manifest without AI. Keep destination data/cache volumes for recovery; do not run `down -v` or prune volumes.
5. Restore the AI CI target to source before resuming deployments if the migration is abandoned. Gateway EBS remains 20 GiB; it cannot be shrunk in place. Extra internal SG rules can be removed through a reviewed Terraform plan after no migrated traffic uses them.

## Verified preparation

- Local Compose structure validation passes with `config --no-env-resolution --no-interpolate -q`; this does not validate production credentials or dependency reachability.
- Terraform validation and format check pass. Reviewed plan: 3 additions, 2 in-place changes, 0 destroys; only gateway root capacity grows.
- Cross-repository deployment race identified in review and addressed with the same host-level `flock` in AI/gateway workflows.
- Production cutover and model-cache transfer completed; actual authenticated crawl verification remains pending session re-upload.

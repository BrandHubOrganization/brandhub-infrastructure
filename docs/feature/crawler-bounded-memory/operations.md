# Bounded-memory Facebook crawler

Facebook runs use a supervisor and one disposable browser worker at a time. Feed and results are checkpointed in `<output>.crawl.sqlite3`; comments are spooled to temporary SQLite storage. Comment workers process at most 25 posts before exiting, releasing Python and Chromium memory. Feed collection is a separate phase and is not limited to 25 posts. The API and scheduler remain running.

Defaults (see AI-service `.env.example`):

- `CRAWLER_ISOLATED_BATCHES=true`
- `CRAWLER_BATCH_SIZE=25` (1–100)
- `CRAWLER_RAM_SOFT_PERCENT=75`
- `CRAWLER_RAM_HARD_PERCENT=85`
- `CRAWLER_WORKER_TIMEOUT_SECONDS=900`
- `CRAWLER_BLOCK_MEDIA=true` blocks main-page image/video/font downloads.

Thresholds use total container cgroup memory where available, otherwise total host usage. They are cooperative guards, not a reservation or guarantee against sudden OOM. At soft pressure the worker checkpoints and exits. Hard pressure cancels work; the supervisor terminates an unresponsive owned process tree after 10 seconds. No-progress attempts stop after three retries with partial results preserved. An unrelated workload keeping memory above the soft threshold prevents further workers from starting.

Keep output/checkpoint files on a disk-backed persistent volume. Do not move SQLite output to `/dev/shm`; it counts against container RAM. Temporary comment spools are removed on normal exit; abrupt OS/container kills can leave `.crawl-comments-*` directories. Remove orphan spools only after confirming no active worker owns them. Preserve checkpoints for runs that may resume; apply the existing retention policy to completed runs.

Restarting the same output/run identity resumes its checkpoint without duplicate post IDs. Starting a new run ID starts independent work. Existing comment limits and late high-like comment ranking remain unchanged. Native JSON-array publishing reads batches of 25; the legacy object-envelope input retains its compatibility reader.

## Validation before deployment

Local tests cover 250 synthetic posts, separate child PIDs, crash recovery, orphan cleanup, memory-pressure cancellation, and bounded export allocation (20 MB output, under 4 MB Python peak allocation). These are not live Chromium/Facebook RSS measurements.

On a test server, run 50 → 150 → 300 posts with one crawl at a time. Record container `memory.current`/`memory.max`, host available memory, OOM events, worker exit codes, completed/pending counts, and peak Chromium RSS. Verify worker PIDs disappear after every batch and results have no duplicate/missing IDs. The feed phase still navigates Facebook's scrolling page: if its DOM cannot fit, partial feed is checkpointed and bounded retries eventually fail visibly; a durable Facebook pagination cursor is not implemented. Do not report such a run as complete.

No container limit was increased. `crawler-management.compose.yaml` specifies 4608m, while `backend.compose.json` specifies 5g; inspect the actual deployed container before sizing memory. Increasing RAM alone does not correct accumulation. Rollback switch: `CRAWLER_ISOLATED_BATCHES=false` restores the legacy in-process path and its previous memory risks.

Production update (2026-11-05): deployed and verified; see deployment-2026-11-05.md. Docker init is required to reap orphan Chromium processes; both production backend Compose and the crawler overlay now enable it. A real-browser 26-post synthetic smoke passed, including zombie cleanup; actual Facebook scale validation remains pending.

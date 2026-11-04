# Full configured Facebook run — 2026-11-03

Status: **INTERRUPTED** at source 4/26 around 18:14 Asia/Saigon. This is a partial capacity test, not a successful run across all configured sources.

## Terminal result

- Native API run status: `INTERRUPTED`, stage `INTERRUPTED`, error `CRAWLER_PROCESS_INTERRUPTED`; observed duration 2186 seconds (~36.4 minutes).
- Completed three sources: `yeah1tv`, `beatvn.network`, `theanh28`, 25 posts each (75 posts delivered). Three of three observed worker batches finished.
- Source 4, `K14vn`, has 21 posts in its partial local output. These are separate from the 75 posts in completed-source manifests. Remaining 22 configured sources were not started.
- A stop-request flag exists for this exact run. Native parent process is no longer alive; only the singleton scheduler remains among native runner processes. The on-disk run record is stale (`RUNNING`, no exit code/finished time), so the API correctly derives interruption from process liveness. The actor/reason that created the stop request is not established by this observation.
- No observer `stop_requested` RAM/time guard event was recorded: highest sampled AI usage was below 4500 MiB, host availability stayed above 1024 MiB, and elapsed time was below four hours. Do not attribute this interruption to the RAM guard or OOM.
- Run-level `databaseSaved=false`, `liveUpdated=false`, `resolutionStatus=pending`. Finished worker batches do not prove that final aggregation/live publication completed; the run closure was interrupted.

| Final measurement | Result |
| --- | --- |
| AI cgroup high-water mark | 4379.6 MiB (~4.28 GiB) / 5 GiB |
| Maximum five-second sampled memory.current | 4285.4 MiB (~4.18 GiB) |
| Minimum gateway MemAvailable | 2509.3 MiB (~2.45 GiB) |
| Minimum service MemAvailable | 5648.7 MiB (~5.52 GiB) |
| AI OOM / OOM kill / restart count | 0 / 0 / 0 |
| Last post-run AI usage | 2283.2 MiB (~2.23 GiB), including resident worker/model state |
| Collected samples | 438 target, 456 source |

Both observer SSM commands ended successfully; source stop flag was issued after the target observer detected the terminal run state. No new crawl was started and no application/container was restarted. Kernel OOM diagnostics for 18:10–18:16 Asia/Saigon returned no OOM/killed-process events. AI container remains healthy with its original start time and zero restarts. Public HTTPS health was 200/UP, Business validation 400, protected unauthenticated endpoint 401 after interruption.

Full raw, secret-free observations are retained locally at `D:/capstone/brandhub/.audit/full-facebook-results.json`; partial crawler output and registry artifacts remain on the gateway for recovery. The heartbeat is deleted after this terminal report, rather than continuing to poll an ended run.

User requested Facebook testing against all previously configured pages after small browser tests succeeded. Native production run ID: `e683fda78a474675b854fdfc8bcde308`, pipeline started around 17:38 Asia/Saigon. Source configuration revision 1 has 26 sources (24 pages, 2 groups), with `maxPostsPerSource=25`. Only Facebook is selected. `test=false`: native RabbitMQ/worker processing and live-result publication are enabled. No schedule, source list, application image or resource limit was changed for this run.

## Progress snapshot at about 17:51 Asia/Saigon

- Completed `yeah1tv`: 25 posts, 559 comments. First worker batch finished (1/1 observed at this snapshot).
- Collecting source 2/26, `beatvn.network`; 11 posts written incrementally and latest comment milestone 10/25.
- AI cgroup high-water mark 3321.0 MiB (~3.24 GiB) out of its 5 GiB hard limit; latest usage 2994.2 MiB.
- Lowest observed gateway MemAvailable so far: 3392.3 MiB (~3.31 GiB).
- AI OOM, OOM kills and restart count remained zero.
- Public HTTPS health 200/UP, Business validation 400 and protected unauthenticated endpoint 401 verified during the run.

## Observation and stop conditions

Target and service host RAM sampled every five seconds by independent SSM observer commands. Target JSONL includes AI cgroup current/high-water memory, anonymous/file usage, host available RAM, OOM/restarts and native pipeline progress. Observers were reattached in append mode without touching the active native crawler, to allow enough time for the full source list.

Controller requests a graceful stop if AI memory.current exceeds 4500 MiB, gateway MemAvailable drops below 1024 MiB, or elapsed run time exceeds four hours. Four hours is an observation/test guard, not a completion estimate. It records a separate event if the run fails to stop within 90 seconds. Actual crawler/worker work remains under the existing API/container lifecycle.

Session-local helpers and state:

- `.audit/full-facebook-state.json`: current SSM observer IDs.
- `.audit/run-full-facebook-observation.py status`: compact, secret-free progress and RAM.
- `.audit/run-full-facebook-observation.py collect`: collect completed observations in bounded chunks, after writers stop.
- Remote observation directory on both hosts: `/tmp/brandhub-full-facebook-20261103`.
- `.audit/full-facebook-heartbeat.json`: follow-up automation ID.

The thread heartbeat checked this same run every five minutes and stayed quiet during ordinary progress. It did not launch a duplicate crawl or restart AI (sessions are RAM-only). It was removed after the terminal report. Historical progress snapshots below/above do not establish success across all 26 sources; use the terminal result in this document.

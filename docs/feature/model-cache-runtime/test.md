# Test plan and results â€” 2026-11-15

- Focused volume/persistence suite after final edits: 26 passed. Includes valid HF snapshot links, unsafe external paths, retained model files, and failed aggregation retry without false publication.
- Crawler and worker suites: 279 passed.
- Full AI unit suite: 1,163 passed, 8 failed. One failure is missing google.auth; seven real video-render tests fail because ffmpeg is not installed/on PATH in the local test environment. Video code/tests are unchanged in this diff. This is not a fully green CI result.
- Modified Python source and tests: flake8 correctness checks passed. Workflow YAML parses successfully; git diff --check passed.
- Local Linux Docker test: isolated named volume, network disabled, existing appuser image, updated initializer mounted read-only. Root initializer followed by non-root cache probe passed; retained blob fixture and HF snapshot symlink remain readable. Read-only cache mount correctly fails preflight. Test volume removed.
- No actual E5 model download or full rebuilt-image smoke test performed. No AWS, shared DB, provider API, production deploy or DLQ replay performed.
- neo4j_trend_service.py and embedding_service.py are unchanged from HEAD. No fake/zero embeddings, altered vector dimensions or false completion fallback.
- Remaining resolver service/job references in app/scripts/tests: none. Compatibility responses report FEATURE_REMOVED; existing pipeline no longer waits for that job.

## Recovery boundary
The supplied incident is consistent with run_closed finalization exhausting retries on E5 cache permissions. Graph upsert precedes embeddings, so partial graph writes may already exist; publication flags do not prove an empty database. Production ownership/mounts have not been inspected in this task.
After an approved deployment, verify the actual runtime cache and model load. Before retrying only this run_closed event, confirm its manifest/run identity, all saved batch-feature checkpoints, completion markers and DLQ entry. If checkpoints remain intact, finalization can reuse them without recrawling. Do not replay unrelated DLQ messages, manually force publication flags or claim the production run recovered from local tests.

## Develop integration acceptance
AI must import without bundled crawlfb modules, forward crawler controls over HTTP, retain successful/failed publication guards, and never invoke removed entity resolution. Existing scoped init/probe tests use separate AI state/cache roots. Preserve develop deployment target/3g limit and verify cache env/init/probe ordering. Re-run regressions and isolated Docker checks; no production operations.


### Develop integration results — 2026-11-15
- All 14 merge conflicts resolved: develop crawler split, HTTP proxy boundary, Service EC2 deployment and 3g limit preserved. Removed crawler modules remain deleted. AI-specific scripts/prepare_ai_volume.py replaces the old crawler initializer.
- Existing ai-model-cache mount (/home/appuser/.cache) retained; HF_HOME/HF_HUB_CACHE/SENTENCE_TRANSFORMERS_HOME now point there. Root prep touches only AI checkpoints and AI cache, followed by appuser write probe. No crawler state/output initialization in AI.
- Full AI unit + worker integration regression: 1,155 passed, 8 failed (same missing google.auth/ffmpeg local environment failures). No new failures in the affected pipeline/cache boundary. After final test assertions: focused cache/HTTP/persistence/worker suite 49 passed. Full flake8 app/scripts/tests-unit passed.
- Workflow YAML parsed; rendered Compose updater executed on a temporary fixture: deployment target, 3g, crawler URL, other environment, volume declarations and other services retained.
- Linux Docker isolated smoke using existing image and mounted new initializer: two QA volumes, no network; root prep + non-root cache/checkpoint writes passed, model blob/snapshot link preserved; read-only cache rejected. QA volumes removed.
- Compared with origin/develop: Neo4j upsert, embedding algorithm, crawler client and proxy routes unchanged. No obsolete resolver/moved-controller imports remain in app/scripts/tests.
- New crawler repo is not present in this checkout. Its implementation/scheduler was not modified or tested here; develop moved-module deletions were respected. AI legacy CronTrigger retains its existing Vietnam timezone.
- No full rebuilt-image/model-download smoke, remote CI, AWS deploy or production DLQ replay. Old social_crawler private runtime leftovers are locally excluded via .git/info/exclude, never staged.

# Test plan and results — 2026-11-15

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

# Plan
1. Broaden removal audit to scripts and fix obsolete resolver reference in live QA harness.
2. Set HF_HOME=/app/data/crawler/model_cache/huggingface and HF_HUB_CACHE=SENTENCE_TRANSFORMERS_HOME=$HF_HOME/hub in Dockerfile; create/chown cache as image appuser.
3. Extend scripts/prepare_crawler_volume.py with scoped cache folders and a --check non-root write/read/delete temporary probe. Paths outside allowed base are rejected; do not relax symlink/hardlink guards.
4. Update local workflow source to set same env in Compose and prepare then check as runtime user before up. No workflow execution/push authorized. Runtime remains non-root.
5. Add tests to existing tracked volume unit tests. Validate Linux permissions on an isolated Docker volume using existing local image; do not require model download or live credentials.
6. Run unit/crawler regressions + lint. Recovery procedure after approved deploy: verify cache as actual runtime user, load E5, retain run feature checkpoints, requeue only run_closed event corresponding to failed run after verifying no completed-event marker/newer publication conflict. All AWS/DLQ actions need separate user approval.

## Service split adaptation
1. Accept develop deletions for moved crawler modules; retain AI aggregation/upsert and resolver removal.
2. Replace crawler initializer with AI-only volume initializer; keep /app/data/crawler/trend_runs and separate /home/appuser/.cache scope. Keep security validation and valid HF blob links.
3. Use develop Dockerfile/workflow with cache environment, scoped root init and non-root probe added. Preserve deployment destination, memory limit and crawler HTTP boundary.
4. Align existing tests to the split; run full AI unit/worker regressions, lint, isolated Docker permissions and verify no stale imports. Do not modify the new crawler repo without inspecting it and explicit scope.

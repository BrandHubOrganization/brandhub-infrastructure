# Plan
1. Broaden removal audit to scripts and fix obsolete resolver reference in live QA harness.
2. Set HF_HOME=/app/data/crawler/model_cache/huggingface and HF_HUB_CACHE=SENTENCE_TRANSFORMERS_HOME=$HF_HOME/hub in Dockerfile; create/chown cache as image appuser.
3. Extend scripts/prepare_crawler_volume.py with scoped cache folders and a --check non-root write/read/delete temporary probe. Paths outside allowed base are rejected; do not relax symlink/hardlink guards.
4. Update local workflow source to set same env in Compose and prepare then check as runtime user before up. No workflow execution/push authorized. Runtime remains non-root.
5. Add tests to existing tracked volume unit tests. Validate Linux permissions on an isolated Docker volume using existing local image; do not require model download or live credentials.
6. Run unit/crawler regressions + lint. Recovery procedure after approved deploy: verify cache as actual runtime user, load E5, retain run feature checkpoints, requeue only run_closed event corresponding to failed run after verifying no completed-event marker/newer publication conflict. All AWS/DLQ actions need separate user approval.

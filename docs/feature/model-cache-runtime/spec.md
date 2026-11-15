# Model cache runtime — 2026-11-15
Scope: fix non-root runtime cache permissions locally; no AWS access/deploy/requeue.
Failure supplied by user: run 1c7daaa06e774488b9f762c14a302a95 completed crawl/batches but finalization failed loading E5 at /home/appuser/.cache/huggingface.
Model used for Chroma persistence is independent of removed entity-resolution job.
AC: image defines writable persistent model-cache locations before importing HF libraries; existing volume initializer prepares only its allowed base; non-root write probe precedes deployment start; preserve configured explicit local behavior outside Docker.
AC: do not fake embeddings, mark failed aggregation successful, replay all DLQ or recrawl automatically. No changes to model, prompts, dimensions, vector collection or keys. Keep cache across restarts and no chmod777/root application.
No UI changes. No DB schema changes or old-data repair. Actual production ownership/mounts remain unverified without permission.

## Adaptation to develop service split — 2026-11-15
Use develop as the architecture source of truth: keep crawler HTTP proxy, dedicated crawl deployment and Service EC2 AI limit 3g. Do not restore removed crawler controllers, scripts or bundled social_crawler code in AI. Keep removal of entity-resolution and unchanged graph upsert/embedding algorithms.
Use develop's existing ai-model-cache volume at /home/appuser/.cache rather than creating a second cache below crawler data. Define HF cache environment before import, prepare AI-owned checkpoint and cache volumes via an AI-specific initializer, then probe as runtime appuser before deployment. No AWS execution or data migration in this task.

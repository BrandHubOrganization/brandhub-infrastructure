# Verification
Compare retained dotenv values and Settings model fields before/after; only intentionally removed unused rag_top_k/embedding_model fields may return defaults. Preserve effective Gemini value from last definition. Verify all retained names have a consumer or SDK/launcher rationale, no malformed assignments and .env remains git ignored.

Completed 2026-10-27: removed 19 unused/ignored/Compose-only names and one duplicate GEMINI_API_KEY assignment; retained 51 unique variables grouped by purpose. dotenv parser validation passed, retained values unchanged, Settings load/effective-value comparison passed. No temporary secret backups created. .env remains ignored by Git.

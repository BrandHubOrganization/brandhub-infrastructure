1. Add SQLite feed/result store with streaming legacy JSON import and atomic output export; test resume/upsert and bounded Python allocations above100 posts.
2. Add memory policy/sampler and isolated worker supervisor. Refactor crawl session to accept a disk-backed feed sink, bounded pending batch and memory checks; retain legacy session retry tests behind explicit rollback mode.
3. Spool paginated comments on disk and select top-N after pagination; clear bounded per-post interception caches. Add worker session stdin restoration without logging credentials.
4. Wire default CLI run to isolated supervisor, add documented batch/pressure controls and leave deploy memory limits unchanged.
5. Run full crawler tests and affected AI-service tests plus synthetic multi-process >100-post/resume/pressure tests. Record no real Facebook or production OOM trial unless separately run.

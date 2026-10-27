# Plan

1. Add bounded S3 manifest discovery/read module and request validation. Pin ETags,
   deterministic key dates and object sizes. Paginate listing; never arbitrary bucket.
2. Extend trend_run_store with optional root argument, preserving live defaults.
   Route replay through TrendService with separate history root and unchanged
   processing/persistence, then CrawlRunService finalization. Add historical daily
   snapshot support without changing normal live defaults.
3. Redis job store + leased async runner: start previewed job, sequential files/day,
   checkpoints, immutable source reads, safe failure and explicit resume.
4. AI internal /api/v1/ai/trends/replays preview/create/list/detail/resume routes.
5. Business Admin proxy controller/service + validated DTO, guarded authorization.
6. Feature-scoped Web service/types/hook/panels; Admin view/navigation and parallel
   src/i18n/locales/{vi,en}/admin.json keys; no new dependency/framework.
7. Isolated fake S3/Redis/pipeline checks and browser API-mocked fixture under
   keep-local-only; existing regressions, TypeScript/lint/build/Java compile.
8. Scoped old-trend preflight and cleanup only after user confirms stopped writers.
9. Read-only runtime preflight inside the leased async runner, before file work:
   Neo4j/APOC, Chroma heartbeat and MiniLM vector sanity. Import/model/network
   failures surface safe codes; no zero-vector or mock fallback. Restore missing
   dependencies from requirements, verify import compatibility, resume the existing
   job only when all checks pass. Do not reset checkpoints or replace the NLP model.

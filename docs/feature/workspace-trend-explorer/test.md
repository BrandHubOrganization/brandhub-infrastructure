# Workspace Trend Explorer — verification
Depends on spec.md, plan.md and task.md.
- Nonempty Redis cache; published-empty does not hit graph; missing/error/timeout falls back; explicit date bypasses cache.
- Cursor changed filters/source, malformed/oversized rejected. limit<=50, stable date/id seek, no graph-wide grouping/deep SKIP, transaction and request timeout.
- History<=90 days, cap2000/truncation, exact normalized keyword; unknown counts/days null. Multiple rows/day select deterministic latest. Invalid dates/keyword rejected.
- Tenant graph/source nodes excluded; DTOs whitelist fields. Never production mock fallback. Active Workspace membership checked before AI call; unauthorized denied. Existing Admin/global/caption behavior retained.
- Skeleton list/history, error/empty/retry/freshness, vi/en and light/dark keyboard375/768/1440. No per-row requests or stale overwrite.
- New QA only ignored keep-local-only, no src tests. Run meaningful Python/Java and npm run ci. Offline PROFILE/scale benchmarking required before scale guarantee. No live APPLY, paid provider or new crawl for testing.

## Execution 2026-11-01
- Reader + existing Neo4j regression suite: 14 passed (8 new isolated cases, 6 existing regressions) (cache empty/miss/error, explicit date, cursors, bounds, null metrics, history/source cap/predicate, normalization).
- Java compile and Mockito smoke passed: active membership before AI, outsider makes no AI call, Unicode/ampersand URI encoding preserved.
- Read-only live smoke: current returns Redis; selected2026-11-01 returns Neo4j; adjacent graph pages disjoint; 7-day history returns7 points and public links; injected cache timeout falls back to Neo4j.
- Browser mocked API: lazy history (one list + one history request), skeleton, null values, charts, vi/en, light/dark375/768/1440 passed. Screenshots kept ignored local only. No provider/mutation requests.
- Web npm run ci passed: lint0 errors (185 repo warnings), type-check and production build; existing bundle-size warning remains. Local QA directory excluded from ESLint to prevent traversing temporary artifacts.
- No live data migration/backfill/index APPLY or deliberate user-service restart. Optional index definitions supplied; existing graph rows missing new scalar fields return null. No production-scale benchmark claimed. Earlier pre-existing uncommitted changes preserved.
- Runtime reload/restart of Business is required to register the new controller; coordinate only after active jobs are finished. AI dev reload may already pick up routes. Prefer explicit service reload only with no active workloads.

Ranking: shuffled input sorted high score first; equal scores paginate by deterministic ID without repeats. Existing AI Studio renders one row per trend and Rising topics below. Top3 differentiated in both themes; keyboard detail/copy retained. No query/index APPLY during UI work.

Ranking verification:9 isolated reader tests passed including equal-score cursor; read-only Neo4j score descending/disjoint pages passed. Browser row layout, source chart below, vi/en light/dark375/1440 passed. Web CI passed. Fixed pre-existing screen-reader table overflow exposed by relocating the chart. QA artifacts remain ignored.

Weekly regression: rank1 has daily31/weekly100, rank2 daily45/weekly90; response scores100/90, topic total190, rank1 remains above rank2. Daily without weekly score retains31/45. Check no DB/provider calls, compile and Web CI.

Weekly backend regression passed: rank1 daily31/weekly100 and rank2 daily45/weekly90 map to100/90; topic total190. Daily remains31/45 and76 total. Business compile passed. Test harness remains ignored local only.

Weekly frontend validation: targeted ESLint for trends.tsx passed. Full-repo CI was intentionally stopped during the long lint phase; no fresh full-CI pass is claimed for this comparator-only follow-up. Previous row-layout CI passed before this follow-up.

# Test plan
Business: upstream 503/timeout propagates, malformed/null payload rejected, real [] remains [], no generated keywords, existing ranking/topic/platform/posts mapping preserved. Reuse AiTrendControllerTest only.
Web: zero/one history points -> noGrowth, two observed points -> real SVG; no sourceSum-based synthetic trend, zero observed count remains valid. Reuse existing UI/unit tooling; no new tests in src. Existing error/empty/loading handling retained. npm run ci required before any commit.
AI: Google/TikTok legacy strategies cannot produce fabricated posts; unavailable reaches route as 503, no normalization/publication called. Missing internal replay file fails, real file reads unchanged. Workspace/admin reads reject fake DB driver; cache errors do not fall back to mock; S3 boards retain real snapshot path. Existing tests used for regressions; no shared DB writes or real crawler/provider API calls.
Results — 2026-11-15:
- Business focused Maven suite: 14 passed (10 AiTrendController + 4 AdminTrendGraphService), BUILD SUCCESS. Existing genuine empty/mapping/filtering tests retained; new upstream/malformed/optional metadata tests passed. JaCoCo emitted old execution-data mismatch warnings; no pom changes.
- Web npm run ci passed (lint/type-check/production build/prerender). Five isolated server-render QA checks passed: absent series/source-only/one daily/one growth do not create SVG, real two-point series including zero render. QA test was temporarily placed outside src and removed; ignored source artifact retained locally only.
- An initial QA config accidentally merged the broader existing Web unit suite: 137 passed, 1 failed in tests/unit/materialUpload.test.ts (Office MIME policy expected 0, actual 26214400). Repository upload source/tests untouched. This is separate from successful npm run ci and the focused five trend render cases; do not report all Web unit tests green.
- AI first focused regression: 41 passed (persistence, Neo4j, boards, scheduler); after adding S3 guard, final persistence/board regression: 21 passed. Counts overlap and must not be summed. Flake8 app + changed tests passed.
- Local HTTP probes of 127.0.0.1:8082 Redis-live/summary returned URLError (service unreachable). No assertion of actual running DB contents or production behavior. No S3/AWS/live crawl/model calls, writes to shared DB, deploy/restart or data cleanup performed.
- Generated build artifacts restored to pre-check state. Only existing tracked test files modified in source repos; no new test files staged/committed. No commit/push performed.


Board test: MockS3Client -> explicit unavailable, never an empty/successful board; injected fixture client continues validating real payload mapping without network. Local AI HTTP probes must report connection failure honestly, not claim DB verification.

## Audited read paths
- Global Trends: src/services/trendService.ts -> Business AiTrendController -> AI /api/v1/ai/trends -> TrendSnapshotCache (Redis v2).
- Workspace list/history: workspace-trends/services/trends.ts -> WorkspaceTrendService -> AI WorkspaceTrendExplorer. Current list reads Redis, valid fallback reads durable Neo4j; history reads Neo4j. Graph reads reject MockNeo4jDriver and return unavailable.
- Admin trend list: trendViewService -> AdminTrendService -> AI Redis or explicit /neo4j. Admin graph search/neighborhood/expand -> TrendGraphService read transactions against Neo4j, no mock-driver fallback.
- Google/TikTok boards: fetchTrendBoard -> Business board proxy -> AI trend_boards.latest -> real S3 snapshot; MockS3Client rejected with API 503. Legitimate observed sample_posts, sums/differences of observations, graph layout fallback and loading skeletons are not fabricated records.
- Existing DB content is not proven free from historic seeded/sample records by code audit; cleaning or classifying existing records is outside scope and was not performed.

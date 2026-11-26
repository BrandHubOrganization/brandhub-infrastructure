# Trend views: real data only — 2026-11-15
Objective: user-facing trend views must use stored pipeline results, never replace upstream failures with fabricated trends or growth points.
Scope: global Trends (Business /ai/trending-topics -> AI Redis v2), workspace explore/history (Redis/Neo4j), Admin trends/graph (Redis/Neo4j), Google/TikTok boards (real S3 snapshots). No schema/data cleanup or production AWS access.
AC: Business propagates AI failure, rejects malformed list response, preserves genuine empty lists, filters/ranking/source posts. Remove hardcoded fallbackTrends. Preserve optional crawl-summary failure as null; it must not fabricate data or hide real trends.
AC: sparkline draws only observed growth/dailyCounts with >=2 points. Missing/single observations show existing translated detail.noGrowth text; no generated zero-day or guessed source-count history. Keep theme tokens and layout; no new translations needed (existing vi/en key).
AC: legacy Google/TikTok mock strategies no longer return synthetic RawPostItem records. They explicitly report unavailable via old crawl route; the separate crawler service/boards pipeline remains unchanged. Missing explicit local replay input must fail instead of generating sample posts. Do not delete test mocks or legitimate observed sample_posts excerpts.
No deployment, restart, live crawl, paid API calls, production data mutation, commit or push in this task. Real DB content may contain old samples; do not clean data automatically.

Additional AC: trend boards must reject MockS3Client rather than treating a development in-memory store as a real snapshot. Scope this guard to trend boards, preserving unrelated S3 consumers.

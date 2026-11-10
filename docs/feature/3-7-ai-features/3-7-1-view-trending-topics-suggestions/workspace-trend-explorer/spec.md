# Workspace Trend Explorer — specification
Updated 2026-11-01. Implementation authorized. Supersedes the earlier projection-first design.

## Confirmed BA
Workspace members view public trends. Current view reads Redis first; errors or missing snapshot fall back to Neo4j. Explicit historical date and selected-topic history read Neo4j directly. Published-empty Redis is valid empty data. Preserve old Admin/AI Studio endpoints and caption daily trend IDs.
Initial UI: current or single historical day, paginated list, selected topic history7/30/90 days, score and observed-post charts and public source links. Conservative exact normalized keyword grouping, no semantic auto-merge. No new topic/projection nodes or alias-writing UI this release.

## Acceptance and API
Business GET /api/v1/workspaces/{workspaceId}/trends and /history. Internal AI /api/v1/ai/trends/explore and /explore/history. Active Workspace authorization before proxy. Public graph only, scalar whitelisted output, never private entity/brand properties.
Default20/max50 rows, bounded signed cursor, q<=100; historical window<=90 days, result cap2000 with truncation. Cursor binds source/date/search/asOf; pagination is best-effort under concurrent writes, not snapshot isolation. No global aggregation/deep SKIP or N+1.
Missing count/day is null, not zero. Score is pipeline-window metric. Legacy graph completeness/scope can be unknown; label it. Redis failure/miss fallback is bounded and source visible. Both unavailable -> explicit error, no fake data.
Skeleton for initial list and selected details. Empty/error/retry/freshness/truncation states. URL filters, keyboard, responsive375/768/1440, semantic light/dark. All copy uses parallel aiStudio.workspaceTrends keys in vi/en.
No automatic live migration, paid AI/crawl, restart or data cleanup. Done requires isolated backend/auth tests, Web CI/browser checks and documented query/index limitations.

UI refinement: move Rising topics below the ranked list on the existing AI Studio page; one trend per row, highlighted top3 rank badges. Workspace list also exposes rank. Sort by score descending and stable ID descending; paginate with the same tuple.

Weekly ranking correction: displayed score and ranking must use the same period. Weekly uses weekly_final_score, live/daily use final_score. Preserve AI ranks, including gaps under filters; do not renumber only the visible subset.

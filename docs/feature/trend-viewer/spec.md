# Trend viewer

## Objective and scope

Admin can inspect published trend snapshots after live crawling or daily S3 replay,
without invoking models or graph writes. Reuse the existing AI Redis read APIs.
Do not replace another member's AI Studio/mock screens or modify scoring/publish.

## Acceptance criteria / UI states

- Admin menu and deep link `/admin?view=trends`; navigation to Neo4j Graph.
  S3 replay navigation is integrated by the separate replay feature.
- Select live (`6h`), a historical day (`24h`) or trailing seven days (`7d`), target
  date, and maximum returned candidates (20/50/100). Date is disabled for live.
- Search keyword/related keywords and filter topic locally within the returned
  bounded result set. Scores remain pipeline values, never labeled percentages.
- Show rank, topic/status, score, component scores, momentum and source post links
  when present. Disclose detail inline; only http(s) source URLs are clickable.
- Summary describes the latest published snapshot globally, not the selected
  date's run or Neo4j health. Missing summary must not hide a successful list.
- Distinguish loading, no published data, no filter matches and request failures;
  include retry and replay recovery link. No mock fallback, no forced reset.
- Filters use URL query parameters for back/refresh and links from replay days.
- All UI labels under `admin.trends` and `admin.navigation.trends` in both
  `src/i18n/locales/{vi,en}/admin.json`; preserve BrandHub theme tokens in light/dark,
  labeled inputs, visible keyboard focus and responsive 375/768/1440 layout.

## API contract

- Existing AI GET `/api/v1/ai/trends?period=24h&date=2026-10-08&limit=20` (raw array).
- Existing AI GET `/api/v1/ai/trends/summary` (global latest published status).
- Existing Business GET `/api/v1/ai/trending-topics` is a mapped current-date view;
  leave its contract unchanged.
- New Business Admin GET `/api/v1/admin/ai/trends` accepts `period`, optional ISO
  `date`, `limit` and returns the unchanged candidate array in ApiResponse.
- New Admin GET `/api/v1/admin/ai/trends/summary` returns AI summary in ApiResponse.
- Every new endpoint requires an active Admin before upstream reads; validate
  period/date/limit. Errors remain structured; no AI internal key in browser.

## Out of scope / definition of done

The current viewer also exposes the existing guarded crawl APIs through a
confirmation action and crawl-history drawer. Its frontend dependencies are
CrawlRunsDrawer and crawlConfigService; no crawler/pipeline backend is introduced
by this change. New labels use admin.crawlRuns/admin.crawl/admin.trendVisuals in
the parallel vi/en Admin locale files. S3 replay implementation is committed
separately from this viewer/graph scope.

No migration, seed, deletion, background crawl/replay execution, AI generation,
new DB storage, charts inventing missing history, commit or push. Done when Java
compile/local isolated checks and frontend build/lint/browser cases pass. Real
published data may remain absent until the blocked replay successfully resumes.

# Admin trend source configuration

## Objective and user story
Admin can change the Facebook page/group list and maximum posts per source used
by the bundled trend pipeline, without editing files or changing its downstream flow.

## Acceptance criteria
- Manage pages and groups together, one public Facebook source URL per line.
- Retain the current page/group list and FB_MAX_POSTS (default 50) until first save.
- Accept 1–50 distinct sources and 1–1000 posts per source; these are technical
  bounds, not a promise that Facebook returns that many posts. Show the maximum
  possible run total (source count × posts per source).
- Manual and scheduled runs use the same durable configuration. Freeze a snapshot
  for each new run; saving while running only affects later runs. Recovery retains
  the original saved files and never uses new sources or triggers a new crawl.
- Admin-only read/update, internal-key protected AI routes, successful-update audit.
- Reject malformed/non-Facebook/post URLs, duplicate identities, empty lists and
  stale revisions. Never fall back to crawling all defaults after invalid saved data.
- Preserve cron, legacy ScrapeCreators/Apify configuration, worker stages and storage.

## UI/UX and states
Compact expandable configuration within Admin > Trends > Trend pipeline. Direct
URL textarea, numeric limit and save/cancel. Saving does not run a pipeline. Keep
unsaved input during status polling; show loading, error, stale-revision, pending
and saved states. No native alerts. Keyboard labels and narrow-screen wrapping.
All new strings use admin.trendSourceConfig.* in both vi/en admin.json files.
Use existing semantic theme tokens and verify light/dark mode; no new palette.

## API contract
GET /api/v1/admin/ai/trend-pipeline/source-config returns
{revision, sourceUrls, maxPostsPerSource}; PATCH accepts the same object with the
revision last read. Internal GET/POST use /api/v1/ai/trends/pipeline/source-config.
400 invalid settings, 409 stale revision, 503 unavailable configuration store.
No cookies, credentials, filesystem paths or shell commands in requests/responses.

## Definition of done / out of scope
Verified shared snapshots, concurrent updates, admin guards and mocked UI flows.
No live crawl/paid AI for QA. No DB migration/init/seeder changes, subscription,
Facebook login UI, schedule editing, per-source heterogeneous limits or total-run cap.

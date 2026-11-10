# Verification plan

- Defaults retain all existing page/group sources and 50 posts (or valid env override).
- Canonicalize facebook.com/www/m hosts, trailing slash and profile.php?id numeric.
  Reject non-HTTPS, credentials/ports, arbitrary subdomains, posts/videos/share URLs,
  encoded traversal, unsafe IDs, duplicates (including aliases), empty and >50 lists,
  boolean/fraction/out-of-range limits, invalid and stale revisions.
- Simultaneous writes with same revision: one succeeds, one conflicts. Atomic file
  replacement never yields partial JSON. Corrupt saved settings block, no default fallback.
- Manual start freezes settings before subprocess; schedule/default wrapper uses
  same store. Saving next config cannot change current snapshot. CLI explicit
  source/max flags remain honored. Recovery receives no new source config.
- Manifest retains source count, snapshot revision and max posts; downstream queue,
  batch, closure, aggregation, graph/vector writes and cron are unchanged.
- API internal auth and Business Admin guard reject before store/upstream access;
  invalid DTO, stale revision and unavailable storage are safe 400/409/503, successful
  save audited once. No secrets or filesystem paths returned.
- Mocked browser: expand, direct edit/save/cancel, numeric validation, dirty input
  survives polling, double-save prevented, 409 explicit reload, loading/503 retry,
  saved total, no start-run request, keyboard labels, vi/en/light/dark and 375px.
- Native pipeline/recovery regressions; Business compile; Web lint/build.
  No live setting write, crawl, paid AI, database migration or seed during QA.

## Results — 2026-10-30

- 38 source-config checks passed: defaults (10 shipped pages + 1 group), env,
  aliases, malformed URLs, duplicate identities/output names, bounds, revision
  races, atomic replacement, corrupt-store refusal, snapshot immutability,
  explicit CLI overrides, scheduled wrapper/manual argv and untouched recovery.
  FastAPI tests verified internal auth and safe 400/409/503 with temporary files.
- 36 existing native pipeline/recovery regression checks passed. Dummy runner
  fixture now includes source defaults; real Facebook/browser/provider never invoked.
- Business compile passed. Mockito smoke verified requireAdmin before upstream,
  payload, successful save audit, validation and structured 400/409/503 mapping;
  existing recovery smoke also passed. No DB connection or real audit writes.
- Web npm run ci passed (existing repository warnings remain); changed component,
  hook, service and type lint passed. Mocked real browser passed source editing,
  totals, inline bounds, keyboard save, pending/double-click protection, dirty
  input retained through pipeline refresh/collapse, 409 explicit reload, GET/PATCH
  503, undo and vi/en/light/dark at 375/768/1440px. Screenshots inspected; explicit
  foreground classes fix shared native field/ghost-button dark-mode inheritance.
  Expected mock error responses only, no page exceptions or horizontal overflow.
- All executable QA/screenshots/logs remain ignored in keep-local-only. The actual
  deployment's source list, max posts, schedule and business DBs were not changed.

## Rollout and manual check

1. Restart Business and AI Service, and restart the crawler scheduler if used.
   Do not start the scheduler merely to test the settings UI: it can trigger crawling.
2. Admin > Trends > Trend pipeline > Nguồn crawl và số bài. Current defaults show
   the existing 11 sources and 50 posts/source unless FB_MAX_POSTS overrides it.
   Edit URLs/limit and save; this alone does not launch a crawl.
3. The next normal manual/scheduled run freezes settings. Check its native manifest
   source_config_revision, max_posts_per_source and planned_sources. Sources use
   the existing browser/queue/worker/DB flow. A recovery does not read new settings.
4. Durable configuration is social_crawler/keep-local-only/crawl-control/source-config.json;
   snapshots are in config-snapshots/. Preserve this runtime directory across
   redeployments and share it between API and scheduler; do not commit it or treat
   it as disposable QA. A multi-host setup needs shared storage. No migration,
   init/seeder edits, source-file rewrite or data cleanup is required.

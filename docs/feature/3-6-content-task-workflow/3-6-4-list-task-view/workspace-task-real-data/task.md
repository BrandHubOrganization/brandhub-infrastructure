# Checklist

## Demo isolation correction (2026-10-16)

- [x] Remove sample Task creation from list reads; preserve explicit dev seeder and existing data.
- [x] Add regression for empty/Untitled lists and all member roles; no Mongo writes.
- [x] Run focused Task/Campaign/Request/content-writing/Post regressions (156 unit tests). External Facebook publishing not exercised.
- [x] Rehearse existing five Request/Task migrations on isolated Mongo, apply only after clean preflight and writer freeze, verify Task fingerprints unchanged.
- [x] Handoff restart instructions; do not automatically retry deployment or publish to Facebook.

- [x] Implement scoped, filtered, paginated Task read API with safe display fields and tests.
- [x] Replace Web mock fallback; add response checks, loading/error/retry and stale-request handling.
- [x] Support five types/nine statuses; preserve real Campaign/Request links and safe Task details.
- [x] Remove fake dates/durations/locations/priorities and local-only mutations from all four views.
- [x] Keep pagination accessible across views, missing-deadline/read-only explanations.
- [x] Update parallel vi/en tasks locale and keyboard/light/dark feedback.
- [x] Run regressions, build and browser checks; record verified limits and no DB changes.

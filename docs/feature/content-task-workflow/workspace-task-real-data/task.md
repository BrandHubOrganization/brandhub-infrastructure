# Checklist

- [x] Implement scoped, filtered, paginated Task read API with safe display fields and tests.
- [x] Replace Web mock fallback; add response checks, loading/error/retry and stale-request handling.
- [x] Support five types/nine statuses; preserve real Campaign/Request links and safe Task details.
- [x] Remove fake dates/durations/locations/priorities and local-only mutations from all four views.
- [x] Keep pagination accessible across views, missing-deadline/read-only explanations.
- [x] Update parallel vi/en tasks locale and keyboard/light/dark feedback.
- [x] Run regressions, build and browser checks; record verified limits and no DB changes.

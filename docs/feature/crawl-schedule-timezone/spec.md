# Crawl schedule timezone

User request, 2026-11-22: default crawl schedules to Vietnam time and offer other timezones in a dropdown.

- Missing timezone defaults to `Asia/Ho_Chi_Minh` in pipeline settings, scheduler and readiness responses.
- Preserve an explicitly stored timezone (including UTC); changing unrelated settings must not move the schedule.
- Admin selects an IANA timezone through the shared dropdown, with Vietnam first, UTC and common alternatives. Preserve valid stored zones outside the suggested list.
- Cron represents wall-clock time in the selected timezone. Changing timezone keeps the clock/cron and explicitly changes its interpretation; no hidden UTC conversion.
- Vietnamese/English labels and help text stay parallel. Reuse BrandHub controls/theme tokens and verify keyboard, narrow screens and light/dark themes.
- Changing timezone alone is a dirty edit; an unchanged form is not dirty solely because an optional timezone default was filled.
- Saving settings invalidates the health/next-run display so it reflects saved timezone and schedule.
- No crawl execution, production configuration migration or AWS EventBridge mutation in this change. The existing external AWS schedule remains independently managed; saved settings must not imply that a stopped scheduler is running.

Complete when defaulting, explicit-zone persistence, validation, dropdown save/reset and next-run formatting are verified without a live crawl.

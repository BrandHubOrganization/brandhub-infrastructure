# Verification

- New settings or a legacy schedule without timezone returns `Asia/Ho_Chi_Minh`.
- A stored UTC, New York or valid non-preset IANA zone remains unchanged through get/save.
- Invalid, null and non-string zones are rejected before saving.
- Daily cron `0 2 * * *` fires at 02:00 in the chosen zone. Vietnam has UTC+7; UTC remains +0; DST zones use ZoneInfo rules.
- Dropdown defaults to Vietnam only when missing; exposes alternatives; saving only a zone change sends the same cron and revision.
- No edits => Save/Cancel disabled. Cancel restores the stored zone. Pending/stale states prevent saving.
- Health/next-run query is invalidated after save, then displays returned times in the saved zone.
- Vietnamese/English labels, keyboard selection, mobile width, light/dark appearance and unsupported preset fallback are checked using stub APIs; no real crawl or credential change.
- Web `npm run ci`, existing crawler scheduler tests and focused offline regression checks pass. Any pre-existing failures are reported separately.

## Local results (2026-11-22)

- Existing scheduler and management regression tests: 21 passed.
- Offline settings checks: 8 passed, including legacy fallback, explicit UTC/custom zones, invalid input without disk mutation, round-trip persistence and DST offsets.
- Browser fixture using the actual settings form: 14 checks passed, no page errors and zero live crawl requests. Covered save/cancel, clean baseline, pending, keyboard, mobile, light/dark and Vietnamese/English.
- Locale keys and timezone interpolation match; git diff whitespace checks pass.
- Web CI: lint passed (0 errors, 227 warnings); type-check passed; production build passed, including video editor build and 105 prerendered public pages.
- Optional crawler flake8 was unavailable in the existing virtualenv; no dependency was installed.
- Production configuration, AWS schedules, running crawls and existing explicitly saved timezones were not changed.

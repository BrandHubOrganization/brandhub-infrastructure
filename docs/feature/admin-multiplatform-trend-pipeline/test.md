# Verification
## Follow-up checks
Facebook appears before Threads/TikTok with no nested forms. Shared settings still save together; Facebook sources save independently. Missing Threads session blocks start with explicit remediation. Disabled automatic scheduling alone does not block manual start. QA uses mocks, not live crawling.
Browser QA and Web CI passed. Verified platform order/no nested forms, intact save payload, missing-session guard, and manual start available with schedule paused when selected platforms are ready; vi/en, light/dark, 375/768/1440px. Read-only local preflight found Facebook ready, Threads session missing and TikTok API not configured. No operational settings changed; no crawl started.
## Daily picker cases
- Existing `14 08 * * *` displays 08:14; selecting 09:30 submits `30 9 * * *`.
- Empty time blocks saving. Hours/minutes stay in valid bounds.
- Weekly/custom cron remains unchanged while editing other fields. Explicit switch requires selecting a daily time before saving.
- Check vi/en labels, light/dark shared input styling and keyboard interaction; run Web CI. No live schedule/config writes.
- Browser QA passed: 08:14 parsing, 09:30 conversion, midnight, empty input, preserved weekly cron and explicit daily switch, vi/en light/dark at mobile width. QA artifacts stay ignored; no operational settings written.
- Store: defaults preserve deployed values; valid save increments revision; stale/unknown/invalid/boolean-as-number/cron/duplicate inputs reject without writes; corrupt files fail closed; concurrent updates serialize.
- Snapshot: save during a run cannot change its settings; selected-platform and explicit CLI overrides survive; recovery skips settings snapshot.
- Wiring: scheduler reloads on settings modification; paused schedule still permits manual run; Threads/TikTok argv matches saved limits and sources without modifying tracked data.
- Preflight: disabled platform prerequisites do not block selected platforms; selected platform missing session/key fails safely; no secrets or file paths returned.
- Collection: FB/Threads/TikTok share run ID and downstream delivery; nonzero-with-posts is partial, nonzero-without-posts failed; pending platform interruption cannot report full collection success. Recovery and batch receipts remain compatible.
- API: Admin guard, internal key, 400/409/503 mapping, audit without secrets; legacy routes untouched.
- UI mocked API: load/save/invalid/stale/reload/pending/error; active run and schedule state; Vietnamese/English; keyboard; widths 375/768/1440 in light and dark; no horizontal overflow or raw translation keys.
- Run existing native collector/recovery/source tests, Java compile/proxy smoke, npm run ci. No real provider calls or production database/config writes.

## Verification result (2026-10-31)
- PASS: 115 isolated Python settings/control/source/recovery checks, including concurrent revision saves, frozen settings, platform change between preflight/dispatch, collector argv, unchanged delivery flow, live per-platform counts and reserved-source recovery without duplicate identities.
- PASS: 57 existing native multi-platform/Threads/TikTok fixture regressions.
- PASS: Business compile and 3 Java mock smoke suites (new settings, existing Facebook sources and recovery), Admin guards, intact nested payload, audit and error mapping; no DB/network.
- PASS: npm run ci (lint/type-check/build). Existing lint warnings: 189, zero errors; existing large bundle warning remains.
- PASS: browser mocked API load/save, pending lock, invalid integer, stale revision/reload, Facebook source editor, per-platform partial/failed progress; Vietnamese/English, light/dark, 375/768/1440px; no horizontal overflow or raw translation keys. Shared labels/switches/buttons retain keyboard semantics.
- Test code, mock pages, logs and screenshots remain ignored under keep-local-only. No new tracked test files. Existing untracked crawl-handover session files were not read, edited or staged.
- PASS: keyboard Space toggles platform and schedule, Enter opens the Threads section, and Tab moves through input fields in order; no API writes.
- Not performed: live crawling/provider authentication, paid AI, saving operational settings, restarting user services, database writes or migrations. These require the deployment runtime and real session/API connectivity.

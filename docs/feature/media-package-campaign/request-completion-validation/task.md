# Checklist

- [x] Add timezone-safe min/max deadline bounds and loading/error/no-interval UX to create/edit only.
- [x] Add vi/en range/state labels; verify date boundaries, timezone/day rollover and native validity (unit + browser mock).

- [x] Synchronize affected existing specs and BA decision.
- [x] Add durable cancellation outbox migration/init and completion enqueue/worker.
- [x] Serialize Request create/update/receipt; validate deadline in Workspace timezone.
- [x] Validate optional partner phone/email/website in backend and UI.
- [x] Add vi/en inline errors; retain light/dark semantic tokens.
- [x] Run backend regression/unit tests and frontend type-check.
- [x] Document deployment migration and limitations; do not modify auth.
- [ ] Manual browser smoke test (including both themes); live migration not applied.

# DA-1255 — Checklist

- [x] PostgreSQL migration and init schema synchronized in files; migration applied to local `brandhub` on 2026-10-09 and columns/indexes verified.
- [x] Owner-only duplicate API with transactional copy and idempotency.
- [x] Selected member validation and one-Manager rule.
- [x] Timezone-only optional copy; no Package/Campaign/execution data copy.
- [x] UI selection, summary and validation in Vietnamese/English.
- [x] Unit/controller tests, full Business Service suite, frontend type-check/lint/build.
- [ ] Smoke-test API against local PostgreSQL.
- [ ] Browser review for light/dark and narrow viewport.
- [x] Regression 2026-10-14: clone timezone follows canonical column when legacy settings disagree;
  tracked with [timezone consistency fix](../workspace-timezone-consistency/task.md).

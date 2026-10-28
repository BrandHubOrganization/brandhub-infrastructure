# Verification
Seams selected by supplied spec section 13: mutation service, purge worker, quota
transaction, API-backed frontend. Test ACL Manager/all vs Creator/Client/own, revoked
client access, 30-day boundary, quota-independent restore, optional version CAS,
concurrent restore/claim, references Post/Task/derivative, provider selection,
storage error, PG retry and exactly-once decrement. Trash paging must scope before
count and never sign previews. Existing pinned content must still resolve safely.
Frontend: delete confirmation alertdialog/cancel focus/Escape, undo, Trash empty/error,
restore unaffected by quota, vi/en parity, light/dark, keyboard and mobile layout.
Run focused tests per slice, compile/typecheck, full suites once at completion.
Integration tests require disposable Mongo replica set + PostgreSQL/Docker; record skips.
Never apply staged migrations or enable purge on shared infrastructure during checks.

## Verification results — 2026-10-25
- Frontend typecheck, production build and changed-file ESLint: PASS.
- Full frontend Vitest: 4 files / 13 tests PASS.
- Repository Playwright: 9 tests PASS, including existing upload regressions,
  vi/en, Cancel focus, Escape/focus return, Undo, 375/768/1440px, light/dark,
  ownership controls and overflow checks. Screenshots inspected locally.
- Real disposable Mongo replica set: Trash roundtrip, ACL-before-count aggregation,
  worker claim vs restore, object deletion before quota release, receipt replay PASS.
- Real disposable PostgreSQL: duplicate concurrent purge receipts subtract once PASS.
- Focused rules/worker tests: retention boundary/backoff, revoked Client scope,
  storage failure and object-deleted crash recovery PASS.
- Post key whitespace bypass: regression observed failing before fix, passing after fix.
- code-review Standards and Spec parallel reviews: all blocking findings resolved.
- Full backend suite: PASS; final totals recorded after completion below.
- Production migrations, provider capability tests against shared storage and purge
  activation were not run. They remain rollout prerequisites, not local test claims.
- Final backend suite: 186 suites, 1,245 tests; 1,152 passed, 93 conditional skips, 0 failures/errors. Command: mvn -Dapi.version=1.44 test (Docker API compatibility override).

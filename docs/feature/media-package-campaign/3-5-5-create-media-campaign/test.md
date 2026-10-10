# Test - FR 3.5.5

| Case | Expected result |
|---|---|
| Approved package | Campaign is created as `DRAFT`. |
| Unapproved package | `409 PACKAGE_NOT_APPROVED`. |
| Work items | Stable IDs and required task fields are validated. |
| Duplicate campaign / concurrent creates | At most one Campaign exists for a Workspace, including DRAFT. |
| Create after Campaign COMPLETED | Cannot create another Campaign in that Workspace. |
| Agreement reassignment to bypass uniqueness | Rejected; Workspace still has one agreement/Campaign. |
| New Workspace using the same catalogue package | Independent selection, snapshot/counter/approvals; no reused approval. |
| Stale draft update | Conflict; current version and approvals are not overwritten. |
| Existing duplicate Campaigns before migration | Report specific conflicting IDs; do not delete or relink history automatically. |
| Locale/theme/mobile | vi/en, light/dark and narrow layouts remain usable. |

New lifecycle tests: **not run**; implementation has not started. Total-quantity,
legacy-snapshot and expanded Task type cases are in [phase-1 test matrix](../phase-1-design/test.md).

## Stage 2 execution — 2026-10-08 (supersedes status above for draft tests only)

- Maven clean targeted suite: 66 tests, zero failures/errors (Campaign service 13,
  validator 15, access 4, Package service 24, Package controller 10).
- Web build: pass; scoped ESLint: pass. Build includes TypeScript compilation.
- Playwright media-package suite: 17 pass / 1 fail. Four new Campaign cases pass:
  Manager create/edit (375px/dark), Client read-only (desktop/light), legacy monthly
  rejection and stale version preserving input. Screenshots in ignored test-results.
- Failed test: utility `/media-package` redirect lands on `/dashboard`; not fixed here.
- Live DB audit read-only: 116 Campaign; 35 agreements with two Campaigns. Migration
  not applied; no runtime schema/concurrent-request claim. Existing monthly/empty
  snapshots and prototype plans remain intact and require explicit review.
- Approval/deploy/completion/Task integration cases still belong to later stages.

## Review execution — 2026-10-10

- Full Business Service suite: 447 tests reported, 416 passed, 31 skipped,
  zero failures/errors. Includes 16 Campaign service and 15 plan-validator tests.
- Web lint: zero errors/81 warnings; type-check and production build passed.
- Mocked Package/Campaign Playwright suite: 16/18 passed initially. RETAINER
  timed out but passed on an isolated rerun; all four Campaign cases passed.
  Utility `/media-package` still redirects to `/dashboard` and fails its test.
- Live authenticated API, concurrent creation and end-to-end Atlas deployment
  were not tested in this review; no database changes were executed.

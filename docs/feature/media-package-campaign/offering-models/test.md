# Test cases

| Case | Expected |
|---|---|
| Existing package API and legacy rows | Remain readable; existing selections preserved |
| Create each model with valid deliverables | Persist and return structured details |
| Invalid quantity, duplicate ID, unknown service | 400; no write |
| Manager from another workspace/Agency | 403; no write |
| Select package then change catalogue | Snapshot stays unchanged |
| Either party submits new terms | Version increments; both approvals null |
| Draft from unapproved/legacy incomplete terms | Rejected without creating Campaign |
| Draft allocation within allowance | DRAFT and frozen terms saved |
| Duplicate, unknown or excessive allocation | Rejected |
| Two concurrent allocations exceed allowance | At most valid allocation succeeds |
| RETAINER two months | Independent allowances; no rollover |
| Client or unrelated user creates draft | Forbidden |
| Unrelated user reads Campaign | Forbidden |
| English/Vietnamese + light/dark + mobile | Labels and contrast correct; no overflow |
| Local Admin-template refresh | Only matching Admin catalogue rows change; no new accounts or Workspace snapshots |

## Execution status (2026-10-06)

Historical results below describe the earlier prototype. The isolated-fixture
instructions were superseded by the existing-account flow in seed-guide.md.

- 51 targeted backend tests passed: package service/controller, allocation validator,
  Campaign service and workspace access tests.
- Full backend suite: 406 tests, 0 assertion failures, 11 context errors, 31 skipped.
  Errors are in WorkspaceControllerIntegrationTest and WorkspaceTemplateControllerIntegrationTest:
  missing ClientProfileRepository/WorkspaceRepository mocks for the existing RequireRoleAspect.
  These unrelated files were not changed in this slice.
- Frontend TypeScript and production build passed; new component/service ESLint passed.
- Browser tests: 14 passed after correcting required-field locators. Covers all three offering
  create forms, monthly draft allocation, existing selection/custom-package flows, hard gate,
  Manager access and light/dark layouts at 375/768/1440px. New RETAINER form also tested at 375px/dark.
  Existing unscoped `/media-package` redirect test fails independently: WorkspaceScopedRedirect
  immediately redirects before workspaceList is loaded. That routing component is unchanged;
  use the scoped `/workspaces/{id}/media-package` route. It was excluded from the final 14-test run,
  not silently marked passed or deleted.
- All 35 new offering locale leaf keys match between vi/en; English browser rendering not separately verified.
- Migration applied successfully on local PostgreSQL. Repeatability, fresh-init parity and
  corrected isolated seed execution await Docker Desktop startup.
- Concurrent DB transaction test and live API/Hibernate smoke test are not yet verified.

## Commit checkpoint (2026-10-08)

- Targeted backend suite re-run: 53 tests, zero failures/errors/skips
  (MediaPackageControllerTest, MediaPackageServiceImplTest,
  CampaignAllocationValidatorTest, CampaignWorkspaceAccessTest,
  MediaCampaignServiceImplTest).
- No seed or migration executed at this checkpoint; full application integration
  and browser checks are not implied by the targeted unit/controller test result.
- Frontend `npm run type-check` re-run successfully. Production build passed on
  2026-10-07 for the same application sources; it was not repeated for documentation
  and commit-only changes. The full lint/browser suites were not re-run here.

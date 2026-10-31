# Test Specification — FR 3.5.3: Request Media Package

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.3` |
| **Function Name** | Request Media Package |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `MediaPackageServiceImpl.negotiateTerms()` (55 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaPackageServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Select or negotiate adjustments to a workspace media package between Client and Agency (Owner/Manager) |
| **Preconditions** | Can connect with server; Caller is Client, Owner, or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Status DRAFT | `workspaceId` = `existing workspace`, `budgetAmount` = `7000.00` | status=CLIENT_REQUESTED_CHANGE, termsVersion+1, approvedByClientAt set, agency approval null | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is MANAGER of workspace; Status CLIENT_REQUESTED_CHANGE | `workspaceId` = `existing workspace`, `durationWeeks` = `6` | status=AGENCY_COUNTERED, approvedByAgencyAt set, client approval null | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Status CLIENT_REQUESTED_CHANGE; User is OWNER of agency | `workspaceId` = `existing workspace`, `scopeDescription` = `New scope` | status=AGENCY_COUNTERED, scopeDescription updated | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Status AGENCY_COUNTERED | `workspaceId` = `existing workspace`, `budgetAmount` = `6500.00` | status=CLIENT_REQUESTED_CHANGE; agency approval cleared | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Status DRAFT | `workspaceId` = `existing workspace`, `budgetAmount` = `1000`, `durationWeeks` = `4`, `scopeDescription` = `s` | All three term fields updated in finalTerms | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Status DRAFT | `workspaceId` = `existing workspace`, `budgetAmount` = `null`, `durationWeeks` = `null`, `scopeDescription` = `null` | No field changed but termsVersion still +1 | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Multiple negotiation rounds | `workspaceId` = `existing workspace`, `budgetAmount` = `2nd round value` | termsVersion increments each round (2 -> 3) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Client resolved via clientProfile (not direct member) | `workspaceId` = `existing workspace`, `budgetAmount` = `900` | Role resolved as CLIENT via clientProfile; change accepted | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Only agency approved before | `workspaceId` = `existing workspace`, `durationWeeks` = `3` | Agency approval invalidated (null) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; termsVersion is 1 | `workspaceId` = `existing workspace`, `durationWeeks` = `1` | termsVersion=2 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; finalTerms is corrupt JSON | `workspaceId` = `existing workspace`, `budgetAmount` = `100` | Terms rebuilt from empty object; update succeeds | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace | `workspaceId` = `existing workspace`, `scopeDescription` = `blank` | scopeDescription stored as null | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Status APPROVED | `workspaceId` = `existing workspace`, `budgetAmount` = `100` | MEDIA_PACKAGE_ALREADY_APPROVED: Media package has already been approved and cannot be renegotiated | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace exists; Workspace has selected package; User is MANAGER of workspace; Status APPROVED | `workspaceId` = `existing workspace`, `durationWeeks` = `2` | MEDIA_PACKAGE_ALREADY_APPROVED: Media package has already been approved and cannot be renegotiated | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace exists; User is CLIENT of workspace; Workspace has no selected package | `workspaceId` = `existing workspace`, `budgetAmount` = `100` | WORKSPACE_MEDIA_PACKAGE_NOT_FOUND: No media package has been selected for this workspace | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Workspace exists; Workspace has selected package; User is not a workspace member | `workspaceId` = `existing workspace`, `budgetAmount` = `100` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Workspace exists; Workspace has selected package; User is member with other role (e.g. VIEWER) | `workspaceId` = `existing workspace`, `budgetAmount` = `100` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Workspace exists | `workspaceId` = `non-existent id`, `budgetAmount` = `100` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test - FR 3.5.3

| Case | Expected result |
|---|---|
| Client request change | New immutable event; status becomes client-requested-change. |
| Agency counter-offer | New immutable event; status becomes agency-countered. |
| Multiple rounds | Earlier events remain readable in order. |
| Terms-changing event | Version increments and both prior approvals become invalid. |
| Replace package after first event | Rejected. |
| Approved package change | Rejected. |

## Phase 5 cases (before code)

| Case | Expected |
|---|---|
| Fresh successful proposal | BASELINE old version + actor event new version in same transaction |
| Legacy migration twice | Exactly one honest baseline; no inferred actor/old rounds; selections unchanged |
| Invalid/no-change/stale proposal | No event, count or approval writes and no notification |
| Proposal after one approval | Both approvals reset, history preserved |
| Old UI approves after counter-offer | 409, no approval written |
| Old UI approves after DRAFT package switch | Version advanced, 409 rather than approval of another package |
| Missing version on propose/approve | HTTP 400; stale approved retries also 409 |
| Event insert failure | Whole proposal transaction rolls back including baseline/reset/count |
| Competing proposals same version | One succeeds, other conflicts; no duplicate versions |
| Creator/outsider/foreign Workspace | 403/404, no history disclosure |
| Direct event update/delete | SQL rejected; approved parent deletion retains existing cascade policy |
| Client limit exhausted/Manager proposal | Client blocked; Manager may counter without incrementing Client count |
| Read history | Newest-first paging, no writes; snapshots remain unchanged |
| Browser history/diff | Read-only, baseline warning, current approval target unchanged |
| UI vi/en/light/dark/375/768/1440 | Accessible disclosure/retry, no horizontal overflow |

## Evidence — 2026-10-13

- Selected Package/Campaign/ContentRequest suites: **246 passed, 13 skipped**, zero
  failures/errors (259 cases including skips; aggregate current Surefire reports
  after broad regression + final role/idempotence/history-unit reruns).
- Skips are explicit opt-in Mongo transaction/Atlas/application-DB smoke checks;
  they were not silently run against shared data. Live cross-store flow still pending.
- PostgreSQL 17 disposable container/database `brandhub-phase5-postgres-test` /
  `package_test` at 127.0.0.1:55439. Full init succeeded; Hibernate validated history
  and selection mappings. PackageNegotiationPostgresTest creates its own random
  schema, runs real migration twice, verifies honest legacy baseline, descending
  history query, atomic rollback on forced event insert failure, competing actual
  proposal services (one success/one version conflict), direct mutation block and
  parent cascade compatibility. No writes to application PostgreSQL or Atlas.
- PackageVersionGuardTest verifies stale proposal/approval, stale APPROVED retry,
  unchanged terms, baseline captured before mutation, resetting both approvals,
  preserving Client count on Agency counter-offer, same-side repeat timestamp,
  and Owner-as-Manager effective actor role. Existing Package tests keep proposal
  limit/locked Client fields/selection guard; Campaign suites cover plan/approval/
  deployment retry/completion; Request suites cover its own lifecycle and source.
- PackageVersionHttpTest requires version in both payloads (400 missing/null/0/-1);
  MockMvc filters disabled, so this is **not JWT/Gateway smoke**. History service
  unit verifies scoped authorization before query, pagination and no writes on read.
- Web type-check/build passed; lint 0 errors / 80 existing warnings. History vi/en
  keys parallel. Playwright CLI API fixture verifies history disclosure/read-only
  diff/baseline, displayed version sent on approve and proposal, localized 409,
  retained budget/note, beforeunload warning, history API error/retry, vi/en,
  light/dark and no overflow at 375/768/1440. Screenshots inspected; expected fixture
  HTTP 409/503 console entries are not unhandled JavaScript failures. No full A11y audit.
- Shared read-only inventory: 50 selection snapshots, all JSON objects; history
  table absent. New migrations not applied. No accounts or shared records seeded.

### Reproduce isolated PostgreSQL case

Start a NEW PostgreSQL 17 tmpfs container at 127.0.0.1:55439 with fixture-only
DB/user `package_test`, password `package_test_only`, then run updated init ONLY
in that disposable DB. Never change the test URL to the application DB:

```powershell
$env:BRANDHUB_PACKAGE_ISOLATED_TEST='true'
$env:BRANDHUB_PACKAGE_TEST_URL='jdbc:postgresql://127.0.0.1:55439/package_test'
mvn.cmd '-Dtest=PackageNegotiationPostgresTest,PackageVersion*Test,PackageNegotiationHistoryServiceTest,MediaPackage*Test' test
Remove-Item Env:\BRANDHUB_PACKAGE_ISOLATED_TEST
Remove-Item Env:\BRANDHUB_PACKAGE_TEST_URL
```

Test asserts the exact fixture URL and drops only its own random schema. Container
and browser artifacts are cleaned after verification. Operator setup is documented
at [test-setup.md](../test-setup.md); actual account/Gateway acceptance remains open.

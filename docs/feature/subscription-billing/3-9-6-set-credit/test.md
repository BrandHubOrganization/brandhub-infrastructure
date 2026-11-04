# Test Specification — FR 3.9.6: Set Credit

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.9.6` |
| **Function Name** | Set Credit |
| **Functional Domain** | Billing |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceCreditService.update()` (20 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceCreditServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Allow the Owner to set or clear a workspace's AI credit cap with optimistic expectedRevision concurrency control |
| **Preconditions** | Can connect with server; Caller is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=500, expectedRevision=0)` | 200 OK - WorkspaceCreditResponse(creditLimit=500, revision=1, used, held, periodStart, periodEnd) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=null, expectedRevision=1) [uncapped]` | 200 OK - Setting cap=null removes workspace cap (uncapped within agency pool) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 1)`, `request` = `SetCreditLimitRequest(cap=500, expectedRevision=0)` | 200 OK - Revision incremented atomically (expectedRevision -> expectedRevision + 1) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 1)`, `request` = `SetCreditLimitRequest(cap=null, expectedRevision=1) [uncapped]` | 200 OK - Lowering cap below already used credits succeeds without rolling back used credits | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; SetCreditLimitRequest contains cap (>= 0 or null to remove cap) and expectedRevision | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=50, expectedRevision=1) [below used]` | 200 OK - list(agencyId, actor) returns List<WorkspaceCreditResponse> for all active workspaces | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; SetCreditLimitRequest contains cap (>= 0 or null to remove cap) and expectedRevision | `workspace` = `active workspace UUID (rev 1)`, `request` = `SetCreditLimitRequest(cap=50, expectedRevision=1) [below used]` | 200 OK - get(agencyId, workspaceId, actor) returns current WorkspaceCreditResponse | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=500, expectedRevision=0)` | 200 OK - Usage and held amounts scoped to current CreditCycle window [periodStart, periodEnd) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=null, expectedRevision=1) [uncapped]` | 200 OK - Audit / configuration store records actorId and updated cap | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of the active agency; Workspace already has used/held credits exceeding the new lower cap (no rollback boundary) | `workspace` = `workspace with existing usage=80`, `request` = `SetCreditLimitRequest(cap=0, expectedRevision=0) [zero cap]` | 200 OK - Boundary cap=0 blocks new AI reservations in workspace while preserving history | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of the active agency; Workspace already has used/held credits exceeding the new lower cap (no rollback boundary) | `workspace` = `workspace with existing usage=80`, `request` = `SetCreditLimitRequest(cap=0, expectedRevision=0) [zero cap]` | 200 OK - Initial configuration (expectedRevision=0) creates workspace_credit_limits row | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=50, expectedRevision=1) [below used]` | 200 OK - High cap (Long.MAX_VALUE / enterprise pool) persisted accurately | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of the active agency; expectedRevision mismatches current workspace credit revision or workspace is not in agency | `workspace` = `workspace in another agency`, `request` = `SetCreditLimitRequest(cap=500, expectedRevision=0)` | WORKSPACE_NOT_IN_AGENCY - 404 Workspace is not active in the specified agency | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of the active agency; expectedRevision mismatches current workspace credit revision or workspace is not in agency | `workspace` = `workspace with stale revision`, `request` = `SetCreditLimitRequest(cap=500, expectedRevision=0)` | CREDIT_CONFIGURATION_STALE - 409 expectedRevision does not match current revision | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not the Owner | `workspace` = `active workspace UUID (rev 0)`, `request` = `SetCreditLimitRequest(cap=500, expectedRevision=0)` | FORBIDDEN - 403 Caller is not the Owner of the agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `workspace in another agency`, `request` = `stale expectedRevision=99` | AGENCY_NOT_FOUND - 404 Agency not found or is soft-deleted | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of the active agency; Target workspace is ACTIVE and belongs to the agency | `workspace` = `workspace with stale revision`, `request` = `negative cap=-1 or null expectedRevision` | VALIDATION_ERROR - 400 cap must be >= 0 and expectedRevision is required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.9.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

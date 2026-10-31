# Test Specification — FR 3.9.4: View AI Credit Tracking

> Note: This specification maps to official **FR 3.9.4 — View AI Credit Tracking** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-9-4-view-ai-credit-tracking/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.9.4` |
| **Function Name** | View AI Credit Tracking |
| **Functional Domain** | Billing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `CreditBalanceService.summary()` (42 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/CreditBalanceServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Return real-time AI credit balance summary at AGENCY scope for Owner or WORKSPACE cap scope for Manager/Creator |
| **Preconditions** | Can connect with server; Caller is Owner or Manager/Creator |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `active READY agency UUID`, `workspaceId` = `null (Owner AGENCY scope)` | 200 OK - Owner gets CreditBalanceResponse(scope='AGENCY', available, granted, reserved, expiresAt) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `active READY agency UUID`, `workspaceId` = `workspace UUID (Owner with workspaceId)` | 200 OK - Owner passing valid workspaceId in agency still receives full AGENCY scope balance | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `agency with workspace cap`, `workspaceId` = `null (Owner AGENCY scope)` | 200 OK - Manager/Creator gets CreditBalanceResponse(scope='WORKSPACE', available=remainingCap, granted=null) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `agency with workspace cap`, `workspaceId` = `workspace UUID (Owner with workspaceId)` | 200 OK - Effective workspace available is min(agencyAvailable, max(0, cap - used - held)) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Agency has active credit grants (SUBSCRIPTION/PERIOD/TOPUP) and workspace has credit limit | `agencyId` = `active READY agency UUID`, `workspaceId` = `workspace UUID (Manager/Creator WORKSPACE scope)` | 200 OK - Uncapped workspace for Manager/Creator returns agencyAvailable as remainingCap | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Agency has active credit grants (SUBSCRIPTION/PERIOD/TOPUP) and workspace has credit limit | `agencyId` = `agency with workspace cap`, `workspaceId` = `workspace UUID (Manager/Creator WORKSPACE scope)` | 200 OK - Expired credit grants excluded and active grants summed with earliest expiresAt | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `active READY agency UUID`, `workspaceId` = `null (Owner AGENCY scope)` | 200 OK - CreditCycle.current resolves active subscription period or UTC calendar month | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `active READY agency UUID`, `workspaceId` = `workspace UUID (Owner with workspaceId)` | 200 OK - Active reservation holds subtracted from granted credits to compute available | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Workspace has no explicit cap (null limit) or remaining agency pool is lower than workspace cap | `agencyId` = `agency with 0 remaining credits`, `workspaceId` = `workspace with uncapped limit` | 200 OK - Agency with 0 grants returns available=0, granted=0, reserved=0, expiresAt=null | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Workspace has no explicit cap (null limit) or remaining agency pool is lower than workspace cap | `agencyId` = `agency with 0 remaining credits`, `workspaceId` = `workspace with uncapped limit` | 200 OK - Workspace where used + held >= cap returns available=0 (never negative) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `active READY agency UUID`, `workspaceId` = `workspace UUID (Manager/Creator WORKSPACE scope)` | 200 OK - Manager and Creator roles both permitted for WORKSPACE scope query | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Subscription is SUSPENDED, migration_state != READY, or wallet_verified is false | `agencyId` = `agency with unready/suspended subscription`, `workspaceId` = `null (Owner AGENCY scope)` | BILLING_SUBSCRIPTION_NOT_READY - 409 Subscription is SUSPENDED, not READY, or wallet unverified | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Subscription is SUSPENDED, migration_state != READY, or wallet_verified is false | `agencyId` = `non-existent or unauthorized agency UUID`, `workspaceId` = `null (Owner AGENCY scope)` | BILLING_FORBIDDEN - 403 Workspace does not belong to the specified agency | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is neither Owner nor active Manager/Creator of the workspace | `agencyId` = `active READY agency UUID`, `workspaceId` = `null (Owner AGENCY scope)` | BILLING_FORBIDDEN - 403 Caller is not Owner and has no active Manager/Creator workspace role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `agency with unready/suspended subscription`, `workspaceId` = `workspace not in agency` | BILLING_FORBIDDEN - 403 Non-Owner omitted workspaceId parameter | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Agency exists and subscription migration_state is READY, not SUSPENDED, and wallet is verified; Caller is Owner (AGENCY scope) or active Manager/Creator (WORKSPACE scope) | `agencyId` = `non-existent or unauthorized agency UUID`, `workspaceId` = `unauthorized Client/outsider user` | BILLING_FORBIDDEN - 403 Agency does not exist or is soft-deleted | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.9.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

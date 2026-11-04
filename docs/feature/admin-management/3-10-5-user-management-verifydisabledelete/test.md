# Test Specification — FR 3.10.5: Update User Violation Status

> Note: This specification maps to official **FR 3.10.5 — Update User Violation Status** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-5-update-user-violation-status/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.5` |
| **Function Name** | Update User Violation Status |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminAccountService.record()` (48 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminAccountServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to add or pardon YELLOW/ORANGE/RED user strikes with operationId idempotency, FLAGGED status sync, and SanctionReview creation |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `ACTIVE user UUID`, `request` = `ADD YELLOW strike (category='SPAM', reason)` | 200 OK - ADD YELLOW strike saves UserStrike and extends cleanPeriodEndsAt by +90 days | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `ACTIVE user UUID`, `request` = `ADD ORANGE/RED strike (triggers FLAGGED & SanctionReview)` | 200 OK - ADD ORANGE or RED strike transitions user status to FLAGGED | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `FLAGGED user UUID (with live strikes)`, `request` = `ADD YELLOW strike (category='SPAM', reason)` | 200 OK - 3 live YELLOW strikes automatically escalate into 1 ORANGE strike via StrikePolicy | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `FLAGGED user UUID (with live strikes)`, `request` = `ADD ORANGE/RED strike (triggers FLAGGED & SanctionReview)` | 200 OK - Reaching sanction threshold (2 ORANGE or 1 RED) creates PENDING SanctionReview | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); AdminStrikeRequest has valid operationId, action (ADD or REMOVE), and reason (3..500 chars) | `target` = `ACTIVE user UUID`, `request` = `REMOVE active strikeId (pardon)` | 200 OK - REMOVE pardons live strike (sets removedAt, removedBy, removalReason) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); AdminStrikeRequest has valid operationId, action (ADD or REMOVE), and reason (3..500 chars) | `target` = `FLAGGED user UUID (with live strikes)`, `request` = `REMOVE active strikeId (pardon)` | 200 OK - REMOVE closes PENDING SanctionReview as 'CLOSED' if live strikes drop below threshold | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `ACTIVE user UUID`, `request` = `ADD YELLOW strike (category='SPAM', reason)` | 200 OK - Overdue FLAGGED user (cleanPeriodEndsAt <= now) auto-restored to ACTIVE before action | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `ACTIVE user UUID`, `request` = `ADD ORANGE/RED strike (triggers FLAGGED & SanctionReview)` | 200 OK - AdminAccountJournal records strike / PARDON_STRIKE audit entry | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user reaches 3 YELLOW strikes (escalation) or 2 ORANGE / 1 RED strike (SanctionReview) | `target` = `user with overdue FLAGGED cleanPeriodEndsAt`, `request` = `idempotent replay of existing operationId` | 200 OK - Idempotent operationId replay with same payload returns without duplicate strike | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user reaches 3 YELLOW strikes (escalation) or 2 ORANGE / 1 RED strike (SanctionReview) | `target` = `user with overdue FLAGGED cleanPeriodEndsAt`, `request` = `idempotent replay of existing operationId` | 200 OK - Reason at 3-char minimum and 500-char maximum boundary accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `ACTIVE user UUID`, `request` = `REMOVE active strikeId (pardon)` | 200 OK - Category at 100-character maximum boundary trimmed and saved | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user is DEACTIVATED, strikeId is missing/expired, or request fields are invalid | `target` = `DEACTIVATED user UUID`, `request` = `ADD YELLOW strike (category='SPAM', reason)` | ADMIN_STATE_CONFLICT - 409 Target user is DEACTIVATED or strike already removed/expired | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user is DEACTIVATED, strikeId is missing/expired, or request fields are invalid | `target` = `ADMIN or self user UUID`, `request` = `ADD YELLOW strike (category='SPAM', reason)` | FORBIDDEN - 403 Caller is not ADMIN or target user is an ADMIN / self | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not ADMIN or attempts to strike another ADMIN or self | `target` = `ACTIVE user UUID`, `request` = `ADD YELLOW strike (category='SPAM', reason)` | USER_NOT_FOUND - 404 Target user does not exist | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `DEACTIVATED user UUID`, `request` = `invalid ADD/REMOVE fields or blank reason` | INVALID_REQUEST - 400 Invalid action/level/category/reason or conflicting operationId payload | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user (lockTarget); Target user status is ACTIVE or FLAGGED | `target` = `ADMIN or self user UUID`, `request` = `non-existent or expired strikeId on REMOVE` | STRIKE_NOT_FOUND - 404 strikeId not found for target user on REMOVE | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.10.9: Deactivate User

> Note: This specification maps to official **FR 3.10.9 — Deactivate User** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-9-deactivate-user/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.9` |
| **Function Name** | Deactivate User |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminAccountService.confirm()` (35 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminAccountServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to confirm a pending SanctionReview, set user status to DEACTIVATED, increment tokenVersion, and record audit log |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `FLAGGED user UUID with PENDING review`, `request` = `AdminSanctionRequest(reviewId, confirmed=true, reason='Severe policy violation')` | 200 OK - User status set to DEACTIVATED, isActive=false, and lastBannedAt=now | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `FLAGGED user UUID with PENDING review`, `request` = `confirm on multi-session user` | 200 OK - SanctionReview status updated to CONFIRMED with resolvedBy=actor and resolvedAt=now | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `ACTIVE user UUID with RED strike review`, `request` = `AdminSanctionRequest(reviewId, confirmed=true, reason='Severe policy violation')` | 200 OK - User tokenVersion incremented to immediately invalidate active JWT tokens | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `ACTIVE user UUID with RED strike review`, `request` = `confirm on multi-session user` | 200 OK - Reactivation schedule or clean period state updated per sanction policy | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user's live strikes still meet StrikePolicy.needsReview(live, now) | `target` = `FLAGGED user UUID with PENDING review`, `request` = `idempotent repeat confirm on CONFIRMED review` | 200 OK - AdminAccountJournal appends CONFIRM_SANCTION audit record with reason | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user's live strikes still meet StrikePolicy.needsReview(live, now) | `target` = `ACTIVE user UUID with RED strike review`, `request` = `idempotent repeat confirm on CONFIRMED review` | 200 OK - Sanction notification email queued to user via outbox | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `FLAGGED user UUID with PENDING review`, `request` = `AdminSanctionRequest(reviewId, confirmed=true, reason='Severe policy violation')` | 200 OK - Subsequent login attempts by deactivated user are rejected with ACCOUNT_DEACTIVATED | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `FLAGGED user UUID with PENDING review`, `request` = `confirm on multi-session user` | 200 OK - User's historical agency/workspace data preserved without hard deletion | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; SanctionReview is already in CONFIRMED status (idempotent repeat call) | `target` = `user with already CONFIRMED reviewId`, `request` = `reason at 3-char / 500-char boundary` | 200 OK - Idempotent repeat confirm on already CONFIRMED reviewId returns 200 OK cleanly | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; SanctionReview is already in CONFIRMED status (idempotent repeat call) | `target` = `user with already CONFIRMED reviewId`, `request` = `reason at 3-char / 500-char boundary` | 200 OK - Reason at exact 3-character minimum boundary accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `FLAGGED user UUID with PENDING review`, `request` = `idempotent repeat confirm on CONFIRMED review` | 200 OK - Reason at exact 500-character maximum boundary accepted | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; SanctionReview is not PENDING, does not belong to target, or strikes no longer meet threshold | `target` = `user whose strikes were pardoned/expired`, `request` = `AdminSanctionRequest(reviewId, confirmed=true, reason='Severe policy violation')` | ADMIN_STATE_CONFLICT - 409 Strikes no longer reach sanction threshold or user already DEACTIVATED | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; SanctionReview is not PENDING, does not belong to target, or strikes no longer meet threshold | `target` = `ADMIN or non-existent user UUID`, `request` = `AdminSanctionRequest(reviewId, confirmed=true, reason='Severe policy violation')` | FORBIDDEN - 403 Caller is not ADMIN or cannot sanction an ADMIN account | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not ADMIN or targets an ADMIN user | `target` = `FLAGGED user UUID with PENDING review`, `request` = `AdminSanctionRequest(reviewId, confirmed=true, reason='Severe policy violation')` | USER_NOT_FOUND - 404 Target user not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `user whose strikes were pardoned/expired`, `request` = `confirmed=false or reviewId=null` | INVALID_REQUEST - 400 confirmed must be true, reviewId required, and reason 3..500 chars | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role and target user is a non-ADMIN user; Target user is ACTIVE or FLAGGED and has a PENDING SanctionReview matching reviewId | `target` = `ADMIN or non-existent user UUID`, `request` = `wrong reviewId or blank reason` | ADMIN_STATE_CONFLICT - 409 SanctionReview ID not found for target user | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.9`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

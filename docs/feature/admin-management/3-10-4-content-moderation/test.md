# Test Specification — FR 3.10.4: Content Moderation Queue

> Note: This specification maps to official **FR 3.10.4 — Content Moderation Queue** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-4-content-moderation-queue/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.4` |
| **Function Name** | Content Moderation Queue |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `ContentModerationService.decide()` (49 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/ContentModerationServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to approve (note >= 10 chars) or block (recording strike + returning post to DRAFT) a pending moderation item |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.APPROVE, note='Verified safe content'` | 200 OK - Decision.APPROVE sets review status='APPROVED', increments row_version, notifies author | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.BLOCK, strikeLevel=YELLOW, category='CONTENT_POLICY', note='Profanity'` | 200 OK - Decision.BLOCK sets status='BLOCKED', records strike via AdminAccountService.record | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (FLAGGED_AUTHOR)`, `request` = `Decision.APPROVE, note='Verified safe content'` | 200 OK - Decision.BLOCK returns PENDING_APPROVAL post in Mongo back to DRAFT for editing | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (FLAGGED_AUTHOR)`, `request` = `Decision.BLOCK, strikeLevel=YELLOW, category='CONTENT_POLICY', note='Profanity'` | 200 OK - list() returns AdminModerationItem.Page with pending and today reviewed counts | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Immutable snapshot of reviewed version is stored in Mongo post_versions collection | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `list(status='PENDING', source='COMPLIANCE', page=1, size=20)` | 200 OK - detail() returns AdminModerationItem with immutable Mongo post_versions snapshot | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Immutable snapshot of reviewed version is stored in Mongo post_versions collection | `id` = `PENDING review UUID (FLAGGED_AUTHOR)`, `request` = `list(status='PENDING', source='COMPLIANCE', page=1, size=20)` | 200 OK - eligibility() returns ALLOWED/APPROVED or holds FLAGGED author's unreviewed post | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.APPROVE, note='Verified safe content'` | 200 OK - AdminAudit records CONTENT_MODERATION UPDATE and AdminEmailOutbox queues author email | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.BLOCK, strikeLevel=YELLOW, category='CONTENT_POLICY', note='Profanity'` | 200 OK - flag() reuses existing review item idempotently on duplicate (postId, contentVersion) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Decision note is at exact minimum length boundary (10 chars for APPROVE, 3 chars for BLOCK) | `id` = `PENDING review UUID (boundary note)`, `request` = `APPROVE with exact 10-char note / BLOCK with 3-char note` | 200 OK - APPROVE with exact 10-character note accepted at minimum boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Decision note is at exact minimum length boundary (10 chars for APPROVE, 3 chars for BLOCK) | `id` = `PENDING review UUID (boundary note)`, `request` = `APPROVE with exact 10-char note / BLOCK with 3-char note` | 200 OK - BLOCK with exact 3-character note and default category='CONTENT_POLICY' accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `list(status='PENDING', source='COMPLIANCE', page=1, size=20)` | 200 OK - Operation ID = review ID prevents duplicate strike on retried BLOCK | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Review item is not found, already decided, rowVersion mismatches, or post version changed | `id` = `non-existent review UUID`, `request` = `Decision.APPROVE, note='Verified safe content'` | MODERATION_NOT_FOUND - 404 Moderation review ID or flagged post not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Review item is not found, already decided, rowVersion mismatches, or post version changed | `id` = `already decided or stale-version UUID`, `request` = `Decision.APPROVE, note='Verified safe content'` | ADMIN_STATE_CONFLICT - 409 Review is no longer PENDING, rowVersion stale, or post version changed | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller does not have ADMIN system role | `id` = `PENDING review UUID (COMPLIANCE)`, `request` = `Decision.APPROVE, note='Verified safe content'` | FORBIDDEN - 403 Caller does not have ADMIN system role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `non-existent review UUID`, `request` = `APPROVE with <10-char note` | MODERATION_NOTE_TOO_SHORT - 400 APPROVE decision note must be at least 10 characters | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Moderation review item exists in PENDING status matching PostDocument.contentVersion | `id` = `already decided or stale-version UUID`, `request` = `BLOCK without strikeLevel or <3-char note` | VALIDATION_ERROR - 400 BLOCK decision requires strikeLevel and note >= 3 characters | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

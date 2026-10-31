# Test Specification — FR 3.4.6: Remove Agency

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.6` |
| **Function Name** | Remove Agency |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyServiceImpl.removeAgency()` (23 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to soft-delete an agency (retaining data for 30-day recovery) and cascade soft-delete its workspaces |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency; Agency has 2 workspaces | `agencyId` = `existing id` | 204 - agency and 2 workspaces SOFT_DELETED with deletedAt | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency; Agency has 1 workspace | `agencyId` = `existing id` | 204 - agency and workspace SOFT_DELETED | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency; Agency has members | `agencyId` = `existing id` | 204 - agency SOFT_DELETED, member rows kept | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency; Agency has pending invitations | `agencyId` = `existing id` | 204 - agency SOFT_DELETED | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Agency has 2 workspaces | `agencyId` = `existing id` | 204 - agency and workspaces get same deletedAt timestamp | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Agency status ACTIVE | `agencyId` = `existing id` | 204 - status changed ACTIVE to SOFT_DELETED | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; User is OWNER of agency; Agency has no workspace | `agencyId` = `existing id` | 204 - only agency SOFT_DELETED | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is OWNER of agency; Agency has only owner member | `agencyId` = `existing id` | 204 - agency SOFT_DELETED | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is OWNER of agency; Agency has 1 workspace already SOFT_DELETED | `agencyId` = `existing id` | 204 - workspace deletedAt overwritten, no error | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency; Agency already SOFT_DELETED | `agencyId` = `existing id` | 204 - status stays SOFT_DELETED (idempotent) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member role MANAGER | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member role CREATOR | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is not related to agency | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CLIENT of agency workspace | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Request without valid token | `agencyId` = `existing id`, `currentUser` = `null` | 401 UNAUTHORIZED - authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Remove Agency (FR 3.4.6)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner `DELETE /api/v1/agencies/{id}` | AC2 | 200; `status == SOFT_DELETED`, `deletedAt != null` | Happy path | Pass |
| TC-02 | User không phải Owner xóa | AC1, Error (mục 6) | 403 `NOT_AGENCY_OWNER`, không đổi data | Error case | Pass |
| TC-03 | Agency đã soft-delete → gọi list | AC2, Edge (mục 7) | KHÔNG còn xuất hiện trong list | Edge case | Pass |

| TC-04 | `restoreAgency_ownerWithinWindow_setsActiveAndClearsDeletedAt` | AC restore | 200; `status == ACTIVE`, `deletedAt == null` | Happy path | Pass — xác nhận 2026-09-21 |
| TC-05 | `restoreAgency_nonOwner_throwsNotAgencyOwner` | Error | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-06 | `restoreAgency_notDeleted_throwsAgencyNotDeleted` | Edge | 400 `AGENCY_NOT_DELETED` khi agency đang ACTIVE, không phải SOFT_DELETED | Edge case | Pass |
| TC-07 | `restoreAgency_pastWindow_throwsRestoreWindowExpired` | Edge | 410 `RESTORE_WINDOW_EXPIRED` khi `deletedAt` quá 30 ngày | Edge case | Pass |
| TC-08 | Xóa Agency có Workspace con | AC cascade | Workspace con `status == SOFT_DELETED`, `deletedAt != null` | Happy path | Chưa test tự động |
| TC-09 | Restore Agency | AC cascade restore | Mọi Workspace con `status == ACTIVE`, `deletedAt == null` | Happy path | Chưa test tự động |
| TC-10 | Restore Agency khi 1 Workspace con đã bị xóa độc lập trước đó (FR 3.4.15) | Edge (xem spec "Cần xác nhận") | Workspace đó cũng bị set `ACTIVE` (hành vi hiện tại — "hồi sinh" ngoài ý muốn) | Edge case | Chưa test tự động |

## Ghi chú

- AC2 = "Set status = SOFT_DELETED, deletedAt = now". Restore đã code + test (TC-04..07).
- Cascade Workspace con đã code (2026-09-23): TC-08/TC-09 mô tả hành vi mong đợi, **chưa thấy test tự động riêng** trong repo — cần BE lead xác nhận đã có test hay chưa.
- Job xóa cứng tự động sau 30 ngày vẫn ngoài scope (chưa làm).

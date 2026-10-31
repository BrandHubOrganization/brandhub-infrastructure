# Test Specification — FR 3.4.7: Invite Agency Member

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.7` |
| **Function Name** | Invite Agency Member |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyServiceImpl.inviteMember()` (62 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to create a 72-hour PENDING agency invitation token for an email and send an invitation email |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 23** (`Passed`: 23, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 6, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID23`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn` | 201 - AgencyInvitationResponse(status=PENDING, expires in 30 days) | Agency invitation email sent | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `NEW@BrandHub.vn` | 201 - email normalized to lowercase and trimmed | Agency invitation email sent | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `expiryDays` = `7.0` | 201 - expiresAt = now + 7 days | Agency invitation email sent | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `note` = `Welcome aboard`, `inviteeName` = `An` | 201 - invitation with note | Agency invitation email sent | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Workspace belongs to agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `workspaceId` = `agency workspace id`, `role` = `CREATOR` | 201 - invitation assigned to workspace with role CREATOR | Agency invitation email sent | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Workspace belongs to agency and has no manager | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `workspaceId` = `agency workspace id`, `role` = `MANAGER` | 201 - invitation with role MANAGER | Agency invitation email sent | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is OWNER of agency; Workspace belongs to agency | `agencyId` = `existing id`, `email` = `client@brandhub.vn`, `workspaceId` = `agency workspace id`, `role` = `CLIENT` | 201 - CLIENT invitation scoped to workspace | Agency invitation email sent | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is OWNER of agency; Previous invitation for email expired | `agencyId` = `existing id`, `email` = `new@brandhub.vn` | 201 - new PENDING invitation created | Agency invitation email sent | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `expiryDays` = `1.0` | 201 - expiresAt = now + 1 day | Agency invitation email sent | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `expiryDays` = `30.0` | 201 - expiresAt = now + 30 days | Agency invitation email sent | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `expiryDays` = `0.0` | 201 - expiry clamped to minimum 1 day | Agency invitation email sent | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `expiryDays` = `90.0` | 201 - expiry clamped to 30 days | Agency invitation email sent | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is OWNER of agency; Agency has 19 pending invitations | `agencyId` = `existing id`, `email` = `new@brandhub.vn` | 201 - 20th invitation created | Agency invitation email sent | **Passed** |
| `UTCID14` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `note` = `whitespace only` | 201 - blank note stored as null | Agency invitation email sent | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is OWNER of agency; Agency has 20 pending invitations | `agencyId` = `existing id`, `email` = `new@brandhub.vn` | TOO_MANY_PENDING_INVITATIONS: maximum of 20 pending invitations | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id`, `email` = `new@brandhub.vn` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MEMBER of agency (not owner) | `agencyId` = `existing id`, `email` = `new@brandhub.vn` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is OWNER of agency; Email belongs to existing agency member | `agencyId` = `existing id`, `email` = `member@brandhub.vn` | ALREADY_AGENCY_MEMBER: User is already a member of this agency | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is OWNER of agency; Pending unexpired invitation exists for email | `agencyId` = `existing id`, `email` = `pending@brandhub.vn` | INVITATION_ALREADY_PENDING: An invitation is already pending for this email | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `workspaceId` = `non-existing id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is OWNER of agency; Workspace belongs to another agency | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `workspaceId` = `other agency workspace id` | WORKSPACE_NOT_IN_AGENCY: Workspace does not belong to this agency | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; User is OWNER of agency; Workspace already has a manager | `agencyId` = `existing id`, `email` = `new@brandhub.vn`, `workspaceId` = `agency workspace id`, `role` = `MANAGER` | MANAGER_ALREADY_ASSIGNED: This workspace already has a manager | — | **Passed** |
| `UTCID23` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `email` = `client@brandhub.vn`, `workspaceId` = `null`, `role` = `CLIENT` | WORKSPACE_REQUIRED_FOR_CLIENT_INVITE: A workspace must be selected when inviting a client | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Invite Agency Member (FR 3.4.7)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner gửi `{email:"new@x.com"}` (không expiryDays) | AC1, AC2 | 200; invitation tạo với `token`, `status == PENDING`, `expiresAt ≈ now+30d`; gửi email | Happy path | Pass |
| TC-02 | Email đã là member của Agency | Error (mục 6) | 409 `ALREADY_AGENCY_MEMBER` | Error case | Pass |
| TC-03 | User không phải Owner gửi invite | Error (mục 6) | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-04 | Email có invitation PENDING còn hạn | Edge | 409 `INVITATION_ALREADY_PENDING` | Edge case | Pass |
| TC-05 | Email chưa có User account | Edge (mục 7) | Vẫn tạo invite thành công (gắn `invitedEmail`) | Edge case | Pass |
| TC-06 | `expiryDays = 5` | AC | `expiresAt ≈ now+5d` | Happy path | Pass |
| TC-07 | Agency đã có 20 invitation PENDING còn hạn | Edge | 409 `TOO_MANY_PENDING_INVITATIONS` | Edge case | Pass |
| TC-08 | `workspaceId` không thuộc agency | Edge | 400 `WORKSPACE_NOT_IN_AGENCY` | Edge case | Pass |
| TC-09 | `role=MANAGER` nhưng workspace đã có manager active | Edge | 409 `MANAGER_ALREADY_ASSIGNED` | Edge case | Pass |
| TC-10 | `role=CLIENT` không kèm `workspaceId` | Edge | 400 `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` | Edge case | Pass |
| TC-11 | `role=CLIENT` kèm `workspaceId` hợp lệ | Happy path | 200; invitation lưu `role=CLIENT`, `workspaceId` | Happy path | Pass |

## Ghi chú

- AC2 = "Gửi lời mời qua email". AC3 = "Người được mời sau accept không có role" — role MEMBER gắn ở bước accept (3.4.8), không ở bước invite.

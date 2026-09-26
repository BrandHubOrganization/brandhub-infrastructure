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

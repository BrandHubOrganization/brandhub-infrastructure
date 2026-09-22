# Test — Invite Agency Member (FR 3.4.7)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner gửi `{email:"new@x.com"}` | AC1, AC2 | 200; invitation tạo với `token`, `status == PENDING`, `expiresAt ≈ now+3d`; gửi email | Happy path | Pass |
| TC-02 | Email đã là member của Agency | Error (mục 6) | 409 `ALREADY_AGENCY_MEMBER` | Error case | Pass |
| TC-03 | User không phải Owner gửi invite | Error (mục 6) | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-04 | Email có invitation PENDING còn hạn | Edge | 409 `INVITATION_ALREADY_PENDING` | Edge case | Pass |
| TC-05 | Email chưa có User account | Edge (mục 7) | Vẫn tạo invite thành công (gắn `invitedEmail`) | Edge case | Pass |

## Ghi chú

- AC2 = "Gửi lời mời qua email". AC3 = "Người được mời sau accept không có role" — role MEMBER gắn ở bước accept (3.4.8), không ở bước invite.

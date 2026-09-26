# Test — View Agency Invitation Status (FR 3.4.8)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | User gọi `GET /invitations/my-pending` | AC2 | 200; chỉ invitation PENDING + còn hạn | Happy path | Pass |
| TC-02 | Owner gọi `GET /{agencyId}/invitations` | AC1 | 200; list toàn bộ invitation của Agency | Happy path | Pass |
| TC-03 | Accept với token hợp lệ + đúng email | AC1, AC2 | 200; tạo `AgencyMember(MEMBER)`, invitation `ACCEPTED` | Happy path | Pass |
| TC-04 | Accept token không tồn tại | Error | `INVALID_INVITATION` | Error case | Pass |
| TC-05 | Accept invitation đã hết hạn | Edge (mục 7) | `INVALID_INVITATION`, KHÔNG tạo member | Edge case | Pass |
| TC-06 | Accept với email khác `invitedEmail` | Edge | `INVALID_INVITATION` | Edge case | Pass |
| TC-07 | Decline invitation hợp lệ | AC1 | 200; `status == REVOKED` | Happy path | Pass |

## Ghi chú

- AC3 = "Invitation tự hết hạn sau 3 ngày" — implement bằng filter `expiresAt > now` tại query/accept (không có job).
- DoD = "tự hết hạn sau 3 ngày chính xác (test clock giả lập)" — cover bằng TC-05.

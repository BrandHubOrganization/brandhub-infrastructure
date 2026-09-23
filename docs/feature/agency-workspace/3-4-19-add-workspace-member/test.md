# Test — Add Workspace Member (FR 3.4.19)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | MANAGER invite email hợp lệ, role CREATOR | AC3.1 | 200; invitation PENDING tạo, mail gửi | Happy path | Pass |
| TC-02 | Invitee accept token hợp lệ | Sequence-flow (nhánh phụ) | 200; `WorkspaceMember` tạo mới, invitation `status=ACCEPTED` | Happy path | Pass |
| TC-03 | MANAGER assign 2 user hợp lệ, đều là AgencyMember, chưa active trong workspace | AC3.2 | 200; `added` đủ 2, `skippedUserIds` rỗng | Happy path | Pass |
| TC-04 | Non-MANAGER gọi invite hoặc assign | Error (mục 6) | 403 `FORBIDDEN` | Error case | Pass |
| TC-05 | Invite email đã là active WorkspaceMember | Sequence-flow error | 409 `ALREADY_IN_WORKSPACE` | Error case | Pass |
| TC-06 | Invite email đã có invitation PENDING còn hạn | Edge (mục 7 spec cũ) | 409 `INVITATION_ALREADY_PENDING` | Error case | Pass |
| TC-07 | Invite `role=MANAGER` khi workspace đã có MANAGER active | Error (mục 6) | 409 `MANAGER_ALREADY_ASSIGNED` | Error case | Pass |
| TC-08 | Assign `role=MANAGER` khi workspace đã có MANAGER active | Error (mục 6) | 409 `MANAGER_ALREADY_ASSIGNED` | Error case | Pass |
| TC-09 | Assign `userId` không phải AgencyMember của agency | Error (mục 6) | 403 `NOT_AGENCY_MEMBER` | Error case | Pass |
| TC-10 | Assign `userId` không tồn tại trong `users` | Sequence-flow error | Lỗi `USER_NOT_FOUND` | Error case | Pass |
| TC-11 | Assign nhiều user, 1 user đã active sẵn | Edge (mục 7) | User đó vào `skippedUserIds`, không có trong `added`, batch còn lại xử lý bình thường, không throw | Edge case | Pass |
| TC-12 | Invite `email` sai định dạng / `role` thiếu | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-13 | Assign `members` rỗng | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-14 | Invite người đã có tài khoản nhưng chưa từng vào Agency này | Edge (mục 7) | 200; vẫn gửi được invite | Edge case | Pass |

## Ghi chú

- 2 luồng invite/assign độc lập, test đầy đủ cả 2 vì cả 2 đều đã code và trong scope FR 3.4.19.

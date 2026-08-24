# Test — Workspace Detail UX Fixes

## Backend Unit Test
| Case | Input | Expected |
|---|---|---|
| Mời khi đã có PENDING | Invite lại cùng email, invitation cũ còn hạn PENDING | 409 `INVITATION_ALREADY_PENDING`, không tạo bản ghi mới |
| Mời sau khi invitation cũ EXPIRED | invitation cũ PENDING nhưng `expiresAt` đã qua | Tạo invitation mới thành công |
| Mời sau khi invitation cũ DECLINED | invitation cũ status DECLINED | Tạo invitation mới thành công |
| Mời chính mình (đã active) | currentUser mời email chính họ, đã active trong ws | `ALREADY_IN_WORKSPACE` (hành vi hiện có, xác nhận không đổi) |
| listMyPendingInvitations | user có 2 invitation PENDING ở 2 ws khác nhau | trả đủ 2, đúng field workspaceName/invitedByName |
| declineInvitation | token hợp lệ, đang PENDING | status chuyển DECLINED, không tạo WorkspaceMember |

## Frontend Manual (Chrome DevTools)
1. Tạo workspace mới — không thấy Input múi giờ ở form settings.
2. Lưu settings workspace — Network tab: `timezone` trong body khớp
   timezone trình duyệt (vd `Asia/Ho_Chi_Minh`).
3. Vào `/workspaces/{id}/settings` — breadcrumb hiện tên workspace thật,
   không phải chuỗi UUID.
4. Tài khoản A (OWNER) mời email tài khoản B — toast thành công.
5. Tài khoản A mời lại đúng email B ngay lập tức — toast lỗi rõ ràng
   (INVITATION_ALREADY_PENDING), không tạo lời mời trùng.
6. Đăng nhập tài khoản B — vào Profile dropdown thấy mục "Lời mời", click
   vào `/invitations` — thấy lời mời từ A.
7. B bấm Accept — thành member workspace của A, invitation biến mất khỏi
   list.
8. Tài khoản A mời tài khoản C, C login vào `/invitations`, bấm Decline —
   invitation biến mất, C không thành member.
9. A mời lại C (đã decline trước đó) — thành công, không bị chặn nhầm.
10. `npx tsc --noEmit`, `npx eslint` trên file đã sửa: 0 lỗi.

## Pass Criteria
Case 5 (chặn mời trùng PENDING) và case 9 (không chặn nhầm sau decline) là
2 case quan trọng nhất — xác nhận bug fix đúng, không phá luồng hợp lệ.

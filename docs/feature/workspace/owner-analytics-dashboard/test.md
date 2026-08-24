# Test — Owner/Account Team Analytics Dashboard

## Backend
| Case | Input | Expected |
|---|---|---|
| GET /workspaces/my-managed đúng route | user OWNER 2 workspace | 200, list 2 item, không lỗi UUID parse |
| listAuditLogs scoped đúng workspace | 2 workspace có log khác nhau | chỉ trả log của workspace được query |
| listManagedWorkspaces filter đúng role | user có role OWNER 1 ws, CREATOR 1 ws khác | chỉ trả ws có role OWNER |
| listManagedWorkspaces user không quản lý gì | user chỉ CREATOR mọi nơi | trả mảng rỗng, 200 |
| listManagedAuditLogs rỗng không lỗi | user không quản lý workspace nào | trả Page rỗng, không query IN rỗng |
| audit-logs sai role | CREATOR gọi /{id}/audit-logs | 403 |

## Frontend Manual (Chrome DevTools)
1. Login OWNER — Sidebar không có Content Editor/Calendar, có mục "Tổng quan".
2. Login CREATOR — Sidebar có đủ Content Editor/Calendar, không có "Tổng quan".
3. OWNER vào `/analytics` — thấy bảng thành viên đúng số lượng thật, số liệu
   theo role đúng.
4. Trigger 1 hoạt động (vd invite member) rồi vào `/analytics` — audit log
   hiện đúng hoạt động vừa làm, mới nhất trên đầu.
5. CREATOR vào `/analytics` (gõ trực tiếp URL nếu cần) — không thấy 4 khối
   mới, giao diện y hệt bản gốc.
6. OWNER sở hữu ≥2 workspace, vào `/analytics/overview` — liệt kê đủ, tổng số
   liệu cộng dồn đúng.
7. Audit log gộp ở overview đúng thứ tự thời gian giữa các workspace khác
   nhau.
8. User không quản lý workspace nào, gõ thẳng URL `/analytics/overview` —
   hiện trạng thái rỗng, không crash/blank page.
9. Đổi theme dark/light + ngôn ngữ vi/en trên cả `/analytics` và
   `/analytics/overview`.
10. `npx tsc --noEmit`, `npx eslint` trên file đã sửa: 0 lỗi.

## Pass Criteria
Case "GET /workspaces/my-managed đúng route" ưu tiên cao nhất — xác nhận
route ordering không bị Spring nuốt nhầm thành path variable trước khi test
các case còn lại.

# Test — RBAC Middleware & Isolation

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Role đủ quyền | OWNER gọi API `@RequireRole({OWNER,MANAGER})` | 200, thực thi bình thường | ☐ |
| 2 | Role không đủ quyền | CLIENT gọi API `@RequireRole({OWNER,MANAGER})` | 403 INSUFFICIENT_ROLE | ☐ |
| 3 | Không phải member workspace | User chưa từng join workspace gọi API | 403 WORKSPACE_ACCESS_DENIED (không 404) | ☐ |
| 4 | Truy cập workspace khác | JWT workspaceId=A, resource thuộc workspaceId=B | 403 WORKSPACE_ACCESS_DENIED | ☐ |
| 5 | SystemRole ADMIN bypass | ADMIN gọi API `@RequireRole({OWNER})` dù ADMIN không phải OWNER | 200, bypass check | ☐ |
| 6 | Permission override granted=false | Role đủ quyền theo matrix nhưng có override granted=false | 403 INSUFFICIENT_ROLE | ☐ |
| 7 | Member bị deactivate | `workspace_members.isActive=false` nhưng JWT cũ còn hạn | 403 WORKSPACE_ACCESS_DENIED (re-check DB) | ☐ |
| 8 | Isolation query list | User workspace A query danh sách resource | Chỉ trả record của workspace A | ☐ |
| 9 | CLIENT xem client khác | BRAND_CLIENT của clientId=X gọi API data clientId=Y | 403 | ☐ |
| 10 | CLIENT xem đúng client mình | BRAND_CLIENT clientId=X gọi API data clientId=X | 200 | ☐ |

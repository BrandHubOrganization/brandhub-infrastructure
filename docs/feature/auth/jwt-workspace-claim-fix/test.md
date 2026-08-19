# Test — Fix JWT thiếu claim workspaceId

## Unit Test
| Case | Input | Expected |
|---|---|---|
| login có workspace | user là member active của workspace X | access token decode có `workspaceId = X` |
| login không workspace | user chưa join workspace nào | access token decode có `workspaceId = null` |
| refresh có workspace | refresh token hợp lệ, user có workspace | access token mới có đúng `workspaceId` |
| OAuth callback login-mode | user OAuth có workspace | access token có đúng `workspaceId` |

## Manual (Chrome DevTools)
1. Login `brandhub404@gmail.com`/`Test1234` (đã là OWNER của workspace).
2. Decode access token (jwt.io hoặc base64 decode payload) — xác nhận có
   claim `workspaceId` khớp đúng workspace user đang OWNER.
3. Gọi `PATCH /workspaces/{id}/settings` với `id` = workspace đó — 200, không
   còn 403 `WORKSPACE_ACCESS_DENIED`.
4. Test lại toggle Report frequency trên `WorkspaceSettingsPage` (từ feature
   `workspace-detail-enum-fields`) — lưu thành công, F5 giữ đúng trạng thái.

## Pass Criteria
Case 3 là điều kiện tiên quyết để hoàn thành test case còn treo của
`workspace-detail-enum-fields/test.md` case 6 (toggle reportFrequency lưu +
F5).

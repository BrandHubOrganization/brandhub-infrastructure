# Spec — Fix JWT thiếu claim workspaceId (bug nghiêm trọng, chặn toàn bộ @RequireRole)

## Objective
Phát hiện khi test tính năng `workspace-detail-enum-fields`: mọi request PATCH
`/workspaces/{id}/settings` qua HTTP thật đều trả 403 `WORKSPACE_ACCESS_DENIED`,
bất kể user có đúng role OWNER trong workspace đó hay không.

Root cause: `AuthServiceImpl.login()` (dòng 177), `AuthServiceImpl.refresh()`
(dòng 215), và `OAuthService.handleCallback()` (dòng 150) đều gọi
`jwtUtil.generateAccessToken(userId, role, null)` — **truyền cứng `null`** cho
tham số `workspaceId`. `JwtUtil.generateAccessToken` có hỗ trợ set claim
`workspaceId` vào token nhưng không bao giờ được gọi với giá trị thật.

Hệ quả: `JwtAuthenticationFilter` đọc claim `workspaceId` từ token → luôn
`null` → `AuthenticatedUser.getWorkspaceId()` luôn `null` với MỌI user, MỌI
token, kể cả token vừa login mới nhất. `RequireRoleAspect.checkRole()` query
`workspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue(null,
userId)` → luôn rỗng → luôn ném `WORKSPACE_ACCESS_DENIED`.

**Mọi endpoint có `@RequireRole` không bao giờ hoạt động được với user thật
qua HTTP**: `WorkspaceController.updateSettings`, `.uploadLogo`,
`.inviteMember`, `.removeMember`. Bug này tồn tại từ trước, không liên quan
đến các feature enum/logo vừa làm — chỉ bị phát hiện vì đây là lần đầu có
test thủ công qua trình duyệt thật cho các endpoint này.

## User Story
Là user đã login với role OWNER trong workspace X, tôi muốn gọi được các API
cần quyền OWNER (đổi settings, mời thành viên, xoá thành viên, đổi logo) mà
không bị từ chối sai.

## Acceptance Criteria
- Sau khi login (password hoặc OAuth) hoặc refresh token, access token JWT
  phải mang claim `workspaceId` là workspace mà user đang là member active
  gần nhất/đầu tiên (không có khái niệm "workspace đang chọn" ở tầng JWT
  hiện tại — theo đúng thiết kế `rbac-middleware/spec.md` mục 7: "JWT chỉ
  mang 1 workspaceId tại một thời điểm").
- User không thuộc workspace nào (mới đăng ký, chưa tạo/join workspace nào)
  → claim `workspaceId` là `null` — hành vi hợp lệ, không lỗi login.
- Sau khi user tạo workspace mới hoặc được mời vào workspace khác, JWT cũ
  KHÔNG tự cập nhật (đúng thiết kế hiện tại, out of scope đổi — ghi nhận ở
  `rbac-middleware/spec.md`) — user cần gọi lại `/auth/refresh` hoặc
  login lại để lấy JWT phản ánh workspace mới nhất.
- `PATCH /workspaces/{id}/settings`, `POST /workspaces/{id}/logo`,
  `POST /workspaces/{id}/members/invite`, `DELETE
  /workspaces/{id}/members/{memberId}` hoạt động đúng (200, không còn 403
  sai) khi user thật đúng role gọi qua HTTP sau khi có JWT claim đúng.

## API Contract
Không đổi endpoint nào — chỉ đổi logic nội bộ tạo JWT ở `AuthServiceImpl`,
`OAuthService`. Response `/auth/login`, `/auth/refresh` giữ nguyên shape
`LoginResponse{accessToken, tokenType, expiresIn}`.

## Error Handling
- User có nhiều hơn 1 workspace active — chọn 1 (workspace tạo/join sớm
  nhất theo `joinedAt`, hoặc bất kỳ — không có tiêu chí "current workspace"
  ở tầng backend hiện tại nên chọn deterministic nào cũng chấp nhận được,
  quyết định: lấy theo `joinedAt` cũ nhất, ổn định, dễ test).
- User không có workspace nào → `workspaceId = null` trong token, các
  endpoint `@RequireRole` vẫn 403 đúng như spec (không có workspace để có
  quyền) — không phải bug.

## Edge Cases
- `WorkspaceMemberRepository` query cho user chưa từng join workspace nào →
  `Optional.empty()` → truyền `null` cho `generateAccessToken`, không throw.
- OAuth login lần đầu (user mới tạo qua Google/GitHub) → tương tự, chưa có
  workspace, `null` hợp lệ.
- Refresh token khi user vừa bị remove khỏi workspace duy nhất giữa lúc JWT
  cũ còn hạn → token mới sau refresh sẽ có `workspaceId = null` (đúng, phản
  ánh trạng thái mới nhất — khớp nguyên tắc "re-check DB mỗi request" của
  `rbac-middleware/spec.md`).

## UI States
Không có UI thay đổi — đây là bug fix backend thuần túy.

## i18n
Không áp dụng (không có UI mới).

## Light/Dark mode
Không áp dụng.

## Test Cases (sơ bộ)
1. User có workspace, login → decode JWT access token, xác nhận claim
   `workspaceId` khớp `workspace_members.workspace_id` của user đó.
2. User không có workspace nào, login → claim `workspaceId` là `null`,
   login vẫn thành công (200).
3. Refresh token cho user có workspace → access token mới có đúng claim.
4. User join thêm workspace thứ 2 → JWT hiện tại (chưa refresh) vẫn giữ
   workspace cũ (không tự đổi — đúng thiết kế).
5. Integration test thật: login → dùng access token gọi `PATCH
   /workspaces/{id}/settings` (đúng workspace, đúng role OWNER) → 200,
   không còn 403.
6. `WorkspaceServiceTest` (unit, mock trực tiếp `AuthenticatedUser`) không
   bị ảnh hưởng — vẫn pass như cũ, đây là integration-level fix.

## Definition of Done
- `AuthServiceImpl.login`/`refresh`, `OAuthService.handleCallback` inject
  `WorkspaceMemberRepository`, truyền `workspaceId` thật thay vì `null`.
- Unit test mới cho `AuthServiceImpl` xác nhận claim đúng (mock repository).
- `mvn -o compile`/`test` pass toàn bộ (không chỉ `WorkspaceServiceTest`).
- Verify thủ công qua Chrome DevTools: login → decode JWT → gọi PATCH
  settings → 200.

## Out of Scope
- Cơ chế "switch active workspace" tự cập nhật JWT không cần re-login (đã
  ghi nhận out-of-scope trong `rbac-middleware/spec.md`, không đổi ở đây).
- Đổi cấu trúc JWT sang mang nhiều workspace (multi-tenant token) — thiết kế
  lớn hơn, ngoài phạm vi bug fix này.

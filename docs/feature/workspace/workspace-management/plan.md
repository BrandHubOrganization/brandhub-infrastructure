# Plan — Quản lý Workspace (Create / Settings / Members)

## Mục tiêu
Xây API backend Workspace từ đầu (chưa tồn tại) + 3 trang frontend Create/Settings/Members, thay `WorkspacePage.tsx` hardcode bằng data thật.

## Thành phần liên quan
**Backend (mới hoàn toàn):**
- `repository/WorkspaceRepository.java`, `repository/WorkspaceInvitationRepository.java`, `repository/WorkspaceMemberPermissionRepository.java` — chưa tồn tại, tạo mới (JpaRepository chuẩn).
- `service/WorkspaceService.java` + `service/impl/WorkspaceServiceImpl.java`.
- `controller/WorkspaceController.java` — theo pattern `AdminController.java` (thin, `ApiResponse<T>` return).
- `dto/request/CreateWorkspaceRequest.java`, `UpdateWorkspaceSettingsRequest.java`, `InviteMemberRequest.java`, `dto/response/WorkspaceResponse.java`, `WorkspaceMemberResponse.java`.
- Slug generator util (kebab-case + unique suffix) — kiểm tra `util/` package có sẵn helper string chưa trước khi viết mới.
- Email gửi invitation — kiểm tra service email hiện có (dùng cho forgot-password) có tái dùng được không trước khi viết mới.

**Frontend:**
- `src/services/workspaceService.ts` — theo pattern `authService.ts`.
- `src/types/workspace.ts` — sửa lại khớp backend: bỏ `logo`/`description`/`subscriptionId`, thêm `slug`, `logoUrl`, `isActive`, `updatedAt`. Thêm `WorkspaceMember`, `MemberRole` type mới (chưa có).
- `src/pages/workspaces/CreateWorkspacePage.tsx`, `WorkspaceSettingsPage.tsx`, `WorkspaceMembersPage.tsx` (route `/workspaces/create`, `/workspaces/:id/settings`, `/workspaces/:id/members`) — theo pattern `ChangePasswordPage.tsx`.
- `src/pages/WorkspacePage.tsx` — sửa: gọi `workspaceService.list()` thay `WORKSPACES` hardcode; nút "Tạo Workspace Mới" wire `navigate('/workspaces/create')`.
- Route mới trong `App.tsx` hoặc router config hiện tại (đọc `App.tsx` trước khi thêm, theo đúng convention route hiện có).
- `src/i18n/locales/vi.json`, `src/i18n/locales/en.json` — thêm namespace `workspace.*` (danh sách key đầy đủ ở spec.md mục 3).

## Quyết định kiến trúc
- `settings` (jsonb) lưu object tự do phía Postgres — Java DTO map tường minh field `timezone`, `defaultPlatforms`, `reportFrequency` thay vì `Map<String,Object>` tự do, để có validation.
- Soft-delete member (`isActive=false`) — không hard delete, giữ lịch sử audit.
- `POST /workspaces` không cần `@RequireRole` (user nào cũng tạo được workspace mới, trở thành OWNER) — các endpoint còn lại cần.
- Frontend role type: đổi `UserRole` trong `authStore.ts` sang `MemberRole` (OWNER/CREATOR/VIEWER/CLIENT/ACCOUNT) — việc sửa `authStore` là prerequisite chung cho cả Workspace pages và RBAC UI-gating, nên làm sớm trong nhánh này.

## Thứ tự build
1. Backend: slug util, repository, DTOs, service `createWorkspace` (kèm tạo OWNER member tự động).
2. Backend: `POST /workspaces` + `GET /workspaces/{id}` + controller, test tay qua curl/Postman.
3. Backend: `PATCH /workspaces/{id}/settings` (cần RBAC feature xong song song để gắn `@RequireRole`; nếu RBAC chưa xong, tạm code TODO annotation, gắn sau).
4. Backend: members list/invite/remove + validate "không xoá OWNER cuối".
5. Frontend: sửa `authStore.ts` role type trước.
6. Frontend: `workspaceService.ts` + sửa `types/workspace.ts`.
7. Frontend: `CreateWorkspacePage` → test luồng tạo thật qua backend vừa xong.
8. Frontend: `WorkspaceSettingsPage`, `WorkspaceMembersPage`.
9. Frontend: sửa `WorkspacePage.tsx` dùng API thật.
10. Test toàn luồng qua Chrome DevTools: tạo workspace → vào settings sửa → vào members mời/xoá.

## Rủi ro
- JWT chỉ mang 1 `workspaceId` cố định — tạo workspace mới xong cần cách nào đó cập nhật context (refresh token hoặc client tự set active workspace tạm thời phía FE mà chưa đổi JWT) — cần quyết định cụ thể khi code tới bước 7, có thể cần thêm endpoint `POST /auth/switch-workspace` (ngoài scope hiện tại, ghi nhận rủi ro).
- Phụ thuộc RBAC middleware (branch khác, repo khác) — nếu RBAC chưa merge, Settings/Members endpoint tạm không có annotation, phải quay lại gắn sau (task riêng, không block frontend build UI trước).
- Email invitation cần xác nhận có sẵn `EmailService`/`MailService` hay chưa (dùng cho forgot-password) — nếu chưa generic hoá được, có thể phải tạo template mới.

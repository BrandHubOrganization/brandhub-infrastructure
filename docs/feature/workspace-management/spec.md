# UC — Quản lý Workspace (Create / Settings / Members)

| | |
|---|---|
| Feature | Workspace management |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | B. Chức năng workspace |

## 1. Objective

Cho phép user tạo workspace mới, chỉnh sửa cài đặt workspace, và quản lý member (mời/xem/xoá). Đây là nền tảng multi-tenant của hệ thống — mọi nội dung/data khác đều gắn với 1 workspace.

**Lưu ý phạm vi:** backend hiện chưa có bất kỳ endpoint/service/repository nào cho Workspace (chỉ có entity + 1 repo method dùng cho login). Feature này bao gồm cả xây dựng API backend lẫn 3 trang frontend — không chỉ UI.

## 2. User Story

Là một user đã đăng nhập,
tôi muốn tạo workspace mới, cấu hình cài đặt, và quản lý thành viên,
để tổ chức công việc nhóm/agency của mình trên BrandHub.

## 3. Acceptance Criteria

### Create Workspace (DA-323)
- Form nhập `name` (bắt buộc) + `industry` (dropdown, theo yêu cầu task Jira).
- Submit thành công → tạo `Workspace` (owner = user hiện tại), tự động tạo `WorkspaceMember` với `role=OWNER` cho user đó, redirect vào workspace vừa tạo.
- `slug` tự sinh từ `name` (kebab-case, đảm bảo unique — thêm suffix số nếu trùng).

### Workspace Settings (DA-576)
- Trang settings hiển thị + cho sửa: `name`, `timezone`, `defaultPlatforms` (mảng nền tảng mặc định: Facebook/Instagram/TikTok/LinkedIn...), `reportFrequency`. Các field này lưu trong cột `settings` (jsonb) của `Workspace`.
- Chỉ `OWNER`/`ACCOUNT` được sửa settings (RBAC — phụ thuộc rbac-middleware feature).
- Lưu thành công → toast confirm, không cần reload trang.

### Workspace Members (DA-577)
- Bảng danh sách member: tên, email, role, ngày tham gia, trạng thái active.
- Nút "Mời thành viên" → tạo `WorkspaceInvitation` (email + role), gửi email mời (tái dùng hạ tầng email đã có ở forgot-password nếu có sẵn service gửi mail — kiểm tra trước khi build mới).
- Nút xoá member (có confirm dialog) → set `workspace_members.isActive=false` (soft delete, giữ lịch sử) — không xoá cứng record.
- Chỉ `OWNER`/`ACCOUNT` thấy nút mời/xoá; `CREATOR`/`VIEWER`/`CLIENT` chỉ xem danh sách (RBAC).
- Không cho xoá `OWNER` cuối cùng của workspace (luôn phải còn ít nhất 1 OWNER).

### Đa ngôn ngữ (i18n)
Toàn bộ text mới dùng key namespace `workspace.*`, thêm song song cả `vi.json` và `en.json`:
- `workspace.create.title`, `workspace.create.nameLabel`, `workspace.create.industryLabel`, `workspace.create.submit`
- `workspace.settings.title`, `workspace.settings.timezoneLabel`, `workspace.settings.defaultPlatformsLabel`, `workspace.settings.reportFrequencyLabel`, `workspace.settings.saveSuccess`
- `workspace.members.title`, `workspace.members.inviteButton`, `workspace.members.removeConfirm`, `workspace.members.roleLabel`, `workspace.members.joinedAtLabel`
- `workspace.errors.slugConflict`, `workspace.errors.lastOwnerCannotBeRemoved`, `workspace.errors.alreadyMember`
- Không hardcode chuỗi tiếng Việt/Anh trong JSX của 3 trang mới hay trong `WorkspacePage.tsx` sau khi sửa.

### Light/Dark mode
3 trang mới dùng token theme sẵn có (`bg-background`, `text-foreground`, `border-input`, v.v. — theo đúng class đã dùng ở `ChangePasswordPage.tsx`/auth pages), không hardcode màu hex/rgb cố định. Bảng member, badge role, dialog confirm xoá phải kiểm tra tương phản ở cả 2 theme trước khi coi hoàn thành.

## 4. UI / UX

- 3 trang riêng: `/workspaces/create`, `/workspaces/:id/settings`, `/workspaces/:id/members`.
- Theo pattern `PageWrapper` + form local state + `loading`/`toast` đã dùng ở `ChangePasswordPage.tsx` — không phát minh pattern mới.
- `WorkspacePage.tsx` hiện tại (danh sách workspace, đang hardcoded `WORKSPACES` array) — nút "Tạo Workspace Mới" cần wire sang `/workspaces/create`; danh sách cần đổi từ hardcode sang gọi API thật (nằm trong scope vì nếu không sửa, trang Create/Settings/Members mới không có lối vào thực tế).

### UI States
- Loading: skeleton hoặc disable form khi submit.
- Success: toast + redirect (Create) hoặc toast tại chỗ (Settings).
- Error: hiển thị message theo `extractErrorMessage`.
- Empty: Members page — workspace mới chỉ có 1 member (owner) — không coi là empty state đặc biệt, vẫn hiển thị bảng 1 dòng.

## 5. API Contract (dự kiến, backend cần xây mới hoàn toàn)

```
GET /api/v1/workspaces
(list toàn bộ workspace mà user hiện tại đang là active member — phát hiện thiếu lúc code WorkspacePage.tsx, bổ sung sau bản đầu)
→ 200 { "success": true, "data": [{ "id", "name", "slug", "logoUrl", "settings", "isActive", "createdAt" }] }

POST /api/v1/workspaces
{ "name": "string", "industry": "string" }
→ 201 { "success": true, "data": { "id", "name", "slug", "ownerId" } }

GET /api/v1/workspaces/{id}
→ 200 { "success": true, "data": { "id", "name", "slug", "logoUrl", "settings", "isActive", "createdAt" } }

PATCH /api/v1/workspaces/{id}/settings
{ "name"?, "timezone"?, "defaultPlatforms"?, "reportFrequency"? }
→ 200 { "success": true, "data": { ...updated workspace... } }

GET /api/v1/workspaces/{id}/members
→ 200 { "success": true, "data": [{ "id", "userId", "fullName", "email", "role", "joinedAt", "isActive" }] }

POST /api/v1/workspaces/{id}/members/invite
{ "email": "string", "role": "OWNER|CREATOR|VIEWER|CLIENT|ACCOUNT" }
→ 201 { "success": true, "data": { "invitationId", "token" } }

DELETE /api/v1/workspaces/{id}/members/{memberId}
→ 200 { "success": true, "data": null }
```

Tất cả endpoint trừ `POST /workspaces` yêu cầu `@RequireRole` phù hợp — phụ thuộc rbac-middleware feature đã build trước hoặc song song.

## 6. Error Handling

- `name` trống → 400 `VALIDATION_ERROR`.
- Slug trùng sau khi thử suffix → 409 `WORKSPACE_SLUG_CONFLICT` (hiếm, retry tự động với suffix khác trước khi trả lỗi).
- Xoá `OWNER` cuối cùng → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.
- Mời email đã là member active → 409 `ALREADY_MEMBER`.
- Không đủ quyền (không phải OWNER/ACCOUNT) → 403 `INSUFFICIENT_ROLE` (từ RBAC middleware).

## 7. Edge Cases

- User tạo workspace đầu tiên — chưa có `workspaceId` trong JWT trước đó → sau khi tạo cần refresh token hoặc trả kèm `workspaceId` mới để frontend cập nhật `authStore` (JWT hiện tại mang 1 `workspaceId` cố định — cần xác nhận flow refresh khi build, ghi trong plan.md).
- Mời lại email đã từng bị remove (isActive=false) trước đó → cho phép, tạo lại invitation, khi accept thì set `isActive=true` lại trên record cũ (không tạo record `WorkspaceMember` trùng).
- `defaultPlatforms` rỗng → cho phép lưu rỗng, không bắt buộc.

## 8. Definition of Done

- Toàn bộ Acceptance Criteria mục 3 đạt.
- Backend: `WorkspaceController`, `WorkspaceService`, `WorkspaceRepository`, `WorkspaceInvitationRepository`, DTOs đầy đủ, có `@RequireRole` áp đúng theo RBAC feature.
- Frontend: `workspaceService.ts`, 3 trang mới, `WorkspacePage.tsx` gọi API thật thay hardcode, `types/workspace.ts` khớp field backend.
- Test case mục test.md pass.
- Không lỗi console/network nghiêm trọng, `tsc --noEmit` clean.

## Out of Scope

- Upload logo workspace (giữ `logoUrl` field nhưng chưa làm UI upload — theo dõi task riêng nếu cần).
- Billing/subscription liên kết workspace (`WorkspaceSubscription`) — feature riêng.
- Chấp nhận lời mời (accept invitation flow, trang riêng cho người được mời) — out of scope 3 task này, cần task riêng nếu chưa có.

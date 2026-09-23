# Sequence Flow — Update Workspace Profile

> Bổ sung cho `spec.md` (FR 3.4.14). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.updateSettings`/`uploadLogo`, `WorkspaceServiceImpl`).

## Actors

- **MANAGER** — thành viên role MANAGER của Workspace.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspaces`).
- **Storage** — file storage service (logo upload).

---

## Flow A — Cập nhật settings/thông tin Workspace

1. MANAGER → FE: mở `/workspaces/:id/profile/edit`, sửa `name`/`timezone`/`defaultPlatforms`/`industry`/`companySize`/`website`/`phone`/`location`.
2. FE → BE: `PATCH /api/v1/workspaces/{workspaceId}/settings` (kèm các field muốn đổi, field nào không gửi giữ nguyên).
3. BE: `@RequireRole({MemberRole.MANAGER})` chặn trước khi vào controller — không phải MANAGER của workspace này → `403 FORBIDDEN`.
4. BE (`WorkspaceServiceImpl.updateSettings`):
   a. `findWorkspaceOrThrow(workspaceId)` — không tồn tại → `404 WORKSPACE_NOT_FOUND`.
   b. Nếu `name` không blank → set `workspace.name`.
   c. Parse `settings` JSON hiện tại, merge `timezone`/`defaultPlatforms` mới (field nào null trong request giữ giá trị cũ).
   d. Ghi lại `settings` (serialize JSON).
   e. Set `industry`/`companySize`/`website`/`phone`/`location` nếu request có truyền (không null).
   f. `updatedAt = now()`.
5. BE → DB: `UPDATE workspaces`.
6. BE → FE: `200 { data: WorkspaceResponse }` (đã cập nhật).
7. FE: hiển thị toast thành công, cập nhật UI.

## Flow B — Cập nhật logo Workspace (endpoint riêng)

1. MANAGER → FE: chọn file ảnh logo, submit.
2. FE → BE: `POST /api/v1/workspaces/{workspaceId}/logo` (multipart/form-data, field `file`).
3. BE: `@RequireRole({MemberRole.MANAGER})` chặn — không phải MANAGER → `403 FORBIDDEN`.
4. BE (`WorkspaceServiceImpl.updateLogo`):
   a. `findWorkspaceOrThrow(workspaceId)` — không tồn tại → `404 WORKSPACE_NOT_FOUND`.
   b. Đọc bytes file (`file.getBytes()`) — lỗi IO → bắt `IOException`, ném `BusinessException(ErrorCode.FILE_READ_ERROR)` → `400 FILE_READ_ERROR`.
   c. → Storage: `fileStorageService.uploadWorkspaceLogo(workspaceId, bytes, contentType)` → trả về `url`.
   d. Set `workspace.logoUrl = url`, `updatedAt = now()`.
5. BE → DB: `UPDATE workspaces`.
6. BE → FE: `200 { data: WorkspaceResponse }` (có `logoUrl` mới).
7. FE: hiển thị logo mới.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Update settings / Upload logo | Không phải MANAGER của Workspace này | 403 | `FORBIDDEN` (chặn qua `@RequireRole`) |
| Update settings / Upload logo | Workspace không tồn tại | 404 | `WORKSPACE_NOT_FOUND` |
| Upload logo | Lỗi đọc file (IOException) | 400 | `FILE_READ_ERROR` |

## Ghi chú khác biệt so với spec.md gốc

- Không có — spec.md và sequence-flow đã khớp code thật (`updateSettings`, `updateLogo`).

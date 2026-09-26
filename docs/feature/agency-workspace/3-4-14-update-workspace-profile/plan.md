# Plan — Update Workspace Profile (FR 3.4.14)

> Liên kết: [spec.md](spec.md) — cho MANAGER cập nhật thông tin/settings/logo của Workspace.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.updateSettings()`, `WorkspaceServiceImpl.updateLogo()` |
| File đã có | `WorkspaceController` (`PATCH /{workspaceId}/settings`, `POST /{workspaceId}/logo`), `UpdateWorkspaceSettingsRequest`, `FileStorageService` |

## 2. API Contract (final)

```
PATCH /api/v1/workspaces/{workspaceId}/settings
Body: { name?, timezone?, defaultPlatforms?, industry?, companySize?, website?, phone?, location? }
→ 200 ApiResponse<WorkspaceResponse>

POST /api/v1/workspaces/{workspaceId}/logo
Body: multipart/form-data, field "file"
→ 200 ApiResponse<WorkspaceResponse>
```

Cả 2 endpoint bảo vệ bởi `@RequireRole({MemberRole.MANAGER})`. Không lệch spec.md.

## 3. Data Model

- `UPDATE workspaces`: set `name` (nếu không blank), merge `settings` JSON (`timezone`/`defaultPlatforms`, field null giữ nguyên), set `industry`/`companySize`/`website`/`phone`/`location` (nếu request có truyền), `updatedAt = now()`.
- Logo: đọc bytes file → `fileStorageService.uploadWorkspaceLogo` → set `logoUrl`, `updatedAt = now()`.
- Không migration.

## 4. Luồng xử lý

**Flow A — settings:**
1. `@RequireRole(MANAGER)` chặn ở tầng controller.
2. `findWorkspaceOrThrow` → 404.
3. Merge field theo request (partial update, field null giữ nguyên).
4. Save.

**Flow B — logo:**
1. `@RequireRole(MANAGER)` chặn.
2. `findWorkspaceOrThrow` → 404.
3. `file.getBytes()` — `IOException` → 400 `FILE_READ_ERROR`.
4. Upload storage → set `logoUrl`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Workspace` entity, `FileStorageService` (đã có) |
| Bị chặn | Không |

## 6. Rủi ro kỹ thuật

- **Đổi `timezoneConfig` không cảnh báo ảnh hưởng Task/Livestream đã lên lịch** (Edge case mục 7 trong spec.md) — chưa có validate/cảnh báo ở BE, cần FE tự xử lý cảnh báo trước khi gọi API, hoặc bổ sung sau.
- **Update qua PATCH true-partial** (field null giữ nguyên) khác với Update Agency Profile (dùng PUT, full-update) — 2 pattern khác nhau giữa Agency và Workspace, cần lưu ý khi FE tích hợp cả 2.
- **`@RequireRole` không check đúng "MANAGER của chính workspace này" nếu aspect chỉ check role chung** — cần xác nhận aspect có resolve đúng theo `{workspaceId}` path variable hay không (khác với `getWorkspace`/`listMembers` phải check thủ công vì lý do này).

# Plan — Save Workspace Template (FR 3.4.17)

> Liên kết: [spec.md](spec.md) — cho user lưu cấu hình Workspace thành Template, resource độc lập `/api/v1/workspace-templates`. Không có thay đổi code trong lần đồng bộ này. ⚠ BA conflict: `WorkspaceTemplateServiceImpl` hiện tại mọi method (`saveTemplate`/`listTemplates`/`getTemplate`/`deleteTemplate`) đều `throw new UnsupportedOperationException("Not implemented yet")` — Controller/DTO/FE đã wired đúng contract dưới đây nhưng backend chưa thực sự chạy được. Mục 2-4 dưới đây mô tả **contract dự kiến/đã thiết kế**, không phải hành vi runtime thật hiện tại.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceTemplateController`, `WorkspaceTemplateServiceImpl` (tên service suy theo pattern chung, xác nhận qua Grep controller) |
| File đã có | `WorkspaceTemplate` entity, `WorkspaceTemplateResponse` |

## 2. API Contract (final)

```
POST   /api/v1/workspace-templates            { name, sourceWorkspaceId?, configSnapshot } → 200 WorkspaceTemplateResponse
GET    /api/v1/workspace-templates             → 200 [WorkspaceTemplateResponse]
GET    /api/v1/workspace-templates/{templateId} → 200 WorkspaceTemplateResponse
DELETE /api/v1/workspace-templates/{templateId} → 200 null
```

Không lệch spec.md. Resource độc lập, KHÔNG nested dưới `/agencies/{id}` hay `/workspaces/{id}`.

## 3. Data Model

- `workspace_templates`: `id`, `agencyId` (tự set theo currentUser), `name`, `sourceWorkspaceId` (optional), `configSnapshot` (JSON string), `createdBy` (tự set), `createdAt`.
- `configSnapshot` độc lập với vòng đời Workspace gốc — Workspace gốc bị xóa không ảnh hưởng Template đã lưu.
- Không migration (entity đã có).

## 4. Luồng xử lý

1. Create: validate `name`/`configSnapshot` không trống → 400 `VALIDATION_ERROR`; set `agencyId`/`createdBy` tự động theo currentUser; insert.
2. List: query theo `agencyId` của currentUser (hoặc phạm vi service quy định).
3. Detail: tìm theo `id` — không có → 404 `NOT_FOUND`.
4. Delete: tìm theo `id` — không có → 404 `NOT_FOUND`; xóa cứng record (không soft-delete).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Không |
| Bị chặn | `Create Workspace` (3.4.12) — chiều ngược, dùng Template để tạo Workspace mới là mở rộng UX, không bắt buộc trong CSV hiện tại |

## 6. Rủi ro kỹ thuật

- **Không có `@RequireRole` giới hạn cụ thể trên 4 endpoint** — spec.md tự ghi nhận "cần double-check với BE liệu có giới hạn quyền theo Agency/role dự kiến hay chưa". Rủi ro: bất kỳ user đã đăng nhập nào cũng gọi được list/detail template của Agency khác nếu không có filter theo `agencyId` đúng ở tầng service — cần xác nhận lại query List có filter đúng scope Agency của currentUser hay không.
- **Detail/Delete dùng `404 NOT_FOUND` chung** thay vì ErrorCode riêng cho template (khác pattern `WORKSPACE_NOT_FOUND`/`AGENCY_NOT_FOUND` các FR khác) — nên thống nhất naming nếu cần đồng bộ ErrorCode toàn hệ thống.
- **Xóa cứng (không soft-delete)** — khác pattern soft-delete phổ biến trong domain Workspace/Agency; chấp nhận vì Template không phải dữ liệu nghiệp vụ quan trọng cần khôi phục.

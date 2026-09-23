# UC — Save Workspace Template

| | |
|---|---|
| FR Code | 3.4.17 |
| Feature | Save Workspace Template |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Agency member đã đăng nhập (chưa có `@RequireRole` giới hạn cụ thể trong code) |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Cho phép user lưu lại cấu hình 1 Workspace hiện có thành Template (resource độc lập `/api/v1/workspace-templates`) để tái sử dụng, xem, và xóa sau này.

## 2. User Story

Là một thành viên Agency,
tôi muốn lưu cấu hình Workspace hiện tại thành template,
để tạo Workspace mới tương tự nhanh hơn trong tương lai.

## 3. Acceptance Criteria

- Tạo `WorkspaceTemplate` gồm: `name` (bắt buộc), `sourceWorkspaceId` (optional, Workspace gốc), `configSnapshot` (bắt buộc, chuỗi JSON snapshot cấu hình).
- `WorkspaceTemplate` KHÔNG nested dưới `/agencies/{id}` hay `/workspaces/{id}` — là resource riêng biệt `/api/v1/workspace-templates`, có 4 endpoint: tạo (POST), danh sách (GET), chi tiết (GET /{templateId}), xóa (DELETE /{templateId}).
- `agencyId` và `createdBy` được set tự động theo `currentUser` (không truyền trong request body).

## 4. UI / UX

- Nút trong Workspace Settings; danh sách Template hiển thị ở trang riêng cho template (không phải nested `/agencies/:id/workspace-templates`).

## 5. API Contract

```
POST /api/v1/workspace-templates
{ "name": "string", "sourceWorkspaceId"?: "uuid", "configSnapshot": "string" }
→ 200 { "success": true, "data": WorkspaceTemplateResponse }

GET /api/v1/workspace-templates
→ 200 { "success": true, "data": [WorkspaceTemplateResponse, ...] }

GET /api/v1/workspace-templates/{templateId}
→ 200 { "success": true, "data": WorkspaceTemplateResponse }

DELETE /api/v1/workspace-templates/{templateId}
→ 200 { "success": true, "data": null }
```

`WorkspaceTemplateResponse` gồm: `id`, `agencyId`, `name`, `sourceWorkspaceId`, `configSnapshot`, `createdBy`, `createdAt`.

## 6. Error Handling

- `name` hoặc `configSnapshot` trống → 400 `VALIDATION_ERROR`.
- Không có `@RequireRole` cụ thể trên các endpoint này trong code hiện tại — cần double-check với BE liệu có giới hạn quyền theo Agency/role dự kiến hay chưa.

## 7. Edge Cases

- Workspace gốc (`sourceWorkspaceId`) bị xóa sau khi đã lưu Template → Template vẫn tồn tại độc lập (`configSnapshot` không phụ thuộc Workspace gốc còn sống hay không).

## 8. Definition of Done

- Lưu/xem/xóa Template thành công qua `/api/v1/workspace-templates`, dùng lại được khi tạo Workspace mới.

## Out of Scope

- Chia sẻ Template giữa các Agency khác nhau (chỉ trong phạm vi 1 Agency theo CSV).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

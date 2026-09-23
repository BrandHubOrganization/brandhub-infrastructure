# Sequence Flow — Save Workspace Template

> Bổ sung cho `spec.md` (FR 3.4.17). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceTemplateController`, service tương ứng — xác nhận qua Grep controller `/api/v1/workspace-templates`).

## Actors

- **User** — thành viên Agency đã đăng nhập (không có `@RequireRole` giới hạn cụ thể trong code).
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspace_templates`).

---

## Flow A — Tạo Template từ Workspace hiện có

1. User → FE: trong Workspace Settings, bấm "Lưu thành Template", điền `name`, `configSnapshot` (JSON snapshot cấu hình hiện tại, FE tự build từ `WorkspaceResponse` đang xem), `sourceWorkspaceId` (optional, workspace gốc).
2. FE → BE: `POST /api/v1/workspace-templates` `{name, sourceWorkspaceId?, configSnapshot}`.
3. BE:
   a. Validate `name`/`configSnapshot` không trống (`@Valid`) — trống → `400 VALIDATION_ERROR`.
   b. `agencyId` và `createdBy` set tự động theo `currentUser` (không lấy từ request body).
   c. `INSERT workspace_templates`.
4. BE → DB: 1 INSERT.
5. BE → FE: `200 { data: WorkspaceTemplateResponse }` (`id`, `agencyId`, `name`, `sourceWorkspaceId`, `configSnapshot`, `createdBy`, `createdAt`).
6. FE: hiển thị toast thành công, thêm vào danh sách Template.

## Flow B — Xem danh sách Template

1. User → FE: mở trang danh sách Template.
2. FE → BE: `GET /api/v1/workspace-templates`.
3. BE: query `workspace_templates` theo `agencyId` của `currentUser` (hoặc theo phạm vi mà service quy định).
4. BE → FE: `200 { data: [WorkspaceTemplateResponse, ...] }`.

## Flow C — Xem chi tiết Template

1. User → FE: bấm vào 1 Template.
2. FE → BE: `GET /api/v1/workspace-templates/{templateId}`.
3. BE: tìm theo `id` — không tồn tại → `404 NOT_FOUND` (theo pattern chung).
4. BE → FE: `200 { data: WorkspaceTemplateResponse }`.

## Flow D — Xóa Template

1. User → FE: bấm "Xóa" trên 1 Template.
2. FE → BE: `DELETE /api/v1/workspace-templates/{templateId}`.
3. BE: tìm theo `id` — không tồn tại → `404 NOT_FOUND`; xóa record.
4. BE → DB: `DELETE workspace_templates WHERE id = ?`.
5. BE → FE: `200 { data: null }`.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Create | `name` trống | 400 | `VALIDATION_ERROR` |
| Create | `configSnapshot` trống | 400 | `VALIDATION_ERROR` |
| Detail / Delete | `templateId` không tồn tại | 404 | `NOT_FOUND` |

## Ghi chú khác biệt so với spec.md gốc

- `spec.md` mục 6 tự ghi chú "chưa double-check với BE liệu có giới hạn quyền theo Agency/role dự kiến hay chưa" — sequence-flow này giữ nguyên cảnh báo đó (không có `@RequireRole` cụ thể xác nhận được trên các endpoint `/workspace-templates`), không phát sinh thêm drift mới.

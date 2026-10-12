# UC — View Mail Template

| | |
|---|---|
| FR Code | 3.6.28 |
| Feature | View Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [../3-6-28-32-mail-template/plan.md](../3-6-28-32-mail-template/plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **List**: `GET /api/v1/workspaces/{id}/mail-templates?includeSystem=true&q=&page=&size=` → `[{id, name, subject (preview), type, attachmentCount, createdAt}]`; template hệ thống hiển thị kèm nhãn "Hệ thống"; lọc `deletedAt = null`.
- **Chi tiết**: `GET .../mail-templates/{tid}`; **Preview**: `POST .../{tid}/preview`.
- **Lịch sử gửi** (trang lô): `GET .../mail-batches`, `GET .../mail-batches/{bid}`, `GET .../mail-quota` — OWNER/MANAGER/CREATOR xem toàn bộ, giữ 12 tháng.

## 1. Objective

Hiển thị mẫu email đã tạo.

## 2. User Story

Là một Member,
tôi muốn xem danh sách mẫu email,
để tái sử dụng khi cần gửi email cho Client.

## 3. Acceptance Criteria

- List các Mail Template của Workspace: tên, subject preview, ngày tạo.
- Role: OWNER, MANAGER, CREATOR (đã chốt 2026-10-12).

## 4. UI / UX

- Trang `/workspaces/:id/mail-templates`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/mail-templates
→ 200 { "success": true, "data": [{ "id", "name", "subject" }] }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- List hiển thị đúng.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

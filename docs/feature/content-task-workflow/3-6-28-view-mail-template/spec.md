# UC — View Mail Template

| | |
|---|---|
| FR Code | 3.6.28 |
| Feature | View Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | TBD (chưa gán role trong CSV) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị mẫu email đã tạo.

## 2. User Story

Là một Member,
tôi muốn xem danh sách mẫu email,
để tái sử dụng khi cần gửi email cho Client.

## 3. Acceptance Criteria

- List các Mail Template của Workspace: tên, subject preview, ngày tạo.
- **[CÂU HỎI MỞ]** CSV chưa gán role cụ thể cho nhóm FR Mail Template (3.6.28-3.6.32) — cần Trung xác nhận ai được dùng (đề xuất tạm: MANAGER, có thể mở rộng cho CREATOR khi thiết kế chi tiết).

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

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

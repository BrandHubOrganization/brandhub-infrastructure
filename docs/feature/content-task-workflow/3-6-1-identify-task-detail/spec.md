# UC — Identify Task Detail

| | |
|---|---|
| FR Code | 3.6.1 |
| Feature | Identify Task Detail |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Manager thêm đầy đủ chi tiết cho Task còn ở backlog (mới có tên + deadline thô từ Campaign/Content Request/thủ công) — người thực hiện, ngày đăng, yêu cầu chi tiết.

## 2. User Story

Là một Manager,
tôi muốn bổ sung chi tiết cho 1 Task trong backlog,
để chuẩn bị giao việc cụ thể cho Creator.

## 3. Acceptance Criteria

- Task ở backlog chỉ có: tên, yêu cầu đầu ra thô, deadline sơ bộ — CHƯA có người làm, CHƯA có yêu cầu chi tiết.
- Manager điền: mô tả chi tiết yêu cầu, ngày đăng dự kiến, và **các field khác tùy theo loại Task** (Post/Livestream/Survey — xem FR 3.6.22-3.6.27 cho Livestream/Survey).
- Sau bước này, Task chuyển trạng thái `DETAIL_IDENTIFIED`, sẵn sàng để Assign (FR 3.6.2).

## 4. UI / UX

- Trang `/workspaces/:id/tasks/:taskId/detail` — form điền chi tiết, hiển thị khác nhau tùy `task.type`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/detail
{ "description", "dueDate", "typeSpecificFields": {...} }
→ 200 { "success": true, "data": { ...updated task..., "status": "detail_identified" } }
```

## 6. Error Handling

- Task không ở trạng thái `backlog` → 409 `TASK_NOT_IN_BACKLOG`.
- Không phải Manager của Workspace này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Task sinh từ Content Request đã có `description` gốc từ Client → Manager có thể giữ nguyên hoặc bổ sung thêm, không bắt buộc viết lại từ đầu.

## 8. Definition of Done

- Điền chi tiết thành công, Task chuyển đúng trạng thái tiếp theo.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

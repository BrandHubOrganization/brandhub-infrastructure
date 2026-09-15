# UC — Calendar Task View

| | |
|---|---|
| FR Code | 3.6.5 |
| Feature | Calendar Task View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị Task dạng lịch kiểu Google Calendar, kéo thả được để đổi ngày.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn xem Task theo dạng lịch,
để nắm được phân bổ công việc theo ngày/tuần/tháng.

## 3. Acceptance Criteria

- Hiển thị Task theo `dueDate` trên lưới calendar (tháng/tuần/ngày).
- Kéo thả 1 Task sang ngày khác → cập nhật `dueDate` ngay (chỉ Manager/Creator được kéo, Client chỉ xem).

## 4. UI / UX

- Trang `/workspaces/:id/tasks?view=calendar`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks?view=calendar&month=2026-09
→ 200 { "success": true, "data": [{ "id", "title", "dueDate", "status" }] }

PATCH /api/v1/workspaces/{id}/tasks/{taskId}/reschedule
{ "dueDate": "ISO date" }
→ 200 { "success": true, "data": { ...task... } }
```

## 6. Error Handling

- Client cố kéo thả đổi ngày → 403 `FORBIDDEN` (chỉ Manager/Creator được sửa dueDate).

## 7. Edge Cases

- Kéo Task sang ngày đã qua (trong quá khứ) → cảnh báo xác nhận trước khi lưu, không tự động chặn cứng.

## 8. Definition of Done

- Calendar hiển thị đúng, kéo thả cập nhật deadline hoạt động cho Manager/Creator.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

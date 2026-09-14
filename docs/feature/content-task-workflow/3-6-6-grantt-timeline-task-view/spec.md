# UC — Grantt Timeline Task View

| | |
|---|---|
| FR Code | 3.6.6 |
| Feature | Grantt Timeline Task View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị tiến trình công việc dạng waterfall/Gantt timeline.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn xem Task theo dạng Gantt timeline,
để theo dõi tiến độ tổng thể của Campaign.

## 3. Acceptance Criteria

- Hiển thị các Task theo thanh ngang theo thời gian bắt đầu-kết thúc, nhóm theo Campaign nếu có.
- Hiển thị % hoàn thành theo trạng thái hiện tại của Task.

## 4. UI / UX

- Trang `/workspaces/:id/tasks?view=gantt`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks?view=gantt&campaignId=...
→ 200 { "success": true, "data": [{ "id", "title", "startDate", "dueDate", "progressPercent" }] }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Task không có `startDate` (chỉ có `dueDate`) → hiển thị thanh timeline dạng điểm (milestone) thay vì thanh dài.

## 8. Definition of Done

- Gantt hiển thị đúng tiến độ theo trạng thái Task.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

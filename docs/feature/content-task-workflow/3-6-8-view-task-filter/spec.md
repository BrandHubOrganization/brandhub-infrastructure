# UC — View Task Filter

| | |
|---|---|
| FR Code | 3.6.8 |
| Feature | View Task Filter |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Filter/sort/search cho toàn bộ các view Task theo mọi field dữ liệu, tham khảo cách làm của Jira.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn filter/search Task theo nhiều tiêu chí,
để nhanh chóng tìm đúng công việc cần xem.

## 3. Acceptance Criteria

- Filter theo: `type`, `status`, `assignee`, `dueDate range`, `campaignId`.
- Search full-text theo `title`/`description`.
- Filter áp dụng đồng thời cho List/Calendar/Gantt/Kanban view (dùng chung query params).

## 4. UI / UX

- Filter bar phía trên mọi trang Task view (`/workspaces/:id/tasks`).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks?type=post&status=in_progress&assigneeId=...&search=...
→ 200 { "success": true, "data": [...] }
```

## 6. Error Handling

- Không có lỗi đặc biệt — filter không khớp trả list rỗng.

## 7. Edge Cases

- Kết hợp nhiều filter cùng lúc (type + status + search) → AND logic giữa các filter, không phải OR.

## 8. Definition of Done

- Filter/search hoạt động đúng trên mọi view.

## Out of Scope

- Saved filter (lưu bộ filter thường dùng) — không có trong CSV, có thể bổ sung sau.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

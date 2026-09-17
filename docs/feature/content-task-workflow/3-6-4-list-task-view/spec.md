# UC — List Task View

| | |
|---|---|
| FR Code | 3.6.4 |
| Feature | List Task View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị danh sách Task kiểu Jira — 1 trong 4 kiểu view chuẩn dùng chung cho mọi loại Task.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn xem danh sách Task dạng list,
để quét nhanh toàn bộ công việc trong Workspace.

## 3. Acceptance Criteria

- Bảng: tên Task, loại (Post/Livestream/Survey), assignee, trạng thái, deadline.
- Sort theo cột, phân trang.
- Click vào 1 dòng → vào Task Detail.

## 4. UI / UX

- Trang `/workspaces/:id/tasks?view=list`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks?view=list&sort=dueDate&order=asc
→ 200 { "success": true, "data": [{ "id", "title", "type", "assigneeName", "status", "dueDate" }] }
```

## 6. Error Handling

- Không có quyền truy cập Workspace → 403 `FORBIDDEN`.

## 7. Edge Cases

- Workspace chưa có Task nào → empty state với gợi ý tạo Campaign/Content Request đầu tiên.

## 8. Definition of Done

- List hiển thị đúng, sort/phân trang hoạt động.

## Out of Scope

- Không có (chi tiết filter xem FR 3.6.8).

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

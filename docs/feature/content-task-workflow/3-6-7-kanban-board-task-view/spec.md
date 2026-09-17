# UC — Kanban Board Task View

| | |
|---|---|
| FR Code | 3.6.7 |
| Feature | Kanban Board Task View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Board kéo thả trạng thái công việc kiểu Jira — làm thêm 3 kiểu board khác nhau theo yêu cầu CSV.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn xem Task theo dạng Kanban board,
để kéo thả đổi trạng thái công việc trực quan.

## 3. Acceptance Criteria

- Board mặc định: cột theo trạng thái Approval Sequence (Backlog / Assigned / In Progress / Review / Completed).
- **Làm thêm 3 kiểu board khác** (theo CSV, chưa chỉ rõ tiêu chí — đề xuất 3 kiểu: theo Assignee, theo Loại Task (Post/Livestream/Survey), theo Campaign) — cần xác nhận tiêu chí cụ thể với Trung khi thiết kế UI.
- Kéo Task sang cột khác → tương đương thao tác approve/reject tùy vị trí cột (map với Approval Sequence, FR 3.6.9) — chỉ Manager/Creator kéo được, Client chỉ xem hoặc kéo trong phạm vi quyền approve của họ.

## 4. UI / UX

- Trang `/workspaces/:id/tasks?view=kanban&groupBy=status|assignee|type|campaign`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks?view=kanban&groupBy=status
→ 200 { "success": true, "data": { "columns": [{ "key", "label", "tasks": [...] }] } }
```

## 6. Error Handling

- Kéo Task vào cột không hợp lệ theo Approval Sequence hiện tại (ví dụ kéo thẳng từ Assigned sang Completed, bỏ qua Review) → 409 `INVALID_STATUS_TRANSITION`.

## 7. Edge Cases

- Client kéo Task sang cột 'Reject' → phải map đúng vào action reject của Approval Sequence, quay Task về `ASSIGNED` (theo state machine đã xác nhận).

## 8. Definition of Done

- 4 kiểu board hoạt động, kéo thả map đúng vào state machine Approval Sequence.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md), [12-state-machines.md](../../../BA/12-state-machines.md)

# UC — Assign Task To Creator

| | |
|---|---|
| FR Code | 3.6.2 |
| Feature | Assign Task To Creator |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Gắn Task cho người làm (Creator) và tùy chọn người chịu trách nhiệm QC.

## 2. User Story

Là một Manager,
tôi muốn giao Task cho 1 Creator cụ thể,
và tùy chọn thêm người QC nếu cần kiểm tra chất lượng trước khi tôi duyệt.

## 3. Acceptance Criteria

- Chọn `assigneeId` (Creator — 1 WorkspaceMember có role MEMBER trong Workspace này).
- **Tùy chọn** chọn `qcAssigneeId` (1 Creator khác) — quyết định có/không có bước QC trong Approval Sequence (FR 3.6.9) cho Task này.
- Set `requiresClientApproval` (boolean) — quyết định Task có cần Client duyệt ở cuối chuỗi hay không.
- Sau Assign, Task chuyển `ASSIGNED`, Creator nhận notification.

## 4. UI / UX

- Modal/form Assign trong trang Task Detail, dropdown chọn Creator + checkbox 'Cần QC' + checkbox 'Cần Client duyệt'.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/assign
{ "assigneeId": "string", "qcAssigneeId"?: "string", "requiresClientApproval": boolean }
→ 200 { "success": true, "data": { ...task..., "status": "assigned" } }
```

## 6. Error Handling

- `assigneeId` không phải Member (role=MEMBER) của Workspace này → 400 `INVALID_ASSIGNEE`.
- Task chưa qua Identify Task Detail (còn ở backlog) → 409 `TASK_DETAIL_NOT_IDENTIFIED`.

## 7. Edge Cases

- `qcAssigneeId` trùng `assigneeId` → 400 `QC_CANNOT_BE_SAME_AS_ASSIGNEE` (người làm không thể tự QC chính mình).

## 8. Definition of Done

- Assign thành công, đúng ràng buộc QC/Client approval tùy chọn.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md), [12_State_Machines.md](../../../BA/12_State_Machines.md)

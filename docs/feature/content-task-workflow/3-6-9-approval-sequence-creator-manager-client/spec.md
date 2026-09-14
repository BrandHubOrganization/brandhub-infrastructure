# UC — Approval Sequence (Creator -> Manager -> Client)

| | |
|---|---|
| FR Code | 3.6.9 |
| Feature | Approval Sequence (Creator -> Manager -> Client) |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Chuỗi duyệt Task: Creator làm → (tùy chọn QC bởi Creator khác) → Manager duyệt → Client duyệt (nếu cần). Reject ở bước nào cũng quay về `ASSIGNED` để sửa nội dung, nhưng giữ lại các approval đã pass ở step trước.

## 2. User Story

Là một Creator, Manager, hoặc Client,
tôi muốn tham gia đúng vai trò của mình trong chuỗi duyệt Task,
để đảm bảo chất lượng nội dung trước khi công bố.

## 3. Acceptance Criteria

- Chuỗi: `Creator submit → [QC review, TÙY CHỌN] → Manager review → [Client review, NẾU requiresClientApproval] → Completed`.
- **[CONFIRMED 2026-09-14]** Bước QC là tùy chọn, do Manager quyết định lúc Assign Task (FR 3.6.2) có giao `qcAssigneeId` hay không.
- **Reject ở BẤT KỲ bước nào → Task luôn quay về trạng thái `ASSIGNED`** — Creator (người làm ban đầu) sửa lại nội dung rồi submit lại.
- **[SỬA 2026-09-15, override bản 2026-09-14]** Approval các step TRƯỚC step bị reject KHÔNG bị xoá. Ví dụ: QC đã approve → Manager reject → về `ASSIGNED` → Creator submit lại → **đi thẳng vào `MANAGER_REVIEW`, không phải qua lại `QC_REVIEW`**. Manager có thể chủ động gửi lại QC thủ công nếu thấy cần, không tự động.
- Đi hết chuỗi không bị reject → Task chuyển `COMPLETED`.
- Chi tiết đầy đủ transition xem [12_State_Machines.md](../../../BA/12_State_Machines.md) mục 4.

## 4. UI / UX

- Nút Submit/Approve/Reject trên trang Task Detail, hiển thị rõ đang ở bước nào trong chuỗi (progress stepper).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/submit
→ 200 { "success": true, "data": { ...task..., "status": "in_progress|qc_review|manager_review" } }

POST /api/v1/workspaces/{id}/tasks/{taskId}/approve
{ "step": "qc|manager|client" }
→ 200 { "success": true, "data": { ...task..., "status": "..." } }

POST /api/v1/workspaces/{id}/tasks/{taskId}/reject
{ "step": "qc|manager|client", "reason": "string" }
→ 200 { "success": true, "data": { ...task..., "status": "assigned" } }
(chỉ TaskApproval của step này đổi thành reject, các step trước giữ nguyên approve trong lịch sử)

GET /api/v1/workspaces/{id}/tasks/{taskId}/approvals
→ 200 { "success": true, "data": [{ "step", "action", "actorId", "comment", "createdAt" }] }
```

## 6. Error Handling

- Approve/Reject không đúng người phụ trách bước đó (ví dụ Client approve khi đang ở bước `qc_review`) → 403 `WRONG_APPROVAL_STEP`.
- Approve Task chưa `submit` → 409 `TASK_NOT_SUBMITTED`.

## 7. Edge Cases

- Task không có QC, không cần Client approval → chuỗi ngắn nhất: Creator submit → Manager approve → Completed (2 bước).
- Reject ở bước Client (bước cuối) → vẫn quay về `ASSIGNED`, không quay về `MANAGER_REVIEW` — nhưng approval của Manager (đã pass trước đó) vẫn giữ; submit lại đi thẳng vào `CLIENT_REVIEW` lại, không phải qua `MANAGER_REVIEW` lần 2.
- QC reject → về `ASSIGNED` → không có approval nào trước để giữ (QC là step đầu tiên) → submit lại đi vào `QC_REVIEW` như bình thường.

## 8. Definition of Done

- Toàn bộ transition trong state machine (mục 12 BA) hoạt động đúng, reject luôn quay về ASSIGNED, approval các step trước không bị xoá.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md), [12_State_Machines.md](../../../BA/12_State_Machines.md)

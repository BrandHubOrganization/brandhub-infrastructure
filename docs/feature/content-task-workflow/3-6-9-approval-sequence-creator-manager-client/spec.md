# UC — Approval Sequence (Creator -> Manager -> Client)

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

| | |
|---|---|
| FR Code | 3.6.9 |
| Feature | Approval Sequence (Creator -> Manager -> Client) |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Resubmit BA reconfirmed 2026-10-14; code do chủ E51-03 triển khai/phối hợp |

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
- **[XÁC NHẬN LẠI 2026-10-14, thay thế quy tắc skip của bản 15/09]** Approval đã pass KHÔNG bị xóa khỏi lịch sử, nhưng nội dung được Creator sửa và submit lại phải duyệt lại từ QC nếu có; không có QC thì từ Manager. Không dùng approval lượt cũ làm approval hợp lệ cho nội dung mới. Phân biệt giữ lịch sử audit với hiệu lực duyệt của lượt hiện tại.
- Đi hết chuỗi không bị reject → Task chuyển `COMPLETED`.
- Chi tiết đầy đủ transition xem [12-state-machines.md](../../../BA/12-state-machines.md) mục 4.

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
(append record reject; không sửa/xóa record approve trước đó. Lượt resubmit mới có approval riêng.)

GET /api/v1/workspaces/{id}/tasks/{taskId}/approvals
→ 200 { "success": true, "data": [{ "step", "action", "actorId", "comment", "createdAt" }] }
```

## 6. Error Handling

- Approve/Reject không đúng người phụ trách bước đó (ví dụ Client approve khi đang ở bước `qc_review`) → 403 `WRONG_APPROVAL_STEP`.
- Approve Task chưa `submit` → 409 `TASK_NOT_SUBMITTED`.

## 7. Edge Cases

- Task không có QC, không cần Client approval → chuỗi ngắn nhất: Creator submit → Manager approve → Completed (2 bước).
- Reject ở bước Client → về ASSIGNED; lịch sử QC/Manager cũ giữ nguyên. Submit lại bắt đầu từ QC nếu có, nếu không thì Manager, rồi Client nếu requiresClientApproval; không đi thẳng Client nhờ approval cũ.
- QC reject → về `ASSIGNED` → không có approval nào trước để giữ (QC là step đầu tiên) → submit lại đi vào `QC_REVIEW` như bình thường.
- Reject về ASSIGNED không xóa dấu mốc đã bắt đầu để mở khóa sửa brief/giao lại theo FR 3.6.1/3.6.2. Q8 confirmed 2026-10-14: Creator bấm Bắt đầu làm mới chuyển IN_PROGRESS; mở trang/editor không tính. Cần phối hợp contract marker/CAS cùng chủ E51-03, không tự sửa code Approval trong giai đoạn 1.

## 8. Definition of Done

- Toàn bộ transition theo state machine (mục 12 BA), reject về ASSIGNED, không mất lịch sử; resubmit duyệt lại đúng chuỗi của lượt mới. Không đánh dấu Done chỉ vì cập nhật tài liệu.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../ba/05-content-task-workflow.md), [12-state-machines.md](../../../ba/12-state-machines.md), [quyết định 2026-10-14](../task-detail-assignment-comments-roadmap.md). Người dùng/lead cần thông báo chủ E51-03 trước khi tích hợp; thay đổi này chỉ đồng bộ tài liệu, không sửa code của thành viên đó.

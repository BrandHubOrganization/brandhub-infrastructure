# UC — Assign Task To Creator

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

| | |
|---|---|
| FR Code | 3.6.2 |
| Feature | Assign Task To Creator |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER (giao việc), CREATOR assignee (Bắt đầu làm) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | BA confirmed Q13; đợt 2026-10-15 đã code assign/start/API/UI, chờ nghiệm thu Atlas và review tích hợp |

## 1. Objective

Gắn Task cho người làm (Creator) và tùy chọn người chịu trách nhiệm QC.

## 2. User Story

Là một Manager,
tôi muốn giao Task cho 1 Creator cụ thể,
và tùy chọn thêm người QC nếu cần kiểm tra chất lượng trước khi tôi duyệt.

## 3. Acceptance Criteria

- Chọn `assigneeId` là User ID của Creator có membership active, role CREATOR trong đúng Workspace; không nhầm với WorkspaceMember ID. Tên MEMBER trong bản cũ là thuật ngữ lịch sử.
- **Tùy chọn** chọn `qcAssigneeId` (1 Creator khác) — quyết định có/không có bước QC trong Approval Sequence (FR 3.6.9) cho Task này.
- Set `requiresClientApproval` (boolean) — quyết định Task có cần Client duyệt ở cuối chuỗi hay không.
- Sau Assign, Task chuyển `ASSIGNED`, Creator nhận notification.
- Giao lần đầu chỉ sau DETAIL_IDENTIFIED. Manager được giao lại Creator/QC và sửa cấu hình trước khi Creator bắt đầu; Task giữ ASSIGNED. Sau khi bắt đầu/đang duyệt/terminal thì khóa thao tác này trong đợt hiện tại; reject về ASSIGNED không mở khóa lại.
- QC cũng phải là Creator active của đúng Workspace và khác assignee. Quyền Manager dựa trên vai trò hiện tại của Workspace; Owner được gán Manager áp dụng quyền Manager.
- Creator bấm **Bắt đầu làm** để chuyển ASSIGNED → IN_PROGRESS; mở trang/editor không phải bắt đầu. Lưu lần bắt đầu đầu tiên, không xóa khi reject về ASSIGNED (Q8 confirmed).
- Không sửa/xóa lịch sử approval hoặc đổi ID/nguồn Task khi giao lại. Hợp đồng dấu mốc bắt đầu phải được chủ E51-03 phối hợp trước tích hợp.

- Q13 confirmed 2026-10-14: không phân biệt nội bộ/thường. Mọi Task trong Workspace đều cho Client
  active xem/bình luận; requiresClientApproval=true/false đều hợp lệ khi các guard giao việc khác đạt.
  Q12 cũ không còn áp dụng; không có thao tác đổi visibility hoặc tự thay cờ duyệt.

## 4. UI / UX

- Modal/form Assign trong trang Task Detail, dropdown chọn Creator + checkbox 'Cần QC' + checkbox 'Cần Client duyệt'.
- Nút Bắt đầu làm riêng cho Creator được giao; không gắn side effect start vào mở editor.
- Checkbox Cần Khách hàng duyệt chỉ cấu hình chuỗi duyệt kết quả; không khóa theo nguồn Task thủ công/Campaign/Request.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/assign
{ "assigneeId": "User UUID", "qcAssigneeId"?: "User UUID", "requiresClientApproval": boolean, "expectedRevision": number }
→ 200 { "success": true, "data": { ...task..., "status": "ASSIGNED" } }
```

## 6. Error Handling

- `assigneeId` không phải Creator active của Workspace này → 400 `INVALID_ASSIGNEE`.
- Task chưa qua Identify Task Detail (còn ở backlog) → 409 `TASK_DETAIL_NOT_IDENTIFIED`.
- Đã bắt đầu/đang duyệt/terminal hoặc revision cũ → 409, không tự ghi đè/giao lại. Mã lỗi cụ thể chốt trong plan.

## 7. Edge Cases

- `qcAssigneeId` trùng `assigneeId` → 400 `QC_CANNOT_BE_SAME_AS_ASSIGNEE` (người làm không thể tự QC chính mình).

## 8. Definition of Done

- Assign thành công, đúng ràng buộc QC/Client approval tùy chọn.

## Out of Scope

- Approval transitions/submit/start code do chủ E51-03 phối hợp; không tự mở lại Task terminal.

## i18n và theme

Form/dropdowns/validation/notifications feedback dùng `tasks.assignment.*`, `tasks.actions.start`, `tasks.errors.*` vi/en song song; semantic light/dark. Có loading, không có Creator khả dụng, lỗi validation, conflict và success. Không đổi UI editor hoặc các views của thành viên khác. Xem [plan](plan.md), [task](task.md), [test](test.md).

## Tham chiếu BA

[05-content-task-workflow.md](../../../ba/05-content-task-workflow.md), [12-state-machines.md](../../../ba/12-state-machines.md), [roadmap](../task-detail-assignment-comments-roadmap.md).

## Đợt tiếp tục 2026-10-15

Triển khai giao/giao lại và thao tác Bắt đầu lần đầu đã chốt Q8; không triển khai submit/reject/resubmit của E51-03. Chưa coi hợp đồng Approval đã được thành viên review. Schema chưa sẵn sàng thì đọc vẫn hoạt động, mutation trả TASK_SCHEMA_NOT_READY; worker notification không tự tạo collection. Không tự chạy migration hoặc chuẩn hóa Task legacy trên Atlas.

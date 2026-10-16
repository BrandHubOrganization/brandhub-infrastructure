# UC — Identify Task Detail

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

| | |
|---|---|
| FR Code | 3.6.1 |
| Feature | Identify Task Detail |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | BA confirmed Q13; đợt 2026-10-15 đã code workflow/API/UI, chờ nghiệm thu Atlas và review tích hợp |

## 1. Objective

Manager bổ sung yêu cầu đầu vào cho Task trước khi Creator bắt đầu. Giao người thực hiện thuộc FR 3.6.2; ngày đăng dự kiến POST tách khỏi hạn hoàn thành công việc.

## 2. User Story

Là một Manager,
tôi muốn bổ sung chi tiết cho 1 Task trong backlog,
để chuẩn bị giao việc cụ thể cho Creator.

## 3. Acceptance Criteria

- Task ở backlog chỉ có: tên, yêu cầu đầu ra thô, deadline sơ bộ — CHƯA có người làm, CHƯA có yêu cầu chi tiết.
- Phạm vi đợt này: mô tả yêu cầu, hạn hoàn thành và đầu vào/tham khảo cho POST/LIVESTREAM/SURVEY/EVENT_PLAN/PRESS_RECOMMENDATION. Không làm thay editor Post, kịch bản Livestream, form Survey hoặc nội dung chuyên biệt của thành viên khác.
- Mọi Task có hạn hoàn thành (`dueDate`). POST có thêm thời điểm đăng dự kiến, độc lập với dueDate; lưu giá trị này không tự lập lịch/publish.
- Task gắn Campaign: hạn hoàn thành từ max(ngày hiện tại, ngày bắt đầu Campaign) đến hết ngày kết thúc theo múi giờ Workspace. Ngày đăng dự kiến POST không trước dueDate và cũng nằm trong Campaign. Task thủ công không gắn Campaign: hạn từ ngày hiện tại trở đi (Q10 confirmed).
- Lần xác định chi tiết đầu tiên: `BACKLOG → DETAIL_IDENTIFIED`, sẵn sàng Assign (FR 3.6.2).
- Manager được sửa chi tiết ở BACKLOG/DETAIL_IDENTIFIED và ASSIGNED trước khi Creator bắt đầu; chỉnh sửa không đưa Task đã giao trở về backlog hoặc xóa người phụ trách.
- Creator phải bấm **Bắt đầu làm** mới chuyển ASSIGNED → IN_PROGRESS và ghi nhận lần bắt đầu đầu tiên. Mở trang/editor không tính bắt đầu (Q8 confirmed 2026-10-14).
- Sau khi Creator bắt đầu hoặc Task đã vào vòng duyệt thì khóa sửa chi tiết trong phạm vi đợt này. Reject về ASSIGNED không xóa dấu mốc bắt đầu và không mở lại quyền sửa yêu cầu của Manager.
- Chỉ Manager thực tế của đúng Workspace được sửa. Giữ ID, liên kết Campaign/Request, số lượng/kế hoạch đã duyệt và audit hủy Task; không mở lại COMPLETED/CANCELLED.
- Q13 confirmed 2026-10-14: Client active được xem và bình luận mọi Task trong đúng Workspace,
  kể cả Task Manager tạo thủ công và Task cũ; không phân biệt nội bộ/thường, không có field visibility.
  Quyền này không cho Client sửa brief, giao việc hoặc sửa content/editor. Cờ requiresClientApproval
  chỉ quyết định có bước Client duyệt kết quả, không quyết định quyền xem/bình luận.

## 4. UI / UX

- Xác nhận UI 2026-10-15: mở Task trong bảng chi tiết phía phải của danh sách, không chuyển sang trang mới. Desktop giữ danh sách tương tác được; màn hình nhỏ dùng bảng trượt có nút đóng. URL `/workspaces/:id/tasks?task={taskId}` hỗ trợ liên kết trực tiếp và Back/Forward; route detail cũ chuyển về URL này.
- Bảng dùng cùng workflow/form/capabilities hiện có: xem, lưu brief, giao việc và bắt đầu làm; không thay đổi BA/quyền hoặc editor chuyên biệt. Lưu thành công cập nhật danh sách mà không mất bộ lọc/chế độ xem/trang.
- Bàn phím mở được Task, đóng bằng nút hoặc Escape và trả focus về điểm mở. vi/en dùng `tasks.panel.*` song song; giữ semantic light/dark tokens và layout không tràn viewport.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/detail
{ "description", "dueDate", "plannedPublishAt"?: "ISO timestamp for POST", "inputReferences"?: [...], "expectedRevision" }
→ 200 { "success": true, "data": { ...updated task... } }
```

Tên field trên là đề xuất kỹ thuật, chưa final. Lần đầu chuyển DETAIL_IDENTIFIED; sửa trước bắt đầu giữ trạng thái hiện tại. Không nhận blob typeMetadata tùy ý để ghi đè nội dung module khác.

## 6. Error Handling

- Lần xác định đầu tiên không phải BACKLOG hoặc sửa sau khi bắt đầu/terminal → 409 theo lỗi trạng thái được chốt trong plan. Quy tắc cũ “mọi sửa chỉ BACKLOG” được thay thế bởi xác nhận 2026-10-14.
- Không phải Manager của Workspace này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Task sinh từ Content Request đã có `description` gốc từ Client → Manager có thể giữ nguyên hoặc bổ sung thêm, không bắt buộc viết lại từ đầu.
- Campaign đã hết ngày hợp lệ → không có hạn mới hợp lệ để lưu; hiển thị lỗi thay vì tự kéo dài timeline. API vẫn kiểm tra khi vượt UI hoặc dữ liệu thay đổi đồng thời.

## 8. Definition of Done

- Điền chi tiết thành công, Task chuyển đúng trạng thái tiếp theo.

## Out of Scope

- Không sửa editor/Approval, không tự schedule/publish, không làm module chuyên biệt hoặc views E51-05.

## i18n và theme

Nhãn/form/errors dùng namespace `tasks`: `detail.*`, `fields.*`, `status.*`, `actions.*`, `errors.*`, `common.*` (vi/en song song). Semantic light/dark tokens; loading/empty/forbidden/error/success/conflict rõ ràng, lỗi cạnh field, không mất input khi conflict. Date picker giới hạn ngay khi chọn theo Q10; backend vẫn xác minh. Không có bộ chọn nội bộ/thường. Xem [plan](plan.md), [task](task.md), [test](test.md).

## Tham chiếu BA

[05-content-task-workflow.md](../../../ba/05-content-task-workflow.md), [roadmap và quyết định BA](../task-detail-assignment-comments-roadmap.md).

## Đợt tiếp tục 2026-10-15

Dùng danh sách Task thật vừa tích hợp làm điểm vào; mở bảng chi tiết bên phải bằng ID Task, không tạo list/backlog thứ hai. Đọc workflow riêng cho mọi thành viên active; form chỉ xuất hiện theo capabilities backend. Hiển thị lý do khóa khi thiếu foundation, legacy thiếu bằng chứng bắt đầu, Task đã bắt đầu/terminal hoặc Campaign hoàn thành. Không tự backfill để mở khóa Task cũ. Giữ contract editor/Approval; comments thuộc đợt sau.

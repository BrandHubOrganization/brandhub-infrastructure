# Plan — FR 3.6.1 / DA-978

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

## Điều chỉnh UI đã được yêu cầu 2026-10-15

Thay dialog tóm tắt + trang detail bằng TaskDetailPanel trên danh sách. Tách workflow content khỏi PageWrapper; QueryClientProvider riêng theo Workspace/Task, mutation callback refresh useTasks. Desktop dùng aside không modal, màn hình nhỏ dùng Sheet với focus trap; cả hai tái sử dụng nội dung/form. Chọn Task qua query parameter task, giữ nguyên query khác và state của list; route detail cũ redirect. Các link từ Campaign/Request chỉ đổi đích tới list?task. Không đổi API/DB/editor/ACL.

File UI: pages/tasks/index.tsx, detail.tsx, components/TaskDetailPanel.tsx, TaskWorkflowContent.tsx, hooks/useTaskPanel.ts, TaskTable.tsx; locale src/i18n/locales/{vi,en}/tasks.json. Giữ tone BrandHub: font/token sẵn có, nền card/background, border phân cột, orange chỉ cho hành động/Task được chọn; không thêm palette/font. Kiểm tra browser mock desktop/mobile, đóng/mở/switch Task, mutation, focus, Back/Forward và direct link; kiểm thử provider dùng component thật không bọc provider từ test.

2026-10-14. [Spec confirmed, Q13 mới nhất](spec.md). Mục tiêu: Manager chuẩn bị brief trước Creator bắt đầu.
Thiết kế giai đoạn 1, chưa có API/UI triển khai; dùng [contract chung](../task-workflow-contract.md).

## Phạm vi và model

Business đọc TaskDocument Mongo, Workspace membership/ClientProfile và Campaign PostgreSQL.
Thêm TaskWorkflowController/Service/Access/Store + DTO riêng; không thay TaskResponse/editor legacy SQL.
Task optional fields theo contract §2; migration foundation + init/checker, không backfill lịch sử start.
POST plannedPublishAt tách dueDate; inputReferences không ghi đè typeMetadata.

## API final cho phần đã chốt

GET `.../tasks/{taskId}/workflow`, GET `.../tasks/workflow` (list tối thiểu cần review E51-05),
GET `.../tasks/{taskId}/member-options`, PATCH `.../tasks/{taskId}/detail`.
Payload PATCH gồm description, dueDate, optional plannedPublishAt, inputReferences,
expectedRevision; trả workflow DTO, status uppercase. Chi tiết và errors theo contract §3.
Q13: đọc workflow theo active Workspace membership, Client đọc mọi nguồn Task, kể cả manual/legacy.
Không có visibility trong schema/DTO/payload hoặc Q12 validation. Quyền đọc/bình luận không cấp quyền sửa/editor.

## Xử lý

Auth + scope + quyền → legacy/start/status guard cho mutation → Campaign lock → date validation theo Workspace
→ CAS/targeted update → BACKLOG thành DETAIL_IDENTIFIED lần đầu; lần sửa sau giữ status/assignee.
Không sửa Campaign plan, approvalRound, cancellation, source hoặc specialist content.
Legacy thiếu lịch sử bắt đầu không tự coi chưa bắt đầu; phải inventory/review trước sửa/giao lại,
nhưng không lấy thiếu marker/revision làm lý do chặn Client xem/bình luận Task cùng Workspace.

## Frontend, i18n và theme

Module `src/pages/tasks/` + service/hooks/types; route `/workspaces/:id/tasks/:taskId/detail`.
Locale `src/locales/vi/tasks.json` và `src/locales/en/tasks.json` + registry theo repo thực tế.
Keys detail/fields/status/actions/errors/common; semantic theme, keyboard/focusable
error summary + inline errors, date min/max, giữ draft khi 409. Không đổi editor/views toàn hệ thống.

## Dependencies, trình tự và rủi ro

Schema/ACL → API đọc → form → mutation/validation/CAS → integration regression.
Phối hợp E51-03 firstStartedAt và writer trạng thái; E51-05 list; editor auto-create source defaults.
Rủi ro: legacy thiếu marker; ClientProfile resolve; nhầm quyền đọc/bình luận thành quyền editor;
timezone/ngày hết hạn; Mongo/SQL không distributed ACID; cancellation đua với detail.
Xem [task](task.md) và [test](test.md); không coi schema pass là FR Done.

## Implementation slice 2026-10-15

Reuse GET tasks của DA-979 thay GET /tasks/workflow thứ hai. Thêm GET /{taskId}/workflow và member-options, PATCH detail. Date bounds/timezone/campaign state do backend trả; input datetime-local được chuyển chính xác từ timezone Workspace, từ chối giờ DST không tồn tại. DTO không expose specialist content. Mongo raw presence phân biệt missing marker với explicit null; writer mới khởi tạo metadata, không tự đổi legacy. Targeted update CAS cả revision/status/updatedAt; mutation Campaign dùng SQL agreement lock và Mongo transaction. Locale thực tế: src/i18n/locales/{vi,en}/tasks.json. Link từ List/Campaign/Request vào route detail; các editor links vẫn giữ nguyên.

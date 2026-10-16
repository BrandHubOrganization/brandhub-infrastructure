# Plan — FR 3.6.2 / DA-978

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

2026-10-14. [Spec confirmed, Q13 mới nhất](spec.md). Dùng [contract chung](../task-workflow-contract.md).

## Phạm vi, API và model

Business TaskWorkflowService/Access/Store dùng cùng DTO/model/lock với FR3.6.1.
Q13 thay Q12: không có visibility hoặc ràng buộc nội bộ + Client duyệt. requiresClientApproval là
checkbox độc lập cho mọi nguồn Task; true/false chỉ cấu hình chuỗi duyệt kết quả.
Schema nền vẫn optional để tương thích writers cũ; không tự sửa legacy data.
POST `.../tasks/{taskId}/assign` nhận User IDs, requiresClientApproval, expectedRevision.
POST `.../tasks/{taskId}/start` chỉ assignee, expectedRevision; action do Creator bấm rõ ràng.
Trả status ASSIGNED/IN_PROGRESS uppercase, revision mới và capabilities. Errors contract §3.
Thêm assignedAt/By, firstStartedAt/By optional vào tasks; outbox notification riêng.

## Luồng

Giao lần đầu DETAIL_IDENTIFIED → ASSIGNED; giao lại trước start giữ ASSIGNED.
Kiểm tra Creator/QC active cùng WS, khác nhau; không nhận membership ID thay User ID.
CAS revision/status/start marker + Campaign lock; Mongo transaction Task + outbox.
Creator mới nhận thông báo một lần/assignment event; retry không nhân đôi.
Start chỉ ghi marker đầu tiên; reject không xóa marker, submit/resubmit do E51-03 phối hợp.
Không sửa approvalRound/history, không giao/bắt đầu Task terminal hoặc Campaign completed.

## Frontend và dependencies

Assign form trong Task Detail, member options scoped, nút start riêng cho assignee;
không thêm hành vi tự start vào editor. `src/locales/{vi,en}/tasks.json` assignment/actions/errors
song song, semantic light/dark, empty members/loading/conflict/keyboard states.
E51-03 phải review marker/CAS/approval resets; E51-05 cùng list điểm vào.
Risk: reject có ASSIGNED nhưng đã start; legacy marker thiếu; người bị gỡ membership;
outbox SQL idempotency, tránh hứa distributed transaction.
Trình tự: schema → membership/options → assign/start guards → outbox worker → UI → race tests.

## Implementation slice 2026-10-15

Thêm workflow DTO/actions, member options chỉ Creator active với User ID. Không ghi specialist metadata/approvalRound. Task + TASK_ASSIGNED outbox cùng Mongo transaction; worker lease token, retry và SQL INSERT ON CONFLICT (id), recheck active Creator/Task scope trước delivery. Chỉ sự kiện TASK_ASSIGNED trong đợt này; không claim comments/Approval đã triển khai. Schema missing không tự create; worker bỏ qua khi collection chưa có. UI form có expectedRevision, giữ draft khi 409 và nút reload riêng. Locale thực tế src/i18n/locales/{vi,en}/tasks.json.

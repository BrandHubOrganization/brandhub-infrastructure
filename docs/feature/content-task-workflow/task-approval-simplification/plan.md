> **SUPERSEDED for new implementation — 2026-10-18:** tài liệu này giữ lịch sử đề xuất ngày 16/10, không dùng làm checklist hiện hành hoặc lệnh APPLY. Xem [spec FR3.6.9 v3](../3-6-9-approval-sequence-creator-manager-client/spec.md), [plan](../3-6-9-approval-sequence-creator-manager-client/plan.md), [task](../3-6-9-approval-sequence-creator-manager-client/task.md), [test](../3-6-9-approval-sequence-creator-manager-client/test.md). Đã chốt /editor, một bản hiện tại không review snapshots, withdraw trước Manager decision và một Client bất kỳ. Task structure đã triển khai riêng; Approval mới hoàn thành tài liệu giai đoạn 1.

> Checkpoint 2026-10-17 (historical): Task structure removal of QC/plannedPublishAt and Atlas metadata APPLY were implemented separately; earlier inventory/results below are dated history, not current-state evidence.

# Kế hoạch thay đổi Task/Approval — DB trước, ứng dụng sau

Ngày: 2026-10-16. **Chờ review; không phải hướng dẫn chạy APPLY ngay.** Đọc [spec](spec.md), [checklist](task.md), [test](test.md).

## 1. Mục tiêu và giới hạn an toàn

Giữ bản demo ổn định, chuẩn bị schema tương thích cho BA bỏ QC/ngày đăng dự kiến. Không init/seed/xóa dữ liệu, không thay Content Writing/publishing, không thêm collection review round. Không chỉnh migration cũ đã merge. Không tự commit/push hoặc chạy migration theo tài liệu này.

## 2. Baseline đã kiểm tra trên Atlas ngày 2026-10-16

Đây là ảnh chụp kiểm kê, KHÔNG là số liệu để hardcode khi APPLY; phải kiểm tra lại.

| Collection | Kết quả kiểm tra |
|---|---|
| tasks | 14 Task, validator hỗ trợ canonical + legacy; 1 QC_REVIEW, 5 có qcAssigneeId, 1 IN_REVIEW thiếu reviewStep |
| task_approvals | 0 bản ghi; action APPROVE/REJECT, step QC/MANAGER/CLIENT; có index đọc lịch sử nhưng chưa unique quyết định mỗi bước/lượt |
| posts | 39 Post, 0 có task_id; validator legacy dùng platform trong khi code dùng target_platforms; validationAction=warn, 33 không khớp validator hiện tại |
| post_versions | Chưa có tại thời điểm kiểm kê; thuộc thiết kế snapshot/Admin hiện có, không tự thêm trong phạm vi đang hoãn |
| task_notification_outbox | Có schema/index, 0 bản ghi; eventType hiện TASK_ASSIGNED/TASK_COMMENTED |

Task/Request foundation và five-state migration đã được áp dụng trước đó; không chạy lại migration cũ để ghi đè validator mới.

## 3. Giai đoạn A — Review trước thay đổi DB

1. Chốt spec và các điểm mở; phân biệt nhận xét quyết định duyệt với thảo luận Task.
2. Đồng bộ BA/spec dùng chung sau review; không thay thế lịch sử bằng giả định mới.
3. Xác định writer/consumer: TaskWorkflowSchema/Service/DTO/UI còn đọc plannedPublishAt và QC; TaskNotificationWorker hiện xử lý giao việc theo Creator, chưa phù hợp người duyệt Manager/Client.
4. Chốt tên field nhận xét. reviewNote hiện là ĐỀ XUẤT, không phải contract đã triển khai.

## 4. Giai đoạn B — Inventory + thiết kế migration tương thích

- Kiểm kê count, trạng thái, QC, ngày đăng dự kiến, approval trùng, missing round/revision/start evidence; chỉ xuất metadata/count hoặc allowlist cần review, không log token/nội dung nhạy cảm.
- Không suy lịch sử firstStartedAt/By từ trạng thái; không tự liên kết Post với Task từ tiêu đề/tác giả.
- Giữ validator của các field legacy để code đang chạy vẫn hoạt động. Đặc biệt TaskWorkflowSchema hiện yêu cầu property plannedPublishAt; xóa ngay sẽ gây TASK_SCHEMA_NOT_READY.
- Giữ nguyên dueDate và workflowRevision, nguồn Campaign/Request, cancellation, index nền và lịch sử.
- Unique quyết định: khóa taskId + approvalRound + step cho APPROVE/REJECT. Preflight dữ liệu/index hiện có; nếu chọn partial index phải thử đúng phiên bản Mongo trước. Không xóa/ghi đè duplicate để ép tạo index.
- Nếu chốt reviewNote: bổ sung optional, giữ comment cũ; thiết kế reader ưu tiên reviewNote rồi fallback comment. Hai field có nội dung khác nhau phải báo để review, không tự ghi đè.
- Có thể bổ sung posts.task_id optional + unique có điều kiện cho Post gắn Task sau khi contract liên kết được review. Không đổi posts.validationAction sang error, không làm sạch 33 Post ngoài scope. Link phải được kiểm tra cùng Workspace/đúng TaskType ở API.
- Mở rộng enum notification theo event đã chốt nhưng giữ loại cũ; tên event cụ thể chốt cùng service/worker, schema một mình không bảo đảm giao thông báo.
- Không thêm snapshot fields/collection hoặc SUBMIT/WITHDRAW events vào approval trong giai đoạn này.

Các file mới dự kiến (tên cuối chốt lúc implementation):

| Migration đề xuất, CHƯA TẠO | Phạm vi |
|---|---|
| task-approval-decisions-foundation.js | Field nhận xét nếu được chốt, index chống trùng quyết định |
| task-post-link.js | task_id optional/index, không auto-link dữ liệu cũ |
| task-review-notifications.js | Loại sự kiện duyệt bổ sung tương thích |
| task-review-legacy-reconciliation.js — riêng, chỉ sau duyệt allowlist | Task QC/thiếu bước duyệt; không tự chạy cùng schema migration |

Mỗi migration mới mặc định DRY_RUN, explicit APPLY, fail trước ghi khi conflict. Cập nhật cùng init-mongo.js, checker và tests. Không có thay đổi PostgreSQL dự kiến ở phạm vi này; kiểm tra lại khi review contract ứng dụng.

## 5. Giai đoạn C — Rehearsal và APPLY có kiểm soát

1. Backup theo chính sách team; freeze mọi writer liên quan, không chỉ máy local nếu Atlas dùng chung.
2. Chạy cả chuỗi trên Mongo cô lập với metadata và dữ liệu bounded; thử writer cũ/mới và chạy lại.
3. Đối chiếu fingerprint/count/index, phát hiện thay đổi đồng thời hoặc duplicate thì dừng.
4. Chỉ APPLY Atlas khi operator duyệt và preflight sạch. DDL nhiều collection không atomic; nếu áp một phần phải khóa tính năng, kiểm kê và khôi phục metadata theo phương án đã review; không drop collection.
5. Xác minh không đổi tài liệu/content/Task cũ hoặc Post/Chat/Mail schemas ngoài phạm vi. Schema readiness phải pass với bản ứng dụng hiện tại.

## 6. Giai đoạn D — Code ứng dụng, làm sau review DB

- Bỏ QC và plannedPublishAt khỏi UI/DTO/validation/schema guard; giữ dueDate/CAS/date bounds. Backend phải ngừng ghi field bỏ dùng.
- Tạo/tìm đúng một Post theo Task; không đụng publishing. Các module content khác nối sau, chưa có integration thì không cho duyệt giả.
- Submit/approve/reject/history theo round; role/scope/step/CAS trong transaction, reason bắt buộc reject, final approve FINISHED. Thứ tự tăng round ở lần gửi đầu/gửi lại phải nhất quán với mặc định approvalRound=1 hiện có.
- Review nội dung/khóa sửa/phiên bản vẫn là checkpoint với Content Writing; không tuyên bố end-to-end an toàn khi chưa phối hợp.
- Notification có outbox và phân quyền recipient Manager/Client/Creator theo event, giữ hành vi giao việc hiện có.
- Thu hồi chưa code khi BA chưa chốt; chưa mở lại FINISHED.

## 7. Giai đoạn E — Cleanup sau khi ổn định

Chỉ sau khi writer mới triển khai và dữ liệu cũ được review, mới cân nhắc migration riêng để bỏ plannedPublishAt/QC/detailIdentified legacy. Không xóa bằng việc đơn thuần xóa field Java. Không xóa lịch sử approval. Việc thu hẹp enum phải preflight sạch và có kế hoạch tương thích/rollback.

## 8. Ranh giới bàn giao

- Phước/chủ Content Writing: nhận contract Task-content và điểm mở, không tự thay editor/Yjs/content versions.
- Chủ publishing: không sửa status/queue/callback/xuất bản trong kế hoạch này.
- Chủ module Livestream/Survey/Event: thống nhất nội dung bàn giao và API tích hợp riêng.
- Tài liệu report không thuộc phạm vi yêu cầu; Jira/master plan không tự đổi assignee/Done.

# DA-1236 — Bình luận Task: triển khai và setup test

Ngày 2026-10-17. FR 3.6.3. [Spec](3-6-3-add-comments-on-task/spec.md), [kết quả kiểm tra](3-6-3-add-comments-on-task/test.md).

## Đã triển khai

- Bình luận trong hộp chi tiết Task hiện có: văn bản/link, nhắc tên thành viên, tải và xem ảnh, tải lịch sử cũ, làm mới, giữ bản nháp khi gửi lỗi. Gõ @ ngay trong ô soạn để mở dropdown nổi tại vị trí @, tự tránh mép màn hình. Chọn bằng chuột hoặc ↑↓ + Enter thành nhãn inline có highlight; xóa nhãn cuối sẽ bỏ User ID, Undo khôi phục. Esc chỉ đóng gợi ý. Email không mở gợi ý; chỉ tên được chọn mới thêm User ID mention. Nút Nhắc tên vẫn giữ. Ctrl/⌘ + Enter để gửi khi không đang chọn tên/không trong IME composition.
- Manager/Creator/Client active cùng Workspace được xem/gửi trên mọi Task, kể cả manual/legacy/đã kết thúc; không phụ thuộc cờ Client duyệt hay markers lịch sử bắt đầu. Owner cần membership Manager thực tế trong Workspace.
- Không sửa Task/Campaign/approval round, không mở lại công việc; không sửa/xóa comment. Nhận xét duyệt nội dung và Chat vẫn là chức năng riêng.
- Thông báo in-app cho mentions + Creator phụ trách + Managers, loại tác giả và trùng; Client chỉ nhận khi được nhắc tên. Không QC, không email. Worker kiểm lại quyền trước delivery.
- Mongo transaction tạo comment, gắn ảnh và ghi outbox; retry cùng tác giả/Task/clientRequestId và payload trả kết quả cũ. Thay payload cùng key trả conflict.

## Phạm vi file và dữ liệu

Business: TaskCommentController, TaskCommentService/Store/Access, TaskCommentUploads/ImageValidator/UploadCleanup/Outbox, DTO và TaskCommentProperties; mở rộng TaskNotificationWorker hiện có.

Web: components/services/hooks/types trong pages/tasks, tích hợp TaskWorkflowContent và locale src/i18n/locales/{vi,en}/tasks.json. Cache đọc comment/member/image tách theo User ID; composer reset khi đổi tài khoản/Task. Không thay module viết nội dung, xuất bản, Chat, auth hoặc UI khác.

Ô soạn comment dùng Tiptap/Radix đã có trong dependencies, cấu hình riêng chỉ văn bản và mention atomic; không tái sử dụng/sửa editor Post, không thêm package. Chỉ draft có node/nhãn; khi gửi serialize về content plain text + mentions User IDs như API cũ. Chưa bổ sung vị trí/label snapshot để highlight lịch sử đã gửi. Clipboard chỉ nhận văn bản, không nhận HTML/mention ID từ ngoài.

Gateway giữ nguyên catch-all route API hiện có. Không thêm bảng PostgreSQL. Reuse user_notifications và TaskNotificationInbox hiện có.

Mongo dùng task_comments, task_comment_uploads, task_notification_outbox. **File init-mongo.js và migration foundation đã có đủ schema/index cho comment**, không cần migration mới cho đợt code này. Không chạy migration, init hay seed lên Atlas/demo trong đợt triển khai này. Chỉ init container kiểm thử riêng, không gắn volume dữ liệu dự án; đã dọn container/dữ liệu tạm và dừng Vite/trình duyệt kiểm thử sau khi xong.

## 1. Kiểm tra Mongo trước khi chạy ứng dụng

Chạy **toàn bộ** playground chỉ đọc `docs/database/migrations/check-mongo-migrations.mongodb.js` trên kết nối đúng. File tự kiểm database brandhub kể cả ban đầu chọn test. Nó kiểm trạng thái schema hiện tại, không chứng minh lịch sử chạy từng file migration.

Cần ba collection cùng validator/index, đặc biệt:

| Collection | Index quan trọng |
|---|---|
| task_comments | idx_task_comments_timeline; **unique** uq_task_comments_client_request |
| task_comment_uploads | **unique** uq_task_comment_uploads_storage_key; idx_task_comment_uploads_owner; idx_task_comment_uploads_cleanup |
| task_notification_outbox | **unique** uq_task_notification_outbox_event; idx_task_notification_outbox_due; idx_task_notification_outbox_lease |

Môi trường cần Mongo replica set/Atlas hỗ trợ transaction. Nếu thiếu validator/index, API gửi trả TASK_COMMENT_SCHEMA_NOT_READY; không tự tạo schema lúc ghi.

Nếu checker báo thiếu: dừng và đối chiếu schema hiện tại trước khi lập migration nâng cấp. `2026-10-14-task-detail-comments-foundation.js` là nguồn gốc ba collection này, nhưng còn chứa Task fields lịch sử đã được clean sau đó; **không chạy lại toàn bộ migration cũ một cách mù quáng**, không chạy init lên DB đang dùng. Không cần backfill Task chỉ để mở bình luận.

## 2. Kiểm tra storage và PostgreSQL

- Dùng cấu hình FileStorageService/S3 hiện có, không in hoặc gửi credentials. Service cần quyền PutObject/GetObject/DeleteObject trên prefix `task-comment-images/`.
- Prefix này **phải private**, không nằm trong public policy/prefix `image/`. API không trả S3 URL/key; ảnh tải qua API có auth, kiểm quyền Task, no-store/nosniff. Chưa kiểm chứng bucket policy thật trong đợt này; phải review policy trước khi dùng ảnh nhạy cảm.
- DRAFT chỉ chủ upload preview được và chỉ khi chưa hết hạn; ATTACHED theo quyền Workspace/Task hiện tại. Không dùng endpoint Mail hoặc Material Library.
- PostgreSQL cần user_notifications hiện có. Notification worker lấy outbox Mongo, ghi inbox SQL bằng ID ổn định + ON CONFLICT; chỉ SENT sau commit, lỗi thì retry. Không có migration PostgreSQL mới.

## 3. Cấu hình kỹ thuật

| Property | Mặc định | Ý nghĩa |
|---|---|---|
| app.task-comments.draft-hours | 24 | Thời gian giữ ảnh nháp chưa gắn comment |
| app.task-comments.max-draft-uploads-per-user | 20 | Trần ảnh DRAFT theo User **trong từng Task**; không phải số ảnh mỗi comment |
| app.task-comments.cleanup-enabled | true | Bật worker dọn ảnh nháp hết hạn |
| app.task-comments.cleanup-ms | 60000 | Chu kỳ dọn, batch tối đa 20; lease 300 giây |
| app.task-notifications.enabled | true | Worker thông báo Task/comment hiện có |
| app.task-notifications.poll-ms | 5000 | Chu kỳ lấy sự kiện thông báo |

Comment bắt buộc văn bản không rỗng, tối đa 10.000 ký tự. Tối đa 100 User ID mention đang hoạt động, tra cứu theo trang 50. Tối đa 5 ảnh/comment, JPEG/PNG/WebP, mỗi ảnh tối đa 5 MiB (5.242.880 byte); MIME/decode thật và trần 20 triệu điểm ảnh chống quá tải decode.

spring.servlet.multipart.max-file-size giữ 5MB; max-request-size tăng từ 5MB lên **6MB** để đủ overhead multipart cho **một ảnh 5MB**. UI tải từng file tuần tự, không gửi năm ảnh trong cùng request. Reverse proxy (nếu có) cần cho request tương ứng.

Cleanup dùng lease/CAS DRAFT → CLEANUP_PENDING; chỉ xóa metadata sau khi xóa object thành công, không TTL metadata và không dọn ảnh ATTACHED. Ảnh người dùng bỏ khỏi bản nháp sẽ hết hạn rồi được dọn, không xóa ngay ảnh có thể vừa được gắn.

## 4. Chạy và test thủ công

1. Kiểm Mongo/schema, cấu hình S3 private và PostgreSQL như trên. Không cần reset DB/seed thêm tài khoản.
2. Business: dừng process cũ, clean compile và chạy lại từ đúng thư mục `brandhub-business-service`:

   ```powershell
   mvn.cmd clean compile
   mvn.cmd spring-boot:run
   ```

   Trong cmd khi đổi ổ đĩa dùng `cd /d D:\FPT\FA26\SEP490\brandhub-business-service`. Đã gặp class cũ/IDE ghi lại target/classes trong quá trình kiểm tra; clean build/restart trước khi kết luận API chưa có. Không thay cấu hình IDE của thành viên.
3. Chạy Gateway và Web theo cấu hình hiện có. Mở Danh sách công việc → một Task → phần **Bình luận công việc** bên dưới chi tiết.
4. Manager gửi văn bản + link, nhắc Creator/Client; đổi sang các tài khoản test có sẵn của cùng Workspace và kiểm timeline/thông báo/link mở đúng Task. Không nhắc Client thì Client không nhận notification tự động.
5. Thử ảnh hợp lệ và ảnh quá 5MB/sai định dạng, xem preview trước/sau gửi. Client khác không xem được DRAFT của người gửi; ATTACHED cùng Task thì xem được.
6. Ngắt mạng lúc gửi, kiểm nội dung giữ lại rồi **Thử gửi lại**; cùng nội dung không xuất hiện hai lần. Bản nháp chưa gửi phải được xác nhận trước khi đóng bằng dialog ứng dụng.
7. Thử Task FINISHED/CANCELLED và Task manual, Client vẫn xem/gửi; status Task/Campaign không đổi. Thử tài khoản ngoài/bị gỡ Workspace phải bị chặn. Kiểm cả light/dark, vi/en và màn hình nhỏ.

Timeline không tự đồng bộ qua WebSocket trong đợt này; người khác bấm **Làm mới** để lấy bình luận mới.

## 5. Kết quả và giới hạn bàn giao

Đã qua 46 test Task hiện có, 38 assertions smoke trên Mongo replica set cô lập (mock S3/SQL repos/inbox), lint Web mới và browser API-mock cho mention/retry/ảnh/layout. Không thêm/commit file test dưới src. Không chạm dữ liệu Atlas/demo, không seed tài khoản.

Chưa xác minh S3 policy/IAM thật, notification inbox SQL thật, request multipart qua Gateway thật, crash sau SQL commit và các race cross-store trên môi trường dùng chung. Typecheck toàn Web còn lỗi ngoài scope ở Content Writing/editor/Workspace dashboard/AppRoutes; chưa sửa phần thành viên khác. Chờ team review và kiểm thử tích hợp trước khi đánh Done Jira/Report.

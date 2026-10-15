# Plan — FR 3.6.3 / DA-1236

2026-10-14. [Spec confirmed](spec.md); [contract chung](../task-workflow-contract.md) §5/6.
Comments độc lập start/Q8, dùng active Workspace membership + Task scope theo Q13.

## API final và model

GET/POST `.../tasks/{taskId}/comments`: cursor timeline và clientRequestId idempotency.
POST `.../tasks/{taskId}/comment-uploads` multipart; GET `.../comment-uploads/{id}/content`
stream có auth, không public S3 URL. Payload/DTO/errors như contract, không nhận author snapshot từ browser.
Mongo task_comments, task_comment_uploads, task_notification_outbox với indexes định danh/cursor/cleanup.
Không thêm SQL table: đưa notification vào user_notifications hiện có bằng delivery UUID.

## Xử lý và bảo mật

TaskWorkflowAccess áp mọi lần đọc/gửi/mention/ảnh, kể cả terminal. Mentions User ID cùng WS và
có quyền Task; Client active được bình luận mọi Task cùng WS, kể cả manual/legacy.
Không dùng first-start/revision làm gate đọc/bình luận. Task/comment không đổi status/Campaign/approvalRound.
Server plain text, HTTP(S) link; upload MIME thực + decode, 5 ảnh ×5MB JPEG/PNG/WebP.
Bind DRAFT owner upload vào một comment bằng CAS; transaction comment + bind + per-user outbox.
Retry cùng key cùng payload trả kết quả cũ, khác payload trả 409.
Cleanup DRAFT bằng worker/state CAS, không TTL xóa metadata trước object. Download ACL, không Mail/Library.
Notification dedup/exclude author/recheck access, Client chỉ mentioned. Cursor createdAt/id tránh trùng.

## Files, UI và trình tự

Business TaskCommentController/Service/Store, upload adapter FileStorageService, outbox worker;
không tái sử dụng API MailAttachment làm endpoint chung. Web comment panel/composer trong Tasks,
mention keyboard, preview/upload progress, giữ draft; không sửa Workspace Chat.
Locale `src/locales/vi/tasks.json` và `src/locales/en/tasks.json` comments/mentions/uploads/errors,
semantic theme, loading/empty/error và responsive. Registry i18n xác minh trước implementation.
Schema → ACL → timeline/text → upload/bind → notifications → UI → race/security regression.

## Dependencies/risk

Private S3 bucket/config, MIME detection sẵn có dùng adapter không mở rộng Mail rules;
Mongo replica set transactions, SQL inbox idempotency. Race membership/cleanup;
retry cùng id khác nội dung; ảnh giả/oversize; notification không lộ brief/comment cho người ngoài WS.
Chỉ kiểm schema offline phase1; không tuyên bố storage/notification vận hành trước integration tests.

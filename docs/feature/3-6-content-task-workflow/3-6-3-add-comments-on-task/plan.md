# Plan — FR 3.6.3 / DA-1236

2026-10-14. [Spec confirmed](spec.md); [contract chung](../task-workflow-contract.md) §5/6.
Comments độc lập start/Q8, dùng active Workspace membership + Task scope theo Q13.

2026-10-17 execution: separate TaskCommentAccess (no workflow/date/start/schema gate for reads), scoped raw Mongo store and transactions; dedicated comment-members route to avoid changing assignment member-options. Reuse existing private FileStorageService object APIs and shared transaction/inbox, no Mail endpoint changes. No QC notifications. UI lives below Task details inside existing dialog with one composer, mention dropdown, cursor load older, private image previews and retry-safe submission. Use actual locale paths src/i18n/locales/{vi,en}/tasks.json. Draft uploads expire after configurable 24h; cleanup claims DRAFT/expired lease with CAS, removes metadata only after successful object deletion. Technical safety limits: 20 million decoded pixels, at most 100 mentions; all active scoped users remain visible through paginated mention search. Existing foundation init/migration already defines needed collections, so no schema rewrite or Atlas writes in this implementation. All new tests stay outside src and are not committed.

## API final và model

GET/POST `.../tasks/{taskId}/comments`: cursor timeline và clientRequestId idempotency.
POST `.../tasks/{taskId}/comment-uploads` multipart; GET `.../comment-uploads/{id}/content`
stream có auth, không public S3 URL. Payload/DTO/errors như contract, không nhận author snapshot từ browser.
Mongo task_comments, task_comment_uploads, task_notification_outbox với indexes định danh/cursor/cleanup.
Không thêm SQL table: đưa notification vào user_notifications hiện có bằng delivery UUID.

## Xử lý và bảo mật

TaskCommentAccess áp mọi lần đọc/gửi/mention/ảnh, kể cả terminal. Mentions User ID cùng WS và
có quyền Task; Client active được bình luận mọi Task cùng WS, kể cả manual/legacy.
Không dùng first-start/revision làm gate đọc/bình luận. Task/comment không đổi status/Campaign/approvalRound.
Server plain text, HTTP(S) link; upload MIME thực + decode, 5 ảnh ×5MB JPEG/PNG/WebP.
Bind DRAFT owner upload vào một comment bằng CAS; transaction comment + bind + per-user outbox.
Retry cùng key cùng payload trả kết quả cũ, khác payload trả 409.
Cleanup DRAFT bằng worker/state CAS, không TTL xóa metadata trước object. Download ACL, không Mail/Library.
Notification dedup/exclude author/recheck access, Client chỉ mentioned. Cursor createdAt/id tránh trùng.
Cache comment/member/image phía Web được phân tách theo User ID đang đăng nhập; không dùng lại dữ liệu riêng tư của phiên trước khi quick-login đổi tài khoản. Draft composer cũng reset khi đổi User/Task.

## Files, UI và trình tự

Business TaskCommentController/Service/Store, upload adapter FileStorageService, outbox worker;
không tái sử dụng API MailAttachment làm endpoint chung. Web comment panel/composer trong Tasks,
mention keyboard, preview/upload progress, giữ draft; không sửa Workspace Chat.
Locale `src/i18n/locales/vi/tasks.json` và `src/i18n/locales/en/tasks.json`, keys comments và workflow.errors,
semantic theme, loading/empty/error và responsive; dùng registry i18n hiện có.
Schema → ACL → timeline/text → upload/bind → notifications → UI → race/security regression.

### Bổ sung nhập @ trực tiếp (2026-10-17)

Tách hook truy vấn thành viên dùng chung cho nút Nhắc tên và autocomplete. Debounce tìm kiếm, không hiện kết quả query cũ trong lúc người dùng đang đổi từ khóa. Theo UX mới, dùng Tiptap đã có trong dependencies với document/paragraph/text/hardBreak/undo và node mention inline atomic riêng cho comment; không tái sử dụng hoặc sửa editor Post. Node giữ User ID/label/role trong draft, serialize về plain text + User IDs dedup trước khi gửi API cũ. Filter transaction giữ giới hạn 10.000 ký tự/100 người; paste chỉ plain text, không nhận mention HTML từ clipboard.

Popover Radix sẵn có, virtual anchor bằng editor.coordsAtPos tại dấu @, có collision/flip/scroll handling; giữ focus editor, listbox/option, aria-activedescendant, phím ↑↓ Enter/Escape, IME guard. Initials thay avatar chưa có. Chọn toolbar Nhắc tên chèn node ở selection hiện tại. Controlled draft reset/success/discard chỉ sync khi text/mentions thực sự khác để không nhảy caret. Chỉ đổi Web và tài liệu, không DB/API/Chat/module editor khác. Locale tasks.comments.mentionHint/mentionSuggestions/mentionTooLong ở vi/en song song. Kiểm serialization, xóa/undo/retry và popup vị trí bằng helper local/browser API mock.

## Dependencies/risk

Private S3 bucket/config, MIME detection sẵn có dùng adapter không mở rộng Mail rules;
Mongo replica set transactions, SQL inbox idempotency. Race membership/cleanup;
retry cùng id khác nội dung; ảnh giả/oversize; notification không lộ brief/comment cho người ngoài WS.
Đã kiểm schema/init trên Mongo replica set riêng, không truy cập Atlas. Storage/inbox thật cần integration test theo [hướng dẫn setup](../task-comments-implementation-2026-10-17.md); không coi mock adapter là đã xác minh cấu hình S3/PostgreSQL thực tế.

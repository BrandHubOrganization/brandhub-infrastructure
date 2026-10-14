# Plan — 3-10-4-content-moderation-queue

Nguồn: [spec](spec.md), [quyết định đã duyệt](../confirmed-decisions-2026-10-01.md).

Thiết kế, file paths, API, migration, thứ tự và rủi ro: **mục 3** của [plan tổng thể](../plan.md). Các global constraints và Review Focus trong plan tổng thể áp dụng đầy đủ.

Thành phần: ContentVersionService; AdminModerationController/Service; PublishJobConsumer.

Trình tự: test nghiệp vụ RED → backend/data GREEN → API/security → UI/locale → build/integration. Locale thêm trong brandhub-web/src/i18n/locales/vi/admin.json và en/admin.json; theme dùng token hiện có. Không sửa monitoring.

## Local schema recovery — 2026-10-14

Preflight read-only xác nhận thiếu bảng moderation nhưng có `users`, `user_strikes`, `audit_logs`, `admin_email_outbox`. Backup PostgreSQL local, sau đó chạy đúng `2026-10-04-content-moderation.sql` với ON_ERROR_STOP. Kiểm tra chạy lại an toàn, schema/constraints/indexes, query danh sách và bộ đếm ở ba trạng thái. File init đã chứa migration này: chỉ đối chiếu, không thêm trùng. Chạy AdminSecurityTest hiện có; không dùng ContentModerationDatabaseTest với DB shared vì fixture xóa collection test. Không tự tạo token hoặc đăng nhập thay người dùng để smoke test live.

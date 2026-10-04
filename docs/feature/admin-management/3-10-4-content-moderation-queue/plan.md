# Plan — 3-10-4-content-moderation-queue

Nguồn: [spec](spec.md), [quyết định đã duyệt](../confirmed-decisions-2026-10-01.md).

Thiết kế, file paths, API, migration, thứ tự và rủi ro: **mục 3** của [plan tổng thể](../plan.md). Các global constraints và Review Focus trong plan tổng thể áp dụng đầy đủ.

Thành phần: ContentVersionService; AdminModerationController/Service; PublishJobConsumer.

Trình tự: test nghiệp vụ RED → backend/data GREEN → API/security → UI/locale → build/integration. Locale thêm trong brandhub-web/src/i18n/locales/vi/admin.json và en/admin.json; theme dùng token hiện có. Không sửa monitoring.

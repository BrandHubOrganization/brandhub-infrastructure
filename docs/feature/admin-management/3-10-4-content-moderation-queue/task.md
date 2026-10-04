# Task — 3-10-4-content-moderation-queue

- [x] Đối chiếu spec và quyết định ngày 2026-10-01; xác định chủ sở hữu tích hợp (bài Mongo: Lộc, phiên bản soạn thảo FR 3.6.10: Trung, FR 3.6.33/34: Tuấn, publisher: Phước).
- [x] Viết plan kỹ thuật và kịch bản test trước code.
- [x] Migration PostgreSQL `2026-10-04-content-moderation.sql` + Mongo `2026-10-04-create-post-versions-collection.js`; chạy 2 lần trên DB test, backup, 2 lần trên DB dev.
- [x] `posts.content_version` (tăng mỗi lần sửa) + hook `PostServiceImpl.submitForReview` → `ContentModerationService.onSubmitted` (đã được người dùng duyệt; cần báo Lộc review).
- [x] Quyết định APPROVE/BLOCK theo phiên bản, ghi strike qua FR 3.10.5 cùng transaction, email tác giả, audit.
- [x] API nội bộ cho Tuấn (`/flags`) và Phước (`/eligibility`), khóa `X-Internal-Service-Key`.
- [x] UI SCR-ADM-04: hàng đợi, lọc trạng thái/nguồn, phân trang 10/20/50, hộp thoại đối chiếu snapshot và phán quyết; VI/EN, light/dark, 390px.
- [x] Chạy test/build; ghi kết quả trong test.md.
- [ ] Tuấn nối FR 3.6.33/34 vào `/flags`; Phước gọi `/eligibility` trong `PublishJobConsumer` trước adapter (fail closed).
- [ ] Review độc lập diff trước khi commit/push.

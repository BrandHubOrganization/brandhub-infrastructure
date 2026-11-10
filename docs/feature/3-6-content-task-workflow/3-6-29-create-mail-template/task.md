# Task — Create Mail Template (FR 3.6.29)

- **FR:** 3.6.29 · **Jira:** DA-999
- **Mục tiêu:** Tạo mẫu email mới (từ đầu hoặc clone mẫu hệ thống/mẫu Workspace), có biến, ảnh và tệp đính kèm.
- Mục đã tick là đã làm và đã kiểm chứng (kết quả ở `test.md`).

## 0. Chuẩn bị
- [ ] 0.1 Đọc đủ spec/plan/task/test; xác nhận các giả định ở plan §13 còn hiệu lực.
- [x] 0.2 Chuyển DA-998..DA-1002 và DA-1256..DA-1259 sang In Progress khi bắt đầu từng task (đã hoàn tất — toàn bộ 9 ticket nay ở Done).
- [x] 0.3 Dựng môi trường dev: Postgres, Redis, Mongo, SMTP giả (MailHog/GreenMail), S3 hoặc emulator; kiểm `admin.mail.allowed-recipients` để không gửi mail thật.

## 1. Nền tảng dữ liệu (plan §4 — DA-998)
- [x] 1.1 Migration Postgres: `mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, `mail_attachments` (+ index, unique `event_key`, unique `(workspace_id, email_lower)`).
- [x] 1.2 Migration Mongo: collection `mail_templates` (validator `$jsonSchema`, index `{workspaceId, deletedAt, createdAt}`, `{type, deletedAt}`).
- [x] 1.3 Cập nhật `init-postgres-v2.sql`, `init-mongo.js`, `mongo-atlas-migrations.md`.
- [x] 1.4 Cập nhật ERD, DBML, `erd-entity-descriptions.md`, `database-strategy.md` (xem mục 10).
- [x] 1.5 Entity/Document + repository (Postgres access uses JdbcTemplate stores `MailDeliveryStore`, `MailAttachmentStore`, `MailSuppressionStore`, `MailRecipientLookup`): `MailTemplateDocument`, `MailBatch`, `MailDelivery`, `MailSendQuota`, `MailSuppression`, `MailAttachment`.
- [x] 1.6 `ErrorCode` mới: `TEMPLATE_NOT_FOUND`, `SYSTEM_TEMPLATE_READ_ONLY`, `MAIL_QUOTA_EXCEEDED`, `MAIL_SCHEDULE_OUT_OF_RANGE`, `MAIL_ATTACHMENT_INVALID`, `MAIL_BATCH_NOT_CANCELLABLE`, `EMAIL_SERVICE_UNAVAILABLE`.
- [x] 1.7 Cấu hình: các property ở plan §10 (có mặc định, khai báo trong `application.yml`, `AppProperties`).
- [x] 1.8 Thêm dependency `jsoup`, `tika-core` (backend) và `@tiptap/extension-image` (frontend).

## 2. Template CRUD (plan §5.1, §6.1 — DA-998..DA-1001)
- [x] 2.1 `HtmlSanitizer` (allow-list jsoup) + unit test payload XSS.
- [x] 2.2 `MailTemplateService`: list (lọc `deletedAt`, `includeSystem`, tìm kiếm, phân trang), get.
- [x] 2.3 Create (+ clone từ `cloneFromId`, kiểm nguồn hợp lệ, `type = CUSTOM`).
- [x] 2.4 Update PATCH một phần; chặn template hệ thống; kiểm sở hữu (người tạo hoặc OWNER/MANAGER).
- [x] 2.5 Soft delete; kiểm quyền như 2.4.
- [x] 2.6 `MailTemplateController` + `@RequireRole({OWNER, MANAGER, CREATOR})`.
- [x] 2.7 `TemplateRenderer`: parse biến `{{x}}`, built-in, escape, danh sách biến còn thiếu; `POST .../preview`.
- [x] 2.8 Test JUnit cho 2.1–2.7 (AC-V*, AC-C*, AC-U*, AC-D*).

## 3. Tệp đính kèm và ảnh (plan §5.4, §8 — DA-1256)
- [x] 3.1 `MailAttachmentService`: upload S3 (khóa riêng theo Workspace), kiểm kích thước, allow-list, magic bytes (Tika), tổng ≤10MB, ≤3 tệp.
- [x] 3.2 Endpoint `POST .../attachments` và `.../images` (ảnh công khai trên prefix riêng).
- [x] 3.3 Gắn `attachmentIds` vào template (create/update) và đánh dấu `bound`.
- [x] 3.4 Job dọn tệp chưa gắn quá 24h.
- [x] 3.5 Test JUnit: loại hợp lệ/không hợp lệ, đuôi giả, vượt kích thước, vượt số tệp (AC-A*).

## 7. Frontend Workspace (plan §9 — DA-998..DA-1002, DA-1256..1258)
- [x] 7.1 Service/API client + types + hooks (`useMailTemplates`, `useMailBatches`, `useMailQuota`).
- [x] 7.2 Trang list `/workspaces/:id/mail-templates` (tìm kiếm, phân trang, chip "Hệ thống", loading/empty/error).
- [x] 7.3 Form tạo/sửa với TipTap (chèn biến, ảnh), đính kèm, "Dùng mẫu hệ thống"; giữ dữ liệu khi lỗi.
- [x] 7.4 Modal Gửi: chọn template, dán/upload CSV (parse BOM/quote, map cột), biến tự phát hiện, bật/tắt đính kèm, preview, gửi thử, hẹn giờ, quota; chặn bấm đúp.
- [x] 7.5 Trang lô + chi tiết người nhận + hủy lịch.
- [x] 7.6 Trang unsubscribe công khai (vi/en).
- [x] 7.7 Route, `ROUTE_ACCESS`, mục sidebar.
- [x] 7.8 Vitest cho parser biến/CSV/validate form; Playwright E2E theo test.md.

## 9. i18n và giao diện
- [x] 9.1 Thêm namespace `mailTemplate` + `admin.mailTemplate` + `nav` + `broadcast.pickTemplate` vào **cả** `vi.json` và `en.json` (key song song).
- [ ] 9.2 Kiểm tra light/dark: không hex/rgb cứng, trạng thái lô và chip dùng token.
- [ ] 9.3 Kiểm tra responsive (mobile) cho list, modal gửi, trang lô.

## 10. Tài liệu
- [x] 10.1 ERD (`brandhub-erd.puml`): thêm `mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, `mail_attachments`; cập nhật `mail_templates` (`attachments`, `clonedFromId`, `deletedAt`, `workspaceId` nullable) — **đã làm ở bản tài liệu 2026-10-12**, đối chiếu lại với code.
- [x] 10.2 DBML + `erd-entity-descriptions.md` + `database-strategy.md` + `service-boundaries.md` tương ứng.
- [x] 10.3 Đối chiếu `report3_spec.md` và `report4_sequence.puml` của 5 FR với code thật.
- [x] 10.4 Ghi kết quả test và giới hạn vào `test.md` (mục kết quả).
- [x] 10.5 Cập nhật BA §9 nếu phát sinh thay đổi nghiệp vụ.

## 11. Kiểm thử và bàn giao
- [x] 11.1 Chạy JUnit, Vitest, Playwright, type-check, lint (0 lỗi mới).
- [x] 11.2 Chạy integration live (backend thật + Postgres + Mongo + SMTP giả): theo test.md §9.
- [ ] 11.3 Review độc lập diff (đặc biệt: sanitize, quota đồng thời, token unsubscribe, quyền chéo Workspace).
- [x] 11.4 Commit theo convention; PR vào `develop` với tiêu đề `[DA-xxx] ...`, Squash and merge (PR #41, #48, #50, #64, #68 đã merge vào develop).
- [x] 11.5 Chuyển Jira các task sang In review; sau review → Done (DA-998, 999, 1000, 1001, 1002, 1256, 1257, 1258, 1259 đã chuyển Done).
- [ ] 11.6 Kiểm tra migration đã áp dụng trên môi trường staging trước khi deploy (Postgres + Mongo + seed).

## Ánh xạ Jira ↔ task

| Jira | Nhóm task |
|---|---|
| DA-999 Create | 2.1, 2.3, 7.3 |

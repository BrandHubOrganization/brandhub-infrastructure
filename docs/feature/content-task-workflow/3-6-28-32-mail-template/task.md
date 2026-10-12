# Task — Mail Template (FR 3.6.28 – 3.6.32)

> Bước ③ của [feature-workflow](../../../rule/feature-workflow.md). Đọc [spec.md](spec.md) và [plan.md](plan.md) trước; kiểm chứng bằng [test.md](test.md).
> Mỗi task ánh xạ tới mục trong plan và nhóm AC trong spec. Tick khi xong; không đổi nghiệp vụ trong lúc code — sai nghiệp vụ thì quay lại spec (feature-workflow §5).
> Quy ước commit: `<type>(DA-xxx): <English description>` — xem [git-commit-convention](../../../rule/git-commit-convention.md). Nhánh: `feat/DA-<id>-<mô-tả>` từ `develop`, không push thẳng `develop`.

## 0. Chuẩn bị
- [ ] 0.1 Đọc đủ spec/plan/task/test; xác nhận các giả định ở plan §13 còn hiệu lực.
- [ ] 0.2 Chuyển DA-998..DA-1002 và DA-1256..DA-1259 sang In Progress khi bắt đầu từng task.
- [ ] 0.3 Dựng môi trường dev: Postgres, Redis, Mongo, SMTP giả (MailHog/GreenMail), S3 hoặc emulator; kiểm `admin.mail.allowed-recipients` để không gửi mail thật.

## 1. Nền tảng dữ liệu (plan §4 — DA-998)
- [ ] 1.1 Migration Postgres: `mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, `mail_attachments` (+ index, unique `event_key`, unique `(workspace_id, email_lower)`).
- [x] 1.2 Migration Mongo: collection `mail_templates` (validator `$jsonSchema`, index `{workspaceId, deletedAt, createdAt}`, `{type, deletedAt}`).
- [ ] 1.3 Cập nhật `init-postgres-v2.sql`, `init-mongo.js`, `mongo-atlas-migrations.md`.
- [ ] 1.4 Cập nhật ERD, DBML, `erd-entity-descriptions.md`, `database-strategy.md` (xem mục 10).
- [ ] 1.5 (MailTemplateDocument + MailTemplateMongoRepository done; Postgres entities pending DA-1002) Entity/Document + repository: `MailTemplateDocument`, `MailBatch`, `MailDelivery`, `MailSendQuota`, `MailSuppression`, `MailAttachment`.
- [ ] 1.6 (TEMPLATE_NOT_FOUND, SYSTEM_TEMPLATE_READ_ONLY done; the rest come with later steps) `ErrorCode` mới: `TEMPLATE_NOT_FOUND`, `SYSTEM_TEMPLATE_READ_ONLY`, `MAIL_QUOTA_EXCEEDED`, `MAIL_SCHEDULE_OUT_OF_RANGE`, `MAIL_ATTACHMENT_INVALID`, `MAIL_BATCH_NOT_CANCELLABLE`, `EMAIL_SERVICE_UNAVAILABLE`.
- [ ] 1.7 Cấu hình: các property ở plan §10 (có mặc định, khai báo trong `application.yml`, `AppProperties`).
- [ ] 1.8 Thêm dependency `jsoup` (done), `tika-core` (pending, DA-1256) (backend).

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
- [ ] 3.1 `MailAttachmentService`: upload S3 (khóa riêng theo Workspace), kiểm kích thước, allow-list, magic bytes (Tika), tổng ≤10MB, ≤3 tệp.
- [ ] 3.2 Endpoint `POST .../attachments` và `.../images` (ảnh công khai trên prefix riêng).
- [ ] 3.3 Gắn `attachmentIds` vào template (create/update) và đánh dấu `bound`.
- [ ] 3.4 Job dọn tệp chưa gắn quá 24h.
- [ ] 3.5 Test JUnit: loại hợp lệ/không hợp lệ, đuôi giả, vượt kích thước, vượt số tệp (AC-A*).

## 4. Engine gửi (plan §5.2, §6.2, §7 — DA-1002)
- [ ] 4.1 `MailService`: hàm gửi có tệp đính kèm, Reply-To, `List-Unsubscribe`; ném `EmailDeliveryException` (giữ nguyên 4 hàm cũ).
- [ ] 4.2 `RecipientClassifier`: trong/ngoài Workspace (Client `contact_email`, thành viên active).
- [ ] 4.3 `MailSendService.send`: validate, dedupe, render từng dòng, loại dòng lỗi, kiểm quota còn lại, ghi batch + deliveries trong một transaction, trả `202`.
- [ ] 4.4 `MailSendService.sendTest`: gửi đồng bộ, rate limit 10 lần/giờ/người dùng, 502 khi SMTP lỗi.
- [ ] 4.5 `MailDeliveryWorker`: `FOR UPDATE SKIP LOCKED`, throttle, retry/backoff, `event_key` idempotent, guard dev recipient.
- [ ] 4.6 `QuotaService`: tăng nguyên tử SYSTEM + WORKSPACE, ngày theo `Asia/Ho_Chi_Minh`, dời `next_attempt_at` sang ngày kế.
- [ ] 4.7 Test JUnit (service + worker) cho AC-S* (cần PostgreSQL thật cho `SKIP LOCKED` và quota đồng thời).

## 5. Hẹn giờ, hủy, unsubscribe (plan §6.3, §6.5 — DA-1257)
- [ ] 5.1 Hẹn giờ: validate khoảng, snapshot subject/body/đính kèm vào batch, trạng thái `SCHEDULED`.
- [ ] 5.2 Job mỗi phút chuyển `SCHEDULED → QUEUED` khi đến hạn.
- [ ] 5.3 `POST .../mail-batches/{bid}/cancel` (409 khi sai trạng thái; quyền người tạo hoặc OWNER/MANAGER).
- [ ] 5.4 `UnsubscribeTokenService` (HMAC `MAIL_UNSUBSCRIBE_SECRET`), footer + header cho người ngoài Workspace.
- [ ] 5.5 Endpoint công khai `GET/POST /api/v1/public/mail/unsubscribe` (permit ở SecurityConfig, không cần JWT, rate limit theo IP).
- [ ] 5.6 Bỏ qua người trong `mail_suppressions` (`SUPPRESSED`).
- [ ] 5.7 Test JUnit cho AC-H*, AC-X*.

## 6. Lịch sử, thông báo, retention (plan §5.3, §7 — DA-1258)
- [ ] 6.1 `GET .../mail-batches`, `GET .../mail-batches/{bid}` (phân trang, lọc trạng thái), `GET .../mail-quota`.
- [ ] 6.2 Notification trong app cho người tạo khi lô `COMPLETED`/`FAILED` (dùng service notification sẵn có).
- [ ] 6.3 Job retention 12 tháng (xóa deliveries và `body_html`, giữ counters).
- [ ] 6.4 Test JUnit cho AC-L*.

## 7. Frontend Workspace (plan §9 — DA-998..DA-1002, DA-1256..1258)
- [ ] 7.1 Service/API client + types + hooks (`useMailTemplates`, `useMailBatches`, `useMailQuota`).
- [ ] 7.2 Trang list `/workspaces/:id/mail-templates` (tìm kiếm, phân trang, chip "Hệ thống", loading/empty/error).
- [ ] 7.3 Form tạo/sửa với TipTap (chèn biến, ảnh), đính kèm, "Dùng mẫu hệ thống"; giữ dữ liệu khi lỗi.
- [ ] 7.4 Modal Gửi: chọn template, dán/upload CSV (parse BOM/quote, map cột), biến tự phát hiện, bật/tắt đính kèm, preview, gửi thử, hẹn giờ, quota; chặn bấm đúp.
- [ ] 7.5 Trang lô + chi tiết người nhận + hủy lịch.
- [ ] 7.6 Trang unsubscribe công khai (vi/en).
- [ ] 7.7 Route, `ROUTE_ACCESS`, mục sidebar.
- [ ] 7.8 Vitest cho parser biến/CSV/validate form; Playwright E2E theo test.md.

## 8. Điểm vào Client và Admin (plan §6.6, §6.7 — DA-1259)
- [ ] 8.1 Nút "Gửi email" trên trang Client, mở modal với người nhận và `clientName` điền sẵn.
- [ ] 8.2 Admin API `/api/v1/admin/mail-templates` (quyền hệ thống ADMIN, audit như các Admin controller).
- [ ] 8.3 Trang Admin "Mẫu email hệ thống" (CRUD, TipTap).
- [ ] 8.4 Seed 4 mẫu hệ thống (migration/seeder idempotent).
- [ ] 8.5 Nút "Chọn mẫu" trong form Broadcast 3.10.1 (chỉ sao chép subject/body); không sửa worker 3.10.1.
- [ ] 8.6 Test JUnit + Playwright cho AC-M*.

## 9. i18n và giao diện
- [ ] 9.1 Thêm namespace `mailTemplate` + `admin.mailTemplate` + `nav` + `broadcast.pickTemplate` vào **cả** `vi.json` và `en.json` (key song song).
- [ ] 9.2 Kiểm tra light/dark: không hex/rgb cứng, trạng thái lô và chip dùng token.
- [ ] 9.3 Kiểm tra responsive (mobile) cho list, modal gửi, trang lô.

## 10. Tài liệu
- [ ] 10.1 ERD (`brandhub-erd.puml`): thêm `mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, `mail_attachments`; cập nhật `mail_templates` (`attachments`, `clonedFromId`, `deletedAt`, `workspaceId` nullable) — **đã làm ở bản tài liệu 2026-10-12**, đối chiếu lại với code.
- [ ] 10.2 DBML + `erd-entity-descriptions.md` + `database-strategy.md` + `service-boundaries.md` tương ứng.
- [ ] 10.3 Đối chiếu `report3_spec.md` và `report4_sequence.puml` của 5 FR với code thật.
- [ ] 10.4 Ghi kết quả test và giới hạn vào `test.md` (mục kết quả).
- [ ] 10.5 Cập nhật BA §9 nếu phát sinh thay đổi nghiệp vụ.

## 11. Kiểm thử và bàn giao
- [ ] 11.1 Chạy JUnit, Vitest, Playwright, type-check, lint (0 lỗi mới).
- [ ] 11.2 Chạy integration live (backend thật + Postgres + Mongo + SMTP giả): theo test.md §9.
- [ ] 11.3 Review độc lập diff (đặc biệt: sanitize, quota đồng thời, token unsubscribe, quyền chéo Workspace).
- [ ] 11.4 Commit theo convention; PR vào `develop` với tiêu đề `[DA-xxx] ...`, Squash and merge.
- [ ] 11.5 Chuyển Jira các task sang In review; sau review → Done.
- [ ] 11.6 Kiểm tra migration đã áp dụng trên môi trường staging trước khi deploy (Postgres + Mongo + seed).

## Ánh xạ Jira ↔ task

| Jira | Nhóm task |
|---|---|
| DA-998 View | 1, 2.2, 2.6–2.8, 7.2, 7.7 |
| DA-999 Create | 2.1, 2.3, 7.3 |
| DA-1000 Update | 2.4, 7.3 |
| DA-1001 Delete | 2.5, 7.2 |
| DA-1002 Send | 4, 7.4, 8.1 |
| DA-1256 Attachments | 3, 7.3–7.4 |
| DA-1257 Scheduling/Quota/Unsubscribe | 4.6, 5, 7.4, 7.6 |
| DA-1258 History/Notifications | 6, 7.5 |
| DA-1259 Admin templates | 8.2–8.6 |

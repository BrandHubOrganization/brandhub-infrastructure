# Task — Send Email via Template (FR 3.6.32)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.32 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-1002
- **Mục tiêu:** Gửi email theo mẫu tới danh sách người nhận: hàng đợi, hạn mức, hẹn giờ/hủy, hủy đăng ký, lịch sử, Admin.
- Các mục đã tick là đã làm và đã kiểm chứng (kết quả ở `test.md`).

## 4. Engine gửi (plan §5.2, §6.2, §7 — DA-1002)
- [x] 4.1 `MailService`: hàm gửi có tệp đính kèm, Reply-To, `List-Unsubscribe`; ném `EmailDeliveryException` (giữ nguyên 4 hàm cũ).
- [x] 4.2 `RecipientClassifier`: trong/ngoài Workspace (Client `contact_email`, thành viên active).
- [x] 4.3 `MailSendService.send`: validate, dedupe, render từng dòng, loại dòng lỗi, kiểm quota còn lại, ghi batch + deliveries trong một transaction, trả `202`.
- [x] 4.4 `MailSendService.sendTest`: gửi đồng bộ, rate limit 10 lần/giờ/người dùng, 502 khi SMTP lỗi.
- [x] 4.5 `MailDeliveryWorker`: `FOR UPDATE SKIP LOCKED`, throttle, retry/backoff, `event_key` idempotent, guard dev recipient.
- [x] 4.6 `QuotaService`: tăng nguyên tử SYSTEM + WORKSPACE, ngày theo `Asia/Ho_Chi_Minh`, dời `next_attempt_at` sang ngày kế.
- [x] 4.7 Test JUnit (service + worker) cho AC-S* (cần PostgreSQL thật cho `SKIP LOCKED` và quota đồng thời).

## 5. Hẹn giờ, hủy, unsubscribe (plan §6.3, §6.5 — DA-1257)
- [x] 5.1 Hẹn giờ: validate khoảng, snapshot subject/body/đính kèm vào batch, trạng thái `SCHEDULED`.
- [x] 5.2 Job mỗi phút chuyển `SCHEDULED → QUEUED` khi đến hạn.
- [x] 5.3 `POST .../mail-batches/{bid}/cancel` (409 khi sai trạng thái; quyền người tạo hoặc OWNER/MANAGER).
- [x] 5.4 `UnsubscribeTokenService` (HMAC `MAIL_UNSUBSCRIBE_SECRET`), footer + header cho người ngoài Workspace.
- [x] 5.5 Endpoint công khai `GET/POST /api/v1/public/mail/unsubscribe` (permit ở SecurityConfig, không cần JWT, rate limit theo IP).
- [x] 5.6 Bỏ qua người trong `mail_suppressions` (`SUPPRESSED`).
- [x] 5.7 Test JUnit cho AC-H*, AC-X*.

## 6. Lịch sử, thông báo, retention (plan §5.3, §7 — DA-1258)
- [x] 6.1 `GET .../mail-batches`, `GET .../mail-batches/{bid}` (phân trang, lọc trạng thái), `GET .../mail-quota`.
- [x] 6.2 Notification trong app cho người tạo khi lô `COMPLETED`/`FAILED` (dùng service notification sẵn có).
- [x] 6.3 Job retention 12 tháng (xóa deliveries và `body_html`, giữ counters).
- [x] 6.4 Test JUnit cho AC-L*.

## 7. Frontend Workspace (plan §9 — DA-998..DA-1002, DA-1256..1258)
- [x] 7.1 Service/API client + types + hooks (`useMailTemplates`, `useMailBatches`, `useMailQuota`).
- [x] 7.2 Trang list `/workspaces/:id/mail-templates` (tìm kiếm, phân trang, chip "Hệ thống", loading/empty/error).
- [x] 7.3 Form tạo/sửa với TipTap (chèn biến, ảnh), đính kèm, "Dùng mẫu hệ thống"; giữ dữ liệu khi lỗi.
- [x] 7.4 Modal Gửi: chọn template, dán/upload CSV (parse BOM/quote, map cột), biến tự phát hiện, bật/tắt đính kèm, preview, gửi thử, hẹn giờ, quota; chặn bấm đúp.
- [x] 7.5 Trang lô + chi tiết người nhận + hủy lịch.
- [x] 7.6 Trang unsubscribe công khai (vi/en).
- [x] 7.7 Route, `ROUTE_ACCESS`, mục sidebar.
- [x] 7.8 Vitest cho parser biến/CSV/validate form; Playwright E2E theo test.md.

## 8. Điểm vào Client và Admin (plan §6.6, §6.7 — DA-1259)
- [x] 8.1 Nút "Gửi email" trên trang Client, mở modal với người nhận và `clientName` điền sẵn.
- [x] 8.2 Admin API `/api/v1/admin/mail-templates` (quyền hệ thống ADMIN, audit như các Admin controller).
- [x] 8.3 Trang Admin "Mẫu email hệ thống" (CRUD, TipTap).
- [x] 8.4 Seed 4 mẫu hệ thống (migration/seeder idempotent).
- [x] 8.5 Nút "Chọn mẫu" trong form Broadcast 3.10.1 (chỉ sao chép subject/body); không sửa worker 3.10.1.
- [x] 8.6 Test JUnit + Playwright cho AC-M*.

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
- [ ] 11.4 Commit theo convention; PR vào `develop` với tiêu đề `[DA-xxx] ...`, Squash and merge.
- [ ] 11.5 Chuyển Jira các task sang In review; sau review → Done.
- [ ] 11.6 Kiểm tra migration đã áp dụng trên môi trường staging trước khi deploy (Postgres + Mongo + seed).

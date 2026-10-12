# Test — 3-10-1-push-notification

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 4 của [plan kỹ thuật](../plan.md).

- [x] Audience tại lúc gửi: người nhận lấy khi worker bắt đầu gửi; PENDING_VERIFICATION, DEACTIVATED và gói khác bị loại.
- [x] cancel/send race: sửa/hủy khóa dòng `FOR UPDATE`, worker `FOR UPDATE SKIP LOCKED`; hủy sau khi SENDING → 409. Chưa chạy test đa luồng thật.
- [x] retry không gửi lại delivered: mỗi người nhận một dòng outbox, `event_key` unique; outbox chỉ lấy dòng chưa gửi/chưa bỏ cuộc; bỏ cuộc sau 5 lần SMTP lỗi.
- [x] zero recipients: SENT với recipientCount=0.
- [x] Validation: tiêu đề 5–200/nội dung 10–5.000 sau trim (MSG03), lịch quá khứ (MSG45), BY_ROLE chỉ ADMIN/USER, BY_PLAN theo catalog.
- [x] VI/EN; light/dark kiểm bằng ảnh màn hình.

- [x] Chưa đăng nhập 401; USER gọi Admin 403; ADMIN hợp lệ mới được thao tác (`AdminSecurityTest`).
- [x] Lỗi server không báo thành công, form giữ nguyên; nút bị khóa khi đang gửi request.
- [x] Response/audit không có passwordHash/otpCode/totpSecret; audit lưu trạng thái, đối tượng, lịch và số người nhận.

## Kết quả

Bằng chứng chung (2026-10-04):
- `AdminFinanceDatabaseTest` (PostgreSQL 17, DB `brandhub_admin_20261001_test`, clock cố định 2030 để không đụng dữ liệu khác): 4/4 pass. `AdminReportPeriodTest` 3/3, `AdminSecurityTest` 11/11 pass.
- Playwright `tests/e2e/admin/finance.spec.ts` 5/5 pass (API mock); toàn bộ `tests/e2e/admin/{overview,accounts,finance}` 22/22.
- `npx tsc`, ESLint các file đổi và `npm run build` pass.
- Smoke thật qua Gateway với dữ liệu `seed-admin-demo`: xem doanh thu, tải PDF tháng 9 (26 trang), kỳ rỗng báo MSG122, broadcast BY_PLAN=PRO 160 người nhận → SENT.
- Migration `2026-10-04-admin-notifications-reports.sql`: chạy 2 lần trên DB test, backup `.tmp/brandhub-before-notifications-20261004.dump`, chạy 2 lần trên DB dev, 0 lỗi.

Giới hạn còn lại:
- Chỉ kênh EMAIL; in-app/FCM ngoài phạm vi giai đoạn (BR-57).
- Dev dùng SMTP Gmail thật: domain `demo.brandhub.dev` bị chặn (`admin.mail.suppressed-domain`) và ghi `SUPPRESSED_DEMO_DOMAIN`, nên smoke chưa gửi email thật tới hộp thư nào.
- Worker chạy mỗi 10 giây, outbox giao tối đa 100 email/phút (`admin.account.email-batch`); giới hạn gửi/ngày của Gmail chưa được xử lý.

## In-app (bổ sung 2026-10-04)

- [x] Mỗi người nhận lúc gửi có đúng một dòng hộp thư (`uq_user_notification`), cùng snapshot với email.
- [x] `/api/v1/notifications/me` chỉ trả và chỉ cho đánh dấu dòng của chính người gọi (người khác → 404).
- [x] Chuông của tài khoản client hiển thị thông báo hệ thống thật cùng thông báo workspace mẫu; bấm vào đánh dấu đã đọc; link ngoài mở tab mới.
- [x] Dev allowlist: người nhận ngoài `ADMIN_MAIL_ALLOWED_RECIPIENTS` → `DEV_RECIPIENT_BLOCKED`, không gọi SMTP.
- Bằng chứng: `AdminFinanceDatabaseTest` 5/5 (gồm hộp thư và allowlist), `tests/e2e/notifications/system-inbox.spec.ts` pass; smoke thật: Admin gửi "Tất cả người dùng" (1.115 người), tài khoản Dev Client thấy thông báo trong chuông; 5 địa chỉ domain thật bị chặn, 0 email ra SMTP.
- Migration `2026-10-04-user-notifications.sql`: DB test 2 lần, backup `.tmp/brandhub-before-user-notifications-20261004.dump`, DB dev 2 lần.

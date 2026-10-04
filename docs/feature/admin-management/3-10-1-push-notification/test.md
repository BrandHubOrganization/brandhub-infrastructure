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

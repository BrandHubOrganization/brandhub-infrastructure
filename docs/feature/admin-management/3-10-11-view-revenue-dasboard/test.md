# Test — 3-10-11-view-revenue-dasboard

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 5 của [plan kỹ thuật](../plan.md).

- [ ] Annual 1200000 → MRR 100000: **chưa áp dụng được**, catalog hiện chỉ có `price_monthly`, không có chu kỳ năm.
- [x] ARR = MRR × 12.
- [ ] discount: **chưa áp dụng được**, schema thuê bao chưa có giảm giá.
- [x] AI Credit không vào MRR; chỉ vào tiền thu.
- [ ] partial refund: **chưa áp dụng được**, `transactions` chỉ có trạng thái REFUNDED toàn phần; ngày hoàn lấy `updated_at`.
- [x] UTC/VN: 00:30 ngày 01/01 giờ VN thuộc tháng 1 theo VN, tháng 12 theo UTC.
- [x] no payment no revenue: PENDING/FAILED không tính; MSG122 khi kỳ không có giao dịch.
- [x] Tách tiền tệ: USD không cộng vào VND.
- [x] MRR chỉ tính thuê bao ACTIVE có kỳ hiện tại phủ thời điểm thống kê; CANCELLED/hết kỳ bị loại.
- [x] VI/EN và light/dark; 390px không tràn ngang.

- [x] Chưa đăng nhập 401; USER gọi Admin 403; ADMIN hợp lệ mới được xem (`AdminSecurityTest`).
- [x] Mỗi lần xem ghi audit VIEW với kỳ, múi giờ, gói (BR-16).
- [x] Response không có thông tin bí mật; chỉ tên/email khách hàng và mã PayOS.

## Kết quả

Bằng chứng chung (2026-10-04):
- `AdminFinanceDatabaseTest` (PostgreSQL 17, DB `brandhub_admin_20261001_test`, clock cố định 2030 để không đụng dữ liệu khác): 4/4 pass. `AdminReportPeriodTest` 3/3, `AdminSecurityTest` 11/11 pass.
- Playwright `tests/e2e/admin/finance.spec.ts` 5/5 pass (API mock); toàn bộ `tests/e2e/admin/{overview,accounts,finance}` 22/22.
- `npx tsc`, ESLint các file đổi và `npm run build` pass.
- Smoke thật qua Gateway với dữ liệu `seed-admin-demo`: xem doanh thu, tải PDF tháng 9 (26 trang), kỳ rỗng báo MSG122, broadcast BY_PLAN=PRO 160 người nhận → SENT.
- Migration `2026-10-04-admin-notifications-reports.sql`: chạy 2 lần trên DB test, backup `.tmp/brandhub-before-notifications-20261004.dump`, chạy 2 lần trên DB dev, 0 lỗi.

Giới hạn còn lại: ba mục chưa áp dụng ở trên cần billing bổ sung chu kỳ năm, giảm giá và sự kiện hoàn tiền (webhook PayOS). Khi có, chỉ cần sửa truy vấn trong `AdminRevenueService`.

# Test — 3-10-12-export-report-file-pdf

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 6 của [plan kỹ thuật](../plan.md).

- [x] No data MSG122: không tạo file, không thêm dòng export.
- [x] link 24h: `expiresAt` = lúc tạo + 24 giờ; job xóa nội dung file khi hết hạn, metadata giữ làm audit; tải sau hạn → 410.
- [x] ADMIN download: tải cần cả quyền ADMIN hiện tại và token; sai token → 404; USER → 403.
- [x] parity với dashboard: báo cáo doanh thu dùng chung `AdminRevenueService` với màn Doanh thu.
- [x] A4/Vietnamese/overflow: font Liberation Sans nhúng; trích văn bản PDF ra đúng chữ có dấu; bảng tự xuống dòng và lặp header khi sang trang.
- [x] VI/EN và light/dark cho modal/trang xuất.
- [ ] Báo cáo moderation: chờ FR 3.10.4.

- [x] Chưa đăng nhập 401; USER gọi Admin 403 (`AdminSecurityTest`).
- [x] Lỗi server không báo thành công; nút tải bị khóa khi đang tạo.
- [x] PDF không chứa passwordHash/otpCode/totpSecret; audit EXPORT lưu loại, kỳ, múi giờ, asOf, số dòng, tên file, hạn tải.

## Kết quả

Bằng chứng chung (2026-10-04):
- `AdminFinanceDatabaseTest` (PostgreSQL 17, DB `brandhub_admin_20261001_test`, clock cố định 2030 để không đụng dữ liệu khác): 4/4 pass. `AdminReportPeriodTest` 3/3, `AdminSecurityTest` 11/11 pass.
- Playwright `tests/e2e/admin/finance.spec.ts` 5/5 pass (API mock); toàn bộ `tests/e2e/admin/{overview,accounts,finance}` 22/22.
- `npx tsc`, ESLint các file đổi và `npm run build` pass.
- Smoke thật qua Gateway với dữ liệu `seed-admin-demo`: xem doanh thu, tải PDF tháng 9 (26 trang), kỳ rỗng báo MSG122, broadcast BY_PLAN=PRO 160 người nhận → SENT.
- Migration `2026-10-04-admin-notifications-reports.sql`: chạy 2 lần trên DB test, backup `.tmp/brandhub-before-notifications-20261004.dump`, chạy 2 lần trên DB dev, 0 lỗi.

Giới hạn còn lại: nhãn PDF song ngữ Việt/Anh cố định, chưa theo ngôn ngữ người xuất; tối đa 5.000 dòng chi tiết mỗi bảng.

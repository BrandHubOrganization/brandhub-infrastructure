# Test Specification — FR 3.10.13: View Revenue Dashboard

> Note: This specification maps to official **FR 3.10.13 — View Revenue Dashboard** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-13-view-revenue-dashboard/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.13` |
| **Function Name** | View Revenue Dashboard |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminRevenueService.overview()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminRevenueServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Aggregate verified SePay receipts into gross/subscription/credit totals, MRR/ARR by plan, daily receipts, and recent transactions |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan=null, transactionLimit=20` | 200 OK - AdminRevenueResponse with mrr, arr (mrr*12), activePaidSubscribers, totals, byPlan, daily, transactions | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan='PLUS', transactionLimit=50` | 200 OK - Only VERIFIED SePay payments on FULFILLED orders with matching amount/currency included | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-01-01, 2026-10-30, 'UTC')`, `planAndLimit` = `plan=null, transactionLimit=20` | 200 OK - CurrencyTotal separates gross revenue into SUBSCRIPTION and CREDIT_TOPUP amounts | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-01-01, 2026-10-30, 'UTC')`, `planAndLimit` = `plan='PLUS', transactionLimit=50` | 200 OK - PlanRevenue computes recurring subscribers and MRR from active READY subscriptions | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Active agency_subscriptions and billing_plan_versions exist for MRR/ARR calculation | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan='   ' (blank -> null), transactionLimit=10` | 200 OK - Plan filter='PLUS' scopes receipts and recurring MRR to PLUS plan | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Active agency_subscriptions and billing_plan_versions exist for MRR/ARR calculation | `period` = `AdminReportPeriod(2026-01-01, 2026-10-30, 'UTC')`, `planAndLimit` = `plan='   ' (blank -> null), transactionLimit=10` | 200 OK - Blank plan parameter normalized to null (aggregates across all plans) | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan=null, transactionLimit=20` | 200 OK - daily() returns zero-filled DailyReceipts series for every date in [from..to] | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan='PLUS', transactionLimit=50` | 200 OK - transactions() returns recent verified receipts ordered by paid_at desc | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Date range has 0 verified receipts or transactionLimit is clamped to [1..100] | `period` = `single-day period (from == to)`, `planAndLimit` = `transactionLimit=0 or 500 (clamped to 1..100)` | 200 OK - Period with 0 receipts returns mrr=0, arr=0, totals=[], and zeroed daily series | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Date range has 0 verified receipts or transactionLimit is clamped to [1..100] | `period` = `single-day period (from == to)`, `planAndLimit` = `transactionLimit=0 or 500 (clamped to 1..100)` | 200 OK - Single-day period (from == to) returns 1 DailyReceipts entry | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan='   ' (blank -> null), transactionLimit=10` | 200 OK - transactionLimit=0 clamped to 1 and transactionLimit=500 clamped to 100 | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Plan filter code does not exist in billing_plan_versions or period dates are invalid | `period` = `period with 0 receipts`, `planAndLimit` = `plan=null, transactionLimit=20` | INVALID_REQUEST - 400 Start date is after end date or period exceeds allowed range | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Plan filter code does not exist in billing_plan_versions or period dates are invalid | `period` = `invalid period (from > to)`, `planAndLimit` = `plan=null, transactionLimit=20` | INVALID_REQUEST - 400 Unknown subscription plan code filter (not in billing_plan_versions) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller does not have ADMIN system role | `period` = `AdminReportPeriod(2026-10-01, 2026-10-30, 'Asia/Ho_Chi_Minh')`, `planAndLimit` = `plan=null, transactionLimit=20` | FORBIDDEN - 403 Caller does not have ADMIN system role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `period with 0 receipts`, `planAndLimit` = `unknown plan='ENTERPRISE_X'` | INVALID_REQUEST - 400 Unsupported timezone identifier in AdminReportPeriod | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Database has FULFILLED SePay billing_orders with VERIFIED billing_payments in period | `period` = `invalid period (from > to)`, `planAndLimit` = `non-ADMIN caller` | UNAUTHORIZED - 401 Authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

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
- [x] Response không có thông tin bí mật; chỉ tên/email khách hàng và mã SePay.

## Kết quả

Bằng chứng chung (2026-10-04):
- `AdminFinanceDatabaseTest` (PostgreSQL 17, DB `brandhub_admin_20261001_test`, clock cố định 2030 để không đụng dữ liệu khác): 4/4 pass. `AdminReportPeriodTest` 3/3, `AdminSecurityTest` 11/11 pass.
- Playwright `tests/e2e/admin/finance.spec.ts` 5/5 pass (API mock); toàn bộ `tests/e2e/admin/{overview,accounts,finance}` 22/22.
- `npx tsc`, ESLint các file đổi và `npm run build` pass.
- Smoke thật qua Gateway với dữ liệu `seed-admin-demo`: xem doanh thu, tải PDF tháng 9 (26 trang), kỳ rỗng báo MSG122, broadcast BY_PLAN=PRO 160 người nhận → SENT.
- Migration `2026-10-04-admin-notifications-reports.sql`: chạy 2 lần trên DB test, backup `.tmp/brandhub-before-notifications-20261004.dump`, chạy 2 lần trên DB dev, 0 lỗi.

Giới hạn còn lại: ba mục chưa áp dụng ở trên cần billing bổ sung chu kỳ năm, giảm giá và sự kiện hoàn tiền (webhook SePay). Khi có, chỉ cần sửa truy vấn trong `AdminRevenueService`.

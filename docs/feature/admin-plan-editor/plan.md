# Admin Plan Editor — plan

## DB (`migrations/2026-11-22-admin-plan-editor.sql`, nối vào `init-postgres-v2.sql`)
`billing_plan_change_log(id, plan_code, plan_version_id → billing_plan_versions, action NEW_VERSION|ENABLE_SALE|
DISABLE_SALE, actor_user_id → users, reason 3..500, created_at)` + index `(plan_code, created_at desc)`.
Không đổi trigger bất biến: sửa = INSERT phiên bản mới; bật/tắt bán = UPDATE `is_sellable` (trigger cho phép).

## Business service
- `AdminPlanService` (mới): list / updatePlan / setSellable / history. updatePlan khóa bản mới nhất
  `FOR UPDATE`, so `expectedVersion`, validate AC3, INSERT bản mới (copy `features`, ghi đè
  `newsletter_email_quota`), INSERT `billing_plan_cycle_prices`, `is_sellable=false` cho bản cũ, ghi log.
- `AdminPlanController` `/api/v1/admin/billing/plans` (requireAdmin).
- `PublicBillingPlanController` `/api/v1/public/billing/plans?line=` → `BillingPlanCatalogService.listLine`.
- `SecurityConfig`: permitAll GET `/api/v1/public/billing/plans`.
- `ErrorCode`: `PLAN_VERSION_CONFLICT`, `PLAN_UNCHANGED`, `PLAN_SALE_LOCKED`.
- Bỏ số cứng: `StorageQuotaService.effectiveQuota` lấy dung lượng gói miễn phí từ phiên bản của subscription;
  `NewsletterQuotaService` lấy `features.newsletter_email_quota` của phiên bản đang dùng (fallback cấu hình cũ).

## Gateway
Route `billing-plans-public` (GET, RateLimit publicIp) + thêm path vào allowlist của `RateLimitGatewayFilterFactory`.

## Web
- `services/adminPlanService.ts`, `pages/admin/components/AdminPlansPanel.tsx` (+ dialog sửa, dialog lịch sử).
- `pages/admin/index.tsx` view `plans`; `adminNavConfig.ts` mục `plans`.
- `components/landing/Pricing.tsx` đọc API public; dòng tính năng sinh từ số liệu.
- i18n: `vi/admin.json`, `en/admin.json` (`admin.plans.*`, `admin.navigation.plans`),
  `vi/landing.json`, `en/landing.json` (`landing.pricing.*`).

## Rủi ro
Landing phụ thuộc backend → hiển thị skeleton / thông báo lỗi khi API lỗi. Prod phải chạy migration trước khi
deploy backend.

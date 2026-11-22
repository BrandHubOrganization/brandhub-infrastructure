# Studio Plans — Task

## DB
- [x] T1. Viết `migrations/2026-11-22-studio-plans.sql` (CHECK code, seed 3 gói, cycle prices, chuyển Personal BASIC→STUDIO_FREE, registry) — plan §2
- [x] T2. Cập nhật `init-postgres-v2.sql` (CHECK + seed STUDIO_*)
- [x] T3. Chạy migration 2 lần trên DB local, xác nhận lần 2 không đổi gì (throwaway docker postgres:17 — local Windows service postgresql-x64-18 stopped, needs admin)

## Backend
- [x] T4. `PlanLine` (freeCode/line/rank) + unit test
- [x] T5. `AgencyServiceImpl.createAgency` + `SubscriptionCreditSeeder` seed gói miễn phí theo company_type
- [x] T6. SQL "gói hiệu lực" theo company_type ở `AgencyPlanEntitlementService`, `AgencyServiceImpl.loadPlanCodes`, `NewsletterQuotaService`, `AgencyBillingService.getSubscription`
- [x] T7. `AgencyPlanEntitlementService`: defaults STUDIO_*, resolveFree, clients=0 hợp lệ, đếm slot gồm workspace Personal
- [x] T8. `WorkspaceServiceImpl`: slot check cho create/restore personal + PERSONAL→AGENCY
- [x] T9. `AgencySubscriptionLifecycle`: hết hạn về gói miễn phí theo dòng + thông báo đúng dòng
- [x] T10. `BillingPlanCatalogService` + `BillingPlanController` (`agencyId`, productLine, checkoutEnabled, rank order) + `BillingPlanResponse`
- [x] T11. `AgencyBillingService.createSubscriptionOrder`: planCode, kiểm dòng, kiểm hạng, proration, hash/snapshot
- [x] T12. `AgencyBillingService.fulfill`: kiểm hạng, upgrade giữa kỳ đóng kỳ cũ tại paidAt, outbox planCode thật
- [x] T13. `quoteUpgrade` + endpoint `GET /agencies/{id}/upgrade-quote`
- [x] T14. `StorageQuotaService`, `AdminRevenueService` nhận STUDIO_*
- [x] T15. Test service: createAgency Personal, entitlement, lifecycle expiry, order cross-line/rank/proration, fulfill upgrade — billing: `StudioBillingOrderRulesTest` (always) + `StudioBillingPostgresTest` (opt-in `BRANDHUB_BILLING_ISOLATED_TEST`, 13/13 pass on throwaway postgres:17)
- [x] T16. `mvn clean test` xanh

## Web
- [x] T17. `agencyBillingService.ts`: getPlans(agencyId), getUpgradeQuote, type productLine
- [x] T18. `plans.tsx` + `CatalogPlanCard` hiển thị dòng Studio, mua đúng planCode, hiện proration
- [x] T19. `checkout.tsx` / `OrderSummaryCard` dòng trừ proration
- [x] T20. Nhãn gói Studio ở `planPrice.ts`, `OrgSwitcherDropdown`, `AgencyHubCard`
- [x] T21. Cập nhật vi.json + en.json (`subscription.studio.*`) key-parallel
- [x] T22. Kiểm tra light/dark mode trang Gói + checkout — code uses tokens only; visual check pending
- [x] T23. `npx tsc --noEmit` xanh

## Enterprise & lỗi luồng Personal
- [x] T26. Migration: ENTERPRISE version mới 500 GB + copy cycle prices; `defaultsForCode` ENTERPRISE 500 GB (AC12) — migration (ENTERPRISE vN+1 500 GB + cycle prices) + `defaultsForCode` 500 GB
- [x] T27. Form tạo không gian khoá PERSONAL trong công ty Personal (AC13a)
- [x] T28. Trang Công việc Personal không tự gắn chiến dịch, ẩn banner nghiệm thu (AC13b)
- [x] T29. Ẩn khối chuyển chế độ ở cài đặt không gian công ty Personal (AC13c)

## Kết thúc
- [x] T24. Chạy test.md, tick pass/fail — 2026-11-22 local stack (docker postgres:17/mongo/redis/rabbit/mailpit, business :18081, web :3005); kết quả ở cột Kết quả test.md
- [x] T25. Cập nhật memory + ghi chú prod: thứ tự 2 migration 2026-11-22

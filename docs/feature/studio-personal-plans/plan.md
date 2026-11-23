# Studio Plans — Plan kỹ thuật

## 1. Hướng tiếp cận (ít thay đổi nhất)

Công ty Personal **đã là một dòng `agencies`**, nên gói Studio đi qua đúng bộ máy billing Agency hiện có
(`agency_subscriptions`, `billing_orders`, `agency_subscription_periods`, `credit_grants`, SePay webhook,
trả trước 3/6/12 tháng, cấp credit theo tháng). Không tạo bảng mới.

- Mã gói mới `STUDIO_FREE | STUDIO_PLUS | STUDIO_PRO`. Cột sinh `billing_scope` tự ra `'AGENCY'`
  (chỉ `PERSONAL` mới là `'USER'`), nên mọi FK/CHECK `plan_billing_scope='AGENCY'` giữ nguyên.
- "Dòng gói" suy ra từ tiền tố mã: `STUDIO_*` = Studio, còn lại = Agency.
- Thay mọi chỗ gắn cứng `'BASIC'` là "gói miễn phí" bằng **gói miễn phí theo `company_type`**
  (`PERSONAL → STUDIO_FREE`, `AGENCY → BASIC`).
- Thay mọi chỗ gắn cứng `'PLUS'` là "gói bán được duy nhất" bằng **`planCode` từ request** + bảng thứ hạng.

Một helper Java dùng chung `PlanLine`:

```java
static String freeCode(String companyType)  // "PERSONAL" -> STUDIO_FREE, else BASIC
static String line(String planCode)         // STUDIO_* -> STUDIO, else AGENCY
static int rank(String planCode)            // BASIC/STUDIO_FREE 0, PLUS/STUDIO_PLUS 1, ENTERPRISE/STUDIO_PRO 2
```

SQL "gói hiệu lực" hiện có (`CASE WHEN expired THEN 'BASIC' ELSE p.code END`) đổi thành
`CASE WHEN expired THEN (CASE WHEN a.company_type='PERSONAL' THEN 'STUDIO_FREE' ELSE 'BASIC' END) ELSE p.code END`
(join `agencies a`).

## 2. DB — `brandhub-infrastructure/docs/database/migrations/2026-11-22-studio-plans.sql`

Idempotent, `psql -X -v ON_ERROR_STOP=1`, chạy sau `2026-11-22-agency-company-type.sql`.

1. `billing_plan_versions_code_check` → thêm `STUDIO_FREE, STUDIO_PLUS, STUDIO_PRO`.
2. Insert 3 version 1 (ON CONFLICT DO NOTHING):

| code | price_monthly | ws | members | clients | storage bytes | credits | jobs | version | trash | activity | sellable |
|---|---|---|---|---|---|---|---|---|---|---|---|
| STUDIO_FREE | 0 | 1 | 1 | 0 | 2147483648 | 100 | 1 | 7 | 7 | 30 | true |
| STUDIO_PLUS | 99000 | 3 | 1 | 0 | 5368709120 | 900 | 1 | 30 | 30 | 90 | true |
| STUDIO_PRO | 299000 | 10 | 3 | 0 | 32212254720 | 2400 | 2 | 90 | 30 | 180 | true |

   `features = '{"product_line":"STUDIO"}'`.
3. `billing_plan_cycle_prices`: Plus 3/6/12 = 279000/529000/949000; Pro = 849000/1599000/2869000.
4. Chuyển công ty Personal đang `BASIC` sang `STUDIO_FREE`
   (`UPDATE agency_subscriptions s SET plan_version_id=<STUDIO_FREE v1> FROM agencies a, billing_plan_versions p
   WHERE a.id=s.agency_id AND a.company_type='PERSONAL' AND p.id=s.plan_version_id AND p.code='BASIC'`).
5. ENTERPRISE: insert version mới copy từ version mới nhất, `storage_limit_bytes = 500000000000`
   (giá, cycle prices giữ nguyên; copy `billing_plan_cycle_prices` sang version mới; version cũ `is_sellable=false`) — AC12.
6. Ghi `brandhub_schema_migrations('20261122_studio_plans_v1')`.
6. Đồng bộ `init-postgres-v2.sql` (CHECK + seed) cho môi trường mới.

## 3. Backend (`brandhub-business-service`)

| File | Thay đổi |
|---|---|
| `service/PlanLine.java` (mới, nhỏ) | `freeCode`, `line`, `rank` + unit test |
| `service/impl/AgencyServiceImpl.java` | `createAgency`: seed gói `freeCode(companyType)` thay `BASIC`; `loadPlanCodes` dùng SQL hiệu lực mới |
| `seed/SubscriptionCreditSeeder.java` | seed theo `company_type` |
| `service/AgencySubscriptionLifecycle.java` | hết hạn → gói miễn phí theo `company_type`; nội dung thông báo theo dòng (Studio / Plus) |
| `service/AgencyPlanEntitlementService.java` | SQL hiệu lực mới; `defaultsForCode` thêm 3 STUDIO; `resolveBasicFromCatalogOrDefaults` → `resolveFree(code)`; `max_clients` = 0 hợp lệ cho STUDIO; `requireWorkspaceSlot` đếm cả workspace chế độ Personal (trừ `isPersonalDefault` của công ty Agency cũ) |
| `service/impl/WorkspaceServiceImpl.java` | bỏ điều kiện `mode != PERSONAL` khi gọi `requireWorkspaceSlot` (create + restore); `updateSettings` PERSONAL→AGENCY gọi `requireWorkspaceSlot` |
| `dto/request/CreateAgencyBillingOrderRequest.java` | `@Pattern("PLUS|STUDIO_PLUS|STUDIO_PRO")` |
| `service/AgencyBillingService.java` | `createSubscriptionOrder`: plan theo `planCode`; kiểm dòng = dòng công ty; kiểm hạng (UPGRADE: rank đích > rank hiện tại; RENEWAL: đích = hiện tại hoặc EXPIRED); proration khi hiện tại là gói trả phí cùng dòng & chưa hết hạn; payload hash + snapshot chứa `planCode`, `prorationCredit`. `fulfill`: kiểm hạng như trên; upgrade giữa kỳ đóng kỳ CURRENT tại `paidAt` và **không** đẩy `periodStart` về `lastEnd`; outbox payload dùng planCode thật. Thêm `quoteUpgrade(...)` |
| `service/BillingPlanCatalogService.java` | lọc theo dòng (`agencyId` → company_type); `checkoutEnabled` = sellable && price>0 && mã bán qua SePay (PLUS, STUDIO_PLUS, STUDIO_PRO); thứ tự theo rank; thêm `productLine` |
| `controller/BillingPlanController.java` | `@RequestParam(required=false) UUID agencyId` |
| `controller/BillingController.java` | `GET /agencies/{agencyId}/upgrade-quote` |
| `dto/response/BillingPlanResponse.java` | thêm `productLine`; mặc định newsletter/support cho STUDIO_* |
| `service/NewsletterQuotaService.java` | SQL hiệu lực mới |
| `service/material/StorageQuotaService.java` | `p.code IN ('PLUS','ENTERPRISE')` → thêm `STUDIO_PLUS, STUDIO_PRO` |
| `service/admin/AdminRevenueService.java` | thứ tự nhóm thêm STUDIO_* |

### Proration (AC6)

```
cur = kỳ CURRENT (agency_subscription_periods join billing_orders o on o.id = order_id)
paid = o.amount ; total = ends_at - starts_at ; left = max(0, ends_at - now)
credit = floor(paid * left / total / 1000) * 1000
amount = cyclePrice(target, months) - credit ; amount <= 0 -> BILLING_ORDER_CONFLICT
```
Chỉ áp dụng khi `line(current)=line(target)`, `rank(current)>=1`, subscription ACTIVE chưa hết hạn, không có kỳ FUTURE.
Hash idempotency gồm `planCode` + `planVersionId` + `action` + `months` (PLUS giữ định dạng cũ); `credit` chỉ lưu trong `product_snapshot` vì nó đổi theo thời gian — đưa vào hash thì retry cùng key vài phút sau sẽ bị conflict thay vì trả lại đúng đơn.

## 4. Web (`brandhub-web`)

| File | Thay đổi |
|---|---|
| `src/services/agencyBillingService.ts` | `getPlans(agencyId?)`, `getUpgradeQuote(agencyId, planCode, months)`, kiểu `productLine` |
| `src/pages/subscription/plans.tsx` + `hooks/*` | truyền `currentAgencyId`; dòng Studio ẩn `PlanComparisonMatrix` Agency |
| `src/pages/subscription/components/CatalogPlanCard.tsx` | tên/tagline/feature Studio qua i18n; nút mua gửi đúng `planCode`; hiện proration |
| `src/pages/subscription/checkout.tsx`, `OrderSummaryCard.tsx` | dòng "Trừ phần Plus còn lại" khi có `prorationCredit` |
| `src/lib/planPrice.ts` | nhãn gói STUDIO_* |
| `src/components/layout/sidebar/OrgSwitcherDropdown.tsx`, `src/pages/agency/components/hub/AgencyHubCard.tsx` | badge tên gói Studio |
| `src/i18n/locales/vi/subscription.json`, `src/i18n/locales/en/subscription.json` | key `subscription.studio.*` |
| `src/pages/workspace/hooks/useCreateWorkspace.ts`, `components/CreateWorkspaceForm.tsx` | AC13a: agency `companyType=PERSONAL` → khoá `workspaceMode=PERSONAL`, ẩn chọn chế độ / ClientInvitePicker / trường doanh nghiệp |
| `src/pages/tasks/index.tsx` | AC13b: Personal → `campaignId={null}` cho QuickCreate, ẩn banner chiến dịch |
| `src/pages/workspace/detail.tsx` | AC13c: ẩn khối chuyển chế độ khi công ty Personal |
| `AgencyPlanEntitlementService.defaultsForCode` | ENTERPRISE fallback storage 500 GB (AC12) |

## 5. Thứ tự build

DB migration → `PlanLine` + test → entitlement/lifecycle/createAgency → catalog API → order + proration + quote
→ web catalog/checkout → i18n → kiểm tra light/dark → test.md.

## 6. Rủi ro

- Billing đụng tiền thật: mọi thay đổi `AgencyBillingService` phải có test cho upgrade, renewal, cross-line, proration.
- `billing_guard_plan_version` cấm sửa version → giá sai phải tạo version 2, không UPDATE.
- Prod: chạy `2026-11-22-agency-company-type.sql` **trước** `2026-11-22-studio-plans.sql`.
- Web/business worktree đang có nhiều sửa đổi chưa commit của phiên khác — chỉ commit file của feature này.

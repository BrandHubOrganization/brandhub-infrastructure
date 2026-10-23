# G7 — Subscription & Billing (mobile)

> Trạng thái: DRAFT — tài liệu đặc tả, KHÔNG code. Tham chiếu `docs/mobile/mobile-app-plan.md` (bảng mục 3, dòng G7) và `docs/ba/08-subscription-billing.md`.

## 1. Mục tiêu & phạm vi

Mobile G7 cho phép user:
- Xem plan hiện tại (Basic/Pro/Enterprise), ngày hết hạn/renewal, trạng thái subscription.
- Xem danh sách plan khả dụng để so sánh (đọc, không nhất thiết mua ngay trong app — xem mục 7).
- Xem lịch sử invoice/giao dịch của Agency, xem chi tiết 1 invoice, xem trạng thái thanh toán SePay.
- Xem AI credit allowance gắn với plan: hạn mức tháng, đã dùng, còn lại (cả cấp Agency và cấp cá nhân nếu Owner có set limit).

**Lưu ý quan trọng:** hành động "mua/upgrade/downgrade plan" có rủi ro chính sách App Store khi làm trong app trên iOS (xem mục 7) — khuyến nghị của tài liệu này là KHÔNG thực hiện thanh toán thật trong app ở G7, chỉ đọc + điều hướng ra ngoài. Đây là đề xuất của người viết tài liệu, **chưa được user xác nhận**, cần chốt trước khi lên implementation plan.

## 2. FR tham chiếu

Từ `docs/ba/08-subscription-billing.md` (FR 3.9.1–3.9.7):

| FR | Tên | Role | Mobile G7 làm gì |
|---|---|---|---|
| 3.9.1 | Upgrade Plan | USER | Đọc danh sách plan, xem so sánh. Hành động "upgrade" thật → điều hướng ra web (mục 7), không build checkout trong app. |
| 3.9.2 | Downgrade Plan | OWNER | Tương tự — xem, không thao tác cancel/downgrade thật trong G7 (có thể xét lại ở giai đoạn sau nếu không đụng thanh toán). |
| 3.9.3 | Make Payment (PayOS theo doc BA, thực tế code dùng SePay) | USER | KHÔNG làm ở mobile G7 — xem mục 7 và mục 8 (có sai khác BA doc vs code, cần hỏi lại). |
| 3.9.4 | View Invoice History | OWNER | Làm đầy đủ: list + detail + trạng thái thanh toán. |
| 3.9.5 | View AI Credit Tracking | CREATOR, OWNER | Làm đầy đủ: allowance/used/remaining theo Agency và theo Creator. |
| 3.9.6 | Buy Credit | OWNER | KHÔNG làm ở G7 (đụng thanh toán thật) — chỉ xem, điều hướng ra web nếu cần mua. |
| 3.9.7 | Set Credit | OWNER | Không trong phạm vi đọc liệu có cần — đánh giá sau; nếu làm thì là ghi dữ liệu không phải tiền, rủi ro thấp, có thể đưa vào G7 nếu còn thời gian (xem mục 7). |

## 3. API cần dùng (đã đọc code, không đoán)

Business-service có **2 hệ thống plan/billing song song** đang hoạt động — cần lưu ý khi tích hợp mobile:

### 3a. Hệ cũ — `SubscriptionController` (`/api/v1/subscription`)
Model: `SubscriptionPlan` (`model/SubscriptionPlan.java`), `UserSubscription` (`model/UserSubscription.java`). Plan gắn theo **User** (không theo Agency).

- `GET /api/v1/subscription/plans` → `List<SubscriptionPlanResponse>` — field: `id, name (BASIC/PRO/ENTERPRISE), displayName, priceMonthly, maxWorkspaces, aiCreditsMonth, features (JSON string), isActive, createdAt`.
- `GET /api/v1/subscription/me` → `UserSubscriptionResponse` — field: `id, userId, planId, status (enum SubscriptionStatus, default TRIALING), currentPeriodStart, currentPeriodEnd, cancelledAt, createdAt`.
- `POST /api/v1/subscription` (body `SubscribeRequest`) → subscribe/upgrade.
- `POST /api/v1/subscription/cancel` → downgrade/hủy.

### 3b. Hệ mới — Billing Plan Catalog + Agency Billing (`/api/v1/billing/...`)
Model: `BillingPlanResponse` — plan versioned, có `checkoutEnabled`, `isSellable`, gắn theo **billingScope** (có vẻ theo Agency, field `monthlyAiCredits` thay vì `aiCreditsMonth`).

- `GET /api/v1/billing/plans` (`BillingPlanController`) → `List<BillingPlanResponse>` — field: `id, code, version, displayName, billingScope, priceMonthly, currency, maxActiveWorkspaces, maxInternalMembers, maxClients, storageLimitBytes, monthlyAiCredits, maxConcurrentAiJobs, versionRetentionDays, trashRetentionDays, activityRetentionDays, maxPersonalSpaces, isSellable, checkoutEnabled`.
- `GET /api/v1/billing/agencies/{agencyId}/subscription` (`BillingController`) → `AgencySubscriptionResponse` — subscription hiện tại của Agency.
- `POST /api/v1/billing/agencies/{agencyId}/orders` (header `Idempotency-Key` bắt buộc, body `action=UPGRADE` mặc định) → tạo order SePay, trả `AgencyBillingOrderResponse` (có `qrUrl`, `status PENDING_PAYMENT`, xem mục 6).
- `GET /api/v1/billing/agencies/{agencyId}/orders/{orderId}` → trạng thái 1 order.
- `POST /api/v1/billing/webhooks/sepay` — webhook SePay xác nhận thanh toán, KHÔNG liên quan mobile client trực tiếp.

### 3c. Invoice history (`InvoiceHistoryController`, `/api/v1/billing/agencies/{agencyId}/invoices`)
- `GET /invoices?cursor&limit&status&kind&from&to` → `InvoiceHistoryResponse { items: List<Item>, nextCursor }`. `Item` field: `id, agencyId, agencyName, payerUserId, kind, status, planCode, amount, currency, createdAt, paidAt, fulfilledAt, expiresAt, periodStart, periodEnd, transferContent, receiptAvailable`.
- `GET /invoices/{orderId}` → `Detail { order: Item, productSnapshot, payments: List<Payment>, reviewReasons }`. `Payment` field: `id, amount, currency, providerReference, verificationState, paidAt`.
- `GET /invoices/{orderId}/sepay-transactions?page` → `SePayHistoryResponse` — tra soát transaction SePay thủ công (admin-ish; mobile có thể không cần).
- `GET /invoices/{orderId}/receipt` → file `.txt` receipt (response `ResponseEntity<byte[]>`, content-type `text/plain`, header `Content-Disposition attachment`) — mobile cần xử lý tải file, không phải JSON.

### 3d. Legacy billing/transactions + AI credit (`BillingController`, `/api/v1/billing`)
- `GET /api/v1/billing/transactions` → `List<TransactionResponse>` (model `Transaction.java`) — route cũ cho FR 3.9.4, có thể trùng lặp với 3c; cần hỏi BE đang dùng route nào là chính thức.
- `GET /api/v1/billing/transactions/{transactionId}` → chi tiết 1 transaction.
- `POST /api/v1/billing/credits/buy` (body `BuyCreditRequest`) → FR 3.9.6, KHÔNG dùng ở mobile G7.
- `GET /api/v1/billing/credits/{agencyId}/usage?month=YYYY-MM` → `CreditUsageResponse` — FR 3.9.5, dùng được ở G7 (đọc only).
- `PUT /api/v1/billing/credits/{agencyId}/limits` (body `SetCreditLimitRequest`) → FR 3.9.7, Owner-only, cân nhắc đưa vào G7 nếu còn thời gian (không phải thanh toán thật, chỉ set số nguyên).
- `POST /api/v1/billing/payments` — "Legacy user-scoped payment stub" theo comment trong code, KHÔNG dùng.

**Khuyến nghị cho mobile:** ưu tiên hệ 3b (`/api/v1/billing/...` Agency-scoped) vì có `checkoutEnabled`/`isSellable` rõ ràng và khớp model 3 tầng Agency trong BA doc; hệ 3a (`/api/v1/subscription`) là User-scoped, có thể là code cũ hơn chưa dọn — **cần hỏi BE team xác nhận route nào là nguồn sự thật hiện tại** trước khi code thật (câu hỏi mở, mục 8).

## 4. Luồng màn hình

1. **Current Plan screen** — gọi `GET /billing/agencies/{agencyId}/subscription` (hoặc `/subscription/me` nếu BE xác nhận dùng hệ cũ): hiển thị plan name, trạng thái, `currentPeriodEnd` (ngày renew), và block AI credit allowance (gọi thêm `GET /billing/credits/{agencyId}/usage?month=<tháng hiện tại>` — hiển thị used/remaining theo `AiCreditService.Balance`: `allowance, used, remaining, creatorLimit, creatorUsed`).
2. **Plan comparison list** — gọi `GET /billing/plans`, hiển thị card mỗi plan (`displayName, priceMonthly, monthlyAiCredits, maxActiveWorkspaces, maxInternalMembers, isSellable, checkoutEnabled`). Nút hành động "Nâng cấp" trên mỗi card **không mở checkout trong app** — mở deep link ra trình duyệt ngoài tới trang `/subscription/checkout?tier=...` của web (xem mục 7).
3. **Upgrade confirmation** — KHÔNG có trong G7 mobile (xảy ra trên web sau khi mở deep link).
4. **Invoice history list** — gọi `GET /invoices` (paginate bằng `cursor`/`nextCursor`), hiển thị `planCode, amount, currency, status, createdAt, paidAt`. Có filter `status`/`kind`/khoảng ngày nếu UI cho phép.
5. **Invoice detail** — gọi `GET /invoices/{orderId}`, hiển thị `productSnapshot`, danh sách `payments` (verificationState từng payment), `reviewReasons` nếu có. Nút "Tải receipt" gọi `GET /invoices/{orderId}/receipt` — xử lý file `.txt` tải xuống (dùng file system API của Expo, không parse JSON).

## 5. State & cache — TanStack Query keys

- `['billing', 'agency', agencyId, 'subscription']` — current plan, staleTime ngắn (vài phút) vì có thể đổi qua webhook SePay.
- `['billing', 'plans']` — catalog plan, cache lâu hơn (ít đổi), có thể để `staleTime: 1 hour`.
- `['billing', 'agency', agencyId, 'credits', month]` — AI credit usage theo tháng, key theo `month` để tránh lẫn dữ liệu tháng cũ.
- `['billing', 'agency', agencyId, 'invoices', filters]` — invoice list, dùng `useInfiniteQuery` với `cursor`/`nextCursor` (không dùng offset).
- `['billing', 'agency', agencyId, 'invoices', orderId]` — invoice detail, invalidate khi list refetch nếu cùng `orderId`.
- Không cache receipt file (luôn fetch mới khi user bấm tải, vì nội dung có thể đổi nếu trạng thái order thay đổi).

## 6. Business rules đặc biệt (từ `docs/ba/08-subscription-billing.md`)

- Plan (Basic/Pro/Enterprise) gắn với **User/Owner**, ảnh hưởng toàn bộ Agency của Owner đó — không mua riêng theo Workspace (mô hình 3 tầng: User → Agency → Workspace).
- AI credit có **2 lớp**: hạn mức Agency (từ plan) và hạn mức Creator (do Owner set qua `Set Credit`, FR 3.9.7) — `AiCreditService.Balance.remaining()` = `min(agency_remaining, creator_limit - creator_used)` nếu Owner có set limit cho Creator đó, ngược lại chỉ bị chặn bởi agency remainder.
- Hạn mức Creator là **hard limit** (CONFIRMED 2026-09-17): hết credit → chặn hẳn thao tác AI tiếp theo, không phải soft warning, tới khi Owner cấp thêm hoặc sang kỳ mới.
- Mặc định hệ thống fallback: 10 credit/thành viên/kỳ nếu Owner chưa set riêng.
- Credit Plan (theo allowance tháng) không rollover sang kỳ sau; dùng credit Plan trước, credit mua thêm (Buy Credit) sau. Credit mua thêm KHÔNG hết hạn, vẫn dùng được khi subscription hết hạn/hủy.
- Subscription hết hạn vẫn reset hạn mức hàng tháng theo anchor chu kỳ cũ (không dừng reset khi hủy).
- Thanh toán qua **SePay** (không phải PayOS như `08-subscription-billing.md` mô tả ở FR 3.9.3 — đây là điểm sai khác giữa BA doc và code thực tế, xem mục 8): flow là tạo order → BE trả `qrUrl` (ảnh QR chuyển khoản ngân hàng) → hiển thị QR trong `AgencyPaymentPanel.tsx` (web) → user chuyển khoản thật qua app ngân hàng của họ → SePay gọi webhook `POST /billing/webhooks/sepay` xác nhận → order chuyển trạng thái `PAID`/fulfilled. Đây không phải redirect sang trang thanh toán của provider, mà là hiển thị ảnh QR tĩnh ngay trong UI, chờ webhook.
- `BillingController.createPayment` (`/billing/payments`) được chú thích trong code là **"Legacy user-scoped payment stub"** — không phải luồng chính thức hiện tại.

## 7. Việc KHÔNG làm ở G7 (và khuyến nghị — đây là đề xuất, CHƯA được user xác nhận)

**Không build luồng mua/upgrade/thanh toán thật trong app mobile ở giai đoạn này.** Lý do:

- Flow thanh toán thật hiện tại (SePay QR + chuyển khoản ngân hàng thật, xem mục 6) là thanh toán tiền thật ngoài hệ sinh thái Apple/Google. Apple App Store Review Guidelines (mục 3.1.1) yêu cầu nội dung số bán trong app (gồm subscription) phải dùng In-App Purchase (IAP) của Apple nếu app được publish công khai trên App Store — route thanh toán ngân hàng/QR riêng hiển thị trong app (dù là ảnh tĩnh, không phải WebView) vẫn được xem là "thanh toán ngoài IAP cho nội dung số", vi phạm chính sách nếu app public.
- **Vì mobile-app-plan.md đã chốt: đây là bản demo nội bộ qua Expo Go / TestFlight / ad-hoc, KHÔNG public release App Store** — rủi ro chính sách này KHÔNG chặn demo capstone. Nó chỉ trở thành vấn đề thật nếu dự án sau này publish công khai lên App Store.
- Dù vậy, để tránh phải viết lại toàn bộ UI khi/nếu app public hoá sau capstone, khuyến nghị (đề xuất riêng, cần confirm): mobile G7 chỉ làm **READ-ONLY** — xem plan, xem invoice, xem credit. Hành động "Nâng cấp/Mua thêm credit" chỉ có nút **"Mở trên web"** dùng `Linking.openURL()` của Expo để mở trình duyệt ngoài (Safari/Chrome) tới trang checkout web (`/subscription/checkout?tier=...`), KHÔNG mở trong WebView nhúng trong app. Browser ngoài hệ app → không tính là "mua trong app" theo cách hiểu phổ biến của Apple review, giữ app sẵn sàng public hoá sau này mà không phải sửa lại kiến trúc thanh toán.
- Không làm: `POST /subscription`, `POST /billing/agencies/{agencyId}/orders`, `POST /billing/credits/buy`, `POST /subscription/cancel`, hiển thị QR SePay trong app.
- Có thể xét làm nếu còn thời gian (rủi ro thấp, không phải tiền): `PUT /billing/credits/{agencyId}/limits` (Set Credit, FR 3.9.7) — chỉ ghi số nguyên hạn mức, không chạm luồng thanh toán.

## 8. Rủi ro / câu hỏi mở

1. **BA doc vs code sai khác về payment gateway:** `docs/ba/08-subscription-billing.md` FR 3.9.3 ghi "Make Payment (PayOS)" nhưng code thực tế (`SePayProperties`, `SePayTransactionClient`, `BillingController.sepayWebhook`, `AgencyPaymentPanel.tsx` dùng `qrUrl`) dùng **SePay** (QR chuyển khoản ngân hàng), không thấy PayOS/VNPay/Momo/Stripe trong codebase. Cần hỏi BA/PM xác nhận đây là update chưa đồng bộ vào doc, hoặc PayOS từng được dự tính nhưng đã đổi sang SePay.
2. **Hai hệ plan song song:** `SubscriptionController`/`SubscriptionPlan` (User-scoped, enum BASIC/PRO/ENTERPRISE, field `aiCreditsMonth`) vs `BillingPlanController`/`BillingPlanResponse` (Agency-scoped, versioned, field `monthlyAiCredits`, có `checkoutEnabled`/`isSellable`). Web frontend (`brandhub-web/src/pages/subscription/`) dùng hệ nào là chính? Cần xác nhận route nào mobile nên gọi — tài liệu này tạm ưu tiên hệ 3b vì khớp BA doc hơn, nhưng cần BE xác nhận trước khi code.
3. **`/billing/transactions` vs `/billing/agencies/{agencyId}/invoices`:** có vẻ trùng chức năng View Invoice History (FR 3.9.4) — cần hỏi route nào đang active/được web dùng thật (ground truth) trước khi mobile tích hợp, tránh build trên route đã deprecated.
4. **Khuyến nghị "mở web ngoài thay vì mua trong app" ở mục 7 là đề xuất của tài liệu này, chưa phải quyết định đã chốt** — cần user/PM xác nhận trước khi đưa vào implementation plan thật.
5. **Độ chính xác mapping plan → AI credit:** số liệu cụ thể (giá, số credit mỗi plan) nằm trong DB seed/migration, không nằm trong code Java đọc được trực tiếp ở các file đã xem — nếu cần số thật để demo UI, phải tra thêm seed data (`AdminDemoSeeder.java`) hoặc DB, chưa làm ở phạm vi tài liệu này.

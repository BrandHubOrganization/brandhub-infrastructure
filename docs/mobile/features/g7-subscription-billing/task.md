# Task — G7 Subscription & Billing (Mobile, READ-ONLY)

> [spec.md](./spec.md)

## Chặn trước khi code (cần xác nhận với BE/PM)

- [ ] **Hỏi BE route plan nào là chính thức** — hệ cũ `SubscriptionController` (User-scoped) vs hệ mới `BillingPlanController`/`BillingController` (Agency-scoped). Spec đề xuất ưu tiên hệ mới nhưng chưa confirm (mục 8 câu 2).
- [ ] **Hỏi BE route invoice nào chính thức** — `/billing/transactions` vs `/billing/agencies/{agencyId}/invoices` có vẻ trùng chức năng (mục 8 câu 3).
- [ ] **Xác nhận với PM**: khuyến nghị "không thanh toán thật trong app, chỉ mở web ngoài" ở spec mục 7 là đề xuất của tài liệu, **chưa phải quyết định đã chốt** — cần duyệt trước khi lên implementation plan thật.
- [ ] Tra seed data (`AdminDemoSeeder.java`) hoặc DB nếu cần số liệu thật (giá/credit mỗi plan) để demo UI.

## Current Plan screen

- [ ] `GET /billing/agencies/{agencyId}/subscription` (hoặc `/subscription/me` nếu BE xác nhận dùng hệ cũ) — hiển thị plan name, trạng thái, `currentPeriodEnd`.
- [ ] Block AI credit allowance — `GET /billing/credits/{agencyId}/usage?month=<tháng hiện tại>`, hiển thị `allowance/used/remaining/creatorLimit/creatorUsed`.

## Plan comparison list

- [ ] `GET /billing/plans` — card mỗi plan: `displayName, priceMonthly, monthlyAiCredits, maxActiveWorkspaces, maxInternalMembers, isSellable, checkoutEnabled`.
- [ ] Nút "Nâng cấp" — **KHÔNG mở checkout trong app**, dùng `Linking.openURL()` mở trình duyệt ngoài tới `/subscription/checkout?tier=...` của web (không WebView nhúng).

## Invoice history

- [ ] `GET /invoices?cursor&limit&status&kind&from&to` — `useInfiniteQuery` theo `cursor`/`nextCursor` (không dùng offset).
- [ ] List hiển thị `planCode, amount, currency, status, createdAt, paidAt` + filter status/kind/khoảng ngày.
- [ ] Invoice Detail — `GET /invoices/{orderId}`, hiển thị `productSnapshot`, `payments` (verificationState từng payment), `reviewReasons` nếu có.
- [ ] Nút "Tải receipt" — `GET /invoices/{orderId}/receipt` (file `.txt`, không JSON) — dùng Expo file system API, không cache (luôn fetch mới).

## State/cache

- [ ] `['billing','agency',agencyId,'subscription']` — staleTime ngắn (vài phút, đổi qua webhook SePay).
- [ ] `['billing','plans']` — cache lâu (`staleTime: 1 hour`).
- [ ] `['billing','agency',agencyId,'credits',month]` — key theo `month` tránh lẫn dữ liệu tháng cũ.
- [ ] `['billing','agency',agencyId,'invoices',filters]` — infinite query.

## Business rules cần hiển thị đúng

- [ ] AI credit 2 lớp: hạn mức Agency (plan) + hạn mức Creator (Owner set) — `remaining = min(agency_remaining, creator_limit - creator_used)` nếu có set riêng.
- [ ] Hạn mức Creator là hard limit — hết credit chặn hẳn thao tác AI, không phải soft warning.
- [ ] Credit Plan không rollover sang kỳ sau; dùng credit Plan trước, credit mua thêm sau (không hết hạn).
- [ ] Subscription hết hạn vẫn reset hạn mức hàng tháng theo anchor cũ.
- [ ] Payment gateway thật là **SePay** (QR chuyển khoản), KHÔNG phải PayOS như BA doc ghi — không hiển thị nhầm tên gateway trong UI (mục 8 câu 1).

## Có thể làm thêm nếu còn thời gian (rủi ro thấp, không phải tiền)

- [ ] `PUT /billing/credits/{agencyId}/limits` (Set Credit, FR 3.9.7) — Owner-only, chỉ ghi số nguyên hạn mức.

## Chưa làm / out of scope G7 (xem spec mục 7)

- [ ] Không làm: `POST /subscription`, `POST /billing/agencies/{agencyId}/orders`, `POST /billing/credits/buy`, `POST /subscription/cancel`, hiển thị QR SePay trong app — mọi hành động mua/upgrade/thanh toán chỉ mở web ngoài.

## Rủi ro cần chốt trước khi code (xem spec mục 8)

1. BA doc ghi payment gateway PayOS nhưng code dùng SePay — cần BA/PM xác nhận doc chưa update hay đổi gateway giữa đường.
2. 2 hệ plan song song (User-scoped cũ vs Agency-scoped mới) — xác nhận route nào web đang dùng thật trước khi mobile tích hợp.
3. `/billing/transactions` vs `/billing/agencies/{id}/invoices` trùng chức năng — xác nhận route active, tránh build trên route deprecated.
4. Khuyến nghị "mở web ngoài" là đề xuất riêng của spec, chưa phải quyết định chính thức.
5. Số liệu giá/credit mỗi plan nằm trong seed/migration, không đọc được trực tiếp từ code Java.

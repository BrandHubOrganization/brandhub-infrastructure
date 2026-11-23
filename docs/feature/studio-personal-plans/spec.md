# Studio Plans — Gói trả phí cho công ty Personal

> FR liên quan: 3.9.1 Upgrade Plan, 3.9.2 Renew Plan, 3.9.5 Buy Credit, 3.4.x Create Workspace / Invite Member.
> Quyết định nghiệp vụ chốt với chủ dự án ngày 2026-11-22.
> Thay thế phần "Personal proposal" của `subscription-four-plan-catalog` (gói `PERSONAL` scope USER giữ nguyên, không bán).

## 1. Objective

Personal là nguồn doanh thu chính lúc ra mắt, nhưng hiện chưa có đường thu tiền:
công ty Personal đang bị gán gói BASIC của Agency (0 credit, 3 thành viên, 5 khách hàng),
và muốn nâng cấp chỉ có Agency Plus 990k. Gói `PERSONAL` cũ trong DB không bán được.

Mục tiêu: một dòng gói riêng **Studio** cho công ty `company_type = PERSONAL`, giá theo
thị trường cá nhân VN (Google AI Plus 132k, CapCut Pro ~290k, Canva Pro ~250-330k),
lãi ≥ 60% kể cả khi người dùng đốt hết credit vào video.

## 2. Bảng gói (chốt)

| Quyền lợi | Studio Free | Studio Plus | Studio Pro |
|---|---|---|---|
| Mã gói (`code`) | `STUDIO_FREE` | `STUDIO_PLUS` | `STUDIO_PRO` |
| Giá / tháng | 0đ | 99.000đ | 299.000đ |
| Trả trước 3 / 6 / 12 tháng | — | 279k / 529k / 949k | 849k / 1.599k / 2.869k |
| Không gian cá nhân | 1 | 3 | 10 |
| Người dùng | chỉ chủ | chỉ chủ | chủ + 2 Creator |
| Plan credit / tháng | 100 | 900 | 2.400 |
| Lưu trữ | 2 GB | 5 GB | 30 GB |
| Tác vụ AI song song | 1 | 1 | 2 |
| Lịch sử hoạt động | 30 ngày | 90 ngày | 180 ngày |
| Lịch sử phiên bản | 7 ngày | 30 ngày | 90 ngày |
| Thùng rác | 7 ngày | 30 ngày | 30 ngày |
| Khách hàng / Client Portal | không | không | không |
| Mua thêm credit (3.9.5) | có | có | có |

Cơ sở giá (sheet "Chi phí " — Business & Finance.xlsx, tỷ giá 25.726đ/USD):
credit đắt nhất = video 32,2đ/credit; AI text 1.443đ/người/tháng; S3 643đ/GB/tháng.

| Gói | Chi phí tối đa / tháng | Lãi sau phí cổng 3,5% |
|---|---|---|
| Studio Free | ~3k (100 credit không đủ 1 video, credit hết hạn cuối kỳ) | — |
| Studio Plus | 33,6k | 62,6% |
| Studio Pro | 100,9k | 62,8% |

Hòa vốn chi phí cố định 7,66 triệu/tháng ≈ 70 Plus hoặc 25 Pro (theo mức dùng thực tế).

## 3. User Stories

- US1. Là chủ công ty Personal mới, tôi được cấp ngay Studio Free, không thấy gì về Agency.
- US2. Là chủ công ty Personal, ở trang Gói tôi chỉ thấy 3 gói Studio và mua Plus/Pro qua SePay.
- US3. Đang ở Studio Plus, tôi lên Studio Pro ngay và chỉ trả phần chênh lệch theo ngày còn lại.
- US4. Gói Studio hết hạn thì tôi tự về Studio Free (không về Agency Basic).
- US5. Vượt số không gian / thành viên của gói thì tôi bị chặn kèm gợi ý nâng cấp.
- US6. Là chủ Agency, tôi không thấy và không mua được gói Studio (và ngược lại).

## 4. Acceptance Criteria

- AC1. Tạo công ty `PERSONAL` (form, chooser, bootstrap) → subscription `STUDIO_FREE`, ví credit được tạo.
  Tạo công ty `AGENCY` → `BASIC` như cũ.
- AC2. Migration: công ty `PERSONAL` đang ở `BASIC` chuyển sang `STUDIO_FREE`.
  Công ty Personal đã mua `PLUS` Agency giữ nguyên tới hết kỳ (grandfather), hết kỳ về `STUDIO_FREE`.
- AC3. `GET /api/v1/billing/plans?agencyId=` trả đúng dòng gói theo `company_type` của agency
  (không có `agencyId` → dòng Agency như cũ).
- AC4. Đặt hàng: `planCode ∈ {PLUS, STUDIO_PLUS, STUDIO_PRO}`; gói phải cùng dòng với công ty, nếu không → `BILLING_ORDER_CONFLICT`.
- AC5. Thứ hạng: Free(0) < Plus(1) < Pro(2) trong mỗi dòng. UPGRADE chỉ khi hạng đích > hạng hiện tại (hiệu lực);
  RENEWAL chỉ khi đích = gói hiện tại hoặc đang EXPIRED. Không có hạ cấp (AGENTS.md).
- AC6. Nâng Studio Plus → Studio Pro giữa kỳ (proration):
  `giá = giáPro(chu kỳ chọn) − floor_1000(số tiền đã trả kỳ Plus hiện tại × thời gian còn lại / độ dài kỳ)`.
  Kỳ Pro bắt đầu ngay khi thanh toán; kỳ Plus hiện tại kết thúc tại thời điểm đó;
  credit tháng đầu của Pro cấp ngay; credit Plus còn lại giữ tới hạn cũ.
  Nếu phần trừ ≥ giá Pro chu kỳ đã chọn → từ chối, yêu cầu chọn chu kỳ dài hơn.
  Nếu đang có kỳ FUTURE (đã gia hạn trước) → từ chối nâng giữa kỳ.
- AC7. Hết hạn gói Studio trả phí → `STUDIO_FREE` + thông báo "Gói Studio đã hết hạn" (không nhắc Basic/Plus Agency).
- AC8. Giới hạn không gian áp dụng cho công ty Personal: tạo / khôi phục không gian thứ N+1 → mã lỗi PLAN_LIMIT hiện có.
  Công ty Agency: workspace chế độ Personal cũng tính slot (bịt lỗ tạo PERSONAL rồi chuyển AGENCY để lách giới hạn).
- AC9. Giới hạn thành viên: Free/Plus không mời được ai; Pro mời tối đa 2 Creator.
- AC10. Danh sách công ty (`GET /agencies`) trả `planCode` hiệu lực đúng (STUDIO_*).
- AC11. Admin revenue nhóm theo gói hiển thị STUDIO_* (sau dòng Agency, thứ tự Free, Plus, Pro).
- AC12. Agency Enterprise giảm lưu trữ 1 TB → 500 GB (version gói mới, giá giữ 3,99tr) để biên xấu nhất đạt 64,7% ≥ 60%.
  Thuê bao Enterprise đang chạy giữ version cũ tới hết kỳ.
- AC13. Sửa 3 lỗi luồng Personal (review 2026-11-22):
  (a) form tạo không gian trong công ty Personal khoá chế độ PERSONAL, ẩn chọn chế độ / mời khách hàng / trường doanh nghiệp, tạo xong vào dashboard;
  (b) trang Công việc ở không gian Personal không tự gắn task vào chiến dịch đầu tiên, hiện ô chọn chiến dịch tuỳ chọn, ẩn banner nghiệm thu chiến dịch;
  (c) cài đặt không gian của công ty Personal ẩn khối chuyển chế độ Personal/Agency.

Mô hình giá & lợi nhuận đầy đủ: `brandhub-infrastructure/docs/ba/BrandHub_Pricing_Model.xlsx`.

## 5. UI/UX (web; mobile theo sau)

- Trang `/subscription/plans` với công ty Personal: 3 thẻ Studio, toggle chu kỳ 1/3/6/12 tháng,
  thẻ hiện tại gắn "Gói hiện tại", không có ma trận Agency (khách hàng/newsletter).
  Thẻ Pro khi đang Plus: hiện "Trả chênh lệch ~Xđ" (lấy từ báo giá backend).
- Thẻ công ty / switcher hiển thị tên gói "Studio Plus" thay vì "Plus".
- Toast vượt giới hạn (upgrade funnel) dẫn tới `/subscription/plans?reason=...` như hiện có.
- **i18n:** key mới trong `subscription.json` (vi + en, key-parallel):
  `subscription.studio.free|plus|pro.name`, `subscription.studio.free|plus|pro.tagline`,
  `subscription.studio.scope`, `subscription.studio.proration`, `subscription.studio.cycleTooShort`,
  `subscription.studio.features.*` (spaces, members, credits, storage, aiJobs, history, trash),
  `subscription.studio.expiredNotice`. Không hardcode chuỗi trong JSX.
- **Light/Dark:** chỉ dùng token sẵn có (`bg-card`, `text-muted-foreground`, `brand-orange`, `dark:` variant);
  không thêm màu hex mới.

## 6. API Contract

- `GET /api/v1/billing/plans?agencyId={uuid}` → `BillingPlanResponse[]` (thêm field `productLine: "AGENCY"|"STUDIO"`).
- `POST /api/v1/billing/agencies/{agencyId}/orders` body `{ planCode, action, periodMonths }`
  — `planCode` pattern `PLUS|STUDIO_PLUS|STUDIO_PRO`. Order lưu `amount` đã trừ proration và
  `product_snapshot.prorationCredit`.
- `GET /api/v1/billing/agencies/{agencyId}/upgrade-quote?planCode=&periodMonths=` → `{ price, prorationCredit, amount }`
  (UI hiện số tiền trước khi tạo đơn).

## 7. Error Handling

| Tình huống | Mã lỗi |
|---|---|
| Mua gói khác dòng công ty | `BILLING_ORDER_CONFLICT` |
| Hạ cấp / mua gói thấp hơn | `BILLING_ORDER_CONFLICT` |
| Proration ≥ giá chu kỳ | `BILLING_ORDER_CONFLICT` (message: chọn chu kỳ dài hơn) |
| Đang có kỳ FUTURE mà nâng giữa kỳ | `BILLING_ORDER_CONFLICT` |
| Vượt số không gian / thành viên | mã PLAN_LIMIT hiện có của `AgencyPlanEntitlementService` |
| Gói Studio chưa cấu hình giá | `BILLING_NOT_CONFIGURED` |

## 8. Edge Cases

- Webhook về sau khi order hết hạn: giữ luồng REVIEW_REQUIRED hiện có.
- Proration tính lúc tạo đơn; đơn sống ngắn (expires_at) nên lệch vài phút có lợi cho khách — chấp nhận.
- Plus trả trước 12 tháng nâng lên Pro 1 tháng → phần trừ lớn hơn giá → bắt chọn chu kỳ dài hơn.
- Hết hạn khi đang có 3 không gian / 2 Creator (vượt Free): giữ dữ liệu, chặn tạo mới (giống Agency hiện tại).
- Công ty Personal cũ nhận diện bằng `logo_icon='personal-studio'` đã được backfill `company_type` ở migration 2026-11-22.

## 9. UI States

Loading (skeleton thẻ gói), lỗi tải catalog (DataErrorState), thẻ disabled khi không mua được
(gói thấp hơn / gói hiện tại không gia hạn được), nút loading khi tạo đơn, trạng thái chờ thanh toán SePay (hiện có).

## 10. Definition of Done

AC1–AC11 pass; `mvn clean test` xanh; `npx tsc --noEmit` xanh; migration chạy idempotent 2 lần;
test.md tick hết; i18n vi/en song song; light/dark kiểm tra.

## 11. Out of Scope

- Mobile app (đợt sau, dùng lại API).
- Dùng thử miễn phí / ưu đãi sinh viên.
- Chuyển công ty Personal ↔ Agency (muốn làm agency thì tạo công ty Agency mới).
- Hoàn tiền, hạ cấp.
- Xoá gói `PERSONAL` (USER scope) cũ — giữ nguyên, không bán.

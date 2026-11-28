# 08 — Gói Cước, Thanh Toán SePay (VietQR) & Ví AI Credit (Subscription & Billing)

> Navigation: [← BA Overview & Hub](./README.md) · [← 07 - Publishing & Social](./07-publishing-social.md) · [Tiếp: 09 - Admin Functions →](./09-admin-functions.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.9 Subscription & Billing` — 6 FR (`3.9.1` – `3.9.6`)** | `UC-122` – `UC-127` · Use Cases chi tiết: [use-cases/07-subscription.md](./use-cases/07-subscription.md) · Đặc tả SRS: [08-subscription-billing](../feature/srs/08-subscription-billing/README.md).
> Tuân thủ tuyệt đối `AGENTS.md` (**Không có Downgrade Plan**, **Chỉ sử dụng cổng thanh toán SePay (VietQR)**) và mô hình tài chính chi tiết tại `brandhub-pricing-model.xlsx`.

---

## 1. Bảng Tổng hợp 6 Yêu cầu Chức năng Chuẩn (`3.9.1` – `3.9.6`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (141-FR Baseline) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.9.1`** | `UC-122` | **Upgrade Plan** | `Owner` | Nâng cấp gói đăng ký dịch vụ từ gói mặc định lên gói cao hơn trên `/subscription/plans` (**chỉ hỗ trợ nâng cấp lên cấp cao hơn, đã lược bỏ luồng hạ cấp gói trực tiếp**, `BR-15`, `BR-58`, `BR-59`). |
| **`3.9.2`** | `UC-123` | **Make Payment (SePay)** | `Owner` | Thực hiện thanh toán đơn hàng nâng cấp gói cước hoặc mua thêm AI Credit thông qua cổng **SePay (VietQR)** (`/billing/checkout/:transactionId`). Khởi tạo giao dịch `PENDING` tuân thủ ACID trong PostgreSQL; khi nhận Webhook chữ ký hợp lệ từ SePay sẽ xử lý bất biến (`idempotent`) chuyển sang `PAID` và kích hoạt ngay quyền lợi (`BR-58`–`BR-61`). |
| **`3.9.3`** | `UC-124` | **View Invoice History** | `Owner` | Xem lịch sử toàn bộ các giao dịch thanh toán (`PAID`, `PENDING`, `EXPIRED`, `FAILED`) và tải xuống hóa đơn điện tử dạng PDF tại `/billing/invoices` (`BR-15`, `BR-61`). |
| **`3.9.4`** | `UC-125` | **View AI Credit Tracking** | `Owner`, `Manager` | Giám sát chi tiết lượng AI Credit đã tiêu thụ, lượng đang tạm giữ và số dư còn lại theo thời gian thực (`/billing/credits`) theo từng loại tác vụ AI, từng Workspace và kỳ thanh toán tháng (lượng credit định kỳ hàng tháng không cộng dồn sang tháng sau, `BR-48`, `BR-60`, `BR-64`). |
| **`3.9.5`** | `UC-126` | **Buy Credit** | `Owner` | Mua bổ sung các gói nạp thêm AI Credit (`Top-up Credit Packs`) qua cổng **SePay (VietQR)** (`3.9.2`) và cộng ngay số lượng AI Credit mua thêm vào tổng quỹ khả dụng của Agency sau khi thanh toán thành công (`BR-15`, `BR-59`, `BR-60`). |
| **`3.9.6`** | `UC-127` | **Set Credit** | `Owner` | Thiết lập và điều chỉnh hạn mức tiêu thụ AI Credit tối đa hàng tháng cho từng Workspace trực thuộc Agency (`/agency/:id/workspaces/:id/credit-limit`) sao cho không thấp hơn mức Workspace đó đã tiêu thụ trong kỳ hiện tại (`BR-15`, `BR-48`, `BR-60`, `BR-64`). |

---

## 2. Cơ cấu 2 Dòng Sản phẩm & 6 Gói Cước Chuẩn (`Subscription Plans`)

Hệ thống phục vụ cả người sáng tạo cá nhân (`Personal Studio`) và doanh nghiệp truyền thông (`Agency Suite`) thông qua **2 dòng sản phẩm (6 gói cước)**:

| Dòng sản phẩm | Mã Gói Cước (`plan_code`) | Cấp bậc | Đặc trưng Quyền lợi & Hạn mức |
| :--- | :--- | :---: | :--- |
| **1. BrandHub AI Studio** *(Chế độ `PERSONAL` / Solo Creator)* | `STUDIO_FREE` → `STUDIO_PLUS` → `STUDIO_PRO` | 3 bậc nâng cấp | Tối ưu cho cá nhân/nhóm nhỏ: cấp định mức `Plan Credit` hàng tháng tăng dần, dung lượng kho tư liệu, số kênh MXH cá nhân và hạn mức gửi bản tin. |
| **2. BrandHub Agency Suite** *(Chế độ `AGENCY` B2B)* | `BASIC` → `PLUS` → `ENTERPRISE` | 3 bậc nâng cấp | Quản trị đa Workspace / đa `Client`: mở rộng số lượng Workspace, thành viên, kênh mạng xã hội, định mức gửi Email Newsletter (`1.000` / `10.000` / `50.000` email/tháng) và quỹ `Plan Credit` lớn. |

> **Quy tắc bất biến**: Hệ thống chỉ cho phép **nâng cấp lên gói cao hơn hoặc gia hạn (`3.9.1 Upgrade Plan`)**; không hỗ trợ hạ cấp trực tiếp (`Downgrade Plan`).

---

## 3. Luồng Thanh Toán ACID Qua Cổng SePay (VietQR — `3.9.1`..`3.9.3`)

```text
[Owner chọn Nâng cấp gói (3.9.1) hoặc Mua thêm Credit (3.9.5)]
       │
       ▼
[Backend tạo Order + Transaction (status = PENDING) trong PostgreSQL kèm mã tham chiếu duy nhất]
       │
       ▼
[Frontend hiển thị mã VietQR động của SePay (Ngân hàng, Số tài khoản, Số tiền, Nội dung tham chiếu)]
       │
       ├──(Owner quét QR trên ứng dụng Ngân hàng)──▶ [Cổng SePay ghi nhận biến động số dư]
       │                                                       │
       │                                                       ▼
       │                                    [SePay gửi Webhook xác thực chữ ký về Backend (Idempotent)]
       │                                                       │
       ▼                                                       ▼
[Trạng thái chuyển sang PAID] ──▶ [Kích hoạt gói Subscription mới / Cộng Credit vào agency_credit_wallets]
```

---

## 4. Kiến trúc Ví AI Credit Cấp Agency & Trần Ngân sách Workspace (`3.9.4` – `3.9.6`)

1. **Một Ví Tổng cấp Agency (`agency_credit_wallets`) & Hai Lớp Số dư**:
   - **`Plan Credit` (Credit định kỳ theo gói)**: Làm mới hàng tháng theo chu kỳ gói, không cộng dồn sang kỳ sau.
   - **`Purchased Credit` (Credit mua thêm tại `3.9.5`)**: Bảo lưu không hết hạn theo chu kỳ tháng.
   - **Thứ tự khấu trừ**: Luôn ưu tiên trừ `Plan Credit` trước, hết `Plan Credit` mới trừ sang `Purchased Credit`.
2. **Trần Ngân sách cấp Workspace (`workspace_credit_limits` — `3.9.6 Set Credit`)**:
   - `Owner` cấu hình trần tiêu thụ hàng tháng cho từng Workspace (`cap = null` là không giới hạn riêng theo ví tổng; `cap = N > 0` giới hạn tổng `used + held <= N`; `cap = 0` khóa tác vụ tính phí trong Workspace đó).
3. **Quy trình Giữ chỗ & Quyết toán Nguyên tử (`ai_credit_reservations`)**:
   - Chỉ 4 nhóm tác vụ tính phí (`CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, `VIDEO_GENERATE`) trừ credit theo bảng đơn giá hệ thống (`3.10.10`–`3.10.12`).
   - Trước khi gọi sang `ai-service`, `business-service` khóa tạm credit (`HOLD`); khi AI hoàn tất mới chốt trừ (`SETTLE`), nếu AI lỗi hoặc timeout sẽ tự động hoàn trả 100% (`RELEASE`).

---

## 5. Bảng Tham chiếu Quy tắc Nghiệp vụ (`BR-58` – `BR-61`, `BR-64`)

| Mã BR | Tên Quy tắc | Quy định Ràng buộc Cụ thể | FR Áp dụng |
| :-: | :--- | :--- | :--- |
| `BR-58` | **Chỉ Nâng cấp Gói & Áp dụng Tức thì Hạn mức** | Hệ thống chỉ cho phép nâng cấp lên bậc gói cao hơn trong cùng dòng hoặc nâng cấp từ dòng `STUDIO_*` lên dòng `Agency` (`BASIC`/`PLUS`/`ENTERPRISE`) hoặc gia hạn chu kỳ tháng/năm (`billing_plan_cycle_prices`); **tuyệt đối không hỗ trợ luồng hạ cấp gói (`Downgrade Plan`)**. | `3.9.1`, `3.9.2` |
| `BR-59` | **Thanh toán Duy nhất qua SePay (VietQR) & Xử lý Webhook Bất biến** | Mọi đơn hàng nâng cấp gói (`3.9.1`), mua thêm AI Credit (`3.9.5`) hoặc mua thêm dung lượng (`storage_addon_plans`) đều thanh toán qua **SePay (VietQR)**; sự kiện webhook từ SePay được ghi vào `billing_payment_events` và đối chiếu khóa chống trùng (`idempotent`) trước khi chuyển đơn sang `PAID` và cấp phát quyền lợi tại `billing_order_fulfillments`. | `3.9.2`, `3.9.5`, `3.10.13` |
| `BR-60` | **Thứ tự Ưu tiên Khấu trừ Sổ cái Ví AI Credit** | Ví tổng `agency_credit_wallets` phân bổ từng lô `credit_grants`: luôn khấu trừ lô `Plan Credit` (có hạn theo kỳ tháng, không cộng dồn sang kỳ mới) trước, chỉ khi hết sạch mới khấu trừ sang lô `Purchased Credit` (mua thêm không hết hạn). Xem lại lịch sử nội dung cũ (`3.6.34`) không phát sinh bút toán trừ mới. | `3.9.4`–`3.9.6` |
| `BR-61` | **Tính Bất biến của Chứng từ Hóa đơn & Sổ cái Giao dịch** | Bản ghi `transactions`, `billing_payments` và `billing_audit_events` trong PostgreSQL là bất biến (append-only); mọi hóa đơn `PAID` đều có thể kết xuất chứng từ điện tử PDF và đối soát trực tiếp trên bảng doanh thu của `Admin`. | `3.9.2`, `3.9.3`, `3.10.13`, `3.10.14` |
| `BR-64` | **Ràng buộc Trần Ngân sách Workspace & Khóa Giá Tại Thời điểm Đặt chỗ** | Khi `Owner` cập nhật trần `workspace_credit_limits` (`3.9.6 Set Credit`), giá trị mới không được nhỏ hơn tổng credit mà Workspace đó đã tiêu thụ + đang giữ chỗ trong kỳ hiện hành; khi `Admin` đổi bảng giá (`3.10.11`), các lệnh `ai_credit_reservations` đã giữ chỗ trước đó vẫn quyết toán theo mức giá cũ lúc đặt chỗ. | `3.9.4`, `3.9.6`, `3.10.10`–`3.10.12` |

---

## 6. Ánh xạ Hệ thống Bảng Sổ cái PostgreSQL (`Billing V3` — 29 Bảng)

Toàn bộ dữ liệu tài chính và sổ cái AI Credit được lưu trữ độc quyền trên **PostgreSQL 17** (`brandhub-business-service`):
- **Danh mục & Chu kỳ gói**: `subscription_plans`, `billing_plan_versions`, `billing_plan_cycle_prices`, `billing_plan_change_log`, `user_subscriptions`, `subscription_plan_changes`, `agency_subscriptions`, `agency_subscription_periods`.
- **Đơn hàng & Thanh toán SePay**: `billing_orders`, `billing_payment_attempts`, `billing_payment_events`, `billing_payments`, `billing_order_fulfillments`, `transactions`, `subscription_operational_issues`, `subscription_observation_jobs`, `subscription_provider_checks`.
- **Sổ cái Kép AI Credit**: `agency_credit_wallets`, `credit_grants`, `workspace_credit_limits`, `credit_usage_periods`, `workspace_credit_usage`, `ai_credit_operation_prices`, `ai_credit_reservations`, `credit_reservation_allocations`, `credit_operations`, `credit_entries`, `billing_outbox_events`, `billing_audit_events`.

### Lộ trình Nâng cấp Gói Cước Hợp lệ (`Upgrade-Only Matrix`)

| Gói Hiện tại | Các Gói Đích Được Phép Nâng Cấp (`3.9.1 Upgrade Plan`) | Quy tắc Chuyển đổi Quyền lợi |
| :--- | :--- | :--- |
| `STUDIO_FREE` | `STUDIO_PLUS`, `STUDIO_PRO`, `BASIC`, `PLUS`, `ENTERPRISE` | Mở khóa ngay hạn mức mới sau khi đơn hàng **SePay (VietQR)** chuyển sang `PAID`. |
| `STUDIO_PLUS` | `STUDIO_PRO`, `BASIC`, `PLUS`, `ENTERPRISE` | Chuyển thẳng từ `Personal Studio` lên `Agency Suite` giữ nguyên 100% dữ liệu & `Purchased Credit`. |
| `STUDIO_PRO` | `BASIC`, `PLUS`, `ENTERPRISE` | Nâng cấp sang vận hành đa `Workspace` / đa `Client` B2B. |
| `BASIC` | `PLUS`, `ENTERPRISE` | Mở rộng trần `Workspace`, thành viên, định mức gửi Newsletter và lô `Plan Credit` tháng. |
| `PLUS` | `ENTERPRISE` | Cấp bậc doanh nghiệp cao nhất (không có gói cao hơn; chỉ gia hạn chu kỳ hoặc mua thêm `Top-up Credit`). |

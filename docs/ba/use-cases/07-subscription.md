# UC 07 — Subscription & Billing (`UC-122` – `UC-127`)

> [<< 06-publishing-social.md](./06-publishing-social.md) | [UC Index](./README.md) | [Domain BA Spec: 08-subscription-billing.md](../08-subscription-billing.md) | [08-admin-functions.md >>](./08-admin-functions.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (6 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-122` | Upgrade Plan | `Owner` | `3.9.1` | `BR-15, BR-58, BR-59` |
| `UC-123` | Make Payment (SePay) | `Owner` | `3.9.2` | `BR-15, BR-58, BR-59, BR-60, BR-61` |
| `UC-124` | View Invoice History | `Owner` | `3.9.3` | `BR-15, BR-61` |
| `UC-125` | View AI Credit Tracking | `Owner`, `Manager` | `3.9.4` | `BR-48, BR-60, BR-64` |
| `UC-126` | Buy Credit | `Owner` | `3.9.5` | `BR-15, BR-59, BR-60` |
| `UC-127` | Set Credit | `Owner` | `3.9.6` | `BR-15, BR-48, BR-60, BR-64` |

---

## UC-122 — Upgrade Plan

- **Related FR:** `3.9.1` (3.9 Subscription & Billing)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-58, BR-59`
- **System Messages:** `MSG02, MSG03, MSG07, MSG36, MSG55`
- **Specification & Flow:** Nâng cấp gói đăng ký dịch vụ của Agency từ gói mặc định (Basic/Free) lên gói cao hơn (PLUS hoặc Enterprise) trên màn hình Subscription Plans (/subscription/plans). Hệ thống chỉ hỗ trợ nâng cấp lên gói có cấp bậc cao hơn (đã lược bỏ luồng hạ cấp gói trực tiếp) để mở rộng giới hạn số lượng Workspace, số lượng thành viên, số kênh mạng xã hội kết nối và định mức AI Credit hàng tháng (BR-58).

---

## UC-123 — Make Payment (SePay)

- **Related FR:** `3.9.2` (3.9 Subscription & Billing)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-58, BR-59, BR-60, BR-61`
- **System Messages:** `MSG07, MSG36, MSG56`
- **Specification & Flow:** Thực hiện thanh toán đơn hàng nâng cấp gói cước hoặc mua thêm AI Credit thông qua cổng thanh toán VietQR SePay (Make Payment SePay — /billing/checkout/:transactionId). Hệ thống khởi tạo giao dịch ở trạng thái PENDING tuân thủ nghiêm ngặt tính chất ACID trong PostgreSQL, sinh mã QR chuyển khoản ngân hàng chứa mã tham chiếu duy nhất; khi nhận Webhook xác thực chữ ký hợp lệ từ SePay, hệ thống xử lý bất biến (idempotent) để chuyển giao dịch sang PAID và kích hoạt ngay quyền lợi gói/credit (BR-59).

---

## UC-124 — View Invoice History

- **Related FR:** `3.9.3` (3.9 Subscription & Billing)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-61`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem lịch sử toàn bộ các giao dịch thanh toán và tải xuống hóa đơn điện tử dạng PDF của tài khoản/Agency (View Invoice History — /billing/invoices). Hiển thị Mã hóa đơn, Loại giao dịch (Nâng cấp gói / Mua thêm AI Credit), Số tiền, Phương thức thanh toán (SePay VietQR), Trạng thái (PAID, PENDING, EXPIRED, FAILED), Thời gian giao dịch và nút tải tệp hóa đơn PDF (BR-61).

---

## UC-125 — View AI Credit Tracking

- **Related FR:** `3.9.4` (3.9 Subscription & Billing)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-48, BR-60, BR-64`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Giám sát chi tiết lượng AI Credit đã tiêu thụ và số dư còn lại theo thời gian thực (View AI Credit Tracking — /billing/credits). Thống kê lượng credit mà các Creator đã sử dụng theo từng loại tác vụ AI (Generate Caption, Image, Video, Virtual Ambassador), theo từng Workspace và theo kỳ thanh toán tháng (lượng credit định kỳ hàng tháng không cộng dồn sang tháng sau, BR-48, BR-60).

---

## UC-126 — Buy Credit

- **Related FR:** `3.9.5` (3.9 Subscription & Billing)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-59, BR-60`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36, MSG55`
- **Specification & Flow:** Mua bổ sung các gói nạp thêm AI Credit (Top-up Credit Packs) khi Agency sử dụng hết định mức credit có sẵn trong gói PLUS/Enterprise (Buy Credit — /billing/credits/buy). Khởi tạo giao dịch thanh toán qua SePay (3.9.2) và cộng ngay số lượng AI Credit mua thêm vào tổng quỹ khả dụng của Agency sau khi thanh toán thành công (BR-59, BR-60).

---

## UC-127 — Set Credit

- **Related FR:** `3.9.6` (3.9 Subscription & Billing)
- **Canonical Actor(s):** `Owner`
- **Business Rules:** `BR-15, BR-48, BR-60, BR-64`
- **System Messages:** `MSG01, MSG03, MSG07, MSG57`
- **Specification & Flow:** Thiết lập và điều chỉnh hạn mức tiêu thụ AI Credit tối đa hàng tháng cho từng Workspace trực thuộc Agency (Set Credit — /agency/:id/workspaces/:id/credit-limit). Giúp Owner kiểm soát phân bổ ngân sách AI giữa các dự án/nhãn hàng; tổng hạn mức cấp cho các Workspace không vượt quá quỹ credit của Agency và không thấp hơn số credit mà Workspace đó đã tiêu thụ trong kỳ hiện tại (BR-60).

# Plan — G7 Subscription & Billing (Mobile, READ-ONLY)

> [spec.md](./spec.md) — chi tiết API/flows/business rules đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **Chặn trước khi code bất kỳ màn nào** — cần xác nhận với BE/PM:
   - Route plan chính thức: hệ cũ `SubscriptionController` (User-scoped) hay hệ mới `BillingPlanController`/`BillingController` (Agency-scoped).
   - Route invoice chính thức: `/billing/transactions` hay `/billing/agencies/{id}/invoices`.
   - Hướng "không thanh toán thật trong app, chỉ mở web ngoài" — đây là **đề xuất của spec, chưa phải quyết định chính thức**, cần PM duyệt.
2. **Current Plan screen** — đơn giản nhất, chỉ đọc.
3. **Plan comparison list** — nút "Nâng cấp" mở web ngoài (`Linking.openURL`), không checkout trong app.
4. **Invoice history** — list + detail + tải receipt.

## Quyết định kỹ thuật đã chốt

- **G7 là READ-ONLY tuyệt đối** — không build bất kỳ luồng mua/upgrade/thanh toán thật trong app. Lý do: Apple App Store Review Guidelines (mục 3.1.1) yêu cầu nội dung số bán trong app dùng IAP nếu app public; flow SePay QR hiện tại là thanh toán ngoài hệ sinh thái Apple/Google.
- **Vì bản demo nội bộ (Expo Go/TestFlight/ad-hoc, không public App Store)**, rủi ro chính sách này KHÔNG chặn demo capstone — nhưng để tránh viết lại UI khi/nếu app public hoá sau, vẫn giữ nguyên tắc READ-ONLY ngay từ đầu.
- **Payment gateway thật là SePay (QR chuyển khoản ngân hàng), KHÔNG phải PayOS** như BA doc ghi — xác nhận bằng code thật (`SePayProperties`, `SePayTransactionClient`, `qrUrl` trong `AgencyPaymentPanel.tsx`). Không hiển thị nhầm tên gateway trong UI.
- **AI credit 2 lớp**: hạn mức Agency (từ plan) và hạn mức Creator (Owner set, hard limit — hết credit chặn hẳn, không phải soft warning).

## Việc cần xác nhận trước khi code (chưa làm, xem spec mục 8)

- 2 hệ plan song song — xác nhận route web đang dùng thật trước khi mobile tích hợp.
- `/billing/transactions` vs `/billing/agencies/{id}/invoices` trùng chức năng — xác nhận route active, tránh build trên route deprecated.
- Khuyến nghị "mở web ngoài" chưa phải quyết định chính thức — PM cần duyệt.
- Số liệu giá/credit mỗi plan nằm trong seed/migration (`AdminDemoSeeder.java`), không đọc được trực tiếp từ code Java — cần tra thêm nếu muốn demo UI với số liệu thật.

## Rủi ro còn mở

- BA doc ghi PayOS nhưng code dùng SePay — cần BA/PM xác nhận doc chưa update hay đổi gateway giữa đường, tránh gây hiểu lầm khi review tài liệu.

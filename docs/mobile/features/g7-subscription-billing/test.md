# Test — G7 Subscription & Billing (Mobile, READ-ONLY)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Current Plan hiển thị đúng plan + trạng thái | Mục 4 | Plan name, status, `currentPeriodEnd` khớp dữ liệu Agency | Chưa test |
| TC-02 | AI credit allowance hiển thị đúng | Mục 4, 2 lớp Agency+Creator | `allowance/used/remaining/creatorLimit/creatorUsed` đúng | Chưa test |
| TC-03 | Plan comparison list hiện đủ card | Mục 4 | Mỗi plan hiện `displayName/priceMonthly/monthlyAiCredits/...` | Chưa test |
| TC-04 | Bấm "Nâng cấp" | Mục 7, READ-ONLY | Mở trình duyệt ngoài (`Linking.openURL`), KHÔNG mở WebView/checkout trong app | Chưa test |
| TC-05 | Invoice history list | Mục 4 | Hiện đúng `planCode/amount/currency/status/createdAt/paidAt` | Chưa test |
| TC-06 | Invoice history filter status/kind/khoảng ngày | Mục 4 | Filter hoạt động đúng, kết hợp được nhiều điều kiện | Chưa test |
| TC-07 | Invoice history pagination | Mục 5, cursor-based | `useInfiniteQuery` dùng `cursor`/`nextCursor`, không dùng offset | Chưa test |
| TC-08 | Invoice Detail | Mục 4 | Hiện `productSnapshot`, `payments` (verificationState từng payment), `reviewReasons` nếu có | Chưa test |
| TC-09 | Tải receipt | Mục 4 | File `.txt` tải về đúng (không parse JSON), dùng Expo file system API | Chưa test |
| TC-10 | Credit hết hạn mức Creator (hard limit) | Mục 6 business rule | Chặn hẳn thao tác AI tiếp theo, không phải soft warning | Chưa test |
| TC-11 | Subscription hết hạn | Mục 6 | Vẫn reset hạn mức hàng tháng theo anchor chu kỳ cũ | Chưa test |
| TC-12 | UI không hiển thị nhầm tên gateway | Mục 6, SePay không phải PayOS | Không có text "PayOS" ở đâu trong UI mobile | Chưa test |
| TC-13 | Không có action mua/upgrade/thanh toán nào gọi API ghi | Mục 7, READ-ONLY | Verify codebase: không có `POST /subscription`, `POST .../orders`, `POST .../credits/buy` nào được gọi từ mobile | Chưa test |

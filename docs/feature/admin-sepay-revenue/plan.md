Đổi truy vấn read-only repeatable-read AdminRevenueService sang billing_payments/attempts/orders/plan_versions; thêm revenue/count theo gói, giữ contract tương thích. MRR dùng số tiền đơn kỳ CURRENT active, không lấy giá catalog mới. Chart cột gọn màu brand, tooltip/theme rõ; panel phải dùng revenue thay mrr. Cập nhật vi/en, PDF nguồn SePay.

Dùng AS receipt_date trong SELECT/GROUP BY và đọc cùng tên qua JDBC; lỗi log 23:25:12 chỉ ra alias day thiếu AS.

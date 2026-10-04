# Task tổng thể — Admin Management

Nguồn: [plan](plan.md), [quyết định đã duyệt](confirmed-decisions-2026-10-01.md). Tiến độ chi tiết: [implementation status](implementation-status-2026-10-02.md).

- [x] Viết plan tổng thể và plan/task/test cho cả10 FR được sửa.
- [x] Nền tảng PostgreSQL: strike, nguồn quy đổi, pending review, operation id, audit, email outbox và phiên bản phiên/bản ghi.
- [x] API danh sách/lọc/phân trang, ghi/gỡ strike, bỏ cờ có điều kiện, xác nhận khóa30 ngày.
- [x] Job hết hạn sạch/tự mở khóa; giữ session đã thu hồi vô hiệu; gửi lại email không khóa lại account.
- [x] Kiểm tra ADMIN hiện tại; cấm tự phạt/ADMIN ngang hàng; tách Owner khỏi system role.
- [x] Tab user dùng API thật; dialog lịch sử/thao tác; VI/EN, sáng/tối và mobile.
- [x] Review độc lập và sửa ba lỗi đồng thời tìm được.
- [x] Migration DB test/dev; backup dev; smoke đăng nhập và đọc API thật qua Gateway.
- [ ] Hoàn thiện toàn bộ FR3.10.6: subscription catalog/plan và metadata liên quan cùng giai đoạn2.
- [ ] Giai đoạn2: Admin tạo user, kích hoạt bắt buộc/đổi mật khẩu, sửa hồ sơ và đổi gói kỳ sau có thanh toán.
- [ ] Giai đoạn3: contentVersion, moderation thật, hold schedule và kiểm tra tại Publisher.
- [ ] Giai đoạn4: soạn/hẹn giờ/hủy broadcast EMAIL với audience tại lúc gửi.
- [ ] Giai đoạn5: thống kê, payment ledger/đầu nối thanh toán, MRR/ARR/refund và timezone.
- [ ] Giai đoạn6: xuất PDF, link24h, snapshot/filter parity.
- [ ] Nghiệm thu end-to-end đủ10 FR. Monitoring3.10.3 thuộc Tuấn, không nằm trong checklist này.

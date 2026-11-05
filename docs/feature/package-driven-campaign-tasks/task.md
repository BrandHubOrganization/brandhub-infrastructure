# Checklist triển khai

- [ ] Liệt kê API, màn hình, trường nhập, luồng gọi web/mobile và các thành phần UI dùng lại.
- [x] Chốt contract package có cấu trúc và quyền Owner/Manager/Client. Cập nhật editor và tóm tắt package.
- [x] Tự tạo campaign và đủ task từ snapshot ngay khi package được chốt. Bảo vệ một campaign mỗi package đã chốt.
- [x] Bỏ luồng /prepare ở web, đọc campaign được tạo khi duyệt package. Hiển thị draft và task sinh sẵn để Manager bổ sung.
- [x] Chuyển bước bắt đầu campaign sang kiểm tra task sẵn có. Giữ duyệt hai bên, version và gate IN_PROGRESS.
- [x] Thêm mô hình, API đọc/tạo subtask, phân quyền và supervisor hiệu lực.
- [x] Thêm thao tác chuyển trạng thái và kiểm tra subtask khi gửi duyệt cha. Giữ approval circle cha.
- [x] Bổ sung danh sách subtask, trạng thái, người phụ trách, deadline và supervisor vào chi tiết task.
- [x] Rà hủy task lớn, Content Request, đếm task, đóng campaign và ranh giới liên kết sản phẩm.
- [x] Chặn đóng campaign nếu còn Content Request đã nhận chưa hoàn thành và hiển thị các request đang chặn.
- [ ] Phủ bảng kiểm hỗ trợ nhập liệu bằng mẫu và dữ liệu sẵn có. Cập nhật locale vi/en.
- [ ] Kiểm tra light/dark, bàn phím, responsive, API và kịch bản end-to-end. Chạy CI.

- [x] Đồng bộ seed SQL/Mongo với schema, trạng thái, thành viên workspace và liên kết task/post hiện tại; kiểm chứng CLI trên DB test riêng.
- [ ] Kiểm tra trình duyệt đầy đủ cho theme, bàn phím, responsive và các luồng người dùng.

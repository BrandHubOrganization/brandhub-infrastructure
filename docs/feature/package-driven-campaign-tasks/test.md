# Kịch bản nghiệm thu

| Kịch bản | Kết quả |
|---|---|
| Owner tạo gói mẫu, Manager tạo gói custom, Client chọn gói mẫu | Đúng quyền từng luồng |
| Chọn bài đăng 3, event 1 | Mỗi dịch vụ một dòng, mở đúng nhóm trường; API từ chối trùng, livestream và số lượng không hợp lệ với gói mới |
| Hai bên duyệt chốt package | Một DRAFT, đúng 4 task lớn, từng task truy về dòng cam kết |
| Duyệt đồng thời hoặc lỗi trong transaction tạo campaign/task | Một campaign, đủ task; khi transaction thất bại phải rollback, không để dữ liệu ghi dở |
| Duyệt một bên rồi cả hai, sau đó bắt đầu campaign | DRAFT → APPROVED → IN_PROGRESS đúng luồng; trước IN_PROGRESS thành viên không thể bắt đầu task kể cả gọi API trực tiếp |
| Manager sửa một task, rồi hủy một task lớn | Snapshot không đổi; chỉ Manager được hủy; không sinh thay thế |
| Client yêu cầu thêm qua Content Request | Task mới không tính vào số lượng gốc |
| Manager thêm subtask; đổi assignee cha | Chặn tầng thứ hai; supervisor mặc định đổi theo, override giữ nguyên |
| Thành viên, supervisor, Manager và Client thao tác | Đúng quyền đọc/chuyển trạng thái; supervisor và Manager có thể chuyển thẳng Done/Cancelled; Client chỉ xem |
| Gửi duyệt cha khi có subtask mở, rồi đưa tất cả về Done/Cancelled | Lần đầu bị chặn và có thông tin xử lý; lần sau đi qua approval circle hiện có |
| Đóng campaign sau khi task lớn đạt điều kiện hiện tại | Đối chiếu đúng tập task gốc; subtask không bị tính như task đầu ra |
| Tất cả task lớn từ package đã kết thúc nhưng còn Content Request đã nhận chưa hoàn thành | Chặn đóng campaign và chỉ rõ request đang chặn |
| Task liên kết của mọi Content Request đã nhận đều Done hoặc Cancelled | Đóng được campaign nếu các điều kiện còn lại đều đạt |
| Kiểm tra toàn bộ form, vi/en, light/dark, responsive | Mọi trường có hỗ trợ theo kiểu dữ liệu, gợi ý chỉnh được và giao diện giữ khả năng thao tác |

## Kiểm chứng seed

Đã chạy CLI seed-postgres và seed-mongo trên DB test riêng, kiểm tra 275 tài liệu Mongo không vi phạm schema. Kiểm tra quick-login có 5 task, 5 subtask và 2 post liên kết. Chạy lại CLI giữ nguyên số lượng theo seed marker; chạy lại quick-login trên workspace đã tồn tại bị từ chối để tránh ghi đè workflow. Các kết quả này không thay cho kiểm tra giao diện trên trình duyệt.

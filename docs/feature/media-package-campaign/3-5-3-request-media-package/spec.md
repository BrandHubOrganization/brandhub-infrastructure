# FR 3.5.3 — Ghi nhận thỏa thuận bên ngoài và chỉnh gói trước triển khai

Cập nhật BA 2026-11-05. Flow Client request-change/Agency counter-offer trong hệ thống đã được thay bằng [hành trình Manager quản lý](../guest-sharing-manager-led/spec.md).

## Mục tiêu

Manager dùng kết quả trao đổi bên ngoài với Client để tạo/cập nhật gói workspace. Khách được xem gói quảng bá và trao đổi với Agency trước khi được mời vào làm việc.

## Tiêu chí nghiệm thu

- Đàm phán/chốt gói diễn ra bên ngoài hệ thống. Không yêu cầu lượt đề xuất, phản hồi hay chấp nhận của Client trên Web.
- Manager chọn gói Agency để tùy chỉnh hoặc nhập mới trong workspace mình quản lý.
- Lưu gói hợp lệ tạo/cập nhật cùng Campaign DRAFT và task theo gói. Không tạo thêm Campaign khi lưu lại.
- Trước triển khai, Manager được sửa gói. Hạng mục không đổi giữ định danh, người phụ trách, giám sát, brief/deadline, subtask và bình luận đã nhập.
- Thêm/giảm/đổi hạng mục phải đồng bộ kế hoạch/task an toàn, hiển thị tác động và lấy xác nhận cần thiết của Manager. Không tự xóa dữ liệu liên quan để khớp số lượng.
- Chặn lưu hoặc triển khai khi có xung đột phiên bản/trạng thái hay chưa đồng bộ xong. Retry không sinh task trùng.
- Từ lúc triển khai cố định bản gói/kế hoạch của lượt đó, cho retry trên cùng bản. Gói đã triển khai được khóa.
- Góp ý của Client về Campaign là comment riêng. Comment không thay điều khoản gói hoặc tạo lượt request-change.
- UI có trường nhập rõ ràng, lựa chọn nhanh hiện hành, lỗi tại trường, xác nhận tác động, vi/en và light/dark.

## Lịch sử và tương thích

Bảo toàn lịch sử đàm phán cũ để truy vết. Cách hiển thị dữ liệu legacy và xử lý endpoint request-change/counter-offer cũ phải được thống nhất khi lập kế hoạch API/DB. Không tạo sự kiện hoặc lượt đồng ý giả cho Client.

# FR 3.5.1 — Tạo gói Agency và gói workspace

Cập nhật BA 2026-11-05, chờ triển khai. Theo [spec hành trình mới](../3-5-6-view-media-campaign/guest-sharing-manager-led/spec.md).

## Mục tiêu và vai trò

Owner tạo gói của Agency để quảng bá. Manager ghi nhận gói thực hiện của workspace sau khi chốt với Client bên ngoài hệ thống. Admin template vẫn thuộc phạm vi quản lý riêng của Admin.

## Tiêu chí nghiệm thu

- Owner tạo gói Agency độc lập với workspace, theo quyền danh mục hiện hành. Có thể tham khảo nguồn mẫu được phép.
- Gói dùng các dịch vụ, mô tả, tiêu chí, tổng sản lượng và đơn vị hiện hành. Ngân sách/thời lượng tùy chọn, có giá trị thì phải hợp lệ.
- Owner xuất nội dung đã lưu thành ảnh/PDF hoặc chia sẻ link guest. Link hiển thị bản Agency mới nhất đã lưu, file là bản tại thời điểm xuất.
- Owner tạo workspace và gán Manager khi chưa có Client. Manager không phải chờ Client tham gia để chuẩn bị gói.
- Manager chọn gói Agency phù hợp để tùy chỉnh hoặc tạo gói workspace mới theo thỏa thuận bên ngoài.
- Gói workspace giữ nội dung riêng. Sửa danh mục Agency không tự sửa gói workspace, Campaign hoặc task.
- Lưu gói workspace hợp lệ tự tạo một Campaign DRAFT và task lớn theo gói. Lưu lại/retry không tạo trùng.
- Manager không cần thêm lượt duyệt Owner hoặc Client để lưu gói. Client xem gói đã ghi nhận sau khi tham gia.
- Có thể chỉnh trước triển khai và đồng bộ an toàn với Campaign/task. Khi triển khai phải cố định bản sử dụng, khóa gói theo spec mới.
- i18n vi/en song song, semantic light/dark, bàn phím và mobile. Trạng thái tải/lưu/trống/lỗi/thiếu quyền rõ ràng.

## Ranh giới

Quyền xuất/share danh mục thuộc Owner. Không biến gói workspace thành gói công khai. Chi tiết API, vòng đời share và mapping dữ liệu cũ sẽ chốt trong plan, không dùng endpoint chọn/duyệt Client cũ làm hợp đồng cho flow mới.

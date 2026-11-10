# FR 3.5.6 — Client góp ý và Manager triển khai Campaign

Cập nhật BA 2026-11-05. Bước duyệt Campaign hai phía đã được thay bằng [flow xem/góp ý và Manager triển khai](../3-5-6-view-media-campaign/guest-sharing-manager-led/spec.md).

## Quyền và góp ý

- Client đã tham gia đúng workspace được xem Campaign DRAFT, IN_PROGRESS và COMPLETED theo quyền xem hiện hành.
- Client được comment góp ý cả khi Campaign còn DRAFT. Lưu người gửi, thời điểm và ngữ cảnh phiên bản đang xem khi có.
- Comment không sửa kế hoạch, không chuyển trạng thái hoặc tạo approval. Manager quyết định xử lý góp ý trong phạm vi trạng thái cho phép.
- Client không có nút approve/reject Campaign hoặc triển khai. Manager không cần chờ Client đồng ý/góp ý xong để triển khai.
- Duyệt kết quả Task/bài đăng tiếp tục theo module Task và không được thay bằng comment Campaign.

## Triển khai

- Manager chủ động triển khai khi gói, kế hoạch, task và thông tin bắt buộc đã hợp lệ/đồng bộ.
- Không còn gate Campaign APPROVED hoặc timestamp duyệt hai phía trong flow mới.
- Lượt triển khai cố định bản gói/kế hoạch được dùng và ngăn sửa đồng thời. Lỗi/gián đoạn cho phép retry trên cùng bản, không ghi đè task hoặc sinh task trùng.
- Campaign chuyển IN_PROGRESS sau khi xác nhận đầy đủ công việc theo gói. Các task đã tồn tại từ khi lưu gói được giữ định danh và thông tin đã nhập.
- Sau triển khai khóa gói/phạm vi kế hoạch. Thành viên bắt đầu công việc theo quyền Task hiện hành.
- Hoàn thành Campaign vẫn do Manager thực hiện với điều kiện closure hiện hành. Request/Task chưa xử lý vẫn là điều kiện chặn theo spec riêng.

## Trạng thái và UX

Vòng đời nghiệp vụ đích là DRAFT → IN_PROGRESS → COMPLETED. Tiến trình deployment/retry được hiển thị riêng. Giao diện Client tập trung kế hoạch, tiến độ và góp ý, dùng vi/en, semantic light/dark, bàn phím/mobile và các trạng thái tải/lỗi/trống/thiếu quyền.

API, trạng thái APPROVED cũ và lịch sử review/approval cần kế hoạch tương thích riêng. Không tự chuyển/xóa dữ liệu trong giai đoạn chỉnh spec.

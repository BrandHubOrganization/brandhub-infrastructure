# FR 3.5.5 — Tự tạo Campaign DRAFT từ gói workspace

Cập nhật BA 2026-11-05, chờ triển khai. Theo [spec hành trình mới](../guest-sharing-manager-led/spec.md) và [package-driven task](../../package-driven-campaign-tasks/spec.md).

## Mục tiêu

Manager lưu gói workspace hợp lệ sẽ có ngay một Campaign DRAFT và task lớn để chuẩn bị thực hiện. Campaign mô tả kế hoạch triển khai của gói đã chốt bên ngoài hệ thống.

## Tiêu chí nghiệm thu

- Tạo workspace chỉ cần Owner/gán Manager theo quy tắc tổ chức, chưa cần Client hoặc Package approval.
- Lần lưu gói workspace hợp lệ đầu tiên tự tạo đúng một Campaign DRAFT cùng task theo dịch vụ/sản lượng của gói.
- Lưu lại/retry/concurrent save sử dụng cùng Campaign/workspace và các định danh task ổn định.
- Campaign/task giữ nguồn gói, liên kết workspace và các dữ liệu cần cho kế hoạch, tổng sản lượng, strategy, timeline và work items hiện hành.
- Manager hoàn thiện các trường còn thiếu sau khi tạo DRAFT. Chỉ ra trường thiếu khi kiểm tra sẵn sàng triển khai.
- Task có thể được chuẩn bị brief, deadline, assignee, supervisor, subtask trong giai đoạn DRAFT. Bắt đầu thực hiện vẫn yêu cầu Campaign IN_PROGRESS.
- Cho phép Manager sửa gói trước triển khai, đồng bộ kế hoạch/task và giữ thông tin đã nhập. Thay đổi ảnh hưởng task phải theo quy tắc đồng bộ an toàn của spec mới.
- Client được mời sau đó xem và góp ý cả bản nháp. Bình luận không làm thay đổi version nội dung kế hoạch hoặc đóng vai trò approval.
- Một workspace có tối đa một Campaign. Chiến dịch mới dùng workspace mới theo quy tắc hiện hành.
- Loading/error/empty/permission/conflict states, key vi/en và light/dark được thiết kế tương ứng.

## Tính nhất quán

Campaign/work items và Mongo Task phải giữ cùng phạm vi gói. Retry không tạo task/Campaign trùng. Nếu ghi một phần thất bại, hệ thống phải thể hiện trạng thái chưa sẵn sàng và phục hồi có kiểm soát trước triển khai.

Các trường/version dùng để chống ghi đè vẫn có thể cần thiết. Không dùng approval hai phía làm điều kiện lưu, đồng bộ hoặc tạo Campaign. Dữ liệu/code/schema hiện tại sẽ được đánh giá ở bước plan.

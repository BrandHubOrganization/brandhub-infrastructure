# Package, campaign và task

> Cập nhật BA 2026-11-05. Phần hành trình Package/Campaign ở đây theo [spec guest sharing và Manager-led](../../3-5-6-view-media-campaign/guest-sharing-manager-led/spec.md). Đây là yêu cầu đích, chưa xác nhận đã triển khai code.

Owner tạo gói mẫu cho Agency và dùng chức năng xuất ảnh/PDF hoặc link guest để quảng bá. Link luôn hiển thị gói mới nhất đã lưu. Owner tạo workspace và gán Manager trước khi cần có Client. Manager chốt gói với Client bên ngoài rồi chọn mẫu để tùy chỉnh hoặc tạo gói workspace mới. Manager không cần Owner duyệt gói custom. Client tham gia sau để xem gói đã ghi nhận. Luồng mới bỏ bước Client chọn, đàm phán và duyệt gói trong hệ thống.

Một gói chọn từ một đến bốn dịch vụ (bài đăng, workshop, event, báo điện tử). Mỗi loại có một dòng, mở phần nhập số lượng, mô tả, tiêu chí khi chọn. Hệ thống lưu tiêu chí để người duyệt kết quả Task đánh giá.

Ngay khi Manager lưu gói workspace hợp lệ, backend tự tạo một Campaign DRAFT và đủ task lớn theo từng dòng dịch vụ/sản lượng. Lưu lại hoặc retry cập nhật cùng Campaign, không sinh trùng. Web đọc Campaign đã tạo. Form đặt ngày bắt đầu mặc định là ngày hiện tại. Manager có thể bổ sung thông tin task và tạo/chỉnh subtask trong Đầu việc dự kiến. Client được xem và comment góp ý cả bản nháp. Campaign được Manager triển khai khi đủ điều kiện, không cần lượt duyệt Campaign của Client hoặc hai phía.

Manager được sửa gói trước triển khai, đồng bộ kế hoạch/task theo phần thay đổi và giữ thông tin đã nhập ở hạng mục còn hiệu lực. Thay đổi tác động tới công việc có dữ liệu phải được xử lý có kiểm soát theo spec Manager-led. Khi triển khai, cố định bản dùng cho lượt triển khai và khóa thay đổi gói/kế hoạch. Thành viên bắt đầu làm task khi Campaign IN_PROGRESS. Manager được hủy task lớn theo quyền hiện hành. Client dùng Content Request để yêu cầu việc mới, không tự sinh task thay thế.

Subtask một cấp, có người phụ trách, deadline, trạng thái và supervisor. Supervisor mặc định theo người phụ trách hiện tại của cha. Manager có thể gán supervisor riêng. Client xem được subtask. Thành viên có quyền thao tác chuyển giữa To Do, In Progress và In Review. Supervisor kế thừa quyền đó và được chuyển sang Done hoặc Cancelled. Manager kế thừa quyền supervisor. In Review là tùy chọn. Task cha được gửi approval circle khi mọi subtask đã Done hoặc Cancelled và hoàn thành theo approval circle hiện tại.

Owner tạo gói Agency và Manager tạo/chỉnh gói workspace có lựa chọn nhanh cho thời lượng, ngân sách, số lượng. Phạm vi, mô tả và tiêu chí có mẫu và lựa chọn Khác. Đơn vị hiển thị cạnh nhãn số lượng. Campaign có mẫu chiến lược và lựa chọn Khác, bỏ trường hướng dẫn thương hiệu trên web. Giao diện kiểm tra sẵn sàng triển khai nêu chính xác các trường thiếu. Hỗ trợ vi/en, light/dark, tải, lỗi, trống và thiếu quyền.

Campaign chỉ được đóng khi thỏa điều kiện hiện có và tất cả Content Request đã nhận thuộc campaign đã xử lý xong. Request ở trạng thái ACCEPTED được xem là đã xử lý khi task sinh từ request ở Done hoặc Cancelled. Request đã nhận còn dang dở chặn đóng campaign, kể cả khi tất cả task lớn từ package đã kết thúc.

Phạm vi dừng ở package, campaign, task và subtask. Post/event/workshop tiếp tục gắn với task lớn. Mô hình, nghiệp vụ và đầu ra từng dịch vụ thuộc phần của các thành viên khác.

Task lớn mới tạo được gán cả người thực hiện và người giám sát cho Manager. Manager có thể đổi từng trường sang thành viên nội bộ đang hoạt động trong workspace. Subtask cũng chỉ được gán cho thành viên nội bộ đang hoạt động trong workspace. Khi người thực hiện đồng thời là người giám sát, bỏ qua bước duyệt nội bộ; vẫn giữ bước duyệt Client nếu được yêu cầu. Bài đăng phải được duyệt trước khi chuyển sang trạng thái lên lịch; tác vụ xuất bản không được tự hoàn thành task chưa được duyệt.


## Campaign Timeline update (2026-11-07)

The approved [Campaign Timeline specification](../../../3-6-content-task-workflow/3-6-6-gantt-timeline-task-view/campaign-timeline/spec.md) supersedes the default supervisor rule above for newly created Tasks/subtasks: supervisor defaults to the creating member. Existing rows retain their prior inheritance behavior. Planned start defaults to today in the Workspace timezone and missing deadline to two calendar days later; planned dates do not change actual workflow start history.

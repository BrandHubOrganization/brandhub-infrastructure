# Kế hoạch triển khai

## 1. Package và hỗ trợ nhập liệu

Tái sử dụng PackageDeliverable, offeringDetails và snapshot điều khoản. Kiểm tra server cho gói mới/chỉnh sửa về loại hợp lệ, mỗi loại tối đa một dòng, số lượng nguyên dương và ít nhất một dịch vụ. Đối chiếu quyền tạo gói Agency và custom ở API. Dùng cùng OfferingEditor cho các màn hình phù hợp. Chỉ dùng enum hiện tại; dữ liệu hoặc validator cũ phải được sửa trước khi sử dụng. Rà các nguồn gọi web/mobile trước khi đổi hợp đồng.

## 2. Khởi tạo campaign và task lớn

Tách thao tác từ package đã chốt với thao tác bắt đầu campaign đã duyệt. Luồng duyệt chốt package tự tạo draft từ phiên bản điều khoản đã chốt, một work item cố định cho mỗi đơn vị dịch vụ. Lưu quan hệ với ID dòng dịch vụ và dùng ID task ổn định như CampaignTaskStore hiện có. Work item phục vụ việc đối chiếu số lượng và duyệt campaign. Task phục vụ thực thi. Chọn một nguồn cho các trường kế hoạch có thể sửa, tránh hai form ghi hai bản khác nhau.

Tạo campaign và manifest trong transaction SQL của lần duyệt chốt package. Ghi đủ task Mongo theo batch transaction và ID cố định; nếu SQL rollback thì bù xóa batch Mongo vừa tạo. Ràng buộc duy nhất bảo vệ một campaign mỗi package. Kiểm tra đủ task khi duyệt campaign. Web đọc dữ liệu đã tạo và báo lỗi nếu thiếu, không gọi /prepare hoặc tự vá dữ liệu cũ.

Giữ DRAFT → APPROVED → IN_PROGRESS → COMPLETED. Giữ điều kiện duyệt và phiên bản hiện có. Rà ràng buộc due date của CampaignWorkItem và TaskSchemaGuard để hỗ trợ draft chưa điền, kiểm tra các trường bắt buộc hiện có trước khi duyệt. Bước bắt đầu xác minh task và phiên bản đã duyệt. Dùng gate IN_PROGRESS phía server cho thao tác thực thi, tách khỏi quyền Manager chuẩn bị task.

## 3. Subtask và vòng đời

Bổ sung parentTaskId và supervisorOverrideId tùy chọn. Lưu subtask trong tài liệu task cha để giữ đúng một cấp và tách khỏi tập task đầu ra dùng để đếm, đóng campaign và gắn sản phẩm. Supervisor hiệu lực là override nếu có, nếu không thì lấy assignee hiện tại của cha. Client đọc theo quyền hiện có. Hiển thị Done cho FINISHED. Giữ API duyệt chính cho task lớn, dùng luồng duyệt task chung cho các task campaign không phải post. Thực thi quyền chuyển trạng thái và kiểm tra toàn bộ subtask khi submit ở server. Dùng cùng khóa điều khoản campaign khi chuyển trạng thái, thêm subtask và gửi duyệt.

Rà CampaignDeploymentProcessor, CampaignClosureService và summary. Đối chiếu số lượng theo tập task lớn sinh từ package. Tách subtask và Content Request khỏi tập đối chiếu. Giữ điều kiện đóng campaign hiện có đối với task lớn và request. Tái sử dụng luồng hủy task lớn với quyền Manager. Các thao tác gắn sản phẩm kiểm tra đối tượng là task lớn tại ranh giới chung, phối hợp tại điểm tích hợp khi cần.

Kiểm tra điều kiện đóng ở backend theo Content Request đã nhận thuộc campaign. Với request ACCEPTED, kiểm tra task đã sinh ở Done hoặc Cancelled. Trả danh sách request còn dang dở để Manager biết việc cần xử lý.

## 4. Web và kiểm chứng

Tham khảo các màn hình đang dùng như OfferingEditor, CampaignForm, TaskDetailPanel, TaskAssigneePicker, ContentRequestTable và bộ chọn ngày hiện có. Dùng thành phần và token chung, bố cục form rộng hiện tại, cập nhật các namespace mediaPackage, campaign và tasks tương ứng ở cả locales vi/en. Kiểm tra trạng thái lỗi, focus bàn phím, theme và responsive. Lập bảng kiểm tất cả trường nhập theo màn hình, nguồn gợi ý và cách điền/chỉnh.

Rà hợp đồng mobile nếu client dùng API thay đổi. Kiểm tra backend, luồng web và chạy npm run ci. Mongo đang dùng Atlas. Kiểm chứng seed bằng database test tách biệt với schema hiện tại; không tự reset database chính. Seed mới dùng DATASET_VERSION=3 và marker mongo-dev-v2, từ chối dataset cũ thay vì tự chuyển đổi. Các CLI seed và luồng quick-login đã được kiểm tra trên database test riêng.

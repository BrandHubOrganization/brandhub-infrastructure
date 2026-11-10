# Đặc tả Chức năng: Publish Threads Post (FR 3.8.15)

## 1. Tổng quan
- **Mã chức năng**: FR 3.8.15
- **Tên chức năng**: Publish Threads Post
- **Mô tả**: Đẩy bài đăng lên mạng xã hội trên Threads
- **Phân hệ**: Hệ thống BrandHub Platform

## 2. Tác nhân & Phân quyền
- **Tác nhân chính**: Scheduler (Job)
- **Quyền hạn**: Người dùng đã được xác thực có vai trò phù hợp trong Workspace / Hệ thống.

## 3. Luồng nghiệp vụ
1. Người dùng truy cập màn hình `Publish Threads Post Page`.
2. Hệ thống kiểm tra quyền hạn và trạng thái của người dùng.
3. Người dùng kích hoạt hành động `Publish Threads Post`.
4. Hệ thống tiếp nhận qua `POST /{targetId}/threads_publish`, thực thi kiểm tra và xử lý dữ liệu.
5. Hệ thống trả về kết quả `ApiResponse` và giao diện cập nhật trạng thái tương ứng.

## 4. Quy tắc nghiệp vụ (Business Rules)
- Yêu cầu xác thực tài khoản qua JWT Token hợp lệ trên tất cả các request.
- Dữ liệu đầu vào phải tuân thủ nghiêm ngặt định dạng và ràng buộc nghiệp vụ.
- Đảm bảo tính toàn vẹn dữ liệu trong các thao tác ghi nhận hoặc cập nhật.

## 5. Tiêu chí nghiệm thu (Acceptance Criteria)
- [x] Giao diện hiển thị đúng và trực quan trên Web Dashboard.
- [x] API thực thi ổn định, trả về đúng mã trạng thái HTTP và cấu trúc DTO `ApiResponse`.
- [x] Xử lý đầy đủ các kịch bản lỗi (400, 401, 403, 404, 500) với thông báo thân thiện.

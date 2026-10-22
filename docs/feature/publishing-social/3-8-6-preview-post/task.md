# Task — Schedule Platform Post (FR 3.8.6)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `PostController` (`POST /api/v1/workspaces/{workspaceId}/posts/{postId}/schedule`)
- [x] Cài đặt nghiệp vụ tại `PostServiceImpl.postDoc.setStatus()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`200 OK (ApiResponse { data: scheduleResponse }`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/schedule`
- [x] Cập nhật giao diện tại `SchedulePostModal / Calendar (UI)` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

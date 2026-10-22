# Task — View Dashboard Post (FR 3.8.3)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `PostController` (`GET /api/v1/workspaces/{workspaceId}/posts/dashboard`)
- [x] Cài đặt nghiệp vụ tại `PostServiceImpl.processRequest()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`200 OK (ApiResponse { data: dashboardData }`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `GET /api/v1/workspaces/{workspaceId}/posts/dashboard`
- [x] Cập nhật giao diện tại `PostDashboardResponse` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

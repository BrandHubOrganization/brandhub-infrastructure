# Task — Track Post Status (FR 3.8.7)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `PostController` (`GET /api/v1/workspaces/{workspaceId}/posts/{postId}/status`)
- [x] Cài đặt nghiệp vụ tại `PostServiceImpl.mapToStepperProgress()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`200 OK (ApiResponse { data: trackingData }`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/status`
- [x] Cập nhật giao diện tại `PostStatusBadge / TrackingModal (UI)` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

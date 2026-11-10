# Task — Check Compliance Content (FR 3.6.33)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `ContentCheckController` (`POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/compliance-check`)
- [x] Cài đặt nghiệp vụ tại `ContentCheckService.processRequest()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`ApiResponse`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/compliance-check`
- [x] Cập nhật giao diện tại `Check Compliance Content Page` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

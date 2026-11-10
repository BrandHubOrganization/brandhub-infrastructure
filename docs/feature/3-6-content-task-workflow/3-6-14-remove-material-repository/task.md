# Task — Remove Material Repository (FR 3.6.14)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `MaterialController` (`DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId}`)
- [x] Cài đặt nghiệp vụ tại `MaterialService.Confirm removal()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`ApiResponse`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId}`
- [x] Cập nhật giao diện tại `Remove Material Repository Page` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

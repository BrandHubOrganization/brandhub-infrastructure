# Task — Generate Image (FR 3.7.5)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `AiGenerationController` (`POST /api/v2/ai/image/commercial/generate`)
- [x] Cài đặt nghiệp vụ tại `AiServiceClient.processRequest()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`imageUrl, creditsUsed=1, remainingCredits`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `POST /api/v2/ai/image/commercial/generate`
- [x] Cập nhật giao diện tại `ImageGeneratorUI` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

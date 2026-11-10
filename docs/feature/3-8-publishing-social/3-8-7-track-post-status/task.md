# Task — Publish Facebook Post (FR 3.8.8)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `ApiController` (`POST https://graph.facebook.com/v26.0/{pageId}/feed`)
- [x] Cài đặt nghiệp vụ tại `FacebookPublishAdapter (Publisher Service).consume()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`200 OK`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `POST https://graph.facebook.com/v26.0/{pageId}/feed`
- [x] Cập nhật giao diện tại `Publish Facebook Post Page` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

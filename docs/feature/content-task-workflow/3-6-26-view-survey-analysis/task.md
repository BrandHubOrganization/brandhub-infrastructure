# Task — View Survey Analysis (FR 3.6.26)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Triển khai API Contract tại `SurveyTaskController` (`GET /api/v1/workspaces/{wId}/tasks/{taskId}/survey/analysis`)
- [x] Cài đặt nghiệp vụ tại `SurveyTaskServiceImpl.aggregateMetrics()`
- [x] Tích hợp truy vấn và ràng buộc dữ liệu tại các Repository liên quan
- [x] Định nghĩa DTO request/response (`200 OK (Aggregated metrics, question breakdowns, chart datasets`) chuẩn RESTful

## Frontend — `brandhub-web-dashboard`

- [x] Tích hợp API service client gọi `GET /api/v1/workspaces/{wId}/tasks/{taskId}/survey/analysis`
- [x] Cập nhật giao diện tại `SurveyAnalysisDashboard (UI)` xử lý trạng thái loading, dữ liệu thật và báo lỗi
- [x] Đồng bộ thông báo toast/modal phản hồi tương tác người dùng

## Verify

- [x] `mvn test` pass cho các test suite liên quan
- [x] `tsc --noEmit` pass trên frontend
- [x] Kiểm thử luồng tích hợp Happy Path và Error Handling

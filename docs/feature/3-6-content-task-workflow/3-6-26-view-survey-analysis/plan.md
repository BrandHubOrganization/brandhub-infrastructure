# Plan — View Survey Analysis (FR 3.6.26)

> Liên kết: [spec.md](spec.md) — Coi kết quả tổng quát của khảo sát.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `SurveyTaskServiceImpl.aggregateMetrics()` |
| File đã có | `SurveyTaskController` (`GET /api/v1/workspaces/{wId}/tasks/{taskId}/survey/analysis`), `200 OK (Aggregated metrics, question breakdowns, chart datasets` |

## 2. API Contract (final)

```
GET /api/v1/workspaces/{wId}/tasks/{taskId}/survey/analysis
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK (Aggregated metrics, question breakdowns, chart datasets>
```

- Endpoint phục vụ nghiệp vụ `View Survey Analysis` cho Actor `Creator / Client / Manager`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK (Aggregated metrics, question breakdowns, chart datasets` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `surveyanalysisresponses` qua `SurveyResponseRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `SurveyTaskServiceImpl` thực thi logic nghiệp vụ trọng tâm `aggregateMetrics()`.
4. Tương tác với `SurveyResponseRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK (Aggregated metrics, question breakdowns, chart datasets` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của View Survey Analysis |

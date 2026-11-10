# Plan — View Image Style Template (FR 3.7.4)

> Liên kết: [spec.md](spec.md) — Hệ thống gợi ý các template mẫu như phong cách anime, mùa xuân, hồi ức,...
cho người dùng để tọa ra các Image với các phong cách mà không cần phải mô tả nhiều..

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `AiServiceClient.processRequest()` |
| File đã có | `AiGenerationController` (`GET /api/v1/ai/templates/{templateId}`), `ImageStyleTemplateDetailResponse` |

## 2. API Contract (final)

```
GET /api/v1/ai/templates/{templateId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<ImageStyleTemplateDetailResponse>
```

- Endpoint phục vụ nghiệp vụ `View Image Style Template` cho Actor `Creator`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ImageStyleTemplateDetailResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `aimicroservices` qua `BusinessRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `AiServiceClient` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `BusinessRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ImageStyleTemplateDetailResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của View Image Style Template |

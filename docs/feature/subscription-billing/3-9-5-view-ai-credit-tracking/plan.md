# Plan — View AI Credit Tracking (FR 3.9.5)

> Liên kết: [spec.md](spec.md) — Giám sát lượng credit mà CREATOR đã sử dụng cho các tính năng AI trong tháng (tạo ảnh, tạo content, tạo video).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `BillingService.processRequest()` |
| File đã có | `BillingController` (`GET /api/v1/billing/credits/usage`), `ApiResponse` |

## 2. API Contract (final)

```
GET /api/v1/billing/credits/usage
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `View AI Credit Tracking` cho Actor `USER (self) / OWNER (managed
Agency)`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `AgencyRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `BillingService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `AgencyRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của View AI Credit Tracking |

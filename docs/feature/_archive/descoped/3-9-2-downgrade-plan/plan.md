# Plan — Downgrade Plan (FR 3.9.2)

> Liên kết: [spec.md](spec.md) — Huỷ gói khi người dùng không còn nhu cầu sử dụng nữa.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `SubscriptionService.processRequest()` |
| File đã có | `SubscriptionController` (`POST /api/v1/subscription/cancel`), `ApiResponse` |

## 2. API Contract (final)

```
POST /api/v1/subscription/cancel
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Downgrade Plan` cho Actor `USER (own account)`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `UserSubscriptionRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `SubscriptionService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `UserSubscriptionRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Downgrade Plan |

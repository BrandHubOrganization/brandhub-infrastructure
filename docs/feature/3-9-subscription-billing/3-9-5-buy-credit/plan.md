# Plan — Buy Credit (FR 3.9.6)

> Liên kết: [spec.md](spec.md) — Mua thêm creadit để tiếp tục sử dụng tính năng AI khi sử dụng hết creadit có trong các gói Pro/Enterprise.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `BillingService.processRequest()` |
| File đã có | `BillingController` (`POST /api/v1/billing/credits/buy`), `ApiResponse` |

## 2. API Contract (final)

```
POST /api/v1/billing/credits/buy
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Buy Credit` cho Actor `USER (owned budget)`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `AiCreditAccountRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `BillingService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `AiCreditAccountRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Buy Credit |

# Plan — Make Payment (PayOs) (FR 3.9.3)

> Liên kết: [spec.md](spec.md) — Tính năng tạo Transaction cho các tính năng nâng gói, mua thêm creadit (tuân thủ ACID).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `BusinessService.processRequest()` |
| File đã có | `ApiController` (`GET /api/v1/billing/transactions/{transactionId}`), `Return from checkout / Check Status` |

## 2. API Contract (final)

```
GET /api/v1/billing/transactions/{transactionId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<Return from checkout / Check Status>
```

- Endpoint phục vụ nghiệp vụ `Make Payment (PayOs)` cho Actor `USER (own order), USER (own order), USER (own order)`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `Return from checkout / Check Status` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `PaymentReceiptRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `BusinessService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `PaymentReceiptRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `Return from checkout / Check Status` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Make Payment (PayOs) |

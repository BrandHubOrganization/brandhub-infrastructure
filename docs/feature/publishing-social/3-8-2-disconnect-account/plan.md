# Plan — Disconnect Account (FR 3.8.2)

> Liên kết: [spec.md](spec.md) — Khi đã connect tài khoản thì có thể ngắt tài khoản để log out mạng xã hội.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `SocialAccountServiceImpl.processRequest()` |
| File đã có | `SocialAccountController` (`DELETE /me/permissions`), `19: return 200 OK (ApiResponse { success: true }` |

## 2. API Contract (final)

```
DELETE /me/permissions
Authorization: Bearer <access-token>
→ 200 ApiResponse<19: return 200 OK (ApiResponse { success: true }>
```

- Endpoint phục vụ nghiệp vụ `Disconnect Account` cho Actor `Client`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `19: return 200 OK (ApiResponse { success: true }` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `socialaccountdocuments` qua `SocialAccountMongoRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `SocialAccountServiceImpl` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `SocialAccountMongoRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `19: return 200 OK (ApiResponse { success: true }` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Disconnect Account |

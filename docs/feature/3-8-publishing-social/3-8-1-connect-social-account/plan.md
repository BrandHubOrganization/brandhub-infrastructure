# Plan — Connect Social Account (FR 3.8.1)

> Liên kết: [spec.md](spec.md) — Kết nối tài khoản này cho client thực hiện để login vào trong toàn bộ các tài khoản đăng bài tự động.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `MetaOAuthService.authorizes permissions()` |
| File đã có | `SocialOAuthController` (`GET /api/v1/oauth/social/callback?code=...&state=...`), `ApiResponse` |

## 2. API Contract (final)

```
GET /api/v1/oauth/social/callback?code=...&state=...
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Connect Social Account` cho Actor `User, User, User`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `meta graph apis` qua `BusinessRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `MetaOAuthService` thực thi logic nghiệp vụ trọng tâm `authorizes permissions()`.
4. Tương tác với `BusinessRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Connect Social Account |

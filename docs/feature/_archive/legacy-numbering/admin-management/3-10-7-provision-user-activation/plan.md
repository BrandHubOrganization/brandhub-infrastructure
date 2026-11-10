# Plan — Create User (FR 3.10.7)

> Liên kết: [spec.md](spec.md) — Tạo USER mới vào hệ thống.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `AdminUserService.processRequest()` |
| File đã có | `AdminUserController` (`POST /api/v1/admin/users/provision`), `UserProvisionResponse` |

## 2. API Contract (final)

```
POST /api/v1/admin/users/provision
Authorization: Bearer <access-token>
→ 200 ApiResponse<UserProvisionResponse>
```

- Endpoint phục vụ nghiệp vụ `Create User` cho Actor `Admin`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `UserProvisionResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `entitys` qua `UserRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `AdminUserService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `UserRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `UserProvisionResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Create User |

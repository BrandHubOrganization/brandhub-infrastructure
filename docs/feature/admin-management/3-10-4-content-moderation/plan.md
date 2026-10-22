# Plan — Content Moderation Queue (FR 3.10.4)

> Liên kết: [spec.md](spec.md) — Hiển thị các content do CREATOR tạo ra bị dính vào chính sách kiểm duyệt của hệ thống, ADMIN có thể check lại để xem quyết định của hệ thống có đúng hay không.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ModerationService.processRequest()` |
| File đã có | `ModerationController` (`PATCH /api/v1/admin/moderation/{contentId}`), `ModerationResponse` |

## 2. API Contract (final)

```
PATCH /api/v1/admin/moderation/{contentId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<ModerationResponse>
```

- Endpoint phục vụ nghiệp vụ `Content Moderation Queue` cho Actor `Admin`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ModerationResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `entitys` qua `ContentRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `ModerationService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `ContentRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ModerationResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Content Moderation Queue |

# Plan — Push Notification (FR 3.10.1)

> Liên kết: [spec.md](spec.md) — Tạo thông báo toàn hệ thống, có phân chia các user.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `NotificationService.processRequest()` |
| File đã có | `NotificationController` (`POST /api/v1/notifications/send`), `NotificationResponse` |

## 2. API Contract (final)

```
POST /api/v1/notifications/send
Authorization: Bearer <access-token>
→ 200 ApiResponse<NotificationResponse>
```

- Endpoint phục vụ nghiệp vụ `Push Notification` cho Actor `System/Event`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `NotificationResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `entitys` qua `NotificationRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `NotificationService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `NotificationRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `NotificationResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Push Notification |

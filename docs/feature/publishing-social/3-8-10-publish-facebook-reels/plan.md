# Plan — Publish Facebook Reels (FR 3.8.10)

> Liên kết: [spec.md](spec.md) — Đẩy lên những video Reels lên Facebook.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `SchedulerService.publish()` |
| File đã có | `ApiController` (`POST /{pageId}/videos`), `ApiResponse` |

## 2. API Contract (final)

```
POST /{pageId}/videos
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Publish Facebook Reels` cho Actor `Scheduler (Job)`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `rabbitmqs` qua `PostRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `SchedulerService` thực thi logic nghiệp vụ trọng tâm `publish()`.
4. Tương tác với `PostRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Publish Facebook Reels |

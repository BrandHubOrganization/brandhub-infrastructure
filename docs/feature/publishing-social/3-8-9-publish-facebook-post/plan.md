# Plan — Publish Facebook Story (FR 3.8.9)

> Liên kết: [spec.md](spec.md) — Bài đăng đẩy lên Story của Facebook.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `PublishCallbackConsumer (Business Service).consume()` |
| File đã có | `ApiController` (`POST https://graph.facebook.com/v26.0/{pageId}/photo_stories`), `200 OK` |

## 2. API Contract (final)

```
POST https://graph.facebook.com/v26.0/{pageId}/photo_stories
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK>
```

- Endpoint phục vụ nghiệp vụ `Publish Facebook Story` cho Actor `Scheduler (Job)`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `rabbitmq (brandhub.publishing)s` qua `PostMongoRepository (Business Service)`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `PublishCallbackConsumer (Business Service)` thực thi logic nghiệp vụ trọng tâm `consume()`.
4. Tương tác với `PostMongoRepository (Business Service)` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Publish Facebook Story |

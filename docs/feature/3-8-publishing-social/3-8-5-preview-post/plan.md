# Plan — Schedule Platform Post (FR 3.8.6)

> Liên kết: [spec.md](spec.md) — Trang hiển thị lịch đăng bài mà có thể coi những bài đó ở trong lịch cụ thể.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `PostServiceImpl.postDoc.setStatus()` |
| File đã có | `PostController` (`POST /api/v1/workspaces/{workspaceId}/posts/{postId}/schedule`), `200 OK (ApiResponse { data: scheduleResponse }` |

## 2. API Contract (final)

```
POST /api/v1/workspaces/{workspaceId}/posts/{postId}/schedule
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK (ApiResponse { data: scheduleResponse }>
```

- Endpoint phục vụ nghiệp vụ `Schedule Platform Post` cho Actor `Creator / Manager`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK (ApiResponse { data: scheduleResponse }` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `postscheduleresponses` qua `PostMongoRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `PostServiceImpl` thực thi logic nghiệp vụ trọng tâm `postDoc.setStatus()`.
4. Tương tác với `PostMongoRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK (ApiResponse { data: scheduleResponse }` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Schedule Platform Post |

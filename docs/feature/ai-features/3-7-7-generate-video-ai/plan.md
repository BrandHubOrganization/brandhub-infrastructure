# Plan — Generate Video (FR 3.7.7)

> Liên kết: [spec.md](spec.md) — Sử dụng LLM và promt để tạo ra Image cho bài post.
Sử dụng các API gen video 3th party.
Có thể mở rộng thành studio..

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `AiVideoService.processRequest()` |
| File đã có | `AiFeatureController` (`POST /ai/generate-video`), `AiVideoResponse` |

## 2. API Contract (final)

```
POST /ai/generate-video
Authorization: Bearer <access-token>
→ 200 ApiResponse<AiVideoResponse>
```

- Endpoint phục vụ nghiệp vụ `Generate Video` cho Actor `User`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `AiVideoResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `entitys` qua `PostRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `AiVideoService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `PostRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `AiVideoResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Generate Video |

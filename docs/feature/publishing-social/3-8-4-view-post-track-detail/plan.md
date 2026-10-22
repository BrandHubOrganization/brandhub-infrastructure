# Plan — View Posted Detail (FR 3.8.4)

> Liên kết: [spec.md](spec.md) — Trang hiển thị bài đăng thành công có thể coi chi tiết bài đăng và tổng số reactions tương tác và comment bài đăng đó ví dụ như: count reaction, comment, share.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `PostServiceImpl.getPostTrackDetail()` |
| File đã có | `PostController` (`GET /{platformPostId}?fields=reactions.summary`), `200 OK (ApiResponse { data: trackDetailResponse }` |

## 2. API Contract (final)

```
GET /{platformPostId}?fields=reactions.summary
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK (ApiResponse { data: trackDetailResponse }>
```

- Endpoint phục vụ nghiệp vụ `View Posted Detail` cho Actor `Member / Manager`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK (ApiResponse { data: trackDetailResponse }` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `posttrackdetailresponses` qua `PostMongoRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `PostServiceImpl` thực thi logic nghiệp vụ trọng tâm `getPostTrackDetail()`.
4. Tương tác với `PostMongoRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK (ApiResponse { data: trackDetailResponse }` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của View Posted Detail |

# Plan — View Dashboard Post (FR 3.8.3)

> Liên kết: [spec.md](spec.md) — Hiển thị bảng trang tổng quát ở trong workspace khi mà đã đăng thành công bài post lên mạng xã hội.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `PostServiceImpl.processRequest()` |
| File đã có | `PostController` (`GET /api/v1/workspaces/{workspaceId}/posts/dashboard`), `200 OK (ApiResponse { data: dashboardData }` |

## 2. API Contract (final)

```
GET /api/v1/workspaces/{workspaceId}/posts/dashboard
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK (ApiResponse { data: dashboardData }>
```

- Endpoint phục vụ nghiệp vụ `View Dashboard Post` cho Actor `«Actor»
Member / Manager`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK (ApiResponse { data: dashboardData }` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `postdashboardresponses` qua `PostMongoRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `PostServiceImpl` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `PostMongoRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK (ApiResponse { data: dashboardData }` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của View Dashboard Post |

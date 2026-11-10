# Plan — Download Material (FR 3.6.16)

> Liên kết: [spec.md](spec.md) — Toàn bộ người dùng có thể download tài liệu từ workspace về máy local để lưu trữ hoặc với mục đích khác dùng cho chỉnh sửa.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `MaterialService.processRequest()` |
| File đã có | `MaterialController` (`GET /api/v1/workspaces/{workspaceId}/materials/{materialId}/download`), `ApiResponse` |

## 2. API Contract (final)

```
GET /api/v1/workspaces/{workspaceId}/materials/{materialId}/download
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Download Material` cho Actor `CREATOR / CLIENT / MANAGER`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `WorkspaceRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `MaterialService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `WorkspaceRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Download Material |

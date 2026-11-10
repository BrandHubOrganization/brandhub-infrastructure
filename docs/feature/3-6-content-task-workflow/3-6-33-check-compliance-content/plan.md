# Plan — Check Compliance Content (FR 3.6.33)

> Liên kết: [spec.md](spec.md) — Check đạo văn. bạo lưc, hình ảnh dung tục. Phần này sử dụng API kéo về để cho ra kết quả chuẩn nhất, có bảng phân tích từ ngữ, các đoạn không đúng đàn hoàn, giúp cho người làm việc hiểu được và có thể fix các lỗi để không vi phạm các nọi dung của nền tàng hoặc không lên được trending.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ContentCheckService.processRequest()` |
| File đã có | `ContentCheckController` (`POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/compliance-check`), `ApiResponse` |

## 2. API Contract (final)

```
POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/compliance-check
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Check Compliance Content` cho Actor `CREATOR / CLIENT / MANAGER`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `WorkspaceRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `ContentCheckService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `WorkspaceRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Check Compliance Content |

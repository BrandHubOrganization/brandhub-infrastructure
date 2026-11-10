# Plan — Suggest hashtag trend (FR 3.7.10)

> Liên kết: [spec.md](spec.md) — Ở 2 chỗ: gợi ý hashtag trend cho content creator khi viết content và khi add hashtag collection thì recommend các hashtag để các thành viên có thêm vào.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `AiHashtagService.processRequest()` |
| File đã có | `AiHashtagController` (`POST /api/v1/ai/suggest-hashtags`), `ApiResponse` |

## 2. API Contract (final)

```
POST /api/v1/ai/suggest-hashtags
Authorization: Bearer <access-token>
→ 200 ApiResponse<ApiResponse>
```

- Endpoint phục vụ nghiệp vụ `Suggest hashtag trend` cho Actor `OWNER / MANAGER / CREATOR`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `ApiResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `web dashboards` qua `WorkspaceRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `AiHashtagService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `WorkspaceRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `ApiResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Suggest hashtag trend |

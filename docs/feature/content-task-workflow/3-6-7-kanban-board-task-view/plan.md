# Plan — Kanban Board Task View (FR 3.6.7)

> Liên kết: [spec.md](spec.md) — Làm giống kiểu board kéo thả trạng thái công việc trong jira (làm thêm 3 kiểu view board).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `TaskServiceImpl.processRequest()` |
| File đã có | `TaskController` (`GET /api/v1/resource`), `200 OK (Updated task status` |

## 2. API Contract (final)

```
GET /api/v1/resource
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK (Updated task status>
```

- Endpoint phục vụ nghiệp vụ `Kanban Board Task View` cho Actor `Creator / Client / Manager`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK (Updated task status` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `taskkanbanresponses` qua `TaskRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `TaskServiceImpl` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `TaskRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK (Updated task status` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Kanban Board Task View |

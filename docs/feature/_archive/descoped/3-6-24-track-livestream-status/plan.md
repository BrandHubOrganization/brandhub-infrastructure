# Plan — Track Livestream Status (FR 3.6.24)

> Liên kết: [spec.md](spec.md) — Hiển thị tiến độ của Live Stream.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `LivestreamTaskServiceImpl.transitionLivestreamStatus()` |
| File đã có | `LivestreamTaskController` (`PATCH /api/v1/workspaces/{wId}/tasks/{taskId}/livestream/status`), `200 OK (Updated livestream status` |

## 2. API Contract (final)

```
PATCH /api/v1/workspaces/{wId}/tasks/{taskId}/livestream/status
Authorization: Bearer <access-token>
→ 200 ApiResponse<200 OK (Updated livestream status>
```

- Endpoint phục vụ nghiệp vụ `Track Livestream Status` cho Actor `Manager / Creator`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `200 OK (Updated livestream status` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `livestreamidearesponses` qua `TaskRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `LivestreamTaskServiceImpl` thực thi logic nghiệp vụ trọng tâm `transitionLivestreamStatus()`.
4. Tương tác với `TaskRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `200 OK (Updated livestream status` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Track Livestream Status |

# Plan — Export Report File PDF (FR 3.10.12)

> Liên kết: [spec.md](spec.md) — xuất báo cáo cho các trang quản lí User, Revenue, ... dạng PDF.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ReportService.processRequest()` |
| File đã có | `ReportController` (`GET /api/v1/admin/reports/{reportId}/download`), `Content-Disposition: attachment` |

## 2. API Contract (final)

```
GET /api/v1/admin/reports/{reportId}/download
Authorization: Bearer <access-token>
→ 200 ApiResponse<Content-Disposition: attachment>
```

- Endpoint phục vụ nghiệp vụ `Export Report File PDF` cho Actor `Admin`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `Content-Disposition: attachment` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `entitys` qua `ReportRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `ReportService` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `ReportRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `Content-Disposition: attachment` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Export Report File PDF |

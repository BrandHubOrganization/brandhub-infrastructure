# Plan — System Health Monitoring (FR 3.10.3)

> Liên kết: [spec.md](spec.md) — Hiển thị cho ADMIN xem Server tại thời điểm đó đang tiêu tốn tài nguyên như thế nào(%CPU, %RAM, ...) trong hệ thống microservice và server đó có còn đang sống không.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `HealthQueryService.evaluateDependencyUptime()` |
| File đã có | `MonitoringHealthController` (`GET /api/monitoring/health-targets`), `HealthTargetsResponse` |

## 2. API Contract (final)

```
GET /api/monitoring/health-targets
Authorization: Bearer <access-token>
→ 200 ApiResponse<HealthTargetsResponse>
```

- Endpoint phục vụ nghiệp vụ `System Health Monitoring` cho Actor `ADMIN, Admin, Admin`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `HealthTargetsResponse` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `monitoringservers` qua `ServerMetricsRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `HealthQueryService` thực thi logic nghiệp vụ trọng tâm `evaluateDependencyUptime()`.
4. Tương tác với `ServerMetricsRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `HealthTargetsResponse` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của System Health Monitoring |

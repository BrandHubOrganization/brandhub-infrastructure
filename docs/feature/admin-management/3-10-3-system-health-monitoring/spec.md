# UC — System Health Monitoring

| | |
|---|---|
| FR Code | 3.10.3 |
| Feature | System Health Monitoring |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị Server tại thời điểm hiện tại đang tiêu tốn tài nguyên như thế nào (%CPU, %RAM...) trong hệ thống microservice và server đó có còn sống không.

## 2. User Story

Là một Admin,
tôi muốn xem tình trạng health của các microservice,
để phát hiện sớm sự cố hệ thống.

## 3. Acceptance Criteria

- Hiển thị mỗi service: trạng thái (UP/DOWN), %CPU, %RAM, uptime.
- Auto-refresh định kỳ (ví dụ mỗi 30s) hoặc real-time qua WebSocket.

## 4. UI / UX

- Trang Admin `/admin/system-health`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/system-health
→ 200 { "success": true, "data": [{ "serviceName", "status", "cpuPercent", "ramPercent", "uptime" }] }
```

## 6. Error Handling

- 1 service không phản hồi (down thật) → hiển thị `status=DOWN`, không throw lỗi toàn trang.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng health từng service theo thời gian thực/gần thực.

## Out of Scope

- Không có.

## Tham chiếu BA

[09_Admin_Management.md](../../../BA/09_Admin_Management.md)

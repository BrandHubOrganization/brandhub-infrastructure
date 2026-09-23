# UC — Push Notification

| | |
|---|---|
| FR Code | 3.10.1 |
| Feature | Push Notification |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo thông báo toàn hệ thống, có phân chia theo nhóm user.

## 2. User Story

Là một Admin,
tôi muốn gửi thông báo toàn hệ thống,
để thông báo maintenance/feature mới đến đúng nhóm user.

## 3. Acceptance Criteria

- Form soạn notification: `title`, `content`, `targetAudience` (all | by plan | by role).
- Gửi ngay hoặc lên lịch gửi sau.

## 4. UI / UX

- Trang Admin `/admin/notifications/create`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/admin/notifications
{ "title", "content", "targetAudience", "scheduledAt"? }
→ 201 { "success": true, "data": { "id", "recipientCount" } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- `targetAudience` không khớp user nào → `recipientCount=0`, vẫn tạo thành công (không lỗi).

## 8. Definition of Done

- Gửi notification thành công, đúng nhóm target.

## Out of Scope

- Không có.

## Tham chiếu BA

[09-admin-management.md](../../../BA/09-admin-management.md)

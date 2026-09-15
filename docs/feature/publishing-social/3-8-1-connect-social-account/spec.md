# UC — Connect Social Account

| | |
|---|---|
| FR Code | 3.8.1 |
| Feature | Connect Social Account |
| Domain | Publishing & Social (FR 3.8) |
| Role | CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Kết nối tài khoản social của Client để hệ thống đăng bài tự động thay họ.

## 2. User Story

Là một Client,
tôi muốn kết nối tài khoản social media của mình,
để Agency có thể đăng bài tự động thay tôi.

## 3. Acceptance Criteria

- OAuth flow kết nối Facebook/Instagram/TikTok/Threads (theo platform Client chọn).
- Lưu access token đã mã hóa, liên kết với Client trong Workspace này.

## 4. UI / UX

- Trang `/workspaces/:id/social-accounts`, nút 'Kết nối' theo từng platform.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/social/{platform}/connect → redirect OAuth consent
GET /api/v1/social/{platform}/callback?code=...
→ 200 { "success": true, "data": { "accountId", "platform", "displayName" } }
```

## 6. Error Handling

- OAuth thất bại/user cancel → redirect về trang social-accounts kèm thông báo lỗi.

## 7. Edge Cases

- Client kết nối lại tài khoản đã từng disconnect trước đó (FR 3.8.2) → tạo record mới hoặc reactivate record cũ, quyết định khi thiết kế kỹ thuật (đề xuất reactivate để giữ lịch sử post cũ liên kết đúng).

## 8. Definition of Done

- Kết nối thành công, token lưu mã hóa an toàn.

## Out of Scope

- Không có.

## Tham chiếu BA

[07-publishing-social-collaborator.md](../../../BA/07-publishing-social-collaborator.md)

# UC — Schedule Platform Post

| | |
|---|---|
| FR Code | 3.8.7 |
| Feature | Schedule Platform Post |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Trang hiển thị lịch đăng bài, xem những bài đó ở lịch cụ thể.

## 2. User Story

Là một Member,
tôi muốn xem lịch đăng bài theo platform,
để biết bài nào sẽ đăng vào lúc nào.

## 3. Acceptance Criteria

- Calendar view riêng cho Post đã lên lịch publish (khác Calendar Task View chung ở FR 3.6.5 — đây tập trung vào lịch publish thực tế, có tính timezone Workspace).

## 4. UI / UX

- Trang `/workspaces/:id/posts/schedule`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/posts/schedule?month=2026-09
→ 200 { "success": true, "data": [{ "postId", "platform", "scheduledAt" }] }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- `scheduledAt` hiển thị theo `Workspace.timezoneConfig` (FR 3.4.13) — không theo timezone máy user.

## 8. Definition of Done

- Hiển thị đúng lịch theo timezone Workspace.

## Out of Scope

- Không có.

## Tham chiếu BA

[07_Publishing_Social_Collaborator.md](../../../BA/07_Publishing_Social_Collaborator.md)

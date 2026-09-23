# UC — View Dashboard Post

| | |
|---|---|
| FR Code | 3.8.3 |
| Feature | View Dashboard Post |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị trang tổng quan trong Workspace khi đã đăng thành công bài post lên social media.

## 2. User Story

Là một Member,
tôi muốn xem dashboard tổng quan các bài đã đăng,
để theo dõi hiệu quả publishing của Workspace.

## 3. Acceptance Criteria

- Hiển thị: tổng số Post đã publish, breakdown theo platform, tỉ lệ thành công/thất bại.

## 4. UI / UX

- Trang `/workspaces/:id/posts/dashboard`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/posts/dashboard
→ 200 { "success": true, "data": { "totalPosts", "byPlatform": {...}, "successRate" } }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Workspace chưa publish bài nào → dashboard toàn 0.

## 8. Definition of Done

- Dashboard hiển thị đúng số liệu.

## Out of Scope

- Không có.

## Tham chiếu BA

[07-publishing-social-collaborator.md](../../../BA/07-publishing-social-collaborator.md)

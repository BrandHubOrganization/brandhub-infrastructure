# UC — View Post Track Detail

| | |
|---|---|
| FR Code | 3.8.4 |
| Feature | View Post Track Detail |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Trang chi tiết bài đăng thành công — reaction, comment, share.

## 2. User Story

Là một Member,
tôi muốn xem chi tiết 1 bài đã đăng,
để biết mức độ tương tác thực tế trên social media.

## 3. Acceptance Criteria

- Hiển thị: count reaction, comment, share; link tới bài gốc trên platform.

## 4. UI / UX

- Trang `/workspaces/:id/posts/:postId`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/posts/{postId}
→ 200 { "success": true, "data": { "platformPostUrl", "reactionCount", "commentCount", "shareCount" } }
```

## 6. Error Handling

- Post không tồn tại/chưa publish → 404 `POST_NOT_FOUND`.

## 7. Edge Cases

- Platform API rate-limit khi lấy số liệu tương tác real-time → cache số liệu cũ, hiển thị timestamp lần cập nhật gần nhất.

## 8. Definition of Done

- Hiển thị đúng chi tiết tương tác.

## Out of Scope

- Không có.

## Tham chiếu BA

[07_Publishing_Social_Collaborator.md](../../../BA/07_Publishing_Social_Collaborator.md)

# UC — Publish Instagram Post

| | |
|---|---|
| FR Code | 3.8.12 |
| Feature | Publish Instagram Post |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tự động đăng Post lên Instagram qua API chính thức, khi Task loại Post đã hoàn thành Approval Sequence.

## 2. User Story

Là một Member,
tôi muốn hệ thống tự động đăng Post lên Instagram,
để không cần đăng tay thủ công.

## 3. Acceptance Criteria

- Task loại `post` đạt trạng thái `COMPLETED` (qua Approval Sequence, FR 3.6.9) và có `targetPlatform=Instagram` → vào hàng đợi publish.
- Publisher service gọi API chính thức của Instagram bằng token đã connect (FR 3.8.1) để đăng Post.
- Kết quả cập nhật vào View Status Tracking (FR 3.8.8): `PENDING → IN_PROGRESS → DONE`/`FAIL`.

## 4. UI / UX

- Không có UI riêng — publish tự động, chỉ hiển thị kết quả qua Status Tracking (FR 3.8.8) và Dashboard (FR 3.8.3).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
(internal) POST /internal/publisher/instagram/publish
{ "taskId", "content", "mediaUrls" }
→ 200 { "platformPostId", "postUrl" } hoặc lỗi platform cụ thể
```

## 6. Error Handling

- Token Instagram hết hạn/bị revoke → `FAIL`, lý do `TOKEN_EXPIRED`, thông báo Client cần reconnect (FR 3.8.1).
- Nội dung vi phạm giới hạn platform (độ dài, định dạng media) → `FAIL` với lý do cụ thể từ API platform.

## 7. Edge Cases

- Client disconnect account đúng lúc bài đang trong hàng đợi publish → xem Edge Case ở FR 3.8.2 (Post chuyển FAIL rõ lý do).

## 8. Definition of Done

- Publish Post lên Instagram thành công qua API thật, trạng thái cập nhật đúng.

## Out of Scope

- Không có.

## Tham chiếu BA

[07_Publishing_Social_Collaborator.md](../../../BA/07_Publishing_Social_Collaborator.md)

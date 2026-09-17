# UC — Preview Post

| | |
|---|---|
| FR Code | 3.8.6 |
| Feature | Preview Post |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem trước layout bài đăng theo từng mạng xã hội khi Creator sửa/làm bài.

## 2. User Story

Là một Member,
tôi muốn xem trước layout bài đăng theo từng platform,
để đảm bảo hiển thị đúng trước khi publish.

## 3. Acceptance Criteria

- Preview render đúng format riêng của FB/IG/TikTok/Threads (tỉ lệ ảnh, giới hạn ký tự caption, vị trí hashtag).

## 4. UI / UX

- Panel Preview trong Task Detail (loại Post), tab chọn theo platform.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks/{taskId}/preview?platform=facebook
→ 200 { "success": true, "data": { "renderedHtml" hoặc "previewData" } }
```

## 6. Error Handling

- Content vượt giới hạn ký tự platform (ví dụ Threads 500 ký tự) → cảnh báo rõ trong preview, không chặn cứng lưu draft.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Preview hiển thị đúng format từng platform.

## Out of Scope

- Không có.

## Tham chiếu BA

[07-publishing-social-collaborator.md](../../../BA/07-publishing-social-collaborator.md)

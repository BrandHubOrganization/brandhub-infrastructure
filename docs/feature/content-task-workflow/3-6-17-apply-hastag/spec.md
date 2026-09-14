# UC — Apply Hastag

| | |
|---|---|
| FR Code | 3.6.17 |
| Feature | Apply Hastag |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Thêm 1 hoặc nhiều hashtag cho bài đăng/sự kiện/chiến dịch.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn gắn hashtag cho bài đăng,
để tăng khả năng lan tỏa trên social media.

## 3. Acceptance Criteria

- Chọn/gõ hashtag từ Hashtag Collection của Workspace (FR 3.6.18) hoặc gõ mới.
- Gắn nhiều hashtag cho 1 Task (loại Post).

## 4. UI / UX

- Input tag-picker trong trang soạn content (Task Detail, loại Post).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/hashtags
{ "hashtagIds": ["string"] }
→ 200 { "success": true, "data": { "hashtags": [...] } }
```

## 6. Error Handling

- Hashtag không thuộc Workspace này → 400 `INVALID_HASHTAG`.

## 7. Edge Cases

- Gắn hashtag chưa tồn tại trong Collection → tự động tạo mới vào Collection luôn (liên kết với FR 3.6.19 Add Hashtag Collection).

## 8. Definition of Done

- Gắn hashtag thành công cho Task.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

# UC — Add Hastag Collection

| | |
|---|---|
| FR Code | 3.6.19 |
| Feature | Add Hastag Collection |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Thêm hashtag mới vào Collection, phân loại rõ mục đích sử dụng.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn thêm hashtag mới vào kho,
để dùng lại cho các bài đăng sau.

## 3. Acceptance Criteria

- Form nhập `tag`, chọn `purpose` (ví dụ: brand, campaign, trending, event-specific).
- Client thêm → tự động `isRequired=true` nếu đánh dấu đặc thù sự kiện.

## 4. UI / UX

- Nút 'Thêm hashtag' trong `/workspaces/:id/hashtags`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/hashtags
{ "tag": "string", "purpose": "string", "isRequired"?: boolean }
→ 201 { "success": true, "data": { "id", "tag" } }
```

## 6. Error Handling

- Hashtag trùng đã tồn tại trong Workspace → 409 `HASHTAG_ALREADY_EXISTS`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Thêm thành công, phân loại đúng purpose.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

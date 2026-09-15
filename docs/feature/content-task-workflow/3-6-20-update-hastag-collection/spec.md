# UC — Update Hastag Collection

| | |
|---|---|
| FR Code | 3.6.20 |
| Feature | Update Hastag Collection |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cập nhật hashtag đã có trong Collection.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn sửa lại thông tin hashtag,
để cập nhật đúng mục đích sử dụng.

## 3. Acceptance Criteria

- Sửa `tag`, `purpose`, `isRequired`.

## 4. UI / UX

- Nút Edit trong list Hashtag.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/hashtags/{hashtagId}
{ "tag"?, "purpose"?, "isRequired"? }
→ 200 { "success": true, "data": { ...updated hashtag... } }
```

## 6. Error Handling

- Không phải người tạo/không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Đổi hashtag đã được apply vào nhiều Task cũ → các Task cũ vẫn giữ giá trị hashtag đã dùng lúc đó (không tự động cập nhật ngược, tương tự soft-update-only).

## 8. Definition of Done

- Update thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

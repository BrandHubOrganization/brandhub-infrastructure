# UC — Remove Hastag Collection

| | |
|---|---|
| FR Code | 3.6.21 |
| Feature | Remove Hastag Collection |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xóa hashtag cũ khỏi Collection — soft delete, hashtag đã áp dụng vào bài cũ không bị xóa theo.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn xóa hashtag không còn dùng,
nhưng không muốn ảnh hưởng các bài đăng cũ đã dùng hashtag đó.

## 3. Acceptance Criteria

- Xóa hashtag khỏi Collection (`status=removed`) — **soft delete**.
- Hashtag đã gắn vào Task cũ (FR 3.6.17) vẫn giữ nguyên hiển thị ở bài đăng đó, chỉ không còn xuất hiện trong danh sách chọn mới.

## 4. UI / UX

- Nút Delete trong list Hashtag, confirm dialog.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}/hashtags/{hashtagId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Xóa hashtag đang `isRequired=true` do Client set → Manager/Creator có thể xóa được (không cần Client tự xóa), nhưng nên cảnh báo rõ đây là hashtag bắt buộc trước khi confirm.

## 8. Definition of Done

- Soft delete thành công, không ảnh hưởng hashtag đã dùng ở Task cũ.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

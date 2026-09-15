# UC — Content Writting View

| | |
|---|---|
| FR Code | 3.6.10 |
| Feature | Content Writting View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Soạn văn bản kiểu Google Docs, tự động chuyển font đúng chuẩn khi đăng, có Content History/Version.

## 2. User Story

Là một Creator,
tôi muốn soạn content trực tiếp trên hệ thống,
và không cần copy qua công cụ ngoài để đổi font trước khi đăng.

## 3. Acceptance Criteria

- Editor dạng rich-text (vector-based, giống Google Docs) — hỗ trợ format cơ bản (bold, italic, list, emoji).
- **Tự động chuyển font chữ đúng chuẩn khi đăng bài** — giải quyết pain point hiện tại phải copy qua Unikey/Yantext trước khi đăng lên social.
- **Content History/Version**: lưu lại từng lần sửa (ai sửa, khi nào, nội dung khác biệt), cho phép khôi phục về version cũ.

## 4. UI / UX

- Editor nhúng trong Task Detail (loại Post), có sidebar Version History.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/content
{ "body": "rich text content" }
→ 200 { "success": true, "data": { "versionId", "savedAt" } }

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions
→ 200 { "success": true, "data": [{ "versionId", "editedBy", "editedAt" }] }

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{versionId}/restore
→ 200 { "success": true, "data": { ...restored content... } }
```

## 6. Error Handling

- Task không phải loại `post` → 400 `INVALID_TASK_TYPE_FOR_CONTENT_WRITING`.

## 7. Edge Cases

- 2 Creator cùng sửa 1 content đồng thời (do QC + Creator gốc cùng có quyền edit) → cần cơ chế conflict resolution (last-write-wins hoặc lock khi đang edit — quyết định khi thiết kế kỹ thuật).

## 8. Definition of Done

- Editor hoạt động, auto-convert font đúng khi publish, Version History lưu và khôi phục đúng.

## Out of Scope

- Real-time collaborative editing (nhiều người sửa cùng lúc thấy nhau gõ) — không có trong CSV, chỉ cần version history.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

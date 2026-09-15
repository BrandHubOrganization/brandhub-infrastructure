# UC — Add Material Repository

| | |
|---|---|
| FR Code | 3.6.12 |
| Feature | Add Material Repository |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Upload file mới vào Material Repository.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn upload ảnh/video mới vào Material Repository,
để lưu trữ và dùng cho các Task sau này.

## 3. Acceptance Criteria

- Upload file (ảnh/video), chọn `type` (raw/retouched).
- Client upload thường vào Brand Collection (không phải Material Repository thông thường) — phân biệt theo endpoint/UI.

## 4. UI / UX

- Nút Upload trong `/workspaces/:id/materials`, hỗ trợ drag-drop multi-file.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/materials
FormData: file, type
→ 201 { "success": true, "data": { "id", "url", "type" } }
```

## 6. Error Handling

- File vượt dung lượng cho phép → 400 `FILE_TOO_LARGE`.
- Định dạng không hỗ trợ → 400 `UNSUPPORTED_FILE_TYPE`.

## 7. Edge Cases

- Upload file trùng tên → tạo record mới, không overwrite (giữ cả 2 bản, đặt tên khác nhau tự động).

## 8. Definition of Done

- Upload thành công, hiển thị ngay trong list.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

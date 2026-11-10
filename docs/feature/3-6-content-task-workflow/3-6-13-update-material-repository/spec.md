# UC — Update Material Repository

| | |
|---|---|
| FR Code | 3.6.13 |
| Feature | Update Material Repository |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cập nhật metadata của Material đã có (đổi loại raw/retouched, ghi chú).

## 2. User Story

Là một Creator,
tôi muốn cập nhật thông tin 1 Material,
ví dụ đánh dấu đã retouch xong từ raw.

## 3. Acceptance Criteria

- Sửa `type`, `note` của Material — không sửa file gốc (muốn đổi file phải upload mới).

## 4. UI / UX

- Nút Edit trong list Material.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/materials/{materialId}
{ "type"?, "note"? }
→ 200 { "success": true, "data": { ...updated material... } }
```

## 6. Error Handling

- Không phải người upload/không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Đổi `type` từ raw sang retouched → không xóa cảnh báo ở các Task đã dùng bản raw trước đó (lịch sử vẫn giữ đúng thực tế lúc dùng).

## 8. Definition of Done

- Update metadata thành công.

## Out of Scope

- Đổi file gốc (chỉ đổi metadata).

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

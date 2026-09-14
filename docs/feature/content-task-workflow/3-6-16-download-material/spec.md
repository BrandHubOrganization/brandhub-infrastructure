# UC — Download Material

| | |
|---|---|
| FR Code | 3.6.16 |
| Feature | Download Material |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép mọi role download tài liệu từ Workspace về máy local.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn download material về máy,
để lưu trữ hoặc dùng cho mục đích chỉnh sửa ngoài hệ thống.

## 3. Acceptance Criteria

- Nút Download ở mỗi Material — trả file gốc (không qua watermark trừ khi chọn bản đã watermark).
- Không giới hạn role — cả 3 role đều download được.

## 4. UI / UX

- Nút Download cạnh mỗi item trong list Material/Brand Collection.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/materials/{materialId}/download
→ 200 (binary file stream)
```

## 6. Error Handling

- Material không tồn tại/đã xóa → 404 `MATERIAL_NOT_FOUND`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Download hoạt động cho cả 3 role.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)

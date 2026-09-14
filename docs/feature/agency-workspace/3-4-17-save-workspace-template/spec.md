# UC — Save Workspace Template

| | |
|---|---|
| FR Code | 3.4.17 |
| Feature | Save Workspace Template |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner lưu lại cấu hình 1 Workspace hiện có thành Template để tái sử dụng khi tạo Workspace mới sau này.

## 2. User Story

Là một Owner,
tôi muốn lưu cấu hình Workspace hiện tại thành template,
để tạo Workspace mới tương tự nhanh hơn trong tương lai.

## 3. Acceptance Criteria

- Bấm 'Lưu thành Template' từ 1 Workspace đang có → tạo `WorkspaceTemplate` chứa: thông tin cơ bản (không bao gồm Member/Client cụ thể), cách triển khai (ví dụ: Media Package template đã dùng).
- Template này xuất hiện trong danh sách chọn khi tạo Workspace mới (mở rộng UX cho FR 3.4.12, không bắt buộc).

## 4. UI / UX

- Nút trong Workspace Settings; danh sách Template hiển thị ở `/agencies/:id/workspace-templates`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/save-as-template
{ "templateName": "string" }
→ 201 { "success": true, "data": { "templateId" } }

GET /api/v1/agencies/{id}/workspace-templates
→ 200 { "success": true, "data": [{ "id", "templateName", "basedOnWorkspaceId" }] }
```

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.

## 7. Edge Cases

- Workspace gốc bị xóa sau khi đã lưu Template → Template vẫn tồn tại độc lập (không phụ thuộc Workspace gốc còn sống hay không).

## 8. Definition of Done

- Lưu Template thành công, dùng lại được khi tạo Workspace mới.

## Out of Scope

- Chia sẻ Template giữa các Agency khác nhau (chỉ trong phạm vi 1 Agency theo CSV).

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)

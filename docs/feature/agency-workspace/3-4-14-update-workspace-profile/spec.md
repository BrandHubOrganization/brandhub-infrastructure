# UC — Update Workspace Profile

| | |
|---|---|
| FR Code | 3.4.14 |
| Feature | Update Workspace Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER (chỉ) |
| Version | 2.2 — Cập nhật 2026-09-23 — đồng bộ theo code thật (logo IOException trả 400 FILE_READ_ERROR) |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Cho phép MANAGER của Workspace cập nhật thông tin/settings của Workspace.

## 2. User Story

Là một MANAGER của Workspace,
tôi muốn cập nhật thông tin Workspace,
để giữ cấu hình luôn chính xác với thực tế vận hành.

## 3. Acceptance Criteria

- Form sửa: `name`, `timezone`, `defaultPlatforms` (list), `industry`, `companySize`, `website`, `phone`, `location`.
- Endpoint được bảo vệ bởi `@RequireRole({MemberRole.MANAGER})` — chỉ MANAGER của chính Workspace đó mới gọi được (không có khái niệm OWNER ở cấp Workspace).
- Route có suffix `/settings` (khác route xem chi tiết `GET /{workspaceId}`).

## 4. UI / UX

- Trang `/workspaces/:id/profile/edit`.

## 5. API Contract

```
PATCH /api/v1/workspaces/{workspaceId}/settings
{
  "name"?, "timezone"?, "defaultPlatforms"?: ["string"],
  "industry"?: "FNB|FASHION|BEAUTY|TECHNOLOGY|REAL_ESTATE|EDUCATION|HEALTHCARE|SERVICES|RETAIL|OTHER",
  "companySize"?: "SIZE_1_10|SIZE_11_50|SIZE_51_200|SIZE_201_500|SIZE_500_PLUS",
  "website"?, "phone"?, "location"?
}
→ 200 { "success": true, "data": WorkspaceResponse }
```

Ghi chú: cập nhật logo dùng endpoint riêng `POST /api/v1/workspaces/{workspaceId}/logo` (multipart form-data, field `file`), cũng yêu cầu role MANAGER.

## 6. Error Handling

- Không phải MANAGER của Workspace này → 403 `FORBIDDEN` (`@RequireRole` chặn).
- Upload logo, đọc file lỗi (`IOException` khi gọi `file.getBytes()`) → 400 `FILE_READ_ERROR`.

## 7. Edge Cases

- Đổi `timezoneConfig` khi đang có Task/Livestream đã lên lịch theo timezone cũ → cần cảnh báo rõ ảnh hưởng trước khi lưu (không tự động dời lịch).

## 8. Definition of Done

- Update thành công, đúng phân quyền Owner/Manager.

## Out of Scope

- Tự động điều chỉnh lịch Task hiện có khi đổi timezone.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

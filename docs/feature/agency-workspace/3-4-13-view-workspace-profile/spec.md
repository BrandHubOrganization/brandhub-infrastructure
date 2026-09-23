# UC — View Workspace Profile

| | |
|---|---|
| FR Code | 3.4.13 |
| Feature | View Workspace Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER/CREATOR/CLIENT |
| Version | 2.2 — Cập nhật 2026-09-23 — đồng bộ theo code thật (bổ sung membership check) |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Xem thông tin chi tiết Workspace, bao gồm cấu hình timezone và các field branding/thông tin doanh nghiệp.

## 2. User Story

Là một thành viên Workspace,
tôi muốn xem thông tin Workspace bao gồm cấu hình timezone và branding,
để hiểu Workspace đang vận hành theo mốc giờ nào và cấu hình thương hiệu ra sao.

## 3. Acceptance Criteria

- Hiển thị đầy đủ field của `WorkspaceResponse`: `id`, `name`, `agencyId`, `settings` (chứa `timezoneConfig`, `defaultPlatforms`...), `industry`, `companySize`, `website`, `phone`, `location`, `description`, `brandColor`, `logoIcon`, `logoUrl`, `tagline`, `foundedYear`, `facebookUrl`, `linkedinUrl`, `instagramUrl`, `createdAt`.
- Không có field `mediaPackageTemplate` hay danh sách Client đang hoạt động trong response thật — đây là phần chưa được code, cần làm rõ nếu vẫn cần hiển thị (Out of Scope tạm thời).
- Caller phải là active `WorkspaceMember` của chính workspace đang xem — kiểm tra thủ công trong `WorkspaceServiceImpl.getWorkspace` (không dùng `@RequireRole` vì aspect đó không check đúng workspace theo path).

## 4. UI / UX

- Trang `/workspaces/:id/profile`.

## 5. API Contract

```
GET /api/v1/workspaces/{workspaceId}
→ 200 { "success": true, "data": WorkspaceResponse }
```

## 6. Error Handling

- Workspace không tồn tại → 404 `WORKSPACE_NOT_FOUND`.
- Caller không phải active member của chính workspace này → 403 `WORKSPACE_ACCESS_DENIED` (check thủ công trong `getWorkspace`, không dùng `@RequireRole` vì aspect đó check sai workspace).

## 7. Edge Cases

- Workspace phục vụ Client ở nhiều địa điểm khác nhau → chỉ có 1 `timezoneConfig` cấp Workspace (không phải theo từng Client/Task) — nếu cần khác timezone theo từng Campaign, đó là mở rộng ngoài CSV hiện tại.

## 8. Definition of Done

- Hiển thị đúng đầy đủ field, đặc biệt timezoneConfig.

## Out of Scope

- Timezone theo từng Task/Campaign riêng (chỉ có 1 timezone cấp Workspace theo CSV).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

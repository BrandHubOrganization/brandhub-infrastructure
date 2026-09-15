# UC — View Workspace Profile

| | |
|---|---|
| FR Code | 3.4.13 |
| Feature | View Workspace Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem thông tin Workspace, đặc biệt field Timezone Configuration — mốc thời gian chuẩn hoạt động của Workspace.

## 2. User Story

Là một Owner hoặc Manager,
tôi muốn xem thông tin Workspace bao gồm cấu hình timezone,
để hiểu Workspace đang vận hành theo mốc giờ nào.

## 3. Acceptance Criteria

- Hiển thị: `name`, `timezoneConfig`, `mediaPackageTemplate` (nếu đã chọn), ngày tạo, danh sách Client đang hoạt động.
- **Timezone Configuration quan trọng**: định nghĩa mốc thời gian chuẩn của Workspace — dùng để tối ưu giờ đăng bài viral theo địa điểm tổ chức sự kiện thực tế (khác timezone hệ thống mặc định).

## 4. UI / UX

- Trang `/workspaces/:id/profile`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}
→ 200 { "success": true, "data": { "id", "name", "timezoneConfig", "mediaPackageTemplateId", "createdAt" } }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Workspace phục vụ Client ở nhiều địa điểm khác nhau → chỉ có 1 `timezoneConfig` cấp Workspace (không phải theo từng Client/Task) — nếu cần khác timezone theo từng Campaign, đó là mở rộng ngoài CSV hiện tại.

## 8. Definition of Done

- Hiển thị đúng đầy đủ field, đặc biệt timezoneConfig.

## Out of Scope

- Timezone theo từng Task/Campaign riêng (chỉ có 1 timezone cấp Workspace theo CSV).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

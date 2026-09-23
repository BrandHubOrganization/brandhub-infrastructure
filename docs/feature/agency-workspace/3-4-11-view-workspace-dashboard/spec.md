# UC — View Workspace Dashboard

| | |
|---|---|
| FR Code | 3.4.11 |
| Feature | View Workspace Dashboard |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER/CREATOR/CLIENT |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Draft — chưa code (chưa có endpoint dashboard riêng trong `WorkspaceController`) |

## 1. Objective

Hiển thị thông tin chung và thống kê của 1 Workspace.

## 2. User Story

Là một thành viên (MANAGER/CREATOR/CLIENT) của Workspace,
tôi muốn xem dashboard của Workspace,
để nắm tình hình công việc đang triển khai.

## 3. Acceptance Criteria

- Hiển thị: số Task theo trạng thái (backlog/in progress/completed), số Client đang làm việc, Campaign đang active.
- Chỉ user có `WorkspaceMember` record (role MANAGER/CREATOR/CLIENT) ở Workspace này mới xem được — không còn khái niệm "Owner Agency" ở cấp Workspace (Owner chỉ tồn tại ở cấp Agency).

## 4. UI / UX

- Trang `/workspaces/:id/dashboard`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/dashboard
→ 200 { "success": true, "data": { "taskStats": {...}, "activeClientCount", "activeCampaignCount" } }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Workspace vừa tạo, chưa có Package/Campaign/Task nào → dashboard hiển thị toàn 0.

## 8. Definition of Done

- Dashboard hiển thị đúng số liệu.

## Out of Scope

- Chart chi tiết theo thời gian (mở rộng sau).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

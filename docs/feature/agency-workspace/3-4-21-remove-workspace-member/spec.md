# UC — Remove Workspace Member

| | |
|---|---|
| FR Code | 3.4.21 |
| Feature | Remove Workspace Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER |
| Version | 2.2 — Cập nhật 2026-09-23 — đồng bộ theo code thật (bổ sung guard last-MANAGER) |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Xóa (soft-delete) thành viên khỏi Workspace (không xóa khỏi Agency).

## 2. User Story

Là một MANAGER,
tôi muốn xóa 1 thành viên khỏi Workspace,
nhưng họ vẫn còn trong Agency để có thể tham gia Workspace khác.

## 3. Acceptance Criteria

- Bấm Remove (confirm dialog).
- Chỉ MANAGER của Workspace gọi được (`@RequireRole({MemberRole.MANAGER})`).
- Set `WorkspaceMember.isActive = false` (soft-delete, không xóa cứng record) — **không đụng đến `AgencyMember`**.
- Member bị xóa mất quyền truy cập Workspace này ngay, nhưng vẫn còn trong Agency và các Workspace khác họ đang tham gia.
- **Guard last-MANAGER:** nếu member bị xóa có role MANAGER và là MANAGER active DUY NHẤT của workspace (đếm `countByWorkspaceIdAndRoleAndIsActiveTrue <= 1`) → chặn, ném `LAST_OWNER_CANNOT_BE_REMOVED` (409). Tái sử dụng `ErrorCode.LAST_OWNER_CANNOT_BE_REMOVED` có sẵn (message "Cannot remove the last owner of the workspace" — tên field ghi OWNER nhưng áp dụng chung cho context MANAGER ở Workspace). Guard này dùng chung method `assertNotLastManager` với FR 3.4.16 (Leave) và FR 3.4.20 (Update Role).

## 4. UI / UX

- Nút Remove trong bảng Members ở `/workspaces/:id/members`.

## 5. API Contract

```
DELETE /api/v1/workspaces/{workspaceId}/members/{memberId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không phải MANAGER của Workspace này → 403 `FORBIDDEN`.
- `memberId` không tồn tại / không active / không thuộc `workspaceId` này → 404 `NOT_FOUND`.
- Xóa MANAGER active duy nhất của workspace → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.

## 7. Edge Cases

- Member bị xóa đang có Task đang thực hiện ở Workspace này → Task không tự unassign (chưa verify trong code phạm vi Workspace này — theo pattern tương tự FR 3.4.9 phía Agency).

## 8. Definition of Done

- Remove thành công qua `DELETE /{workspaceId}/members/{memberId}`, không ảnh hưởng `AgencyMember`. Chặn đúng trường hợp xóa MANAGER active duy nhất (409 `LAST_OWNER_CANNOT_BE_REMOVED`).

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

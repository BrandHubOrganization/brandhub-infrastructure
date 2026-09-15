# UC — Remove Workspace Member

| | |
|---|---|
| FR Code | 3.4.21 |
| Feature | Remove Workspace Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xóa thành viên khỏi Workspace (không xóa khỏi Agency).

## 2. User Story

Là một Owner hoặc Manager,
tôi muốn xóa 1 thành viên khỏi Workspace,
nhưng họ vẫn còn trong Agency để có thể tham gia Workspace khác.

## 3. Acceptance Criteria

- Bấm Remove (confirm dialog).
- Xóa `WorkspaceMember` record — **không đụng đến `AgencyMember`** (khác với Remove Member cấp Agency, FR 3.4.9).
- Member bị xóa mất quyền truy cập Workspace này ngay, nhưng vẫn còn trong Agency và các Workspace khác họ đang tham gia.

## 4. UI / UX

- Nút Remove trong bảng Members ở `/workspaces/:id/members`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}/members/{memberId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Xóa Manager duy nhất → 409 `CANNOT_REMOVE_LAST_MANAGER`.

## 7. Edge Cases

- Member bị xóa đang có Task đang thực hiện ở Workspace này → Task không tự unassign, Manager cần reassign thủ công (giống logic FR 3.4.9).

## 8. Definition of Done

- Remove thành công, không ảnh hưởng AgencyMember, chặn đúng trường hợp mất Manager cuối.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

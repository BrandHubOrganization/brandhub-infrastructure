# Sequence Flow — Remove Workspace Member

> Bổ sung cho `spec.md` (FR 3.4.21). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.removeMember`, `WorkspaceServiceImpl.removeMember` + `assertNotLastManager`).

## Actors

- **MANAGER** — MANAGER của Workspace, người xóa thành viên.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspace_members`).

---

## Flow A — Xóa (soft-delete) thành viên khỏi Workspace

1. MANAGER → FE: trong `/workspaces/:id/members`, bấm "Remove" trên 1 Member, xác nhận (confirm dialog).
2. FE → BE: `DELETE /api/v1/workspaces/{workspaceId}/members/{memberId}`.
3. BE: `@RequireRole({MemberRole.MANAGER})` chặn trước — không phải MANAGER của workspace này → `403 FORBIDDEN`.
4. BE (`WorkspaceServiceImpl.removeMember`):
   a. `workspaceMemberRepository.findById(memberId)`, filter `member.workspaceId == workspaceId && member.isActive` — không thỏa (không tồn tại / không active / thuộc workspace khác) → `404 NOT_FOUND`.
   b. `assertNotLastManager(workspaceId, member)`: nếu `member.role != MANAGER` → pass ngay. Nếu `member.role == MANAGER` → đếm `countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MANAGER)` — nếu `<= 1` (member này là MANAGER active duy nhất) → `409 LAST_OWNER_CANNOT_BE_REMOVED`.
   c. Set `member.isActive = false`, `updatedAt = now()`.
5. BE → DB: `UPDATE workspace_members SET is_active = false, updated_at = ? WHERE id = ?`.
6. BE → FE: `200 { data: null }`.
7. FE: cập nhật bảng thành viên, member biến mất khỏi danh sách active. `AgencyMember` record của người này không bị đụng tới (member vẫn còn trong Agency, còn ở các Workspace khác nếu có).

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Remove | Không phải MANAGER của Workspace | 403 | `FORBIDDEN` |
| Remove | `memberId` không tồn tại / không active / không thuộc `workspaceId` này | 404 | `NOT_FOUND` |
| Remove | Member là MANAGER active duy nhất của workspace | 409 | `LAST_OWNER_CANNOT_BE_REMOVED` |

## Ghi chú khác biệt so với spec.md gốc

- Không có — spec.md và sequence-flow đã khớp code thật, guard last-MANAGER (`assertNotLastManager`, dùng chung với FR 3.4.16 và 3.4.20) đã được phản ánh đầy đủ.

# UC — Update Workspace Member Role

| | |
|---|---|
| FR Code | 3.4.20 |
| Feature | Update Workspace Member Role |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER |
| Version | 3.0 — Cập nhật 2026-09-23 — viết lại hoàn toàn, đã code |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Cho phép MANAGER đổi role của 1 Member trong chính Workspace đó.

## 2. User Story

Là một MANAGER,
tôi muốn đổi role của 1 thành viên trong Workspace,
để điều chỉnh quyền hạn phù hợp với công việc thực tế, kể cả chuyển giao vai trò MANAGER.

## 3. Acceptance Criteria

- Chỉ MANAGER của Workspace gọi được (`@RequireRole({MemberRole.MANAGER})`).
- Chọn Member trong danh sách → đổi role sang `MANAGER`/`CREATOR`/`CLIENT` (KHÔNG có `OWNER` ở cấp Workspace — Owner chỉ tồn tại ở cấp Agency).
- Đổi role **chỉ ảnh hưởng Workspace hiện tại** — không lan sang Workspace khác của cùng Member trong cùng Agency.
- **Guard last-MANAGER (giảm quyền):** nếu member hiện tại là MANAGER active DUY NHẤT của workspace và role mới ≠ MANAGER → chặn, ném `LAST_OWNER_CANNOT_BE_REMOVED` (409) — phải có MANAGER khác thay thế trước.
- **Guard MANAGER trùng (thăng quyền):** nếu role mới = MANAGER và member hiện tại chưa phải MANAGER → kiểm tra workspace đã có MANAGER active khác chưa; nếu có → chặn, ném `MANAGER_ALREADY_ASSIGNED` (409) — mỗi workspace chỉ có đúng 1 MANAGER active.
- `memberId` không tồn tại / không active / không thuộc `workspaceId` này → 404 `NOT_FOUND`.
- Response trả về `WorkspaceMemberResponse` đã cập nhật (bao gồm `role` mới).

## 4. UI / UX

- Dropdown đổi role ngay trong bảng Members ở `/workspaces/:id/members`.

## 5. API Contract

```
PATCH /api/v1/workspaces/{workspaceId}/members/{memberId}/role
{ "role": "MANAGER|CREATOR|CLIENT" }
→ 200 { "success": true, "data": WorkspaceMemberResponse }
```

Request body: `UpdateMemberRoleRequest { role: MemberRole }`.

## 6. Error Handling

- Không phải MANAGER của Workspace này → 403 `FORBIDDEN` (chặn qua `@RequireRole`).
- `memberId` không tồn tại / không active / không thuộc `workspaceId` này → 404 `NOT_FOUND`.
- Đổi role của MANAGER duy nhất xuống CREATOR/CLIENT (mất MANAGER cuối) → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.
- Đổi role sang MANAGER khi workspace đã có MANAGER active khác → 409 `MANAGER_ALREADY_ASSIGNED`.

## 7. Edge Cases

- MANAGER đổi role của chính mình xuống CREATOR/CLIENT → cho phép nếu còn ít nhất 1 MANAGER khác trong workspace này; nếu là MANAGER duy nhất → bị chặn 409 giống mọi member khác (không có ngoại lệ "tự đổi chính mình").
- Đổi role của 1 member từ `CREATOR` sang `CLIENT` (hoặc ngược lại, không liên quan MANAGER) → luôn cho phép, không guard nào áp dụng (2 guard chỉ kích hoạt khi role cũ hoặc role mới là MANAGER).
- Đổi role sang cùng giá trị hiện tại (ví dụ CREATOR → CREATOR) → cho phép, không có guard đặc biệt nào chặn no-op.

## 8. Definition of Done

- Đổi role thành công qua `PATCH /{workspaceId}/members/{memberId}/role`, chặn đúng trường hợp mất MANAGER cuối cùng và trường hợp có 2 MANAGER cùng lúc.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

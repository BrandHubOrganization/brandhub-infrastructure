# UC — Leave Workspace

| | |
|---|---|
| FR Code | 3.4.16 |
| Feature | Leave Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER/CREATOR/CLIENT (bất kỳ active member nào rời chính workspace của mình) |
| Version | 3.0 — Cập nhật 2026-09-23 — viết lại hoàn toàn, đã code |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Cho phép 1 Member tự rời khỏi 1 Workspace, nhưng vẫn còn trong Agency (rời Workspace ≠ rời Agency).

## 2. User Story

Là một Member,
tôi muốn rời khỏi 1 Workspace tôi không còn tham gia,
nhưng vẫn giữ tư cách thành viên Agency để tham gia Workspace khác.

## 3. Acceptance Criteria

- Bấm "Rời Workspace" (confirm dialog).
- Endpoint không có `@RequireRole` — bất kỳ user đã đăng nhập nào cũng gọi được, vì action chỉ áp dụng lên chính `WorkspaceMember` record của `currentUser` (lấy `userId` từ `AuthenticatedUser` principal, không nhận tham số member khác).
- Soft-delete: set `WorkspaceMember.isActive = false` cho record của `currentUser` tại workspace này — **không đụng `AgencyMember`**, user vẫn còn trong Agency và các Workspace khác đang tham gia.
- Nếu `currentUser` không phải active member của workspace này → 403 `WORKSPACE_ACCESS_DENIED` (không tìm thấy membership để leave).
- **Guard last-MANAGER:** nếu `currentUser` đang là MANAGER active DUY NHẤT của workspace → chặn, ném `LAST_OWNER_CANNOT_BE_REMOVED` (409) — phải chuyển giao MANAGER cho người khác trước (qua FR 3.4.20 Update Workspace Member Role) rồi mới leave được.

## 4. UI / UX

- Nút "Rời Workspace" trong Workspace Settings/Members (chỉ hiện với chính user đó).

## 5. API Contract

```
DELETE /api/v1/workspaces/{workspaceId}/leave
→ 200 { "success": true, "data": null }
```

Không có request body — `userId` lấy từ `AuthenticatedUser` principal (JWT), không truyền qua path/body.

## 6. Error Handling

- `currentUser` không phải active member của workspace này → 403 `WORKSPACE_ACCESS_DENIED`.
- `currentUser` là MANAGER active duy nhất của workspace → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.

## 7. Edge Cases

- MANAGER duy nhất muốn leave → phải gán MANAGER khác trước (qua Update Workspace Member Role, FR 3.4.20) rồi mới leave được.
- CREATOR/CLIENT leave khi vẫn còn nhiều thành viên khác → luôn cho phép, không có guard nào khác ngoài last-MANAGER (guard chỉ áp dụng khi role bị xóa là MANAGER).
- Gọi endpoint 2 lần liên tiếp (đã leave rồi gọi lại) → lần 2 không tìm thấy active membership → 403 `WORKSPACE_ACCESS_DENIED`.

## 8. Definition of Done

- Leave thành công qua `DELETE /{workspaceId}/leave`, vẫn còn trong Agency; chặn đúng trường hợp MANAGER duy nhất.

## Out of Scope

- Tự động chọn MANAGER thay thế khi MANAGER duy nhất leave (phải làm thủ công trước qua FR 3.4.20).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)

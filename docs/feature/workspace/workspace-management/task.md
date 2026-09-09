# Task — Quản lý Workspace (Create / Settings / Members)

## Backend (mới hoàn toàn, thứ tự build trước frontend)
- [ ] `WorkspaceRepository`, `WorkspaceInvitationRepository`, `WorkspaceMemberPermissionRepository`.
- [ ] Slug generator (kebab-case + unique suffix retry).
- [ ] `WorkspaceService.createWorkspace` — tạo Workspace + tự tạo WorkspaceMember role=OWNER.
- [ ] `POST /api/v1/workspaces`.
- [ ] `GET /api/v1/workspaces/{id}`.
- [ ] `PATCH /api/v1/workspaces/{id}/settings` (`@RequireRole({OWNER,ACCOUNT})`).
- [ ] `GET /api/v1/workspaces/{id}/members`.
- [ ] `POST /api/v1/workspaces/{id}/members/invite` (`@RequireRole({OWNER,ACCOUNT})`) + gửi email.
- [ ] `DELETE /api/v1/workspaces/{id}/members/{memberId}` (`@RequireRole({OWNER,ACCOUNT})`) + validate không xoá OWNER cuối.
- [ ] Error codes: `WORKSPACE_SLUG_CONFLICT`, `LAST_OWNER_CANNOT_BE_REMOVED`, `ALREADY_MEMBER`.

## DA-323 — Build Create Workspace page
- [ ] Sửa `authStore.ts` role type sang MemberRole (prerequisite chung).
- [ ] `workspaceService.ts` — method `create`.
- [ ] `types/workspace.ts` khớp backend field.
- [ ] `CreateWorkspacePage.tsx` — form name + industry, submit → redirect.

## DA-576 — Build Workspace Settings page
- [ ] `workspaceService.ts` — method `getById`, `updateSettings`.
- [ ] `WorkspaceSettingsPage.tsx` — timezone selector, defaultPlatforms multi-select, reportFrequency.

## DA-577 — Build Workspace Members page
- [ ] `workspaceService.ts` — method `listMembers`, `inviteMember`, `removeMember`.
- [ ] `WorkspaceMembersPage.tsx` — bảng member, nút mời (dialog form email+role), nút xoá (confirm dialog).
- [ ] Ẩn nút mời/xoá nếu role hiện tại không phải OWNER/ACCOUNT (UI-gating dựa trên `authStore`).

## Wiring chung
- [ ] `WorkspacePage.tsx` — gọi API thật thay `WORKSPACES` hardcode, nút "Tạo Workspace Mới" → `/workspaces/create`.
- [ ] Route mới trong router config.
- [ ] Cập nhật `vi.json` + `en.json` với namespace `workspace.*` (đủ key theo spec.md mục 3).
- [ ] Kiểm tra light/dark mode cho cả 3 trang mới + `WorkspacePage.tsx` sau khi sửa.
- [ ] Test luồng end-to-end qua Chrome DevTools (tạo → settings → members).

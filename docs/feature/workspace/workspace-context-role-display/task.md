# Task — Workspace Context & Role Display

## Store
- [ ] `authStore.ts` — thêm `activeWorkspaceId`, `systemRole` + setter, giữ nguyên `UserRole`/`user.role` cũ.

## Backend-facing service (frontend only, không sửa backend)
- [ ] `services/userService.ts` — file mới, method `getProfile()` gọi `GET /api/v1/users/me`.
- [ ] Type `UserProfileResponse` khớp backend record.

## Layout — nơi fetch dữ liệu
- [ ] `Layout.tsx` — `useEffect` gọi `workspaceService.list()`, set `workspaces` state.
- [ ] `Layout.tsx` — xác định `activeWorkspace` (từ `activeWorkspaceId` store, fallback workspace đầu tiên nếu id không hợp lệ).
- [ ] `Layout.tsx` — `useEffect` theo `activeWorkspace?.id` gọi `workspaceService.listMembers()`, tìm role user hiện tại → set `memberRole`.
- [ ] `Layout.tsx` — `useEffect` gọi `userService.getProfile()` 1 lần, set `systemRole` vào store.
- [ ] `Layout.tsx` — truyền `workspaces`/`activeWorkspace`/`onSwitchWorkspace`/`memberRole`/`systemRole` xuống Sidebar + Navbar.

## Sidebar
- [ ] Bỏ `WORKSPACES` hardcode array.
- [ ] Đổi prop `role` sang nhận `MemberRole | null`.
- [ ] Thêm prop `systemRole` riêng cho Admin Panel filter.
- [ ] Filter: `role === "CLIENT"` ẩn `/workspace` + `/editor` (thay `BRAND_CLIENT`).
- [ ] Workspace dropdown render từ props `workspaces`/`activeWorkspace`, `onClick` gọi `onSwitchWorkspace`.

## Navbar
- [ ] Bỏ `handleRoleSimulation`, `ROLE_LABELS` (UserRole-based), dropdown "Mô phỏng Phân quyền".
- [ ] Badge role đổi thành `<div>` tĩnh, nhận `memberRole` qua props, label qua `t(\`workspace.roles.${memberRole}\`)`.
- [ ] Badge ẩn hoàn toàn khi `memberRole` là `null` (chưa load xong hoặc user không có role ở workspace nào).

## Verify
- [ ] `tsc --noEmit` clean.
- [ ] `eslint` clean cho các file đã sửa.
- [ ] Test tay qua Chrome DevTools: login → xem role đúng → chuyển workspace → role đổi theo → chuyển lại → role đúng như cũ.
- [ ] Test tay: user là `CLIENT` ở 1 workspace → xác nhận `/workspace`, `/editor` ẩn khỏi Sidebar.
- [ ] Test tay: user có `SystemRole=ADMIN` → xác nhận Admin Panel hiện dù `MemberRole` ở workspace hiện tại không phải OWNER.

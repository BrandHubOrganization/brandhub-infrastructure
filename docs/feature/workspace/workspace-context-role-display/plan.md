# Plan — Workspace Context & Role Display

## Mục tiêu
Bỏ 2 chỗ demo-data sai nghiệp vụ trong `Sidebar.tsx`/`Navbar.tsx` (workspace hardcode, role tự chọn), thay bằng dữ liệu thật từ API đã có sẵn. Thuần frontend, không cần backend mới.

## Thành phần liên quan

**Frontend (sửa, không tạo file mới ngoài store):**
- `src/store/authStore.ts` — thêm state mới, KHÔNG xoá `UserRole`/`user.role` hiện có (còn dùng ở chỗ khác chưa migrate, xem rủi ro). Thêm:
  - `activeWorkspaceId: string | null` + `setActiveWorkspaceId(id)`.
  - `systemRole: "ADMIN" | "USER" | null` + `setSystemRole(role)`.
  - Cả 2 field mới persist qua `zustand/middleware persist` đã dùng sẵn.
- `src/components/layout/Sidebar.tsx`:
  - Bỏ `const WORKSPACES = [...]` hardcode.
  - Prop `role` đổi ý nghĩa: nhận `MemberRole | null` (không phải `UserRole` như hiện tại).
  - Filter nav: `role === "CLIENT"` ẩn `/workspace`+`/editor` (thay `role === "BRAND_CLIENT"`); Admin Panel dùng `systemRole` riêng (prop mới), không dùng `role`.
  - Workspace dropdown data từ props (Sidebar không tự fetch — nhận `workspaces: Workspace[]`, `activeWorkspace`, `onSwitchWorkspace` từ `Layout.tsx`, giữ Sidebar là component thuần trình bày).
- `src/components/layout/Navbar.tsx`:
  - Bỏ `handleRoleSimulation`, `ROLE_LABELS` (UserRole-based), dropdown "Mô phỏng Phân quyền".
  - Badge role đổi thành `<div>` tĩnh, label lấy qua `t(\`workspace.roles.${memberRole}\`)` (key đã có sẵn trong i18n).
  - Nhận `memberRole: MemberRole | null` qua props từ `Layout.tsx`.
- `src/components/layout/Layout.tsx` — trở thành nơi fetch dữ liệu (đã có `useAuthStore` sẵn):
  - `useEffect` gọi `workspaceService.list()` 1 lần khi mount (hoặc khi chưa có workspace nào trong state cục bộ) → set `workspaces` state.
  - Xác định `activeWorkspace` = tìm theo `activeWorkspaceId` trong store, fallback workspace đầu tiên nếu id không hợp lệ/null → gọi `setActiveWorkspaceId` nếu cần đổi fallback.
  - `useEffect` phụ theo `activeWorkspace?.id` — gọi `workspaceService.listMembers(activeWorkspace.id)`, tìm `m.userId === currentUserId` → set `memberRole` state (giống pattern đã dùng ở `WorkspaceMembersPage.tsx`).
  - `useEffect` gọi `userService.getProfile()` (cần tạo `userService.ts` — chưa tồn tại, xem bên dưới) 1 lần lấy `systemRole`, set vào `authStore`.
  - Truyền `workspaces`, `activeWorkspace`, `memberRole`, `systemRole` xuống `Sidebar`/`Navbar` qua props.
- `src/services/userService.ts` — **file mới**, chưa tồn tại (kiểm tra: không có `services/userService.ts` nào, chỉ `authService.me()` gọi `/auth/me` khác endpoint và không có field role). Thêm 1 method:
  ```ts
  export const userService = {
    getProfile: () => api.get<ApiResponse<UserProfileResponse>>("/api/v1/users/me"),
  };
  ```
  Type `UserProfileResponse` mirror backend record (`userId, email, fullName, avatarUrl, role, workspaceId, createdAt`).

## Quyết định kiến trúc

- **Không sửa JWT/token khi đổi workspace.** Đổi active workspace chỉ đổi state cục bộ (`authStore.activeWorkspaceId`) — không gọi refresh token, không có endpoint "switch workspace" ở backend. `AuthenticatedUser.workspaceId` (JWT claim) chỉ dùng cho các API cần "workspace hiện tại của tôi theo token" (không có trong Sidebar/Navbar) — các API gọi ở đây (`GET /workspaces`, `GET /workspaces/{id}/members`) đều nhận `workspaceId` qua path/query, không phụ thuộc JWT claim. Ghi nhận: đây là lý do plan `workspace-management` cũ (dòng 42, rủi ro JWT 1-workspaceId) không còn chặn feature này — vì Sidebar/Navbar không dùng claim đó.
- **Không xoá `UserRole`/`authStore.user.role` khỏi codebase.** 8 file cũ (`DashboardPage.tsx` đã sửa trước đó, `types/user.ts`, và các trang chưa migrate) vẫn tham chiếu — theo quyết định trước ("Không đổi authStore/8 file cũ"), giữ nguyên `UserRole` tồn tại song song, chỉ Sidebar/Navbar không dùng nó nữa cho việc filter/hiển thị.
- **`Sidebar.tsx` thành presentational component** — không tự fetch, nhận data qua props từ `Layout.tsx`. Lý do: `Layout.tsx` đã là nơi duy nhất giữ `collapsed`/`mobileOpen` state và truyền xuống cả `Sidebar` lẫn `Navbar` — giữ pattern nhất quán, tránh 2 nơi tự fetch cùng 1 API.
- **Không tạo endpoint "GET my role in workspace X" riêng ở backend.** Dùng lại `GET /workspaces/{id}/members` rồi filter client-side (đúng pattern `WorkspaceMembersPage.tsx` đã làm) — chấp nhận tốn băng thông hơn 1 endpoint chuyên biệt, nhưng tránh thêm API mới ngoài scope đã chốt ở spec.md.

## Thứ tự build

1. `authStore.ts` — thêm `activeWorkspaceId`/`systemRole` + setter, verify không phá `UserRole` cũ (`tsc` sau bước này).
2. `services/userService.ts` — file mới, method `getProfile()`.
3. `Layout.tsx` — thêm 3 `useEffect` (workspaces list, member role theo active workspace, system role), truyền props xuống Sidebar/Navbar.
4. `Sidebar.tsx` — đổi prop signature nhận `workspaces`/`activeWorkspace`/`onSwitchWorkspace`/`role: MemberRole | null`/`systemRole`, bỏ `WORKSPACES` hardcode, sửa filter logic.
5. `Navbar.tsx` — bỏ role simulator, đổi badge thành tĩnh nhận `memberRole` qua props.
6. Test tay qua Chrome DevTools: login → xem role đúng ở workspace hiện tại → tạo/join workspace thứ 2 (dùng lại flow đã build trước) → chuyển qua lại, xác nhận role đổi theo.
7. `tsc --noEmit` + `eslint` toàn bộ file đã sửa.

## Rủi ro

- `Layout.tsx` gọi 3 API tuần tự sau mỗi lần mount/đổi workspace (`list workspaces`, `list members` để suy role, `users/me` cho systemRole) — không có cache, có thể gọi lại nhiều lần nếu user chuyển route qua lại trong `Layout` (React Router không unmount `Layout` khi đổi route con, nên chỉ chạy lại khi `activeWorkspace?.id` đổi — chấp nhận được, không phải bug nhưng cần verify bằng DevTools Network tab lúc test tay).
- Nếu user có nhiều workspace và danh sách lớn, việc suy role bằng cách gọi full `listMembers` rồi filter có thể chậm ở workspace đông member — chấp nhận theo quyết định "không tạo endpoint mới" ở trên, tối ưu sau nếu cần (ghi trong Out of Scope của spec.md).

# UC — Workspace Context & Role Display (bỏ Role Simulator, hiển thị role thật theo workspace)

| | |
|---|---|
| Feature | Workspace context switcher + role display |
| Version | 1.0 |
| Nhóm | B. Chức năng workspace |

## 1. Objective

Sidebar/Navbar hiện tại dùng dữ liệu demo sai nghiệp vụ:
- Workspace switcher (`Sidebar.tsx`) hardcode 3 workspace giả (`WORKSPACES` array), không load workspace thật của user.
- "Role Simulator" (`Navbar.tsx`, `handleRoleSimulation`) cho user tự chọn role bất kỳ — sai hoàn toàn: role trong 1 workspace do OWNER/ACCOUNT của workspace đó quyết định qua invite (`WorkspaceMember.role`), user không tự đổi được.

Feature này thay 2 chỗ demo bằng dữ liệu thật: workspace switcher gọi API thật, role hiển thị (đọc-only) = `MemberRole` của user tại workspace đang active — đổi workspace thì role hiển thị đổi theo.

## 2. User Story

Là một user đã đăng nhập và là member của nhiều workspace,
tôi muốn chuyển đổi giữa các workspace của mình và luôn thấy đúng role tôi đang có ở workspace đó,
để biết mình có quyền làm gì mà không cần tự chọn/giả lập role.

## 3. Acceptance Criteria

### Active Workspace State
- Sau login, active workspace mặc định = workspace đầu tiên trong danh sách `GET /api/v1/workspaces` (hoặc workspace đã lưu từ lần trước, nếu còn hợp lệ).
- Active workspace id lưu persist (localStorage qua `authStore` hoặc store riêng) để giữ nguyên qua reload.
- Đổi workspace qua dropdown Sidebar → cập nhật active workspace id, re-fetch role của user tại workspace mới, không reload trang.

### Role Display (đọc-only)
- Badge "Role: Creator" trong `Navbar.tsx` đổi từ dropdown-chọn-được thành hiển thị tĩnh, lấy từ `MemberRole` của user tại workspace đang active.
- Bỏ hoàn toàn `handleRoleSimulation`, `ROLE_LABELS` dùng `UserRole`, dropdown "Mô phỏng Phân quyền" trong `Navbar.tsx`.
- Role hiển thị dùng nhãn tiếng Việt theo `MemberRole`: OWNER→Chủ sở hữu, CREATOR→Người tạo nội dung, VIEWER→Người xem, CLIENT→Khách hàng, ACCOUNT→Quản lý tài khoản (khớp key `workspace.roles.*` đã có sẵn trong i18n).

### Nav Filtering theo MemberRole
- `Sidebar.tsx` filter menu theo `MemberRole` (không còn theo `UserRole`):
  - `CLIENT` không thấy `/workspace`, `/editor` (tương đương rule cũ của `BRAND_CLIENT`).
  - Menu khác hiển thị cho tất cả role còn lại (OWNER/CREATOR/VIEWER/ACCOUNT).
- `WORKSPACES` hardcode array trong `Sidebar.tsx` bị xoá, thay bằng data từ `GET /api/v1/workspaces` (dùng lại `workspaceService.list()` đã có).

### Admin Panel — tách riêng khỏi MemberRole
- Mục "Admin Panel" trong Sidebar hiện theo `SystemRole` (cấp hệ thống, từ `GET /api/v1/users/me` → field `role`), độc lập hoàn toàn với `MemberRole` của workspace đang active.
- Gọi `GET /api/v1/users/me` một lần sau login (hoặc khi chưa có SystemRole trong store), lưu `systemRole` vào `authStore` tách biệt với workspace-role.

### Đa ngôn ngữ (i18n)
- Không thêm text mới ngoài các key `workspace.roles.*` đã tồn tại — tái dùng, không hardcode chuỗi Việt/Anh mới trong Sidebar/Navbar.
- Nếu cần label "Chọn Workspace" — đã có sẵn hardcode tiếng Việt trong `Sidebar.tsx` hiện tại (không phải lỗi mới, nhưng nếu sửa file nên tiện thể chuyển qua `t()` với key `workspace.list.*` nếu khớp nghĩa).

### Light/Dark mode
- Giữ nguyên toàn bộ token theme đã dùng đúng trong `Sidebar.tsx`/`Navbar.tsx` (CSS variable `--sidebar`, `--brand-orange`, v.v.) — không đổi cấu trúc theme, chỉ đổi nguồn dữ liệu.

## 4. UI / UX

- Workspace switcher: giữ nguyên UI dropdown hiện có trong `Sidebar.tsx` (avatar 2-ký-tự, tên, "Workspace" label) — chỉ đổi data source.
- Role badge: giữ nguyên vị trí/style hiện có trong `Navbar.tsx` (icon `ShieldAlert`, border-dashed cam) — bỏ `DropdownMenuTrigger`/`DropdownMenuContent`, đổi thành `<div>` tĩnh không click được.
- Khi user chưa là member của workspace nào (0 workspace) — Sidebar switcher hiện trạng thái rỗng, không render dropdown item nào; nav filter coi như không có role, ẩn hết menu "Quản lý" phụ thuộc workspace.

### UI States
- Loading: khi đang fetch danh sách workspace hoặc role, badge role hiện skeleton/placeholder ngắn (`...`) thay vì để trống đột ngột.
- Error: fetch workspace/role lỗi → fallback về không hiển thị badge role (ẩn), không chặn render Sidebar.

## 5. API Contract (đã có sẵn, không cần API mới)

```
GET /api/v1/workspaces
→ danh sách workspace user là active member (đã build, dùng lại)

GET /api/v1/workspaces/{workspaceId}/members
→ lấy list member, tìm current user theo userId để lấy role tại workspace đó
(đã build, dùng lại — không có endpoint "GET my role in this workspace" riêng,
tái dùng cách WorkspaceMembersPage.tsx đã làm: find(m => m.userId === currentUserId))

GET /api/v1/users/me
→ trả UserProfileResponse.role (SystemRole: ADMIN/USER) — đã build, dùng lại
```

Không cần backend mới cho feature này — thuần frontend, ghép nối API đã tồn tại.

## 6. Error Handling

- `GET /api/v1/workspaces` lỗi → Sidebar hiện switcher rỗng, toast lỗi generic (`common.loadFailed`).
- `GET /api/v1/workspaces/{id}/members` lỗi (để tìm role) → badge role ẩn, không toast (tránh spam lỗi phụ, không phải hành động user chủ động).
- `GET /api/v1/users/me` lỗi → coi như không phải ADMIN, ẩn Admin Panel (fail-safe, không lộ menu nhạy cảm khi không xác định được quyền).

## 7. Edge Cases

- User là member của 0 workspace (vừa đăng ký, chưa tạo/được mời workspace nào) → Sidebar switcher rỗng, badge role ẩn, menu "Quản lý → Workspaces" vẫn hiện (để user vào tạo workspace mới).
- User bị remove khỏi workspace đang active trong lúc đang dùng (isActive=false) → lần fetch role tiếp theo không tìm thấy user trong member list → badge role ẩn (không crash), nhưng KHÔNG tự động chuyển active workspace khác trong scope feature này (out of scope: tồn tại nhưng không tự phát hiện — chỉ xử lý khi user F5 lại).
- Active workspace id lưu trong localStorage trỏ tới workspace user không còn là member (bị remove ở session trước) → khi load lại danh sách `GET /api/v1/workspaces`, nếu id đã lưu không nằm trong danh sách mới → fallback về workspace đầu tiên trong danh sách.

## 8. Definition of Done

- Toàn bộ Acceptance Criteria mục 3 đạt.
- `Sidebar.tsx`: bỏ `WORKSPACES` hardcode, gọi `workspaceService.list()`, filter nav theo `MemberRole`.
- `Navbar.tsx`: bỏ `handleRoleSimulation`/dropdown mô phỏng role, badge role tĩnh đọc từ `MemberRole` của workspace active.
- `authStore.ts` hoặc store mới: có state `activeWorkspaceId`, `systemRole` tách biệt.
- Test case mục test.md pass.
- `tsc --noEmit`, `eslint` clean.

## Out of Scope

- Tự động chuyển active workspace khi user bị remove khỏi workspace đang xem (chỉ xử lý ở lần load lại).
- Cache/optimize số lần gọi `GET /api/v1/workspaces/{id}/members` (hiện tại gọi full list rồi filter client-side, giống pattern `WorkspaceMembersPage.tsx` — chưa có endpoint "my role" riêng, không tạo mới trong scope này).
- Đổi UI style/redesign khác — chỉ đổi nguồn dữ liệu, giữ nguyên giao diện hiện có.

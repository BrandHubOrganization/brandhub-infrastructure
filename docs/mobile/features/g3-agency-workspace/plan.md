# Plan — G3 Agency / Workspace (Mobile)

> [spec.md](./spec.md) — chi tiết API/flows/business rules đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **Infra trước — G4-G7 phụ thuộc trực tiếp vào store này:**
   - `useCurrentWorkspaceStore` (Zustand): `currentWorkspace`, `currentMemberRole` (derive từ `myRole`, KHÔNG set tay riêng), `currentAgencyId` (derive từ `agencyId`).
   - Persist chỉ `currentWorkspace.id` vào AsyncStorage/SecureStore (không persist cả object) — fetch lại `GET /workspaces/{id}` khi app mở lại để tránh stale data.
   - Clear store khi logout, đồng bộ với `clearAuth()` (G1) — tránh lẫn session user khác.
2. **Agency screens:** List → Dashboard/Profile → Member List + drawer → Invite modal → Pending Invitations.
3. **Workspace screens:** List theo Agency đã chọn → Detail (tab Profile **chặn bởi `timezoneConfig` thiếu field**, tab Members) → Invite/Assign/Update-Role/Remove Member → Leave Workspace → Workspace Switcher.

## Quyết định kỹ thuật đã chốt

- **Role luôn đọc theo `currentWorkspace.myRole`, không cache 1 role duy nhất per-user toàn app** — 1 user có thể là MANAGER ở Workspace X nhưng chỉ CREATOR ở Workspace Y cùng 1 Agency (CONFIRMED trong BA doc).
- **Workspace Switcher = "role switcher" duy nhất** — không có màn role switcher riêng, role luôn gắn theo workspace đang chọn.
- **2 tầng permission tách biệt**: Agency-level (check `ownerId`, không dùng `MemberRole`) và Workspace-level (`@RequireRole(MemberRole...)`). UI phải phân biệt rõ, không gộp chung logic hiển thị quyền.
- **Điều kiện add vào Workspace**: user phải đã là Agency Member trước — nếu chưa, UI chặn/gợi ý "Invite to Agency first" thay vì gọi API rồi nhận lỗi 409 (UX chủ động, không dựa vào lỗi server).

## Việc cần xác nhận trước khi code (chưa làm, xem spec mục 8)

- `timezoneConfig` thiếu trong `WorkspaceResponse` dù model `Workspace.java` có field này — **chặn thiết kế UI Workspace Profile**, cần hỏi BE bổ sung field hay dùng API khác.
- `AgencyMemberProfileResponse`/`AuditLogResponse` chưa đọc chi tiết field — đọc trước khi code Member Profile drawer; có thể cắt Activity Feed ở bản đầu để giảm scope.
- `ManagedWorkspaceResponse` (`/workspaces/my-managed`) chưa đọc field — đọc trước khi code shortcut "My Managed Workspaces".
- Deep-link accept invitation qua token — xác nhận Expo app đã config scheme `brandhub` (đã chốt ở G1) có dùng lại được cho flow này không.
- Agency Owner xem Workspace không phải Manager/Member — hành vi thật của `@RequireRole` + service layer override cần test API thật trước khi dựa vào.

## Rủi ro còn mở

- Nếu backend chưa bổ sung `timezoneConfig`, mobile tạm thời ẩn field Timezone ở Workspace Profile thay vì hiển thị sai/trống — cần quyết định UI fallback trước khi code màn này.

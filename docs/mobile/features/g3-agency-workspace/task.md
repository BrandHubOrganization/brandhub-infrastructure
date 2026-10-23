# Task — G3 Agency / Workspace (Mobile)

> [spec.md](./spec.md)

**Trạng thái: ĐÃ CODE XONG (2026-10-23)** — backend + mobile, bao gồm TanStack Query refactor và ClientProfile picker (xem mục cuối). Code thật tại `brandhub-mobile-app/src/{screens/agency,screens/workspace,services,store,navigation}`.

## Infra / state

- [x] `useWorkspaceStore` (Zustand, `src/store/workspaceStore.ts`) — `currentWorkspace`, `currentMemberRole` (derive từ `myRole`), `currentAgencyId` (derive từ `agencyId`), `setCurrentWorkspace()`, `reset()`, `switchWorkspace()`.
- [x] Persist `currentWorkspace.id` (không persist cả object) vào `expo-secure-store` — `restore()` fetch lại `GET /workspaces/{id}` khi app mở lại (gọi trong `AppNavigator` sau `authStore.bootstrap()`).
- [x] Clear store khi logout — `authStore.clearAuth()` gọi `useWorkspaceStore.getState().reset()` đồng bộ.
- [x] TanStack Query key structure (`src/services/queryKeys.ts`) — `agencies.list()`, `agencies.detail(id)`, `agencies.stats(id)`, `agencies.members(id)`, `agencies.memberProfile(agencyId,userId)`, `agencies.invitations(id)`, `agencies.myPendingInvitations()`, `workspaces.list()`, `workspaces.detail(id)`, `workspaces.members(id)`, `workspaces.myManaged()`. Toàn bộ 11 screen G3 dùng `useQuery`/`useMutation`, invalidate đúng key sau mỗi mutation (invite/remove/update role/accept/decline). Accept invitation invalidate thêm `workspaces.list()` để Picker/Switcher không stale.

## Agency screens

- [x] Agency List (FR 3.4.1) — `AgencyListScreen.tsx`, `GET /agencies`, truy cập từ Settings → "Agency của tôi".
- [x] Agency Dashboard (FR 3.4.2) — gộp vào `AgencyDetailScreen.tsx`, `GET /agencies/{id}/stats` (memberCount/workspaceCount).
- [x] Agency Profile (FR 3.4.4) — `AgencyDetailScreen.tsx`, `GET /agencies/{id}`.
- [x] Agency Member List (`AgencyMembersScreen.tsx`) + Member Profile drawer (`MemberProfileScreen.tsx`) — info cơ bản (fullName/email/phone/professionalTitle) + list workspace+role. Activity Feed (`AuditLogResponse`) **cắt ở bản này** theo đúng gợi ý task.md gốc.
- [x] Invite Agency Member modal (FR 3.4.7) — `AgencyInviteScreen.tsx`, `POST /agencies/{id}/invitations`, OWNER only.
- [x] Pending Invitations screen — `AgencyInvitationsScreen.tsx` (phía Owner, `GET /agencies/{id}/invitations` + revoke) và `MyInvitationsScreen.tsx` (phía được mời, `GET /agencies/invitations/my-pending`, Accept/Decline).

## Workspace screens

- [x] Workspace List theo Agency (FR 3.4.10) — `WorkspacePickerScreen.tsx`, `GET /workspaces`.
- [x] Workspace Detail — `WorkspaceDetailScreen.tsx` (FR 3.4.13). `timezoneConfig` **đã thêm vào `WorkspaceResponse`** (backend fix, xem mục Bug đã sửa).
- [x] Tab Members (FR 3.4.18) — `WorkspaceMembersScreen.tsx`, `GET /workspaces/{id}/members`, role badge.
- [x] Invite/Assign Member modal (FR 3.4.19) — `WorkspaceInviteMemberScreen.tsx`, chỉ hiện nếu `currentMemberRole === MANAGER`; chặn UI nếu email chưa là Agency Member (check client-side qua `agencyService.listMembers`, hiện hint "mời vào Agency trước" thay vì gọi API nhận lỗi 409).
- [x] Update Member Role (FR 3.4.20) + Remove Member (FR 3.4.21) — long-press trong `WorkspaceMembersScreen.tsx`, MANAGER only.
- [x] Leave Workspace (FR 3.4.16) — nút ở `WorkspaceDetailScreen.tsx`, ẩn với OWNER.
- [x] Workspace Switcher — `SettingsScreen.tsx` nút "Đổi Workspace" (`switchWorkspace()` → quay lại `WorkspacePickerScreen`). Shortcut "My Managed Workspaces" — `ManagedWorkspacesScreen.tsx`, `GET /workspaces/my-managed`.

## Business rules đã enforce ở client

- [x] Không cache 1 "role" duy nhất per-user toàn app — luôn đọc `currentMemberRole` từ `workspaceStore` (derive theo `currentWorkspace.myRole` mỗi lần set).
- [x] UI phân biệt 2 tầng permission: Agency-level (`ownerId`, check qua `agency.myRole === "OWNER"`) vs Workspace-level (`currentMemberRole` MANAGER/CREATOR/CLIENT).
- [x] Hiển thị đúng status invitation (Pending/Accepted/Rejected/Expired) qua `STATUS_LABEL` map trong `AgencyInvitationsScreen`/`MyInvitationsScreen` — hết hạn tự động phía BE, mobile chỉ đọc field `status` trả về, không tự tính.
- [x] Remove Agency/Workspace Member — không có cảnh báo mất dữ liệu (đúng theo rule, tài nguyên họ tạo không bị xoá theo).

## Chưa làm / out of scope G3 (xem spec mục 7)

- [ ] Không làm: Create/Update/Remove Agency, Create/Update/Delete Workspace, Save Workspace Template, Billing/Subscription Workspace, Duplicate Workspace, Workspace Settings update (logo/banner).
- [ ] Activity Feed trong Member Profile drawer (`AuditLogResponse`) — cắt khỏi bản đầu, API `/members/{userId}/activity` đã có sẵn, chưa code UI.

## Bug backend đã phát hiện + sửa trong lúc code (2026-10-23)

1. **`timezoneConfig` thiếu trong `WorkspaceResponse`** — không phải thiết kế thiếu, chỉ thiếu wiring 1 dòng (`Workspace.getTimezoneConfig()` có sẵn, DTO record quên thêm field). Đã sửa `WorkspaceResponse.java` + 2 call site (`WorkspaceServiceImpl.toResponse()`, `WorkspaceTemplateServiceImpl`).
2. **Agency Owner xem Workspace bị 403 — dead code thật**: `WorkspaceServiceImpl.getWorkspace()` có logic gán `myRole = "OWNER"` cho Agency Owner (dòng ~205-210) nhưng **không bao giờ chạy tới** vì `assertMember()` throw `WORKSPACE_ACCESS_DENIED` trước đó — `assertMember` không hề check Agency Owner. Thêm nữa, `@RequireRole({MANAGER, CREATOR, CLIENT})` ở `WorkspaceController` (3 endpoint: `getWorkspace`, `getDashboard`, `listMembers`) thiếu `MemberRole.OWNER` trong list allowed, nên fallback Owner có sẵn trong `RequireRoleAspect` (dòng 86-93, check `allowed.contains(MemberRole.OWNER)`) cũng không bao giờ kích hoạt. Đã sửa cả annotation (thêm `OWNER`) và `assertMember()` (thêm check Agency Owner) ở cả 3 endpoint.

## ClientProfile picker cho CLIENT accept invitation (bổ sung 2026-10-23)

Ban đầu chặn: CLIENT role cần chọn/tạo `ClientProfile` lúc accept invitation (field `clientProfileId` hoặc `newClientProfile` trong `AcceptInvitationRequest`), mobile chưa có UI nên yêu cầu dùng web. Đã bổ sung đầy đủ:

- `AcceptInvitationScreen.tsx` — khi `invitation.role === "CLIENT"`, hiện picker chọn 1 trong `myClientProfiles` có sẵn, hoặc form tạo mới (`displayName` bắt buộc, `company`/`phone` tùy chọn — đúng theo `ClientProfileRequest`, không thêm field khác).
- `MyInvitationsScreen.tsx` — nút "Nhận" với invitation CLIENT navigate sang `AcceptInvitationScreen` (dùng chung picker, không duplicate UI).
- Sửa luôn 1 type-mismatch: `agencyService.ts` khai `InvitationPreview.myClientProfiles: {id, name}[]` sai field — backend trả `ClientProfileResponse` thật có field `displayName`, không có `name`.

**Kết quả: CLIENT giờ accept/decline invitation hoàn toàn trên mobile, không cần mở web.** Sau khi đã là member của workspace (bất kể role), mọi tính năng khác (G1 auth, G2 upload, G3 workspace/agency view) hoạt động bình thường như MANAGER/CREATOR — không có giới hạn nào khác ngoài bước accept lần đầu này.

## Rủi ro còn mở (không block, hỏi team sau)

1. Deep-link `brandhub://invite?token=...` — đã config `scheme` trong `app.json` + `linking` trong `AppNavigator`, nhưng **backend `MailServiceImpl` hiện chỉ build link web** (`frontendUrl/invitations/accept?token=`) trong email mời, chưa có link `brandhub://`. Cần team xác nhận có bổ sung mobile deep-link trong email không, nếu không thì luồng "mở link từ email → vào thẳng app" chưa hoạt động thật (chỉ `MyInvitationsScreen` trong app hoạt động được).
2. Deep-link accept chỉ resolve được khi app đang ở `MainTabNavigator` (đã login + đã chọn workspace) — nếu mở link lúc chưa login, route không khớp và bị bỏ qua lặng lẽ.

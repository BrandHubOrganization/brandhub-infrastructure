# G3 — Agency / Workspace (Mobile)

> [<< Về mobile-app-plan](../mobile-app-plan.md) — G3 trong bảng giai đoạn tổng thể.
> Nguồn BA: [03-agency-workspace-management.md](../../ba/03-agency-workspace-management.md), [01-organization-structure.md](../../ba/01-organization-structure.md), [10-roles-permissions-matrix.md](../../ba/10-roles-permissions-matrix.md), use-case [02-agency-workspace.md](../../ba/use-cases/02-agency-workspace.md).
> Nguồn code: `brandhub-business-service/.../controller/AgencyController.java`, `WorkspaceController.java`, model `Agency.java`/`Workspace.java`/`AgencyMember.java`/`WorkspaceMember.java`, enum `MemberRole.java`/`AgencyMemberRole.java`.
> Ground truth tham chiếu UX thật: `brandhub-web/src/store/agencyStore.ts`, `workspaceStore.ts`, `services/agencyService.ts`, `services/workspaceService.ts`.

**Lưu ý role quan trọng (đã đọc code, khác giả định ban đầu):** enum `MemberRole` thực tế trong code chỉ có **`OWNER, MANAGER, CREATOR, CLIENT`** (file `model/enums/MemberRole.java`) — KHÔNG có `ADMIN`/`GUEST` ở cấp này, và không có giá trị `MEMBER` riêng (member nội dung thường = role `CREATOR`). `ADMIN` là role hệ thống tách biệt (`09-admin-management.md`), `GUEST` là trạng thái chưa đăng nhập. Agency-level còn có enum riêng `AgencyMemberRole` (OWNER/MEMBER) dùng cho `AgencyMember.role`, độc lập với `MemberRole` của Workspace.

## 1. Mục tiêu & phạm vi

Mobile G3 làm bản thu nhỏ của web cho domain Agency/Workspace, gồm:

- List Agency mà user sở hữu (`myRole` = OWNER qua `AgencyResponse.myRole`), xem Agency Dashboard/Profile.
- List Workspace theo Agency đã chọn (Owner thấy toàn bộ, member chỉ thấy workspace mình có mặt).
- Xem Workspace Detail: profile + timezone, danh sách Workspace Member kèm role.
- Invite Member — cả 2 tầng: invite vào Agency (FR 3.4.7) và add/invite vào Workspace cụ thể (FR 3.4.19).
- Theo dõi trạng thái lời mời đang chờ (pending invitations) của chính mình.
- Role switcher / Workspace switcher — màn chọn "workspace đang làm việc" (current workspace context), vì hầu hết các màn hình G4–G7 sau này phụ thuộc vào lựa chọn này.

## 2. FR tham chiếu

| FR | Tên | Role bắt buộc (theo `10-roles-permissions-matrix.md`) |
|---|---|---|
| 3.4.1 | List Agency | OWNER (agency) |
| 3.4.2 | View Agency Dashboard | OWNER |
| 3.4.4 | View Agency Profile | OWNER |
| 3.4.7 | Invite Agency Member | OWNER |
| 3.4.8 | View Agency Invitation Status | OWNER / USER (invited) |
| 3.4.9 | Remove Agency Member | OWNER |
| 3.4.10 | List Workspace | OWNER (toàn bộ) / MEMBER (của mình) |
| 3.4.11 | View Workspace Dashboard | OWNER / MANAGER / CREATOR / CLIENT |
| 3.4.13 | View Workspace Profile | MANAGER (+ Agency OWNER kế thừa) |
| 3.4.16 | Leave Workspace | MEMBER (bất kỳ role Workspace) |
| 3.4.18 | View Workspace Members | MANAGER / CREATOR / CLIENT |
| 3.4.19 | Add Workspace Member | MANAGER |
| 3.4.20 | Update Workspace Member Role | MANAGER |
| 3.4.21 | Remove Workspace Member | MANAGER |

Không nằm trong G3 (xem mục 7): 3.4.3 Create Agency, 3.4.5 Update Agency Profile, 3.4.6 Remove/Restore Agency, 3.4.12 Create Workspace, 3.4.14 Update Workspace Profile, 3.4.15 Delete/Restore Workspace, 3.4.17 Save Workspace Template.

## 3. API cần dùng

Base path business-service: `/api/v1/agencies`, `/api/v1/workspaces`. Auth: Bearer token hiện có (tái dùng từ G1).

### 3.1 Agency

| Method | Path | Request | Response | Ghi chú |
|---|---|---|---|---|
| GET | `/api/v1/agencies` | — | `List<AgencyResponse>` | FR 3.4.1 — chỉ agency mà `ownerId` = current user |
| GET | `/api/v1/agencies/{agencyId}` | — | `AgencyResponse` | FR 3.4.4 |
| GET | `/api/v1/agencies/{agencyId}/stats` | query `from`,`to` (yyyy-MM-dd, optional) | `AgencyStatsResponse` | FR 3.4.2 dashboard, lọc theo khoảng ngày nếu truyền |
| GET | `/api/v1/agencies/{agencyId}/members` | — | `List<AgencyMemberResponse>` | |
| GET | `/api/v1/agencies/{agencyId}/members/{userId}/profile` | — | `AgencyMemberProfileResponse` | member detail drawer — contact info + role từng workspace |
| GET | `/api/v1/agencies/{agencyId}/members/{userId}/activity` | — | `List<AuditLogResponse>` | activity feed, có thể bỏ ở MVP mobile nếu ưu tiên thời gian |
| POST | `/api/v1/agencies/{agencyId}/invitations` | `InviteAgencyMemberRequest` | `AgencyInvitationResponse` | FR 3.4.7 |
| GET | `/api/v1/agencies/{agencyId}/invitations` | — | `List<AgencyInvitationResponse>` | FR 3.4.8, phía Owner |
| DELETE | `/api/v1/agencies/{agencyId}/invitations/{invitationId}` | — | — | huỷ lời mời đang pending |
| DELETE | `/api/v1/agencies/{agencyId}/members/{memberId}` | — | — | FR 3.4.9 |
| GET | `/api/v1/agencies/invitations/preview?token=` | — | `InvitationPreviewResponse` | xem trước lời mời trước khi accept (deep-link từ email) |
| POST | `/api/v1/agencies/invitations/accept` | `AcceptInvitationRequest` | `AgencyMemberResponse` | |
| GET | `/api/v1/agencies/invitations/my-pending` | — | `List<AgencyInvitationResponse>` | FR 3.4.8, phía người được mời |
| POST | `/api/v1/agencies/invitations/decline` | `DeclineInvitationRequest` | — | |

`AgencyRequest` (body cho create/update, G3 không dùng — xem mục 7) có field: `name, logoUrl, bannerUrl, description, category, companySize, website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl`.

`AgencyResponse` fields: `id, name, ownerId, logoUrl, bannerUrl, description, category, companySize, website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, status, createdAt, updatedAt, myRole (AgencyMemberRole: OWNER|MEMBER)`.

`InviteAgencyMemberRequest`: `email* (NotBlank, @Email), inviteeName, note, workspaceId (optional — nếu kèm sẵn 1 workspace+role), role (MemberRole, optional), expiryDays`.

`AgencyInvitationResponse`: `id, agencyId, agencyName, invitedEmail, invitedBy, token, note, workspaceId, workspaceName, role (MemberRole), status (InvitationStatus), expiresAt, acceptedAt, createdAt`.

**Error case chung:** 403 nếu không phải Owner của agency đó; 404 nếu agencyId không tồn tại/đã soft-delete; 409 khi invite email đã là member/đã có lời mời pending trùng.

### 3.2 Workspace

| Method | Path | Request | Response | Ghi chú |
|---|---|---|---|---|
| GET | `/api/v1/workspaces` | — | `List<WorkspaceResponse>` | FR 3.4.10 — BE tự lọc theo quyền (Owner: toàn Agency; member: chỉ workspace mình có mặt). Field `myRole` trả `"OWNER"` hoặc tên `MemberRole` |
| GET | `/api/v1/workspaces/my-managed` | — | `List<ManagedWorkspaceResponse>` | workspace mà user đang là MANAGER — dùng cho shortcut |
| GET | `/api/v1/workspaces/{workspaceId}` | — | `WorkspaceResponse` | `@RequireRole(MANAGER, CREATOR, CLIENT)` — Agency Owner luôn pass thêm ở service layer |
| GET | `/api/v1/workspaces/{workspaceId}/dashboard` | — | `WorkspaceDashboardResponse` | FR 3.4.11 |
| GET | `/api/v1/workspaces/{workspaceId}/members` | — | `List<WorkspaceMemberResponse>` | FR 3.4.18, `@RequireRole(MANAGER, CREATOR, CLIENT)` |
| POST | `/api/v1/workspaces/{workspaceId}/members/invite` | `InviteMemberRequest` | — | FR 3.4.19 kiểu invite-qua-email, `@RequireRole(MANAGER)`. **Lưu ý:** service sẽ reject nếu email chưa là Agency Member (phải invite agency trước — UC-18/29 A1) |
| POST | `/api/v1/workspaces/{workspaceId}/members/assign` | `AssignWorkspaceMembersRequest` | `AssignMembersResponse` | FR 3.4.19 kiểu gán trực tiếp Agency Member có sẵn (list `{userId, role}`), `@RequireRole(MANAGER)` |
| PATCH | `/api/v1/workspaces/{workspaceId}/members/{memberId}/role` | `UpdateMemberRoleRequest{role}` | `WorkspaceMemberResponse` | FR 3.4.20, `@RequireRole(MANAGER)` |
| DELETE | `/api/v1/workspaces/{workspaceId}/members/{memberId}` | — | — | FR 3.4.21, `@RequireRole(MANAGER)` |
| DELETE | `/api/v1/workspaces/{workspaceId}/leave` | — | — | FR 3.4.16, member tự rời |
| POST | `/api/v1/workspaces/invitations/accept` | `AcceptInvitationRequest{token, clientProfileId?, newClientProfile?}` | `WorkspaceMemberResponse` | |
| GET | `/api/v1/workspaces/invitations/my-pending` | — | `List<InvitationResponse>` | |
| POST | `/api/v1/workspaces/invitations/decline` | `DeclineInvitationRequest` | — | |

`WorkspaceResponse` fields: `id, name, agencyId, settings (WorkspaceSettings), industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, bannerUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, createdAt, myRole (String: "OWNER" | MemberRole name | null — chỉ populate ở listMyWorkspaces), clientProfileId (chỉ có giá trị khi myRole=="CLIENT")`.

Model `Workspace.java` còn field `timezoneConfig` (default `"Asia/Ho_Chi_Minh"`) — **không có trong `WorkspaceResponse` hiện tại**, cần xác nhận lại với BE trước khi code màn hình Workspace Profile hiển thị Timezone (FR 3.4.13 yêu cầu hiển thị field này) — xem mục 8 rủi ro.

`WorkspaceMemberResponse` fields: `id, workspaceId, userId, fullName, email, clientProfileId, role (MemberRole), joinedAt, isActive`.

`InviteMemberRequest`: `email* (@Email), role* (MemberRole), note`.

`AssignWorkspaceMembersRequest`: `members: [{userId*, role*(MemberRole)}]` — dùng khi gán Agency Member có sẵn vào workspace (không qua email invite lại).

**Error case chung:** 403 nếu không phải MANAGER của workspace (và không phải Owner của Agency cha); 404 workspace không tồn tại/đã soft-delete; 409 khi assign user chưa thuộc Agency (phải invite Agency trước, theo UC-29 A1).

## 4. Luồng màn hình

```
Agency List (FR 3.4.1)
  → chọn 1 Agency → Agency Dashboard (FR 3.4.2) / Agency Profile (FR 3.4.4)
       → tab "Members" → Agency Member List (FR 3.4.9 context)
             → nút "Invite" → Invite Agency Member modal (FR 3.4.7)
             → tap 1 member → Member Profile drawer (API /members/{userId}/profile)
       → tab "Workspaces" (hoặc màn Workspace List riêng, điều hướng từ bottom tab)
             → Workspace List theo Agency đã chọn (FR 3.4.10)
                   → chọn 1 Workspace → Workspace Detail
                         - Tab Profile: fields + timezone (FR 3.4.13, xem rủi ro mục 8)
                         - Tab Members: Workspace Member List kèm role badge (FR 3.4.18)
                               → nút "Invite Member" (chỉ hiện nếu currentMemberRole==MANAGER) → Invite/Assign Member modal (FR 3.4.19)
                               → long-press 1 member (MANAGER only) → đổi role (FR 3.4.20) / remove (FR 3.4.21)
                         - Nút "Leave Workspace" (mọi role trừ khi là Agency Owner độc quyền) (FR 3.4.16)
                   → chọn Workspace làm "current" → Workspace Switcher cập nhật context toàn app
Workspace Switcher (modal/bottom-sheet, mở từ header mọi màn hình chính)
  → list workspace user có mặt (GET /workspaces) → chọn 1 → set currentWorkspace vào Zustand store
Pending Invitations (badge ở Notification hoặc tab riêng)
  → list GET /agencies/invitations/my-pending + GET /workspaces/invitations/my-pending
  → Accept (deep-link từ email dùng token qua preview endpoint) / Decline
```

Role switcher ở đây = Workspace Switcher (không có "role switcher" riêng — role luôn gắn theo workspace đang chọn, đúng nguyên tắc cốt lõi ở mục 6).

## 5. State & cache

### TanStack Query key structure

```
["agencies", "list"]
["agencies", agencyId]
["agencies", agencyId, "members"]
["agencies", agencyId, "members", userId, "profile"]
["agencies", agencyId, "invitations"]
["agencies", agencyId, "stats", from, to]
["agencies", "invitations", "my-pending"]

["workspaces", "list"]
["workspaces", "my-managed"]
["workspaces", workspaceId]
["workspaces", workspaceId, "dashboard"]
["workspaces", workspaceId, "members"]
["workspaces", "invitations", "my-pending"]
```

Invalidate `["workspaces", "list"]` + `["workspaces", workspaceId, "members"]` sau mọi mutation invite/assign/remove/update-role. Invalidate `["agencies", agencyId, "members"]` sau accept/decline/remove ở tầng Agency.

### Zustand store — `useCurrentWorkspaceStore` (tái thiết kế từ `brandhub-web/src/store/workspaceStore.ts` cho mobile)

```ts
interface CurrentWorkspaceState {
  currentWorkspace: WorkspaceResponse | null;
  currentMemberRole: MemberRole | "OWNER" | null; // derive từ workspace.myRole, KHÔNG set tay riêng
  currentAgencyId: string | null; // derive từ currentWorkspace.agencyId, hoặc chọn riêng ở Agency List
  setCurrentWorkspace: (w: WorkspaceResponse | null) => void;
  reset: () => void;
}
```

- Persist `currentWorkspace.id` (không persist cả object) vào `expo-secure-store` hoặc AsyncStorage — khi app mở lại, fetch lại `GET /workspaces/{id}` để tránh stale data, tương tự cách web làm với `localStorage` key `brandhub_current_agency_id`.
- **Quan trọng:** đây là store mà mọi domain G4–G7 sau này sẽ đọc `currentWorkspace.id` để biết đang request workspace nào — thiết kế ngay từ G3, không đổi tên field sau.
- Clear store khi logout (đồng bộ với `reset()` của Auth store ở G1), tránh lẫn qua session user khác — bug đã note rõ bên web (`agencyStore.ts` comment dòng 11-14).

## 6. Business rules đặc biệt

- **Role gán theo Workspace, không global:** 1 user có thể là `MANAGER` ở Workspace X nhưng chỉ `CREATOR` ở Workspace Y, cùng 1 Agency (xác nhận `[CONFIRMED 2026-09-14]` trong `01-organization-structure.md` mục 4). Mobile KHÔNG được cache 1 "role" duy nhất per-user toàn app — phải luôn đọc role theo `currentWorkspace.myRole`.
- **2 tầng permission tách biệt:** Agency-level (`ownerId` check, không dùng `MemberRole`) và Workspace-level (`@RequireRole(MemberRole...)`). Agency Owner không tự có `MemberRole` ở mọi Workspace con trừ khi được gán riêng — ngoại trừ các action list/view đã liệt kê ở mục 2 (kế thừa quyền sở hữu).
- **Điều kiện add vào Workspace:** user phải đã là Agency Member trước (FR 3.4.19 + UC-29 A1) — nếu chưa, UI phải chặn/gợi ý "Invite to Agency first" thay vì gọi API rồi nhận lỗi 409.
- **Invite Agency hết hạn sau 3 ngày** (FR 3.4.8) — tự động, không cần action gì từ app; chỉ cần hiển thị đúng status (Pending/Accepted/Rejected/Expired).
- **Remove Agency Member không xoá tài nguyên họ tạo** (FR 3.4.9) — tài sản chung của Agency; UI remove không cần cảnh báo mất dữ liệu.
- **Remove Workspace Member chỉ xoá khỏi Workspace, không khỏi Agency** (FR 3.4.21) — Agency membership giữ nguyên.
- **Leave Workspace không rời Agency** (FR 3.4.16).
- **Đúng 1 MANAGER/Workspace, không co-manage** — re-assign MANAGER tự động revoke người cũ (xử lý ở BE, mobile chỉ hiển thị kết quả, không cần validate client-side phức tạp).

## 7. Việc KHÔNG làm ở G3

- **Không tạo Agency mới từ mobile** (FR 3.4.3) — flow tạo Agency có nhiều field branding (logo/banner/category/company size...) phù hợp web hơn; chưa có yêu cầu rõ ràng mobile phải làm được. Nếu sau cần, tách riêng 1 file `g3b-agency-create.md`.
- **Không Update/Remove Agency Profile** (FR 3.4.5, 3.4.6) từ mobile — admin-ish action, để web xử lý.
- **Không Create/Update/Delete Workspace** (FR 3.4.12, 3.4.14, 3.4.15) từ mobile — tạo Workspace cần chọn Manager + có thể dùng Workspace Template, phức tạp hơn phù hợp web; mobile G3 chỉ View.
- **Không Save Workspace Template** (FR 3.4.17) — admin/setup flow, web-only.
- **Không có màn Billing/Subscription của Workspace** — thuộc G7 riêng.
- **Không làm Duplicate Workspace** (`/workspaces/{id}/duplicate`, `/duplicate-options`) — tính năng admin nặng, không trong phạm vi mobile.
- **Không làm Workspace Settings update** (`PATCH /{workspaceId}/settings`, upload logo/banner workspace) — thuộc nhóm Update Workspace Profile, loại theo mục trên.

## 8. Rủi ro/câu hỏi mở

1. **`timezoneConfig` thiếu trong `WorkspaceResponse`:** model `Workspace.java` có field này nhưng DTO response hiện tại không map ra — FR 3.4.13 yêu cầu hiển thị Timezone Config ở Workspace Profile. Cần hỏi BE: bổ sung field vào `WorkspaceResponse`, hay mobile gọi API khác? Không giả định — chặn thiết kế UI màn Workspace Profile chi tiết.
2. **`AgencyMemberProfileResponse` và `AuditLogResponse` chưa đọc field chi tiết** (chỉ thấy signature trong Controller) — cần đọc thêm trước khi code màn Member Profile drawer nếu giữ trong MVP; có thể cắt bớt phần Activity Feed ở lần đầu để giảm scope.
3. **`ManagedWorkspaceResponse`** (`GET /workspaces/my-managed`) chưa đọc chi tiết field — nếu dùng cho shortcut "My Managed Workspaces" cần đọc DTO trước khi code.
4. **Mobile có cần hỗ trợ accept invitation qua deep-link (email mở app bằng token)?** Web có `invitations/preview?token=` — cần xác nhận Expo app có config deep link scheme chưa (liên quan G1 Auth, có thể đã có sẵn cho reset-password link).
5. **Agency Owner xem Workspace mà họ không phải Manager/Member:** `WorkspaceController.getWorkspace` có `@RequireRole(MANAGER, CREATOR, CLIENT)` — code hiện tại dựa vào "service layer" cho Agency Owner pass thêm (theo comment ở matrix doc), cần xác nhận lại hành vi thật khi test API, vì annotation không thấy override rõ cho OWNER case.

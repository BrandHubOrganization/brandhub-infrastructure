# Plan — Workspace Detail UX Fixes

## Backend (brandhub-business-service)

### 1. ErrorCode.java
Thêm:
```java
INVITATION_ALREADY_PENDING (HttpStatus.CONFLICT, "An invitation is already pending for this email"),
```

### 2. WorkspaceInvitationRepository — query method mới
```java
Optional<WorkspaceInvitation> findByWorkspaceIdAndInvitedEmailAndStatusAndExpiresAtAfter(
        UUID workspaceId, String invitedEmail, String status, OffsetDateTime now);
List<WorkspaceInvitation> findByInvitedEmailAndStatus(String invitedEmail, String status);
```
Method đầu dùng cho check-before-invite (thêm điều kiện `expiresAt` để
invitation hết hạn thực tế không chặn nhầm — xem spec.md Edge Cases).
Method sau dùng cho `my-pending`.

### 3. dto/response/InvitationResponse.java (mới)
```java
public record InvitationResponse(
        UUID id, UUID workspaceId, String workspaceName, MemberRole role,
        String invitedByName, OffsetDateTime expiresAt, String token
) {}
```

### 4. dto/request/DeclineInvitationRequest.java (mới)
```java
public record DeclineInvitationRequest(@NotBlank String token) {}
```

### 5. WorkspaceService (interface) + Impl
```java
List<InvitationResponse> listMyPendingInvitations(AuthenticatedUser currentUser);
void declineInvitation(DeclineInvitationRequest request);
```

`inviteMember` sửa: thêm check trước khi build `WorkspaceInvitation`:
```java
workspaceInvitationRepository
    .findByWorkspaceIdAndInvitedEmailAndStatusAndExpiresAtAfter(
        workspaceId, email, "PENDING", OffsetDateTime.now())
    .ifPresent(inv -> { throw new BusinessException(ErrorCode.INVITATION_ALREADY_PENDING); });
```

`listMyPendingInvitations`: lookup email của `currentUser` qua
`userRepository.findById`, gọi `findByInvitedEmailAndStatus(email,
"PENDING")`, filter thêm `expiresAt.isAfter(now)` ở code (không cần thêm
query mới), batch load `Workspace` + `User` (người mời) tránh N+1 giống
pattern `listMembers`.

`declineInvitation`: tương tự `acceptInvitation` nhưng set status
"DECLINED", không tạo `WorkspaceMember`.

### 6. WorkspaceController — 2 endpoint mới
Đặt cạnh `acceptInvitation` (route tĩnh, không có path variable, không lo
thứ tự):
```java
@GetMapping("/invitations/my-pending")
public ApiResponse<List<InvitationResponse>> listMyPendingInvitations(...)

@PostMapping("/invitations/decline")
public ApiResponse<Void> declineInvitation(@Valid @RequestBody DeclineInvitationRequest request, ...)
```

### 7. Test
`WorkspaceServiceTest` bổ sung 6 case theo spec.md Phần D:
- `inviteMember_pendingInvitationExists_throwsInvitationAlreadyPending`
- `inviteMember_previousInvitationExpired_allowsNewInvitation`
- `inviteMember_previousInvitationDeclined_allowsNewInvitation`
- `inviteMember_inviterInvitesSelf_throwsAlreadyInWorkspaceIfActiveMember`
  (xác nhận hành vi hiện tại đúng, không cần sửa code nếu pass)
- `listMyPendingInvitations_returnsOnlyPendingForUserEmail`
- `declineInvitation_validToken_setsStatusDeclined`

## Frontend (brandhub-web-dashboard)

### 8. WorkspaceSettingsPage.tsx — bỏ timezone Input
- Xóa `Input` timezone khỏi JSX, xóa state `timezone`.
- `handleSubmit` gửi `timezone:
  Intl.DateTimeFormat().resolvedOptions().timeZone` thay vì state.
- Đọc lại `getById` — bỏ `setTimezone(data.data.settings.timezone ?? "")`.

### 9. Navbar.tsx — fix breadcrumb
- Thêm prop `workspaceName?: string | null` vào `NavbarProps`.
- `getBreadcrumbs()`: khi gặp segment là UUID (regex kiểm tra format UUID)
  VÀ có `workspaceName` — dùng `workspaceName` làm label thay vì
  capitalize chuỗi thô. Không có `workspaceName` (đang load) → filter bỏ
  segment đó khỏi breadcrumb tạm thời (không hiện gì thay vì hiện UUID).
- `Layout.tsx`: truyền `workspaceName={activeWorkspace?.name}` xuống
  `Navbar` — nhưng lưu ý `activeWorkspace` trong `Layout.tsx` là workspace
  đang "active" toàn cục (từ `activeWorkspaceId` store), CÓ THỂ khác
  workspace đang xem trong URL `/workspaces/:id/...` nếu user bấm vào card
  workspace khác từ `WorkspacePage.tsx` mà chưa switch active. Cách đúng:
  Navbar tự đọc `:id` từ `useParams` nếu route khớp `/workspaces/:id/*`,
  tra tên trong `workspaces` list (đã có ở Layout) thay vì chỉ dùng
  `activeWorkspace`. Cần truyền `workspaces: Workspace[]` xuống Navbar thay
  vì tính sẵn 1 tên.

### 10. types/workspace.ts — type mới
```ts
export interface WorkspaceInvitation {
  id: string; workspaceId: string; workspaceName: string; role: MemberRole;
  invitedByName: string | null; expiresAt: string; token: string;
}
```

### 11. workspaceService.ts — method mới
```ts
listMyPendingInvitations: () =>
  api.get<ApiResponse<WorkspaceInvitation[]>>("/api/v1/workspaces/invitations/my-pending"),
declineInvitation: (token: string) =>
  api.post<ApiResponse<void>>("/api/v1/workspaces/invitations/decline", { token }),
```

### 12. InvitationsPage.tsx (mới)
- List `listMyPendingInvitations()`, mỗi item hiện tên workspace, role, ai
  mời, hạn.
- Nút Accept gọi `authService`/`workspaceService.acceptInvitation({token})`
  (đã có), Decline gọi `declineInvitation(token)` mới.
- Sau accept/decline: reload list hoặc filter bỏ item khỏi state local.

### 13. App.tsx + Navbar.tsx — route + link
- Route mới `/invitations` (AuthGuard + Layout, dùng chung layout để có
  Sidebar/Navbar nhất quán — không dùng `AcceptInvitationPage.tsx` hiện có
  vì trang đó là flow token-in-URL riêng, khác trang list này).
- Navbar Profile dropdown: thêm `DropdownMenuItem` "Lời mời" → navigate
  `/invitations`, đặt trước "Thiết lập".

### 14. i18n
Thêm `invitations.*` (10 key) + `nav.invitations` vào `vi.json` + `en.json`.

## File Touch List
- `brandhub-business-service/.../exception/ErrorCode.java`
- `brandhub-business-service/.../repository/WorkspaceInvitationRepository.java`
- `brandhub-business-service/.../dto/response/InvitationResponse.java` (mới)
- `brandhub-business-service/.../dto/request/DeclineInvitationRequest.java` (mới)
- `brandhub-business-service/.../service/WorkspaceService.java`
- `brandhub-business-service/.../service/impl/WorkspaceServiceImpl.java`
- `brandhub-business-service/.../controller/WorkspaceController.java`
- `brandhub-business-service/src/test/.../WorkspaceServiceTest.java`
- `brandhub-web-dashboard/src/pages/workspaces/WorkspaceSettingsPage.tsx`
- `brandhub-web-dashboard/src/components/layout/Navbar.tsx`
- `brandhub-web-dashboard/src/components/layout/Layout.tsx`
- `brandhub-web-dashboard/src/types/workspace.ts`
- `brandhub-web-dashboard/src/services/workspaceService.ts`
- `brandhub-web-dashboard/src/pages/workspaces/InvitationsPage.tsx` (mới)
- `brandhub-web-dashboard/src/App.tsx`
- `brandhub-web-dashboard/src/i18n/locales/vi.json`, `en.json`

## Rủi ro
- `Layout.tsx` hiện chỉ truyền `memberRole` xuống `Navbar` — cần đọc kỹ
  cách `workspaces` list được quản lý ở đó trước khi đổi prop, tránh phá
  workspace switcher hiện có.
- `AcceptInvitationPage.tsx` đã tồn tại (flow token trong URL, dùng khi
  click link email) — route `/invitations` (trang list) là bổ sung, KHÔNG
  thay thế, cần đặt tên khác rõ ràng tránh nhầm 2 trang.
- Regex kiểm tra UUID trong breadcrumb phải chính xác (36 ký tự, đúng định
  dạng `8-4-4-4-12`) để không nhầm các segment hợp lệ khác.

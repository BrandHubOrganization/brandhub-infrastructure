# Plan — Add Workspace Member (FR 3.4.19)

> Liên kết: [spec.md](spec.md) — cho MANAGER thêm thành viên vào Workspace qua 2 luồng: Invite (mời email) và Assign (gán trực tiếp).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.inviteMember()`, `WorkspaceServiceImpl.assignMembers()` → `assignMembersInternal()`, `WorkspaceServiceImpl.acceptInvitation()` |
| File đã có | `WorkspaceController` (`POST /{workspaceId}/members/invite`, `POST /{workspaceId}/members/assign`, `POST /invitations/accept`), `WorkspaceInvitation` entity, `MailService`, `AgencyMemberRepository` |

## 2. API Contract (final)

```
POST /api/v1/workspaces/{workspaceId}/members/invite
{ email, role, note? }
→ 200 ApiResponse<null>

POST /api/v1/workspaces/{workspaceId}/members/assign
{ members: [{ userId, role }] }
→ 200 ApiResponse<AssignMembersResponse { added, skippedUserIds }>
```

Cả 2 bảo vệ bởi `@RequireRole({MemberRole.MANAGER})`. Không lệch spec.md.

## 3. Data Model

- **Invite**: `INSERT workspace_invitations` (status=PENDING, token=UUID, `expiresAt = now + 7 ngày`, hằng số `INVITATION_EXPIRY_DAYS=7`). Chưa tạo `WorkspaceMember` ngay.
- **Assign**: `INSERT workspace_members` ngay (isActive=true), không cần accept. Entry đã active bị skip, đưa vào `skippedUserIds`.
- **Accept invitation**: `INSERT workspace_members` theo role của invitation, update `workspace_invitations.status = ACCEPTED`.
- Không migration.

## 4. Luồng xử lý

**Flow A — Invite:**
1. `@RequireRole(MANAGER)` chặn.
2. Chuẩn hóa email (`trim().toLowerCase()`).
3. Check đã là active member → 409 `ALREADY_IN_WORKSPACE`.
4. Check invitation PENDING còn hạn → 409 `INVITATION_ALREADY_PENDING`.
5. Nếu `role=MANAGER` và đã có MANAGER active → 409 `MANAGER_ALREADY_ASSIGNED`.
6. Insert invitation, gửi mail.
7. (Nhánh phụ) Accept: validate token/status/expiry/email → insert `WorkspaceMember`.

**Flow B — Assign:**
1. `@RequireRole(MANAGER)` chặn.
2. Với mỗi entry: check `AgencyMember` tồn tại → 403 `NOT_AGENCY_MEMBER`.
3. Check đã active → skip (idempotent), thêm vào `skippedUserIds`.
4. Nếu `role=MANAGER` và đã có MANAGER active → 409 `MANAGER_ALREADY_ASSIGNED`.
5. Check `User` tồn tại → `USER_NOT_FOUND`.
6. Insert `WorkspaceMember`, thêm vào `added`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `AgencyMember`, `WorkspaceInvitation`, `MailService` (đã có) |
| Bị chặn | `View Workspace Members` (3.4.18) — hiển thị kết quả sau khi add |

## 6. Rủi ro kỹ thuật

- **2 luồng độc lập cùng 1 FR** — invite (async, cần accept) và assign (sync, ngay lập tức) có logic khác nhau đáng kể; dễ nhầm khi maintain nếu không tách rõ 2 method.
- **`assignMembersInternal` dùng chung với Create Workspace (3.4.12)** — sửa 1 chỗ ảnh hưởng cả 2 FR.
- **Invite endpoint trả `Void`** (không trả invitation info) — khác pattern Invite Agency Member (3.4.7, trả đầy đủ `AgencyInvitationResponse` kèm token) — có thể là thiếu sót cần đồng bộ pattern nếu FE cần hiển thị trạng thái invitation vừa gửi.
- **`skippedUserIds` không còn im lặng bỏ qua** (khác version cũ) — cần đảm bảo FE đã cập nhật UI hiển thị cảnh báo cho các user bị skip, tránh gây hiểu nhầm "thêm thành công toàn bộ".

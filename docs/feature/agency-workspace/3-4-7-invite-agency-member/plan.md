# Plan — Invite Agency Member (FR 3.4.7)

> Liên kết: [spec.md](spec.md) — cho Owner mời người khác vào Agency qua email, hết hạn 1-30 ngày (mặc định 30).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.inviteMember()` |
| File đã có | `AgencyController` (`POST /{agencyId}/invitations`), `InviteAgencyMemberRequest`, `AgencyInvitation`, `MailService` |

## 2. API Contract (final)

```
POST /api/v1/agencies/{agencyId}/invitations
Authorization: Bearer <access-token>
Body: { "email": "string", "inviteeName"?, "note"?, "workspaceId"?, "role"? (MANAGER|CREATOR|CLIENT), "expiryDays"? (1-30, default 30) }
→ 200 ApiResponse<AgencyInvitationResponse>
   data = { id, agencyId, agencyName, invitedEmail, invitedBy, token, note, workspaceId, workspaceName, role, status, expiresAt, acceptedAt, createdAt }
```

Khác so với spec.md (đề xuất `201` + `{invitationId, expiresAt}`):

- **Trả `200` (không `201`)** — controller dùng `ApiResponse.ok`, không gắn `@ResponseStatus(CREATED)`. Giữ thống nhất với các endpoint khác.
- **Response đầy đủ `AgencyInvitationResponse`** kèm `token` (để FE dựng invite link) thay vì chỉ `{invitationId, expiresAt}`.
- **Gửi email kèm token link** thay vì notification in-app — `MailService.sendAgencyInvitationEmail` gửi link `/invitations/accept?token=...`. Notification in-app chưa có service (ngoài scope).

## 3. Data Model

- Đọc `agencies` (owner-check), `users` (check đã là member), `agency_members`, `agency_invitations`.
- Ghi `agency_invitations`: `token = UUID`, `status = PENDING`, `expiresAt = now + expiryDays` (1-30, mặc định 30, clamp nếu ngoài khoảng).
- Đọc thêm `workspaces`, `workspace_members` khi request có `workspaceId`/`role` (validate workspace thuộc agency, check MANAGER chưa được gán).

## 4. Luồng xử lý

1. `findAgencyOrThrow` → 404; owner-check → 403 `NOT_AGENCY_OWNER`.
2. `email = request.email().trim().toLowerCase()`.
3. Check đã là member → 409 `ALREADY_AGENCY_MEMBER`.
4. Check đã có invitation PENDING còn hạn → 409 `INVITATION_ALREADY_PENDING`.
5. Check tổng invitation PENDING còn hạn của agency ≥ 20 → 409 `TOO_MANY_PENDING_INVITATIONS`.
6. Nếu có `workspaceId`: check workspace thuộc agency (400 `WORKSPACE_NOT_IN_AGENCY`); nếu `role == MANAGER`, check workspace chưa có manager active (409 `MANAGER_ALREADY_ASSIGNED`).
7. Nếu `role == CLIENT` mà không có `workspaceId` → 400 `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`.
8. Build + save invitation (`expiresAt = now + clamp(expiryDays, 1, 30)`) → `sendAgencyInvitationEmail`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `AgencyInvitation` entity, `MailService` (đã có) |
| Bị chặn | `View Invitation Status` (3.4.8), `acceptInvitation` (luồng mời) |

## 6. Rủi ro kỹ thuật

- **Email chưa có User account (spec mục 7):** vẫn gửi được invite (invite gắn `invitedEmail`, không cần User tồn tại). Khi user đăng ký đúng email đó, `acceptInvitation` check `invitedEmail == user.email`. Đúng ý spec.
- **Trùng email pending:** chặn bằng `INVITATION_ALREADY_PENDING` (tránh spam 2 lời mời cùng email).

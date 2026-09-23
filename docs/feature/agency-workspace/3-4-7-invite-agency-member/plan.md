# Plan — Invite Agency Member (FR 3.4.7)

> Liên kết: [spec.md](spec.md) — cho Owner mời người khác vào Agency qua email, hết hạn 3 ngày.

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
Body: { "email": "string" }
→ 200 ApiResponse<AgencyInvitationResponse>
   data = { id, agencyId, agencyName, invitedEmail, invitedBy, token, status, expiresAt, acceptedAt, createdAt }
```

Khác so với spec.md (đề xuất `201` + `{invitationId, expiresAt}`):

- **Trả `200` (không `201`)** — controller dùng `ApiResponse.ok`, không gắn `@ResponseStatus(CREATED)`. Giữ thống nhất với các endpoint khác.
- **Response đầy đủ `AgencyInvitationResponse`** kèm `token` (để FE dựng invite link) thay vì chỉ `{invitationId, expiresAt}`.
- **Gửi email kèm token link** thay vì notification in-app — `MailService.sendAgencyInvitationEmail` gửi link `/invitations/accept?token=...`. Notification in-app chưa có service (ngoài scope).

## 3. Data Model

- Đọc `agencies` (owner-check), `users` (check đã là member), `agency_members`, `agency_invitations`.
- Ghi `agency_invitations`: `token = UUID`, `status = PENDING`, `expiresAt = now + 3 days`.

## 4. Luồng xử lý

1. `findAgencyOrThrow` → 404; owner-check → 403 `NOT_AGENCY_OWNER`.
2. `email = request.email().trim().toLowerCase()`.
3. Check đã là member → 409 `ALREADY_AGENCY_MEMBER`.
4. Check đã có invitation PENDING còn hạn → 409 `INVITATION_ALREADY_PENDING`.
5. Build + save invitation → `sendAgencyInvitationEmail`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `AgencyInvitation` entity, `MailService` (đã có) |
| Bị chặn | `View Invitation Status` (3.4.8), `acceptInvitation` (luồng mời) |

## 6. Rủi ro kỹ thuật

- **Email chưa có User account (spec mục 7):** vẫn gửi được invite (invite gắn `invitedEmail`, không cần User tồn tại). Khi user đăng ký đúng email đó, `acceptInvitation` check `invitedEmail == user.email`. Đúng ý spec.
- **Trùng email pending:** chặn bằng `INVITATION_ALREADY_PENDING` (tránh spam 2 lời mời cùng email).

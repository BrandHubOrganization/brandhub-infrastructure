# Task — Invite Agency Member (FR 3.4.7)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.inviteMember(UUID, AuthenticatedUser, InviteAgencyMemberRequest)` — owner-check → validate → save invitation + gửi email
- [x] 403 `NOT_AGENCY_OWNER`, 409 `ALREADY_AGENCY_MEMBER`, 409 `INVITATION_ALREADY_PENDING`, 409 `TOO_MANY_PENDING_INVITATIONS`, 400 `WORKSPACE_NOT_IN_AGENCY`, 409 `MANAGER_ALREADY_ASSIGNED`, 400 `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`
- [x] `POST /api/v1/agencies/{agencyId}/invitations` đã có ở `AgencyController`
- [x] `token = UUID`, `expiresAt = now + expiryDays` (1-30, mặc định 30, clamp), gửi email qua `MailService`
- [x] **[FE 2026-09-25 — đã fix]** `members.tsx`: expiry đổi từ dropdown {3,7,14,30} sang number input tự do 1-30; role CLIENT thêm vào `ASSIGNABLE_ROLES` (trước đây bị loại do comment cũ sai — CLIENT hợp lệ theo BR-27, workspace bắt buộc khi role=CLIENT)

## Verify

- [x] `mvn test` pass (happy + already-member + pending + non-owner + workspace/manager/client checks)
- [x] Email trim + lowercase trước khi xử lý

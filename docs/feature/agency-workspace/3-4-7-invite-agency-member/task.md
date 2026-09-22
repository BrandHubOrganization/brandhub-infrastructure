# Task — Invite Agency Member (FR 3.4.7)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.inviteMember(UUID, AuthenticatedUser, InviteAgencyMemberRequest)` — owner-check → validate → save invitation + gửi email
- [x] 403 `NOT_AGENCY_OWNER`, 409 `ALREADY_AGENCY_MEMBER`, 409 `INVITATION_ALREADY_PENDING`
- [x] `POST /api/v1/agencies/{agencyId}/invitations` đã có ở `AgencyController`
- [x] `token = UUID`, `expiresAt = now + 3 days`, gửi email qua `MailService`

## Verify

- [x] `mvn test` pass (happy + already-member + pending + non-owner)
- [x] Email trim + lowercase trước khi xử lý

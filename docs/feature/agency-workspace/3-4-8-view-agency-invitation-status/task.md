# Task — View Agency Invitation Status (FR 3.4.8)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `listInvitations(UUID, AuthenticatedUser)` — trả toàn bộ invitation của Agency
- [x] `listMyPendingInvitations(AuthenticatedUser)` — trả invitation PENDING còn hạn của user
- [x] `acceptInvitation` — validate token/expiry/email → tạo `AgencyMember(MEMBER)`
- [x] `declineInvitation` — set `REVOKED`
- [x] 4 endpoint đã có ở `AgencyController`

## Verify

- [x] `mvn test` pass (accept valid/unknown/expired/mismatch; decline)
- [x] Hết hạn 3 ngày tính đúng (filter `expiresAt > now`)

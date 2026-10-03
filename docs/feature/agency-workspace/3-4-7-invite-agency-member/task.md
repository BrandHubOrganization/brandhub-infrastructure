# Task — Invite Agency Member (FR 3.4.7)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.inviteMember(UUID, AuthenticatedUser, InviteAgencyMemberRequest)` — owner-check → validate → save invitation + gửi email
- [x] 403 `NOT_AGENCY_OWNER`, 409 `ALREADY_AGENCY_MEMBER`, 409 `INVITATION_ALREADY_PENDING`, 409 `TOO_MANY_PENDING_INVITATIONS`, 400 `WORKSPACE_NOT_IN_AGENCY`, 409 `MANAGER_ALREADY_ASSIGNED`, 400 `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`
- [x] `POST /api/v1/agencies/{agencyId}/invitations` đã có ở `AgencyController`
- [x] `token = UUID`, `expiresAt = now + expiryDays` (1-30, mặc định 30, clamp), gửi email qua `MailService`
- [x] **[FE 2026-09-25 — đã fix]** `members.tsx`: expiry đổi từ dropdown {3,7,14,30} sang number input tự do 1-30; role CLIENT thêm vào `ASSIGNABLE_ROLES` (trước đây bị loại do comment cũ sai — CLIENT hợp lệ theo BR-27, workspace bắt buộc khi role=CLIENT)

## V2 (2026-10-02) — Invite CLIENT riêng + auto-suggest

- [x] `AgencyServiceImpl.inviteLookup(agencyId, currentUser, email)` + `GET /api/v1/agencies/{agencyId}/invite-lookup?email=` — advisory, trả `isAlreadyClientInAgency` chỉ khi active cùng agency.
- [x] FE: `AddClientDialog` (trang `/workspaces/:id/clients`) — input Gmail, 2 gợi ý inline (`useUserLookup` + `agencyService.inviteLookup`), submit qua `workspaceService.inviteMember`.
- [x] Chặn internal member làm CLIENT — tái dùng check `ALREADY_AGENCY_MEMBER` hiện có (áp dụng mọi role, không cần logic riêng).
- [x] Accept CLIENT: picker chọn/tạo ClientProfile (`GET /client-profile/mine`, `resolveClientProfileForAccept`) — đã có từ trước, không đổi lúc này.

## Verify

- [x] `mvn test` pass (happy + already-member + pending + non-owner + workspace/manager/client checks)
- [x] Email trim + lowercase trước khi xử lý
- [x] Browser-verified (2026-10-01): gõ email đã là client cùng agency ở workspace khác → gợi ý inline hiện đúng tên workspace; gửi invite thành công (200), reload list đúng.

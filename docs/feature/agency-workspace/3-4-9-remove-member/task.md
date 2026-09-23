# Task — Remove Member (FR 3.4.9)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.removeMember(UUID, UUID, AuthenticatedUser)` — owner-check → tìm member → chặn OWNER → delete
- [x] 403 `NOT_AGENCY_OWNER` khi non-owner
- [x] 409 `CANNOT_REMOVE_OWNER` khi cố xóa OWNER (error code riêng, thay cho `FORBIDDEN` 403 trước đây)
- [x] `DELETE /api/v1/agencies/{agencyId}/members/{memberId}` đã có ở `AgencyController`

## Verify

- [x] `mvn test` pass (owner-forbidden + happy)
- [x] Tài nguyên member tạo không bị đụng (không có cascade delete)

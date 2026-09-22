# Task — Remove Agency (FR 3.4.6)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.removeAgency(UUID, AuthenticatedUser)` — owner-check → soft-delete
- [x] 403 `NOT_AGENCY_OWNER` khi non-owner
- [x] `DELETE /api/v1/agencies/{agencyId}` đã có ở `AgencyController`
- [x] **[XÁC NHẬN 2026-09-21 — đã code]** `POST /{agencyId}/restore` — `AgencyServiceImpl.restoreAgency()`: owner-check → check `status == SOFT_DELETED` → check trong 30 ngày kể từ `deletedAt` → set `ACTIVE`, `deletedAt = null`. Chỉ đổi status Agency, KHÔNG cascade khôi phục Workspace con (đã chốt với user — `removeAgency` không đụng Workspace/Member/Invitation nên restore không cần khôi phục gì thêm).
- [ ] Job xóa cứng tự động sau 30 ngày — vẫn chưa làm, ngoài phạm vi (cần scheduler riêng).

## Verify

- [x] `mvn test` pass
- [x] Sau delete, `status == SOFT_DELETED`; list không trả Agency đó nữa

# Task — Remove Agency (FR 3.4.6)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.removeAgency(UUID, AuthenticatedUser)` — owner-check → soft-delete Agency
- [x] 403 `NOT_AGENCY_OWNER` khi non-owner
- [x] `DELETE /api/v1/agencies/{agencyId}` đã có ở `AgencyController`
- [x] **[CASCADE 2026-09-23 — đã code]** `removeAgency` soft-delete toàn bộ Workspace con: `workspaceRepository.findByAgencyId(agencyId)` → set `status = SOFT_DELETED`, `deletedAt = now`.
- [x] **[XÁC NHẬN 2026-09-21 — đã code]** `POST /{agencyId}/restore` — `AgencyServiceImpl.restoreAgency()`: owner-check → check `status == SOFT_DELETED` → check trong 30 ngày kể từ `deletedAt` → set `ACTIVE`, `deletedAt = null`.
- [x] **[CASCADE 2026-09-23 — đã code]** `restoreAgency` khôi phục Workspace con: set `status = ACTIVE`, `deletedAt = null`, `updatedAt = now`.
- [ ] Job xóa cứng tự động sau 30 ngày — vẫn chưa làm, ngoài phạm vi (cần scheduler riêng).

## Verify

- [x] `mvn test` pass
- [x] Sau delete, `status == SOFT_DELETED`; list không trả Agency đó nữa
- [ ] Bổ sung test cho cascade: xóa Agency → Workspace con `SOFT_DELETED`; restore → Workspace con `ACTIVE` (chưa thấy test riêng cho cascade — đề nghị BE lead xác nhận)

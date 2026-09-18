# Task — Deactivate Account

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `UserStatus` thêm `DEACTIVATED`.
- [x] `POST /deactivate { password }` — verify password, soft-delete.
- [x] Chặn nếu Owner Agency active → 409 `AGENCY_OWNERSHIP_ACTIVE`.
- [x] `AgencyRepository.findByOwnerId(UUID)`.
- [x] `DeactivateRequest` DTO.
- [x] Error `ACCOUNT_DEACTIVATED` (login sau deactivate).
- [x] `mvn compile` pass.
- [ ] Test: deactivate xong → login bị chặn 403, data còn trong DB.
- [ ] Test: Owner Agency active → 409, không deactivate.

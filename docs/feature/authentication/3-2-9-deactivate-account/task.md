# Task — Deactivate Account

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `UserStatus` thêm `DEACTIVATED`.
- [x] `POST /deactivate { password }` — verify password, soft-delete.
- [x] Chặn nếu Owner Agency active → 409 `AGENCY_OWNERSHIP_ACTIVE`.
- [x] `AgencyRepository.findByOwnerId(UUID)`.
- [x] `DeactivateRequest` DTO.
- [x] Error `ACCOUNT_DEACTIVATED` (login sau deactivate).
- [x] `mvn compile` pass.
- [x] FE: `authService.deactivate()`, `pages/profile/index.tsx` (Danger Zone, modal password, `handleDeactivate`) — **xác nhận đã wire thật, không phải stub**.
- [ ] Test: deactivate xong → login bị chặn 403, data còn trong DB — **xác nhận (2026-09-21): chưa có `AuthServiceImplTest` case nào cho `deactivate()`**, chưa test.
- [ ] Test: Owner Agency active → 409, không deactivate — **chưa có, xác nhận qua Grep test file**.

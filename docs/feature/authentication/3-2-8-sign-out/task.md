# Task — Sign Out

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /logout` — blacklist access + revoke refresh + clear cookie.
- [x] Idempotent (token hết hạn → vẫn 200).
- [x] Audit log logout — ghi `userId` / `action = LOGOUT` / `resourceType = USER` / `resourceId`.
- [x] **[MỚI 2026-09-23]** `AuditLog` thêm field `ipAddress` + `userAgent` (cột `ip_address`, `user_agent`) và `AuthServiceImpl.logout` **lưu** 2 giá trị này vào audit log (trước đây nhận param nhưng không lưu).
- [x] Migration `brandhub-infrastructure/scripts/migrations/2026-09-23-audit-log-ip-user-agent.sql` (ADD COLUMN IF NOT EXISTS `ip_address` VARCHAR(45), `user_agent` VARCHAR(512)).
- [x] `mvn compile` pass.
- [ ] FE: lưu `lastUsedLoginMethod` vào local storage (email|google_oauth).
- [ ] FE: render `/login` highlight nút theo lastUsedLoginMethod.

> Note: lastUsedLoginMethod thuần FE, không có thay đổi BE.

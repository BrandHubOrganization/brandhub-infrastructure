# Task — Sign Out

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /logout` — blacklist access + revoke refresh + clear cookie.
- [x] Idempotent (token hết hạn → vẫn 200).
- [x] Audit log logout (ip, userAgent).
- [x] `mvn compile` pass.
- [ ] FE: lưu `lastUsedLoginMethod` vào local storage (email|google_oauth).
- [ ] FE: render `/login` highlight nút theo lastUsedLoginMethod.

> Note: lastUsedLoginMethod thuần FE, không có thay đổi BE.

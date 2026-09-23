# Sequence Flow — Sign Out

> Bổ sung cho `spec.md` (FR 3.2.8). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AuthController.logout`, `AuthServiceImpl.logout`).

## Actors

- **User** — đã đăng nhập.
- **FE** — brandhub-web-dashboard (local storage cho `lastUsedLoginMethod`).
- **BE** — brandhub-business-service.
- **DB** — Redis (JWT blacklist), PostgreSQL (`audit_logs` — có `ip_address`, `user_agent`).

---

## Flow A — Đăng xuất thành công

1. User → FE: bấm "Sign Out".
2. FE → BE: `POST /api/v1/auth/logout` (Header `Authorization: Bearer {accessToken}`, Cookie `refreshToken`, `X-Forwarded-For`, `User-Agent`).
3. BE (`AuthController.logout`): thiếu/sai prefix `Bearer ` ở header → `401 INVALID_CREDENTIALS` — **response trả trực tiếp qua `response.setStatus` + `ApiResponse.error`, không throw `BusinessException`** (khác pattern các route khác), do route logout không dùng `requireUserId()` helper.
4. BE (`AuthServiceImpl.logout`):
   a. Parse `accessToken` → lấy `userId`, blacklist accessToken (JWT `jti` vào Redis) — token đã hết hạn/parse lỗi → bắt `JwtException`, bỏ qua (không throw lỗi, vẫn tiếp tục coi là thành công — idempotent).
   b. Có `refreshToken` (từ Cookie) → blacklist luôn refreshToken — lỗi parse cũng bỏ qua tương tự.
   c. Có `userId` hợp lệ → `INSERT audit_logs (userId, LOGOUT, resourceType=USER, ipAddress, userAgent)` — `ipAddress` từ header `X-Forwarded-For`, `userAgent` từ header `User-Agent`.
5. BE → FE: `200 { success: true, data: null }` + Set-Cookie `refreshToken=""` (`maxAge=0` — xóa cookie khỏi browser).
6. FE: xóa `accessToken` khỏi store/memory, **ghi `lastUsedLoginMethod`** (`email` hoặc `google_oauth`, tùy phương thức đăng nhập gần nhất) vào `localStorage` — hoàn toàn phía FE, **không có API call nào tới BE cho việc này** (đúng theo spec — "ĐÃ CHỐT: FE local storage").
7. FE: điều hướng `/login`, đọc lại `localStorage["lastUsedLoginMethod"]` để hiển thị badge "Đã dùng lần trước" ở nút tương ứng.

## Flow B — Logout khi token đã hết hạn/không hợp lệ

1–2. Giống Flow A, nhưng `accessToken` đã hết hạn hoặc bị sửa đổi.
3. BE: header vẫn có prefix `Bearer ` hợp lệ về mặt format → không bị chặn ở controller.
4. BE (`logout`): `jwtUtil.parseToken(accessToken)` ném `JwtException` → bắt, bỏ qua, `userId=null` → không blacklist accessToken được (đã invalid sẵn), không ghi audit log (vì không biết `userId`) — vẫn cố blacklist `refreshToken` nếu có.
5. BE → FE: **vẫn `200 { success: true }`** — logout luôn idempotent, không bao giờ trả lỗi vì token invalid ở bước này (khớp spec mục 6).
6–7. Giống Flow A.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Logout | Thiếu header `Authorization` hoặc sai prefix `Bearer ` | 401 | `INVALID_CREDENTIALS` |
| Logout | accessToken hết hạn/invalid (nhưng có header) | 200 | — (idempotent, không lỗi) |
| Logout | refreshToken hết hạn/invalid | 200 | — (idempotent, không lỗi) |

## Audit log (đã fix drift)

- `AuditLog` (model `com.brandhub.business.model.AuditLog`) nay có thêm 2 field: `ipAddress` (cột `ip_address` VARCHAR 45) và `userAgent` (cột `user_agent` VARCHAR 512).
- `AuthServiceImpl.logout` **lưu** `ipAddress`/`userAgent` nhận từ controller vào bản ghi audit — trước đây nhận param nhưng bỏ qua.
- Migration: `brandhub-infrastructure/scripts/migrations/2026-09-23-audit-log-ip-user-agent.sql`.
- Bản trước ghi "AuditLog không có field `ip`/`userAgent`, tham số nhận qua header KHÔNG được lưu" — **không còn đúng**, đã cập nhật.

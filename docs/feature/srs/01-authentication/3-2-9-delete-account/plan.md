> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.9: Delete Account

> [spec.md](./spec.md) — Soft-delete account, 2 flow xác thực (password / OTP), chặn nếu là Owner duy nhất Agency active.

## Quyết định câu hỏi mở (spec Edge Cases)

Spec để mở: "User là Owner Agency active → deactivate thì Agency xử lý sao?" — **Chốt với Trung: Chặn, bắt transfer trước.** Áp dụng chung cho cả 2 flow.

Spec để mở: "User OAuth-only (không có password) muốn deactivate thì sao, vì không thể verify password?" — **Chốt: thêm flow OTP qua email (2026-09-23).**

## Kỹ thuật

- `DeactivateRequest(password, otpCode)` — cả 2 field optional, không validation annotation.
- `POST /api/v1/auth/deactivate/send-otp` (Bearer, không body) — sinh OTP 6 số, lưu Redis `otp:deactivate:{userId}` TTL 10 phút, gửi email qua `mailService.sendOtpEmail`.
- `POST /api/v1/auth/deactivate { password?, otpCode? }` (Bearer + `refreshToken` cookie):
  - `user.passwordHash != null` → verify `password` (bcrypt) → sai → 400 `WRONG_CURRENT_PASSWORD`.
  - `user.passwordHash == null` → verify `otpCode` với Redis key → sai/thiếu/hết hạn → 400 `OTP_INVALID` → đúng thì xóa key.
- `agencyRepository.findByOwnerId(userId)` → có Agency `EntityStatus.ACTIVE`? → 409 `AGENCY_OWNERSHIP_ACTIVE`.
- Không có → `setStatus(UserStatus.DEACTIVATED)` (soft delete), KHÔNG xóa cứng.
- **MỚI**: Sau khi save status, blacklist accessToken + refreshToken (nếu có) qua `jwtUtil.blacklistToken()` — best-effort, bắt `JwtException` bỏ qua nếu token thiếu/hỏng. Cắt session ngay lập tức, không đợi refresh lần sau.
- Sau deactivate, login/refresh → `checkStatus` → 403 `ACCOUNT_DEACTIVATED` (backup, đã có blacklist nên không còn là cơ chế cắt session duy nhất).

## Luồng

**Flow A (có password):**
1. Auth → userId.
2. Verify password → sai → 400.
3. Check Agency active (owner) → có → 409.
4. `status=DEACTIVATED` → blacklist accessToken + refreshToken → 200.

**Flow B (OAuth-only):**
1. Auth → userId → gọi `send-otp` → sinh OTP, lưu Redis, gửi email → 200.
2. Client gọi `deactivate { otpCode }` → auth → userId.
3. Verify OTP với Redis → sai/thiếu/hết hạn → 400 → đúng thì xóa key.
4. Check Agency active (owner) → có → 409.
5. `status=DEACTIVATED` → blacklist accessToken + refreshToken → 200.

## Data Model

- `users.status` → `DEACTIVATED` (enum value).
- `users.password_hash` — dùng để phân nhánh flow (null → OTP, not null → password).
- `agencies.owner_id`, `agencies.status`.
- Redis key `otp:deactivate:{userId}` — TTL 10 phút, giá trị OTP 6 số.

## Rủi ro

- Không xóa cứng (giữ Agency/Workspace membership). User muốn khôi phục → nhờ Admin (ngoài scope).
- Flow B: nếu mailService lỗi (send-otp thất bại), user OAuth-only không có cách nào khác để deactivate — cần theo dõi log lỗi gửi mail.
- UI/UX 2 bước (send-otp rồi mới nhập OTP) cho user OAuth-only — **cần FE xác nhận thiết kế** (xem spec.md mục 4).

## Tích hợp Frontend Web & Mobile (Đã triển khai)

- **Web (`brandhub-web`):** `src/pages/profile/index.tsx`, `src/services/authService.ts` — đồng bộ song song locale `vi`/`en` (`profile.deactivate.*`) và semantic Light/Dark mode tokens.
- **Mobile (`brandhub-mobile-app`):** `src/screens/settings/AccountSettingsScreen.tsx`, `src/services/authService.ts` — đồng bộ API contract, token state và kiểm tra lỗi nhất quán với Web.
- **Tài liệu tham chiếu:** [BA Authentication & Profile](../../../../ba/02-authentication-profile.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.9` — Delete Account |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/deactivate · POST /api/v1/auth/deactivate/send-otp` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl, JwtUtil, MailService` |
| **Persistence / Cache Targets** | PostgreSQL `users` (`status = DEACTIVATED`), `agencies`; Redis `otp:deactivate:{userId}`, `jwt:blacklist:{jti}` |
| **Business Rule Invariants** | `BR-10, BR-16` |
| **Error Code Contract** | `400 WRONG_CURRENT_PASSWORD` / `OTP_INVALID`, `401 UNAUTHORIZED`, `409 AGENCY_OWNERSHIP_ACTIVE` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/profile/index.tsx`, `src/services/authService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/settings/AccountSettingsScreen.tsx`, `src/services/authService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `profile.deactivate.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).

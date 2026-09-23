# UC — Deactivate Account

| | |
|---|---|
| FR Code | 3.2.9 |
| Feature | Deactivate Account |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 3.0 (V3 — thêm flow OTP cho user OAuth-only, 2026-09-23) |
| Trạng thái tài liệu | Confirmed — đã code (2 flow: password-based + OTP-based) |

## 1. Objective

Cho phép user tự vô hiệu hóa tài khoản của mình — soft delete, không xóa cứng dữ liệu. Hỗ trợ cả user có password lẫn user chỉ đăng nhập qua OAuth (Google, không có password).

## 2. User Story

Là một User không muốn dùng BrandHub nữa,
tôi muốn deactivate tài khoản của mình bằng cách xác nhận danh tính (password hoặc OTP tùy loại tài khoản),
nhưng dữ liệu vẫn được giữ lại phòng trường hợp tôi quay lại.

## 3. Acceptance Criteria

- Bấm Deactivate (có confirm dialog).
  - User có password (`passwordHash != null`): nhập lại password để xác nhận.
  - User OAuth-only (`passwordHash == null`, ví dụ chỉ đăng nhập qua Google): bấm "Gửi mã xác nhận" → nhận OTP 6 số qua email → nhập OTP để xác nhận.
- Set `User.status = DEACTIVATED` — **soft delete**, KHÔNG xóa cứng record User hay dữ liệu liên quan (Agency/Workspace họ đang tham gia).
- Sau deactivate, user không login được nữa; các Agency họ là Owner active vẫn tồn tại — **bị chặn deactivate trước đó** nếu còn sở hữu Agency active (xem Business Rules).

## 4. UI / UX

- Trang `/profile`, mục Danger Zone, có warning rõ ràng trước khi confirm.
- **[CHỐT 2026-09-20]** FE nút "Deactivate" trên trang Profile phải gọi thật API (không phải stub), sau thành công clear auth + redirect `/login`.
- **[XÁC NHẬN 2026-09-21]** `pages/profile/index.tsx` (Danger Zone section) đã wire `handleDeactivate` thật cho flow password.
- **[CẦN BỔ SUNG — 2026-09-23, chưa xác nhận FE]** Với user OAuth-only (không có password), FE cần thêm bước: nút "Gửi mã OTP" gọi `POST /deactivate/send-otp` trước, hiện thông báo "đã gửi email", sau đó hiện ô nhập OTP thay cho ô nhập password trong dialog confirm. **Cần Trung/FE xác nhận UI/UX chi tiết của bước này** (2 bước riêng hay 1 dialog động theo loại tài khoản?).

## 5. API Contract

### 5.1. `POST /api/v1/auth/deactivate/send-otp` — MỚI

Chỉ dùng cho **Flow B** (user OAuth-only). Gửi OTP 6 số qua email, TTL 10 phút.

```
POST /api/v1/auth/deactivate/send-otp
Header: Authorization: Bearer <token>   (bắt buộc)
(không có request body)
→ 200 { "success": true, "data": null }
```

- Thiếu/sai Bearer token → `401 INVALID_CREDENTIALS`.
- User không tồn tại (token hợp lệ, data lỗi) → `404 USER_NOT_FOUND`.
- OTP được sinh ngẫu nhiên (100000–999999), lưu Redis key `otp:deactivate:{userId}`, TTL 10 phút, gửi qua `mailService.sendOtpEmail`.
- Route này **không kiểm tra** user có password hay không — có thể gọi bất kỳ lúc nào (kể cả user có password), nhưng về nghiệp vụ chỉ cần thiết cho user OAuth-only.

### 5.2. `POST /api/v1/auth/deactivate`

Dùng chung cho cả 2 flow qua 1 route duy nhất, phân nhánh theo `user.passwordHash`.

```
POST /api/v1/auth/deactivate
Header: Authorization: Bearer <token>   (bắt buộc)
{
  "password": "string"  // optional — Flow A, bắt buộc nếu user có password
  "otpCode": "string"   // optional — Flow B, bắt buộc nếu user OAuth-only
}
→ 200 { "success": true, "data": null }
```

- `DeactivateRequest` DTO: cả `password` và `otpCode` đều **optional** (không có `@NotBlank`/`@NotNull`) — client chỉ gửi field tương ứng flow của mình.
- Thiếu/sai Bearer token → `401 INVALID_CREDENTIALS`.
- Server tự quyết định flow theo `user.passwordHash`:
  - `passwordHash != null` → bắt buộc verify bằng `password` (Flow A). `otpCode` bị bỏ qua nếu có gửi kèm.
  - `passwordHash == null` → bắt buộc verify bằng `otpCode` (Flow B). `password` bị bỏ qua nếu có gửi kèm.

## 6. Business Rules

### Flow A — User có password (`passwordHash != null`)

1. Client gọi thẳng `POST /deactivate { password }` (không cần gọi `send-otp`).
2. BE so khớp `password` với `passwordHash` (bcrypt) — sai → `400 WRONG_CURRENT_PASSWORD`.
3. Đúng → kiểm tra ownership Agency active (xem rule chung bên dưới).
4. Không sở hữu Agency active → `status = DEACTIVATED`, `200`.

### Flow B — User OAuth-only (`passwordHash == null`)

1. Client **bắt buộc** gọi `POST /deactivate/send-otp` trước (chỉ cần Bearer token, không cần body) → nhận OTP 6 số qua email, TTL 10 phút.
2. Client gọi `POST /deactivate { otpCode }`.
3. BE so khớp `otpCode` với giá trị lưu tại Redis key `otp:deactivate:{userId}`:
   - Key không tồn tại (chưa gọi send-otp, hoặc hết hạn), hoặc `otpCode` null, hoặc không khớp → `400 OTP_INVALID`.
   - Khớp → xóa key khỏi Redis (dùng 1 lần).
4. Đúng → kiểm tra ownership Agency active (xem rule chung bên dưới).
5. Không sở hữu Agency active → `status = DEACTIVATED`, `200`.

### Rule chung cho cả 2 flow — Ownership Agency active

- **ĐÃ CHỐT**: Sau khi xác thực thành công (password hoặc OTP), nếu user là Owner của **≥1 Agency đang `ACTIVE`** (`agencyRepository.findByOwnerId(userId)` lọc `status=ACTIVE`) → **chặn deactivate**, trả `409 AGENCY_OWNERSHIP_ACTIVE`, KHÔNG update `User.status`. Buộc transfer ownership trước khi được deactivate (thuộc domain agency-workspace, ngoài scope FR này).

## 7. Error Handling

| Trường hợp | HTTP | ErrorCode | Áp dụng |
|---|---|---|---|
| Thiếu/sai Bearer token | 401 | `INVALID_CREDENTIALS` | Cả 2 route |
| User không tồn tại (token hợp lệ, data lỗi) | 404 | `USER_NOT_FOUND` | Cả 2 route |
| Password sai (Flow A) | 400 | `WRONG_CURRENT_PASSWORD` | `/deactivate` |
| OTP sai / hết hạn / thiếu (Flow B) | 400 | `OTP_INVALID` | `/deactivate` |
| Sở hữu ≥1 Agency đang `ACTIVE` | 409 | `AGENCY_OWNERSHIP_ACTIVE` | `/deactivate`, cả 2 flow |

## 8. Edge Cases

- **ĐÃ CHỐT**: User là Owner của Agency `ACTIVE` → **chặn deactivate** (409 `AGENCY_OWNERSHIP_ACTIVE`), buộc transfer ownership trước khi được deactivate. Áp dụng cho cả Flow A và Flow B.
- User OAuth-only gọi `/deactivate` với `otpCode` mà **chưa từng gọi `send-otp`** → không có key Redis → `400 OTP_INVALID`.
- User OAuth-only gọi `send-otp` nhiều lần → mỗi lần ghi đè OTP cũ (TTL reset 10 phút), OTP cũ hết hiệu lực ngay.
- OTP dùng 1 lần — verify thành công thì bị xóa khỏi Redis ngay, gọi lại `/deactivate` với OTP đã dùng → `400 OTP_INVALID`.
- User có password nhưng gửi `otpCode` thay vì `password` → BE vẫn theo nhánh `passwordHash != null` → verify `password` (null) → `400 WRONG_CURRENT_PASSWORD`. `otpCode` bị bỏ qua.

## 9. Definition of Done

- Flow A: Deactivate thành công bằng password, user không login được sau đó, dữ liệu liên quan vẫn còn trong DB.
- Flow B: `send-otp` gửi email đúng, `deactivate` với OTP đúng thành công, OTP sai/hết hạn/thiếu bị chặn đúng lỗi.
- Cả 2 flow: bị chặn đúng bởi `AGENCY_OWNERSHIP_ACTIVE` khi còn sở hữu Agency active.

## Out of Scope

- Xóa cứng tài khoản (hard delete) — không có trong CSV, chỉ soft delete.
- Transfer ownership Agency (thuộc domain agency-workspace).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)

# Task — Deactivate Account

> [plan.md](./plan.md) | [test.md](./test.md)

## Backend

- [x] `UserStatus` thêm `DEACTIVATED`.
- [x] `POST /deactivate { password?, otpCode? }` — verify password (Flow A) hoặc OTP (Flow B), soft-delete.
- [x] `POST /deactivate/send-otp` — sinh OTP 6 số, lưu Redis TTL 10 phút, gửi email.
- [x] Chặn nếu Owner Agency active → 409 `AGENCY_OWNERSHIP_ACTIVE` (cả 2 flow).
- [x] `AgencyRepository.findByOwnerId(UUID)`.
- [x] `DeactivateRequest` DTO — `password`, `otpCode` đều optional.
- [x] Error `OTP_INVALID` cho OTP sai/thiếu/hết hạn (Flow B).
- [x] Error `ACCOUNT_DEACTIVATED` (login sau deactivate).
- [x] `mvn compile` pass.

## Frontend

- [x] `authService.deactivate()`, `pages/profile/index.tsx` (Danger Zone, modal password, `handleDeactivate`) — flow A đã wire thật.
- [ ] **MỚI**: FE gọi `authService.sendDeactivateOtp()` trước khi hiện form OTP, cho user OAuth-only (`passwordHash == null` — cần API/state biết user loại nào để hiện đúng UI, kiểm tra FE có field này chưa).
- [ ] **MỚI**: FE thêm ô nhập OTP trong dialog confirm deactivate khi user là OAuth-only.
- [ ] **CẦN CONFIRM VỚI FE**: UX chi tiết — 1 dialog động đổi field theo loại tài khoản, hay 2 bước riêng (bấm gửi OTP → dialog mới nhập OTP)?

## Test

- [ ] Test: deactivate xong (Flow A) → login bị chặn 403, data còn trong DB — chưa có `AuthServiceImplTest` case.
- [ ] Test: Owner Agency active → 409, không deactivate (cả 2 flow) — chưa có.
- [ ] **MỚI**: Test `sendDeactivateOtp` — sinh OTP, lưu Redis đúng TTL, gọi `mailService.sendOtpEmail` đúng email.
- [ ] **MỚI**: Test `deactivate` Flow B — OTP đúng → thành công, xóa Redis key.
- [ ] **MỚI**: Test `deactivate` Flow B — OTP sai/thiếu/hết hạn/chưa gọi send-otp → 400 `OTP_INVALID`.
- [ ] **MỚI**: Test `deactivate` Flow A vẫn hoạt động bình thường sau khi thêm nhánh OTP (regression — không bị route sai nhánh khi `passwordHash != null`).

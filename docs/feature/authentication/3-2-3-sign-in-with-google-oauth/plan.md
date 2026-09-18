# Plan — Sign In with Google OAuth

> [spec.md](./spec.md) — Đăng nhập Google OAuth, bug-fix flow không chạy được.

## Bug đã điều tra + fix

Flow cũ KHÔNG chạy vì `GoogleOAuthService.fetchProfile()` gửi token-exchange request dạng JSON (`body(Map.of(...))`) tới `https://oauth2.googleapis.com/token`. Google **bắt buộc** body `application/x-www-form-urlencoded`; RestClient chỉ tự convert form cho `MultiValueMap`, không cho plain `Map` → request bị Google reject.

**Fix**: chuyển sang `MultiValueMap` + `.contentType(MediaType.APPLICATION_FORM_URLENCODED)`.

## Kỹ thuật

- `OAuthService` (base): build consent URL, exchange code, lưu state CSRF Redis `oauth:state:{state}`, map email→User (merge theo chuẩn hóa email).
- `GoogleOAuthService.fetchProfile()` (đã fix): token exchange form-encoded → gọi `/oauth2/v2/userinfo` → `OAuthProfile(id, email, name, picture)`.
- Callback: email đã có User → login; chưa → tạo User `emailVerified=true`.
- **2FA không áp dụng cho OAuth** (OAuth bỏ qua password; known limitation, ngoài scope).

## Luồng

1. `GET /oauth/google` → tạo state → redirect Google consent.
2. Callback → verify state → exchange code (form-encoded) → lấy profile.
3. Match email (case-insensitive) → login/tạo User → issue token + audit.

## Rủi ro

- State reuse/replay → state dùng 1 lần, xóa sau khi verify.
- Email trùng account password → merge (không tạo account riêng).

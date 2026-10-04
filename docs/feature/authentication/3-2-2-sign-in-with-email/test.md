# Test — Sign In With Email

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Login đúng email/pw (2FA tắt) | AC "trả JWT" | 200, access+refresh token | Chưa test |
| TC-02 | Login sai pw | Error "INVALID_CREDENTIALS" | 401, không tiết lộ email tồn tại | Chưa test |
| TC-03 | Login email case khác (`USER@gmail.com`) | Edge "chuẩn hóa email" | login thành công | Chưa test |
| TC-04 | Login account deactivated | Error "ACCOUNT_DEACTIVATED" | 403 `ACCOUNT_DEACTIVATED` | Chưa test |
| TC-05 | Login account 2FA bật | AC "chặn trước khi cấp token" | 200 `requireTwoFactor=true` + `twoFactorToken`, KHÔNG accessToken | Chưa test |
| TC-06 | Login 2FA bật, gọi /2fa/verify đúng | AC "hoàn tất login-2FA" | 200 access+refresh token | Chưa test |
| TC-07 | Không yêu cầu OTP ở login (2FA tắt) | AC "không OTP" | login thẳng, không bước OTP | Chưa test |
| TC-08 | Login account suspended | Error "ACCOUNT_SUSPENDED" | 403 `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | Login OAuth-only account (không password) | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-10 | Login bằng phone identifier không tồn tại | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-11 | Refresh token sai/hết hạn | Error "REFRESH_TOKEN_INVALID" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
| TC-12 | Refresh token đã blacklist (sau logout) | Error "REFRESH_TOKEN_BLACKLISTED" | 401 `REFRESH_TOKEN_BLACKLISTED` | Chưa test |
| TC-13 | Refresh sau reset password (`iat < lastPasswordChange`) | Edge "revoke mọi thiết bị" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
| TC-14 | Refresh khi user deactivated | Edge "không login được" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |

## Dev Quick Login repair — 2026-10-04

- RED: Manager không được đưa tới UUID cũ, Creator không được dừng ở Agency khi API có Workspace đúng CREATOR.
- Quyền lấy từ myRole trả về; test API trả CREATOR trước MANAGER để chứng minh chọn theo quyền, không chọn phần tử đầu tiên; không ép store systemRole theo nhãn nút.
- OWNER → Agency; CLIENT → ClientProfile; ADMIN → Admin. Không có role phù hợp → fallback Agency/hướng dẫn seed.
- 2FA challenge không gọi users/me, chuyển xác minh; stale-token login tests vẫn pass.
- Live bốn role: login/profile/Workspace hoặc ClientProfile đọc thành công, không 401/403 ngoài hành vi bảo vệ quyền hợp lệ.
- Seed rerun hai lần không nhân bản users/agency/workspaces/member/profile/package; không đổi mật khẩu/status tài khoản hiện hữu và không đụng dữ liệu Admin demo.

Kết quả đã kiểm tra ngày 2026-10-04:

| Kiểm tra | Kết quả |
|---|---|
| RED trước sửa | 3 test thất bại đúng nguyên nhân: Manager dùng UUID cũ, Creator dừng ở Agency, challenge 2FA gọi profile trước xác minh. |
| E2E sau sửa | 16/16 pass: 4 Dev Quick Login, 2 stale-session, 10 Admin overview. |
| Owner qua API thật | `/agency`; login, profile và danh sách Agency đều HTTP 200. |
| Manager qua API thật | `/workspaces/d3100000-0000-4000-8000-000000000002/dashboard`; login, profile và dashboard HTTP 200. |
| Creator qua API thật | `/workspaces/d3100000-0000-4000-8000-000000000003/dashboard`; login, profile và dashboard HTTP 200. |
| Client qua API thật | `/client-profiles`; login, profile và danh sách brand profile HTTP 200. |
| Quyền/session | Cả bốn phiên có systemRole USER, authenticated; không lỗi JavaScript hoặc API 4xx/5xx khi mở màn tương ứng. |
| SQL fixture | Dry-run kết thúc ROLLBACK thành công, áp dụng COMMIT thành công; chạy lại cho snapshot dữ liệu fixture/credentials/status/roles giống hệt (`Idempotent: true`). |
| Chất lượng frontend | ESLint các file TS thay đổi, `tsc -b` và Vite production build đều exit 0. |

Test 2FA ở đây kiểm tra nhánh điều hướng frontend bằng response mock; chưa thay thế kiểm thử backend login → OTP verify trong checklist phía trên.


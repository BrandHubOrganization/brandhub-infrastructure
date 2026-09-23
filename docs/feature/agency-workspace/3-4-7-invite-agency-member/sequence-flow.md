# Sequence Flow — Invite Agency Member → Accept Invitation

> Bổ sung cho `spec.md` (FR 3.4.7) + `3-4-8-view-agency-invitation-status/spec.md` (FR 3.4.8). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyServiceImpl`, `AuthGuard.tsx`, `authRedirect.ts`).

## Actors

- **Owner** — chủ Agency, người gửi lời mời.
- **Invitee** — người được mời (có thể chưa có tài khoản).
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agency_invitations`, `workspace_members`, `client_profiles`).
- **Mail** — SMTP (Gmail), gửi async (`@Async`).

---

## Flow A — Owner gửi lời mời (role MANAGER/CREATOR, không CLIENT)

1. Owner → FE: mở `/agency/:id/members`, điền form (email, tên tuỳ chọn, note tuỳ chọn, hạn 1–30 ngày mặc định 30, chọn workspace + role tuỳ chọn).
2. FE → BE: `POST /api/v1/agencies/{agencyId}/invitations` `{email, inviteeName?, note?, workspaceId?, role?, expiryDays?}`.
3. BE (`AgencyServiceImpl.inviteMember`):
   a. Check caller là Owner của agency đó — không phải → `403 NOT_AGENCY_OWNER`.
   b. Check email đã là `AgencyMember` — có rồi → `409 ALREADY_AGENCY_MEMBER`.
   c. Check đã có invitation `PENDING` chưa hết hạn cho email đó → `409 INVITATION_ALREADY_PENDING`.
   d. Check số invitation `PENDING` hiện tại của agency ≥ 20 (`MAX_PENDING_INVITATIONS`) → `409 TOO_MANY_PENDING_INVITATIONS`.
   e. Nếu có `workspaceId`: load workspace, check thuộc đúng agency — sai → `400 WORKSPACE_NOT_IN_AGENCY`. Nếu `role=MANAGER`: check workspace đó chưa có MANAGER active (`assertNoManagerYet`) → `409 MANAGER_ALREADY_ASSIGNED`.
   f. Nếu `role=CLIENT` mà không kèm `workspaceId` → `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` (xem Flow B — CLIENT luôn cần workspace).
4. BE → DB: `INSERT agency_invitations` (status=PENDING, token=UUID random, expiresAt=now+expiryDays, note, workspaceId, role).
   - Unique constraint thật: `idx_agency_inv_unique_pending` — **partial unique chỉ trên status=PENDING** (sửa 2026-09-23; trước đó unique toàn bộ trạng thái, chặn nhầm cả email đã REVOKED/EXPIRED).
5. BE → Mail (async, không block response): `sendAgencyInvitationEmail` — email chứa link `{FRONTEND_URL}/invitations/accept?token={token}`.
6. BE → FE: `201 { id, agencyId, agencyName, invitedEmail, invitedBy, token, note, workspaceId, workspaceName, role, status=PENDING, expiresAt, acceptedAt=null, createdAt }`.
7. FE: hiện toast thành công, thêm dòng vào bảng invitation `PENDING`.

## Flow B — Owner gửi lời mời role CLIENT

Giống Flow A bước 1–4, khác biệt:

- `workspaceId` **bắt buộc** ngay từ bước 1 (FE chặn submit nếu role=CLIENT mà chưa chọn workspace).
- BE lưu `role=CLIENT` + `workspaceId` trong `agency_invitations` — chưa tạo `WorkspaceMember` gì ở bước này, chỉ tạo khi accept (xem Flow D).

---

## Flow C — Invitee đã có tài khoản, bấm link mời

1. Invitee → click link email → FE mở `/invitations/accept?token=X`.
2. `AuthGuard` check `isAuthenticated` = true (đã login sẵn) → cho qua thẳng, không redirect.
3. `AcceptInvitationPage` mount → FE → BE: `POST /api/v1/agencies/invitations/accept` `{token}`.
4. BE (`AgencyServiceImpl.acceptInvitation`):
   a. Tìm invitation theo token — không có → `400 INVALID_INVITATION`.
   b. Check `status=PENDING` và chưa hết hạn — sai → `400 INVALID_INVITATION`.
   c. Check email invitation khớp email user đang login — sai → `400 INVALID_INVITATION`.
   d. Nếu `role=CLIENT` → rẽ nhánh **Flow D** (`acceptClientInvitation`), return sớm.
   e. (role khác CLIENT) Check đã là `AgencyMember` chưa — có rồi → `409 ALREADY_AGENCY_MEMBER`.
   f. `INSERT agency_members` (role=MEMBER, không có role cụ thể — role chỉ có ý nghĩa ở cấp Workspace).
   g. Update invitation `status=ACCEPTED`, `acceptedAt=now`.
5. BE → FE: `200 { agencyId, userId, fullName, email, ... }`.
6. FE: toast thành công, `setTimeout` 1.2s → `navigate("/agency")`.

## Flow D — Accept invitation role CLIENT (`acceptClientInvitation`)

Tiếp theo bước 4.d ở Flow C:

1. Check invitation có `workspaceId` — không có (dữ liệu hỏng, không nên xảy ra vì Flow B đã validate) → `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`.
2. BE → DB: tìm `ClientProfile` theo `(userId, agencyId)` — chưa có thì tạo mới (`displayName = user.fullName`).
3. BE → DB: check user đã có `WorkspaceMember` active trong workspace đó chưa — chưa có thì `INSERT workspace_members` (role=CLIENT, userId, clientProfileId, addedBy=invitation.invitedBy, isActive=true).
   - Constraint DB: `chk_workspace_members_identity` — CLIENT bắt buộc có `client_profile_id`; role khác CLIENT bắt buộc có `user_id` và **không** có `client_profile_id` (sửa 2026-09-23 để CLIENT được có cả `user_id` lẫn `client_profile_id` cùng lúc — trước đó chặn `user_id` khi role=CLIENT, không hỗ trợ client tự login).
4. Update invitation `status=ACCEPTED`, `acceptedAt=now`.
5. BE → FE: `200 { agencyId, userId, fullName, email, ... }` (không có `workspaceId`/role trong response này — `AgencyMemberResponse` dùng chung cho cả 2 nhánh).
6. FE: giống bước 6 Flow C — về `/agency` sau 1.2s.

---

## Flow E — Invitee CHƯA có tài khoản, bấm link mời

Đây là nhánh vừa sửa 2026-09-23 (trước đó bị gãy — token mất khi qua register/OTP/login).

1. Invitee → click link email → FE mở `/invitations/accept?token=X`.
2. `AuthGuard` check `isAuthenticated` = false → `<Navigate to="/login" replace state={{from: location}} />` (location gồm `pathname=/invitations/accept`, `search=?token=X`).
3. `LoginPage` mount → đọc `location.state.from` → `saveAuthRedirect(from.pathname + from.search)` ghi vào `sessionStorage["brandhub-auth-redirect"]`.
4. Invitee bấm tab "Đăng ký" → FE `navigate("/register")` (không cần truyền state — đã có trong sessionStorage).
5. `RegisterPage` mount → cũng tự đọc `location.state.from` nếu có (phòng trường hợp AuthGuard redirect thẳng vào register) → lưu tương tự bước 3.
6. Invitee điền form → FE → BE: `POST /api/v1/auth/register` → BE tạo `User` (chưa active), gửi OTP email.
7. FE → `navigate("/verify-otp?email=...")`. (sessionStorage redirect vẫn giữ nguyên qua bước này — không đụng tới.)
8. Invitee nhập OTP → FE → BE: `POST /api/v1/auth/verify-otp` → thành công → FE → `navigate("/login")`.
9. Invitee đăng nhập (email/password) → FE → BE: `POST /api/v1/auth/login`.
   - **Nhánh phụ — nếu tài khoản bật 2FA**: BE trả `{requireTwoFactor: true, twoFactorToken}` → FE lưu `twoFactorToken` vào `sessionStorage["brandhub-2fa-token"]`, `navigate("/2fa-verify")` → `TwoFactorVerifyPage` → nhập mã → BE: `POST /api/v1/auth/2fa/verify` → thành công, có `accessToken` → tiếp bước 10 (thay vì từ bước 9).
10. Login thành công → FE lưu `accessToken` vào store → gọi `GET /api/v1/users/me` lấy profile → `setAuth(...)` → `navigate(consumeAuthRedirect())`.
    - `consumeAuthRedirect()` đọc + xoá `sessionStorage["brandhub-auth-redirect"]` → trả về `/invitations/accept?token=X` (đích đã lưu từ bước 3) — nếu không có gì lưu, fallback `/dashboard`.
11. FE điều hướng về `/invitations/accept?token=X` → tiếp tục **Flow C từ bước 3** (đã login, AuthGuard cho qua, gọi accept API).

### Nhánh phụ — OAuth (Google) khi chưa có tài khoản

Thay bước 6–10 ở trên bằng:

6'. Invitee bấm nút Google trên `LoginPage` (`<a href={oauthUrl("google")}>`) — `href` trỏ thẳng backend, browser rời khỏi SPA hoàn toàn.
   - `sessionStorage["brandhub-auth-redirect"]` đã lưu từ bước 3 **trước khi rời trang** — sessionStorage tồn tại theo tab, sống sót qua redirect ngoài domain.
7'. Backend (`GoogleOAuthController`) redirect Google OAuth consent → Google redirect lại backend callback → backend tạo/login user.
   - **Nhánh phụ — nếu tài khoản bật 2FA**: backend redirect FE `/2fa-verify?twoFactorToken=...` (query param, không phải sessionStorage) thay vì bước 8'. `TwoFactorVerifyPage` đọc `twoFactorToken` từ URL trước, fallback `sessionStorage["brandhub-2fa-token"]`. Verify xong → tiếp bước 10' bằng `consumeAuthRedirect()` (sessionStorage `brandhub-auth-redirect` vẫn còn nguyên từ bước 6', không bị mất qua chặng 2FA vì đây vẫn là cùng tab/domain FE).
   - Không bật 2FA: backend redirect thẳng FE `/oauth-callback#token=...` — token nằm ở **URL fragment** (`#`), không phải query string.
8'. `OAuthCallbackPage` mount → `useOAuthCallback()` → `resolveCallback()` đọc token từ `window.location.hash` (fallback query nếu có), gọi `GET /api/v1/users/me`, `setAuth(...)`.
9'. Thành công → `navigate(consumeAuthRedirect(), {replace: true})` — đọc lại sessionStorage đã lưu từ bước 6', về đúng `/invitations/accept?token=X`.
10'. Tiếp tục **Flow C từ bước 3**.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Invite (Flow A/B) | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Invite | Email đã là AgencyMember | 409 | `ALREADY_AGENCY_MEMBER` |
| Invite | Đã có invitation PENDING cho email | 409 | `INVITATION_ALREADY_PENDING` |
| Invite | ≥20 invitation PENDING | 409 | `TOO_MANY_PENDING_INVITATIONS` |
| Invite | workspaceId không thuộc agency | 400 | `WORKSPACE_NOT_IN_AGENCY` |
| Invite | role=MANAGER nhưng workspace đã có MANAGER | 409 | `MANAGER_ALREADY_ASSIGNED` |
| Invite | role=CLIENT thiếu workspaceId | 400 | `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` |
| Accept | Token không tồn tại | 400 | `INVALID_INVITATION` |
| Accept | Status ≠ PENDING hoặc hết hạn | 400 | `INVALID_INVITATION` |
| Accept | Email đăng nhập ≠ email invitation | 400 | `INVALID_INVITATION` |
| Accept (non-CLIENT) | Đã là AgencyMember | 409 | `ALREADY_AGENCY_MEMBER` |
| Accept (CLIENT) | Invitation thiếu workspaceId (data lỗi) | 400 | `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` |

## Ghi chú khác biệt so với spec.md gốc (3.4.7 / 3.4.8) — cần cập nhật riêng

- `spec.md` 3.4.7 mục 7 ghi "khi đăng ký đúng email thì tự động accept invitation" — **sai với code thật**, không có auto-accept, luôn cần bấm lại link/gọi API accept sau khi có tài khoản (Flow E bước 11).
- `spec.md` 3.4.7 mục "Out of Scope" ghi "mời trực tiếp vào 1 Workspace kèm role ngay từ bước Invite" — **đã có trong code** (`workspaceId`/`role` trong `InviteAgencyMemberRequest`), không còn out-of-scope.
- `spec.md` 3.4.8 ghi "hết hạn sau 3 ngày cố định" — **đã đổi**: mặc định 30 ngày, tuỳ chỉnh 1–30 qua `expiryDays`.
- `spec.md` 3.4.8 "Out of Scope: gia hạn/resend" — **đã có cancelInvitation** (`DELETE /{agencyId}/invitations/{invitationId}`, chỉ Owner, chỉ khi PENDING) — resend thật vẫn chưa có (đúng như spec), nhưng cancel thì có rồi, cần cập nhật mục này.

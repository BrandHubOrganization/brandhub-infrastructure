# UC — User Settings (Profile / Avatar / Security)

| | |
|---|---|
| Feature | User Settings page |
| Jira | DA-E13-01 (GET/PUT /users/me), DA-E13-02 (avatar upload) — cả 2 backend đã build sẵn, assignee Trung |
| Nhóm | C. User & Profile Management |

## 1. Objective

Dropdown "Thiết lập" ở Navbar hiện chỉ `navigate("/")` — không có trang settings thật. Backend đã có đủ API (`GET/PUT /api/v1/users/me`, `POST /api/v1/users/me/avatar`) từ DA-E13-01/02 nhưng chưa có frontend dùng tới. `ChangePasswordPage.tsx` tồn tại độc lập, tự ghi chú "Trang test tạm — giao diện chính thức làm sau".

Feature này: xây trang `/settings` thật, gộp Profile + Avatar + đổi mật khẩu vào 1 nơi có tabs, thay thế route `/change-password` rời rạc.

## 2. User Story

Là một user đã đăng nhập,
tôi muốn xem/sửa thông tin cá nhân (tên, timezone, avatar) và đổi mật khẩu ở cùng 1 chỗ,
để quản lý tài khoản của mình mà không phải tìm rải rác nhiều trang.

## 3. Acceptance Criteria

### Tab Profile
- Hiển thị `email` (read-only — API không cho sửa email, cần flow verify riêng ngoài scope).
- Form sửa `fullName` (bắt buộc), `timezone` (bắt buộc, dùng danh sách IANA timezone hoặc input tự do — BE validate `ZoneId.of()`).
- `notificationPreferences` — object tự do theo BE (`Map<String, Object>`), UI tối thiểu: toggle bật/tắt email notification (`{ "email": true/false }`), không cần UI phức tạp hơn API hiện có.
- Submit → `PUT /api/v1/users/me` → toast success, cập nhật `authStore.user.name` nếu đổi fullName.

### Tab Avatar
- Hiển thị avatar hiện tại (`avatarUrl` từ `GET /users/me`, fallback chữ cái đầu tên như đang dùng ở Navbar).
- Input file, chỉ nhận JPEG/PNG/WebP, tối đa 5MB (khớp BE validate) — validate phía client trước khi upload để tránh gọi API dư.
- Upload thành công → `POST /api/v1/users/me/avatar` → cập nhật avatar hiển thị ngay, không cần reload.

### Tab Security (gộp từ ChangePasswordPage.tsx)
- 3 field: mật khẩu hiện tại, mật khẩu mới, xác nhận mật khẩu mới — y nguyên logic `ChangePasswordPage.tsx` hiện có (`authService.changePassword`).
- Submit thành công → toast, không navigate đi đâu (khác hành vi cũ `navigate("/")` — ở lại trang Settings vì giờ đây là trang chính, không phải flow rời).

### Navbar wiring
- `DropdownMenuItem "Thiết lập"` đổi từ `navigate("/")` → `navigate("/settings")`.
- Route `/change-password` — xoá khỏi `App.tsx`, `ChangePasswordPage.tsx` xoá file (logic đã chuyển vào tab Security).

### Đa ngôn ngữ (i18n)
- Namespace mới `settings.*`: `settings.title`, `settings.tabs.profile`, `settings.tabs.avatar`, `settings.tabs.security`, `settings.profile.fullNameLabel`, `settings.profile.timezoneLabel`, `settings.profile.emailLabel`, `settings.profile.notificationLabel`, `settings.profile.saveSuccess`, `settings.avatar.uploadButton`, `settings.avatar.uploadSuccess`, `settings.avatar.invalidType`, `settings.avatar.tooLarge`, `settings.security.*` (tái dùng key cũ nếu `ChangePasswordPage.tsx` đã có sẵn — kiểm tra trước khi tạo mới).
- Thêm đủ cả `vi.json`/`en.json`.

### Light/Dark mode
- Dùng token theme sẵn có, theo đúng pattern `PageWrapper` + `border-border bg-card` đã dùng ở các trang khác trong session này — không hardcode màu.

## 4. UI / UX

- Route `/settings` (đổi từ `/change-password`), nằm trong `AuthGuard` + `Layout` như các trang khác.
- Dùng component Tabs có sẵn trong `components/ui/` nếu tồn tại (kiểm tra trước khi build mới) — nếu chưa có, dùng pattern đơn giản (state `activeTab` + conditional render, giống cách `LoginPage.tsx` xử lý toggle Sign in/Sign up).
- Avatar: dùng `<input type="file">` ẩn, trigger qua button, hiển thị preview trước khi confirm nếu dễ làm — không bắt buộc nếu tốn thời gian.

### UI States
- Loading ban đầu: fetch `GET /users/me` khi mount, skeleton/`null` return trong lúc chờ (theo pattern các trang workspace đã làm).
- Avatar uploading: disable button + spinner trong lúc chờ response.
- Error: toast qua `extractErrorMessage`.

## 5. API Contract (đã có sẵn — DA-E13-01/02, backend không cần sửa)

```
GET /api/v1/users/me
→ 200 { "success": true, "data": { "userId", "email", "fullName", "avatarUrl", "role", "workspaceId", "createdAt" } }

PUT /api/v1/users/me
{ "fullName": "string", "timezone": "string", "notificationPreferences": { ... } }
→ 200 { "success": true, "data": { ...UserProfileResponse... } }

POST /api/v1/users/me/avatar  (multipart/form-data, field "file")
→ 200 { "success": true, "data": { "avatarUrl": "string" } }
→ 400 nếu sai type, 413 nếu quá 5MB
```

`userService.ts` đã có `getProfile()` (từ feature workspace-context-role-display) — bổ sung `updateProfile()`, `uploadAvatar()`.

## 6. Error Handling

- `PUT /users/me` thiếu `fullName`/`timezone` → 400, hiển thị lỗi field-level nếu BE trả (kiểm tra `GlobalExceptionHandler` format).
- Avatar sai type → 400, toast rõ ràng "chỉ nhận JPEG/PNG/WebP".
- Avatar quá 5MB → 413, toast rõ dung lượng tối đa.
- Đổi mật khẩu sai mật khẩu hiện tại → theo lỗi `authService.changePassword` đã xử lý sẵn trong `ChangePasswordPage.tsx` cũ, giữ nguyên logic.

## 7. Edge Cases

- User chưa từng có avatar (`avatarUrl = null`) → hiển thị fallback chữ cái đầu tên, giống Navbar hiện tại.
- Đổi `fullName` ở tab Profile → cần đồng bộ lại tên hiển thị ở Navbar/Sidebar ngay (qua `authStore.setAuth` với `user` mới) — không cần reload trang.
- Timezone input tự do (không dropdown chuẩn IANA) → nếu user nhập sai, BE trả 400 rõ ràng đủ tốt, không cần validate phức tạp phía FE trong scope này.

## 8. Definition of Done

- Toàn bộ Acceptance Criteria mục 3 đạt.
- `userService.ts`: thêm `updateProfile()`, `uploadAvatar()`.
- `pages/SettingsPage.tsx` (hoặc `pages/settings/SettingsPage.tsx`) mới, route `/settings`.
- Xoá `ChangePasswordPage.tsx` + route `/change-password` cũ.
- `Navbar.tsx`: "Thiết lập" trỏ đúng `/settings`.
- Test case mục test.md pass.
- `tsc --noEmit`, `eslint` clean.

## Out of Scope

- Đổi email (cần flow verify riêng, BE explicit không cho sửa qua endpoint này).
- Admin xem/sửa user khác (DA-E13-03/04, thuộc Ân, không liên quan trang settings của chính user).
- 2FA, session management, xem lịch sử đăng nhập — không có trong BE hiện tại.

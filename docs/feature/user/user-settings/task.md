# Task — User Settings Page

## Service
- [ ] `userService.ts` — thêm `updateProfile(data)` (PUT /users/me).
- [ ] `userService.ts` — thêm `uploadAvatar(file)` (POST /users/me/avatar, multipart).

## SettingsPage
- [ ] Khung trang mới `pages/settings/SettingsPage.tsx`, state tab (`profile`/`avatar`/`security`).
- [ ] Fetch profile lúc mount qua `userService.getProfile()`.
- [ ] Tab Profile: form fullName/timezone/notification toggle, submit `updateProfile()`.
- [ ] Tab Avatar: input file, validate type (JPEG/PNG/WebP) + size (≤5MB) client-side trước khi gọi API.
- [ ] Tab Avatar: upload thành công → cập nhật hiển thị + đồng bộ `authStore.user.avatar`.
- [ ] Tab Security: copy logic `ChangePasswordPage.tsx`, bỏ `navigate("/")` sau submit.
- [ ] Đổi fullName → đồng bộ `authStore.setAuth` ngay, không cần F5.

## Wiring
- [ ] `App.tsx` — xoá route `/change-password`, thêm route `/settings`.
- [ ] Xoá file `ChangePasswordPage.tsx`.
- [ ] `Navbar.tsx` — "Thiết lập" trỏ `navigate("/settings")`.
- [ ] i18n `settings.*` — thêm đủ cả `vi.json`/`en.json`, key-parallel.

## Verify
- [ ] `tsc --noEmit` clean.
- [ ] `eslint` clean cho file đã sửa.
- [ ] Test tay: đổi fullName → Navbar/Sidebar cập nhật tên ngay.
- [ ] Test tay: upload avatar hợp lệ → hiển thị đổi ngay.
- [ ] Test tay: upload avatar sai type/quá size → toast lỗi đúng, không crash.
- [ ] Test tay: đổi mật khẩu đúng → toast success, ở lại trang Settings.
- [ ] Test tay: đổi mật khẩu sai mật khẩu hiện tại → toast lỗi.
- [ ] Test tay: reload lúc đang ở tab Avatar/Security → không lỗi, quay về tab Profile mặc định là chấp nhận được.

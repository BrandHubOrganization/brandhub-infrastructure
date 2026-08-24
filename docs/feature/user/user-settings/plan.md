# Plan — User Settings Page

## Mục tiêu
Xây trang `/settings` thật thay placeholder — gộp Profile/Avatar/Security vào 1 trang có tabs. Backend đã đủ API (DA-E13-01/02), thuần frontend.

## Thành phần liên quan

**Frontend:**
- `src/services/userService.ts` — đã có `getProfile()`. Thêm `updateProfile(data)` (PUT), `uploadAvatar(file)` (POST multipart).
- `src/pages/settings/SettingsPage.tsx` — file mới, route `/settings`.
- `src/pages/ChangePasswordPage.tsx` — xoá, logic chuyển vào `SettingsPage.tsx` tab Security.
- `src/App.tsx` — xoá route `/change-password`, thêm route `/settings`.
- `src/components/layout/Navbar.tsx` — sửa `onClick={() => navigate("/")}` → `navigate("/settings")` ở `DropdownMenuItem "Thiết lập"`.
- `src/i18n/locales/{vi,en}.json` — thêm namespace `settings.*` (khác `workspace.settings.*` đã tồn tại — không đụng).

**Không có component Tabs primitive sẵn** (`components/ui/` chỉ có `table.tsx`, không có `tabs.tsx`) — dùng state-based tab đơn giản (`useState<"profile"|"avatar"|"security">`, conditional render), theo đúng pattern `LoginPage.tsx` đã dùng cho toggle Sign in/Sign up. Không thêm Radix Tabs primitive mới cho 3 tab đơn giản này.

## Quyết định kiến trúc

- **1 file `SettingsPage.tsx`, không tách 3 file con.** 3 tab đơn giản (form ngắn), tách file sẽ tạo prop-drilling không cần thiết cho state `profile`/`loading` dùng chung. Nếu sau này phức tạp hơn, tách lại — YAGNI.
- **`uploadAvatar` dùng `FormData` + `multipart/form-data`** qua `api` instance có sẵn (axios tự set Content-Type boundary khi truyền `FormData`, không cần override header thủ công).
- **Đồng bộ `authStore.user` sau khi đổi `fullName`/avatar** — gọi `setAuth(updatedUser, currentToken)` để Navbar/Sidebar cập nhật tên/avatar ngay, không cần user tự F5.
- **`notificationPreferences` — chỉ 1 toggle đơn giản** (`{ email: boolean }`), không xây UI phức tạp hơn field `Map<String,Object>` tự do của BE. Nếu sau này cần nhiều loại notification hơn, mở rộng object mà không cần đổi API.
- **Validate file avatar phía client trước khi gọi API** (type + size) — giảm round-trip không cần thiết, dùng lại đúng rule BE đã định nghĩa (JPEG/PNG/WebP, ≤5MB) để tránh lệch giữa 2 phía.

## Thứ tự build

1. `userService.ts` — thêm `updateProfile()`, `uploadAvatar()`.
2. `SettingsPage.tsx` — khung trang + state tab + fetch profile lúc mount (dùng lại `userService.getProfile()` đã có).
3. Tab Profile — form fullName/timezone/notification, submit `updateProfile()`.
4. Tab Avatar — input file, validate client, upload, cập nhật hiển thị + `authStore`.
5. Tab Security — copy logic từ `ChangePasswordPage.tsx` (form 3 field + `authService.changePassword`), bỏ `navigate("/")` sau submit.
6. Wiring: `App.tsx` route, xoá `ChangePasswordPage.tsx`, `Navbar.tsx` trỏ `/settings`.
7. i18n: thêm `settings.*` cả 2 file, đảm bảo key-parallel.
8. Test tay qua Chrome DevTools: đổi fullName → xác nhận Navbar cập nhật tên ngay; upload avatar → xác nhận hiển thị đổi; đổi mật khẩu → xác nhận vẫn ở lại trang.
9. `tsc --noEmit` + `eslint`.

## Rủi ro

- BE `PUT /users/me` bắt buộc cả 3 field (`@NotBlank fullName`, `@NotBlank timezone`, `@NotNull notificationPreferences`) — không cho update từng phần (partial update). Form Profile phải luôn gửi đủ 3 field kể cả khi user chỉ sửa 1 field — cần giữ state đầy đủ từ lúc fetch ban đầu, không để field nào rỗng khi submit.
- `GlobalExceptionHandler` format lỗi field-level chưa xác nhận trong session này (không đọc lại) — nếu format khác giả định, fallback dùng `extractErrorMessage` generic đã có, không chặn tiến độ.

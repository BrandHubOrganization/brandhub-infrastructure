# Task — Landing Page: Language Switcher + Theme Toggle

## i18n backend

- [x] Sửa `src/i18n/index.ts`: đọc `localStorage.getItem("brandhub-lang")` khi init `lng`
- [x] Thêm key `common.switchLanguage` vào `vi.json` + `en.json`
- [x] Thêm key `common.toggleTheme` vào `vi.json` + `en.json`
- [x] Verify 2 file JSON vẫn parse hợp lệ, key-parallel

## Component LandingControls

- [x] Tạo `src/components/landing/LandingControls.tsx`
- [x] Nút Language: hiện `VI`/`EN` hiện tại, click → `i18n.changeLanguage()` + lưu localStorage
- [x] Nút Theme: icon Sun/Moon theo trạng thái, click → `setTheme("light"|"dark")` từ `useTheme()`
- [x] Style: `fixed top-4 right-4 z-50`, pill/glass background đọc được cả 2 nền
- [x] `aria-label` cho cả 2 nút dùng i18n key mới

## Wiring

- [x] Import + render `<LandingControls />` trong `DashboardPage.tsx` (nhánh unauthenticated)
- [x] Verify không đụng nhánh authenticated (dashboard nội bộ)

## Kiểm tra light/dark mode (bắt buộc theo rule)

- [x] Screenshot 2 nút trên nền Hero tối (`bg-zinc-950`)
- [x] Screenshot 2 nút trên nền section sáng (Features `bg-white`)
- [x] Click Theme toggle → verify `<html>` class đổi `dark`↔`light`, toàn trang đổi màu đúng
- [x] Reload trang → verify theme đã chọn vẫn giữ

## Kiểm tra đa ngôn ngữ (bắt buộc theo rule)

- [x] Click Language toggle → verify toàn bộ text landing page đổi ngôn ngữ ngay
- [x] Reload trang → verify ngôn ngữ đã chọn vẫn giữ
- [x] Không có text nào "sót" (vẫn tiếng Việt cứng khi đã chuyển English) trong phạm vi landing page

## Verify cuối

- [x] `npx tsc --noEmit` sạch
- [x] `npm run lint` không phát sinh lỗi mới
- [x] Test browser desktop + mobile (đảm bảo 2 nút không đè content ở mobile nhỏ)

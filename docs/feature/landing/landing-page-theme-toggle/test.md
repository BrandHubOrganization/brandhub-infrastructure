# Test — Landing Page: Language Switcher + Theme Toggle

> Tất cả 9 test case: PASS (verify qua browser automation sau khi code xong).

## TC1 — 2 nút hiển thị đúng vị trí, đọc được mọi section

**Input:** Load landing page, cuộn từ Hero → Footer.
**Expected:** 2 nút luôn ở góc trên phải, không bị section nào che, text/icon
đọc rõ trên cả nền tối (Hero) và nền sáng (Features, Pricing...).

## TC2 — Language switcher đổi ngôn ngữ

**Input:** Click nút Language (đang `VI`).
**Expected:** Nút đổi hiện `EN`, toàn bộ text landing page (heading, mô tả,
CTA...) đổi sang tiếng Anh ngay lập tức, không cần reload.

## TC3 — Language persist qua reload

**Input:** Sau TC2, reload trang (F5).
**Expected:** Trang load lại vẫn hiện tiếng Anh (không quay về `vi` mặc định).

## TC4 — Theme toggle đổi màu toàn trang

**Input:** Click nút Theme (đang light hoặc theo system).
**Expected:** `<html>` class đổi `dark`/`light`, toàn bộ section landing đổi
màu nền/chữ tương ứng (Features `bg-white`→`dark:bg-zinc-950`, v.v — dùng
token có sẵn, không cần code thêm vì `dark:` variant đã tồn tại).

## TC5 — Theme persist qua reload

**Input:** Sau TC4, reload trang.
**Expected:** Theme đã chọn giữ nguyên (đọc từ `localStorage["vite-ui-theme"]`
qua `theme-provider.tsx` có sẵn).

## TC6 — Không phá animation Hero

**Input:** Load trang, xem Hero animation chạy (IG→TT→FB→LI→MacBook).
**Expected:** 2 nút không che/đè lên post card hay MacBook demo, animation
chạy bình thường như trước khi thêm 2 nút.

## TC7 — Mobile không tràn

**Input:** Resize 375×667, 320×568.
**Expected:** 2 nút vẫn gọn trong viewport, không đè lên nội dung Hero quan
trọng (post card, CTA).

## TC8 — i18n key-parallel

**Input:** Diff `vi.json`/`en.json` phần `common.switchLanguage`,
`common.toggleTheme`.
**Expected:** Cả 2 file có key, khác value.

## TC9 — Type-check & lint

**Input:** `npx tsc --noEmit`, `npm run lint`.
**Expected:** Sạch, không lỗi mới.

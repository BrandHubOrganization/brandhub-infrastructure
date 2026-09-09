# Plan — Landing Page: Language Switcher + Theme Toggle

## Thành phần mới

| File | Vai trò |
|---|---|
| `src/components/landing/LandingControls.tsx` (mới) | Component chứa 2 nút (Language + Theme), floating fixed |
| `src/pages/DashboardPage.tsx` | Render `<LandingControls />` trong nhánh unauthenticated (trước `<CinematicHero />` hoặc ngoài wrapper div) |
| `src/i18n/index.ts` | Đọc `localStorage` lúc init để giữ lựa chọn ngôn ngữ qua reload |
| `src/i18n/locales/{vi,en}.json` | Thêm `common.switchLanguage`, `common.toggleTheme` |

## Không tạo mới

- Không tạo theme system mới — dùng `useTheme()` từ `theme-provider.tsx`
  (đã có sẵn, đã mount ở `main.tsx`).
- Không cần `i18next-browser-languagedetector` package — tự đọc/ghi
  `localStorage` bằng key riêng (`brandhub-lang`) trong `changeLanguage`
  handler, đơn giản hơn thêm dependency mới cho nhu cầu nhỏ này.

## Chi tiết kỹ thuật

**Xác định theme hiện tại để chọn icon Sun/Moon:**
`theme-provider.tsx`'s `theme` state có thể là `"system"` — không đủ để biết
đang sáng hay tối. Cách đơn giản: click toggle chỉ set thẳng `"light"`/
`"dark"` (bỏ qua "system" hoàn toàn từ UI này theo Out of Scope đã ghi trong
spec) — vậy `theme !== "system"` luôn đúng sau lần đầu user bấm, và trước đó
dùng `window.matchMedia("(prefers-color-scheme: dark)").matches` làm
fallback hiển thị icon ban đầu khi `theme === "system"`.

**i18n init đọc localStorage:**
```ts
const savedLang = localStorage.getItem("brandhub-lang");
i18n.use(initReactI18next).init({
  resources: { vi: { translation: vi }, en: { translation: en } },
  lng: savedLang === "en" ? "en" : "vi",
  fallbackLng: "vi",
  interpolation: { escapeValue: false },
});
```
Component `LandingControls` khi click: `i18n.changeLanguage(next)` +
`localStorage.setItem("brandhub-lang", next)`.

**Vị trí render:** `DashboardPage.tsx`, nhánh unauthenticated — thêm
`<LandingControls />` là sibling của `<CinematicHero />` trong cùng wrapper
div (`style={{ fontFamily: "var(--font-sans)" }}`), không phải con của
`CinematicHero` (giữ tách biệt, không đụng file `CinematicHero.tsx` vốn đã
lớn).

**Style pill nút:** tái dùng pattern glass đã có ở nút "Xem trên iPhone"
trong `CinematicHero.tsx` (`bg-white/10 ring-1 ring-white/20 backdrop-blur-md`)
để nhất quán, nhưng cần đọc được trên nền sáng phía dưới — thêm nền có
opacity đủ cao + border rõ để contrast tốt ở cả 2 nền (test thực tế bằng
screenshot ở nhiều section).

## Thứ tự build

1. Sửa `src/i18n/index.ts` đọc localStorage (không đổi behavior khi chưa có
   lựa chọn lưu — vẫn mặc định `vi`).
2. Thêm 2 i18n key vào `vi.json`/`en.json`.
3. Tạo `LandingControls.tsx`.
4. Wire vào `DashboardPage.tsx`.
5. Test browser: cuộn qua toàn bộ section, click cả 2 nút, reload kiểm tra
   persist, test cả light/dark Hero background.

## Rủi ro

- **`localStorage` không khả dụng** (một số trình duyệt chặn trong private
  mode): `getItem`/`setItem` có thể throw. `theme-provider.tsx` gốc không
  try/catch — giữ nguyên convention đó cho `LandingControls` (không thêm
  try/catch không nhất quán với code base có sẵn), chấp nhận rủi ro nhỏ này
  như phần còn lại của app.
- **z-index conflict** với `.cta-overlay` (z-30) trong Hero — dùng `z-50`
  đảm bảo luôn trên cùng.

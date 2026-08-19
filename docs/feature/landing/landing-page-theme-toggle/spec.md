# Spec — Landing Page: Language Switcher + Theme Toggle

## Objective

Landing page hiện có i18n backend (vi/en) và theme provider (light/dark)
sẵn sàng về kỹ thuật, nhưng **không có UI trigger nào** cho người dùng tự
đổi. Thêm 2 nút nổi (floating) ở landing page: đổi ngôn ngữ VI/EN và đổi
theme sáng/tối, đặt cạnh nhau ở vị trí luôn nhìn thấy được.

## User Story

- Là khách quốc tế ghé landing page (mặc định tiếng Việt), tôi muốn đổi
  sang tiếng Anh để đọc hiểu nội dung.
- Là khách dùng máy ở môi trường sáng/tối khác nhau, tôi muốn tự chọn theme
  thay vì chỉ phụ thuộc `prefers-color-scheme` hệ thống.

## Acceptance Criteria

- 2 nút đặt `fixed top-4 right-4 z-50` (hoặc z-index cao hơn mọi section),
  luôn hiển thị khi cuộn qua toàn bộ landing page (Hero → Footer).
- **Language switcher:** nút hiện ngôn ngữ hiện tại (`VI`/`EN`), click đổi
  ngay lập tức toàn bộ text trên trang qua `i18n.changeLanguage()`. Lưu lựa
  chọn vào `localStorage` (dùng `i18next-browser-languagedetector` nếu đã
  cấu hình, hoặc tự lưu key riêng nếu chưa) để giữ lựa chọn qua lần reload.
- **Theme toggle:** icon Sun/Moon theo theme hiện tại, click gọi
  `setTheme()` từ `useTheme()` có sẵn (`theme-provider.tsx`), cycle
  light↔dark (không cần "system" trong UI toggle đơn giản này — theme mặc
  định vẫn `system` cho tới khi user chủ động bấm).
- 2 nút đọc được ở cả nền tối của Hero (`bg-zinc-950`) và nền sáng của các
  section dưới (`bg-white`) — cần background riêng (không trong suốt) để
  đảm bảo contrast qua mọi section (tránh vi phạm rule "ghost button trên
  photographic/section background cần backdrop/scrim/stroke" của
  design-taste-frontend skill).
- Không phá vỡ animation Hero hiện có (`z-index` của 2 nút phải cao hơn
  `.mini-posts` z-20, `.cta-overlay` z-30 — dùng `z-50`).

## UI/UX

- Nhóm 2 nút trong 1 pill/container chung, `gap-2`, style glass/blur nhẹ
  (`backdrop-blur-md bg-white/10` hoặc tương tự) để hoạt động tốt trên cả
  nền tối/sáng — tương tự style nút "Xem trên iPhone" đã có trong Hero.
- Icon: `Languages` hoặc text `VI`/`EN` cho ngôn ngữ; `Sun`/`Moon` (lucide-react,
  đúng convention repo — không dùng emoji) cho theme.
- Kích thước nhỏ gọn, không che nội dung quan trọng ở bất kỳ section nào.

## Đa ngôn ngữ (i18n) — bắt buộc theo rule

- Nút Language switcher **chính là** UI điều khiển i18n — không cần thêm
  text key nào cho bản thân nó ngoài `aria-label` (2 key mới:
  `common.switchLanguage`, `common.toggleTheme` — namespace `common.*` vì
  đây UI chrome dùng chung, không thuộc riêng section nào).
- Thêm đồng thời vào `vi.json` và `en.json` (key-parallel).

## Light/Dark mode — bắt buộc theo rule

- Đây chính là feature triển khai theme toggle — bản thân nút phải hoạt
  động đúng ở cả 2 theme (xem UI/UX ở trên).
- Dùng `useTheme()` có sẵn từ `theme-provider.tsx`, không tạo theme system
  mới.

## Error Handling / Edge Cases

- `localStorage` bị chặn (private browsing một số trình duyệt cũ): theme
  provider đã có try/catch sẵn theo thiết kế gốc (verify khi code) — nếu
  chưa có, thêm fallback không throw.
- Click liên tục nhanh (double-click) — không cần debounce, đổi state đơn
  giản không có side-effect nặng.

## UI States

- Language nút: hiện text ngôn ngữ **hiện tại** (không phải ngôn ngữ sẽ đổi
  sang) — theo pattern phổ biến (giảm nhầm lẫn "đổi thành gì" vs "đang là
  gì"). Quyết định cụ thể: hiện code ngôn ngữ hiện tại, click đổi sang cái
  còn lại.
- Theme nút: icon Sun khi đang dark (bấm để "sáng lên"), icon Moon khi đang
  light (bấm để "tối xuống") — theo convention phổ biến toggle icon.

## Test Cases (sơ bộ)

Xem `test.md`.

## Definition of Done

- [x] 2 nút hiển thị đúng vị trí, đọc được ở mọi section (dark Hero + light
      sections).
- [x] Language switcher đổi text toàn trang ngay lập tức, persist qua reload.
- [x] Theme toggle đổi `dark`/`light` class trên `<html>`, persist qua
      reload (đã có sẵn qua `theme-provider.tsx`).
- [x] i18n key mới thêm vào cả vi.json/en.json.
- [x] Type-check + lint sạch.
- [x] Test browser thực tế desktop + mobile.

## Out of Scope

- Không thêm "system" option vào UI toggle (chỉ light/dark cycle đơn giản
  theo AC) — `theme-provider.tsx` vẫn hỗ trợ "system" ở tầng dưới, chỉ
  không expose qua UI toggle này.
- Không áp dụng 2 nút này cho các trang khác ngoài landing page
  (`/workspace`, `/portal`, `/admin` đã có Layout/Navbar riêng, không thuộc
  scope).

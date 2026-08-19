# Test — Landing Page: Features Bento + Hero Click-to-Demo + Workspace Shared-Space

> Viết hồi tố. Test case đã verify thực tế trong session code (browser
> automation), không phải viết trước rồi chạy sau (đúng ra phải làm ngược
> lại theo rule — ghi nhận).

## TC1 — Bento grid không có ô trống

**Input:** Load landing page, scroll tới `#features`.
**Expected:** 6 card lấp đủ 3 hàng (Planning 2×2 + 4 card nhỏ 2 hàng đầu +
Automation full-width hàng 3), không có ô trống lẻ.
**Kết quả:** PASS — đo `getBoundingClientRect()` xác nhận card cuối
`x:170, w:1088` = full row width.

## TC2 — Click Feature card → scroll đúng vị trí + đúng tab

**Input:** Click card "Sáng tạo với AI" (Creation).
**Expected:** `window.scrollY === 3500` (cuối vùng pin GSAP), tab MacBook =
"AI Studio", sidebar highlight đúng mục.
**Kết quả:** PASS — verify qua screenshot + `scrollY` đo được đúng 3500.

**Input:** Click card "Cộng tác nhóm" (Collab) ngay sau đó.
**Expected:** Tab đổi ngay sang "Workspace" dù `scrollY` không đổi (đã ở
3500 từ trước) — do `requestId` tăng dù `activePage` khác giá trị cũ.
**Kết quả:** PASS.

## TC3 — Workspace 4 tab hoạt động

**Input:** Vào 1 workspace (VCorp Media) → click lần lượt Board, Timeline,
Docs, Members, Activity.
**Expected:** Mỗi tab render đúng nội dung tương ứng, không lỗi console.
**Kết quả:** PASS — verify từng tab qua screenshot + accessibility snapshot.

## TC4 — Avatar AI-generated load thành công

**Input:** Đo toàn bộ `<img src*="pravatar">` trên trang Workspace detail.
**Expected:** Tất cả `img.complete === true && naturalWidth > 0`.
**Kết quả:** PASS — 11/11 ảnh load thành công.

## TC5 — Mobile Hero không tràn viewport

**Input:** Resize browser 320×568 (iPhone SE), 375×667, 390×844. Load lại
trang fresh (không cache scroll state).
**Expected:** Post Instagram mở đầu hiện đầy đủ header (avatar+username),
không bị cắt phía trên viewport.
**Kết quả:** FAIL lần đầu (`postRect.top: -34px`, header bị cắt) → xác định
root cause (`h-screen` + CTA overlay chiếm flex layout) → sửa → PASS lần 2
(`postRect.top: 88px`, dương, không tràn).

## TC6 — CTA overlay không ăn layout khi ẩn

**Input:** Đo `.relative.inset-0.h-full` (stage) height trước/sau fix, tại
375×667.
**Expected:** Stage height ≈ full section height (668px), không bị co lại
vì CTA area bên dưới.
**Kết quả:** PASS sau fix — `stageRect.height: 668` (trước fix: 434px).

## TC7 — Scroll hết animation, MacBook demo + CTA hiện đúng vị trí mobile

**Input:** `window.scrollTo(0, 3500)` tại 320×568.
**Expected:** MacBook demo hiện đầy đủ, 2 CTA button ("Bắt đầu miễn phí",
"Đăng nhập") hiện overlay đúng vị trí, không đè lên nội dung quan trọng.
**Kết quả:** PASS.

## TC8 — i18n key-parallel

**Input:** Diff `vi.json` và `en.json` phần `landing.features`.
**Expected:** Cả 2 file có cùng bộ key (`demoLabel`, `demoAction`), khác
value.
**Kết quả:** PASS.

## TC9 — Type-check & lint

**Input:** `npx tsc --noEmit`, `npm run lint` sau mỗi lần sửa.
**Expected:** Không lỗi mới phát sinh từ file đã sửa (pre-existing lỗi ở
`ContentPage`/`button.tsx`/`spinner.tsx`/`table.tsx` không tính, không liên
quan thay đổi).
**Kết quả:** PASS toàn bộ các lần chạy trong session.

## Chưa test (out of scope / ghi nhận thiếu)

- Không có test tự động (unit/e2e) — chỉ verify thủ công qua browser
  automation trong session. Vi phạm DoD chuẩn ("Đã viết Unit Test /
  Integration Test nếu có logic nghiệp vụ" — click-to-demo store logic có
  thể unit-test được nhưng chưa làm).
- Chưa test dark mode thực tế bằng cách toggle theme (theme toggle UI chưa
  tồn tại tại thời điểm viết — xem feature riêng theme-toggle).
- Chưa test cross-browser (chỉ test Chromium qua chrome-devtools MCP).

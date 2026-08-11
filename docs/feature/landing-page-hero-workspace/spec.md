# Spec — Landing Page: Features Bento + Hero Click-to-Demo + Workspace Shared-Space

> Viết hồi tố sau khi code đã hoàn thành (session trước không đi qua quy trình
> spec→plan→task→test theo `feature-workflow.md`). File này phản ánh đúng những
> gì đã build, dùng làm nguồn tài liệu tham chiếu từ nay về sau.

## Objective

Nâng cấp landing page (unauthenticated `/`) — 3 việc:

1. Features section (6 card) từ layout "3 cột đều nhau" generic sang bố cục
   bento có phân cấp thị giác.
2. Mỗi Feature card, khi click, đưa người dùng lên MacBook demo trong
   CinematicHero và tự chuyển đúng tab tương ứng — cho thấy tính năng thật
   hoạt động ra sao thay vì chỉ đọc mô tả.
3. Trang demo "Workspace" trong MacBook đổi từ list card multi-client đơn
   giản sang giao diện shared-space kiểu Notion/Jira (Board Kanban, Timeline
   Gantt, Docs, Members, Activity feed) — đúng tinh thần "1 không gian chung
   nhiều người cùng làm việc" mà BrandHub bán.

## User Story

- Là khách ghé landing page, tôi muốn xem trước tính năng "Cộng tác nhóm"
  hoạt động thực tế thế nào, để tôi tin tưởng đăng ký dùng thử.
- Là khách ghé landing page trên mobile, tôi muốn Hero hiển thị đầy đủ không
  bị cắt/tràn, để tôi không nghĩ sản phẩm lỗi ngay từ trang đầu.

## Acceptance Criteria

**Features section:**
- 6 card: Planning (anchor 2×2), Creation, Publishing, Analytics, Collab,
  Automation (full-width hàng cuối) — không ô trống lẻ trong bento grid.
- Mỗi card `role="button"`, click/Enter/Space → nhảy đúng tab MacBook demo.
- Hover hiện hint "Xem demo thực tế" (icon `MousePointerClick`).

**Click-to-demo wiring:**
- Click card → scroll tới **cuối** vùng pin GSAP của Hero (nơi MacBook đã
  hiện đầy đủ, không phải đầu animation) + đổi đúng tab MacBook.
- Map: Planning→Schedule, Creation→AI Studio, Publishing→Publish,
  Analytics→Analytics, Collab→Workspace, Automation→Content.

**Workspace shared-space (trong MacBook demo, tab "Workspace"):**
- Chọn 1 workspace từ list → vào detail dạng shared-space:
  header có avatar-stack member (ảnh AI, không phải chữ cái viết tắt) + dot
  "N online".
- 5 tab: Board (Kanban 4 cột, card có avatar assignee), Timeline (Gantt-style
  thanh ngang theo tuần, progress bar), Docs, Members (Online/Offline rõ
  ràng), Activity (feed "X đã làm Y — Z phút trước").

**Mobile Hero (viewport ≤ 640px):**
- Post Instagram mở đầu animation không bị tràn/cắt khỏi viewport — header
  (avatar+username) luôn hiển thị đầy đủ.
- CTA overlay (nút toggle device + 2 CTA button + scroll-hint) không chiếm
  layout height của stage khi đang ẩn (`opacity-0`).

## UI/UX

- Bento grid: `grid-cols-4` desktop → `grid-cols-1` mobile (`sm:grid-cols-2`).
- Timeline: thanh ngang màu theo channel (`CALENDAR_CHANNEL_CONFIG`), width
  theo tỉ lệ tuần, fill theo % progress.
- Avatar: `https://i.pravatar.cc/{size}?u={encodeURIComponent(name)}` — seed
  theo tên để ổn định qua các lần render.

## Đa ngôn ngữ (i18n) — bắt buộc theo rule

- Key mới: `landing.features.demoLabel`, `landing.features.demoAction`
  (namespace `landing.features.*`, interpolation `{{feature}}`).
- Thêm đồng thời `src/i18n/locales/vi.json` và `src/i18n/locales/en.json`
  (key-parallel) — verify: cả 2 file có cùng bộ key.
- Text mock trong MacBook demo (Board/Timeline/Docs/Members/Activity) là nội
  dung tiếng Việt cứng (demo data, không phải UI chrome thật) — nhất quán với
  quy ước sẵn có của `CinematicHero.tsx` (feedContent.ts và các trang demo
  khác trong file này đều hardcode tiếng Việt vì đây là mock nội dung minh
  hoạ, không phải UI có key i18n).

## Light/Dark mode — bắt buộc theo rule

- Features section: dùng `dark:` variant có sẵn (`dark:bg-zinc-950`,
  `dark:text-zinc-100`, `dark:border-zinc-800`...) — không hardcode màu không
  có cặp dark.
- Workspace shared-space UI (Board/Timeline/Docs/Members/Activity) render
  **bên trong MacBook demo** (macOS Safari window mô phỏng) — luôn nền trắng
  cố định theo thiết kế MacBook (không phải UI thật của app, không theo theme
  page). Đây là ngoại lệ có chủ đích: MacBook demo mô phỏng 1 ảnh chụp màn
  hình cố định, không đổi theo dark/light của landing page.
- Hero section (`bg-zinc-950`) vốn luôn nền tối theo thiết kế cinematic gốc —
  không đổi theo light/dark toggle (ngoại lệ tương tự CTASection tối màu cố
  định đã có trong codebase).

## Error Handling / Edge Cases

- Avatar pravatar.cc lỗi tải (mất mạng): trình duyệt hiện broken-image icon
  mặc định — chấp nhận được vì đây trang demo tĩnh, không phải luồng nghiệp
  vụ chính.
- Click Feature card trước khi GSAP ScrollTrigger init xong (`hero-pin` chưa
  tồn tại): fallback `sectionRef.current?.scrollIntoView()`.
- Reduced-motion: `useReducedMotion()` tắt animation card Feature.

## UI States

- Feature card: default / hover (border cam + shadow + hint hiện) /
  focus-visible (ring cam) / click (điều hướng ngay, không có loading state
  vì là scroll đồng bộ).
- Workspace Board/Timeline/Members: static demo data, không có loading/empty
  state thật (đây mock data cố định).

## Test Cases (sơ bộ)

Xem `test.md`.

## Definition of Done

- [x] Type-check (`npx tsc --noEmit`) sạch.
- [x] Lint sạch cho các file thay đổi (không tính lỗi pre-existing khác).
- [x] Test bằng browser thực tế (desktop + mobile 320/375/390px).
- [x] i18n key-parallel vi.json/en.json.
- [ ] ~~spec→plan→task→test viết TRƯỚC khi code~~ — **không đạt**, viết hồi
      tố sau khi code xong. Ghi nhận vi phạm quy trình, không lặp lại.

## Out of Scope

- Không làm real-time collaboration thật (Activity feed là mock tĩnh, không
  WebSocket).
- Không có backend API cho Workspace/Board/Timeline — toàn bộ là demo data
  trong `CinematicHero.tsx`.
- Theme toggle (light/dark switch) cho landing page — xem feature riêng
  `docs/feature/landing-page-theme-toggle/`.

# Task — Landing Page: Features Bento + Hero Click-to-Demo + Workspace Shared-Space

> Viết hồi tố. Checklist phản ánh công việc đã hoàn thành.

## Features section

- [x] Đổi grid 3-col đều nhau → bento (Planning anchor 2×2, Automation full-width)
- [x] Thêm `pageIndex` per-card, map đúng tab MacBook demo
- [x] `role="button"` + `onClick`/`onKeyDown` (Enter/Space) — a11y keyboard nav
- [x] Hover hint "Xem demo thực tế" (`MousePointerClick` icon)
- [x] `useReducedMotion()` tắt animation khi user bật giảm chuyển động

## Click-to-demo store

- [x] Tạo `src/store/landingDemoStore.ts` (zustand, `activePage`/`requestId`/`goToPage`/`setPage`)
- [x] `CinematicHero.BrandHubDashboardBg` đọc `page` từ store (bỏ local `useState`)
- [x] Gán `id: "hero-pin"` cho GSAP ScrollTrigger
- [x] Effect `[requestId]` → `ScrollTrigger.getById("hero-pin").end` → `window.scrollTo`
- [x] Fallback `scrollIntoView()` nếu `ScrollTrigger.getById` trả `undefined`
- [x] Đổi mọi `setPage` nội bộ (sidebar nav, dock, auto-demo cycle) dùng store's `setPage` (không tăng `requestId`)

## Workspace shared-space (5 tab)

- [x] Header: avatar-stack member + dot "N online"
- [x] Tab Board: Kanban 4 cột (To Do/Đang làm/Review/Xong), card có avatar assignee
- [x] Tab Timeline: Gantt-style thanh ngang theo tuần (`TIMELINE_WEEKS=8`), progress bar theo %
- [x] Tab Docs: danh sách content, tái dùng `WORKSPACE_CONTENT`
- [x] Tab Members: Online/Offline rõ ràng, avatar + role
- [x] Tab Activity: feed "X đã làm Y — Z phút trước"
- [x] Thêm mock data: `WORKSPACE_BOARD`, `WORKSPACE_TIMELINE`, `WORKSPACE_ACTIVITY`

## Avatar AI-generated

- [x] Helper `avatarUrl(name, size)` → `https://i.pravatar.cc/{size}?u={encodeURIComponent(name)}`
- [x] Thay initials-circle ở: header avatar-stack, Board card assignee, Timeline hàng, Members tab, Activity feed

## Mobile Hero fix

- [x] `h-screen` → `min-h-[100dvh]` (address-bar overflow trên mobile)
- [x] CTA overlay: flex-participating → `absolute inset-x-0 bottom-0` (không ăn layout height khi ẩn)
- [x] Giảm `max-w-*` 4 post card dưới breakpoint `sm:` (Instagram 340→220px, TikTok 280→180px, FB/LinkedIn 430→220px)
- [x] Verify browser thực tế: 320×568, 375×667, 390×844

## i18n (bắt buộc theo rule)

- [x] Thêm `landing.features.demoLabel`, `landing.features.demoAction` vào `vi.json`
- [x] Thêm cùng key vào `en.json` (key-parallel)

## Kiểm tra light/dark mode (bắt buộc theo rule)

- [x] Features section: verify `dark:` variant hoạt động (đã có sẵn từ trước, không đổi)
- [x] Xác nhận MacBook demo UI (Workspace/Board/Timeline...) là nền cố định trắng theo thiết kế
      MacBook mock, không theo theme page — ghi rõ trong spec.md là ngoại lệ có chủ đích

## Verify cuối

- [x] `npx tsc --noEmit` sạch
- [x] `npm run lint` — không phát sinh lỗi mới (chỉ pre-existing không liên quan)
- [x] Browser test: desktop 1440px, mobile 320/375/390px, click flow Feature→Hero, 4 tab Workspace

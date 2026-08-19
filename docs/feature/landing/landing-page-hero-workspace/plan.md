# Plan — Landing Page: Features Bento + Hero Click-to-Demo + Workspace Shared-Space

> Viết hồi tố. Phản ánh giải pháp kỹ thuật thực tế đã triển khai.

## Thành phần / File chạm tới

| File | Thay đổi |
|---|---|
| `src/components/landing/Features.tsx` | Bento grid layout, `role="button"` + `onClick`/`onKeyDown` gọi `goToPage`, hover hint |
| `src/store/landingDemoStore.ts` (mới) | Zustand store: `activePage`, `requestId`, `goToPage` (đổi tab + trigger scroll), `setPage` (đổi tab không scroll, dùng cho nav nội bộ MacBook) |
| `src/components/landing/cinematic/CinematicHero.tsx` | `BrandHubDashboardBg` đọc `page` từ store thay local state; effect scroll tới `ScrollTrigger.getById("hero-pin").end`; `WorkspaceDetail` viết lại 5 tab; `h-screen`→`min-h-[100dvh]`; CTA overlay đổi flex→absolute |
| `src/components/landing/cinematic/posts/{Instagram,TikTok,Facebook,LinkedIn}Post.tsx` | Responsive `max-w-*` nhỏ hơn dưới `sm:` breakpoint |
| `src/i18n/locales/{vi,en}.json` | Thêm `landing.features.demoLabel`, `landing.features.demoAction` |

## Không thay đổi

- Route/API backend — toàn bộ là frontend demo data.
- `DashboardPage.tsx` — không cần sửa, `<Features />`/`<CinematicHero />` giữ nguyên cách gọi (không props mới).

## Luồng dữ liệu

```
Feature card click
  → useLandingDemoStore.goToPage(pageIndex)
      → set({ activePage: pageIndex, requestId: requestId+1 })
  → CinematicHero.BrandHubDashboardBg subscribes activePage (re-render page)
  → effect [requestId] → ScrollTrigger.getById("hero-pin").end → window.scrollTo(...)
```

Trong MacBook demo (nav sidebar/dock click) dùng `setPage` (không tăng
`requestId`) để tránh trigger scroll không mong muốn khi user đang tương tác
trực tiếp trong demo.

## GSAP / Pin quirk quan trọng

`scrollTrigger: { id: "hero-pin", start: "top top", end: "+=3500", pin: true }`
— gán `id` để `ScrollTrigger.getById` lấy được `.end` (pixel tuyệt đối) từ
component khác, thay vì `scrollIntoView()` chỉ tới điểm bắt đầu pin (đầu
animation, sai UX).

## Thứ tự build (thực tế đã làm)

1. Features.tsx bento redesign (không phụ thuộc phần khác).
2. `landingDemoStore.ts` + wiring `goToPage` trong Features.
3. `CinematicHero.tsx`: đọc store, effect scroll — cần trước để card click hoạt động.
4. Workspace `WorkspaceDetail` 5-tab rewrite (độc lập, có thể làm song song
   với bước 2-3 nhưng làm sau trong thực tế vì phát sinh từ yêu cầu tiếp theo
   của user).
5. Avatar pravatar.cc thay initials-circle (áp dụng lên UI đã có ở bước 4).
6. Mobile Hero fix (`h-screen`, CTA overlay, post card scale) — phát hiện qua
   review chủ động, không phải yêu cầu ban đầu.

## Rủi ro

- **pravatar.cc là dịch vụ ngoài** — nếu service down, avatar vỡ (broken
  image icon). Chấp nhận vì đây demo landing page, không phải luồng nghiệp
  vụ chính; không cần fallback phức tạp.
- **`ScrollTrigger.getById` có thể trả `undefined`** nếu gọi trước khi GSAP
  init xong (race condition hiếm khi trang vừa load). Đã có fallback
  `scrollIntoView()`.
- **Zustand store mới không có `persist`** — state mất khi reload, chấp nhận
  được vì đây UI demo tạm thời, không phải state cần lưu.

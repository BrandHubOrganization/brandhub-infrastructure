# Verification
Member 0 Agency sở hữu tự mở tab tham gia; refresh không ghi đè tab chọn tay.
Agency không Workspace không hiển thị Agency khác. Credit lỗi/visible=false không số dư giả.
Task skeleton/error retry, phân trang 20, mở đúng ?task=ID; không hiển thị tổng từ dữ liệu phân trang.
Logo hỏng/seed fallback, keyboard và responsive; VI/EN, light/dark.
Chạy npm run ci; không thêm test trong src hay thay đổi DB.

## Results — 2026-11-12
- PASS: real local dev Owner (Demo Agency) and Member (DDB Vietnam Agency) data loaded.
- PASS: personal Member defaults to joined agencies; explicit tab survives refresh.
- PASS: actual task deep link /tasks?task=ID.
- PASS: browser-only simulated Task 503 leaves Workspace list usable; Retry recovers.
- PASS: 390px viewport has no horizontal page overflow; VI/EN and light/dark inspected.
- PASS: 73 dashboard experience locale keys match across VI/EN.
- PASS: scoped dashboard ESLint and TypeScript checks.
- Full npm run ci: blocked by existing ChatMediaLightbox.tsx:142 preserve-manual-memoization error; no Chat edits made.
- No DB migration, data seed, new dependency or production action. QA files/screenshots stay in ignored keep-local-only.
- Limitation: member assignments are filtered within the selected Workspace task page (20 recent records); no claim of Agency-wide totals. Workspace list API is list-mine, locally scoped to Agency and UI-paginated at 8.
- PASS: final production build and public-route prerender completed.

## Pre-commit verification
- Full Web CI PASS: eslint (0 errors, 145 existing warnings), type-check, production build, SEO prerender.
- Fixed ChatMediaLightbox CI error by moving the unchanged fullscreen callback above its first use; no runtime logic changed.
- Seven unused dashboard drafts retained in ignored keep-local-only, not committed.
- Page-scoped commits contain no executable tests or local QA artifacts.

## Workspace overview extension checks
Owner/Manager see operational priorities; Creator rows must match current user assigneeId; Client opens content review before deciding. Workspace/user/role switches must not show cached data from other contexts. Overview shows 5 priority tasks; View all opens the complete task screen. Metrics explicitly cover the 20 loaded records. Network failures show retry, never zero-as-success. Check campaign empty/error, malformed historical timeline, no dates, no milestone; no invented fallback metrics. Verify direct task URLs, calendar/chat links, VI/EN, keyboard, light/dark and narrow layout. Full npm run ci required.

### Workspace overview verification — 2026-11-13
- PASS: changed component ESLint, TypeScript and 52 VI/EN overview keys in parity.
- PASS: final full repository lint after develop merge: 0 errors, 188 warnings.
- Scope: counts are page-local, Creator is filtered by authenticated assignee; campaign feedback comes from the workspace/campaign feedback endpoint. No dummy publishing numbers or fabricated revisions.
- PASS: authenticated local dev Manager overview inspected, including BrandHub orange accents and empty task/campaign states. Full four-role light/dark/mobile QA remains pending.
- PASS: full npm run ci including production build and prerender of 105 SEO pages. No DB writes, test files or dependencies added.

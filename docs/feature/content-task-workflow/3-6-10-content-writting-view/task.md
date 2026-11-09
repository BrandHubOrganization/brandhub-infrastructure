# Task — Content Writing View (FR 3.6.10)

> Status: **V4–V5 + Core Dual Publishing Implemented & Verified (52 Vitest + 67 Playwright E2E passing); V6 YayText 36-Style Expansion Specified & Awaiting User Approval** (see items 19–22 below; see [spec.md](spec.md), [plan.md](plan.md), [test.md](test.md)).

- [x] **0. Prerequisite**: minimal `Task` entity + basic CRUD — **implemented**. See `Task.java`, `TaskService(Impl).java`, `TaskController.java`.
- [x] **1. Data model**: `TaskContentOperation` (append-only, opaque base64 Yjs update log), `TaskContentSnapshot` (client-reported Yjs state), migrations applied to local DB.
- [x] **2. OT architecture decision**: direction B chosen and implemented — Yjs CRDT, not hand-written OT. See [plan.md §5](plan.md#5-technical-architecture--design-decisions).
- [x] **3. WebSocket infra (BE)**: `spring-boot-starter-websocket` added, `WebSocketConfig` (STOMP endpoint `/ws/tasks`, broker `/topic`), `WsJwtHandshakeInterceptor` (JWT via query param, reuses `JwtUtil`), `SecurityConfig`/`JwtAuthenticationFilter` updated to permit the WS path at the HTTP layer.
- [x] **4. Canvas rendering engine (FE)** — implemented and browser-verified at `/content-writing`: text layout/measurement, line-breaking, render loop. See `brandhub-web/src/pages/content-writing/`.
- [x] **5. Offscreen input capture (FE)** — implemented and browser-verified: hidden off-screen input, Vietnamese IME handling, CSS cursor overlay, canvas click-to-position, Backspace/Delete, full text selection highlighting.
- [x] **6. Real-time sync (FE+BE)**: `useTaskContentSync` hook — STOMP client (`@stomp/stompjs`), Yjs `Y.Doc` wired to `CanvasTextEditor`, `TaskContentWebSocketController` persists + broadcasts updates.
- [x] **7. Accessibility**: the `aria-live` text mirror plus the hidden input (`role=textbox` `aria-multiline`) and `aria-hidden` on `<canvas>` (E2E-20).
- [x] **8. Sub-pixel cursor & selection physics across multi-font wrapped lines (2026-11-09)**:
  - Fixed cursor/word alignment on `<canvas>` via `measureRunSliceWidth(ctx, text, letterSpacing)` and `buildParagraphIndexMap`, accounting for list prefix widths (`• `, `1. `), center/right alignment offsets, and multi-font/size runs.
  - Added full Google Docs / Word keyboard & mouse navigation (`Ctrl+Left/Right`, `Ctrl+Shift+Left/Right`, `Home/End`, `Ctrl+Home/End`, `Ctrl+Backspace/Delete`, `Double-click` word selection, `Triple-click` paragraph selection) — verified in E2E-23, E2E-25, E2E-31.
- [x] **9. Version History**: REST load/list/restore snapshot implemented (`TaskContentServiceImpl`), `VersionHistorySidebar` UI with word-level diff (`contentUtils.diffText`) and read-only restore applied as a normal Yjs update.
- [x] **10. Offline queue & No-Backend resilience (`Có Backend` vs. `Không Backend`)**:
  - Edits made while disconnected are queued in memory and persisted in `localStorage` (`brandhub-content-pending:{taskId}`), flushed on reconnect.
  - When backend API is completely unavailable (`Không Backend`), `/workspaces/:id/content-writing` automatically initializes a local offline session (`local-task-*`) so all editing, formatting, import/export, and social copy/paste work uninterrupted (verified in E2E-19, E2E-28).
- [x] **11. Dual Social Publishing Workflows — (1) Direct API Auto-Publish & (2) Manual Zantext Copy-Paste (2026-11-09)**:
  - **Direct API Auto-Publish**: Wired `toPublishText(ops)` to the `Đăng bài lên mạng xã hội` modal in `ContentWritingPage` and `Đăng ngay` in `ContentCreatorStudio`, publishing formatted Unicode text to `Facebook`, `Instagram`, `TikTok`, and `Threads` (`POST /api/v1/workspaces/{id}/posts` + `POST .../publish`).
  - **Manual Zantext Copy-Paste**: Intercepted native `Ctrl+C` / `Ctrl+X` inside both `CanvasTextEditor` and `RichTextEditor` (TipTap) so copying selected text or the full post places the Unicode-converted text on the clipboard. Added 1-click `Sao chép bản đăng`, `Copy dán Facebook (Giữ Font)`, `Copy dán Facebook`, and the **Facebook Plain-Text Composer Sandbox (`Thử dán FB`)** on both screens — verified in E2E-17, E2E-24, E2E-32, and `content-creator-studio.spec.ts`.
- [x] **12. Automated tests (updated 2026-11-09)**: **52/52 Vitest unit tests** + **22/22 JUnit backend tests** + **67/67 Playwright E2E tests** (`32` in `content-writing.spec.ts` + `35` in `content-creator-studio.spec.ts`) + **31/31 live-backend integration tests**, all passing — see [test.md](test.md).
- [x] **13. Docs/Word hybrid UI redesign & Google Docs Chrome**: Google Docs menu bar (`Tệp`, `Chỉnh sửa`, `Xem`, `Chèn`, `Định dạng`, `Công cụ`), horizontal page ruler (`816px`), zoom controls (`75%`–`150%`), Docs/Word Ribbon toggle, and live status footer.
- [x] **14. Presence / multi-cursor awareness**: `/app+/topic/tasks/{taskId}/awareness` STOMP relay + live colored peer cursor flags and avatar badges (E2E-21, E2E-22).
- [x] **15–18. React Native mobile port & Maestro flows**: `brandhub-mobile-app/src/screens/content-writing/` with 22 unit + 24 component tests + 7 Maestro YAML flows.
- [x] **19. Document Import (`.docx`, `.txt`, `.md`, `.html`, Live Google Docs Link) & Export (`.docx`, `.md`, `.txt`) (2026-11-09)**:
  - Implemented `ImportDocumentModal.tsx` supporting live Google Docs URLs and file uploads in both **Replace** and **Append** modes across both `ContentWritingPage` and `ContentCreatorStudio`, plus `.docx`/`.md`/`.txt` export — verified in E2E-26, E2E-27, E2E-31, and Studio E2E-35.
- [x] **20. Brand Knowledge (`Có BK` vs. `Không BK`) Integration (2026-11-09)**:
  - Integrated AI Caption generation in `ContentWritingPage` with live Brand Knowledge status badge (`Có BK` vs. `Không BK`) and verified full Brand Knowledge Document upload/search/delete lifecycle — verified in E2E-29, E2E-30.

---

### Pending V6 Expansion Tasks (Awaiting User Approval of `spec.md` §4.3 & `plan.md` §6)

- [ ] **21. V6 YayText 36-Style Unicode Engine (`contentUtils.ts`)**:
  - [ ] **21.1** Add Enclosed Unicode maps: `BLACK_BUBBLE` (`🅑🅤🅑🅑🅛🅔`), `BLACK_SQUARE` (`🅱🅻🅰🅲🅺`), `PARENTHESIZED` (`⒫⒜⒭⒠⒩`), and `REGIONAL_INDICATOR` (`🇧 🇷 🇦 🇳 🇩`).
  - [ ] **21.2** Add Modifier & Flip maps: `SUPERSCRIPT` (`ˢᵘᵖᵉʳ ⁰¹²`), `SUBSCRIPT` (`ₛᵤ₆ ₀₁₂`), and `UPSIDE_DOWN` (`qnpuɐɹB` with line-by-line grapheme reversal).
  - [ ] **21.3** Add Combining Line Overlays: `double-underline` (`\u0333`, `A̳B̳C̳`), `slashthrough` (`\u0338`, `9̸9̸0̸k̸` for sale price crossing), `tilde-strike` (`\u0334`, `A̴B̴C̴`), `overline` (`\u0305`, `A̅B̅C̅`), `under-asterisks` (`\u0359`, `A͙B͙C͙`), and `lightning-above` (`\u035B`, `A͛B͛C͛`).
  - [ ] **21.4** Add Character & Line Decorators: `air-quotes` (`『A』『B』『C』`), `lenticular-brackets` (`【A】【B】【C】`), `sparkles-decorator`, `stars-wave-decorator`, and `arrow-pointer-decorator`.
  - [ ] **21.5** Implement `stripVietnameseAccents(text)` and **Smart Vietnamese Diacritic Mode** (`keep-marks` vs. `strip-accents-auto`) so Vietnamese text inside Enclosed (`🅑🅤🅑🅑🅛🅔`, `🅱🅻🅰🅲🅺`, `🄰🄱🄲`), Superscript, and Upside-Down styles never breaks or misaligns on iOS/Android.
  - [ ] **21.6** Update `stripUnicodeStyling(text)` to cleanly strip all 36 styles, combining marks, and brackets for lossless style switching.
- [ ] **22. V6 YayText Smart UI/UX in `FormattingToolbar.tsx` & `RichTextEditor.tsx`**:
  - [ ] **22.1** Add **6 Category Filter Tabs** (`Tất cả (36)`, `⭐ Yêu thích`, `Tiêu đề`, `Sale & Gạch giá`, `Khung Nổi bật`, `Sang trọng`, `Hiện đại`, `Độc lạ`) + quick search inside the `Font Zantext` popover.
  - [ ] **22.2** Add **Favorite / Pin (`⭐`)** toggle per style persisted in `localStorage` (`brandhub-zantext-favorites`).
  - [ ] **22.3** Add **Vietnamese Diacritic Toggle (`Giữ dấu` / `Lược dấu chuẩn khung`)** and **OS Font Preview Switcher (`Web` / `iOS` / `Android`)**.
  - [ ] **22.4** Expand unit tests in `contentUtils.test.ts` and Playwright E2E tests in `content-writing.spec.ts` & `content-creator-studio.spec.ts` to verify all 36 YayText styles and UX controls.

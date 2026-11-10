# Task — Content Writing View (FR 3.6.10)

> Status: **V4–V6 Complete — All 22 Tasks Implemented & Verified (60/60 Vitest + 22/22 JUnit + 68/68 Playwright E2E + 31/31 Live Integration passing)** (see [spec.md](spec.md), [plan.md](plan.md), [test.md](test.md)).

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
- [x] **12. Automated tests (updated 2026-11-09)**: **60/60 Vitest unit tests** + **22/22 JUnit backend tests** + **68/68 Playwright E2E tests** (`33` in `content-writing.spec.ts` + `35` in `content-creator-studio.spec.ts`) + **31/31 live-backend integration tests**, all passing — see [test.md](test.md).
- [x] **13. Docs/Word hybrid UI redesign & Google Docs Chrome**: Google Docs menu bar (`Tệp`, `Chỉnh sửa`, `Xem`, `Chèn`, `Định dạng`, `Công cụ`), horizontal page ruler (`816px`), zoom controls (`75%`–`150%`), Docs/Word Ribbon toggle, and live status footer.
- [x] **14. Presence / multi-cursor awareness**: `/app+/topic/tasks/{taskId}/awareness` STOMP relay + live colored peer cursor flags and avatar badges (E2E-21, E2E-22).
- [x] **15–18. React Native mobile port & Maestro flows**: `brandhub-mobile-app/src/screens/content-writing/` with 22 unit + 24 component tests + 7 Maestro YAML flows.
- [x] **19. Document Import (`.docx`, `.txt`, `.md`, `.html`, Live Google Docs Link) & Export (`.docx`, `.md`, `.txt`) (2026-11-09)**:
  - Implemented `ImportDocumentModal.tsx` supporting live Google Docs URLs and file uploads in both **Replace** and **Append** modes across both `ContentWritingPage` and `ContentCreatorStudio`, plus `.docx`/`.md`/`.txt` export — verified in E2E-26, E2E-27, E2E-31, and Studio E2E-35.
- [x] **20. Brand Knowledge (`Có BK` vs. `Không BK`) Integration (2026-11-09)**:
  - Integrated AI Caption generation in `ContentWritingPage` with live Brand Knowledge status badge (`Có BK` vs. `Không BK`) and verified full Brand Knowledge Document upload/search/delete lifecycle — verified in E2E-29, E2E-30.

---

### V6 Expansion Tasks (Implemented & Verified — 2026-11-09)

- [x] **21. V6 YayText 36-Style Unicode Engine (`contentUtils.ts`)**:
  - [x] **21.1** Add Enclosed Unicode maps: `BLACK_BUBBLE` (`🅑🅤🅑🅑🅛🅔`), `BLACK_SQUARE` (`🅱🅻🅰🅲🅺`), `PARENTHESIZED` (`⒫⒜⒭⒠⒩`), and `REGIONAL_INDICATOR` (`🇧 🇷 🇦 🇳 🇩`).
  - [x] **21.2** Add Modifier & Flip maps: `SUPERSCRIPT` (`ˢᵘᵖᵉʳ ⁰¹²`), `SUBSCRIPT` (`ₛᵤ₆ ₀₁₂`), and `UPSIDE_DOWN` (`qnHpuɐɹᙠ` with line-by-line grapheme reversal).
  - [x] **21.3** Add Combining Line Overlays: `double-underline` (`\u0333`, `A̳B̳C̳`), `slashthrough` (`\u0338`, `9̸9̸0̸k̸` for sale price crossing), `tilde-strike` (`\u0334`, `A̴B̴C̴`), `overline` (`\u0305`, `A̅B̅C̅`), `under-asterisks` (`\u0359`, `A͙B͙C͙`), and `lightning-above` (`\u035B`, `A͛B͛C͛`).
  - [x] **21.4** Add Character & Line Decorators: `air-quotes` (`『A』『B』『C』`), `lenticular-brackets` (`【A】【B】【C】`), `sparkles-decorator`, `stars-wave-decorator`, and `arrow-pointer-decorator`.
  - [x] **21.5** Implement `stripVietnameseAccents(text)` and **Smart Vietnamese Diacritic Mode** (`keep-marks` vs. `strip-accents-auto`) so Vietnamese text inside Enclosed (`🅑🅤🅑🅑🅛🅔`, `🅱🅻🅰🅲🅺`, `🄰🄱🄲`), Superscript, and Upside-Down styles never breaks or misaligns on iOS/Android.
  - [x] **21.6** Update `stripUnicodeStyling(text)` to cleanly strip all 36 styles, combining marks, and brackets for lossless style switching.
- [x] **22. V6 YayText Smart UI/UX in `FormattingToolbar.tsx` & `RichTextEditor.tsx`**:
  - [x] **22.1** Add **8 Category Filter Tabs** (`Tất cả (36)`, `⭐ Yêu thích`, `Tiêu đề`, `Sale & Gạch giá`, `Khung Nổi bật`, `Sang trọng`, `Hiện đại`, `Độc lạ`) inside the `Font Zantext` popover.
  - [x] **22.2** Add **Favorite / Pin (`⭐`)** toggle per style persisted in `localStorage` (`brandhub-zantext-favorites`).
  - [x] **22.3** Add **Vietnamese Diacritic Toggle (`Giữ dấu` / `Lược dấu chuẩn khung`)** and **OS Font Preview Switcher (`Web` / `iOS` / `Android`)**.
  - [x] **22.4** Expand unit tests in `contentUtils.test.ts` (`TC-YAY-01`..`TC-YAY-08`) and Playwright E2E tests in `content-writing.spec.ts` (`E2E-33`) & `content-creator-studio.spec.ts` to verify all 36 YayText styles and UX controls.

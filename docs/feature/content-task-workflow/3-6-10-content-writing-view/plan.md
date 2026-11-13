# Plan — Content Writing View (FR 3.6.10)

> Link: [spec.md](spec.md) — Document Status: **V4–V6 Implemented & Verified (60 Vitest unit tests + 68 Playwright E2E tests passing)**.
>
> - **V4 (2026-10-01)**: Canvas-rendering + Yjs CRDT real-time sync over STOMP WebSocket, mirroring the real Google Docs technique's effect. See [spec.md §4](spec.md#4-ui--ux--functional-architecture) and [§7](spec.md#7-edge-cases).
> - **V5 (2026-10-26)**: Docs/Word hybrid UI redesign + presence/multi-cursor awareness via `/app+/topic/tasks/{taskId}/awareness` + React Native mobile port.
> - **V6 (2026-11-09)**: Sub-pixel cursor physics (`measureRunSliceWidth`, `buildParagraphIndexMap`), Google Docs/Word full keyboard/mouse navigation, Document Import (`.docx`, `.txt`, `.md`, `.html`, live Google Docs URL) & Export (`.docx`, `.md`, `.txt`), Dual Social Publishing Workflows (**Direct API Auto-Publish** to Facebook/Instagram/TikTok/Threads + **Manual 1-Click Copy/Paste Zantext Workflow** with Plain-Text Facebook Composer Sandbox), and **YayText 36-Style Unicode Font & Text Effect Expansion** across 6 categories.

---

## 1. Technical Scope

| Item | Content |
|---|---|
| Repo | `brandhub-business-service` (BE), `brandhub-web` / `brandhub-UI-Design` (FE), `brandhub-mobile-app` (Mobile) |
| BE | `Task` entity, `TaskContentOperation` (append-only, opaque base64 Yjs update log), `TaskContentSnapshot` (client-reported Yjs state checkpoints), `spring-boot-starter-websocket`, `WebSocketConfig` (STOMP endpoint `/ws/tasks`, broker `/topic`), `WsJwtHandshakeInterceptor`, `TaskContentWebSocketController` (`@MessageMapping` for content + awareness), `PostController` (`POST /api/v1/workspaces/{id}/posts` & `/publish`) |
| FE (`src/pages/content-writing/`) | `CanvasTextEditor.tsx` (pixel-accurate canvas engine + hidden textarea input + sub-pixel cursor/selection math + native `Ctrl+C`/`Ctrl+X` Unicode copy + rich HTML paste), `FormattingToolbar.tsx` (Google Docs / Word Ribbon toggle, 16+ Font selector, Creative Copywriting Toolkit, YayText/Zantext Popover), `ImportDocumentModal.tsx` (Google Docs URL + `.docx`/`.md`/`.txt`/`.html` parser), `SocialPreview.tsx` (4-platform live preview + `Copy dán Facebook (Giữ Font)` + `Thử dán FB` plain-text sandbox), `contentUtils.ts` (Unicode font & effect engine), `VersionHistorySidebar.tsx`, `useTaskContentSync.ts` |
| FE (`src/pages/editor/`) | `RichTextEditor.tsx` (TipTap editor synchronized with `toPublishText`, `handleSelectFont` per-word & whole-post conversion, `Ctrl+C` Unicode copy, `Font Zantext` popover, `Nhập Google Docs / File`), `StudioPreviewPanel.tsx` (`PlatformMockup` for Facebook/Instagram/TikTok/Threads + `Copy dán Facebook (Giữ Font)` + `Thử dán FB` sandbox), `PlatformPreviewModal.tsx` |

---

## 2. Data Model (implemented)

- `Task` (table `tasks` / MongoDB `tasks` collection).
- `TaskContentOperation` (table `task_content_operations`) — append-only: `id`, `taskId`, `sequenceNumber` (bigint, `count(taskId) + 1` per insert), `yjsUpdate` (TEXT, base64-encoded opaque Yjs binary update), `editedBy`, `createdAt`.
- `TaskContentSnapshot` (table `task_content_snapshots`) — `id`, `taskId`, `sequenceNumber`, `yjsState` (TEXT, base64-encoded `Y.encodeStateAsUpdate(yDoc)`), `createdAt`.

---

## 3. API Contract (implemented)

```
FR 3.6.10 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content (Content Writing View)
→ 200 { "success": true, "data": { "snapshot": "<base64|null>", "operationsSinceSnapshot": ["<base64>", ...], "sequenceNumber" } }

FR 3.6.10 — WS /ws/tasks?token=<JWT> (Content Writing View)
Client → Server: PUBLISH /app/tasks/{taskId}/content { "update": "<base64 Yjs update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/content: { "update", "sequenceNumber", "editedBy" }
Client → Server: PUBLISH /app/tasks/{taskId}/awareness { "update": "<base64 y-protocols/awareness update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/awareness: { "update" }

FR 3.6.10 — POST /api/v1/workspaces/{id}/tasks/{taskId}/content/snapshot (Content Writing View)
Body: { "yjsState": "<base64>", "atSequenceNumber" }

FR 3.6.34 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions (View Content History)
→ 200 { "success": true, "data": [{ "snapshotId", "sequenceNumber", "createdAt", "editedBy", "editedByName" }] }

FR 3.6.34 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId} (View Content History)
→ 200 { "success": true, "data": { "snapshot": "<base64>", "operationsSinceSnapshot": [], "sequenceNumber" } }

FR 3.6.10 — POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}/restore (Content Writing View)
→ 200 { "success": true, "data": { "snapshot": "<base64>", "operationsSinceSnapshot": [], "sequenceNumber" } }

FR 3.7.6 — POST /api/v1/workspaces/{id}/ai/captions (Generate Caption)
→ 200 { "success": true, "data": { "generationId", "captions": [...] } }

FR 3.6.33 — POST /api/v1/workspaces/{id}/tasks/{taskId}/compliance (Check Compliance Content)
→ 200 { "success": true, "data": { "status": "PASSED", "issues": [] } }

FR 3.8.5 — POST /api/v1/workspaces/{id}/posts (Preview Post)
Body: { "taskId", "title", "content": "<Unicode-converted text>", "mediaUrls": [...], "targetPlatforms": ["FACEBOOK", "INSTAGRAM", "TIKTOK", "THREADS"] }

FR 3.8.8 — POST /api/v1/workspaces/{id}/posts/{postId}/publish (Publish Facebook Post)
```

---

## 4. Processing Flow (implemented)

### 4.1 Opening Content & Offline Fallback (`Có Backend` vs. `Không Backend`)
1. Client requests `GET /api/v1/workspaces/{id}/tasks/{taskId}/content` (or creates a draft POST task if `taskId` is absent).
2. If backend is reachable (`Có Backend`), client reconstructs `Y.Doc` from `snapshot` + `operationsSinceSnapshot` and connects to STOMP `/ws/tasks`.
3. If backend is unreachable (`Không Backend`), client falls back to `local-task-{workspaceId}` and restores/persists Yjs updates in `localStorage` (`brandhub-content-pending:{taskId}`), displaying `Chế độ Ngoại tuyến` while keeping all editing, Unicode font conversion, import/export, and copy-paste features 100% operational.

### 4.2 Real-Time Editing & Sub-Pixel Cursor Layout
4. `CanvasTextEditor` splits `Y.Text` delta into paragraphs and runs, measuring each run with `measureRunSliceWidth(ctx, text, letterSpacing)` and mapping every visual wrapped line via `buildParagraphIndexMap`.
5. Clicking, dragging, double-clicking (word select), triple-clicking (paragraph select), or pressing `Arrow` / `Ctrl+Arrow` / `Home` / `End` computes the exact `Y.Text` offset and renders the CSS caret and selection highlight rects at the exact glyph pixel boundary.

### 4.3 Dual Social Publishing Flow
6. **Live Conversion (`publishText`)**: On every `Y.Doc` or TipTap update, `toPublishText(ops)` converts each run's `font`, `bold`, `italic`, `underline`, `strikethrough`, and `listType` attributes into its target Unicode characters.
7. **Workflow A — Direct API Auto-Publish**: Clicking `Đăng bài` / `Đăng ngay` sends `publishText` to `POST /api/v1/workspaces/{id}/posts` and triggers `POST .../publish` for `FACEBOOK`, `INSTAGRAM`, `TIKTOK`, and `THREADS`.
8. **Workflow B — Manual Zantext/YayText Copy-Paste**: Pressing `Ctrl+C` / `Ctrl+X` or clicking any `Copy dán Facebook` / `Sao chép bản đăng` / `Font Zantext Copy` button invokes `copyTextToClipboard(convertedText)` and updates the built-in `Thử dán FB` plain-text composer sandbox.

---

## 5. Technical Architecture & Design Decisions

| Area | Decision | Rationale |
|---|---|---|
| Real-time sync algorithm | **Yjs CRDT (`Y.Doc` / `Y.Text`)** over STOMP WebSocket | Commutative, conflict-free merging without server-side decoding or fragile hand-written OT matrices. |
| Cursor & line-wrap alignment | Unified `buildParagraphIndexMap` + `measureRunSliceWidth` | Prevents desync between wrapped rich-text runs (with varying fonts/sizes/letter-spacing) and caret/click hit-testing. |
| Social font persistence | Unicode Mathematical Alphanumeric Symbols + Enclosed Alphanumerics + Combining Overlays | Social networks (`Facebook`, `Instagram`, `TikTok`, `Threads`) strip HTML/CSS `<span style="font-family">` tags from post captions. Converting runs to Unicode code points guarantees 100% visual persistence across API publish and manual clipboard paste. |

---

## 6. Blueprint for V6 Expansion: YayText 36-Style Engine & Smart UX (Pending User Approval)

### 6.1 Files to Modify in V6 Implementation

1. **`brandhub-web/src/pages/content-writing/contentUtils.ts`** (and sync to `brandhub-UI-Design`):
   - Add new Unicode character maps and effect transformers:
     - **Enclosed & Shape Maps**:
       - `BLACK_BUBBLE` (`🅐`–`🅩` `U+1F150`–`U+1F169`, digits `⓿➊➋➌➍➎➏➐➑➒`)
       - `BLACK_SQUARE` (`🅰`–`🆉` `U+1F170`–`U+1F189`, digits `⓿➊➋➌➍➎➏➐➑➒`)
       - `PARENTHESIZED` (`⒜`–`⒵` `U+249C`–`U+24B5`, digits `⓪⑴⑵⑶⑷⑸⑹⑺⑻⑼`)
       - `REGIONAL_INDICATOR` (`🇦`–`🇿` `U+1F1E6`–`U+1F1FF` with thin/space separator to prevent flag ligatures)
     - **Phonetic & Script Modifier Maps**:
       - `SUPERSCRIPT_MAP` (`ᴬᴮᶜᴰᴱᶠᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾQᴿˢᵀᵁⱽᵂˣʸᶻ`, `ᵃᵇᶜᵈᵉᶠᵍʰᶦʲᵏˡᵐⁿᵒᵖ۹ʳˢᵗᵘᵛʷˣʸᶻ`, `⁰¹²³⁴⁵⁶⁷⁸⁹`)
       - `SUBSCRIPT_MAP` (`ₐ₆꜀𝒹ₑ𝒻₉ₕᵢⱼₖₗₘₙₒₚqᵣₛₜᵤᵥwₓᵧ₂`, `₀₁₂₃₄₅₆₇₈₉`)
       - `UPSIDE_DOWN_MAP` (180° rotated glyphs `ɐqɔpǝɟƃɥᴉɾʞןɯuodbɹsʇnʌʍxʎz...` + line-by-line grapheme reversal)
     - **Combining Line / Overlay Effects**:
       - `COMBINING_DOUBLE_UNDERLINE = "\u0333"` (`A̳B̳C̳`)
       - `COMBINING_LONG_SOLIDUS = "\u0338"` (`9̸9̸0̸k̸` — Slash price)
       - `COMBINING_TILDE_OVERLAY = "\u0334"` (`A̴B̴C̴` — Wave strike)
       - `COMBINING_OVERLINE = "\u0305"` (`A̅B̅C̅`)
       - `COMBINING_ASTERISK_BELOW = "\u0359"` (`A͙B͙C͙`)
       - `COMBINING_ZIGZAG_ABOVE = "\u035B"` (`A͛B͛C͛`)
     - **Character & Line Wrapper Effects**:
       - `air-quotes` (`『A』『B』『C』`)
       - `lenticular-brackets` (`【A】【B】【C】`)
       - `sparkles-decorator` (`˜”*°•.˜”*°• ... •°*”˜.•°*”˜`)
       - `stars-wave-decorator` (`¸,ø¤º°\`°º¤ø,¸ ... ¸,ø¤º°°º¤ø,¸`)
       - `arrow-pointer-decorator` (`»»——⍟ ... ⍟——««`)
   - Add **`stripVietnameseAccents(text: string): string`** helper and integrate **Smart Vietnamese Diacritic Mode**:
     - Auto-transliterates Vietnamese accents to clean ASCII (`Khuyến mãi ĐẶC BIỆT` → `Khuyen mai DAC BIET`) when converting into `enclosed` (`circled`, `black-bubble`, `squared`, `black-square`, `parenthesized`, `regional-indicator`), `superscript`, `subscript`, or `upside-down` styles, or when the user enables the `stripAccents` toggle.
   - Expand `stripUnicodeStyling(text: string): string` so switching from any of the 36 styles back to another style cleanly restores the underlying base characters without stacking combining marks or brackets.
   - Expand `ZANTEXT_STYLE_PRESETS` from 14 to **36 presets**, each tagged with:
     - `id`, `label`, `badge`, `category`: `"emphasis" | "lines" | "enclosed" | "luxury" | "modern" | "creative"`
     - `compatibility`: `"Universal (iOS / Android / Web)" | "Modern OS"`
     - `vietnameseMode`: `"keep-marks" | "strip-accents-auto"`

2. **`brandhub-web/src/pages/content-writing/components/FormattingToolbar.tsx`** & **`brandhub-web/src/pages/editor/components/RichTextEditor.tsx`**:
   - Add **Category Filter Tabs** in the `Font Zantext` popover (`all`, `favorites`, `emphasis`, `lines`, `enclosed`, `luxury`, `modern`, `creative`).
   - Add **Favorite Star Toggle (`⭐`)** persisted in `localStorage` (`brandhub-zantext-favorites`).
   - Add **Vietnamese Diacritic Toggle (`Giữ dấu` vs. `Lược dấu chuẩn khung`)** (`data-testid="zantext-strip-accents-toggle"`).
   - Add **OS Font Preview Switcher (`Web` / `iOS` / `Android`)** (`data-testid="zantext-os-preview-select"`).
   - Add new font families (`Black Bubble (🅑🅤🅑)`, `Black Square (🅱🅻🅰)`, `Parenthesized (⒫⒜⒭)`, `Superscript (ᴬᴮᶜ)`) into `FONT_FAMILIES` so they can also be selected directly from the main Font dropdown.

3. **Unit & E2E Tests**:
   - **`contentUtils.test.ts`**: Add unit tests covering all 36 YayText presets, Vietnamese diacritic auto-stripping on enclosed shapes (`"Khuyến mãi"` → `"🅚🅗🅤🅨🅔🅝 🅜🅐🅘"`), price slashthrough (`"990.000đ"` → `"9̸9̸0̸.̸0̸0̸0̸đ̸"`), upside-down text reversal, and `stripUnicodeStyling` round-trip recovery across all 36 styles.
   - **`content-writing.spec.ts` & `content-creator-studio.spec.ts`**: Add E2E verification for Category tabs, Favorite pinning (`⭐`), Vietnamese diacritic toggle, Slash-price / Black Bubble conversion, and 1-click Copy into the Facebook Sandbox.

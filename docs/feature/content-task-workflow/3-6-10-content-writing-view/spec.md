# UC — Content Writing View

| | |
|---|---|
| FR Code | 3.6.10 |
| Feature | Content Writing View |
| Domain | Content & Workflow (FR 3.6) |
| Actors / Roles | `Owner, Manager, Creator, Client` |
| Version | 6.0 (V6 — YayText/Zantext 36-Style Unicode Engine, Dual Social Publishing Workflows, Full Google Docs/Word Cursor & Import/Export Parity, BK/No-BK Resilience, 2026-11-09; V5 — Docs/Word hybrid UI redesign + presence/multi-cursor awareness + React Native mobile port, 2026-10-26; V4 — canvas-rendering + Yjs CRDT real-time sync over WebSocket, 2026-10-01) |
| Document Status | V4–V5 + Core Dual Publishing & 16-Font/14-Preset Zantext Implemented & Verified (52 Vitest + 67 Playwright E2E passing); **V6 YayText 36-Style Expansion & Smart UX** documented below in §4.3 for review prior to implementation |

## 1. Objective

Write content the way Google Docs **actually** works (canvas-rendering with pixel-accurate cursor/selection physics, plus synchronized TipTap Studio support), automatically convert fonts and text effects into platform-safe Unicode characters on publish **and** on 1-click/keyboard copy (`Ctrl+C`), keep Content History/Version, and let multiple Creators edit the same content concurrently in real time via CRDT (Yjs) over WebSocket.

## 2. User Story

As a `Creator`, `Manager`, or `Owner`,
I want to write and format social media content directly inside BrandHub using familiar Google Docs / Microsoft Word tools and rich creative Unicode styles (like YayText / Zantext),
so that whether I **auto-publish via API** to Facebook, Instagram, TikTok, and Threads **or** **copy-paste (`Ctrl+C` / 1-click Copy)** into a normal personal/fanpage Facebook post, 100% of my chosen fonts, bold/italic/underline/strikethrough, price slashes, bullet/numbered lists, and paragraphs remain intact without ever needing an external font website.

## 3. Acceptance Criteria

- **Canvas-based Google Docs / Word editor (`ContentWritingPage`) & synchronized Studio editor (`ContentCreatorStudio`)**:
  - Sub-pixel caret & selection positioning using `measureRunSliceWidth` (incorporating per-run `letterSpacing` and list-marker prefix width) and `buildParagraphIndexMap` so wrapped lines, multi-font runs, center/right alignment, and bullet/numbered lists keep the cursor 100% aligned on every character.
  - Full Google Docs / Word keyboard & mouse navigation (`Ctrl+Left/Right`, `Ctrl+Shift+Left/Right`, `Home/End`, `Ctrl+Home/End`, `Ctrl+Backspace/Delete`, `Double-click` word select, `Triple-click` paragraph select).
  - Document Import from **Google Docs share URL** or local files (`.docx`, `.txt`, `.md`, `.html`) in both **Replace** and **Append** modes, plus Document Export to `.docx` (Word), `.md`, and `.txt`.
- **Dual Social Publishing Workflows (100% Format Preservation)**:
  1. **Direct API Auto-Publish Flow**: Publishes converted Unicode text (`toPublishText(ops)`) + media to **Facebook, Instagram, TikTok, and Threads** via `POST /api/v1/workspaces/{id}/posts` and `POST /api/v1/workspaces/{id}/posts/{postId}/publish`.
  2. **Manual Copy-Paste Flow (Zantext / YayText workflow)**: Pressing `Ctrl+C` / `Ctrl+X` inside the editor, or clicking `Sao chép bản đăng`, `Copy dán Facebook (Giữ Font)`, `Copy dán Facebook`, or any style row's `Copy` button writes the fully converted Unicode text to the clipboard (`navigator.clipboard.writeText` + fallback `<textarea>` + `window.__brandhubLastCopiedText`) and provides an inline **Facebook Plain-Text Composer Sandbox (`Thử dán FB`)** to verify the pasted result immediately.
- **YayText / Zantext Unicode Social Font & Effect Engine (V6 Expansion — see §4.3)**:
  - Supports **36 distinct Unicode text styles & combining-mark effects** across **6 marketing categories** (modeled after `https://yaytext.com/`), with **Smart Vietnamese Diacritic Handling** (preserving combining marks on Mathematical alphabets while optionally stripping diacritics on enclosed Bubble/Square shapes so they never break on iOS/Android), **Category Filter Tabs**, **Favorite/Pinned Styles (`⭐`)**, and **OS Compatibility Preview (`iOS` / `Android` / `Web`)**.
- **Brand Knowledge (`Có BK` vs. `Không BK`) & Offline Resilience (`Có Backend` vs. `Không Backend`)**:
  - AI Caption generation inside the editor adapts between **With Brand Knowledge (`Có BK`)** and **Without Brand Knowledge (`Không BK`)**.
  - When the backend or WebSocket is unreachable (`Không Backend`), the editor seamlessly initializes an offline local task session (`local-task-*`) and persists edits in `localStorage`.
- **Content History/Version & Real-time Collaborative Editing**:
  - Every edit is stored as an append-only Yjs CRDT operation log entry with periodic snapshots, word-level diffing, and read-only restore.
  - 2+ Creators editing concurrently see each other's edits and colored live cursor flags in real time over STOMP WebSocket.

---

## 4. UI / UX & Functional Architecture

### 4.1 Google Docs & Word Hybrid Chrome, Cursor Physics & Document Import/Export

- **Page chrome (V5–V6)**:
  - Google Docs header with document title input, Star/Favorite toggle, Cloud Sync status badge (`Đã lưu vào Đám mây` / `Đang đồng bộ…` / `Chế độ Ngoại tuyến`), menu bar (`Tệp`, `Chỉnh sửa`, `Xem`, `Chèn`, `Định dạng`, `Công cụ`), and **Google Docs ↔ Word Ribbon** layout switcher.
  - Horizontal ruler (`816px` A4/Letter width at 96dpi) with left/right margin markers, Zoom selector (`75%`–`150%`), and bottom status bar (live word count, character count, line/column caret coordinates, and active Font badge).
- **Canvas rendering & sub-pixel cursor physics**:
  - Content is drawn onto `<canvas>` while a hidden off-screen `<textarea>` (`role="textbox"`, `aria-multiline="true"`) captures keyboard, clipboard, and Vietnamese IME (`compositionstart` / `compositionupdate` / `compositionend`) events.
  - `measureRunSliceWidth` measures exact glyph slice widths including per-run `letterSpacing`, and `buildParagraphIndexMap` maps every wrapped visual line back to exact `Y.Text` indices so clicking or moving the cursor lands on the exact character boundary across all 16+ fonts, font sizes (`10pt`–`64pt`), alignments (`left`, `center`, `right`), and list prefixes (`• `, `1. `).
- **Document Import & Export (`ImportDocumentModal.tsx`)**:
  - **Import**: Supports pasting a public/shared **Google Docs URL** (fetches `/export?format=txt` with automatic CORS proxy fallback) or uploading `.docx` (parsed via `mammoth` HTML-to-Delta conversion preserving headings, bold, italic, underline, strikethrough, and lists), `.html`, `.md`, or `.txt`, in either **Replace (`Thay thế`)** or **Append (`Chèn nối tiếp`)** mode.
  - **Export**: Exports the formatted document to `.docx` (Word-compatible HTML/DOCX blob), `.md` (Markdown), or `.txt` (Unicode-converted social text).

### 4.2 Dual Social Publishing Workflows (API Auto-Publish + Manual Zantext Copy-Paste)

| Workflow | User Trigger Points | Data & Formatting Pipeline | Target Platforms |
| :--- | :--- | :--- | :--- |
| **Case 1: Direct API Auto-Publish** | • `Đăng bài` button → `Đăng bài lên mạng xã hội` modal in `ContentWritingPage`<br>• `Đăng ngay` / `Gửi duyệt` in `ContentCreatorStudio` | `yText.toDelta()` (or TipTap JSON) → `toPublishText(ops)` → `POST /api/v1/workspaces/{id}/posts` (`content`: Unicode-styled text, `targetPlatforms`) → `POST /api/v1/workspaces/{id}/posts/{postId}/publish` | `Facebook`, `Instagram`, `TikTok`, `Threads` |
| **Case 2: Manual 1-Click Copy & Paste (Zantext / YayText flow)** | • Keyboard `Ctrl+C` / `Ctrl+X` inside `CanvasTextEditor` or `RichTextEditor`<br>• `Sao chép bản đăng` (`copy-publish-text-btn`)<br>• `Copy dán Facebook (Giữ Font)` (`social-preview-copy-btn` / `studio-preview-copy-btn`)<br>• `Copy dán Facebook` in Publish Modal (`publish-modal-copy-btn`) & Studio toolbar (`studio-copy-publish-btn`)<br>• `Font Zantext` popover (`zantext-copy-{id}`) | Converts only the selected range (on `Ctrl+C`/`Ctrl+X`) or the entire post + hashtags (on button click) via `toPublishText` / `styleRunText`, writes to system clipboard via `copyTextToClipboard()`, and lets the user test-paste directly into the built-in **Plain-Text Facebook Composer Sandbox (`Thử dán FB`)** | Any standard Facebook personal profile, Fanpage composer, Group post, Comment box, Instagram, TikTok, or Threads |

---

### 4.3 YayText / Zantext 36-Style Unicode Social Font & Text Effect Engine (V6 Expansion Specification)

Referenced from **YayText (`https://yaytext.com/`)**, V6 expands BrandHub's Unicode styling engine from 14 basic presets to **36 comprehensive Unicode styles and combining-mark effects** organized into **6 marketing-oriented categories**, while solving YayText's biggest limitation for Vietnamese users (broken diacritics on enclosed/flipped characters).

#### 4.3.1 Complete Catalog of 36 Unicode Styles & Effects (`ZANTEXT_STYLE_PRESETS`)

| # | Style ID | Category | Display Label (VI) | Badge / Example Preview | Unicode Mechanism & Code Points | Vietnamese Diacritic Mode |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `sans-bold` | `emphasis` | Sans-Serif Đậm (Chuẩn FB) | `𝗦𝗮𝗻𝘀 𝗕𝗼𝗹𝗱` | Mathematical Sans-Serif Bold (`U+1D5D4`–`U+1D607`, digits `U+1D7EC`–`U+1D7F5`) | `keep-marks` (NFD base mapped + combining tone marks) |
| 2 | `sans-italic` | `emphasis` | Sans-Serif Nghiêng | `𝘚𝘢𝘯𝘴 𝘐𝘵𝘢𝘭𝘪𝘤` | Mathematical Sans-Serif Italic (`U+1D608`–`U+1D63B`) | `keep-marks` |
| 3 | `sans-bold-italic` | `emphasis` | Sans-Serif Đậm Nghiêng | `𝙎𝙖𝙣𝙨 𝘽𝙤𝙡𝙙 𝙄𝘵𝘢𝙡𝙞𝙘` | Mathematical Sans-Serif Bold Italic (`U+1D63C`–`U+1D66F`) | `keep-marks` |
| 4 | `serif-bold` | `emphasis` | Serif Đậm (Editorial) | `𝐒𝐞𝐫𝐢𝐟 𝐁𝐨𝐥𝐝` | Mathematical Bold (`U+1D400`–`U+1D433`, digits `U+1D7CE`–`U+1D7D7`) | `keep-marks` |
| 5 | `serif-italic` | `emphasis` | Serif Nghiêng (Classic) | `𝑆𝑒𝑟𝑖𝑓 𝐼𝑡𝑎𝑙𝑖𝑐` | Mathematical Italic (`U+1D434`–`U+1D467`, `ℎ` `U+210E`) | `keep-marks` |
| 6 | `serif-bold-italic` | `emphasis` | Serif Đậm Nghiêng | `𝑺𝒆𝒓𝒊𝒇 𝑩𝒐𝒍𝒅 𝑰𝒕𝒂𝒍𝒊𝒄` | Mathematical Bold Italic (`U+1D468`–`U+1D49B`) | `keep-marks` |
| 7 | `double-struck` | `emphasis` | Double Struck (Viền Kép) | `𝔻𝕠𝕦𝕓𝕝𝕖 𝕊𝕥𝕣𝕦𝕔𝕜` | Mathematical Double-Struck (`U+1D538`–`U+1D56B`, digits `U+1D7D8`–`U+1D7E1`) | `keep-marks` |
| 8 | `script` | `luxury` | Script (Chữ Ký Mảnh) | `𝒮𝒸𝓇𝒾𝓅𝓉` | Mathematical Script (`U+1D49C`–`U+1D4CF` + BMP exceptions `ℬℰℱℋℐℒℳℛℯℊℴ`) | `keep-marks` |
| 9 | `bold-script` | `luxury` | Bold Script (Chữ Ký Đậm) | `𝓑𝓸𝓵𝓭 𝓢𝓬𝓻𝓲𝓹𝓽` | Mathematical Bold Script (`U+1D4D0`–`U+1D503`) | `keep-marks` |
| 10 | `fraktur` | `luxury` | Fraktur Gothic (Cổ Điển) | `𝔉𝔯𝔞𝔨𝔱𝔲𝔯` | Mathematical Fraktur (`U+1D504`–`U+1D537` + `ℭℌℑℜℨ`) | `keep-marks` |
| 11 | `bold-fraktur` | `luxury` | Bold Fraktur (Gothic Đậm) | `𝕭𝖔𝖑𝖉 𝕱𝖗𝖆𝖐𝖙𝖚𝖗` | Mathematical Bold Fraktur (`U+1D56C`–`U+1D59F`) | `keep-marks` |
| 12 | `monospace` | `modern` | Monospace (Code / Tech) | `𝙼𝚘𝚗𝚘𝚜𝚙𝚊𝚌𝚎` | Mathematical Monospace (`U+1D670`–`U+1D6A3`, digits `U+1D7F6`–`U+1D7FF`) | `keep-marks` |
| 13 | `small-caps` | `modern` | Small Caps (Chữ Hoa Nhỏ) | `ꜱᴍᴀʟʟ ᴄᴀᴘꜱ` | IPA / Phonetic Small Capitals (`ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘꞯʀꜱᴛᴜᴠᴡxʏᴢ`) | `keep-marks` |
| 14 | `fullwidth` | `modern` | Fullwidth (Vaporwave Giãn Cách) | `Ｆｕｌｌｗｉｄｔｈ` | Halfwidth and Fullwidth Forms (`U+FF21`–`U+FF5A`, `U+FF10`–`U+FF19`) | `strip-accents-auto` |
| 15 | `superscript` | `modern` | Superscript (Chữ Mũ Nhỏ / Ghi Chú) | `ˢᵘᵖᵉʳˢᶜʳᶦᵖᵗ ⁰¹²` | Phonetic Modifiers & Superscripts (`ᴬᴮᶜᴰᴱᶠᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾQᴿˢᵀᵁⱽᵂˣʸᶻ`, `ᵃᵇᶜᵈᵉᶠᵍʰᶦʲᵏˡᵐⁿᵒᵖ۹ʳˢᵗᵘᵛʷˣʸᶻ`, `⁰¹²³⁴⁵⁶⁷⁸⁹`) | `strip-accents-auto` |
| 16 | `subscript` | `modern` | Subscript (Chữ Chỉ Số Dưới) | `ₛᵤ₆ₛ꜀ᵣᵢₚₜ ₀₁₂` | Unicode Subscripts (`ₐ₆꜀𝒹ₑ𝒻₉ₕᵢⱼₖₗₘₙₒₚqᵣₛₜᵤᵥwₓᵧ₂`, `₀₁₂₃₄₅₆₇₈₉`) | `strip-accents-auto` |
| 17 | `circled` | `enclosed` | Circled (Khung Tròn Trắng) | `ⒶⒷⒸ ⓐⓑⓒ` | Enclosed Alphanumerics (`U+24B6`–`U+24E9`, `⓪` `U+24EA`, `①`–`⑨` `U+2460`–`U+2468`) | `strip-accents-auto` |
| 18 | `black-bubble` | `enclosed` | Black Bubble (Tròn Nền Đen) | `🅑🅤🅑🅑🅛🅔` | Negative Circled Latin Capital Letters (`U+1F150`–`U+1F169`, digits `⓿➊➋➌➍➎➏➐➑➒`) | `strip-accents-auto` |
| 19 | `squared` | `enclosed` | Squared (Khung Vuông Trắng) | `🄰🄱🄲` | Enclosed Alphanumeric Supplement Squared (`U+1F130`–`U+1F149`) | `strip-accents-auto` |
| 20 | `black-square` | `enclosed` | Black Square (Vuông Nền Đen) | `🅱🅻🅰🅲🅺` | Negative Squared Latin Capital Letters (`U+1F170`–`U+1F189`) | `strip-accents-auto` |
| 21 | `parenthesized` | `enclosed` | Parenthesized (Khung Ngoặc Đơn) | `⒫⒜⒭⒠⒩` | Parenthesized Latin Letters (`U+249C`–`U+24B5`, digits `⑴`–`⑼` `U+2474`–`U+247C`) | `strip-accents-auto` |
| 22 | `regional-indicator` | `enclosed` | Regional Flag (Chữ Cờ Xanh) | `🇧 🇷 🇦 🇳 🇩` | Regional Indicator Symbols (`U+1F1E6`–`U+1F1FF` joined with spaces so OS does not merge pairs into country flags) | `strip-accents-auto` |
| 23 | `sans-bold-underline` | `lines` | Sans Đậm + Gạch Dưới | `𝗦̲𝗮̲𝗻̲𝘀̲ ̲𝗨̲𝗻̲𝗱̲𝗲̲𝗿̲` | `SANS_BOLD` + Combining Low Line (`U+0332`) | `keep-marks` |
| 24 | `double-underline` | `lines` | Gạch Chân Kép (Double Underline) | `D̳o̳u̳b̳l̳e̳ ̳U̳n̳d̳e̳r̳` | Combining Double Low Line (`U+0333`) after each non-newline glyph | `keep-marks` |
| 25 | `sans-bold-strike` | `lines` | Sans Đậm + Gạch Ngang | `𝗦̶𝗮̶𝗻̶𝘀̶ ̶𝗦̶𝘁̶𝗿̶𝗶̶𝗸̶𝗲̶` | `SANS_BOLD` + Combining Long Stroke Overlay (`U+0336`) | `keep-marks` |
| 26 | `slashthrough` | `lines` | Gạch Chéo Giá Gốc (Slash Price) | `9̸9̸0̸.̸0̸0̸0̸đ̸` | Combining Long Solidus Overlay (`U+0338`) — ideal for crossing out old prices while keeping digits readable | `keep-marks` |
| 27 | `tilde-strike` | `lines` | Gạch Lượn Sóng (Tilde Wave) | `T̴i̴l̴d̴e̴ ̴S̴t̴r̴i̴k̴e̴` | Combining Tilde Overlay (`U+0334`) | `keep-marks` |
| 28 | `overline` | `lines` | Gạch Trên Đầu (Overline) | `O̅v̅e̅r̅l̅i̅n̅e̅` | Combining Overline (`U+0305`) | `keep-marks` |
| 29 | `under-asterisks` | `lines` | Sao Dưới Chân (Under-Asterisks) | `S͙t͙a͙r͙ ͙B͙e͙l͙o͙w͙` | Combining Asterisk Below (`U+0359`) | `keep-marks` |
| 30 | `lightning-above` | `lines` | Tia Chớp Trên Đầu (Zigzag Flash) | `F͛l͛a͛s͛h͛ ͛S͛a͛l͛e͛` | Combining Zigzag Above (`U+035B`) | `keep-marks` |
| 31 | `upside-down` | `creative` | Chữ Lộn Ngược (Upside-Down Flip) | `qnpuɐɹB` | 180° rotated Unicode character map (`ɐqɔpǝɟƃɥᴉɾʞןɯuodbɹsʇnʌʍxʎz...`) with reversed grapheme order per line | `strip-accents-auto` |
| 32 | `air-quotes` | `creative` | Khung Ngoặc Nhật (Air Quotes) | `『B』『r』『a』『n』『d』` | Wraps each non-space character in `『c』` | `keep-marks` |
| 33 | `lenticular-brackets` | `creative` | Khung Ngoặc Đen (Bold Brackets) | `【B】【r】【a】【n】【d】` | Wraps each non-space character in `【c】` | `keep-marks` |
| 34 | `sparkles-decorator` | `creative` | Viền Lấp Lánh (Sparkles Banner) | `˜”*°•. Text .•°*”˜` | Wraps line in `˜”*°•.˜”*°• ` + `SANS_BOLD` + ` •°*”˜.•°*”˜` | `keep-marks` |
| 35 | `stars-wave-decorator` | `creative` | Viền Sóng Sao (Star Wave Banner) | `¸,ø¤º° Text °º¤ø,¸` | Wraps line in `¸,ø¤º°\`°º¤ø,¸ ` + `BOLD_SCRIPT` + ` ¸,ø¤º°°º¤ø,¸` | `keep-marks` |
| 36 | `arrow-pointer-decorator` | `creative` | Viền Mũi Tên Tâm Điểm (Pointer) | `»»——⍟ Text ⍟——««` | Wraps line in `»»——⍟ ` + `SANS_BOLD` + ` ⍟——««` | `keep-marks` |

#### 4.3.2 Smart Vietnamese Diacritic Engine (`VietnameseDiacriticMode`)

- **Problem observed on YayText.com**: When a Vietnamese marketer types `"Khuyến mãi 50%"` into YayText, characters with diacritics (`ế`, `ã`) either fail to convert (producing jarring mixed fonts like `𝗞𝗵𝘂𝘆ế𝗻 𝗺ã𝗶`) or, on Enclosed shapes (`🅑🅤🅑🅑🅛🅔`), attach combining marks outside the circle/square, causing broken glyph boxes (``) on iOS and Android.
- **BrandHub V6 Solution**:
  1. **For Mathematical & Combining-Mark styles (`keep-marks`)**: `styleRunText` decomposes Vietnamese via `NFD`, maps the ASCII base letter (`a`–`z`, `A`–`Z`) to the target Mathematical Unicode code point, and re-attaches the Vietnamese tone/vowel combining marks (`\u0300`–`\u036F`), while mapping `đ/Đ` cleanly (or stripping its stroke when user toggles `Tự động lược dấu`).
  2. **For Enclosed, Superscript/Subscript & Upside-Down styles (`strip-accents-auto`)**: Automatically transliterates Vietnamese characters to their unaccented ASCII base (`ă/â/á/à/ả/ã/ạ` → `a`, `đ/Đ` → `d/D`, `ê/é/...` → `e`, `ô/ơ/...` → `o`, `ư/...` → `u`) **before** mapping into `🅑🅤🅑🅑🅛🅔`, `🅱🅻🅰🅲🅺`, `ⒶⒷⒸ`, `🄰🄱🄲`, `⒫⒜⒭⒠⒩`, `🇧 🇷 🇦 🇳 🇩`, `ˢᵘᵖᵉʳ`, or `upside-down`. This guarantees `"Khuyến mãi"` becomes `"🅚🅗🅤🅨🅔🅝 🅜🅐🅘"` with 100% uniform, unbroken shapes across every device.
  3. **User Toggle in Zantext Panel (`zantext-vietnamese-mode-toggle`)**: Users can also explicitly toggle **"Lược dấu Tiếng Việt (Chuẩn 100% mọi thiết bị)"** on or off for any style if they prefer pure unaccented Unicode headers.

#### 4.3.3 YayText-Inspired UI/UX Enhancements in `FormattingToolbar.tsx` & `RichTextEditor.tsx`

1. **6 Category Filter Tabs + Search Input**:
   - `Tất cả (36)` | `⭐ Yêu thích` | `Tiêu đề (7)` | `Sale & Gạch giá (8)` | `Khung Nổi bật (6)` | `Sang trọng (4)` | `Hiện đại (5)` | `Độc lạ (6)`.
2. **Favorite / Pinned Styles (`⭐`)**:
   - Clicking the star icon (`data-testid="zantext-fav-{id}"`) on any style pins it to the top and persists the list in `localStorage` (`brandhub-zantext-favorites`).
3. **OS / Device Font Rendering Preview Switcher**:
   - Inside the Zantext Popover and Social Preview, users can switch the preview font stack between **`Mặc định`**, **`iOS (Apple San Francisco)`**, and **`Android (Google Roboto / Noto)`** to inspect how the Unicode glyphs render on mobile devices before publishing.

---

## 5. API Contract (implemented)

REST for the initial load, snapshot reporting, version history/restore, Google Docs URL import proxy, Brand Knowledge RAG captioning, and Social Post publishing; STOMP WebSocket for real-time sync and awareness between Creators.

```
GET /api/v1/workspaces/{id}/tasks/{taskId}/content
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state|null>", "operationsSinceSnapshot": ["<base64 Yjs update>", ...], "sequenceNumber" } }

WS /ws/tasks?token=<JWT>  (STOMP over spring-boot-starter-websocket; JWT via query param, not header)
Client → Server: PUBLISH /app/tasks/{taskId}/content  { "update": "<base64 Yjs update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/content: { "update", "sequenceNumber", "editedBy" }

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/snapshot
Body: { "yjsState": "<base64 Yjs state>", "atSequenceNumber" }

Client → Server: PUBLISH /app/tasks/{taskId}/awareness  { "update": "<base64 y-protocols/awareness update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/awareness: { "update" }

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions
→ 200 { "success": true, "data": [{ "snapshotId", "sequenceNumber", "createdAt", "editedBy", "editedByName" }] }

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state>", "operationsSinceSnapshot": [], "sequenceNumber" } }

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}/restore
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state>", "operationsSinceSnapshot": [], "sequenceNumber" } }

POST /api/v1/workspaces/{id}/posts
Body: { "taskId", "title", "content": "<Unicode-converted publish text>", "mediaUrls": [...], "targetPlatforms": ["FACEBOOK", "INSTAGRAM", "TIKTOK", "THREADS"] }
→ 200 { "success": true, "data": { "id": "<postId>", "status": "DRAFT", ... } }

POST /api/v1/workspaces/{id}/posts/{postId}/publish
→ 200 { "success": true, "data": { "id": "<postId>", "status": "PUBLISHED", ... } }
```

## 6. Error Handling

- Task is not of type `post` → 400 `INVALID_TASK_TYPE_FOR_CONTENT_WRITING`.
- WebSocket handshake without a valid JWT → connection rejected with 401 (`WsJwtHandshakeInterceptor`).
- STOMP SEND `/app/tasks/{id}/content` or SUBSCRIBE `/topic/tasks/{id}/content` by a user who is not an active `Owner`, `Manager`, or `Creator` of the task's workspace, or for an unknown task → the frame is rejected with a STOMP ERROR (`ChatInboundChannelInterceptor.authorizeTask`).
- Google Docs import URL is private or invalid → `ImportDocumentModal` displays a clear Vietnamese instruction message guiding the user to enable *"Bất kỳ ai có đường liên kết đều có thể xem"* or upload a `.docx` file directly.
- Backend unreachable when opening `/workspaces/{id}/content-writing` → automatically enters **Offline Mode (`Chế độ Ngoại tuyến`)** with a local `Y.Doc` backed by `localStorage` so the user can still write, format, convert fonts, and copy/paste to Facebook without interruption.

## 7. Edge Cases

- **Two Creators editing the same content concurrently**: Resolved via Yjs CRDT merge over STOMP WebSocket.
- **Vietnamese IME through the off-screen hidden input**: Handled via `compositionstart`/`compositionupdate`/`compositionend` without premature state commits or render loops.
- **Mixed per-word Unicode fonts in a single post**: Both `CanvasTextEditor` (via per-run `RunAttrs.font` and `RunAttrs.zantextStyle`) and `RichTextEditor` (via selection-scoped `handleSelectFont` that strips prior Unicode code points on the selected slice before applying the new style) allow mixing multiple fonts (e.g. `𝗕𝗥𝗔𝗡𝗗𝗛𝗨𝗕` + `𝒢𝓇𝒶𝓃𝒹 𝒪𝓅ℯ𝓃𝒾𝓃𝑔` + `9̸9̸0̸k̸`) inside the same paragraph without overwriting neighboring words.
- **Enclosed Unicode shapes (`🅑🅤🅑🅑🅛🅔`, `🅱🅻🅰🅲🅺`, `🄰🄱🄲`) with Vietnamese text**: Automatically transliterated to unaccented ASCII base characters before code-point substitution so no stray combining marks break the enclosed glyph boxes on mobile OS renderers.

## 8. Definition of Done

- The canvas editor and Studio editor render accurately; cursor/selection coordinates match every character pixel-accurately across all fonts, sizes, alignments, and wrapped lines.
- All **36 YayText / Zantext Unicode styles & effects** across **6 categories** convert accurately and preserve 100% of formatting in both **Direct API Auto-Publish** (`Facebook`, `Instagram`, `TikTok`, `Threads`) and **Manual Copy-Paste** (`Ctrl+C`, toolbar buttons, Zantext popover, and Plain-Text Facebook Composer Sandbox).
- Document Import (`.docx`, `.txt`, `.md`, `.html`, Google Docs URL) and Export (`.docx`, `.md`, `.txt`) work end-to-end.
- Both `Có BK` / `Không BK` and `Có Backend` / `Không Backend` scenarios pass 100% of automated Vitest unit tests and Playwright E2E tests.

## BA Reference

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

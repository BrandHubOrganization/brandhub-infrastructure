# Sequence Flow — Content Writing View (FR 3.6.10)

> Companion to [spec.md](spec.md) and [plan.md](plan.md) (FR 3.6.10). **V6 Implemented & Verified** — Google Docs / Microsoft Word hybrid canvas-rendering editor + synchronized Studio editor with Yjs CRDT real-time sync & peer cursor awareness over STOMP WebSocket, Document Import/Export (`.docx`, `.md`, `.txt`, `.html`, live Google Docs URL), YayText/Zantext 36-Style Unicode Font & Text Effect Engine, and Dual Social Publishing Workflows (**Direct API Auto-Publish** to `Facebook`, `Instagram`, `TikTok`, `Threads` + **Manual 1-Click Copy/Paste** with Facebook Plain-Text Composer Sandbox).
>
> Updated 2026-11-09.

## 1. Canonical Actors & Components

- **Actors**: `Owner`, `Manager`, `Creator`, `Client` (strictly following the 6 canonical BrandHub system roles).
- **Frontend (`brandhub-web` / `brandhub-UI-Design` / `brandhub-mobile-app`)**:
  - `ContentWritingPage` + `CanvasTextEditor` + `FormattingToolbar` + `ImportDocumentModal` + `SocialPreview` + `VersionHistorySidebar` + `useTaskContentSync`.
  - `ContentCreatorStudio` + `RichTextEditor` + `StudioPreviewPanel`.
  - `contentUtils.ts` — 36-Style YayText/Zantext Unicode conversion engine (`toPublishText`, `styleRunText`, `convertPlainTextToSocialStyle`, `stripUnicodeStyling`, `stripVietnameseAccents`).
- **Backend (`brandhub-business-service`)**:
  - `TaskController` — `FR 3.6.10 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content (Content Writing View)`, `@RequireRole({OWNER, MANAGER, CREATOR, CLIENT})`.
  - `WsJwtHandshakeInterceptor` — validates JWT (`?token=`) on WebSocket upgrade for `FR 3.6.10 — WS /ws/tasks?token=<JWT> (Content Writing View)`.
  - `TaskContentWebSocketController` — `@MessageMapping("/tasks/{taskId}/content")` and `@MessageMapping("/tasks/{taskId}/awareness")`.
  - `TaskContentServiceImpl` — `getContent`, `appendOperation`, `reportSnapshot`, `listVersions`, `getVersion`, `restoreVersion`.
  - `PostController` — `FR 3.8.5 — POST /api/v1/workspaces/{id}/posts (Preview Post)` and `FR 3.8.8 — POST /api/v1/workspaces/{id}/posts/{postId}/publish (Publish Facebook Post)`.
- **Database**: PostgreSQL `task_content_operations` (append-only base64 Yjs updates) and `task_content_snapshots`.

---

## 2. Normal Flow — Opening Content & Offline Fallback (`Có Backend` vs. `Không Backend`)

1. `Creator` A opens `/workspaces/:id/content-writing?taskId=:taskId` (or `/workspaces/:id/content-writing`, which creates/loads a draft `POST` task).
2. Client A calls `FR 3.6.10 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content (Content Writing View)`.
3. **Case A — Backend Reachable (`Có Backend`)**:
   - `TaskContentServiceImpl` verifies the task belongs to the workspace and is of type `POST`, then returns `{ snapshot, operationsSinceSnapshot[], sequenceNumber }`.
   - Client A (`useTaskContentSync`) applies `snapshot` and replays `operationsSinceSnapshot` into its local `Y.Doc`, opens `FR 3.6.10 — WS /ws/tasks?token=<JWT> (Content Writing View)`, and subscribes to `/topic/tasks/{taskId}/content` and `/topic/tasks/{taskId}/awareness`.
4. **Case B — Backend Unreachable (`Không Backend` / Offline Fallback)**:
   - Client A automatically switches to `Chế độ Ngoại tuyến` (`local-task-{workspaceId}`), restoring any pending updates from `localStorage` (`brandhub-content-pending:{taskId}`) so the user can continue writing, formatting, converting 36 YayText fonts, importing/exporting files, and copying to Facebook without interruption.

---

## 3. Normal Flow — Real-Time Collaborative Editing & Sub-Pixel Cursor Layout

5. `Creator` A types, pastes rich HTML, or uses Google Docs / Word shortcuts (`Ctrl+B/I/U`, `Ctrl+Arrow`, `Ctrl+Shift+Arrow`, `Double/Triple-click`).
6. `CanvasTextEditor` applies the mutation to `Y.Text("content")` inside a `yDoc.transact()` block, measures runs via `measureRunSliceWidth(ctx, text, letterSpacing)`, and maps wrapped visual lines via `buildParagraphIndexMap` so the CSS caret and selection highlight sit at the exact sub-pixel glyph boundary.
7. `useTaskContentSync` broadcasts `{ update: base64 }` to `/app/tasks/{taskId}/content` and `{ update: awarenessBase64 }` to `/app/tasks/{taskId}/awareness`.
8. `TaskContentWebSocketController` persists the opaque Yjs update into `task_content_operations` with `sequenceNumber = count(taskId) + 1` and broadcasts to `/topic/tasks/{taskId}/content`.
9. `Creator` B receives the broadcast, applies `Y.applyUpdate(yDoc, update, "remote")`, and renders `Creator` A's live colored cursor flag and text update immediately.

---

## 4. Normal Flow — Document Import (`.docx`, `.md`, `.txt`, `.html`, Google Docs URL) & Export

10. `Creator` clicks `Nhập Google Docs / File` (`open-import-doc-btn` / `studio-import-doc-btn`).
11. `ImportDocumentModal` either fetches the public Google Docs export stream (`extractGoogleDocId`) or parses the uploaded `.docx` (ZIP XML via `extractTextFromDocxBuffer`), `.md`, `.txt`, or `.html` into structured `DeltaOp[]` runs (preserving `H1`/`H2`/`H3`, bold, italic, underline, and bullet/numbered lists).
12. Depending on the selected mode (`Thay thế toàn bộ` vs. `Nối thêm vào cuối bài`), the editor applies the imported delta and updates the document title and 4-platform Live Social Preview.
13. From `Tệp` → `Tải xuống`, the user can export the current document losslessly to `.docx` (`deltaToDocxZip`), `.md` (`deltaToMarkdown`), or `.txt`.

---

## 5. Normal Flow — YayText 36-Style Font Conversion & Dual Social Publishing

14. `Creator` selects a font from the toolbar or opens `Font Zantext (36 Font MXH)` (`zantext-panel-trigger` / `studio-zantext-btn`), filters by category (`Tiêu đề`, `Sale & Gạch giá`, `Khung Nổi bật`, `Sang trọng`, `Hiện đại`, `Độc lạ`, `⭐ Yêu thích`), optionally toggles `Lược dấu Tiếng Việt` or `Preview: iOS / Android`, and applies or copies any of the **36 YayText / Zantext presets** (e.g., `🅑🅤🅑🅑🅛🅔`, `🅱🅻🅰🅲🅺`, `9̸9̸0̸.̸0̸0̸0̸đ̸`, `𝐒𝐞𝐫𝐢𝐟 𝐁𝐨𝐥𝐝`, `𝓑𝓸𝓵𝓭 𝓢𝓬𝓻𝓲𝓹𝓽`).
15. On every edit, `toPublishText(ops)` converts the formatted document into a platform-safe Unicode string (`publishText`).
16. **Publishing Case 1 — Direct API Auto-Publish (`Đăng bài` / `Đăng ngay`)**:
    - User selects target platforms (`Facebook`, `Instagram`, `TikTok`, `Threads`) and confirms publish.
    - Client calls `FR 3.8.5 — POST /api/v1/workspaces/{id}/posts (Preview Post)` with `caption = publishText` and `FR 3.8.8 — POST /api/v1/workspaces/{id}/posts/{postId}/publish (Publish Facebook Post)`.
    - The published post banner displays the live permalink and confirms 100% of Unicode fonts, line breaks, and bullets are preserved.
17. **Publishing Case 2 — Manual 1-Click Copy & Paste (`Copy dán Facebook (Giữ Font)` / `Ctrl+C`)**:
    - User presses `Ctrl+C` inside the editor or clicks `Copy dán Facebook (Giữ Font)` / `Sao chép bản đăng` / row `Copy`.
    - `copyTextToClipboard(convertedText)` writes the exact Unicode string to the system clipboard.
    - User can immediately paste into the built-in **`Thử dán FB` (Plain-Text Facebook Composer Sandbox)** or directly into a normal Facebook post with 100% font retention.

---

## 6. Normal Flow — Snapshots & Version History Restore

18. After 200 operations or 20 seconds of idle time after an edit, the client calls `FR 3.6.10 — POST /api/v1/workspaces/{id}/tasks/{taskId}/content/snapshot (Content Writing View)`.
19. `VersionHistorySidebar` loads `FR 3.6.34 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions (View Content History)` and `FR 3.6.34 — GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId} (View Content History)` to display word-level diffs (`diffText`).
20. Clicking `Restore` calls `FR 3.6.10 — POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}/restore (Content Writing View)`, which appends a new forward snapshot and broadcasts the restored state via Yjs without erasing prior history.

---

## 7. Error Paths

| Step | Failure Condition | HTTP / WS | Error Code / Fallback |
|---|---|---|---|
| Open content | Task does not exist or belongs to a different Workspace | 404 | `TASK_NOT_FOUND` (`MSG04`) |
| Open content | Task is not of type `POST` | 400 | `INVALID_TASK_TYPE_FOR_CONTENT_WRITING` (`MSG12`) |
| Open content | Backend unreachable (`503` / network error) | Fallback | Switches to `Chế độ Ngoại tuyến` (`continue-offline-btn`) |
| Open content | Caller is not an authorized workspace member | 403 | `FORBIDDEN` (`@RequireRole`) |
| WS handshake | JWT missing or invalid | Handshake rejected | 401 (`WsJwtHandshakeInterceptor`) |
| Import Google Doc | Google Docs link is private or malformed | Client / 400 | Displays Vietnamese sharing guide + `.docx` upload fallback |
| Restore | `snapshotId` not found or belongs to a different Task | 404 | `TASK_NOT_FOUND` |

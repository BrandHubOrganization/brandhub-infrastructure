**3.6.10 Content Writing View**

**Function Trigger**

A `Creator`, `Manager`, or `Owner` opens the Content Writing View from a Post Task Detail screen or navigates to `/workspaces/{id}/content-writing`.

**Function Description**

- **Actors / Roles**: `Owner, Manager, Creator, Client`
- **Purpose**: Allow workspace members to compose, format, import/export, and preview social media post content using a pixel-accurate Google Docs / Microsoft Word canvas editor, automatically converting chosen fonts and text effects into platform-compatible Unicode characters (YayText / Zantext standard) for both **direct API auto-publishing** (`Facebook`, `Instagram`, `TikTok`, `Threads`) and **manual 1-click copy-paste** into standard social posts, while maintaining an append-only version history and real-time multi-user collaboration.
- **Interface**: Google Docs / Word hybrid canvas editor (`816px` page sheet, ruler, zoom controls, Docs/Ribbon toolbar switcher, YayText/Zantext 36-style font converter popover, Google Docs/File import modal, AI Caption assistant with Brand Knowledge status, 4-platform live social preview with plain-text Facebook paste sandbox, and Version History sidebar).
- **Data Processing**: Every edit is recorded as an append-only Yjs CRDT operation (`TaskContentOperation`) and periodically checkpointed into a `TaskContentSnapshot`. Concurrent edits and live cursor awareness from multiple users are synchronized in real time over STOMP WebSocket (`/ws/tasks`). When copying or publishing, the formatting engine (`toPublishText` / `styleRunText`) converts rich-text runs into Unicode Mathematical Alphanumeric Symbols, Enclosed Alphanumerics (`🅑🅤🅑🅑🅛🅔`, `🅱🅻🅰🅲🅺`, `ⒶⒷⒸ`, `🄰🄱🄲`), and Combining Overlays (`\u0332`, `\u0333`, `\u0336`, `\u0338`) with smart Vietnamese diacritic handling.

**Screen Layout**

*Figure 72 - Content Writing View*

- Canvas-rendered document sheet (`<canvas>`) with pixel-accurate caret and selection rendering, paired with an off-screen Vietnamese IME-aware input layer.
- Formatting toolbar supporting Google Docs compact mode and Microsoft Word Ribbon mode, 16+ font families, YayText/Zantext 36-style quick converter (`Font Zantext`), Document Import (`Nhập Google Docs / File`), Document Export (`.docx`, `.md`, `.txt`), and AI Caption generation (`Có BK` / `Không BK`).
- 4-platform Live Social Preview (`Facebook`, `Instagram`, `TikTok`, `Threads`) with 1-click Unicode Copy (`Copy dán Facebook (Giữ Font)`), Plain-Text Facebook Composer Sandbox (`Thử dán FB`), and Direct API Publish modal (`Đăng bài`).
- Version History sidebar listing snapshots with author name, timestamp, word-level diff (`Changes`), and 1-click restore (`Restore`).

**Function Details**
- **Data Specifications**
    - **Input required**: Workspace identifier (`workspaceId`), Task identifier (`taskId`), and Yjs CRDT operation updates or imported document content.
    - **Input optional**: Target social platforms (`Facebook`, `Instagram`, `TikTok`, `Threads`), selected Unicode font/effect preset, Google Docs share URL or uploaded file (`.docx`, `.txt`, `.md`, `.html`), AI Caption prompt.
    - **System data**: Task record (type `POST`), workspace membership & role permissions, append-only operation log (`task_content_operations`), periodic snapshots (`task_content_snapshots`), connected social accounts, and workspace Brand Knowledge status.
    - **Output**: Real-time synchronized canvas document, Unicode-converted social post text (`publishText`) copied to system clipboard or published via API to connected social platforms, and restorable version snapshots.

- **Business Rules**
    - Only a Task of type `POST` supports the Content Writing View.
    - `Owner`, `Manager`, and `Creator` roles may edit, import, copy, and publish content; `Client` role may view shared content according to workspace permissions.
    - Every edit is persisted as an append-only operation; restoring an earlier version applies the historical state as a new forward operation so no history is overwritten.
    - All chosen fonts, bold/italic/underline/strikethrough marks, price slashes, and bullet/numbered lists are automatically converted to Unicode characters upon clipboard copy (`Ctrl+C` or 1-click Copy buttons) and upon API publishing to `Facebook`, `Instagram`, `TikTok`, and `Threads`.

- **Validation**
    - Task does not exist or belongs to another workspace → Display not-found notification (`MSG04`).
    - Task is not of type `POST` → Display validation notification (`MSG12`).
    - Google Docs import URL is malformed or not publicly shared → Display actionable guidance prompting the user to enable link sharing or upload a `.docx` file.
    - Empty document → Disable `Sao chép bản đăng`, `Copy dán Facebook (Giữ Font)`, and `Đăng bài` actions until content is entered.

**Functionalities**
- **Normal Flow**
    1. The user opens the Content Writing View for a Post task.
    2. The system loads the latest content snapshot and tail operations, renders the canvas page, and establishes a real-time WebSocket session (including live peer cursor awareness).
    3. The user types content directly, imports a Google Docs link / `.docx` file, or generates an AI Caption (`Có BK` / `Không BK`), and applies fonts or YayText/Zantext Unicode styles.
    4. The system renders the styled text on the canvas, updates the 4-platform Live Social Preview in real time, and streams CRDT operations to connected peers.
    5. The user either (a) clicks `Copy dán Facebook (Giữ Font)` / presses `Ctrl+C` to copy the Unicode-formatted post for manual pasting onto Facebook, or (b) clicks `Đăng bài` to auto-publish the formatted post directly to selected social platforms (`Facebook`, `Instagram`, `TikTok`, `Threads`).

- **Abnormal Cases**
    - 2.a1: The backend server or WebSocket connection is temporarily unreachable. 2.a2: The system switches to Offline Mode (`Chế độ Ngoại tuyến`), queuing edits in local storage and resynchronizing automatically upon reconnection.
    - 3.a1: The user imports an unsupported file extension or a private Google Docs link. 3.a2: The system displays a clear validation message and keeps the existing document unchanged.
    - 5.a1: A target social platform account is not yet connected during Direct API Publish. 5.a2: The system prompts the user to connect the account or use the 1-click `Copy dán Facebook` button to post manually.

**Post-Conditions**

- New CRDT operations and periodic snapshots are saved to the task's content history, and the Unicode-formatted social post is either copied to the user's clipboard or published to the selected social media platforms.

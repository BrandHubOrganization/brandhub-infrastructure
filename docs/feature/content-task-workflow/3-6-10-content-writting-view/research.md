# Research — How Google Docs Really Works & Its Application to FR 3.6.10

> Background research for [spec.md](spec.md) / [plan.md](plan.md) (V3 — canvas-rendering + real-time OT). Not a spec, not an implementation plan — this is a synthesis of the technical knowledge behind the design decisions already locked in.
>
> 2026-10-01.

## 1. Why a Separate Research Doc Was Needed

FR 3.6.10 was originally understood as "a Google-Docs-style rich-text editor" — meaning an ordinary rich-text editor library (TipTap, already installed in `brandhub-web-dashboard`) running on `contentEditable`. Comparing that against how Google Docs actually works revealed the real architecture is fundamentally different — not a UI difference, but a difference in **how content is displayed and how data is synced**. This research captures that finding and the decisions that followed from it.

## 2. How the Real Google Docs Works

### 2.1 Display: Canvas, Not DOM

- Google Docs **does not use HTML/DOM to display text**. All content is drawn directly onto `<canvas>` elements — pixel-accurately.
- Reason: Google Docs is a print-accurate WYSIWYG tool (*What You See Is What You Get* — A4/A5 page sizing, correct page breaks). Ordinary HTML is prone to line-shift differences across browsers/machines/fonts → page-count errors when printing or exporting to PDF. Canvas gives pixel-level control.
- Before 2021, Google Docs still used a DOM-based architecture but **had already written its own layout/editing engine**, not relying on real `contentEditable` — it only faked the cursor with a `<div>` + CSS animation. From 2021 onward it fully migrated to canvas-based rendering (confirmed via public discussion from Google engineers on Hacker News).
- **Virtualization**: only a handful of `<canvas>` elements are created for the page(s) currently in the viewport. Scrolling reuses existing canvases to draw the new page's content, keeping hundred-page documents light. This is the standard windowing/virtualization pattern (similar to `react-window`), applied to canvas instead of a DOM list.

### 2.2 Input: Offscreen `contentEditable` + Fake Cursor

- Since the text is pixels drawn on a canvas, not DOM text nodes, ordinary keyboard/focus events cannot be used directly on the canvas.
- Google Docs uses a hidden `<iframe>` containing a `contenteditable` field, pushed off-screen (e.g. `translateX(-10000px)`) — solely to **capture keystrokes, IME input, and paste**. It displays nothing; it only receives input and forwards it into internal state.
- The blinking cursor is actually a `<div>` animated with CSS, positioned using pixel coordinates computed from the canvas text layout.
- Tables and text-selection highlighting are also drawn by the canvas itself — not via the native `window.getSelection()`.

### 2.3 Accessibility: A Parallel Hidden DOM Layer

- Screen readers cannot read pixels on a canvas.
- When accessibility mode is enabled, Google Docs quietly builds an additional hidden DOM region containing the real text, in parallel with the canvas, so screen readers can read it.

### 2.4 Data Sync: Operational Transformation (OT), Not "Saving a File"

- Google Docs **does not save/sync a document as a text blob overwritten on every save**. Every edit is a small **operation** (`insert`/`delete` at position X), written to a **revision log** — it never directly mutates the document's "characters."
- Core algorithm: a function usually written as `transform(opA, opB)` — takes two operations created against the same base state and returns adjusted versions that can be applied one after another while preserving both authors' intent.
- Example: you type "hello" at position 5, but someone else just deleted characters 2-4 → your operation is transformed: "insert at position 5" becomes "insert at position 3" (because two characters vanished before it).
- **Persistence**: periodic snapshots (the server stores one snapshot every few thousand operations) + the tail of the operation log — loading a document = the latest snapshot + replaying the remaining log, not a full replay from scratch every time.
- **Why OT was chosen**: the server already has to see every operation anyway, for access control, rendering, and storage — OT reuses that same data path instead of requiring a separate sync architecture.

### 2.5 Transport: Long Polling, Not WebSocket

- Google Docs uses **Long Polling** via an HTTP request named `bind` (called the *Browser Channel*) — not WebSocket, Server-Sent Events, or WebRTC.
- The main reason is historical: Google Docs began development around 2006 (as Writely), before WebSocket (standardized in 2011) existed. The Long Polling architecture was kept and incrementally optimized rather than rewritten.
- Edit data is pushed continuously in small chunks, combined with OT — only position-based edit commands are sent, never the whole file.

### 2.6 State & Internal Naming

- Document state is kept in RAM, organized into formatting segments called **"runs"**.
- When editing offline, Docs logs commands to `IndexedDB`, syncing once back online.
- Google Docs' internal codename is **"kix"** — visible through the `_kix` variable, CSS classes like `kix-editor`, `kix-canvas`, etc. (observed via DevTools, not official Google documentation).
- The client source is minified/bundled with the **Closure Compiler** into one enormous object with nearly 20,000 keys renamed/shortened — unrelated to the architecture, just a build/optimization detail.

## 3. Applying This to FR 3.6.10 — What Stays, What Changes

| Real Google Docs aspect | Decision for FR 3.6.10 | Reason |
|---|---|---|
| Canvas rendering | **Kept as-is** | This is the literal user requirement — reproduce the real technique, not just the same UI |
| Offscreen `contentEditable` input capture | **Kept as-is** | Required for the canvas to receive keystrokes/IME — no other way to do this on the current web platform |
| Fake CSS cursor | **Kept as-is** | A forced consequence of not using DOM text — there is no native cursor on a canvas |
| Viewport-based virtualization | **Kept as-is** | Standard pattern, low cost, clear benefit (long documents stay light) |
| Shadow/off-screen DOM for accessibility | **Kept as-is** | Mandatory for accessibility — no other option when using canvas |
| Operational Transformation (sync) | **Kept in principle**, but **considering CRDT (Yjs) instead of hand-written OT** | Hand-written OT at production quality is very hard (well-known edge cases that are notoriously hard to debug — see [plan.md §6](plan.md#6-technical-risks)). Yjs uses CRDT — a different algorithm, but the same goal (convergence with no data loss, no locking) — lower risk since it's already battle-tested in production (Figma, Notion use similar mechanisms) |
| Long Polling (Browser Channel `bind`) | **Changed to WebSocket** | The reason Google uses Long Polling is historical (2006, before WebSocket existed) — not a technical advantage worth preserving. WebSocket is the modern standard, Spring Boot already supports it (`spring-boot-starter-websocket`), with lower latency and simpler code |
| In-RAM "runs" state | **Equivalent**: `TaskContentOperation` (operation log) + `TaskContentSnapshot` | Different name, same principle: operation log + periodic snapshot, never saving full text on every save |
| IndexedDB offline queue | **Kept as-is** | Same need: the client must keep working while offline, syncing back on reconnect |
| Internal codename "kix", Closure Compiler | **Not relevant** | Google's internal build/implementation details, no bearing on the design |

## 4. Limitations of This Research

- The observations about `kix`, the hidden DOM structure, and the offscreen iframe are **external observations** (via DevTools, community technical write-ups, and public discussion from Google engineers) — not official architecture documentation from Google. Google has not published Docs' full source code or technical spec.
- Google's actual `transform()` algorithm (handling rich-text formatting, not just plain-text insert/delete) has not been published in detail — the OT design for rich text in `plan.md` will need to be designed independently; it cannot be copied from an original source.
- There is no real benchmark of latency/performance between Long Polling (the original) and WebSocket (the chosen replacement) in BrandHub's specific context — the decision is based on architectural reasoning (simpler, more modern), not on actual measurement.

## References

- [Google Docs will now use canvas based rendering — Hacker News discussion](https://news.ycombinator.com/item?id=27129858)
- [Google Docs will move to canvas based rendering instead of DOM](https://www.libhunt.com/posts/255745-google-docs-will-move-to-canvas-based-rendering-instead-of-dom)
- [Design Google Docs — CRDT & Operational Transformation](https://www.linkedin.com/pulse/design-google-docs-crdt-operational-transformation)
- [Operational transformation — Wikipedia](https://en.wikipedia.org/wiki/Operational_transformation)
- [Google Docs System Design — EnjoyAlgorithms](https://www.enjoyalgorithms.com/blog/design-google-docs/)
- [How Does Google Docs Work — The System Design Newsletter](https://newsletter.systemdesign.one/p/how-does-google-docs-work)
- [How Operational Transformation Powers Google Docs](https://levelop.dev/blog/google-docs-with-25m-concurrent-editors-conflict-resolution-architecture)
- [CRDTs vs. Operational Transformation: How Google Docs Handles Collaborative Editing](https://systemdr.systemdrd.com/p/crdts-vs-operational-transformation)
- A technical analysis write-up the user provided in conversation (2026-10-01) — describing canvas rendering, the offscreen iframe, the "kix" internal codename, the Long Polling `bind` endpoint, and the IndexedDB offline log.

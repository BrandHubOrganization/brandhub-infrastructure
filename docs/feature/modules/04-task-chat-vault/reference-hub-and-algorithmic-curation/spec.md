> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Smart Reference Hub, Shared Moodboard & Client-Side Algorithmic Curation Engine

| Field | Value |
| :--- | :--- |
| **Module Slug** | `reference-hub-and-algorithmic-curation` |
| **Category** | `04-task-chat-vault` — Task Workflow, Realtime Workspace Chat & Encrypted S3 Vault |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `smart-reference-hub`, `workspace-shared-moodboard`, `reference-preview-textrank`, `specialized-task-reference-rail`, `scene-broll-visual-pills`, `cross-modal-content-kit-pairing`, `dynamic-keyphrase-facet-clustering`, `cielab-color-harmony-matcher`, `duration-storyboard-broll-assigner`, `session-rocchio-mmr-reranker` |
| **Aligned SRS Domains** | [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.1–3.6.15`) · [3.7 AI Features](../../../srs/06-ai-features/README.md) (`3.7.1`, `3.7.6`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver an end-to-end, **0-Credit Content Research, Moodboard Curation & Deterministic Algorithmic Recommendation Layer** across BrandHub's Post Editor, Specialized Task Section Editors (`KOL`, `PRESS`, `EVENT`, `WORKSHOP`, `NEWSLETTER`, `SURVEY`), Video Script Storyboards, and Workspace Content Library — **strictly decoupled from core LLM/generative AI endpoints** so high-volume multi-provider API streams (`Pexels`, `Unsplash`, `Pixabay`, `Openverse`, `Wikimedia`, `VN_PRESS`, `GDELT`, `Wikipedia`, and `EXTERNAL` links) are classified, paired, color-matched, duration-aligned, and personalized in `< 5 ms` directly on structured API metadata.

Specifically, this module unifies:
1. **Multi-Source Reference Hub & Shared Moodboard (`WorkspaceReferenceController`):** Workspace/Campaign/Task-scoped discovery, URL unfurling with **TextRank Key Takeaways** (`extract_key_takeaways`), collaborative pinning, and `Owner` / `Manager` / `Client` `APPROVED` curation notes surfaced directly inside authoring tools.
2. **In-App Rich Reference Preview (`ReferencePreviewModal`) & Specialized Task Rail (`SimpleSectionEditorPage`):** Full reader/video/HD-photo preview modal with 1-click Brief/Section insertion across both social posts and all 6 non-post task editors, plus clean visual B-roll attachment pills on video script rows.
3. **Five Deterministic Client/Core Curation Algorithms (Zero LLM Cost, AI-Team Decoupled):**
   - **Algo 1 — Cross-Modal "Content Kit" Tripartite Pairing:** Pairs `[1 Editorial Article + 1 Still Visual + 1 Video B-roll]` via bilingual **BM25+ Cosine** + Weighted Tag Jaccard + Platform Aspect Bonus + **CIEDE2000 ($\Delta E_{00}$) Cross-Visual Harmony** into 1-click **"Ready-to-Use Content Kits"** (supported atomically in both `EditorPage` and `SimpleSectionEditorPage`).
   - **Algo 2 — Dynamic Keyphrase & Agglomerative Jaccard Facet Clustering:** Automatically groups large heterogeneous API result pools (in both `EditorInspirationPanel` and `WorkspaceMoodboardPanel` Discover mode) into 4–5 acronym-preserving sub-topic facets with live counts and a horizontal **Swimlanes ("Kệ chủ đề")** view.
   - **Algo 3 — Perceptual CIELAB ($\Delta E_{00}$ CIEDE2000) Color-Harmony & Carousel Cohesion Matcher:** Converts `dominantColor` HEX values into perceptual CIE $L^*a^*b^*$ space (`sRGB -> D65 XYZ -> Lab`) and applies **ISO/CIE CIEDE2000 ($\Delta E_{00}$)** to classify visual mood buckets and score multi-image **Carousel Cohesion** against selected post media and `APPROVED` Moodboard pins.
   - **Algo 4 — Global Beam-Viterbi Duration-Constrained Storyboard Sequence Assignment:** Parses per-scene target durations $\Delta t_k$ (`0-4s` $\rightarrow 4\text{s}$) in `VIDEO.SCRIPT` / `SHORT_VIDEO.SCRIPT` and runs **Beam-Viterbi Dynamic Programming ($B = 12$)** across the scene lattice to maximize global lexical fit, duration coverage ($\text{dur}_v \ge \Delta t_k$), and adjacent visual continuity ($\Delta E_{00}$ + aspect alignment) without greedy local traps.
   - **Algo 5 — Temporal-Decay Session Rocchio + MMR Re-Ranking & Explainable "More Like This":** Combines `APPROVED` Moodboard priors, recency-weighted positive session actions ($0.92^{\text{age}}$), and negative dismissals (`× Ẩn mẫu`) via a **Rocchio Relevance Feedback** preference vector + **Maximal Marginal Relevance ($\lambda = 0.78$)** diversity re-ranking with explainable boost tooltips and instant k-NN **"Tìm tương tự"** exploration.

## 2. User Stories

- As a `Creator`, when API providers return dozens of mixed articles, photos, and B-roll clips, I want the UI to automatically cluster them into clear sub-topics, pair them into ready-to-use `[Article + Photo + Video]` Content Kits, and adapt rankings to my session clicks and `APPROVED` Moodboard guidelines so I can assemble a post or press draft in 1 click without manually sifting through flat cards.
- As a `Creator` writing a multi-scene Video Script (`VIDEO.SCRIPT` or `SHORT_VIDEO.SCRIPT`), I want a 1-click **"Auto-Match B-roll for Full Script"** workflow that assigns non-duplicate clips matching each scene's exact duration (`durationSeconds`) and camera description into clean visual B-roll pills.
- As a `Creator` building a multi-photo Facebook/Instagram carousel, I want perceptual CIELAB color-mood filters and a **Carousel Cohesion Badge** indicating which candidate visuals harmonize with the photos already attached to my post.
- As an `Owner`, `Manager`, or `Client`, I want to pin external/discovered references onto the Campaign Moodboard, mark approved references as `APPROVED` with creative direction notes (`note`), and know that `Creator` immediately sees those `APPROVED` pins at the top of the Editor Reference Hub and inside specialized Task Editors.

## 3. Consolidated Acceptance Criteria

1. **Workspace Reference Hub, Shared Moodboard & Role Governance:**
   - `Owner`, `Manager`, `Creator`, and `Client` members of a Workspace can query `POST /api/v1/workspaces/{workspaceId}/references/recommend`, unfurl URLs via `POST /unfurl`, and list/pin items on `GET/POST /moodboard`.
   - Only `Owner`, `Manager`, and `Client` can transition `approvalStatus` (`PENDING <-> APPROVED`) on Moodboard pins; `Creator` sees `APPROVED` pins (with `approvedByName` and `note`) surfaced directly in a dedicated **"Đã chốt trên Moodboard"** strip inside `EditorInspirationPanel` and as positive priors in session re-ranking.
2. **In-App Preview Modal, Specialized Task Rail & Visual B-roll Pills:**
   - Clicking any reference card in `EditorInspirationPanel`, `WorkspaceMoodboardPanel`, `EditorTaskContextPanel`, `SceneBrollPopover`, or `SectionListField` opens `ReferencePreviewModal` displaying full video/image media or extracted article paragraphs + TextRank `keyTakeaways` with 1-click Brief/Section insertion.
   - `SimpleSectionEditorPage` (`kol-editor`, `press-editor`, `event-editor`, `workshop-editor`, `newsletter-editor`, `survey-editor`) provides a 3-tab right rail (`Xem trước` | `Tham khảo` | `Yêu cầu`).
   - Attaching B-roll to `VIDEO.SCRIPT` or `SHORT_VIDEO.SCRIPT` stores structured `row.brolls` (and auto-migrates legacy `[B-roll mẫu: ...]` text tags) rendered as interactive thumbnail/duration pills without polluting dialogue text.
3. **Algo 1 — Cross-Modal "Content Kit" Tripartite Pairing:**
   - When the candidate pool contains at least 2 distinct modalities (`ARTICLE`/`KNOWLEDGE`, `IMAGE`/`VECTOR`, `VIDEO`), `buildCrossModalContentKits` computes cross-modal affinity (TF-IDF Cosine + Tag Jaccard + Platform Aspect Bonus) and renders up to `3` **Content Kit** cards at the top of `EditorInspirationPanel` (when `mediaFilter === "ALL"`).
   - Clicking **"Dùng trọn bộ"** (`Apply Kit`) inserts the kit's visual asset(s) into Post Media (or section materials) and attaches the paired editorial source into Brief/Research in a single atomic UI action.
4. **Algo 2 — Dynamic Keyphrase & Jaccard Facet Clustering:**
   - `buildDynamicFacetClusters` extracts bilingual salient keyphrases from `tags`, `matchReasons`, and `title`, merges overlapping clusters ($J \ge 0.65$), and selects up to `5` high-coverage topic chips (`label + count`) plus a toggleable **Swimlanes ("Kệ chủ đề")** layout grouping cards into horizontal topic shelves.
   - When `mediaFilter === "ARTICLE"`, AI expanded query chips switch to Vietnamese/localized `expandedEditorialQueries` instead of English visual stock queries.
5. **Algo 3 — Perceptual CIELAB ($\Delta E$) Color-Harmony & Carousel Cohesion:**
   - `colorHarmony.ts` converts `dominantColor` HEX strings to CIE $L^*a^*b^*$ (`L`, `a`, `b`, Chroma `C`, Hue `hDeg`) to expose interactive **Color Mood Swatch** filters (`Tất cả màu`, `Hợp màu đang chọn`, `Ấm năng động`, `Sáng tối giản`, `Tối điện ảnh`, `Mát hiện đại`).
   - Visual cards display their `dominantColor` swatch dot; whenever reference palette anchors exist (from inserted post media colors or `APPROVED` Moodboard pins), visual cards with high perceptual harmony display a **`Hợp bộ màu · XX%`** cohesion badge.
6. **Algo 4 — Duration-Constrained Storyboard Sequence Assignment:**
   - In `SectionListField` (`name === "scenes"` and `!disabled`), a header button **"Tự ghép B-roll toàn kịch bản"** opens `StoryboardAutoAssignModal`, parses target seconds $\Delta t_k$ from each row's `time` cell, fetches a unified visual pool, and runs `assignStoryboardBrolls` to assign non-duplicate clips optimizing lexical fit ($0.50$), duration coverage ($0.30$), and adjacent visual continuity ($0.20$).
   - Users can cycle alternative clips per scene (`Đổi mẫu`) and click **"Áp dụng cho kịch bản"** to populate `row.brolls` across all matched scenes at once.
7. **Algo 5 — Session Implicit-Feedback Rocchio + MMR Re-Ranking & "More Like This":**
   - User interactions within the editor session (inserting media, saving to brief, pinning, previewing, or clicking `× Ẩn mẫu`) together with `APPROVED` Moodboard pins update the session preference vector $\vec{w}_{\text{user}}$ via Rocchio feedback and re-rank remaining items with MMR ($\lambda = 0.78$).
   - Clicking **"Tìm tương tự"** on a card or inside `ReferencePreviewModal` activates a k-NN similarity filter chip (`Tương tự: <Title>`) ranking the candidate pool by multi-feature cosine/Jaccard similarity to that seed item.
8. **Internationalization (`vi.json` + `en.json`):**
   - Every user-facing label, badge, cluster header, mood filter, storyboard dialog control, and toast message uses key-parallel translations under `editor.{inspiration,referencePreview,sceneBroll,sectionRail,contentKit,colorHarmony,storyboardAssign}.*` in `brandhub-web/src/i18n/locales/{vi,en}/editor.json` with 100% key parity (`i18nParityAudit.test.ts`) and zero hardcoded JSX strings.
9. **Light & Dark Mode + UI Craft & Accessibility (`DESIGN.md`, `baseline-ui`, `fixing-accessibility`):**
   - All surfaces, cards, pills, and modals use semantic CSS tokens (`bg-card`, `bg-background`, `bg-muted`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` variants, strictly respecting 1px borders (no `border-l-3/4/8`), zero multicolor gradients, `rounded-md` chips/badges (no bare `rounded`), `>= 28px` touch targets (`min-h-7` / `size-7`), structural `<Skeleton />` loading cards (`role="status" aria-busy="true"`), `aria-expanded` / `aria-controls` / `aria-pressed` semantics, `text-balance` / `text-pretty` typography, and `font-mono tabular-nums` on counts/durations/percentages (`designSystemCraftAudit.test.ts`).

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):**
  - `src/pages/editor/components/EditorInspirationPanel.tsx` (Approved Moodboard strip, Content Kit carousel, Dynamic Facet Cluster bar + Swimlanes toggle, CIELAB Mood Swatches, Rocchio/More-Like-This controls)
  - `src/pages/editor/index.tsx` (wires `onApplyContentKit`, selected media color anchors, and 1-click AI Caption seed handoff)
  - `src/components/reference-hub/ReferencePreviewModal.tsx` (Reader/Video/Image preview, TextRank Key Takeaways, `"Tìm tương tự"` trigger)
  - `src/components/reference-hub/WorkspaceMoodboardPanel.tsx` (Shared Moodboard pinning, `APPROVED` sign-off, curator notes)
  - `src/pages/tasks/components/SimpleSectionEditorPage.tsx` (3-tab right rail for `KOL`, `PRESS`, `EVENT`, `WORKSHOP`, `NEWSLETTER`, `SURVEY`)
  - `src/components/task-sections/{SectionListField,SceneBrollPopover,StoryboardAutoAssignModal}.tsx` (Visual B-roll pills, `9:16`/`16:9` orientation selector, whole-script Auto-Storyboard dialog)
  - `src/lib/referenceAlgorithms/{textSimilarity,colorHarmony,facetClustering,contentKitPairing,sessionRocchio,storyboardAssigner}.ts`
- **UI States:**
  - **Loading:** Deterministic spinner/skeleton states during initial candidate pool fetch or article unfurl.
  - **Empty / Narrow Filter:** Clear reset action when a combination of Facet Cluster + CIELAB Color Mood filter yields 0 items, without fabricating mock items.
  - **Adaptive / Active Feedback:** Dismissed items (`×`) fade out immediately; `"Tương tự: ..."` and `"Đã chốt Moodboard"` chips display active clearable badges.
  - **Offline / Fallback Resilience:** `referenceHubService.recommend` falls back gracefully to CORS-safe public providers (`Openverse`, `Wikimedia`, `Wikipedia`) if downstream discovery is temporarily unreachable, and all 5 client-side algorithms operate identically on fallback pools.

## 5. API, Messaging & Protocol Contract

| Route / Engine Boundary | Auth / Scope | Service / Module & Responsibility |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/references/recommend` | Bearer (`Owner, Manager, Creator, Client`) | `WorkspaceReferenceController` -> `WorkspaceReferenceService` -> multi-provider candidate pool (`ReferenceRecommendResult`) |
| `POST /api/v1/workspaces/{workspaceId}/references/unfurl` | Bearer (`Owner, Manager, Creator, Client`) | `WorkspaceReferenceController` -> article paragraphs + TextRank `keyTakeaways` (`ReferenceUnfurlResult`) |
| `GET/POST/PATCH/DELETE /api/v1/workspaces/{workspaceId}/references/moodboard/**` | Bearer (`Owner, Manager, Creator, Client`; `APPROVED` restricted to `Owner, Manager, Client`) | `WorkspaceReferenceController` -> MongoDB `workspace_moodboard_items` (`MoodboardItemDocument`) |
| `src/lib/referenceAlgorithms/*` | Client-Side Pure TS (`0` network calls, `< 5 ms`) | Tripartite Kit Pairing, Facet Clustering, CIELAB $\Delta E$ Harmony, Storyboard Sequence Assigner, Session Rocchio + MMR |

## 6. Error Handling, Security & Edge Cases

- **Cross-Tenant Isolation & Role Enforcement:** `WorkspaceReferenceService` validates Workspace membership before reading/mutating `workspace_moodboard_items`; `Creator` attempts to mutate `approvalStatus` are blocked both in UI (`canApprove`) and backend service checks (`403 FORBIDDEN`).
- **Missing Optional Metadata:** Items lacking `dominantColor` (e.g., `ARTICLE` or `WIKIMEDIA` clips) bypass color-bucket exclusion when `"ALL"` mood is active and receive neutral color weight (`0.5`) during sequence/kit scoring rather than throwing `NaN`.
- **Small / Single-Modality Pool:** When fewer than 2 modalities exist (e.g., user filters `VIDEO` only), `buildCrossModalContentKits` cleanly returns `[]` and hides the Content Kit shelf without empty placeholders.
- **Short / Unstructured Scene Durations:** Scenes with empty or non-numeric `time` strings default cleanly to $\Delta t_k = 5\text{s}$ in `parseSceneDurationSeconds`; if scenes outnumber unique candidate videos, remaining scenes fall back to best-matching still frames or remain unassigned rather than duplicating clips.

## 7. Related Specifications & References

- **Sibling Module:** [Five-State Inline Task Editing & Sectioned Specialized Editors](../task-subtask-and-inline-workflow/spec.md)
- **Aligned SRS Functional Requirements:** [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) · [3.7 AI Features](../../../srs/06-ai-features/README.md)
- **Rules & Craft Standards:** [Feature Workflow](../../../../rule/feature-workflow.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Complete 4-doc suite (`spec.md`, `plan.md`, `task.md`, `test.md`) committed in `brandhub-infrastructure`; all 5 algorithmic engines implemented in `src/lib/referenceAlgorithms/` and wired into `EditorInspirationPanel`, `EditorPage`, `ReferencePreviewModal`, `SimpleSectionEditorPage`, and `SectionListField`; 100% `vi`/`en` locale key parity; Light/Dark & Design System Craft audits green; all automated unit & algorithmic tests in [test.md](./test.md) passing.
- **Out of Scope:** Modifying LLM prompt pipelines or GPU workers owned by the AI team (`brandhub-ai-service` generative endpoints), paid stock licensing checkout, or de-scoped SRS features (livestreaming, Zalo OA, VNPay/Stripe, plagiarism scanning).

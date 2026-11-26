> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Implementation Checklist — Smart Reference Hub, Shared Moodboard & Client-Side Algorithmic Curation Engine (`reference-hub-and-algorithmic-curation`)

> Verifiable sequential task breakdown mapped to [spec.md](./spec.md) and [plan.md](./plan.md), covering baseline Reference Hub / Moodboard / Preview infrastructure and all 5 Client-Side Algorithmic × UI/UX engines.

## 1. Baseline Reference Hub, Shared Moodboard & Specialized Task Rail (Plan §1)

- [x] **T01 — Multi-Source Reference Hub & Moodboard Persistence:** Deliver `WorkspaceReferenceController.java`, `WorkspaceReferenceService.java`, and MongoDB `MoodboardItemDocument` (`workspace_moodboard_items`) enforcing canonical role permissions (`Owner, Manager, Creator, Client`; `APPROVED` restricted to `Owner, Manager, Client`).
- [x] **T02 — In-App Preview Modal & TextRank Takeaways:** Implement `ReferencePreviewModal.tsx` wired to `/references/unfurl` (`extract_key_takeaways`) with 1-click Brief insertion across `EditorInspirationPanel`, `WorkspaceMoodboardPanel`, and `EditorTaskContextPanel`.
- [x] **T03 — Specialized Task Right Rail (`SimpleSectionEditorPage`):** Add 3-tab right rail (`Xem trước` | `Tham khảo` | `Yêu cầu`) and section-aware 1-click source/takeaway insertion across `KOL`, `PRESS`, `EVENT`, `WORKSHOP`, `NEWSLETTER`, and `SURVEY` editors.
- [x] **T04 — Structured Visual B-roll Pills (`sceneBrollUtils` & `SectionListField`):** Replace raw `[B-roll mẫu: ...]` text clutter with interactive thumbnail/duration pills, backward-compatible parser, and `9:16`/`16:9` orientation selectors in `SceneBrollPopover`.

## 2. Client-Side Algorithmic Curation Library (`src/lib/referenceAlgorithms/` — Plan §2)

- [x] **T05 — Shared Bilingual IR Primitives (`textSimilarity.ts`):** Implement Vietnamese/English tokenizer, stopword filter, bigram extractor, TF-IDF Cosine Similarity, and Weighted Set Jaccard similarity.
- [x] **T06 — Algo 1: Cross-Modal "Content Kit" Tripartite Pairing (`contentKitPairing.ts`):** Partition candidate pools into `ARTICLE`/`IMAGE`/`VIDEO`, score cross-modal affinity + platform aspect fit, and run Greedy Maximum-Weight Tripartite Matching to produce up to `3` disjoint Content Kits.
- [x] **T07 — Algo 2: Dynamic Keyphrase & Jaccard Facet Clustering (`facetClustering.ts`):** Extract salient keyphrases, merge overlapping clusters ($J \ge 0.65$), and run Greedy Set Cover to output up to `5` high-coverage sub-topic facets.
- [x] **T08 — Algo 3: Perceptual CIELAB ($\Delta E$) Color-Harmony & Carousel Cohesion (`colorHarmony.ts`):** Implement `sRGB -> D65 XYZ -> CIE Lab` conversion, CIE76 $\Delta E$ perceptual distance, visual mood classification, and multi-photo Carousel Cohesion scoring.
- [x] **T09 — Algo 4: Duration-Constrained Storyboard Sequence Assigner (`storyboardAssigner.ts`):** Implement `parseSceneDurationSeconds` and non-repeating sequence assignment balancing lexical match ($0.50$), duration coverage ($0.30$), and adjacent visual continuity ($0.20$) with ranked per-scene alternatives.
- [x] **T10 — Algo 5: Session Rocchio Relevance Feedback + MMR Re-Ranking (`sessionRocchio.ts`):** Implement sparse feature encoding, Rocchio preference shift ($\vec{w}_{\text{user}}$) combining `APPROVED` Moodboard priors + session actions/dismissals, MMR ($\lambda = 0.78$) re-ranking, and k-NN `rankMoreLikeThis`.

## 3. Algorithmic UI / UX Integration Across Authoring Surfaces (Plan §3–§4)

- [x] **T11 — Approved Moodboard Strip & Content Kit Carousel (`EditorInspirationPanel` & `EditorPage`):** Surface `APPROVED` Moodboard pins (with curator `note` and `approvedByName`) at the top of `EditorInspirationPanel`, render the **Content Kit** shelf with **1-Click `"Dùng trọn bộ"`**, and add 1-click handoff from `ReferencePreviewModal` to `ContentCreatorAiPanel`.
- [x] **T12 — Dynamic Facet Chips, Swimlanes View & Localized Editorial Queries:** Render dynamic sub-topic cluster chips with live `tabular-nums` counts, add Grid vs. Swimlanes (`Kệ chủ đề`) layout toggle, and switch `ARTICLE` tab query chips to `expandedEditorialQueries`.
- [x] **T13 — CIELAB Mood Swatches & Carousel Cohesion Badges:** Render interactive Color Mood Swatches, `dominantColor` indicator dots on cards, and **`Hợp bộ màu · XX%`** badges anchored to selected post media colors + `APPROVED` Moodboard visuals.
- [x] **T14 — Rocchio Adaptive Controls (`"Tìm tương tự"` & `"Ẩn mẫu"`):** Wire `"Tìm tương tự"` (on cards and inside `ReferencePreviewModal`), `× Ẩn mẫu` negative feedback, and active filter clear pills.
- [x] **T15 — Whole-Script Auto-Storyboard Modal (`StoryboardAutoAssignModal` & `SectionListField`):** Add **"Tự ghép B-roll toàn kịch bản"** button above `VIDEO.SCRIPT` / `SHORT_VIDEO.SCRIPT` tables, displaying scene-by-scene duration-matched clips via Beam-Viterbi DP, 1-click alternative cycling (`Đổi mẫu`), in-place preview, and atomic apply across all scenes.
- [x] **T15a — Atomic Specialized Kit Application & Moodboard Discover Curation:** Support single-patch `onApplyContentKit` in `SimpleSectionEditorPage` and integrate Facet Clustering (`Algo 2`), CIEDE2000 Color Mood Swatches (`Algo 3`), and More-Like-This (`Algo 5`) into `WorkspaceMoodboardPanel` Discover mode.
- [x] **T15b — UI Skill Craft & Accessibility Polish (`baseline-ui`, `fixing-accessibility`, `DESIGN.md`):** Enforce $\ge 28\text{px}$ touch targets (`min-h-7`/`size-7`), eliminate multicolor gradients, render structural `<Skeleton />` loading cards (`role="status" aria-busy="true"`), and wire `aria-expanded` / `aria-controls` / `aria-pressed` across all interactive controls.

## 4. Internationalization (i18n) & Light/Dark Theme Craft (Plan §5)

- [x] **T16 — Update `vi/editor.json` + `en/editor.json` in Parallel:** Add all new translation keys under `editor.{inspiration,referencePreview,contentKit,colorHarmony,storyboardAssign,sceneBroll,sectionRail}.*` in both Vietnamese and English bundles with zero hardcoded JSX text.
- [x] **T17 — Audit Light/Dark Mode & Design System Craft:** Verify semantic tokens, `dark:` contrast, 1px border discipline, `rounded-md` chips/badges, and `font-mono tabular-nums` metrics.

## 5. Automated Verification & Master Index Sync (Plan §4–§5)

- [x] **T18 — Synchronize Infrastructure Feature Indexes:** Register `reference-hub-and-algorithmic-curation` in `04-task-chat-vault/README.md`, `modules/README.md`, and `feature/README.md`.
- [x] **T19 — Execute TypeScript, Craft, i18n Parity & Algorithmic Unit Suites:** Pass `npx tsc --noEmit` and Vitest suites verifying all 16 cases in [test.md](./test.md).

## 6. Lifecycle Artefact Traceability (`feature-workflow.md`)

| Workflow Stage | Artefact | Responsibility Verified |
| :--- | :--- | :--- |
| **Stage 1 — Business Specification** | [spec.md](./spec.md) | Canonical roles, 5 algorithmic × UX workflows, API contract, i18n (`vi`/`en`) & Light/Dark rules |
| **Stage 2 — Technical Plan** | [plan.md](./plan.md) | Mathematical invariants, touched files, data flow, rollout phases & mitigations |
| **Stage 3 — Implementation Checklist** | `task.md` (this file) | Sequential T01–T19 tasks across algorithmic library, editor UI, storyboard, i18n, and tests |
| **Stage 4 — Verification Matrix** | [test.md](./test.md) | 16-case Normal/Boundary/Algorithmic/Security/i18n/Theme verification matrix & CLI commands |

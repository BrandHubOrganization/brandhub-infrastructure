> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Smart Reference Hub, Shared Moodboard & Client-Side Algorithmic Curation Engine (`reference-hub-and-algorithmic-curation`)

## 1. System Components & Touched Repositories

Implements the end-to-end architecture defined in [spec.md](./spec.md) while strictly maintaining the architectural boundary with the AI team's LLM/GPU endpoints:

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/**` with JWT verification, header sanitization, and `X-Request-Id` propagation) |
| **Business Service (`brandhub-business-service`)** | `WorkspaceReferenceController.java`, `WorkspaceReferenceService.java`, `MoodboardItemDocument.java`, `MoodboardItemMongoRepository.java`, `CreateMoodboardPinRequest.java`, `UpdateMoodboardPinRequest.java`, `MoodboardItemResponse.java` |
| **Discovery & Unfurl Layer (`brandhub-ai-service` — Existing Read-Only Integration)** | `app/services/reference_hub/{providers,reranker,takeaways,models}.py` (multi-provider candidate retrieval & TextRank sentence extraction; untouched by client-side algorithmic upgrades) |
| **Persistence & Cache** | MongoDB `workspace_moodboard_items` (`idx_moodboard_ws_created`, `idx_moodboard_ws_campaign`); `TanStack Query` tenant-scoped client cache (`workspaceId`, `campaignId`, `taskId`) |
| **Client Algorithmic Engine (`brandhub-web/src/lib/referenceAlgorithms/`)** | `textSimilarity.ts`, `colorHarmony.ts`, `facetClustering.ts`, `contentKitPairing.ts`, `sessionRocchio.ts`, `storyboardAssigner.ts`, `index.ts` |
| **Web UI Surfaces (`brandhub-web`)** | `src/pages/editor/components/EditorInspirationPanel.tsx`, `src/pages/editor/index.tsx`, `src/components/reference-hub/{ReferencePreviewModal,WorkspaceMoodboardPanel}.tsx`, `src/pages/tasks/components/SimpleSectionEditorPage.tsx`, `src/components/task-sections/{SectionListField,SceneBrollPopover,StoryboardAutoAssignModal,sceneBrollUtils}.tsx` |
| **i18n & Theme Assets** | `src/i18n/locales/vi/editor.json` + `src/i18n/locales/en/editor.json` (`editor.{inspiration,referencePreview,sceneBroll,sectionRail,contentKit,colorHarmony,storyboardAssign}.*`); semantic Light/Dark CSS tokens |

## 2. Core Algorithmic Design & Mathematical Invariants

All 5 client-side algorithms operate as pure, deterministic, $O(N^2)$ or $O(K \cdot N)$ functions over bounded candidate pools ($N \le 60$) executing in `< 5 ms` on the main thread with zero external API latency:

1. **Shared Bilingual BM25+ IR Primitives (`textSimilarity.ts`):**
   - Normalizes Vietnamese/English strings via Unicode NFC + punctuation stripping, preserves domain acronyms (`AI`, `FPT`, `KOL`, `PR`, `STEM`, `UI/UX`), removes bilingual stopwords, extracts unigrams + salient bigrams, and computes **BM25+ ($k_1 = 1.5, b = 0.75, \delta = 0.5$)** L2-normalized Cosine Similarity $\cos(\vec{u}, \vec{v})$ alongside Set Jaccard $J(A, B) = \frac{|A \cap B|}{|A \cup B|}$.
2. **Algo 1 — Cross-Modal Tripartite "Content Kit" Pairing (`contentKitPairing.ts`):**
   - Partitions `ReferenceItem[]` into Editorial $A$ (`ARTICLE` | `KNOWLEDGE`), Still Visuals $I$ (`IMAGE` | `VECTOR`), and Motion $V$ (`VIDEO`).
   - Combines cross-modal BM25+ Cosine, Tag Jaccard, Platform Aspect Fit, AND **CIEDE2000 ($\Delta E_{00}$) Cross-Visual Color Harmony** between paired Image $i$ and Video $v$:
     $$W_{\text{triplet}}(a, i, v) = 0.42 \cdot W(a, i) + 0.38 \cdot W(a, v) + 0.20 \cdot \text{ColorHarmony}_{\Delta E_{00}}(i, v)$$
   - Runs **Greedy Maximum-Weight Tripartite Matching** enforcing strict asset disjointness across kits and atomic single-patch section application in both `EditorPage` and `SimpleSectionEditorPage`.
3. **Algo 2 — Dynamic Keyphrase & Jaccard Facet Clustering (`facetClustering.ts`):**
   - Extracts acronym-preserving candidate keyphrases from `item.tags` and title bigrams, filtering phrases covering $< 2$ or $> 85\%$ of the pool.
   - Scores candidate clusters by $|S_c| \cdot \ln(1.5 + \overline{\text{score}}_c)$, merges near-duplicate clusters ($J(S_a, S_b) \ge 0.65$), and runs **Greedy Set Cover** to output up to `5` orthogonal topic clusters (`FacetCluster[]`) powering both filter chips and horizontal **Swimlanes** across `EditorInspirationPanel` and `WorkspaceMoodboardPanel` Discover mode.
4. **Algo 3 — Perceptual CIELAB ($\Delta E_{00}$ CIEDE2000) Color-Harmony & Carousel Cohesion (`colorHarmony.ts`):**
   - Converts `#RRGGBB` `dominantColor` via gamma-decoded linear sRGB $\rightarrow$ D65 CIE XYZ $\rightarrow$ CIE $L^*a^*b^*$ ($L^*, C^*, h^\circ$) and implements the full **ISO/CIE CIEDE2000 ($\Delta E_{00}$)** color-difference metric (incorporating $S_L, S_C, S_H$ compensation and blue-region rotation $R_T$).
   - Classifies visuals into mood buckets (`WARM_VIBRANT`, `BRIGHT_MINIMAL`, `DARK_CINEMATIC`, `COOL_MODERN`) without multicolor UI gradients and scores **Carousel Cohesion** against active palette anchors.
5. **Algo 4 — Global Beam-Viterbi Duration-Constrained Storyboard Assignment (`storyboardAssigner.ts`):**
   - Parses `time` strings (`0-4s`, `4-10s`, `00:05 - 00:12`, `8s`) into $\Delta t_k \in [2, 90]$ seconds (default $5\text{s}$).
   - Solves **Beam-Viterbi Dynamic Programming ($B = 12$)** across scenes $k = 1 \dots K$, maintaining disjoint `usedIds` sets along every beam hypothesis to globally maximize:
     $$\sum_{k=1}^K \left[0.50 \cdot \text{LexicalMatch}(q_k, v_k) + 0.30 \cdot \text{DurationFit}(\Delta t_k, \text{dur}_{v_k}) + 0.20 \cdot \text{Continuity}_{\Delta E_{00}}(v_{k-1}, v_k)\right]$$
     avoiding greedy starvation when two scenes compete for the same clip.
6. **Algo 5 — Temporal-Decay Session Rocchio + Explainable MMR Re-Ranking (`sessionRocchio.ts`):**
   - Weights session interactions with recency decay $\omega_{\text{eff}} = \omega_{\text{action}} \cdot 0.92^{\text{age}}$ alongside `APPROVED` Moodboard priors ($\omega = 1.2$), computes $\vec{w}_{\text{user}} = 0.75 \cdot \overline{\vec{f}(P)} - 0.55 \cdot \overline{\vec{f}(N)}$, re-ranks via **MMR ($\lambda = 0.78$)**, and emits explainable boost reasons (`boostReasons`) plus k-NN `rankMoreLikeThis`.

## 3. End-to-End Data & Control Flow

1. **Candidate Pool & Moodboard Fetch:** `EditorInspirationPanel` queries `(workspaceId, taskId, campaignId)` via `referenceHubService.recommend` AND fetches `APPROVED` Moodboard pins via `referenceHubService.listMoodboard(workspaceId, { campaignId, approvedOnly: true })` under tenant-scoped `TanStack Query` keys.
2. **Client Algorithmic Pipeline:** Raw `ReferenceItem[]` flows through `sessionRocchio` (incorporating `APPROVED` Moodboard priors + session interactions) $\rightarrow$ `colorHarmony` (annotating CIELAB mood & Carousel Cohesion) $\rightarrow$ `facetClustering` (deriving dynamic topic chips & swimlanes) $\rightarrow$ `contentKitPairing` (assembling top cross-modal kits).
3. **1-Click Action Execution:**
   - **Post Editor (`EditorPage`):** Applying a Content Kit inserts visual media into `MediaDropzone` (recording its `dominantColor` as a Carousel Cohesion anchor) and appends editorial source/summary into `POST.BRIEF` (or `VIDEO.SCRIPT`), with optional 1-click handoff to `ContentCreatorAiPanel`.
   - **Specialized Section Editors (`SimpleSectionEditorPage`):** Right-rail Reference Hub attaches items directly into `PRESS.COVERAGE`, asset chip lists, or active `richtext` fields.
   - **Video Script Storyboard (`SectionListField`):** `StoryboardAutoAssignModal` fetches a broad visual pool for the script, runs `assignStoryboardBrolls`, previews the full scene-by-scene assignment, and writes structured `row.brolls` visual pills across all scenes on confirm.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Core Algorithmic Library (`src/lib/referenceAlgorithms/`):** Implement `textSimilarity.ts`, `colorHarmony.ts`, `facetClustering.ts`, `contentKitPairing.ts`, `sessionRocchio.ts`, and `storyboardAssigner.ts` as pure typed modules.
2. **Phase 2 — Editor Reference Hub UX Upgrade (`EditorInspirationPanel` & `EditorPage`):** Wire Approved Moodboard strip, Cross-Modal Content Kit cards (`Algo 1`), Dynamic Facet Chips + Swimlanes toggle + localized editorial query chips (`Algo 2`), CIELAB Mood Swatches + Carousel Cohesion badges (`Algo 3`), and Rocchio re-ranking + `"Tìm tương tự"` / `"Ẩn mẫu"` (`Algo 5`).
3. **Phase 3 — Whole-Script Auto-Storyboard (`StoryboardAutoAssignModal` & `SectionListField`):** Deliver 1-click duration-constrained B-roll sequence assignment (`Algo 4`) with per-scene alternative cycling and `ReferencePreviewModal` integration.
4. **Phase 4 — Key-Parallel Localization (`vi`/`en`) & Light/Dark Craft Audit:** Populate all new keys in `src/i18n/locales/vi/editor.json` and `src/i18n/locales/en/editor.json` simultaneously and verify 1px borders, `rounded-md` chips, `tabular-nums`, and dark-mode contrast.
5. **Phase 5 — Automated Verification Matrix:** Write and execute unit + algorithmic + UI SSR suites covering all test cases in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new label in `src/i18n/locales/vi/editor.json` and `src/i18n/locales/en/editor.json` (`editor.inspiration.*`, `editor.contentKit.*`, `editor.colorHarmony.*`, `editor.storyboardAssign.*`, `editor.sceneBroll.*`, `editor.sectionRail.*`) is updated atomically in both languages and gated by `tests/unit/i18nParityAudit.test.ts`.
- **Light & Dark Theme Architecture:** Uses semantic surface/text/border CSS variables (`bg-card`, `bg-muted/40`, `border-border`, `text-foreground`, `text-muted-foreground`) with paired `dark:` classes for status/cohesion badges (`text-emerald-700 dark:text-emerald-300`), verified by `tests/unit/designSystemCraftAudit.test.ts`.

## 6. Engineering Risks & Mitigations

- **Main-Thread Latency on Large Pools:** Bounded pool size ($N \le 60$) and memoized (`useMemo`) pure functions guarantee `< 5 ms` execution per state change without blocking keystrokes.
- **Over-Filtering Dead Ends:** Combining a narrow Facet Cluster with a strict Color Mood can yield 0 items; the empty state provides a 1-click **"Xoá bộ lọc phụ"** button that resets sub-filters while preserving the user's search query.

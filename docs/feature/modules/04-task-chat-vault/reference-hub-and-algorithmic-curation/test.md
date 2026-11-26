> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Verification & Test Suite — Smart Reference Hub, Shared Moodboard & Client-Side Algorithmic Curation Engine (`reference-hub-and-algorithmic-curation`)

> Consolidated verification matrix covering Normal, Algorithmic Invariants, Boundary, Security, i18n (`vi`/`en`), and Light/Dark Craft acceptance criteria for [spec.md](./spec.md) (`Owner, Manager, Creator, Client`).

## 1. Automated Verification Summary

| Test Tier | Tooling / Runner | Verified Components | Status |
| :--- | :--- | :--- | :---: |
| **Algorithmic Engine Unit Suite** | Vitest (`tests/unit/referenceAlgorithms.test.tsx`) | `textSimilarity.ts`, `contentKitPairing.ts`, `facetClustering.ts`, `colorHarmony.ts`, `storyboardAssigner.ts`, `sessionRocchio.ts` | **Passed** |
| **Reference Hub, Moodboard & Preview SSR** | Vitest (`referenceHubAndMoodboard.test.tsx`, `referencePreviewModal.test.tsx`) | `EditorInspirationPanel.tsx`, `WorkspaceMoodboardPanel.tsx`, `ReferencePreviewModal.tsx`, `EditorTaskContextPanel.tsx` | **Passed** |
| **Specialized Section Rail & Storyboard B-roll** | Vitest (`sectionRailAndSceneBroll.test.tsx`) | `SimpleSectionEditorPage.tsx`, `SectionListField.tsx`, `SceneBrollPopover.tsx`, `StoryboardAutoAssignModal.tsx`, `sceneBrollUtils.ts` | **Passed** |
| **Unfurl & TextRank Takeaways** | `pytest` (`brandhub-ai-service/tests/test_reference_hub.py`) | `takeaways.py` (`extract_key_takeaways`), `providers.py` (`unfurl_external_url`) | **Passed** |
| **i18n Parity & Design System Craft** | Vitest (`i18nParityAudit.test.ts`, `designSystemCraftAudit.test.ts`) | `src/i18n/locales/{vi,en}/editor.json`, 1px borders, `rounded-md` chips, `tabular-nums` | **Passed** |

## 2. Acceptance & Regression Test Matrix (16 Cases)

| ID | Category | Scenario | Precondition / Input | Expected Result | Status |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `R01` | Normal / Algo 1 | Cross-Modal Content Kit pairing | Mixed pool of `ARTICLE`, `IMAGE`, and `VIDEO` items sharing topic tags | `buildCrossModalContentKits` produces $\le 3$ disjoint kits pairing matching article + photo + video; clicking `Dùng trọn bộ` populates Media + Brief in 1 click | Pass |
| `R02` | Normal / Algo 2 | Dynamic Keyphrase Facet Clustering & Swimlanes | Heterogeneous pool of $\ge 8$ items across multiple sub-topics | `buildDynamicFacetClusters` merges redundant tags ($J \ge 0.65$) and outputs up to 5 high-coverage facet chips + functional Swimlane shelves | Pass |
| `R03` | Normal / Algo 3 | CIELAB ($\Delta E_{00}$ CIEDE2000) Color-Harmony & Carousel Cohesion | Visual items with `dominantColor` HEX + selected post media anchor `#F05A28` | `hexToLab`, `deltaE2000`, & `computeCarouselCohesion` score perceptual $\Delta E_{00}$ / hue harmony accurately, surfacing `Hợp màu · XX%` badges on harmonious visuals | Pass |
| `R04` | Normal / Algo 4 | Global Beam-Viterbi Storyboard Sequence Assignment | Competing 2-scene / 4-scene `VIDEO.SCRIPT` where greedy choice would starve Scene 2 | `assignStoryboardBrolls` solves Beam-Viterbi DP ($B=12$) maximizing global sequence score without greedy local starvation or duplicate clips | Pass |
| `R05` | Normal / Algo 5 | Session Rocchio Feedback + Approved Moodboard Boost | `APPROVED` Moodboard pin + user clicks `Dùng Media` on `#campus` item and dismisses `#retro` item | `rerankWithSessionRocchio` boosts `#campus` / Moodboard-aligned items to top via MMR ($\lambda = 0.78$) and excludes dismissed `#retro` item | Pass |
| `R06` | Normal / Algo 5 | 1-Click `"Tìm tương tự"` (More Like This) | User clicks `Tìm tương tự` on a card or inside `ReferencePreviewModal` | `rankMoreLikeThis` filters/orders candidate pool by multi-feature similarity to seed item with clearable active badge | Pass |
| `R07` | Normal | Approved Moodboard strip in Editor & Specialized Rail | `Manager` or `Client` marks Moodboard pin `APPROVED` with `note` | `EditorInspirationPanel` (both in `EditorPage` and `SimpleSectionEditorPage`) displays the approved pin + `note` at top | Pass |
| `R08` | Normal | TextRank Preview Modal & AI Caption Handoff | Click article card -> `ReferencePreviewModal` | Displays extracted paragraphs + `keyTakeaways`, supports 1-click Brief insertion and 1-click handoff to `ContentCreatorAiPanel` | Pass |
| `R09` | Boundary | Single-modality or tiny pool ($N \le 1$) | Filter set to `VIDEO` only or 0/1 item returned | `buildCrossModalContentKits` returns `[]` cleanly; no `NaN`, division-by-zero, or empty broken shelves | Pass |
| `R10` | Boundary | Missing `dominantColor` or unstructured scene `time` | `ARTICLE` / `WIKIMEDIA` item without HEX color; scene `time = ""` | Neutral color handling without crash; `parseSceneDurationSeconds("")` defaults cleanly to `5s` | Pass |
| `R11` | Boundary | Backward-compatible legacy `[B-roll mẫu: ...]` migration | Scene row containing legacy inline `[B-roll mẫu: Title — https://...]` | `extractSceneBrolls` strips raw URL from textarea and renders structured visual B-roll pill cleanly | Pass |
| `R12` | Security | Canonical role gate on Moodboard `APPROVED` | `Creator` vs `Owner`/`Manager`/`Client` viewing `WorkspaceMoodboardPanel` | Approve toggle rendered and permitted exclusively for `Owner`, `Manager`, and `Client`; `Creator` restricted to pin/view | Pass |
| `R13` | Security | Cross-tenant cache & API isolation | Switch `workspaceId` in router/store | All `TanStack Query` keys (`editor-reference-hub`, `workspace-moodboard`, `scene-broll-suggest`) scope strictly by `workspaceId` | Pass |
| `R14` | Resilience | Public zero-key fallback when backend discovery offline | Simulated upstream timeout / `503` on `/references/recommend` | `fallbackPublicRecommend` serves CORS-safe `Openverse`/`Wikimedia`/`Wikipedia` items and all 5 client algorithms run seamlessly | Pass |
| `R15` | i18n | `VI` <-> `EN` key-parallel localization | Run `i18nParityAudit.test.ts` and switch language `vi` <-> `en` | 100% key parity across `vi/editor.json` & `en/editor.json`; `ARTICLE` query chips use localized `expandedEditorialQueries` | Pass |
| `R16` | Theme & Craft | `Light` <-> `Dark` mode & Design System Craft | Run `designSystemCraftAudit.test.ts` across all modified files | Semantic tokens pass Light/Dark contrast; strictly 1px borders, `rounded-md` chips, and `font-mono tabular-nums` metrics | Pass |

## 3. Test Isolation & Reproducible CLI Commands

```powershell
# Web TypeScript & Algorithmic + UI + i18n + Craft verification (brandhub-web)
Set-Location "d:\ProjectCode\BrandHub\brandhub-web"
npx tsc --noEmit
npx vitest run tests/unit/referenceAlgorithms.test.tsx tests/unit/referenceHubAndMoodboard.test.tsx tests/unit/referencePreviewModal.test.tsx tests/unit/sectionRailAndSceneBroll.test.tsx tests/unit/i18nParityAudit.test.ts tests/unit/designSystemCraftAudit.test.ts

# Unfurl & TextRank Takeaways unit verification (brandhub-ai-service)
Set-Location "d:\ProjectCode\BrandHub\brandhub-ai-service"
.\.venv\Scripts\python.exe -m pytest tests/test_reference_hub.py -p no:cacheprovider -v
```

## 4. Sign-Off Checklist

- [x] All 5 Client-Side Algorithmic × UI/UX engines (`ContentKit`, `FacetClustering`, `CIELAB Harmony`, `StoryboardAssigner`, `SessionRocchio`) implemented and verified without modifying AI-team LLM endpoints.
- [x] Strictly enforces the 6 canonical system roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
- [x] Key-parallel `vi/editor.json` + `en/editor.json` localization and Light/Dark semantic token craft verified (`0` errors).

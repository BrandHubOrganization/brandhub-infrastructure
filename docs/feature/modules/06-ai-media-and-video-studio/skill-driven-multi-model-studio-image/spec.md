> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Skill-Driven Multi-Model Studio Image Pipeline (`agy` + `codex` + Qwen Worker)

| Field | Value |
| :--- | :--- |
| **Module Slug** | `skill-driven-multi-model-studio-image` |
| **Category** | `06-ai-media-and-video-studio` — AI Commercial Image, Product Video & Conversational Video Studio |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` (`Guest` → `401`; `Client` / `Admin` outside studio scope → `403`) |
| **Aligned SRS Domains** | [FR 3.7.7 — Generate Ambassador](../../../srs/06-ai-features/3-7-7-generate-ambassador/spec.md) · [FR 3.7.8 — View Image Style Template](../../../srs/06-ai-features/3-7-8-view-image-style-template/spec.md) · [FR 3.7.9 — Generate Image](../../../srs/06-ai-features/3-7-9-generate-image/spec.md) |
| **Related Module** | [Commercial Image & Qwen Ambassador](../commercial-image-and-qwen-ambassador/spec.md) |
| **Status** | Proposed — Ready for Implementation |

---

## 1. Objective & Architectural Motivation

Deliver a unified, production-ready, skill-driven image generation and composition pipeline in `brandhub-ai-service` that runs **alongside** (without replacing) the existing Vast.ai **Qwen Image 2.1 ComfyUI** GPU worker:

1. **Creative Orchestration + Multi-Model Image Generation (`agy` & `codex`):**
   - **Antigravity CLI (`agy`)**: Uses `AGY_MODEL=gemini-4-neon-low` as the Creative Director orchestrator to refine prompts with BrandHub domain skills and dispatches to `AGY_IMG=gemini-3.8-flash-low` (`image-generator`) for fast, high-fidelity generation (`~30–40s`).
   - **Codex OAuth (`codex`)**: Uses `GPT_MODEL=gpt-6-sol-light` (mapped to `model="gpt-6-sol"` with `reasoning.effort="low"` on the Codex Responses endpoint) as the Creative Director orchestrator, dispatching `image_generation` to `GPT_IMG_FAST=gpt-image-2.6-flare` (fast daily/layout iteration) or `GPT_IMG_NOR=gpt-image-2.6-sunburst` (high-detail commercial visuals), with real progressive `partial_image_b64` streaming.
2. **Zero-Turn Python Skill Injection (9 Studio Skills + Creative Director):**
   - Stores 10 modular skills in `brandhub-ai-service/.agents/skills/` (`agency-creative-director` + 9 specialized skills). Python reads and injects `agency-creative-director/SKILL.md` + the matched task `SKILL.md` + workspace `brand_context` directly into the first orchestrator turn so quality rises sharply without paying 15–25s of multi-turn disk reads.
3. **Complete Qwen Studio Workflow Coverage (`wf2` & `wf3`):**
   - Wires the missing Vast.ai Qwen worker endpoints (`/api/v1/wf2/pose_match` and `/api/v1/wf3/outfit_change`) into `brandhub-ai-service` and `brandhub-business-service` so `pose-match` and `virtual-tryon` no longer detour through 3-image `wf1_ad_composer`.
4. **Studio Node `model` + `effort` Controls & KSampler Progress UX:**
   - Adds `model` and `effort` selectors to Studio nodes (`StudioNodeInspectorDock.tsx` & `StudioSimpleMode.tsx`) and renders a ComfyUI **KSampler-style** multi-step progress visualizer on `outputNode` and the Simple Mode output panel.
5. **Hybrid S3 / Local Storage:**
   - Reuses `app/services/image/storage_service.py` (`store_generated_image`) across all providers, supporting EC2 IAM Instance Profile (IMDSv2) S3 in production and automatic `/static/generated/` fallback locally.

---

## 2. Approaches Considered & Design Decisions

| Approach | Summary | Tradeoff | Decision |
| :--- | :--- | :--- | :--- |
| **A. Python Zero-Turn Skill Injection + Hybrid Coexisting Providers** | Python pre-loads `agency-creative-director` + task `SKILL.md` + workspace brand context into the single orchestrator call; `agy`, `codex`, and `qwen-studio` coexist behind `studio_image.py` + `storage_service.py`. | Slightly larger single-turn system prompt (~2–3K tokens), zero extra tool turns. | **Selected** |
| **B. Multi-Turn CLI Skill Discovery** | Let `agy`/`codex` run shell/file tools to browse `.agents/skills/` on each request. | Adds 15–25s latency and unpredictable sandbox permission retries. | Rejected |
| **C. Replace Vast.ai Qwen Completely** | Route everything to `agy`/`codex` and drop ComfyUI. | Loses deterministic ComfyUI LoRA + exact pixel-preserving product/pose/outfit locking when GPU worker is online. | Rejected |

### Architect's Default Calls (Confirm with Product Owner)
- **Studio Node `model` Options (`StudioModelId`):** `auto` (default — uses `AI_IMAGE_PROVIDER` / `qwen-studio` fallback), `qwen-studio`, `agy`, `gpt-image-2.6-flare`, `gpt-image-2.6-sunburst`. Availability is fetched dynamically from `GET /api/v1/ai/image/models` so unavailable providers are disabled with a clear reason.
- **Studio Node `effort` Options (`StudioEffortLevel`):** `low` (default, `~25–40s`), `medium` (`~40–60s`), `high` (`~55–80s`). Maps to `reasoning.effort` on `gpt-6-sol` (`codex`), `AGY_IMG=gemini-3.8-flash-low` (`low` fast pass) vs `AGY_MODEL=gemini-4-neon-low` (`medium`/`high` skill-enriched) on `agy`, and `steps` (`20`/`25`/`32`) on `qwen-studio`.
- **Multi-Reference Guard:** `qwen-studio`, `gpt-image-2.6-flare`, and `gpt-image-2.6-sunburst` accept 1–3 reference images directly; when `agy` is selected for a multi-image workflow (`ad-composer`, `pose-match`, `virtual-tryon`), the UI shows a non-blocking hint that `agy` synthesizes via prompt direction rather than pixel-exact LoRA locking.

---

## 3. Nine Active Skills + Creative Director Mapping

All skill files live in `brandhub-ai-service/.agents/skills/`:

| Folder | Role | Injected When |
| :--- | :--- | :--- |
| `agency-creative-director/` (`SKILL.md` + `references/`) | Master Art Director & prompt synthesizer | **Always** injected as base system directive |
| `product-posing/` | Subject-product interaction & hand/grip realism | `ad-composer`, product showcase prompts |
| `virtual-try-on/` | Garment fit, fabric drape, body-contour realism | `virtual-tryon`, `wf3_outfit_change` |
| `outfit-replacement/` | Clean apparel swap preserving face & pose | `virtual-tryon`, color/outfit `refine` |
| `pose-director/` | Skeletal alignment, camera angle, framing | `pose-match`, `wf2_pose_match` |
| `product-photography/` | Studio lighting, surface reflections, packaging fidelity | Product-only or commercial packshots |
| `background-replacement/` | Seamless scene/environment compositing & light match | `ad-composer`, background `refine` |
| `advertising-key-visual/` | Hero campaign composition, negative space, focal hierarchy | Key-visual / campaign banner requests |
| `commercial-retouching/` | Skin/texture polish, color grading, artifact removal | `refine` mode & `high` effort commercial output |
| `brand-consistency/` | Enforces workspace palette, tone, mood & visual identity | **Always** when workspace `brand_context` exists |

---

## 4. Environment Configuration Contract

```env
# Primary image provider for unified Studio endpoint: agy | codex | auto
AI_IMAGE_PROVIDER=agy

# Antigravity CLI (agy)
AGY_CLI_PATH=
AGY_MODEL=gemini-4-neon-low
AGY_IMG=gemini-3.8-flash-low
AGY_TIMEOUT_SECONDS=120
AGY_MAX_CONCURRENCY=1

# Codex OAuth Image Provider
CODEX_OAUTH_ACCESS_TOKEN=
CODEX_AUTH_JSON_PATH=
GPT_MODEL=gpt-6-sol-light
GPT_IMG_FAST=gpt-image-2.6-flare
GPT_IMG_NOR=gpt-image-2.6-sunburst
CODEX_TIMEOUT_SECONDS=180
```

---

## 5. Mandatory UI/UX, i18n (`vi` + `en`) & Light/Dark Mode Requirements

1. **Internationalization (`vi.json` + `en.json` key-parallel):**
   - Every new UI label, model name, effort option, skill badge, KSampler stage title, and error message MUST be added simultaneously to `brandhub-web/src/i18n/locales/vi/aiStudio.json` and `brandhub-web/src/i18n/locales/en/aiStudio.json` under:
     - `aiStudio.studio.models.*` (`label`, `auto`, `qwenStudio`, `agy`, `gptFlare`, `gptSunburst`, `unavailableHint`, `approxRefHint`)
     - `aiStudio.studio.effort.*` (`label`, `low`, `medium`, `high`)
     - `aiStudio.studio.ksampler.*` (`title`, `stageOrchestrating`, `stageComposing`, `stageSampling`, `stageStoring`, `stageCompleted`, `expandedPrompt`, `stepLabel`)
   - Zero hardcoded Vietnamese or English strings in JSX/TSX.
2. **Light & Dark Mode Compliance:**
   - All new node controls, effort pills, and `KSamplerOutputPreview` cards MUST use semantic Tailwind tokens (`bg-card`, `bg-muted/40`, `text-foreground`, `text-muted-foreground`, `border-border`, `text-brand-orange`, `bg-brand-orange`) and `dark:` variants passing WCAG AA contrast in both Light and Dark themes.
3. **UI States:**
   - **Idle:** Shows selected `model` + `effort` badges cleanly on `generatorNode` / `modelNode` without text truncation.
   - **Streaming / Sampling:** Displays 4-stage KSampler node progress, live elapsed timer, real expanded prompt snippet, and progressive `preview_image` frames (real `partial_image_b64` for Codex; animated denoise canvas for `agy`/`qwen-studio`).
   - **Completed:** Displays final sharp image, progressive denoise strip, provider/model/effort metadata, and standard actions (`Save to Library`, `Write Post`, `Attach to Task`).
   - **Error:** Clear localized banner (`400/401/422/429/502/503`) with credit hold released automatically.

---

## 6. API Contract

| Route | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/ai/image/models` | Bearer (`Owner, Manager, Creator`) | `AiGenerationController` → `studio_image.py` (`GET /api/v2/ai/image/models`) |
| `POST /api/v1/ai/image/studio/generate` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiGenerationController` → `AiCreditGenerationService` → `studio_image.py` (`POST /api/v2/ai/image/studio/generate`) |
| `POST /api/v1/ai/image/studio/generate/stream` | Bearer (`Owner, Manager, Creator`) | Gateway → `AiGenerationController` SSE proxy → `studio_image.py` (`POST /api/v2/ai/image/studio/generate/stream`) |
| `POST /api/v1/ai/image/pose-match` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiGenerationController` → `studio_image.py` → `QwenAmbassadorClient.pose_match` (`wf2_pose_match.json`) |
| `POST /api/v1/ai/image/virtual-try-on` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiGenerationController` → `studio_image.py` → `QwenAmbassadorClient.virtual_try_on` (`wf3_outfit_change.json`) |

---

## 7. Error Handling, Security & Edge Cases

- **Secret Hygiene:** Never log `CODEX_OAUTH_ACCESS_TOKEN`, `~/.codex/auth.json`, or `agy` keyring contents; redact tokens in all structured logs.
- **Brain Temp Cleanup (`agy`):** Always delete `~/.gemini/antigravity-cli/brain/<parent_conv_id>` and `<subagent_conv_id>` in `finally` immediately after reading image bytes into memory.
- **Credit Safety:** Reserve `1` credit unit only after input/safety validation passes; release hold immediately on upstream `4xx/5xx/timeout` or client abort.
- **Concurrency & RAM Guard (`mem_limit: 3g`):** Enforce `asyncio.Semaphore(AGY_MAX_CONCURRENCY)` (default `1`) on `agy` subprocesses so EC2 `brandhub-ai` never OOMs alongside PhoBERT/embeddings.

---

## 8. Out of Scope (Deferred)

- `logo-designer/SKILL.md` and `wf4_logo_product.json` (Brand Logo placement workflow — explicitly deferred to a follow-up phase).

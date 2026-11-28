> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Implementation Checklist — Skill-Driven Multi-Model Studio Image Pipeline (`skill-driven-multi-model-studio-image`)

> Verifiable sequential task breakdown mapped to [spec.md](./spec.md) and [plan.md](./plan.md).

## 1. Skills Library & Config Baseline (Plan §4 Phase 1)

- [x] **T01 — Author `agency-creative-director` + 9 Studio Skills (`brandhub-ai-service/.agents/skills/`):** Create `SKILL.md` (and `references/` for `agency-creative-director`) for `agency-creative-director`, `product-posing`, `virtual-try-on`, `outfit-replacement`, `pose-director`, `product-photography`, `background-replacement`, `advertising-key-visual`, `commercial-retouching`, and `brand-consistency` (defer `logo-designer`).
- [x] **T02 — Update Settings & Env Template (`brandhub-ai-service`):** Add `ai_image_provider`, `agy_cli_path`, `agy_model`, `agy_img`, `agy_timeout_seconds`, `agy_max_concurrency`, `codex_oauth_access_token`, `codex_auth_json_path`, `gpt_model`, `gpt_img_fast`, `gpt_img_nor`, `codex_timeout_seconds` to `app/core/config.py` and `.env.example`.
- [x] **T03 — Fix Hybrid S3 IMDSv2 Detection (`storage_service.py`):** Update `is_s3_configured()` to detect EC2 Instance Profile credentials via `boto3.Session().get_credentials()` when `STORAGE_BACKEND=s3` (or `auto` with `S3_BUCKET_NAME`), preserving Zero-S3 `/static/generated/` fallback locally.

## 2. Core Providers, Skill Loader & Qwen Workflows (Plan §4 Phase 2)

- [x] **T04 — Implement `skill_loader.py`:** Build cached zero-turn loader combining `agency-creative-director/SKILL.md` + task-matched `SKILL.md` + optional workspace `brand_context` into a bounded Creative Director prompt block.
- [x] **T05 — Implement `agy_provider.py`:** Implement cross-platform `agy` runner (`agy.exe` / `agy`), `asyncio.Semaphore(AGY_MAX_CONCURRENCY)`, `effort`-based routing (`gemini-3.8-flash-low` vs `gemini-4-neon-low`), `stream-json` + `transcript.jsonl` stage events, JPEG EOI early capture, and `finally` cleanup of `<parent_conv_id>` and `<subagent_conv_id>`.
- [x] **T06 — Implement `codex_provider.py`:** Implement async `httpx` SSE client for `chatgpt.com/backend-api/codex/responses` mapping `gpt-6-sol-light` → `model="gpt-6-sol"` + `reasoning.effort`, `gpt-image-2.6-flare` / `gpt-image-2.6-sunburst`, up to 3 reference images, and real `partial_image_b64` streaming frames.
- [x] **T07 — Wire Missing Qwen Worker Endpoints (`qwen_ambassador_client.py`):** Add `pose_match()` (`/api/v1/wf2/pose_match`) and `virtual_try_on()` (`/api/v1/wf3/outfit_change`), keeping `wf4_logo_product` out of scope.

## 3. FastAPI & Business Service Contracts (Plan §4 Phase 3)

- [x] **T08 — Create `studio_image.py` & Register in `main.py`:** Implement `GET /api/v2/ai/image/models`, `POST /api/v2/ai/image/studio/generate`, `POST /api/v2/ai/image/studio/generate/stream` (SSE with `X-Accel-Buffering: no`), `POST /api/v2/ai/image/pose-match`, and `POST /api/v2/ai/image/virtual-try-on`.
- [x] **T09 — Wire `brandhub-business-service` & Credit Settlement:** Add `/api/v1/ai/image/models`, `/api/v1/ai/image/studio/generate`, `/pose-match`, and `/virtual-try-on` in `AiGenerationController.java` and `AiCreditGenerationService.java` with `Idempotency-Key` credit reserve/settle and automatic hold release on errors.

## 4. Studio Web UI & KSampler Progress UX (Plan §4 Phase 4)

- [x] **T10 — Extend Studio Types & AI Services (`brandhub-web`):** Add `StudioModelId`, `StudioEffortLevel`, and `KSamplerStepEvent` to `types/studio.ts`; add `listImageModels()`, `generateStudioImageStream()`, `poseMatch()`, and `virtualTryOn()` to `aiGenerationService.ts` and `studioAiRunner.ts`.
- [x] **T11 — Add `model` & `effort` Controls to Studio Nodes & Simple Mode:** Update `StudioNodeInspectorDock.tsx`, `StudioNodes.tsx`, and `StudioSimpleMode.tsx` to let users pick `model` (`auto`, `qwen-studio`, `agy`, `gpt-image-2.6-flare`, `gpt-image-2.6-sunburst`) and `effort` (`low`, `medium`, `high`) without text truncation.
- [x] **T12 — Build `KSamplerOutputPreview.tsx`:** Create focused component (`< 250` lines) rendering real-time 4-stage node progress, expanded prompt preview, live progressive `partial_image_b64` / denoise canvas, and 5-step denoise filmstrip on `outputNode` and Simple Mode output card.

## 5. i18n, Theme & Production Infrastructure (Plan §4 Phases 5–6)

- [x] **T13 — Update `vi/aiStudio.json` + `en/aiStudio.json` in Parallel:** Add all `aiStudio.studio.models.*`, `aiStudio.studio.effort.*`, and `aiStudio.studio.ksampler.*` keys in both `vi` and `en` bundles with zero hardcoded strings.
- [x] **T14 — Audit Light & Dark Mode:** Verify semantic Tailwind tokens (`bg-card`, `bg-muted`, `text-foreground`, `border-border`, `text-brand-orange`) across `375px`, `768px`, and `1440px` in Light and Dark themes.
- [x] **T15 — Update `brandhub-ai-service/Dockerfile` & `ai.compose.json`:** Add `dbus-x11`, `gnome-keyring`, `agy` (`AGY_CLI_DISABLE_AUTO_UPDATE=true`), `docker-entrypoint.sh`, `agy-login`, and mount persistent `.gemini` + keyring volumes in `brandhub-infrastructure/prod/hosts/ai/ai.compose.json`.
- [x] **T16 — Execute Verification Suites:** Run all automated tests (`pytest`, `mvn test`, `npx tsc --noEmit`, `npx vitest run`) documented in [test.md](./test.md) and confirm `0` secret leaks in logs.

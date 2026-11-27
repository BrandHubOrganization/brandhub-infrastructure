> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Skill-Driven Multi-Model Studio Image Pipeline (`skill-driven-multi-model-studio-image`)

## 1. System Components & Touched Repositories

Implements [spec.md](./spec.md) across four repositories while preserving full compatibility with existing Vast.ai Qwen workflows:

| Layer / Repository | Key Files, Services & Components |
| :--- | :--- |
| **Skills Library (`brandhub-ai-service/.agents/skills/`)** | `agency-creative-director/` (`SKILL.md` + `references/`), `product-posing/`, `virtual-try-on/`, `outfit-replacement/`, `pose-director/`, `product-photography/`, `background-replacement/`, `advertising-key-visual/`, `commercial-retouching/`, `brand-consistency/` (`SKILL.md`) |
| **AI Service (`brandhub-ai-service`)** | `app/core/config.py`, `.env.example`, `app/schemas/studio_image.py`, `app/services/image/skill_loader.py`, `app/services/image/agy_provider.py`, `app/services/image/codex_provider.py`, `app/services/image/storage_service.py`, `app/services/qwen_ambassador_client.py`, `app/api/v2/endpoints/studio_image.py`, `app/main.py`, `Dockerfile`, `docker/{docker-entrypoint.sh,agy-login.sh}` |
| **Business Service (`brandhub-business-service`)** | `AiGenerationController.java`, `AiCreditGenerationService.java`, `AiServiceClient.java` (forward `models`, `studio/generate`, `studio/generate/stream`, `pose-match`, `virtual-try-on` with credit reserve/settle) |
| **Web Frontend (`brandhub-web`)** | `src/pages/studio/types/studio.ts`, `src/pages/studio/components/nodes/StudioNodeInspectorDock.tsx`, `src/pages/studio/components/nodes/StudioNodes.tsx`, `src/pages/studio/components/StudioSimpleMode.tsx`, `src/pages/studio/components/KSamplerOutputPreview.tsx`, `src/pages/studio/services/studioAiRunner.ts`, `src/services/aiGenerationService.ts`, `src/i18n/locales/{vi,en}/aiStudio.json` |
| **Prod Infra (`brandhub-infrastructure`)** | `prod/hosts/ai/ai.compose.json` (persistent `.gemini` & keyring Docker volumes; `AGY_MODEL`, `AGY_IMG`, `GPT_MODEL`, `GPT_IMG_FAST`, `GPT_IMG_NOR` env wiring) |

---

## 2. Core Technical Design & Module Responsibilities

### 2.1 Zero-Turn Skill Injection (`app/services/image/skill_loader.py`)
- Reads `agency-creative-director/SKILL.md` + the matched task `SKILL.md` files once at startup (cached in memory via `@lru_cache`).
- Maps `workflow_mode` (`ad-composer`, `pose-match`, `virtual-tryon`, `refine`, `ambassador`, `product`, `key-visual`, `background`) + optional `brand_context` into a compact, deterministic Creative Director system directive (`<= 1,800` tokens).
- Ensures **zero** extra CLI tool calls for reading skill markdown files during live requests.

### 2.2 Antigravity CLI Provider (`app/services/image/agy_provider.py`)
- **Cross-platform binary resolution**: `AGY_CLI_PATH` → Windows `%LOCALAPPDATA%\agy\bin\agy.exe` → Linux `~/.local/bin/agy` → `shutil.which("agy")`.
- **Effort & Model routing**:
  - `effort == "low"` → runs `AGY_IMG` (`gemini-3.8-flash-low`) with direct skill-synthesized brief (~29–39s).
  - `effort in ("medium", "high")` → runs `AGY_MODEL` (`gemini-4-neon-low`) as Creative Director orchestrator + `image-generator` (~45–65s).
- **Streaming & Early Capture**: Uses `subprocess.Popen` + threaded `asyncio.Queue` (works identically on Windows `SelectorEventLoop` and Linux `epoll`), parses `stream-json` + tails `<brain>/<subagent_conv_id>/transcript.jsonl` to emit real `orchestrating` → `composing` → `sampling` (with `expanded_prompt`) → `storing` → `completed` events, verifies JPEG EOI (`\xff\xd9`) + `PIL.Image.verify()`, and deletes both `<parent_conv_id>` and `<subagent_conv_id>` directories in `finally`.
- **Memory & Concurrency Guard**: Protected by `asyncio.Semaphore(settings.agy_max_concurrency)` (default `1` inside the `3g` `brandhub-ai` container).

### 2.3 Codex OAuth Image Provider (`app/services/image/codex_provider.py`)
- Reads `CODEX_OAUTH_ACCESS_TOKEN` (env or `CODEX_AUTH_JSON_PATH` / `~/.codex/auth.json`) and extracts `ChatGPT-Account-Id` from the JWT `https://api.openai.com/auth` claim.
- **Model & Effort mapping**:
  - Orchestrator `model`: strips `-light` suffix from `GPT_MODEL=gpt-6-sol-light` → sends `"model": "gpt-6-sol"` with `"reasoning": {"effort": effort}` (`low` / `medium` / `high`).
  - Image tool `model`: `gpt-image-2.6-flare` (`GPT_IMG_FAST`) or `gpt-image-2.6-sunburst` (`GPT_IMG_NOR`), with `partial_images: 3` so SSE emits real `response.image_generation_call.partial_image` (`preview_image`) frames!
- **Reference Images**: Encodes up to 3 reference images (`model`, `product`, `pose`/`outfit`) as `input_image` parts in `input[0].content`.

### 2.4 Qwen Worker Completion (`qwen_ambassador_client.py` + `studio_image.py`)
- Adds `pose_match(prompt, image1_bytes, image2_bytes, ...)` calling `/api/v1/wf2/pose_match` on Vast.ai worker.
- Adds `virtual_try_on(prompt, image1_bytes, image2_bytes, ...)` calling `/api/v1/wf3/outfit_change` on Vast.ai worker.
- Preserves existing `/api/v1/ai/ambassadors/*` and `/api/v2/ai/image/commercial/generate` routes intact.

### 2.5 Hybrid S3 / Local Storage (`app/services/image/storage_service.py`)
- Enhances `is_s3_configured()` so when `STORAGE_BACKEND` is `"s3"` (or `"auto"` with `S3_BUCKET_NAME`), it checks explicit AWS keys **or** `boto3.Session().get_credentials() is not None` (supporting EC2 IMDSv2 Instance Role `brandhub-ec2-ecr-pull` on `brandhub-ai` without static keys).
- Falls back cleanly to `/static/generated/{id}.png` in local development when S3 is unconfigured.

---

## 3. End-to-End Data & KSampler Streaming Flow

```text
brandhub-web (Studio Node: model + effort)
  │  POST /api/v1/ai/image/studio/generate/stream (or /generate)
  ▼
brandhub-api-gateway (:8080, proxy_buffering off, 1260s timeout)
  ▼
brandhub-business-service (:8081, AiCreditGenerationService: reserve 1 credit)
  ▼
brandhub-ai-service (:8082, studio_image.py)
  ├── skill_loader.py: load agency-creative-director + matched task SKILL.md + brand_context
  ├── model == "qwen-studio" ──► QwenAmbassadorClient (wf1 / wf2 / wf3 / ambassador)
  ├── model == "agy" ──────────► agy_provider.py (Semaphore(1) -> stream-json -> early JPEG)
  └── model == "gpt-image-2.6-*" ► codex_provider.py (gpt-6-sol + partial_image_b64 stream)
  ▼
storage_service.py (Prod S3 brandhub-media OR Local /static/generated)
  ▼
KSamplerOutputPreview.tsx (renders live steps, expanded prompt, partial/denoise frames, final image)
```

---

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Skills & Config Baseline:** Author the 10 `SKILL.md` files under `brandhub-ai-service/.agents/skills/`, update `app/core/config.py` and `.env.example`, and fix `is_s3_configured()` in `storage_service.py` for EC2 IMDSv2.
2. **Phase 2 — Providers & Qwen `wf2`/`wf3`:** Implement `skill_loader.py`, `agy_provider.py`, `codex_provider.py`, and add `pose_match` / `virtual_try_on` to `qwen_ambassador_client.py`.
3. **Phase 3 — FastAPI & Business Service Contracts:** Add `studio_image.py` (`GET /models`, `POST /generate`, `POST /generate/stream`, `POST /pose-match`, `POST /virtual-try-on`) and wire `AiGenerationController.java` + `AiCreditGenerationService.java` with credit reserve/settle and SSE passthrough.
4. **Phase 4 — Studio Web UI & KSampler Preview:** Extend `studio.ts`, `StudioNodeInspectorDock.tsx`, `StudioNodes.tsx`, `StudioSimpleMode.tsx`, `KSamplerOutputPreview.tsx`, `studioAiRunner.ts`, and `aiGenerationService.ts`.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Audit:** Add all `aiStudio.studio.models.*`, `effort.*`, and `ksampler.*` keys in `vi/aiStudio.json` & `en/aiStudio.json` and verify Light/Dark contrast.
6. **Phase 6 — Prod Container & Verification:** Update `brandhub-ai-service/Dockerfile` (`dbus-x11`, `gnome-keyring`, `agy`, `agy-login`) + `brandhub-infrastructure/prod/hosts/ai/ai.compose.json` (persistent `.gemini` + keyring volumes), then run automated tests in [test.md](./test.md).

---

## 5. Localization, Theme Tokens & Production Risks

- **i18n Parity:** `vi/aiStudio.json` and `en/aiStudio.json` updated in the same commit with zero hardcoded UI strings.
- **Light/Dark Mode:** `KSamplerOutputPreview.tsx` and inspector dropdowns use semantic Tailwind classes (`bg-card`, `bg-muted/40`, `text-foreground`, `border-border`, `text-brand-orange`) + `dark:` variants.
- **Risks & Mitigations:**
  - *RAM `3g` limit on `brandhub-ai` EC2*: `asyncio.Semaphore(1)` caps concurrent `agy` runs; `codex` runs over async `httpx` with minimal RAM overhead.
  - *Expired Codex OAuth / `agy` session*: Returns `502`/`503` without settling the held AI credit (`AiCreditGenerationService` releases reservation cleanly).
  - *Nginx SSE buffering*: `X-Accel-Buffering: no` header + existing `proxy_buffering off` in `nginx.conf` ensures real-time KSampler steps reach the browser immediately.

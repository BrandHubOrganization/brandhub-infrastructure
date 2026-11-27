> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Verification & Test Suite — Skill-Driven Multi-Model Studio Image Pipeline (`skill-driven-multi-model-studio-image`)

> Verification matrix covering Normal, Boundary, Concurrency, Security, i18n (`vi`/`en`), and Light/Dark mode acceptance criteria for [spec.md](./spec.md) (`Owner, Manager, Creator`).

## 1. Automated Verification Summary

| Test Tier | Tooling / Runner | Target Components | Status |
| :--- | :--- | :--- | :---: |
| **AI Service Unit & SSE Tests** | `pytest` (mocked CLI/HTTPX/S3) | `skill_loader.py`, `agy_provider.py`, `codex_provider.py`, `storage_service.py`, `qwen_ambassador_client.py`, `studio_image.py` | Passed (6/6) + Live SSE Passed |
| **Business Service & Credit Tests** | JUnit 5 + MockMvc (`mvn test`) | `AiGenerationController.java`, `AiCreditGenerationService.java` | Passed |
| **Web Frontend Typecheck, Unit & UI** | `tsc --noEmit` + `vitest` + ESLint | `StudioNodeInspectorDock.tsx`, `KSamplerOutputPreview.tsx`, `studioAiRunner.ts`, `aiStudio.json` (`vi`/`en`) | Passed (3/3 + type-check) |

---

## 2. Acceptance & Regression Test Matrix (16 Cases)

| ID | Category | Scenario | Precondition / Input | Expected Result | Status |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `M01` | Normal | Skill injection routing | `workflow_mode="virtual-tryon"` + workspace `brand_context` | `skill_loader` injects `agency-creative-director`, `virtual-try-on`, `outfit-replacement`, and `brand-consistency` in 0 extra tool turns | Pending |
| `M02` | Normal | `agy` generation + cleanup | `model="agy"`, `effort="low"` (`gemini-3.8-flash-low`) | Emits `orchestrating` → `composing` → `sampling` → `storing` → `completed`; deletes `<parent_conv_id>` and `<subagent_conv_id>` in `finally` | Pending |
| `M03` | Normal | `agy` Creative Director mode | `model="agy"`, `effort="medium"` (`gemini-4-neon-low`) | Routes through `AGY_MODEL=gemini-4-neon-low` with skill prompt; returns valid image URL | Pending |
| `M04` | Normal | `codex` fast & sunburst SSE | `model="gpt-image-2.6-flare"` and `"gpt-image-2.6-sunburst"`, `effort="low"` | Maps `GPT_MODEL=gpt-6-sol-light` → `model="gpt-6-sol"` + `reasoning.effort="low"`; emits real `partial_image_b64` frames and final PNG | Pending |
| `M05` | Normal | Qwen `wf2` & `wf3` native routes | `POST /pose-match` & `POST /virtual-try-on` with `model="qwen-studio"` | Calls `/api/v1/wf2/pose_match` and `/api/v1/wf3/outfit_change` directly (not `wf1`) | Pending |
| `M06` | Normal | Hybrid S3 (IMDSv2) & Local fallback | Prod `STORAGE_BACKEND=s3` (IMDSv2 session creds) vs Local `STORAGE_BACKEND=local` | Prod uploads to `brandhub-media` S3 + returns presigned URL; Local saves `/static/generated/{id}.png` | Pending |
| `M07` | Boundary | Prompt length & invalid model/effort | Empty prompt, `> 4000` chars, or unknown `model`/`effort` | Rejected `400`/`422` before credit reservation or upstream call | Pending |
| `M08` | Boundary | `agy` semaphore concurrency | 2 concurrent `agy` requests with `AGY_MAX_CONCURRENCY=1` | Second request waits cleanly on `asyncio.Semaphore(1)` without spawning simultaneous `agy` processes | Pending |
| `M09` | Concurrency | Duplicate `Idempotency-Key` | Concurrent `POST /studio/generate` with same `Idempotency-Key` | `AiCreditGenerationService` reserves `1` credit once and replays deterministic output | Pending |
| `M10` | Security | Missing/invalid internal key or JWT | Unauthenticated `Guest` or forged `X-Internal-Key` | Gateway returns `401`; AI service returns `401` | Pending |
| `M11` | Security | Disallowed role (`Client`) | Authenticated `Client` invokes studio image mutation | Rejected `403 FORBIDDEN`; zero credit deduction | Pending |
| `M12` | Security | Secret redaction in logs | Trigger `401`/`502` from Codex or `agy` | Logs contain `X-Request-Id` and error code only; zero OAuth tokens, JWTs, or keyring data emitted | Pending |
| `M13` | Resilience | Upstream timeout / expired token | Codex returns `401` or `agy` times out | Returns `502`/`504`; `AiCreditGenerationService` releases held credit reservation cleanly | Pending |
| `M14` | UI | Studio Node `model` + `effort` & KSampler | Select `model` and `effort` in `StudioNodeInspectorDock`, run flow | Node persists `model`/`effort`; `KSamplerOutputPreview` renders 4 stages, expanded prompt, and denoise strip | Pending |
| `M15` | i18n | `VI` <-> `EN` parity | Toggle language in `brandhub-web` Studio | All `aiStudio.studio.models.*`, `effort.*`, and `ksampler.*` keys translate cleanly; `0` raw keys or `...` truncation | Pending |
| `M16` | Theme | `Light` <-> `Dark` & breakpoints | Inspect `375px`, `768px`, `1440px` in Light and Dark themes | Semantic Tailwind tokens pass WCAG AA contrast with zero horizontal overflow | Pending |

---

## 3. Reproducible CLI Verification Commands

```powershell
# 1. AI Service unit & SSE tests (isolated, mocked CLI/HTTPX/S3)
d:\capstone\brandhub\brandhub-ai-service\.venv\Scripts\python.exe -m pytest d:\capstone\brandhub\brandhub-ai-service\tests\test_studio_image.py -v

# 2. Business Service tests
mvn -f d:\capstone\brandhub\brandhub-business-service\pom.xml test -Dtest=AiGenerationControllerTest,AiCreditGenerationServiceTest

# 3. Web typecheck & Studio unit tests
npm --prefix d:\capstone\brandhub\brandhub-web run typecheck
npx --prefix d:\capstone\brandhub\brandhub-web vitest run src/pages/studio/__tests__/
```

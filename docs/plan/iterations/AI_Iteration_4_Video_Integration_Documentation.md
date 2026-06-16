# AI Iteration 4 — Video, Integration & Documentation

**Timeline:** Parallel with Sprints 11–12 (Weeks 21–24)
**Duration:** 2 weeks
**Goal:** Integrate Google Veo for AI video generation, finalize all FastAPI endpoints, complete integration with business-service, and produce all AI research reports for the capstone.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| AI-09 | AI Video Generation | Ân |
| AI-10 | AI Service Integration & API Finalize | Lộc, All |
| AI-11 | AI Research Documentation & Demo | Tuấn, Ân, Lộc, All |

**Prerequisites from previous iterations:**
- All AI endpoints from Iter 1–3 working (AI-02 through AI-08)
- Sprint 9 complete: business-service calling ai-service via internal API (DA-E23, DA-E24)
- Google Veo API access confirmed (DA-AI01-03/04 research complete)

**Deliverables by end of Iteration 4:**
- `/ai/video/generate` async endpoint with polling
- All 7 AI endpoints finalized and Swagger documented
- Full integration test: business-service ↔ ai-service all calls passing
- Virtual Ambassador Technical Report
- Video Generation Research Report (30 prompt templates)
- Image Composition Research Report
- AI Cost Analysis
- Live AI demo video recorded

---

## EPIC AI-09 — AI Video Generation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI09-01 | Integrate Google Veo API (authentication, generate request, async polling for status) | Ân (AI) | 🔴 Critical |
| DA-AI09-02 | Build video prompt template system (receive topic + movement type + duration → generate optimized Veo prompt) | Ân (AI) | 🔴 Critical |
| DA-AI09-03 | Implement movement parameter mapping (camera_pan, zoom_in, zoom_out, subject_walk → Veo params) | Ân (AI) | 🟡 High |
| DA-AI09-04 | Create prompt library: 10 marketing video types x 3 movement styles = 30 prompt templates | Ân (AI) | 🔴 Critical |
| DA-AI09-05 | Build video generation endpoint (POST /ai/video/generate → async, returns jobId → GET /ai/video/{jobId}/status for polling) | Ân (AI) | 🔴 Critical |
| DA-AI09-06 | Upload generated video to S3, extract thumbnail, return {videoUrl, thumbnailUrl, duration} | Ân (AI) | 🔴 Critical |
| DA-AI09-07 | Benchmark 30 prompts (quality, generation time, cost per video) → document results | Ân (AI) | 🟡 High |
| DA-AI09-08 | Write Video Generation Research Report (prompt guide, parameter cheat sheet, best practices) | Ân (AI) | 🟡 High |

**Notes:**
- DA-AI09-01: Veo API is accessed via Google Cloud Vertex AI SDK — requires a GCP project with Vertex AI enabled and billing set up.
- DA-AI09-05 async pattern: on POST, store job in a `video_jobs` dict/Redis with status=PENDING → poll GET endpoint → when Veo completes, upload to S3 and update status=DONE.
- Veo typical generation time: 60–120 seconds per video. Polling interval: 10 seconds.
- DA-AI09-04 prompt library: structure as a JSON file `prompt_library.json` in `ai-service/data/` — include category tags for easy lookup.
- Video thumbnail extraction: use `ffmpeg` via subprocess — extract frame at 1 second mark.
- **Risk:** Google Veo API availability. As of mid-2025 it is in limited preview. Have a fallback plan: document the integration path and show a simulated response if API access is not granted.

---

## EPIC AI-10 — AI Service Integration & API Finalize

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI10-01 | Finalize all FastAPI endpoints (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/compose, /ai/rag/*, /ai/trends) | Lộc (Frontend) | 🔴 Critical |
| DA-AI10-02 | Error handling & retry for external AI API calls (exponential backoff, fallback provider) | All (Team) | 🟡 High |
| DA-AI10-03 | Integration test with business-service (verify all AI calls from business-service work correctly) | All (Team) | 🔴 Critical |
| DA-AI10-04 | Write Postman collection for all AI endpoints with example requests | Lộc (Frontend) | 🟢 Medium |
| DA-AI10-05 | Write Swagger/OpenAPI documentation for ai-service | Lộc (Frontend) | 🟢 Medium |

**Notes:**
- DA-AI10-01: "finalize" means all endpoints match the OpenAPI spec written in DA-E07-06. Cross-check before marking done.
- DA-AI10-02 error handling strategy: Groq rate limit → wait 30s → retry once → fallback to Claude API. External API timeout (>30s) → return 503 with `Retry-After` header.
- DA-AI10-03: integration test must cover all 5 endpoints called from business-service: `/internal/ai/content/generate`, `/internal/ai/image/generate`, `/internal/ai/ambassador/generate`, `/internal/ai/video/generate`, `/internal/ai/trends/fetch`.
- DA-AI10-05: FastAPI auto-generates Swagger at `/docs` — verify all schemas are correct and descriptions are human-readable.

---

## EPIC AI-11 — AI Research Documentation & Demo

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI11-01 | Write Virtual Ambassador Technical Report (model comparison, implementation decisions, sample results gallery) | Tuấn (AI) | 🔴 Critical |
| DA-AI11-02 | Write Video Generation Research Report (full prompt library of 30 templates, movement parameter guide, cost analysis) | Ân (AI) | 🔴 Critical |
| DA-AI11-03 | Write Image Composition Research Report (technique comparison, best practices, quality evaluation) | Lộc (Frontend) | 🟡 High |
| DA-AI11-04 | Compile AI Cost Analysis (estimated cost per feature x average usage x 1000 users/month) | All (Team) | 🟡 High |
| DA-AI11-05 | Record AI feature demo video (showcase all 7 AI features working in practice) | All (Team) | 🔴 Critical |
| DA-AI11-06 | Present AI results to mentor (live demo + Q&A, collect feedback) | All (Team) | 🔴 Critical |

**7 AI Features to Showcase in Demo (DA-AI11-05):**
1. Caption generation with RAG context (no hallucination)
2. Hashtag generation
3. Image generation (3 variations)
4. Virtual brand ambassador generation (face consistency)
5. Ambassador + background composition
6. Product + model image composition
7. Video generation (Veo) — or simulated if API access not available

**Notes:**
- DA-AI11-01 report structure: (1) Problem statement, (2) Tools evaluated, (3) Evaluation methodology, (4) Results table with scores, (5) Final decision + rationale, (6) Screenshot gallery (before/after).
- DA-AI11-04 Cost Analysis format: per-feature cost ($/call) × estimated calls/month × 1000 users = monthly AI infra cost. Compare Free / Basic / Pro tier usage patterns.
- DA-AI11-05 demo video: max 10 minutes. Show real inputs → real outputs. No staging or fake data.
- DA-AI11-06 mentor presentation: prepare answers for: "Why not use OpenAI?", "How do you prevent hallucination?", "What is the compute cost?", "Can InstantID scale?".

---

## Dependency Map

```
AI-09 (sequential):
  DA-AI09-01 → DA-AI09-02 → DA-AI09-04 → DA-AI09-05 → DA-AI09-06 → DA-AI09-07 → DA-AI09-08
               DA-AI09-03 (feeds DA-AI09-02)

AI-10:
  [All Iter 1-3 endpoints] → DA-AI10-01 → DA-AI10-03 → DA-AI10-04
                           → DA-AI10-02
                           → DA-AI10-05

AI-11 (parallel docs, sequential demo):
  DA-AI11-01, DA-AI11-02, DA-AI11-03, DA-AI11-04 (parallel)
  → DA-AI10-03 complete → DA-AI11-05 → DA-AI11-06
```

---

## Iteration 4 Checklist

- [ ] Google Veo API authenticated and returning video (or fallback documented)
- [ ] `/ai/video/generate` async endpoint: POST → jobId → polling → S3 URL
- [ ] 30 prompt library templates committed to `prompt_library.json`
- [ ] All FastAPI endpoints match OpenAPI spec from DA-E07-06
- [ ] Error handling: Groq rate limit fallback to Claude triggers correctly
- [ ] Integration test: all 5 business-service → ai-service calls pass
- [ ] Postman collection exported and committed
- [ ] Swagger `/docs` accurate and human-readable
- [ ] Virtual Ambassador Technical Report committed
- [ ] Video Generation Research Report committed (30 templates)
- [ ] Image Composition Research Report committed
- [ ] AI Cost Analysis committed
- [ ] Demo video recorded (all 7 features, ≤10 min)
- [ ] Mentor presentation scheduled and prepared

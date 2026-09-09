# AI Iteration 3 — Image, Ambassador & Composition

**Timeline:** Parallel with Sprints 9–10 (Weeks 17–20)
**Duration:** 2 weeks
**Goal:** Implement the full AI image pipeline — text-to-image generation, virtual brand ambassador (InstantID), and image composition (background removal + layer compositing).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| AI-06 | Image Generation Pipeline | Ân |
| AI-07 | Virtual Brand Ambassador (InstantID) | Tuấn |
| AI-08 | Image Composition Pipeline | Tuấn |

> 🔀 **Rebalance sau Sprint 4:** Lộc chuyển hẳn sang AI Sub-lead (điều phối, không trực tiếp code 2 pipeline này nữa). AI-06 chuyển sang Ân (cùng nhóm "generative content" với AI-09 Video, đã quen pattern async + S3). AI-08 chuyển sang Tuấn (cùng nhóm "image pipeline" với AI-07 Ambassador). Chi tiết: [Rebalance Log](../Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4).

**Prerequisites from Iteration 1:**
- InstantID selected as ambassador tool (DA-AI01-01/02 decision)
- S3 helper functions working (DA-AI02-03)
- Stability AI API credentials and quota confirmed (DA-AI01-05/06)

**Deliverables by end of Iteration 3:**
- `/ai/image/generate` endpoint: returns 3 image variations as S3 URLs
- `/ai/ambassador/generate` endpoint: face-consistent generation
- `/ai/ambassador/apply` endpoint: ambassador + background compositing
- `/ai/compose` endpoint: product + model + background compositing
- Quality tests: 20 product prompts, 15 ambassador variations, 20 composition pairs
- InstantID vs IP-Adapter benchmark documented

---

## EPIC AI-06 — Image Generation Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI06-01 | Integrate Stability AI API (SDXL): text-to-image with style, aspect ratio, and negative prompt params | Ân (AI) | 🔴 Critical |
| DA-AI06-02 | Build image generation endpoint (POST /ai/image/generate → return S3 URL) | Ân (AI) | 🔴 Critical |
| DA-AI06-03 | Implement batch generation (generate 3 variations simultaneously for user to choose from) | Ân (AI) | 🟡 High |
| DA-AI06-04 | Brand safety filter (default negative prompts to avoid inappropriate content) | Ân (AI) | 🔴 Critical |
| DA-AI06-05 | Test 20 real product prompts, evaluate quality and generation time | Ân (AI) | 🟡 High |

**Notes:**
- DA-AI06-03 batch generation: use `asyncio.gather()` to call Stability AI 3 times concurrently — do NOT call sequentially (3x latency).
- DA-AI06-04 brand safety: minimum negative prompt list = `"nudity, violence, gore, political content, competitor brands"`. Store as configurable env var.
- SDXL typical latency: ~8–15 seconds per image. Batch of 3 = ~12–18 seconds with async.
- Stability AI free tier: 25 credits/month. Use carefully during development; budget testing credits.

---

## EPIC AI-07 — Virtual Brand Ambassador (InstantID)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI07-01 | Set up InstantID pipeline (load model, face encoder InsightFace, ControlNet depth) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-02 | Implement reference photo processing (face detection + face embedding extraction) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-03 | Build face-consistent generation endpoint (POST /ai/ambassador/generate: 1 reference + prompt → generated image preserving the original face) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-04 | Test face consistency (generate 15 different images: varying pose/background/outfit from 1 reference → measure facial similarity score) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-05 | Build ambassador gallery management (save reference + generated images to S3 by clientId) | Tuấn (AI) | 🟡 High |
| DA-AI07-06 | Apply ambassador endpoint (POST /ai/ambassador/apply: ambassador key + background key → composed image) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-07 | Benchmark InstantID vs IP-Adapter on a test set of 20 images, document final decision | Tuấn (AI) | 🟡 High |
| DA-AI07-08 | Write implementation guide (parameters, tips for generating high-quality ambassadors) | Tuấn (AI) | 🟢 Medium |

**Notes:**
- DA-AI07-01 is **hardware-intensive** — InstantID requires GPU. If local GPU is unavailable, use Google Colab (A100) or Replicate API for development/testing.
- InsightFace model download: `buffalo_l` package (~300MB). Cache to avoid re-downloading on each container start.
- DA-AI07-04 facial similarity score: use `insightface.model_zoo.get_model('buffalo_l')` to compute cosine similarity between reference and generated face embeddings. Target ≥ 0.85.
- DA-AI07-07: If IP-Adapter consistently scores higher similarity AND is faster, switch the implementation. Document the decision with evidence.

---

## EPIC AI-08 — Image Composition Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI08-01 | Implement background removal for product images (rembg library, U2Net model) → output transparent PNG | Tuấn (AI) | 🔴 Critical |
| DA-AI08-02 | Implement background removal for model/ambassador images | Tuấn (AI) | 🔴 Critical |
| DA-AI08-03 | Build layer compositing service (product layer + model layer + background layer → single image using Pillow) | Tuấn (AI) | 🔴 Critical |
| DA-AI08-04 | Implement shadow + lighting adjustment for natural-looking merges | Tuấn (AI) | 🟡 High |
| DA-AI08-05 | Build composition endpoint (POST /ai/compose: product S3 key + model S3 key + background S3 key → composed image) | Tuấn (AI) | 🔴 Critical |
| DA-AI08-06 | Test 20 product + model pairs, evaluate realism score, document failure cases | Tuấn (AI) | 🟡 High |
| DA-AI08-07 | Write composition parameter guide (optimal sizes, best practices per product type) | Tuấn (AI) | 🟢 Medium |

**Notes:**
- `rembg` library: first run downloads U2Net model (~170MB). Cache the model file.
- DA-AI08-01 and DA-AI08-02 are identical operations but must handle different image categories (product edges vs skin tones). Test edge quality separately.
- DA-AI08-03 layer order: background → model → product (product on top). Adjust per use case.
- DA-AI08-04 shadow: simple drop shadow via `Pillow.ImageFilter.GaussianBlur` on an alpha-expanded mask. Full lighting correction is out of scope.
- DA-AI08-06: document failure cases by category — "product with transparent packaging", "hair edges", "reflective surfaces" — these are known rembg weak spots.

---

## Dependency Map

```
AI-06 (independent):
  DA-AI06-01 → DA-AI06-02 → DA-AI06-03
                           → DA-AI06-04
                           → DA-AI06-05

AI-07 (sequential):
  DA-AI07-01 → DA-AI07-02 → DA-AI07-03 → DA-AI07-04
                                        → DA-AI07-05
                                        → DA-AI07-06
                           → DA-AI07-07

AI-08 (sequential start, parallel mid):
  DA-AI08-01 ─┐
  DA-AI08-02 ─┴→ DA-AI08-03 → DA-AI08-04 → DA-AI08-05 → DA-AI08-06
```

---

## Iteration 3 Checklist

- [ ] Stability AI SDXL integration working, 3 variations returned per call
- [ ] Brand safety filter active with default negative prompts
- [ ] InstantID pipeline running on GPU (local or cloud)
- [ ] Face consistency test: ≥ 0.85 cosine similarity across 15 variations
- [ ] Ambassador gallery: reference + generated images stored in S3 by clientId
- [ ] Background removal working for products and models (test edge quality)
- [ ] Layer compositing produces visually acceptable results
- [ ] `/ai/compose` endpoint returning composed S3 URL
- [ ] InstantID vs IP-Adapter benchmark documented with final decision
- [ ] 20 product prompt test results documented
- [ ] 20 composition test results with failure case analysis

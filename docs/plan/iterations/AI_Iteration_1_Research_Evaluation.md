# AI Iteration 1 — Research & Evaluation

**Timeline:** Parallel with Sprints 5–6 (Weeks 9–12)
**Duration:** 2 weeks
**Goal:** Evaluate AI tools for all 3 tracks (ambassador, video, image composition) and set up the ai-service project foundation.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| AI-01 | AI Model Research & Evaluation | Tuấn, Ân, Lộc |
| AI-02 | AI Service Infrastructure Setup | Lộc, Tuấn, Ân |

**Deliverables by end of Iteration 1:**
- Comparison report: InstantID vs IP-Adapter vs ControlNet (face consistency)
- Comparison report: Llama 3 (Groq) vs Claude API (caption quality)
- Research report: Google Veo API capabilities and prompt results
- Research report: Image compositing techniques
- `brandhub-ai-service` project initialized and running locally
- All 4 API clients configured (ChromaDB, Groq, Anthropic, Stability AI)
- Dockerfile for ai-service added to infrastructure repo

---

## EPIC AI-01 — AI Model Research & Evaluation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI01-01 | Research and compare InstantID vs IP-Adapter vs ControlNet for face-consistent virtual ambassador generation | Tuấn (AI) | 🔴 Critical |
| DA-AI01-02 | Test 3 virtual ambassador tools on 5 sample images, write comparison table (quality, speed, cost) | Tuấn (AI) | 🔴 Critical |
| DA-AI01-03 | Research Google Veo API: capabilities, pricing, rate limits, movement parameters | Ân (AI) | 🔴 Critical |
| DA-AI01-04 | Collect and test 20+ video generation prompts with various movement parameters, classify results | Ân (AI) | 🔴 Critical |
| DA-AI01-05 | Research product + model image compositing techniques: ControlNet inpainting, DALL-E edit, rembg + composite | Lộc (Frontend) | 🟡 High |
| DA-AI01-06 | Test 3 compositing methods on 10 product + model image pairs, evaluate naturalness and compute cost | Lộc (Frontend) | 🟡 High |
| DA-AI01-07 | Compare Llama 3 (Groq) vs Claude API: Vietnamese caption quality, speed, cost per call | All (Team) | 🔴 Critical |
| DA-AI01-08 | Write AI Research Summary Document consolidating results from all 3 tracks, save to docs/ repo | Ân (AI) | 🟢 Medium |

**Notes:**
- DA-AI01-07 requires all 5 members to evaluate caption quality subjectively — schedule a 1-hour review session.
- DA-AI01-02 and DA-AI01-04 produce artifacts (comparison tables) that directly inform architecture decisions in AI-02.
- Decision on InstantID vs alternatives (DA-AI01-01/02) **must be made before** AI Iteration 3 starts.

---

## EPIC AI-02 — AI Service Infrastructure Setup

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI02-01 | Initialize brandhub-ai-service project: FastAPI + Python 3.11 + folder structure (api/services/models/utils) | Lộc (Frontend) | 🔴 Critical |
| DA-AI02-02 | Configure 4 API clients from .env: ChromaDB client, Groq API client, Anthropic client, Stability AI client | Tuấn (AI) | 🔴 Critical |
| DA-AI02-03 | Configure AWS S3 client with boto3, write 3 helper functions: upload_file(), get_presigned_url(), delete_file() | Lộc (Frontend) | 🔴 Critical |
| DA-AI02-04 | Set up Pydantic base schemas for all request/response models | Ân (AI) | 🟡 High |
| DA-AI02-05 | Write Dockerfile for ai-service + add ai-service to docker-compose.yml in the infrastructure repo | Lộc (Frontend) | 🔴 Critical |
| DA-AI02-06 | Write internal API key authentication middleware (validate X-Internal-Key header) | Tuấn (AI) | 🔴 Critical |
| DA-AI02-07 | Document ChromaDB collection design (collection naming per client, metadata schema, query patterns) | Tuấn (AI) | 🟡 High |

**Notes:**
- DA-AI02-01 must be completed **first** — all other AI-02 tasks depend on the project structure existing.
- DA-AI02-05 coordinates with the infrastructure repo (Trung's domain) — communicate before adding to docker-compose.yml.
- DA-AI02-06 (X-Internal-Key middleware) is required before any internal endpoint can be tested from business-service.

---

## Dependency Map

```
DA-AI02-01 (project init)
    ├── DA-AI02-02 (API clients)
    ├── DA-AI02-03 (S3 helper)
    ├── DA-AI02-04 (Pydantic schemas)
    └── DA-AI02-05 (Dockerfile)

DA-AI01-01/02 → decision feeds AI Iteration 3 (InstantID setup)
DA-AI01-03/04 → decision feeds AI Iteration 4 (Veo integration)
DA-AI01-07    → decision feeds AI Iteration 2 (LLM choice)
```

---

## Iteration 1 Checklist

- [ ] InstantID vs IP-Adapter decision made and documented
- [ ] Llama 3 vs Claude API decision made and documented
- [ ] Google Veo API access confirmed (credentials, quota)
- [ ] `brandhub-ai-service` repo initialized, pushed to GitHub
- [ ] Local dev: `docker-compose up` includes ai-service
- [ ] All 4 API clients return a successful test call
- [ ] AI Research Summary Document committed to docs/ repo

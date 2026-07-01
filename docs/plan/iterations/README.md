# AI Parallel Track — Iteration Files

This directory contains the detailed breakdown of the 4 AI Parallel Track iterations.
The main project plan is at `../BrandHub_Project_Plan.md`.

## Files

| File | Iteration | Timeline | Owner |
|---|---|---|---|
| [AI_Iteration_1_Research_Evaluation.md](AI_Iteration_1_Research_Evaluation.md) | Iteration 1 — Research & Evaluation | Parallel with Sprints 5–6 (Weeks 9–12) | Tuấn, Ân, Lộc |
| [AI_Iteration_2_RAG_LLM_Trends.md](AI_Iteration_2_RAG_LLM_Trends.md) | Iteration 2 — RAG, LLM & Trends | Parallel with Sprints 7–8 (Weeks 13–16) | Ân, Tuấn, Lộc |
| [AI_Iteration_3_Image_Ambassador_Composition.md](AI_Iteration_3_Image_Ambassador_Composition.md) | Iteration 3 — Image, Ambassador & Composition | Parallel with Sprints 9–10 (Weeks 17–20) | Lộc, Tuấn |
| [AI_Iteration_4_Video_Integration_Documentation.md](AI_Iteration_4_Video_Integration_Documentation.md) | Iteration 4 — Video, Integration & Documentation | Parallel with Sprints 11–12 (Weeks 21–24) | Ân, Lộc, All |

## AI Track Summary

| Iteration | Epics | Key Output |
|---|---|---|
| 1 | AI-01, AI-02 | Tool comparison reports, ai-service project scaffolded |
| 2 | AI-03, AI-04, AI-05 | RAG pipeline, LLM generation, trend crawler |
| 3 | AI-06, AI-07, AI-08 | Image gen (SDXL), InstantID ambassador, image composition |
| 4 | AI-09, AI-10, AI-11 | Veo video gen, all endpoints finalized, all research reports |

## Known Issues & Risks

| Risk | Mitigation |
|---|---|
| Google Veo API in limited preview — may not be accessible | Document integration path, show simulated output if access denied |
| TikTok unofficial API may block scrapers | Fallback to Google Trends only + manual hashtag seed list |
| InstantID requires GPU — local dev may not have one | Use Google Colab (A100) or Replicate API for development |
| Groq free tier: 30 req/min rate limit | Exponential backoff + Claude API fallback already planned |
| Epic numbering gap: E25–E27 not used | Reserved for future epics if scope expands; not a bug |

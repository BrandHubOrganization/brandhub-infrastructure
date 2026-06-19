# AI Iteration 2 — RAG, LLM & Trends

**Timeline:** Parallel with Sprints 7–8 (Weeks 13–16)
**Duration:** 2 weeks
**Goal:** Build the complete RAG knowledge base pipeline, integrate LLM content generation with anti-hallucination safeguards, and implement the trend crawler service.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| AI-03 | RAG Knowledge Base Pipeline | Tuấn, Ân, Lộc |
| AI-04 | LLM Content Generation | Ân, Tuấn, Lộc |
| AI-05 | Trend Crawler Service | Ân |

**Prerequisites from Iteration 1:**
- `brandhub-ai-service` running (DA-AI02-01)
- LLM choice confirmed: Llama 3 (Groq) primary + Claude fallback (DA-AI01-07)
- ChromaDB collection design documented (DA-AI02-07)
- Pydantic schemas set up (DA-AI02-04)

**Deliverables by end of Iteration 2:**
- `/ai/rag/*` endpoints: upload, search, delete
- `/ai/content/generate` endpoint: caption + hashtags with RAG context
- RAG accuracy test: 3 real brand documents, 0 hallucinations
- Anti-hallucination test: 20 captions verified
- Trends crawler running every 6 hours with Redis cache
- Prompt Engineering Documentation committed

---

## EPIC AI-03 — RAG Knowledge Base Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI03-01 | Implement document upload endpoint (accept PDF/DOCX/TXT/URL, save file to S3) | Lộc (Frontend) | 🔴 Critical |
| DA-AI03-02 | Build document chunking service using LangChain RecursiveCharacterTextSplitter (chunk_size=500, overlap=50) | Ân (AI) | 🔴 Critical |
| DA-AI03-03 | Build embedding pipeline (text chunk → vector via embedding model → store in ChromaDB with metadata: documentId, clientId, chunkIndex) | Tuấn (AI) | 🔴 Critical |
| DA-AI03-04 | Implement semantic search (query → embedding → top-K retrieval from ChromaDB filtered by clientId) | Tuấn (AI) | 🔴 Critical |
| DA-AI03-05 | Build RAG context builder (format top-K chunks into a context string for LLM prompt) | Ân (AI) | 🔴 Critical |
| DA-AI03-06 | Implement document deletion endpoint (remove chunks from ChromaDB + file from S3) | Lộc (Frontend) | 🟡 High |
| DA-AI03-07 | Test RAG accuracy (upload 3 real brand documents, verify retrieved context is correct and does not hallucinate) | Ân (AI) | 🔴 Critical |
| DA-AI03-08 | Write RAG pipeline documentation (architecture, tuning parameters, evaluation methodology) | Ân (AI) | 🟢 Medium |

**Notes:**
- DA-AI03-01 → DA-AI03-02 → DA-AI03-03: strict sequential dependency — chunk before embed.
- DA-AI03-04 and DA-AI03-05 depend on DA-AI03-03 completing.
- DA-AI03-07 is a **blocking quality gate** — do not proceed to LLM integration (AI-04) without passing RAG accuracy test.
- Embedding model choice: use `sentence-transformers/all-MiniLM-L6-v2` (fast, lightweight) or OpenAI `text-embedding-ada-002` — document the decision.

---

## EPIC AI-04 — LLM Content Generation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI04-01 | Build prompt template system (receive topic + RAG context + trend data + tone → generate full prompt) | Ân (AI) | 🔴 Critical |
| DA-AI04-02 | Integrate Llama 3 via Groq API (system prompt enforces: only use provided context, do not fabricate) | Tuấn (AI) | 🔴 Critical |
| DA-AI04-03 | Integrate Claude API as fallback when Groq is rate-limited or quality is low | Tuấn (AI) | 🔴 Critical |
| DA-AI04-04 | Implement platform-specific optimization (auto-truncate captions: FB 63k, Threads 500, TikTok 4k chars) | Lộc (Frontend) | 🟡 High |
| DA-AI04-05 | Implement hashtag generation endpoint (call Llama 3 with a simple prompt) | Lộc (Frontend) | 🟡 High |
| DA-AI04-06 | Implement regenerate with feedback (receive previous output + feedback → generate improved version) | Ân (AI) | 🟡 High |
| DA-AI04-07 | Anti-hallucination test (verify 20 generated captions — every claim must be sourced from brand context) | All (Team) | 🔴 Critical |
| DA-AI04-08 | Write Prompt Engineering Documentation (template design, system prompt best practices, tone guide) | Ân (AI) | 🟢 Medium |

**Notes:**
- DA-AI04-01 depends on DA-AI03-05 (RAG context builder) — prompt template needs context input format locked.
- DA-AI04-02 and DA-AI04-03 can be developed in parallel; fallback switching logic added after both are working.
- DA-AI04-07 is a **blocking quality gate** — schedule a team review session to manually verify 20 captions.
- Groq free tier: 14,400 requests/day, 30 requests/minute — implement exponential backoff for rate limits.

---

## EPIC AI-05 — Trend Crawler Service

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI05-01 | Implement Google Trends crawler (pytrends) to fetch top trending keywords in Vietnam | Ân (AI) | 🟡 High |
| DA-AI05-02 | Implement TikTok trending hashtag crawler (web scraping or unofficial API) | Ân (AI) | 🟡 High |
| DA-AI05-03 | Normalize trend data into a standard format: {keyword, score, platform, relatedTopics[]} | Ân (AI) | 🟡 High |
| DA-AI05-04 | Implement Redis cache for trend data (TTL 6 hours, key: trends:vn:{date}:{category}) | Ân (AI) | 🟡 High |
| DA-AI05-05 | Implement trend suggestions API endpoint (GET /ai/trends?category=fashion&limit=20) | Ân (AI) | 🟡 High |
| DA-AI05-06 | Set up APScheduler to auto-crawl every 6 hours | Ân (AI) | 🟢 Medium |

**Notes:**
- DA-AI05-02 (TikTok unofficial API) is a **risk item** — TikTok frequently blocks scrapers. Have a fallback: use only pytrends + manual hashtag seed list.
- DA-AI05-04 Redis key must match the Redis instance configured in docker-compose (from Sprint 4 infrastructure).
- DA-AI05-06 APScheduler: use `BackgroundScheduler` — do NOT block the FastAPI event loop.
- Trend data feeds into DA-AI04-01 (prompt template receives trend data as input).

---

## Dependency Map

```
AI-03:
  DA-AI03-01 → DA-AI03-02 → DA-AI03-03 → DA-AI03-04 → DA-AI03-07
                                        → DA-AI03-05 → DA-AI04-01

AI-04:
  DA-AI03-05 → DA-AI04-01 → DA-AI04-02 → DA-AI04-07
                           → DA-AI04-03

AI-05 (independent, feeds AI-04-01):
  DA-AI05-01 → DA-AI05-03 → DA-AI05-04 → DA-AI05-05 → DA-AI05-06
  DA-AI05-02 → DA-AI05-03
```

---

## Iteration 2 Checklist

- [ ] Document upload → chunked → embedded → searchable via `/ai/rag/search`
- [ ] RAG accuracy test passed: 3 brand documents, correct context retrieved
- [ ] Llama 3 (Groq) generating captions with RAG context
- [ ] Claude API fallback triggers when Groq rate-limited
- [ ] Anti-hallucination test passed: 20 captions manually verified
- [ ] Platform-specific caption truncation working for all 4 platforms
- [ ] Trend crawler running, data cached in Redis with 6h TTL
- [ ] `/ai/trends` endpoint returning normalized results
- [ ] Prompt Engineering Documentation committed

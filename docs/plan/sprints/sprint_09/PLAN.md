# Sprint 9 — AI Service Wiring & Business Integration

**Timeline:** Weeks 17–18 (Sep 9–22, 2026)
**Jira:** DA Sprint 9
**Phase:** Phase 4 — Social Integration & AI Pipeline
**Goal:** Expose all internal AI endpoints and wire them into business-service so the full content creation flow (request → AI generate → draft post) works end-to-end.

> **AI Parallel:** AI Iteration 3 runs concurrently this sprint.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E23 | AI Service Internal API Wiring | Tuấn, Ân |
| E24 | Business Service AI Integration | Trung |
| E17 🔀 | Subscription & Billing (dời từ Sprint 6) | Trung, Ân |

> 🔀 **Rebalance sau Sprint 4:** E17 dời từ Sprint 6 sang đây để giảm tải Trung ở Sprint 5–6. Subscription không block gấp, Sprint 9 vốn nhẹ tải hơn. Chi tiết: [Rebalance Log](../../Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4).

**Prerequisites:**
- AI Iteration 1 complete: ai-service project running, API clients configured
- AI Iteration 2 complete: RAG pipeline + LLM generation working
- Sprint 5–6 complete: Auth + Workspace + Client APIs working

**Deliverables by end of Sprint 9:**
- All 5 `/internal/ai/*` endpoints exposed and callable with X-Internal-Key
- business-service calls ai-service for content generation
- business-service calls ai-service for image/ambassador generation trigger
- AI credit usage tracked per workspace per subscription plan
- Subscription plans CRUD (Admin), subscribe flow + Stripe payment + invoice history

---

## EPIC E23 — AI Service Internal API Wiring

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E23-01 | Expose /internal/ai/content/generate endpoint (receives topic + clientId + platform → returns caption + hashtags) | Tuấn (AI) | 🔴 Critical |
| DA-E23-02 | Expose /internal/ai/image/generate endpoint (receives prompt + style → returns S3 URL) | Tuấn (AI) | 🔴 Critical |
| DA-E23-03 | Expose /internal/ai/ambassador/generate endpoint (receives faceImage + productImage → returns S3 URL) | Tuấn (AI) | 🔴 Critical |
| DA-E23-04 | Expose /internal/ai/video/generate endpoint (receives script + style → returns S3 URL, async with polling) | Ân (AI) | 🔴 Critical |
| DA-E23-05 | Expose /internal/ai/trends/fetch endpoint (returns top trending topics by platform + region) | Ân (AI) | 🟡 High |

**Internal endpoint security:**
- All `/internal/*` routes require `X-Internal-Key: {secret}` header (from DA-AI02-06)
- Gateway blocks `/internal/*` from external traffic (configured in Sprint 4)
- business-service stores the key in `.env` as `AI_INTERNAL_KEY`

**Request/Response schemas:**

`POST /internal/ai/content/generate`:
```json
Request:  {"topic": "string", "clientId": "string", "platform": "FACEBOOK|INSTAGRAM|TIKTOK|THREADS", "tone": "professional|casual|playful"}
Response: {"caption": "string", "hashtags": ["string"], "ragSourcesUsed": 3, "model": "llama3|claude"}
```

`POST /internal/ai/image/generate`:
```json
Request:  {"prompt": "string", "style": "photorealistic|illustration|minimal", "aspectRatio": "1:1|16:9|9:16"}
Response: {"imageUrls": ["s3://...", "s3://...", "s3://..."], "generationTimeMs": 12500}
```

`GET /internal/ai/trends/fetch`:
```json
Request:  ?platform=TIKTOK&region=VN&limit=10
Response: {"trends": [{"keyword": "string", "score": 0.95, "relatedTopics": ["string"]}]}
```

---

## EPIC E24 — Business Service AI Integration

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E24-01 | Implement AI content generation flow in business-service: ContentRequest → call ai-service → save draft Post | Trung (Leader) | 🔴 Critical |
| DA-E24-02 | Implement image/ambassador generation trigger from Post editor (user selects AI generate image) | Trung (Leader) | 🔴 Critical |
| DA-E24-03 | Implement AI usage tracking (count ai_credits_per_month against subscription plan limits) | Trung (Leader) | 🟡 High |

**Content generation flow (DA-E24-01):**
1. CONTENT_CREATOR calls `POST /api/v1/posts/ai-generate` with `{contentRequestId, platform, tone}`
2. business-service fetches client brand context
3. business-service calls `/internal/ai/content/generate`
4. business-service saves returned caption+hashtags as draft `Post` document
5. business-service calls `/internal/ai/image/generate` if user requested image
6. Returns `{postId, caption, hashtags, imageUrl}` to frontend

**AI credit tracking (DA-E24-03):**
- Each successful AI call deducts from `ai_usage_logs` collection
- Credit costs: content=1, image=3, ambassador=5, video=10
- Check current month usage before calling ai-service
- If `used + cost > plan.aiCreditsPerMonth`: return 429 with `{creditsUsed, creditsLimit, upgradeUrl}`

---

## EPIC E17 — Subscription & Billing 🔀 *(dời từ Sprint 6)*

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E17-01 | Implement Admin CRUD for subscription plans (Free/Basic/Pro/Enterprise) | Trung (Leader) | 🔴 Critical |
| DA-E17-02 | Implement POST /api/v1/subscriptions/subscribe (AGENCY_OWNER subscribes to a plan) | Trung (Leader) | 🔴 Critical |
| DA-E17-03 | Implement payment flow (integrate payment gateway, create invoice) | Trung (Leader) | 🔴 Critical |
| DA-E17-04 | Implement GET /api/v1/subscriptions/invoices (billing history) | Ân (AI) | 🟡 High |

**Subscription plans (seed data from Sprint 4):**

| Plan | Price | Clients | Posts/mo | AI Credits/mo |
|---|---|---|---|---|
| Free | $0 | 1 | 10 | 20 |
| Basic | $29 | 5 | 50 | 100 |
| Pro | $79 | 20 | 200 | 500 |
| Enterprise | $199 | Unlimited | Unlimited | 2000 |

**Payment gateway (DA-E17-03):** Use Stripe (test mode for capstone). Flow: `POST /subscribe` → create Stripe PaymentIntent → client confirms → webhook callback → create `invoices` record + activate subscription.

**Notes:**
- DA-E17-03 Stripe integration: store only Stripe customer ID and subscription ID in PostgreSQL, never raw card data.
- Invoice PDF generation is out of scope for MVP — store invoice data as JSON, PDF generation in Sprint 16 if time permits.

---

## Sprint 9 Checklist

- [ ] `/internal/ai/content/generate` returns caption + hashtags with RAG context
- [ ] `/internal/ai/image/generate` returns 3 S3 URLs
- [ ] `/internal/ai/ambassador/generate` returns composed S3 URL
- [ ] `/internal/ai/video/generate` returns jobId, polling endpoint works
- [ ] `/internal/ai/trends/fetch` returns normalized trend list
- [ ] All internal endpoints require X-Internal-Key (reject without it)
- [ ] Gateway blocks `/internal/*` from public traffic
- [ ] business-service: ContentRequest → AI generate → draft Post saved
- [ ] Image generation trigger from Post editor working
- [ ] AI credit deduction working per call type
- [ ] Credit limit check: 429 returned when limit exceeded
- [ ] End-to-end test: create ContentRequest → AI generate → see draft Post in DB
- [ ] Admin can create/edit/delete subscription plans
- [ ] AGENCY_OWNER can subscribe to a plan via Stripe test mode
- [ ] Invoice record created after successful payment
- [ ] GET /api/v1/subscriptions/invoices returns paginated invoice history

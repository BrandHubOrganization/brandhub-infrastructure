# Sprint 15 — Testing & Bug Fixes

**Timeline:** Weeks 29–30 (Dec 2–15, 2026)
**Jira:** DA Sprint 15
**Phase:** Phase 7 — Testing, Deployment & Final Report
**Goal:** Write unit + integration + E2E tests, fix bugs found during testing, and complete a security audit.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E42 | Unit & Integration Testing | Trung, Tuấn, Phước, All |
| E43 | Bug Fixes & Polish | All, Lộc, Trung |

**Deliverables by end of Sprint 15:**
- Unit tests for business-service: AuthService, WorkspaceService, PostService (≥ 70% coverage)
- Unit tests for ai-service: content generation, RAG pipeline, image generation
- Integration tests for main business-service API endpoints
- E2E publishing test on real sandbox accounts (all 5 platforms)
- Security audit checklist completed
- All critical bugs from testing fixed

---

## EPIC E42 — Unit & Integration Testing

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E42-01 | Write unit tests for business-service (AuthService, WorkspaceService, PostService) | Trung (Leader) | 🔴 Critical |
| DA-E42-02 | Write unit tests for ai-service (content generation, RAG pipeline, image generation) | Tuấn (AI) | 🔴 Critical |
| DA-E42-03 | Write integration tests for main API endpoints (business-service) | Phước (Publisher) | 🔴 Critical |
| DA-E42-04 | Performance testing (load test with 200 concurrent users) | All (Team) | 🟡 High |
| DA-E42-05 | Test publishing flow E2E on sandbox accounts (FB/IG/TikTok/Threads/Zalo) | Phước (Publisher) | 🔴 Critical |

**Unit test coverage targets:**
- business-service: AuthService (login, register, refresh, logout), WorkspaceService (create, invite, remove), PostService (submit, approve, reject, schedule, enqueue)
- Use JUnit 5 + Mockito. Mock MongoDB and Redis.

**ai-service unit tests (DA-E42-02):**
- Use `pytest` + `unittest.mock`
- Content generation: mock Groq API response, verify prompt construction
- RAG pipeline: mock ChromaDB, verify chunk retrieval and context formatting
- Image generation: mock Stability AI, verify S3 upload called with correct params

**Integration tests (DA-E42-03):**
- Use `@SpringBootTest` with `Testcontainers` (real MongoDB + Redis in Docker)
- Test full auth flow: register → login → refresh → logout
- Test RBAC: verify CONTENT_CREATOR cannot access AGENCY_OWNER endpoints
- Test workspace isolation: verify user A cannot read workspace B data

**Performance testing (DA-E42-04):**
- Tool: Apache JMeter or k6
- Scenario: 200 concurrent users, 60-second ramp-up, 5-minute sustained
- Target: p95 < 500ms for non-AI endpoints, no errors > 0.1%
- Test: login, get posts/calendar, submit content request

**E2E publish test (DA-E42-05):**
- Use real developer sandbox accounts for each platform
- Test full flow: ContentRequest → AI generate → draft → submit → approve → client approve → publish → verify post appears on platform

---

## EPIC E43 — Bug Fixes & Polish

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E43-01 | Sprint retrospective, compile bug list from testing | All (Team) | 🔴 Critical |
| DA-E43-02 | UI responsive fixes (test on various screen sizes: 1920px, 1440px, 1280px, mobile) | Lộc (Frontend) | 🟡 High |
| DA-E43-03 | Security audit checklist (check SQL injection, XSS, CSRF, token handling) | Trung (Leader) | 🔴 Critical |

**Security audit checklist (DA-E43-03):**

| Check | Method | Owner |
|---|---|---|
| SQL injection | Parameterized queries in PostgreSQL (Spring Data JPA) | Trung |
| NoSQL injection | MongoDB `$where` disabled, no string concatenation in queries | Trung |
| XSS | React escapes output by default; verify no `dangerouslySetInnerHTML` | Lộc |
| CSRF | SameSite cookie + CORS whitelist on gateway | Trung |
| JWT security | Verify RS256 used, alg=none rejected, blacklist working | Trung |
| AES key exposure | Verify SOCIAL_TOKEN_ENCRYPTION_KEY not in code or logs | Trung |
| S3 bucket | Verify bucket is private, all access via presigned URLs | Trung |
| RabbitMQ | Verify management UI (port 15672) blocked from public | Trung |
| Admin endpoints | Verify `/api/v1/admin/*` requires ADMIN role | Ân |
| Internal endpoints | Verify `/internal/*` blocked by gateway, X-Internal-Key required | Tuấn |

**Responsive breakpoints (DA-E43-02):**
- 1920px: full sidebar visible, wide table columns
- 1440px: default desktop layout
- 1280px: condensed sidebar, compact tables
- Mobile (≤768px): bottom tab navigation, stacked cards

---

## Sprint 15 Checklist

- [ ] AuthService: register, login, refresh, logout unit tests pass
- [ ] WorkspaceService: create, invite, remove unit tests pass
- [ ] PostService: submit, approve, reject, schedule unit tests pass
- [ ] ai-service: content generation, RAG, image generation unit tests pass
- [ ] Integration tests: auth flow, RBAC, workspace isolation pass
- [ ] JMeter/k6 load test: p95 < 500ms at 200 concurrent users
- [ ] E2E publish test: post published on all 5 platforms
- [ ] Bug list compiled from sprint retrospective
- [ ] All critical bugs fixed
- [ ] Security audit: all 10 checklist items verified
- [ ] UI responsive: no layout breaks at 1920/1440/1280/mobile

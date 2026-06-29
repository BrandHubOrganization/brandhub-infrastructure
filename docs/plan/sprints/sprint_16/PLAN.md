# Sprint 16 — Deployment, Docs & Final Presentation

**Timeline:** Weeks 31–32 (Dec 16–29, 2026)
**Jira:** DA Sprint 16
**Phase:** Phase 7 — Testing, Deployment & Final Report
**Goal:** Deploy all services to production, finalize all documentation, record the demo video, write the capstone report, and deliver the final presentation.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E44 | Production Deployment | Trung |
| E45 | Final Documentation | Trung, All |
| E46 | Final Report & Presentation | All, Trung |

**Deliverables by end of Sprint 16:**
- All 7 services running on production server (VPS/EC2) with SSL
- Monitoring active (uptime + error alerts)
- Swagger API docs finalized for business-service
- User Manual covering all 6 roles
- Deployment Guide for fresh setup
- Demo video (5–10 min) showcasing all features
- Capstone report submitted to FPT
- Slide deck (15–20 slides) presented to mentor

---

## EPIC E44 — Production Deployment

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E44-01 | Set up VPS/EC2 instance, install Docker, configure nginx | Trung (Leader) | 🔴 Critical |
| DA-E44-02 | Deploy all services via docker-compose.prod.yml, set up SSL with Let's Encrypt | Trung (Leader) | 🔴 Critical |
| DA-E44-03 | Set up monitoring (uptime check, error alerts) | Trung (Leader) | 🟡 High |
| DA-E44-04 | Smoke test on production environment | All (Team) | 🔴 Critical |

**Production stack (DA-E44-01):**
- Server: AWS EC2 t3.medium (2 vCPU, 4GB RAM) or equivalent VPS (e.g. DigitalOcean Droplet)
- OS: Ubuntu 22.04 LTS
- Reverse proxy: nginx → routes `api.brandhub.com` to port 8080 (API Gateway)
- SSL: Let's Encrypt via certbot (auto-renew)

**docker-compose.prod.yml differences from dev:**
- No volume mounts for source code
- All services use production Docker images from ghcr.io
- Environment variables from `.env.prod` (never committed to git)
- `restart: always` on all services
- Resource limits (memory caps) to prevent OOM kills

**Monitoring (DA-E44-03):**
- Uptime: UptimeRobot free tier (monitors `/health` endpoint every 5 min, email alert on down)
- Error logs: centralize with `docker logs` + optional Datadog free tier
- Disk/CPU: `htop` + set up alert if disk > 80%

**Smoke test (DA-E44-04):**
- Register new user → login → create workspace → connect 1 social account → create content request → AI generate → approve → publish → verify post on platform

---

## EPIC E45 — Final Documentation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E45-01 | Finalize Swagger API docs for business-service | Trung (Leader) | 🔴 Critical |
| DA-E45-02 | Write User Manual (usage guide for each role) | All (Team) | 🟡 High |
| DA-E45-03 | Write Deployment Guide (step-by-step guide to deploy from scratch) | Trung (Leader) | 🔴 Critical |
| DA-E45-04 | Record demo video (5–10 minute showcase of all features) | All (Team) | 🔴 Critical |

**User Manual sections (DA-E45-02):**
- ADMIN: manage users, plans, view system health
- AGENCY_OWNER: create workspace, invite team, manage clients, billing
- ACCOUNT_MANAGER: manage clients, review + approve content, send reports
- CONTENT_CREATOR: create AI content, manage knowledge base, schedule posts
- BRAND_CLIENT: view calendar, approve/reject content, view analytics
- Appendix: social platform connection guide (screenshots)

**Deployment Guide (DA-E45-03):**
1. Prerequisites (Docker, domain, SSL cert)
2. Clone infrastructure repo
3. Configure `.env.prod` (all variables)
4. Run `docker-compose -f docker-compose.prod.yml up -d`
5. Verify all services healthy
6. Configure nginx + SSL
7. First-time database setup

**Demo video script (DA-E45-04):**
1. System overview (30s)
2. Agency Owner: create workspace, invite team, connect social accounts (90s)
3. Brand Client: submit content request (30s)
4. Content Creator: AI generate caption, image, edit, submit (90s)
5. Account Manager: review, approve, send to client (30s)
6. Brand Client: approve post (30s)
7. Auto-publish to Facebook + Instagram (30s, real publish)
8. Analytics dashboard (30s)
9. Mobile app: notification + approval (60s)

---

## EPIC E46 — Final Report & Presentation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E46-01 | Write Capstone report (following FPT's official template) | All (Team) | 🔴 Critical |
| DA-E46-02 | Consolidate and review the entire report before submission | Trung (Leader) | 🔴 Critical |
| DA-E46-03 | Prepare slide deck (15–20 slides, including demo screenshots) | All (Team) | 🔴 Critical |
| DA-E46-04 | Q&A preparation (anticipate mentor questions on architecture, AI, and database design) | All (Team) | 🟡 High |

**Capstone report structure (FPT template):**
1. Introduction — problem, motivation, objectives
2. Literature Review — related systems, technologies
3. System Design — architecture, database, API design
4. Implementation — key features with screenshots
5. AI Research — model comparisons, results, cost analysis
6. Testing — unit/integration/E2E results, performance test
7. Deployment — production environment, monitoring
8. Conclusion — achievements, limitations, future work
9. References
10. Appendix — ADRs, UC table, API spec link

**Slide deck structure (DA-E46-03):**
1. Title + team
2. Problem statement
3. Solution overview (BrandHub)
4. System architecture diagram
5. Tech stack summary
6. Key feature: AI content generation
7. Key feature: Virtual Ambassador
8. Key feature: Multi-platform publishing
9. Key feature: Approval workflow
10. Database design
11. AI research results (comparison tables)
12. Testing results (coverage, load test)
13. Demo screenshots
14. Challenges + solutions
15. Conclusion + future work

**Anticipated mentor Q&A (DA-E46-04):**
- "Why polyrepo instead of monorepo?" → ADR-001
- "Why MongoDB + PostgreSQL instead of just one?" → ADR-002
- "How do you prevent AI hallucination?" → RAG + system prompt enforcement + manual verification
- "What is your compute cost at scale?" → AI Cost Analysis document
- "How does InstantID work technically?" → Virtual Ambassador Technical Report
- "What happens if a social platform API changes?" → Adapter pattern isolates impact to 1 class per platform
- "Is the system secure?" → Security audit checklist results

---

## Sprint 16 Checklist

- [ ] EC2/VPS provisioned, Docker installed
- [ ] All 7 services running in production (docker ps shows all healthy)
- [ ] SSL certificate active, `https://api.brandhub.com/health` returns 200
- [ ] nginx routing API Gateway correctly
- [ ] UptimeRobot monitoring active
- [ ] Smoke test: full flow from registration to published post on production
- [ ] Swagger API docs: all endpoints documented with example responses
- [ ] User Manual: covers all 6 roles with screenshots
- [ ] Deployment Guide: tested by a team member who follows it cold
- [ ] Demo video: recorded, 5–10 min, all features shown
- [ ] Capstone report: all sections complete, reviewed by Trung
- [ ] Report submitted to FPT before deadline
- [ ] Slide deck: 15–20 slides
- [ ] Q&A preparation: each member prepared for their domain
- [ ] Presentation delivered to mentor

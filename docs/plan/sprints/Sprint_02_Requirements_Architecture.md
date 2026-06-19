# Sprint 2 — Requirements & Architecture

**Timeline:** Weeks 3–4 (May 30–Jun 12, 2026)
**Jira:** DA Sprint 2
**Phase:** Phase 1 — Initiation & Documentation
**Goal:** Document all 60 use cases, write functional/non-functional requirements, and produce system architecture diagrams and ADRs.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E03 | Use Case Documentation | Phước, Trung |
| E04 | Functional & Non-Functional Requirements | Trung, Ân, Lộc |
| E05 | System Architecture Design | Trung, Tuấn |

**Deliverables by end of Sprint 2:**
- BrandHub_UseCases.xlsx: 60 UCs fully documented
- BrandHub_Capstone_Register.docx: submitted
- System architecture diagram (7 services + databases)
- 4 ADRs committed to infrastructure repo
- 4 sequence diagrams for core flows
- BrandHub_Technical_Document.md: first draft

---

## EPIC E03 — Use Case Documentation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E03-01 | List and group all 60 use cases by 6 roles (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, Guest) | Phước (Publisher) | 🔴 Critical |
| DA-E03-02 | Write detailed descriptions for UC 01–20 (Admin + Agency Owner flows) — actor, description, main flow, alt flows | Trung (Leader) | 🔴 Critical |
| DA-E03-03 | Write detailed descriptions for UC 21–40 (Account Manager + Content Creator flows) | Phước (Publisher) | 🔴 Critical |
| DA-E03-04 | Write detailed descriptions for UC 41–60 (Brand Client + Social Publishing flows) | Phước (Publisher) | 🟡 High |
| DA-E03-05 | Review UC list with mentor, update based on feedback | All (Team) | 🟡 High |
| DA-E03-06 | Finalize UC table into Excel file (BrandHub_UseCases.xlsx) | Phước (Publisher) | 🟢 Medium |

**UC Distribution by role (60 total):**
- ADMIN: UC01–10 (user mgmt, plan mgmt, system config)
- AGENCY_OWNER: UC11–20 (workspace, team, billing)
- ACCOUNT_MANAGER: UC21–30 (client mgmt, content review, reports)
- CONTENT_CREATOR: UC31–40 (AI content, knowledge base, scheduling)
- BRAND_CLIENT: UC41–50 (approval, analytics, portal)
- Social Publishing flows: UC51–60 (OAuth connect, publish, token mgmt)

**Notes:**
- DA-E03-01 must complete before E03-02/03/04 can start.
- UC format: Actor | UC ID | Name | Description | Precondition | Main Flow (steps) | Alt Flow | Postcondition.

---

## EPIC E04 — Functional & Non-Functional Requirements

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E04-01 | Write functional objectives per role (6 roles x features) | Trung (Leader) | 🔴 Critical |
| DA-E04-02 | Write non-functional requirements (UI, Performance, Security, Reliability, Usability) | Trung (Leader) | 🔴 Critical |
| DA-E04-03 | Add AI performance requirements (latency, throughput, model accuracy thresholds) to non-functional section | Ân (AI) | 🟡 High |
| DA-E04-04 | Add mobile requirements (FCM, offline draft, camera) to non-functional section | Lộc (Frontend) | 🟡 High |
| DA-E04-05 | Fill in and finalize the Capstone Register form (BrandHub_Capstone_Register.docx) | Trung (Leader) | 🔴 Critical |

**Target NFR thresholds (Ân to verify):**
- API response: p95 < 500ms (excluding AI generation endpoints)
- AI content generation: p95 < 10s
- AI image generation: p95 < 20s
- System uptime: 99.5%
- Concurrent users: support 200

---

## EPIC E05 — System Architecture Design

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E05-01 | Draw system architecture overview diagram (7 services + 5 databases + RabbitMQ + clients) | Trung (Leader) | 🔴 Critical |
| DA-E05-02 | Define service responsibilities and boundaries (what each of the 7 services does and does NOT do) | Trung (Leader) | 🔴 Critical |
| DA-E05-03 | Draw database ownership diagram (which service owns which DB, cross-DB reference strategy) | Trung (Leader) | 🔴 Critical |
| DA-E05-04 | Document service-to-service communication (REST: business-ai, RabbitMQ: business-publisher, HTTP callback: publisher-business) | Trung (Leader) | 🔴 Critical |
| DA-E05-05 | Write Architecture Decision Records (ADRs) for 4 key decisions: polyrepo, MongoDB+PostgreSQL split, RabbitMQ, Spring Cloud Gateway | Trung (Leader) | 🔴 Critical |
| DA-E05-06 | Draw sequence diagrams for 4 core flows: content creation, approval workflow, auto-publishing, OAuth token refresh | Tuấn (AI) | 🔴 Critical |
| DA-E05-07 | Write the AI architecture section in the Technical Document (ai-service internal design, ChromaDB schema, LLM routing strategy) | Tuấn (AI) | 🟡 High |
| DA-E05-08 | Compile full technical document (BrandHub_Technical_Document.md) | Trung (Leader) | 🟡 High |

**4 ADRs to write (DA-E05-05):**
1. ADR-001: Polyrepo vs Monorepo → Polyrepo chosen
2. ADR-002: MongoDB + PostgreSQL split → MongoDB for documents/content, PostgreSQL for payments/audit
3. ADR-003: RabbitMQ for async publishing → chosen over direct HTTP for reliability + retry
4. ADR-004: Spring Cloud Gateway → chosen for centralized JWT validation + rate limiting

**ADR format:** Context | Decision | Rationale | Consequences | Alternatives considered

---

## Sprint 2 Checklist

- [ ] 60 UCs listed and grouped by role
- [ ] UC 01–60 fully described (all flows documented)
- [ ] Mentor review done, feedback incorporated
- [ ] BrandHub_UseCases.xlsx finalized
- [ ] Functional requirements documented per role
- [ ] NFR document includes AI + mobile sections
- [ ] Capstone Register form submitted
- [ ] System architecture diagram drawn and reviewed
- [ ] 4 ADRs committed
- [ ] 4 sequence diagrams drawn (content creation, approval, publishing, token refresh)
- [ ] BrandHub_Technical_Document.md first draft committed

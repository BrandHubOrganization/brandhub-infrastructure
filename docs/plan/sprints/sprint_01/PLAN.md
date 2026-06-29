# Sprint 1 — Project Kickoff

**Timeline:** Weeks 1–2 (May 16–29, 2026)
**Jira:** DA Sprint 1
**Phase:** Phase 1 — Initiation & Documentation
**Goal:** Register the capstone project, confirm team roles, and set up all project management infrastructure.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E01 | Project Initiation | All, Trung |
| E02 | Project Management Setup | Trung |

**Deliverables by end of Sprint 1:**
- Capstone project registered on Call4project
- Mentor confirmed and first meeting scheduled
- GitHub Organization created with 7 repos
- Jira workspace configured with sprint cadence
- Branch protection rules and commit conventions active
- All team service accounts created (AWS, Groq, Stability AI, etc.)

---

## EPIC E01 — Project Initiation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E01-01 | Brainstorm and align on BrandHub topic idea, define scope and MVP | All (Team) | 🔴 Critical |
| DA-E01-02 | Team meeting to confirm roles and responsibilities of each member | Trung (Leader) | 🔴 Critical |
| DA-E01-03 | Find and contact a mentor suitable for the AI + microservices topic | Trung (Leader) | 🔴 Critical |
| DA-E01-04 | Assess each team member's technical skills (Java, Python, React, AI tools) | All (Team) | 🟡 High |
| DA-E01-05 | Submit project registration form on the Call4project system (insideuni.fpt.edu.vn) | Trung (Leader) | 🔴 Critical |

**Notes:**
- DA-E01-01: Output = a 1-page brief: problem statement, target users, MVP feature list, out-of-scope list.
- DA-E01-03: Target mentor with Java microservices or AI/ML background. Prepare a 1-paragraph project pitch.
- DA-E01-05: Deadline for registration is fixed by FPT — do not delay.

---

## EPIC E02 — Project Management Setup

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E02-01 | Create Jira workspace, set up 2-week sprint cadence, create issue templates | Trung (Leader) | 🔴 Critical |
| DA-E02-02 | Create GitHub Organization and 7 repos following polyrepo structure | Trung (Leader) | 🔴 Critical |
| DA-E02-03 | Set up branch protection rules, PR template, commit convention (Conventional Commits) | Trung (Leader) | 🔴 Critical |
| DA-E02-04 | Create project email and accounts for all services (AWS, GitHub Actions, Groq, Stability AI, etc.) | Trung (Leader) | 🔴 Critical |

**7 Repos to create:**
- `brandhub-business-service`
- `brandhub-ai-service`
- `brandhub-publisher-service`
- `brandhub-api-gateway`
- `brandhub-web-dashboard`
- `brandhub-mobile-app`
- `brandhub-infrastructure`

**Notes:**
- DA-E02-03: Branch strategy = `main` (prod), `develop` (integration), `feature/*`, `fix/*`. Require 1 approval + passing CI to merge into `develop`.
- DA-E02-04: Use a shared team email (not personal) for all service accounts. Store credentials in a shared password manager.

---

## Sprint 1 Checklist

- [ ] Project registered on Call4project
- [ ] Mentor contact made
- [ ] All 7 GitHub repos created under GitHub Organization
- [ ] Jira project DA configured with Sprint 1 active
- [ ] Branch protection rules active on all repos
- [ ] All team members have access to GitHub org and Jira
- [ ] AWS account created, IAM user with S3 access
- [ ] Groq API key obtained
- [ ] Stability AI API key obtained

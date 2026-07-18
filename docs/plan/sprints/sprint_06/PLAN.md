# Sprint 6 — Workspace, Client & Subscription

**Timeline:** Weeks 11–12 (Jul 29–Aug 11, 2026)
**Jira:** DA Sprint 6
**Phase:** Phase 3 — Backend Core
**Goal:** Implement workspace CRUD, client/agency management, and subscription/billing APIs in business-service.

> **AI Parallel:** AI Iteration 1 runs concurrently this sprint (final week).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E15 | Workspace Management | Trung |
| E16 | Client & Agency Management | Trung |

> 🔀 **E17 (Subscription & Billing) đã dời sang Sprint 9** để giảm tải Trung ở Sprint 5–6 (25 task Auth+RBAC+Workspace+Client+Subscription dồn 2 sprint liên tiếp). Subscription không block gì gấp. Chi tiết: [Rebalance Log](../../Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4).

**Deliverables by end of Sprint 6:**
- Full workspace CRUD: create, get, invite member, remove member, settings
- Client management: create, assign account manager, set service package, list

---

## EPIC E15 — Workspace Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E15-01 | Implement POST /api/v1/workspaces (create new workspace, AGENCY_OWNER role) | Trung (Leader) | 🔴 Critical |
| DA-E15-02 | Implement GET /api/v1/workspaces/mine (get current user's workspace) | Trung (Leader) | 🔴 Critical |
| DA-E15-03 | Implement POST /api/v1/workspaces/{id}/members (invite member via email) | Trung (Leader) | 🔴 Critical |
| DA-E15-04 | Implement DELETE /api/v1/workspaces/{id}/members/{userId} (remove member) | Trung (Leader) | 🟡 High |
| DA-E15-05 | Implement workspace settings (timezone, default platforms, report frequency) | Trung (Leader) | 🟡 High |

**Workspace invite flow (DA-E15-03):**
1. AGENCY_OWNER POSTs `{email, role}` → system checks if user exists
2. If user exists: add to `workspace_members`, notify user
3. If not exists: send invite email with registration link pre-filled with workspaceId
4. Role options for invite: ACCOUNT_MANAGER, CONTENT_CREATOR

**Notes:**
- One user can only belong to one workspace (enforced at invite time).
- AGENCY_OWNER cannot remove themselves — must transfer ownership first (out of scope for MVP).

---

## EPIC E16 — Client & Agency Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E16-01 | Implement POST /api/v1/clients (AGENCY_OWNER creates new brand client) | Trung (Leader) | 🔴 Critical |
| DA-E16-02 | Implement PUT /api/v1/clients/{id}/assign (AGENCY_OWNER assigns Account Manager) | Trung (Leader) | 🔴 Critical |
| DA-E16-03 | Implement PUT /api/v1/clients/{id}/service-package (set post limit/month and platforms) | Trung (Leader) | 🟡 High |
| DA-E16-04 | Implement GET /api/v1/clients (AGENCY_OWNER and ACCOUNT_MANAGER view client list) | Trung (Leader) | 🔴 Critical |

**Client document fields:**
`clientId`, `workspaceId`, `name`, `industry`, `brandColor`, `logoUrl`, `assignedAccountManagerId`, `servicePackage: {postsPerMonth, platforms[], aiCreditsPerMonth}`, `createdAt`

**Notes:**
- ACCOUNT_MANAGER can only see clients assigned to them (`assignedAccountManagerId == currentUserId`).
- Service package on client is separate from workspace subscription — client-level limit ≤ workspace subscription limit.

---

> 🔀 **EPIC E17 (Subscription & Billing) đã dời sang Sprint 9** — xem PLAN.md của Sprint 9 để biết chi tiết task, subscription plans seed data, và Stripe payment flow.

## Sprint 6 Checklist

- [ ] POST /api/v1/workspaces creates workspace, creator becomes AGENCY_OWNER
- [ ] Invite member: email sent, user added to workspace_members on accept
- [ ] Remove member: user loses workspace access immediately
- [ ] Workspace settings: timezone + default platforms + report frequency saved
- [ ] POST /api/v1/clients creates client under workspace
- [ ] Assign account manager: client.assignedAccountManagerId updated
- [ ] Service package set: postsPerMonth + platforms enforced

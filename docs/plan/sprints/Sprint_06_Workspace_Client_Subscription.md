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
| E17 | Subscription & Billing | Trung, Ân |

**Deliverables by end of Sprint 6:**
- Full workspace CRUD: create, get, invite member, remove member, settings
- Client management: create, assign account manager, set service package, list
- Subscription plans CRUD (Admin)
- Subscribe to plan + payment flow + invoice history

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

## EPIC E17 — Subscription & Billing

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

## Sprint 6 Checklist

- [ ] POST /api/v1/workspaces creates workspace, creator becomes AGENCY_OWNER
- [ ] Invite member: email sent, user added to workspace_members on accept
- [ ] Remove member: user loses workspace access immediately
- [ ] Workspace settings: timezone + default platforms + report frequency saved
- [ ] POST /api/v1/clients creates client under workspace
- [ ] Assign account manager: client.assignedAccountManagerId updated
- [ ] Service package set: postsPerMonth + platforms enforced
- [ ] Admin can create/edit/delete subscription plans
- [ ] AGENCY_OWNER can subscribe to a plan via Stripe test mode
- [ ] Invoice record created after successful payment
- [ ] GET /api/v1/subscriptions/invoices returns paginated invoice history

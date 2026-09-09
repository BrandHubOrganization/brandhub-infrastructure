# Sprint 6 — Workspace, Client & Core Pages

**Timeline:** Weeks 11–12 (Jul 29–Aug 11, 2026)
**Jira:** DA Sprint 6
**Phase:** Phase 3 — Backend Core
**Goal:** Implement workspace CRUD, client/agency management APIs, and build core web-dashboard pages (auth, dashboard, workspace, client, content management).

> **AI Parallel:** AI Iteration 1 runs concurrently this sprint (final week).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E14 🔀 | Role-Based Access Control (dời từ Sprint 5) | Trung + Phước |
| E15 | Workspace Management | Trung |
| E16 | Client & Agency Management | Phước |
| E35 🔀 | Auth & Dashboard Pages (dời từ Sprint 12) | Trung + Phước |
| E36 🔀 | Content Management Pages (dời từ Sprint 12) | Phước |

> 🔀 **E17 (Subscription & Billing) đã dời sang Sprint 9.** Chi tiết: [Rebalance Log](../../Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4).
> 🔀 **E14 (RBAC) dời từ Sprint 5 sang Sprint 6** — chưa làm được ở Sprint 5 do auth core chiếm thời gian. Đây là foundational epic, block E15/E16.
> 🔀 **E35 & E36 dời từ Sprint 12 lên Sprint 6** để có UI sớm cho auth + workspace + client + content, tận dụng Design System foundation đã có từ Sprint 5 (E34). Backend APIs (E15, E16) làm song song → UI có dữ liệu thật ngay.

**Deliverables by end of Sprint 6:**
- RBAC annotation/middleware (@RequireRole) + workspace isolation + client isolation
- Permission matrix document (6 roles × all endpoints)
- Full workspace CRUD: create, get, invite member, remove member, settings
- Client management APIs + UI: create, assign account manager, set service package, list
- Login/Register pages + Google OAuth button
- Main Dashboard page (overview widgets)
- Workspace management pages (create, settings, members)
- Client management pages (list, create, edit, service package)
- Content Request list, Content Editor with AI panel, Content Calendar, Platform Preview, Content Library

---

## EPIC E14 — Role-Based Access Control (RBAC) 🔀 *(dời từ Sprint 5)*

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E14-01 | Write RBAC annotation/middleware for business-service (@RequireRole) | Trung (Leader) | 🔴 Critical |
| DA-E14-02 | Implement workspace isolation filter (every MongoDB query must include workspaceId) | Trung (Leader) | 🔴 Critical |
| DA-E14-03 | Implement client isolation for BRAND_CLIENT (can only view their own clientId data) | Trung (Leader) | 🔴 Critical |
| DA-E14-04 | Write permission matrix document (6 roles × all endpoints = allowed/not allowed) | Phước (Publisher) | 🟢 Medium |

**RBAC flow (DA-E14-01):**
1. `@RequireRole({AGENCY_OWNER, ACCOUNT_MANAGER})` annotation on controller methods
2. Spring AOP aspect intercepts, reads `X-User-Role` header from API Gateway
3. If role not in allowed list → 403 Forbidden
4. Annotation supports single role `@RequireRole(Role.AGENCY_OWNER)` or multiple roles

**Workspace isolation (DA-E14-02):**
- API Gateway injects `X-Workspace-Id` header (from JWT)
- Business-service filter intercepts all requests, ensures every MongoDB query has workspaceId match
- Users without workspaceId → handled gracefully (e.g., newly registered users)

**Client isolation (DA-E14-03):**
- BRAND_CLIENT role can ONLY access data with `clientId == currentUser.clientId`
- Applied on: GET /clients (own brand only), GET /content (own brand's content only)

> ⚠️ **E14 là foundational epic** — DA-E14-01 (@RequireRole) block tất cả các task khác cần authorization trong E15/E16. Phải làm đầu tuần 1.

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
| DA-E16-01 | Implement POST /api/v1/clients (AGENCY_OWNER creates new brand client) | Phước (Publisher) | 🔴 Critical |
| DA-E16-02 | Implement PUT /api/v1/clients/{id}/assign (AGENCY_OWNER assigns Account Manager) | Phước (Publisher) | 🔴 Critical |
| DA-E16-03 | Implement PUT /api/v1/clients/{id}/service-package (set post limit/month and platforms) | Phước (Publisher) | 🟡 High |
| DA-E16-04 | Implement GET /api/v1/clients (AGENCY_OWNER and ACCOUNT_MANAGER view client list) | Phước (Publisher) | 🔴 Critical |

**Client document fields:**
`clientId`, `workspaceId`, `name`, `industry`, `brandColor`, `logoUrl`, `assignedAccountManagerId`, `servicePackage: {postsPerMonth, platforms[], aiCreditsPerMonth}`, `createdAt`

**Notes:**
- ACCOUNT_MANAGER can only see clients assigned to them (`assignedAccountManagerId == currentUserId`).
- Service package on client is separate from workspace subscription — client-level limit ≤ workspace subscription limit.

---

## EPIC E35 — Auth & Dashboard Pages 🔀 *(dời từ Sprint 12)*

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| **Trung — Auth Pages** |
| DA-E35-01 | Build Login page (email/password form, error states, redirect to dashboard) | Trung (Leader) | 🔴 Critical |
| DA-E35-05 🆕 | Build Register page (account creation form, validation, redirect to dashboard) | Trung (Leader) | 🔴 Critical |
| DA-E35-06 🆕 | Build Google OAuth button + callback page (OAuth flow, handle new vs existing user) | Trung (Leader) | 🔴 Critical |
| **Phước — Dashboard** |
| DA-E35-02 | Build main Dashboard page (overview: total posts, success rate, team activity, AI credits, connected accounts) | Phước (Publisher) | 🔴 Critical |
| **Trung — Workspace Pages** |
| DA-E35-03 | Build Create Workspace page (form: name, industry; redirect to workspace after create) | Trung (Leader) | 🔴 Critical |
| DA-E35-07 🆕 | Build Workspace Settings page (timezone selector, default platforms, report frequency) | Trung (Leader) | 🟡 High |
| DA-E35-08 🆕 | Build Workspace Members page (member table, invite button, remove action with confirm) | Trung (Leader) | 🔴 Critical |
| **Phước — Client Pages** |
| DA-E35-04 | Build Client List page (table with search, filter by status, role-based visibility) | Phước (Publisher) | 🔴 Critical |
| DA-E35-09 🆕 | Build Create Client page (form: name, industry, brand color picker, logo upload) | Phước (Publisher) | 🔴 Critical |
| DA-E35-10 🆕 | Build Edit Client page (pre-filled form: name, industry, brand color, logo) | Phước (Publisher) | 🟡 High |
| DA-E35-11 🆕 | Build Client Service Package page (posts/month input, platform checkboxes, AI credits slider) | Phước (Publisher) | 🟡 High |

**Dashboard widgets (DA-E35-02):**
- Total posts this month (by status)
- Publishing success rate (last 30 days)
- Recent team activity feed
- AI credits used / available
- Connected social accounts status (quick view)

**AuthGuard (role-based routing, component sẵn có từ Sprint 5 — DA-E34-03):**
- `/dashboard` → all authenticated roles
- `/workspace` → AGENCY_OWNER only
- `/clients` → AGENCY_OWNER, ACCOUNT_MANAGER
- `/content` → ACCOUNT_MANAGER, CONTENT_CREATOR
- `/portal` → BRAND_CLIENT only

**Notes:**
- 🆕 = task mới tách từ task gốc (E35-01 → E35-01+05+06; E35-03 → E35-03+07+08; E35-04 → E35-04+09+10+11)
- Các task cùng page nhưng tách riêng để code/review độc lập

---

## EPIC E36 — Content Management Pages 🔀 *(dời từ Sprint 12)*

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| **Phước — Content Request** |
| DA-E36-01 | Build Content Request list page (filter by status, platform, deadline; table with pagination) | Phước (Publisher) | 🔴 Critical |
| **Phước — Content Editor** |
| DA-E36-02 | Build Content Editor page (form: caption textarea, hashtag input, platform selector, image upload, schedule date) | Phước (Publisher) | 🔴 Critical |
| DA-E36-06 🆕 | Build AI Generate Panel ("Generate with AI" button → call ai-service → display caption + hashtag + image; regenerate with feedback; "Use this" inserts into editor) | Phước (Publisher) | 🔴 Critical |
| **Phước — Calendar & Preview** |
| DA-E36-03 | Build Content Calendar page (calendar view + drag-drop rescheduling) | Phước (Publisher) | 🔴 Critical |
| DA-E36-04 | Build Platform Preview modal (accurately preview the format of each platform) | Phước (Publisher) | 🟡 High |
| **Phước — Content Library** |
| DA-E36-05 | Build Media Browser page (S3 file browser, upload, folder view) | Phước (Publisher) | 🟡 High |
| DA-E36-07 🆕 | Build Template Browser page (saved post drafts list, search, preview, use template) | Phước (Publisher) | 🟡 High |
| DA-E36-08 🆕 | Build Hashtag Groups page (CRUD hashtag groups, assign to posts) | Phước (Publisher) | 🟡 High |

**Content Editor AI panel (DA-E36-06):**
- "Generate with AI" button → calls `POST /api/v1/posts/ai-generate`
- Shows loading spinner (10s typical)
- Displays: generated caption, hashtags, generated image (if selected)
- "Regenerate" button with feedback input
- "Use this" button inserts into editor

**Notes:**
- DA-E36-03 ContentCalendar uses the React component built in Sprint 10 (DA-E30-03).
- DA-E36-04 PlatformPreview uses the component built in Sprint 10 (DA-E30-04).
- 🆕 = task mới tách từ task gốc (E36-02 → E36-02+06; E36-05 → E36-05+07+08)
- Các task cùng page nhưng tách riêng để code/review độc lập

---

## Sprint 6 Checklist

- [ ] @RequireRole annotation works: AGENCY_OWNER accesses protected endpoints, other roles get 403
- [ ] Workspace isolation: all MongoDB queries include workspaceId filter
- [ ] Client isolation: BRAND_CLIENT can only view their own brand's data
- [ ] Permission matrix document: complete 6 roles × all endpoints
- [ ] POST /api/v1/workspaces creates workspace, creator becomes AGENCY_OWNER
- [ ] Invite member: email sent, user added to workspace_members on accept
- [ ] Remove member: user loses workspace access immediately
- [ ] Workspace settings: timezone + default platforms + report frequency saved
- [ ] POST /api/v1/clients creates client under workspace
- [ ] Assign account manager: client.assignedAccountManagerId updated
- [ ] Service package set: postsPerMonth + platforms enforced
- [ ] Login page: email/password form, redirects to dashboard
- [ ] Register page: account creation form, redirects to dashboard
- [ ] Google OAuth button: initiates OAuth flow, handles callback
- [ ] Dashboard page: widgets load with real API data
- [ ] Create Workspace page: form with name + industry
- [ ] Workspace Settings page: timezone + platforms selector
- [ ] Workspace Members page: member list + invite/remove actions
- [ ] Client List page: table with search + role filter
- [ ] Create Client page: form with all fields
- [ ] Edit Client page: edit form pre-filled
- [ ] Client Service Package page: posts/month + platforms + AI credits config
- [ ] Content Request list: filters by status/platform/deadline work
- [ ] Content Editor page: form fields + platform selector + validation
- [ ] AI Generate Panel: calls API, displays caption + hashtag + image, regenerate
- [ ] Content Calendar: calendar view renders, drag-drop reschedules
- [ ] Platform Preview: shows correct format per platform
- [ ] Media Browser: S3 file browser with upload
- [ ] Template Browser: saved post drafts list
- [ ] Hashtag Groups: CRUD hashtag groups

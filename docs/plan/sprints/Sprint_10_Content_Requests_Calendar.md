# Sprint 10 — Content Requests & Calendar

**Timeline:** Weeks 19–20 (Sep 23–Oct 6, 2026)
**Jira:** DA Sprint 10
**Phase:** Phase 5 — Content Workflow & Publishing
**Goal:** Implement the content request lifecycle, task assignment to Content Creators, and the content calendar with drag-drop scheduling.

> **AI Parallel:** AI Iteration 3 runs concurrently this sprint (final week).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E28 | Content Request Management | Trung |
| E29 | Task Assignment & Tracking | Trung, Ân |
| E30 | Content Calendar & Scheduling | Trung, Lộc |

**Note on Epic numbering:** Epics E25–E27 are reserved for potential scope expansion. No tasks are missing.

**Deliverables by end of Sprint 10:**
- BRAND_CLIENT can submit content requests
- ACCOUNT_MANAGER can view and assign requests to Content Creators
- CONTENT_CREATOR can view their task list
- Deadline alert notifications working
- Content calendar shows posts by date range
- ACCOUNT_MANAGER can schedule a post (set scheduledAt + target platforms)
- ContentCalendar React component with drag-drop
- PlatformPreview component

---

## EPIC E28 — Content Request Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E28-01 | Implement POST /api/v1/content-requests (BRAND_CLIENT submits request: topic, platform, tone, deadline) | Trung (Leader) | 🔴 Critical |
| DA-E28-02 | Implement GET /api/v1/content-requests (ACCOUNT_MANAGER views list of requests from their assigned clients) | Trung (Leader) | 🔴 Critical |
| DA-E28-03 | Implement status tracking (SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED → REJECTED) | Trung (Leader) | 🔴 Critical |

**ContentRequest document fields:**
`requestId`, `workspaceId`, `clientId`, `topic`, `platform[]`, `tone`, `deadline`, `status`, `assignedCreatorId`, `linkedPostId`, `createdAt`, `updatedAt`

**Status transition rules:**
- BRAND_CLIENT: SUBMITTED only
- ACCOUNT_MANAGER: SUBMITTED→ASSIGNED, PENDING_REVIEW→SENT_TO_CLIENT, SENT_TO_CLIENT→APPROVED/REJECTED
- CONTENT_CREATOR: ASSIGNED→IN_PROGRESS, IN_PROGRESS→PENDING_REVIEW
- System: SENT_TO_CLIENT→APPROVED/REJECTED (via client portal action)

---

## EPIC E29 — Task Assignment & Tracking

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E29-01 | Implement PUT /api/v1/content-requests/{id}/assign (ACCOUNT_MANAGER assigns task to CONTENT_CREATOR) | Trung (Leader) | 🔴 Critical |
| DA-E29-02 | Implement GET /api/v1/content-requests/my-tasks (CONTENT_CREATOR views their assigned tasks) | Trung (Leader) | 🔴 Critical |
| DA-E29-03 | Implement deadline management (alert when a task is approaching its deadline) | Ân (AI) | 🟡 High |

**Deadline alert (DA-E29-03):**
- Check every hour: query tasks where `deadline < now + 24h AND status NOT IN [APPROVED, REJECTED]`
- Create notification for CONTENT_CREATOR (if IN_PROGRESS) or ACCOUNT_MANAGER (if SUBMITTED/ASSIGNED)
- Also alert if `deadline < now` (overdue): create OVERDUE notification

---

## EPIC E30 — Content Calendar & Scheduling

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E30-01 | Implement GET /api/v1/posts/calendar (retrieve posts by date range, filter by platform/status) | Trung (Leader) | 🔴 Critical |
| DA-E30-02 | Implement POST /api/v1/posts/{id}/schedule (ACCOUNT_MANAGER sets schedule: scheduledAt + targetPlatforms) | Trung (Leader) | 🔴 Critical |
| DA-E30-03 | Build ContentCalendar React component (drag-drop rescheduling, color-coded status indicators) | Lộc (Frontend) | 🔴 Critical |
| DA-E30-04 | Build PlatformPreview component (display preview in the correct format for FB, IG, TikTok, Threads) | Lộc (Frontend) | 🟡 High |

**Calendar API (DA-E30-01):**
```
GET /api/v1/posts/calendar?startDate=2026-10-01&endDate=2026-10-31&platform=FACEBOOK&status=SCHEDULED
Response: [{postId, title, scheduledAt, platforms[], status, thumbnailUrl}]
```

**ContentCalendar component (DA-E30-03):**
- Use `react-big-calendar` or `@fullcalendar/react` library
- Color coding: DRAFT=gray, SCHEDULED=blue, PUBLISHED=green, FAILED=red, PENDING_REVIEW=yellow
- Drag post to new date → calls `PUT /api/v1/posts/{id}/reschedule`

**PlatformPreview (DA-E30-04):**
- FB: 1200x630 link preview card format
- IG: square (1:1) or portrait (4:5) image with caption below
- TikTok: vertical (9:16) video thumbnail with overlay text
- Threads: text post format, truncated at 500 chars

**Notes:**
- Scheduling a post does NOT immediately enqueue to RabbitMQ — that happens when the post reaches APPROVED status (Sprint 11).
- `targetPlatforms` can be a subset of connected social accounts.

---

## Sprint 10 Checklist

- [ ] BRAND_CLIENT can submit content request with topic, platform, tone, deadline
- [ ] ACCOUNT_MANAGER sees all requests from their clients (not other clients)
- [ ] Status transitions enforce role rules (BRAND_CLIENT cannot jump to ASSIGNED)
- [ ] ACCOUNT_MANAGER can assign request to CONTENT_CREATOR
- [ ] CONTENT_CREATOR sees only their assigned tasks
- [ ] Deadline alert: notification 24h before deadline
- [ ] Overdue alert: notification when deadline passes
- [ ] Calendar API returns posts for date range with filters
- [ ] Schedule API: sets scheduledAt + targetPlatforms on post
- [ ] ContentCalendar React component renders with correct colors
- [ ] Drag-drop reschedule calls API and updates calendar
- [ ] PlatformPreview shows correct format for FB, IG, TikTok, Threads

# Sprint 13 — Client Portal, Analytics & Notifications

**Timeline:** Weeks 25–26 (Nov 4–17, 2026)
**Jira:** DA Sprint 13
**Phase:** Phase 6 — Frontend & Analytics
**Goal:** Build the isolated Brand Client portal, analytics dashboard with charts, automated report generation, and the notification center.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E37 | Client Portal | Lộc |
| E38 | Analytics & Reporting | Trung, Ân, Lộc |
| E39 | Notification System | Trung, Lộc |

**Deliverables by end of Sprint 13:**
- Brand Client can log in to an isolated portal (only sees own data)
- Client can view calendar, approve/reject posts
- Analytics Dashboard with charts (success rate, platform breakdown, campaign performance)
- Automated weekly/monthly PDF reports emailed to clients
- Notification center: bell icon, unread badge, mark as read

---

## EPIC E37 — Client Portal

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E37-01 | Build Client Portal login (isolated, only shows data for the logged-in client) | Lộc (Frontend) | 🔴 Critical |
| DA-E37-02 | Build Client Calendar (read-only, view only, no editing) | Lộc (Frontend) | 🔴 Critical |
| DA-E37-03 | Build Client Approval page (view preview → approve/reject with feedback) | Lộc (Frontend) | 🔴 Critical |
| DA-E37-04 | Build Client Analytics page (publishing results, success rate, campaign summary) | Lộc (Frontend) | 🟡 High |

**Client isolation (DA-E37-01):**
- BRAND_CLIENT role enforced by RBAC (Sprint 5)
- All API calls include `clientId` filter at backend
- Client cannot navigate to `/workspace`, `/clients`, or `/content` pages
- Separate route prefix: `/portal/*`

**Client Approval page (DA-E37-03):**
- Shows posts in SENT_TO_CLIENT status
- For each post: platform preview, caption, hashtags, scheduled date
- "Approve" button → `POST /api/v1/posts/{id}/client-approve`
- "Request Changes" button → textarea for feedback → `POST /api/v1/posts/{id}/client-reject`

---

## EPIC E38 — Analytics & Reporting

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E38-01 | Implement analytics aggregation APIs (aggregate data from posts + publish_logs) | Trung (Leader) | 🔴 Critical |
| DA-E38-02 | Implement automated report generation (weekly/monthly PDF report for clients) | Trung (Leader) | 🟡 High |
| DA-E38-03 | Implement report email sending (automatically send email to Brand Client on schedule) | Ân (AI) | 🟡 High |
| DA-E38-04 | Build Analytics Dashboard (charts: publishing success rate, platform breakdown, campaign performance) | Lộc (Frontend) | 🔴 Critical |

**Analytics API endpoints (DA-E38-01):**
```
GET /api/v1/analytics/overview?clientId=&period=30d
Response: {totalPosts, publishedPosts, failedPosts, successRate, postsByPlatform{}, postsByStatus{}}

GET /api/v1/analytics/timeline?clientId=&startDate=&endDate=&groupBy=day
Response: [{date, published, failed, pending}]
```

**PDF report (DA-E38-02):**
- Use `iTextPDF` (Java) or `jasperreports` library
- Contents: cover page, summary stats, posts table, platform breakdown chart
- Stored in S3 at `reports/{workspaceId}/{clientId}/{year}-{month}.pdf`
- Schedule: weekly (Monday 8:00 AM) and monthly (1st of month 8:00 AM)

**Charts (DA-E38-04):**
- Use `Recharts` library
- Line chart: posts published per day (30-day view)
- Pie chart: breakdown by platform
- Bar chart: success rate per platform
- KPI cards: total posts, success rate %, avg time to publish

---

## EPIC E39 — Notification System

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E39-01 | Implement notification CRUD APIs (/api/v1/notifications: GET, PUT read, PUT read-all) | Trung (Leader) | 🟡 High |
| DA-E39-02 | Implement notification creation when events occur (post published, task assigned, token expiry, etc.) | Trung (Leader) | 🔴 Critical |
| DA-E39-03 | Build Notification Center UI (dropdown bell icon, unread badge, list with mark as read) | Lộc (Frontend) | 🟡 High |

**Notification types (DA-E39-02):**
| Event | Recipient | Message |
|---|---|---|
| Post published | CONTENT_CREATOR, ACCOUNT_MANAGER | "Post '{title}' published on {platform}" |
| Post failed | ACCOUNT_MANAGER | "Post '{title}' failed to publish on {platform}" |
| Task assigned | CONTENT_CREATOR | "New task assigned: {topic}" |
| Post submitted for review | ACCOUNT_MANAGER | "'{title}' is ready for review" |
| Post sent to client | BRAND_CLIENT | "'{title}' is awaiting your approval" |
| Token expiring in 3 days | ACCOUNT_MANAGER | "{platform} token expiring in 3 days" |
| Deadline in 24h | CONTENT_CREATOR | "Task '{topic}' deadline in 24 hours" |

**Notification Center UI (DA-E39-03):**
- Bell icon in Navbar with red badge showing unread count
- Dropdown: list of last 20 notifications, newest first
- Click notification → navigate to relevant page + mark as read
- "Mark all as read" button

---

## Sprint 13 Checklist

- [ ] BRAND_CLIENT logs in, sees only own client data
- [ ] Client Calendar shows posts in read-only view
- [ ] Client can approve a post → post status changes to SCHEDULED
- [ ] Client can reject a post with feedback → status returns to DRAFT
- [ ] Analytics overview API returns correct aggregated data
- [ ] PDF report generated for a client (check S3 file exists)
- [ ] Report email sent to Brand Client on schedule
- [ ] Analytics Dashboard: all 4 chart types render with real data
- [ ] Notification created on task assign, post status change, token expiry
- [ ] Bell icon shows unread count
- [ ] Dropdown shows last 20 notifications
- [ ] Click notification → navigate to correct page + mark as read
- [ ] Mark all as read: badge resets to 0

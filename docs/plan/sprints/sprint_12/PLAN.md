# Sprint 12 — Core Pages

**Timeline:** Weeks 23–24 (Oct 21–Nov 3, 2026)
**Jira:** DA Sprint 12
**Phase:** Phase 6 — Frontend & Analytics
**Goal:** Build all core web-dashboard pages: auth, dashboard, workspace management, client management, and content management.

> **AI Parallel:** AI Iteration 4 runs concurrently this sprint (final week).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E35 | Auth & Dashboard Pages | Phước |
| E36 | Content Management Pages | Phước |

> 🔀 **Rebalance sau Sprint 4:** Lộc chuyển hẳn sang AI Sub-lead, không làm Frontend nữa. E35–E36 chuyển từ Lộc sang Phước (đã có nền UI, đảm nhiệm toàn bộ Web Dashboard + Mobile App từ Sprint 5). **EPIC E34 (Design System) đã dời lên Sprint 5** — component base đã có sẵn từ đó, không cần setup lại ở đây. Chi tiết: [Rebalance Log](../../Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4).

**Deliverables by end of Sprint 12:**
- Login/Register/OAuth pages working
- Main Dashboard, Workspace, Client management pages
- Content Request list, Content Editor with AI panel, Content Calendar

---

## EPIC E35 — Auth & Dashboard Pages

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E35-01 | Build Login/Register pages with Google OAuth button | Phước (Publisher) | 🔴 Critical |
| DA-E35-02 | Build main Dashboard page (overview: total posts, success rate, team activity) | Phước (Publisher) | 🔴 Critical |
| DA-E35-03 | Build Workspace management pages (create, settings, members) | Phước (Publisher) | 🔴 Critical |
| DA-E35-04 | Build Client management pages (list, create, edit, service package) | Phước (Publisher) | 🔴 Critical |

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

---

## EPIC E36 — Content Management Pages

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E36-01 | Build Content Request list page (filter by status, platform, deadline) | Phước (Publisher) | 🔴 Critical |
| DA-E36-02 | Build Content Editor page with AI Generate Panel (call ai-service, display caption + hashtag + image) | Phước (Publisher) | 🔴 Critical |
| DA-E36-03 | Build Content Calendar page (calendar view + drag-drop rescheduling) | Phước (Publisher) | 🔴 Critical |
| DA-E36-04 | Build Platform Preview modal (accurately preview the format of each platform) | Phước (Publisher) | 🟡 High |
| DA-E36-05 | Build Content Library page (media browser, template browser, hashtag groups) | Phước (Publisher) | 🟡 High |

**Content Editor AI panel (DA-E36-02):**
- "Generate with AI" button → calls `POST /api/v1/posts/ai-generate`
- Shows loading spinner (10s typical)
- Displays: generated caption, hashtags, generated image (if selected)
- "Regenerate" button with feedback input
- "Use this" button inserts into editor

**Notes:**
- DA-E36-03 ContentCalendar uses the React component built in Sprint 10 (DA-E30-03).
- DA-E36-04 PlatformPreview uses the component built in Sprint 10 (DA-E30-04).
- DA-E36-05 Content Library: MVP scope = media files uploaded to S3 for the workspace. Template browser = saved post drafts.

---

## Sprint 12 Checklist

- [ ] Sidebar + Navbar render with correct role-based menu items (component từ Sprint 5)
- [ ] AuthGuard redirects unauthenticated users to /login
- [ ] Login page: email/password login works
- [ ] Login page: Google OAuth button initiates OAuth flow
- [ ] Register page: creates account, redirects to dashboard
- [ ] Dashboard page: widgets load with real API data
- [ ] Workspace settings page: update timezone + platforms
- [ ] Invite member: form works, email sent
- [ ] Client list: shows clients with correct role filter
- [ ] Create client: form creates client, appears in list
- [ ] Content Request list: filters by status/platform/deadline work
- [ ] Content Editor: AI Generate panel calls API and displays result
- [ ] Regenerate with feedback: works
- [ ] Content Calendar: calendar view renders, drag-drop reschedules
- [ ] Platform Preview: shows correct format per platform

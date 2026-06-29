# Sprint 12 — Design System & Core Pages

**Timeline:** Weeks 23–24 (Oct 21–Nov 3, 2026)
**Jira:** DA Sprint 12
**Phase:** Phase 6 — Frontend & Analytics
**Goal:** Set up the web-dashboard design system and build all core pages: auth, dashboard, workspace management, client management, and content management.

> **AI Parallel:** AI Iteration 4 runs concurrently this sprint (final week).

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E34 | Design System & Base Components | Lộc |
| E35 | Auth & Dashboard Pages | Lộc |
| E36 | Content Management Pages | Lộc |

**Deliverables by end of Sprint 12:**
- shadcn/ui + Tailwind configured with custom design tokens
- Full common component library built
- Login/Register/OAuth pages working
- Main Dashboard, Workspace, Client management pages
- Content Request list, Content Editor with AI panel, Content Calendar

---

## EPIC E34 — Design System & Base Components

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E34-01 | Set up shadcn/ui + Tailwind CSS + custom design tokens in web-dashboard | Lộc (Frontend) | 🔴 Critical |
| DA-E34-02 | Build common components: Button, Input, Modal, Toast, Table, Badge, Spinner, Dropdown | Lộc (Frontend) | 🔴 Critical |
| DA-E34-03 | Build layout components: Sidebar, Navbar, PageWrapper, AuthGuard | Lộc (Frontend) | 🔴 Critical |
| DA-E34-04 | Set up API service layer (Axios instance + interceptors + token refresh) | Lộc (Frontend) | 🔴 Critical |
| DA-E34-05 | Set up Zustand stores (authStore, workspaceStore, notificationStore) | Lộc (Frontend) | 🔴 Critical |

**Design tokens (DA-E34-01):**
```css
--color-primary: brand color (from client settings)
--color-success: #22c55e
--color-warning: #f59e0b
--color-danger: #ef4444
--radius: 0.5rem
--font-sans: Inter, system-ui
```

**Axios interceptors (DA-E34-04):**
- Request interceptor: inject `Authorization: Bearer {accessToken}` from authStore
- Response interceptor: on 401 → call `/api/v1/auth/refresh` → retry original request → on refresh fail → logout + redirect to `/login`

**Zustand authStore:**
```ts
{user, accessToken, isAuthenticated, login(), logout(), refreshToken()}
```

---

## EPIC E35 — Auth & Dashboard Pages

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E35-01 | Build Login/Register pages with Google OAuth button | Lộc (Frontend) | 🔴 Critical |
| DA-E35-02 | Build main Dashboard page (overview: total posts, success rate, team activity) | Lộc (Frontend) | 🔴 Critical |
| DA-E35-03 | Build Workspace management pages (create, settings, members) | Lộc (Frontend) | 🔴 Critical |
| DA-E35-04 | Build Client management pages (list, create, edit, service package) | Lộc (Frontend) | 🔴 Critical |

**Dashboard widgets (DA-E35-02):**
- Total posts this month (by status)
- Publishing success rate (last 30 days)
- Recent team activity feed
- AI credits used / available
- Connected social accounts status (quick view)

**AuthGuard (role-based routing):**
- `/dashboard` → all authenticated roles
- `/workspace` → AGENCY_OWNER only
- `/clients` → AGENCY_OWNER, ACCOUNT_MANAGER
- `/content` → ACCOUNT_MANAGER, CONTENT_CREATOR
- `/portal` → BRAND_CLIENT only

---

## EPIC E36 — Content Management Pages

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E36-01 | Build Content Request list page (filter by status, platform, deadline) | Lộc (Frontend) | 🔴 Critical |
| DA-E36-02 | Build Content Editor page with AI Generate Panel (call ai-service, display caption + hashtag + image) | Lộc (Frontend) | 🔴 Critical |
| DA-E36-03 | Build Content Calendar page (calendar view + drag-drop rescheduling) | Lộc (Frontend) | 🔴 Critical |
| DA-E36-04 | Build Platform Preview modal (accurately preview the format of each platform) | Lộc (Frontend) | 🟡 High |
| DA-E36-05 | Build Content Library page (media browser, template browser, hashtag groups) | Lộc (Frontend) | 🟡 High |

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

- [ ] `npm run dev` starts with shadcn + Tailwind, no console errors
- [ ] All common components render correctly (Button, Input, Modal, Toast, Table, Badge)
- [ ] Sidebar + Navbar render with correct role-based menu items
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

> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile Task List/Kanban/Calendar, Rich Content Editor, 3-Tier Approvals, Local Reminders & Chat

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-task-workflow` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `mobile-task-workflow`, `mobile-native-enhancements (Local Task Reminders <= 40 & Haptics)` |
| **Aligned SRS Domains** | [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.1–3.6.35`) · [3.8 Publishing & Social](../../../srs/07-publishing-social/README.md) (`3.8.3–3.8.7`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver complete mobile Task & Content execution parity (`brandhub-mobile-app`): **Task List, Kanban Board & Calendar Timeline** (`TaskListScreen`, `TaskKanbanScreen`, `CalendarScreen`), **Mobile Rich-Text Content Editor & Version History** (`ContentWritingEditorScreen`, `RichTextEditor`, `SocialPreview`), **3-Tier Approval Center** (`ApprovalScreen` — `Creator -> Manager -> Client` + Solo `self-approve`), **Task Comments & Attachments**, **Realtime Workspace Chat** (`ChatScreen`), and **On-Device Local Deadline Reminders** (`taskReminders.ts`).

## 2. User Stories

- As a `Creator`, `Manager`, `Owner`, or `Client`, I want to manage Tasks across List/Kanban/Calendar views, draft and preview rich social posts, comment with attachments, execute 3-tier approvals with tactile haptic feedback, and receive automatic `24h` and `1h` local deadline reminders even without opening the app.

## 3. Consolidated Acceptance Criteria

1. **Multi-View Task Management (`TaskListScreen.tsx`, `TaskKanbanScreen.tsx`, `TaskDetailScreen.tsx`, `CalendarScreen.tsx`):** Supports status/priority/assignee filtering, inline status/assignee updates, subtask checklists, survey summaries (`TaskSurveySummaryScreen.tsx`), and post dashboard/detail tracking (`PostDashboardScreen.tsx`, `PostDetailScreen.tsx`).
2. **Mobile Rich-Text Editor & Version History (`ContentWritingEditorScreen.tsx`):** `RichTextEditor.tsx` + `FormattingToolbar.tsx` + `VersionHistory.tsx` + `SocialPreview.tsx` (`Facebook`, `Instagram`, `TikTok`, `Threads` mockups) with snapshot save/restore (`useTaskContentSync.ts`) and compliance moderation banner (`editorModeration.ts`).
3. **3-Tier Approval Queue & Comments (`ApprovalScreen.tsx`):** Supports `submit`, `withdraw`, `approve`, `reject` (with mandatory revision note), `self-approve` (Personal Studio), and sectioned task review (`taskSectionService.ts`) with tactile `expo-haptics` feedback (`haptics.ts`).
4. **On-Device Local Task Deadline Reminders (`mobile-native-enhancements` AC-R1..R6, `taskReminders.ts`):** Opt-in setting (`NotificationPreferencesScreen.tsx`) schedules `1 day` and `1 hour` local `expo-notifications` alerts for open Tasks assigned to the current user (capped at `40` nearest upcoming notifications respecting iOS `64`-schedule OS limit), refreshing on app launch, cancelling completed/reassigned tasks, wiping on logout, and deep-linking directly to the Task (switching Workspace safely if needed).
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`tasks.*`, `approval.*`, `editor.*`, `calendar.*`, `reminders.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Parity with `pages/tasks/*`, `pages/content-writing/*`, `pages/calendar/*`, `pages/chat/*`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content/{TaskListScreen,TaskKanbanScreen,TaskDetailScreen,PostDetailScreen}.tsx`, `src/screens/content-writing/*`, `src/screens/approval/ApprovalScreen.tsx`, `src/screens/calendar/CalendarScreen.tsx`, `src/screens/chat/ChatScreen.tsx`, `src/services/taskReminders.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET/POST/PATCH/DELETE /api/v1/workspaces/{workspaceId}/tasks/**` | Bearer (`Owner, Manager, Creator, Client`) | `TaskController`, `TaskWorkflowController`, `TaskCommentController`, `TaskSectionController` <- `taskService.ts` |
| `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/{submit|withdraw|approve|reject|self-approve}` | Bearer (`Owner, Manager, Creator, Client`) | `TaskApprovalController` <- `ApprovalScreen.tsx` |
| `GET/POST/PATCH /api/v1/workspaces/{workspaceId}/posts/**` | Bearer (`Owner, Manager, Creator, Client`) | `PostController` <- `postDashboardService.ts` & `calendarService.ts` |

## 6. Error Handling, Security & Edge Cases

- **OS Notification Permission Denied:** Toggle reverts to `off` and provides 1-tap link to OS App Settings (`Linking.openSettings()`).
- **iOS 64-Local-Notification Cap:** `taskReminders.ts` sorts candidate triggers chronologically and schedules at most `40` nearest future slots.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.1–3.6.35`) · [3.8 Publishing & Social](../../../srs/07-publishing-social/README.md) (`3.8.3–3.8.7`)
- **BA & Architecture References:** [BA 05 Content & Task Workflow](../../../../ba/05-content-task-workflow.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

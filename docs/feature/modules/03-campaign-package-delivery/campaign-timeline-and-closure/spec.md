> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Interactive Campaign Gantt Timeline, Partner Cooperation, Request Validation & Campaign Closure

| Field | Value |
| :--- | :--- |
| **Module Slug** | `campaign-timeline-and-closure` |
| **Category** | `03-campaign-package-delivery` — Media Package Sharing, Campaign Timeline & Delivery Closure |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `campaign-timeline`, `campaign-collaborators`, `campaign-task-ux`, `campaign-navigation-corrections`, `campaign-closure`, `request-completion-validation`, `workspace-campaign-summary`, `ui-refresh` |
| **Aligned SRS Domains** | [3.5 Media Package & Media Campaign](../../../srs/04-media-package-campaign/README.md) (`3.5.5–3.5.13`) · [FR 3.7.15 Collaborator Directory](../../../srs/06-ai-features/3-7-15-view-collaborator-directory/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Unify active Campaign execution across the interactive **Gantt & Table Timeline** (`CampaignTimelineController`), per-Campaign third-party **Collaborator cooperation tracking** (`CampaignCollaboratorController` — `DA-950`), **Content Request completion validation**, Workspace Campaign summary cards, and **Campaign Closure** (`CampaignClosureController`) with out-of-scope / supplemental Request Task accounting.

## 2. User Stories

- As a `Manager` or `Owner`, I want to schedule, reorder, and color-code Campaign Tasks on an interactive Timeline, track linked third-party Collaborator cooperation states, validate all open Content Requests and deliverable Tasks before closing a Campaign, and cleanly cancel or carry over unfinished tasks upon closure.

## 3. Consolidated Acceptance Criteria

1. **Interactive Campaign Timeline (`campaign-timeline`, `campaign-task-ux`, `campaign-navigation-corrections`):** `CampaignTimelineController` (`GET /campaigns/{campaignId}/timeline`, `PATCH /tasks/{taskId}/schedule`, `POST /timeline/tasks`, `PUT /timeline/reorder-tasks`) powers synchronized Gantt (`CampaignTimelineGrid.tsx`) and Table (`CampaignTimelineTableView.tsx`) views with unscheduled-task alerts (`TimelineUnscheduledRange.tsx`), milestone rails, assignee pickers, and color coding (`GanttColorPicker.tsx`).
2. **Campaign Collaborator Cooperation (`campaign-collaborators`, `DA-950`):** `CampaignCollaboratorController` links active Agency partners (`third_party_collaborators`) into `campaign_collaborators` with independent per-Campaign `cooperation_status` (`PROPOSED`, `CONTACTED`, `CONFIRMED`, `DELIVERED`, `CANCELLED`), stamping `first_used_at` atomically and keeping historical links readable even if the partner is later deactivated.
3. **Content Request & Campaign Completion Validation (`request-completion-validation`, `campaign-closure`):** `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/completion-check` inspects all package Tasks, supplemental Content Request Tasks (`content_requests`), and pending approvals. Closing a Campaign (`POST /campaigns/{campaignId}/complete`) requires resolving or explicitly cancelling (`POST /campaigns/{campaignId}/tasks/cancel`) open tasks with recorded audit reasons.
4. **Workspace Campaign Summary & Scoped UI Polish (`workspace-campaign-summary`, `ui-refresh`):** `WorkspaceCampaignSummary.tsx` displays real-time progress bars, milestone health, and deliverable completion counts on Workspace detail/dashboard views.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`campaign.{timeline,closure,partners,brief}.*`, `contentRequests.*` in `src/i18n/locales/{vi,en}/{campaign,contentRequests}.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/campaign/components/{CampaignTimelineGrid,CampaignTimelineTableView,CampaignClosureSection,CampaignMasterBriefCard,CampaignOutOfScopeTaskDialog}.tsx`, `pages/campaign-partners/page.tsx`, `WorkspaceCampaignSummary.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/CampaignsScreen.tsx`, `CampaignDetailScreen.tsx`, `ContentRequestsScreen.tsx`, `src/components/campaign/CampaignPartnersSection.tsx`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/timeline & PATCH /tasks/{taskId}/schedule` | Bearer (`Owner, Manager, Creator, Client` read; `Owner, Manager` write) | `CampaignTimelineController` -> timeline projection & drag-reschedule |
| `GET /api/v1/workspaces/{workspaceId}/campaign-collaborators & POST /campaigns/{id}/collaborators` | Bearer (`Owner, Manager`; `Client` read) | `CampaignCollaboratorController` -> per-campaign partner linking & status updates |
| `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/completion-check & POST /complete` | Bearer (`Owner, Manager`) | `CampaignClosureController` & `WorkspaceCampaignController` -> pre-closure audit & completion |
| `POST /api/v1/workspaces/{workspaceId}/content-requests/{requestId}/{receive|accept|deny}` | Bearer (`Owner, Manager`) | `ContentRequestReviewController` -> converts accepted Client request into linked supplemental Task |

## 6. Error Handling, Security & Edge Cases

- **Closing Campaign with Pending Client Request:** Blocked (`409`) by `completion-check` until every `ContentRequestDocument` linked to the Campaign is completed, denied, or explicitly resolved.
- **Task Scheduled Outside Campaign Window:** Surfaces warning indicator on `TimelinePendingRange.tsx` / rejects invalid inverted start/end dates (`400`).

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.5 Media Package & Media Campaign](../../../srs/04-media-package-campaign/README.md) (`3.5.5–3.5.13`) · [FR 3.7.15 Collaborator Directory](../../../srs/06-ai-features/3-7-15-view-collaborator-directory/spec.md)
- **BA & Architecture References:** [BA 04 Media Package & Campaign](../../../../ba/04-media-package-campaign.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

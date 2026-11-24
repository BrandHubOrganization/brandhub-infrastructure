> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile Media Package Review, Campaign Tracking & Client Content Request Workflows

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-package-campaign` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Consolidated Feature Scopes** | `mobile-package-campaign`, `mobile-nav-role-parity (Content Requests & Campaign Partners)` |
| **Aligned SRS Domains** | [3.5 Media Package & Media Campaign](../../../srs/04-media-package-campaign/README.md) (`3.5.1–3.5.13`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Enable `Owner`, `Manager`, and `Client` users on the go to inspect and approve **Workspace Media Packages** (`MediaPackageScreen.tsx`), monitor **Media Campaigns & Collaborator Partners** (`CampaignsScreen.tsx`, `CampaignDetailScreen.tsx`, `CampaignPartnersSection.tsx`), and execute the full **Client Content Request lifecycle** (`ContentRequestsScreen.tsx`, `ContentRequestDetailScreen.tsx`, `ContentRequestFormScreen.tsx`) with optimistic version concurrency (`expectedVersion`).

## 2. User Stories

- As a `Client` away from my desk, I want to review and approve proposed Media Packages and Campaigns, submit supplemental Content Requests with attachments/deadlines, and track request acceptance on my phone.
- As a `Manager` or `Owner`, I want to receive, accept (spawning a Campaign Task), or deny Client Content Requests with clear reason notes directly from mobile.

## 3. Consolidated Acceptance Criteria

1. **Media Package Inspection, Negotiation & Approval (`MediaPackageScreen.tsx`):** Displays deliverable line items, pricing/cycle model, negotiation history (`GET /media-package/history`), counter-proposal notes (`PATCH /media-package/negotiate`), and 1-tap `Client`/`Manager` approval (`POST /media-package/approve`).
2. **Campaign Overview, Brief & Partner Tracking (`CampaignsScreen.tsx`, `CampaignDetailScreen.tsx`):** Renders Campaign master brief, milestone progress, deliverable task breakdown, Campaign approval (`POST /campaigns/{id}/approve`), and linked third-party Collaborator statuses (`CampaignPartnersSection.tsx`).
3. **Full Content Request CRUD & Review (`ContentRequestsScreen.tsx`, `ContentRequestDetailScreen.tsx`, `ContentRequestFormScreen.tsx`):** Driven by backend `can*` capability flags and `expectedVersion` optimistic concurrency (`contentRequest.ts`), formatting deadlines in Workspace timezone (`DD/MM/YYYY HH:mm`) and enforcing `Creator` exclusion per `ContentRequestAccess`.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`mediaPackage.*`, `campaign.*`, `contentRequests.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Parity with `pages/campaign/*`, `pages/client/components/{ServicePackageModal,ClientContentRequests}.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/{MediaPackageScreen,CampaignsScreen,CampaignDetailScreen,ContentRequestsScreen,ContentRequestDetailScreen,ContentRequestFormScreen}.tsx`, `src/components/campaign/CampaignPartnersSection.tsx`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET/POST/PATCH /api/v1/workspaces/{workspaceId}/media-package[/negotiate|/approve|/history]` | Bearer (`Owner, Manager, Client`) | `MediaPackageController` & `PackageNegotiationHistoryController` <- `mediaPackageService.ts` |
| `GET/POST /api/v1/workspaces/{workspaceId}/campaigns/** & /campaign-collaborators` | Bearer (`Owner, Manager, Client`) | `WorkspaceCampaignController` & `CampaignCollaboratorController` <- `campaignService.ts` |
| `GET/POST/PATCH/DELETE /api/v1/workspaces/{workspaceId}/content-requests/** & /{id}/{receive|accept|deny}` | Bearer (`Owner, Manager, Client`) | `ContentRequestController` & `ContentRequestReviewController` <- `contentRequestService.ts` |

## 6. Error Handling, Security & Edge Cases

- **Stale Content Request Edit (`409 CONFLICT`):** Mobile form prompts user to reload latest version when `Manager` receives/locks a request while `Client` is editing.
- **Deadline Validation:** Rejects past deadlines in Workspace IANA timezone before submission.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.5 Media Package & Media Campaign](../../../srs/04-media-package-campaign/README.md) (`3.5.1–3.5.13`)
- **BA & Architecture References:** [BA 04 Media Package & Campaign](../../../../ba/04-media-package-campaign.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

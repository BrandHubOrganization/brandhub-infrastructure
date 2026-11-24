> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Manager-Led Media Package Offering Models, Public Guest Share Token & Task Seeding

| Field | Value |
| :--- | :--- |
| **Module Slug** | `manager-led-media-package-sharing` |
| **Category** | `03-campaign-package-delivery` — Media Package Sharing, Campaign Timeline & Delivery Closure |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Client` |
| **Consolidated Feature Scopes** | `guest-sharing-manager-led`, `offering-models`, `package-simplification`, `package-quantity-input`, `package-driven-campaign-tasks`, `media-workspace-ux` |
| **Aligned SRS Domains** | [3.5 Media Package & Media Campaign](../../../srs/04-media-package-campaign/README.md) (`3.5.1–3.5.9`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Streamline the commercial Media Package lifecycle from Agency template creation (`offering-models`, `package-simplification`, `package-quantity-input`), public token-gated `Guest` share links (`GET /api/v1/public/media-packages/{token}`), and `Manager`-led Workspace package planning (`WorkspacePackagePlanningController`) through `Client` negotiation/approval and deterministic Campaign deliverable Task generation (`package-driven-campaign-tasks`).

## 2. User Stories

- As an `Owner` or `Manager`, I want to configure structured Media Package deliverables (fixed bundle, flexible item quantities, or recurring monthly cadence), share read-only public preview links with prospective `Guest` leads, and automatically materialize Campaign Tasks once the `Client` approves the Workspace package.

## 3. Consolidated Acceptance Criteria

1. **Structured Offering Models & Clean Quantity Editing (`offering-models`, `package-simplification`, `package-quantity-input`):** Supports `FIXED_BUNDLE`, `CUSTOM_QUOTE`, and `RETAINER` package structures with typed deliverable line items (`taskType`, `platform`, `quantity >= 1`, unit description). Numeric quantity inputs allow clean backspace/retype without `NaN` or sticky leading-zero bugs.
2. **Token-Gated Public `Guest` Sharing (`guest-sharing-manager-led`, `2026-11-06-manager-led-package-sharing.sql`):** `MediaPackageShareController` issues revocable, optionally expiring share tokens (`GET /api/v1/public/media-packages/{token}`) exposing sanitized package deliverables and Agency branding to `Guest` viewers without leaking internal workspace notes or other clients.
3. **Manager-Led Workspace Planning & Impact Preview (`WorkspacePackagePlanningController`):** `PUT /api/v1/workspaces/{workspaceId}/media-package` and `POST /impact` compute exact deliverable deltas; `package_negotiation_events` logs every proposal, `Client` counter-note, and final approval (`POST /approve`).
4. **Deterministic Package -> Campaign -> Task Provisioning (`package-driven-campaign-tasks`):** Deploying an approved package/campaign (`POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/deploy`) idempotently generates typed deliverable Tasks (`tasks` + MongoDB `TaskDocument`) matching exact line-item quantities.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`mediaPackage.{models,share,negotiation,quantities,impact}.*` in `src/i18n/locales/{vi,en}/mediaPackage.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/client/components/ServicePackageModal.tsx`, `pages/campaign/components/CampaignDeploymentPanel.tsx`, public package share page
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/MediaPackageScreen.tsx`, `src/screens/agency/AgencyMediaPackagesScreen.tsx`, `src/services/mediaPackageService.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/media-package-templates & POST /api/v1/agencies/{agencyId}/media-package-custom` | Bearer (`Owner, Manager`) | `MediaPackageController` -> manages Agency package templates & availability |
| `GET /api/v1/public/media-packages/{token}` | Public (`Guest`) | `MediaPackageShareController` -> read-only sanitized public package view |
| `PUT /api/v1/workspaces/{workspaceId}/media-package & POST /impact & GET /history` | Bearer (`Owner, Manager, Client`) | `WorkspacePackagePlanningController` & `PackageNegotiationHistoryController` |
| `POST /api/v1/workspaces/{workspaceId}/media-package/approve` | Bearer (`Client, Owner, Manager`) | `MediaPackageController` -> locks approved Workspace package snapshot |

## 6. Error Handling, Security & Edge Cases

- **Revoked or Expired Share Token:** Returns `404/410` localized 'Link Unavailable' page to `Guest` with zero Agency internal metadata.
- **Retry Preparation / Deploy (`POST /preparation/retry`):** Idempotent task-generation key prevents duplicate Tasks if network drops mid-deploy.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.5 Media Package & Media Campaign](../../../srs/04-media-package-campaign/README.md) (`3.5.1–3.5.9`)
- **BA & Architecture References:** [BA 04 Media Package & Campaign](../../../../ba/04-media-package-campaign.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).

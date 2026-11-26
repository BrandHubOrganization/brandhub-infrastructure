> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.15 — View Collaborator Directory

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.15` |
| **Use Case ID** | `UC-102` |
| **Feature** | View Collaborator Directory |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager` |
| **Business Rules** | `BR-20`, `BR-51` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `partner-directory` DA-949 / E50-08) |

## 1. Objective & Business Value

Provide a centralized, Agency-scoped Collaborator & Media Partner Directory (`/agency/:agencyId/collaborators` for full directory administration and `/workspaces/:workspaceId/campaign-partners` active-only picker) backed by PostgreSQL `third_party_collaborators` and `campaign_collaborators` (`BR-20`, `BR-51`). Supports categorizing third-party partners (`KOL`, `KOC`, `NEWSPAPER`, `BANNER`, `TV`, `OTHER`), inspecting `isActive` lifecycle states, `canDelete` / `usageHistoryVerified` audit flags, contact metadata, and campaign cooperation links.

## 2. User Story

As an `Owner` or `Manager`, I want to browse, search, and filter the Agency's third-party Collaborator Directory with clear active/inactive badges and campaign usage status so that `Owner` can govern master partner records across the Agency while `Manager` can select active partners for Workspace Campaign execution without cross-Agency data leakage.

## 3. Acceptance Criteria

1. **Dual-Surface Role Authorization (`BR-20`, `BR-51`):**
   - **Agency Management Directory (`GET /api/v1/agencies/{agencyId}/collaborators`):** Accessible to `Owner` of `{agencyId}`, returning paginated active and inactive records (`isActive: true | false`), `version`, `firstUsedAt`, `usageHistoryVerified`, and computed `canDelete` + `deleteLockReason`.
   - **Workspace Active Picker (`GET /api/v1/workspaces/{workspaceId}/collaborators` & `GET /api/v1/collaborators/agencies/{agencyId}`):** Accessible to authorized `Owner` and `Manager` in the Workspace/Agency, returning active partners (`isActive = true`) for campaign linking without exposing cross-Agency records (`MSG07`).
   - Existing linked inactive partners on a Campaign remain readable via `GET /api/v1/workspaces/{workspaceId}/campaign-collaborators` with an explicit `Inactive` badge.
2. **Search, Category & Status Filtering:** Supports keyword search (name, niche, notes), partner type filter (`KOL`, `KOC`, `NEWSPAPER`, `BANNER`, `TV`, `OTHER`), status filter (`ACTIVE`, `INACTIVE`, `ALL`), and deterministic pagination.
3. **Contact Info Structured Rendering:** Safely renders JSONB `contactInfo` fields (`contactPerson`, `email`, `phone`, `website`, social handles) while tolerating additional legacy JSON keys.
4. **Internationalization (`vi.json` + `en.json`):** Uses key-parallel `src/i18n/locales/{vi,en}/collaborators.json` (`title`, `fields.*`, `status.active`, `status.inactive`, `filters.*`, `empty`, `loading`) on Web and `tr('collaborators.*')` on Mobile (`AgencyCollaboratorsScreen.tsx`).
5. **Light & Dark Mode Compliance:** Partner cards, filter toolbars, active/inactive status pills, and detail drawers (`pages/collaborators/page.tsx`, `DirectoryFilters.tsx`, `DirectoryResults.tsx`, `PartnerDetails.tsx`) use semantic theme tokens in both Light and Dark modes across `375px`, `768px`, and `1440px`.

## 4. UI / UX & Screen States

- **Web Surfaces:** `/agency/:agencyId/collaborators` (`pages/collaborators/page.tsx`) and `/workspaces/:workspaceId/campaign-partners` (`pages/campaign-partners/page.tsx`, `PartnerPicker.tsx`).
- **Mobile Surface:** `src/screens/agency/AgencyCollaboratorsScreen.tsx` and `src/components/campaign/CampaignPartnersSection.tsx`.
- **UI States:**
  - **Loading:** Skeleton table/cards (`collaborators.loading`).
  - **Empty:** Contextual empty state differentiating "No collaborators created yet" vs "No collaborators match current filter" with reset-filter button.
  - **Populated:** Paginated partner list with type badge, contact summary, `Active`/`Inactive` pill, and lock tooltip explaining why used/legacy partners cannot be hard-deleted.
  - **Error:** Retryable error banner (`MSG03` / `MSG07`) with zero mock fallback rows.

## 5. API Contract

| Method & Endpoint | Auth | Controller | Response |
| :--- | :--- | :--- | :--- |
| `GET /api/v1/agencies/{agencyId}/collaborators` | Bearer (`Owner`) | `DirectoryPartnerController` | `200 ApiResponse<PageResponse<DirectoryPartnerResponse>>` |
| `GET /api/v1/agencies/{agencyId}/collaborators/{id}` | Bearer (`Owner`) | `DirectoryPartnerController` | `200 ApiResponse<DirectoryPartnerResponse>` |
| `GET /api/v1/collaborators/agencies/{agencyId}` | Bearer (`Owner, Manager`) | `CollaboratorController` | `200 ApiResponse<List<CollaboratorResponse>>` |
| `GET /api/v1/workspaces/{workspaceId}/collaborators` | Bearer (`Owner, Manager`) | `CampaignCollaboratorController` | `200 ApiResponse<List<CollaboratorOptionResponse>>` (active-only picker) |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller belongs to another Agency, or non-Owner attempts full management directory mutation; generic `MEMBER` status never grants `Owner` directory privileges.
- `NOT_FOUND` (`404`, `MSG01`): Collaborator UUID does not exist or belongs to a different `agencyId` (prevents ID enumeration).
- **Inactive Partner Visibility:** Hidden from new-link active pickers, visible in management directory and on historical Campaign links.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.16 — Create Collaborator Profile](../3-7-16-create-collaborator-profile/spec.md) · [FR 3.7.17 — Update Collaborator Profile](../3-7-17-update-collaborator-profile/spec.md) · [FR 3.7.18 — Remove Collaborator Profile](../3-7-18-remove-collaborator-profile/spec.md) · [FR 3.7.19 — Recommend Collaborator](../3-7-19-recommend-collaborator/spec.md)
- **Consolidated Extension Module:** [`campaign-timeline-and-closure`](../../../modules/03-campaign-package-delivery/campaign-timeline-and-closure/spec.md) (`campaign_collaborators` cooperation tracking)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** `DirectoryPartnerControllerTest`, `DirectoryPartnerServiceTest`, `DirectoryPartnerPostgresTest` passing (`100%`), Web & Mobile views localized (`vi`/`en`) and Light/Dark verified per [test.md](./test.md).
- **Out of Scope:** Automated third-party KOL contract payment disbursement or external social inbox messaging.

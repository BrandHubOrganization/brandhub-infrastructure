> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.18 — Remove Collaborator Profile

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.18` |
| **Use Case ID** | `UC-105` |
| **Feature** | Remove Collaborator Profile (Hard Delete Unused vs Safe Deactivate Used) |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager` |
| **Business Rules** | `BR-20`, `BR-51` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `partner-directory` DA-949 / DA-950) |

## 1. Objective & Business Value

Safely retire Collaborator Profiles from an Agency Directory (`third_party_collaborators`) without ever corrupting historical or active Campaign records (`campaign_collaborators`, `BR-51`). Enforces a strict two-path lifecycle verified by PostgreSQL row locks, durable `first_used_at` + `usage_history_verified` markers, and `ON DELETE RESTRICT` foreign keys:
- **Hard Delete (`DELETE`):** Allowed **only** when `usage_history_verified = true`, `first_used_at IS NULL`, and `0` rows reference the partner in `campaign_collaborators`.
- **Safe Deactivate (`POST /{id}/deactivate`):** Required for any partner that has ever been linked to a Campaign (`first_used_at IS NOT NULL`, active links exist, or legacy `usage_history_verified = false`), setting `is_active = false` to block future Campaign assignments while preserving all existing Campaign history.

## 2. User Story

As an `Owner` (or authorized `Manager`), I want unused mistake entries to be cleanly deleted while any collaborator with Campaign history is safely deactivated (`isActive = false`) so that past Campaign deliverables and partner audit trails are never orphaned.

## 3. Acceptance Criteria

1. **Strict Delete Eligibility Gate (`BR-51`):**
   - `DELETE /api/v1/agencies/{agencyId}/collaborators/{id}` acquires a pessimistic row lock on `third_party_collaborators` (in the same lock order as Campaign assign) and succeeds (`204 No Content`) **only if** `usage_history_verified = true AND first_used_at IS NULL AND NOT EXISTS (SELECT 1 FROM campaign_collaborators ...)`.
   - If the partner has `first_used_at IS NOT NULL` (even if the old Campaign/link was later removed), has existing links, or has `usage_history_verified = false` (unverified legacy baseline), `DELETE` returns `409 CONFLICT` with actionable error code instructing deactivation instead.
2. **Idempotent Safe Deactivation (`POST /{id}/deactivate`):**
   - Sets `is_active = false` and increments `version`. Repeated deactivate on an already inactive partner returns the current DTO idempotently.
   - Database trigger (`23514` check/trigger guard) and service layer block any new `campaign_collaborators` link creation to an inactive partner across both Workspace and legacy APIs, while existing Campaign links remain readable and updatable.
3. **Race-Condition Safety:** Concurrent `assign` vs `delete`/`deactivate` serializes on the `third_party_collaborators` row lock: if `assign` wins first, `first_used_at` is stamped and `delete` rejects with `409`; if `deactivate` wins first, `assign` rejects creating a new link.
4. **Distinct UI Confirmation Flows:** `PartnerAction.tsx` renders "Delete Permanently" only when `canDelete == true`, and renders "Deactivate Partner" (with lock explanation tooltip when delete is locked) for used/legacy partners.
5. **Internationalization (`vi.json` + `en.json`):** Distinct confirmation copy (`collaborators.confirm.delete.*` vs `collaborators.confirm.deactivate.*` and `collaborators.lockReason.*`) in `vi.json` and `en.json`.
6. **Light & Dark Mode Compliance:** Confirmation dialogs, warning callouts, and `Inactive` badges use semantic Light/Dark tokens with clear visual hierarchy.

## 4. UI / UX & Screen States

- **Web Components:** `pages/collaborators/components/PartnerAction.tsx`, `PartnerQuickActions.tsx`, `PartnerDetails.tsx`.
- **Mobile Screen:** `src/screens/agency/AgencyCollaboratorsScreen.tsx` destructive/deactivate action sheet.
- **UI States:**
  - **Unused Partner (`canDelete = true`):** Offers both Deactivate and Delete Permanently with red destructive confirmation dialog.
  - **Used / Legacy Partner (`canDelete = false`):** Delete action disabled/hidden with localized explanation (`firstUsedAt` or legacy unverified history); Deactivate button prominent.
  - **Inactive Partner (`isActive = false`):** Displays `Inactive` badge; excluded from Workspace `PartnerPicker.tsx`.

## 5. API Contract

| Method & Endpoint | Auth | Handler | Response |
| :--- | :--- | :--- | :--- |
| `DELETE /api/v1/agencies/{agencyId}/collaborators/{id}` | Bearer (`Owner`) | `DirectoryPartnerController.delete()` | `204 No Content` (or `409 CONFLICT` when used/legacy) |
| `POST /api/v1/agencies/{agencyId}/collaborators/{id}/deactivate` | Bearer (`Owner`) | `DirectoryPartnerController.deactivate()` | `200 ApiResponse<DirectoryPartnerResponse>` (`isActive = false`) |
| `DELETE /api/v1/collaborators/{collaboratorId}` | Bearer (`Owner, Manager`) | `CollaboratorController.delete()` | Enforces identical FK/usage guard |

## 6. Error Handling & Edge Cases

- `PARTNER_IN_USE_OR_HISTORICAL` (`409`, `MSG03`): Partner has current links, non-null `first_used_at`, or `usage_history_verified = false`.
- `VERSION_CONFLICT` (`409`, `MSG03`): Concurrent modification mismatched `expectedVersion`.
- `FORBIDDEN` (`403`, `MSG07`): Cross-Agency or unauthorized role attempt.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.15 — View Collaborator Directory](../3-7-15-view-collaborator-directory/spec.md) · [FR 3.7.16 — Create Collaborator Profile](../3-7-16-create-collaborator-profile/spec.md) · [FR 3.7.17 — Update Collaborator Profile](../3-7-17-update-collaborator-profile/spec.md) · [FR 3.7.19 — Recommend Collaborator](../3-7-19-recommend-collaborator/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via PostgreSQL 17 isolated concurrency & trigger tests (`DirectoryPartnerPostgresTest`, `PartnerLifecycleMigrationTest` — `71 passed`), MockMvc `204/403/409` checks, `vi`/`en` i18n, and Light/Dark UI ([test.md](./test.md)).
- **Out of Scope:** Cascading deletion of Campaign collaboration history (strictly prohibited by `BR-51`).

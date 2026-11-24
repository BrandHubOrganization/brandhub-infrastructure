> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.17 — Update Collaborator Profile

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.17` |
| **Use Case ID** | `UC-104` |
| **Feature** | Update Collaborator Profile |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager` |
| **Business Rules** | `BR-20`, `BR-51` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `partner-directory` DA-949) |

## 1. Objective & Business Value

Enable authorized `Owner` (and `Manager` within permitted collaborator endpoints) to update an existing Collaborator Profile's name, category, rate-card benchmarks, notes, and `contactInfo` JSONB fields in `third_party_collaborators` using optimistic concurrency control (`expectedVersion` -> `version + 1`), while strictly preserving immutable audit markers (`agency_id`, `first_used_at`, `usage_history_verified`) and unknown legacy `contactInfo` JSON keys (`BR-51`).

## 2. User Story

As an `Owner` or `Manager`, I want to update a collaborator's contact person, phone/email, rate card, or specialty tags without losing historical Campaign links or overwriting concurrent edits made by another session.

## 3. Acceptance Criteria

1. **Agency Immutability & Role Check (`BR-20`):** Collaborator `{id}` must belong to `{agencyId}`; `agency_id` can never be mutated to transfer a partner across Agencies (`403`/`404`, `MSG01`, `MSG07`).
2. **Optimistic Concurrency (`expectedVersion`):** `PATCH /api/v1/agencies/{agencyId}/collaborators/{id}` validates `expectedVersion` against `third_party_collaborators.version`. Stale edits (including when a concurrent Campaign first-assign incremented `version` and stamped `first_used_at`) fail deterministically with `409 CONFLICT` rather than silently overwriting state.
3. **Non-Destructive JSONB Contact Merge (`BR-51`):** Updating `contactInfo` validates known fields (`contactPerson`, `email`, `phone` 7–15 digits, `http/https` `website`) and merges them while preserving any unrecognized legacy JSON keys already stored on the row.
4. **Read-Only Lifecycle Markers:** `first_used_at`, `usage_history_verified`, and `is_active` are mapped read-only for profile edit payloads; Campaign approvals and `campaign_collaborators.cooperation_status` are untouched by profile edits.
5. **Internationalization (`vi.json` + `en.json`):** Edit drawer/dialog headers, optimistic conflict banners, and save actions use synchronized `collaborators.edit.*` and `collaborators.errors.versionConflict` keys in `vi.json` and `en.json`.
6. **Light & Dark Mode Compliance:** Edit form (`PartnerForm.tsx`, `PartnerDetails.tsx`) and conflict alerts render cleanly in Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Components:** `pages/collaborators/components/PartnerForm.tsx`, `PartnerDetails.tsx`, `PartnerContactFields.tsx`.
- **Mobile Screen:** `src/screens/agency/AgencyCollaboratorsScreen.tsx` edit sheet.
- **UI States:**
  - **Prefilled Ready:** Loads current `version` and structured contact fields while keeping extra JSON keys in state.
  - **Saving:** Disables inputs and shows spinner on Save CTA.
  - **Version Conflict (`409`):** Displays localized reload prompt so user can refresh latest partner state without losing awareness of concurrent changes.
  - **Success:** Updates detail view and directory list cache immediately with localized confirmation toast.

## 5. API Contract

| Method & Endpoint | Auth | Handler | Request / Response |
| :--- | :--- | :--- | :--- |
| `PATCH /api/v1/agencies/{agencyId}/collaborators/{id}` | Bearer (`Owner`) | `DirectoryPartnerController.update()` | Req: `UpdateDirectoryPartnerRequest` (`expectedVersion`, `name`, `type`, `contactInfo`, `notes`) -> `200 ApiResponse<DirectoryPartnerResponse>` |
| `PUT /api/v1/collaborators/{collaboratorId}` | Bearer (`Owner, Manager`) | `CollaboratorController.update()` | Req: `UpdateCollaboratorRequest` -> `200 ApiResponse<CollaboratorResponse>` |
| `PUT /api/v1/collaborators/campaign/{campaignCollaboratorId}/cooperation` | Bearer (`Owner, Manager`) | `CollaboratorController` / `CampaignCollaboratorController` | Updates per-campaign cooperation status independently of master directory row |

## 6. Error Handling & Edge Cases

- `VERSION_CONFLICT` (`409`, `MSG03`): Concurrent edit or concurrent first-time Campaign assignment bumped `version`; prevents wiping `first_used_at`.
- `PARTNER_NOT_FOUND` (`404`, `MSG01`): Partner deleted prior to edit or belongs to another Agency.
- **Editing Inactive Partner:** Permitted in management directory (e.g., updating archival notes) while `isActive` remains `false`.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.15 — View Collaborator Directory](../3-7-15-view-collaborator-directory/spec.md) · [FR 3.7.16 — Create Collaborator Profile](../3-7-16-create-collaborator-profile/spec.md) · [FR 3.7.18 — Remove Collaborator Profile](../3-7-18-remove-collaborator-profile/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Optimistic locking (`version`), JSONB unknown-key preservation, read-only marker protection, `vi`/`en` i18n, and Light/Dark UI verified in [test.md](./test.md).
- **Out of Scope:** Reactivating a deactivated partner (`isActive: false -> true`) without a separate BA-approved workflow.

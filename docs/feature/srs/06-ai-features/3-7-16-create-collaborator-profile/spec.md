> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.16 — Create Collaborator Profile

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.16` |
| **Use Case ID** | `UC-103` |
| **Feature** | Create Collaborator Profile |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager` |
| **Business Rules** | `BR-20`, `BR-51` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `partner-directory` DA-949) |

## 1. Objective & Business Value

Allow authorized Agency leadership (`Owner` on Agency Directory `/api/v1/agencies/{agencyId}/collaborators`, and `Owner`/`Manager` via `/api/v1/collaborators` per workspace/agency policy) to onboard new third-party Collaborator & Media Partner profiles (`KOL`, `KOC`, `NEWSPAPER`, `BANNER`, `TV`, `OTHER`) into `third_party_collaborators` with validated contact channels, rate-card metadata, `isActive = true`, `usageHistoryVerified = true`, and initial optimistic lock `version = 0` (`BR-51`).

## 2. User Story

As an `Owner` or `Manager`, I want to create a structured Collaborator Profile with partner category, niche/industry tags, pricing benchmarks, reach metrics, and validated phone/email/website contact details so that the partner is immediately available for AI recommendation (FR 3.7.19) and Campaign assignment.

## 3. Acceptance Criteria

1. **Authorization & Tenant Binding (`BR-20`):** `agency_id` is bound strictly from the authenticated Agency context (`DirectoryPartnerController` / `CollaboratorController`), rejecting cross-Agency writes (`403 FORBIDDEN`, `MSG07`).
2. **Input & Contact Validation (`BR-51`):**
   - `name`: Trimmed, required, `1..255` characters.
   - `type`: Required enum (`KOL`, `KOC`, `NEWSPAPER`, `BANNER`, `TV`, `OTHER` — backed by `2026-11-16-collaborator-kol-type.sql`).
   - `contactInfo` (JSONB object, `<= 10,000` chars): Validates Vietnam & international phone numbers (`7–15` digits, optional leading `+` and spaces/hyphens/parentheses), RFC-compliant email, and `http://` or `https://` website URLs on both UI and backend.
   - `notes`: Optional, `<= 10,000` characters. Unknown root payload fields or attempts to spoof `isActive`, `firstUsedAt`, `usageHistoryVerified`, or `version` are rejected (`400 BAD_REQUEST`, `MSG02`).
3. **Lifecycle Initialization:** Newly created rows persist with `is_active = true`, `first_used_at = NULL`, `usage_history_verified = true` (permitting clean hard-delete via FR 3.7.18 until first linked to a Campaign), and `version = 0`.
4. **Client Profile Quick-Fill Helper:** `ClientProfileQuickFill.tsx` optionally assists pre-populating industry/audience alignment tags without mutating client records.
5. **Internationalization (`vi.json` + `en.json`):** Form labels, type options, contact validation hints, and submit/cancel buttons use key-parallel `collaborators.form.*` and `collaborators.errors.*` in `vi.json` and `en.json`.
6. **Light & Dark Mode Compliance:** `PartnerForm.tsx` and `PartnerContactFields.tsx` inputs, focus rings, error borders, and modal surfaces comply with semantic Light/Dark tokens.

## 4. UI / UX & Screen States

- **Web Components:** `pages/collaborators/components/PartnerForm.tsx`, `PartnerContactFields.tsx`, `ClientProfileQuickFill.tsx`.
- **Mobile Screen:** `src/screens/agency/AgencyCollaboratorsScreen.tsx` create modal.
- **UI States:**
  - **Initial / Auto-Focus:** Dialog auto-focuses `name` input and closes cleanly on `Escape` (with unsaved-input guard if dirty).
  - **Submitting:** Primary button shows loading spinner and disables duplicate clicks.
  - **Validation Error:** Field-level inline error messages for invalid phone/email/URL or oversize notes.
  - **Success (`201 Created`):** Closes modal, invalidates directory query cache, highlights newly created partner card, and shows localized toast.

## 5. API Contract

| Method & Endpoint | Auth | Handler | Request / Response |
| :--- | :--- | :--- | :--- |
| `POST /api/v1/agencies/{agencyId}/collaborators` | Bearer (`Owner`) | `DirectoryPartnerController.create()` | Req: `CreateDirectoryPartnerRequest` -> `201 ApiResponse<DirectoryPartnerResponse>` |
| `POST /api/v1/collaborators` | Bearer (`Owner, Manager`) | `CollaboratorController.create()` | Req: `CreateCollaboratorRequest` -> `201 ApiResponse<CollaboratorResponse>` |

## 6. Error Handling & Edge Cases

- `INVALID_CONTACT_FORMAT` (`400`, `MSG02`): Phone outside `7–15` digits, malformed email, or `javascript:` / non-HTTP(S) website scheme.
- `UNRECOGNIZED_FIELD` (`400`, `MSG02`): Payload attempts to override read-only lifecycle markers (`firstUsedAt`, `usageHistoryVerified`).
- `FORBIDDEN` (`403`, `MSG07`): `Creator` or `Client` attempts to create an Agency directory partner.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.15 — View Collaborator Directory](../3-7-15-view-collaborator-directory/spec.md) · [FR 3.7.17 — Update Collaborator Profile](../3-7-17-update-collaborator-profile/spec.md) · [FR 3.7.18 — Remove Collaborator Profile](../3-7-18-remove-collaborator-profile/spec.md) · [FR 3.7.19 — Recommend Collaborator](../3-7-19-recommend-collaborator/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified in `DirectoryPartnerControllerTest`, `DirectoryPartnerServiceTest`, `PartnerLifecycleMigrationTest`, Web Playwright form validation tests, `vi`/`en` i18n parity, and Light/Dark mode ([test.md](./test.md)).
- **Out of Scope:** External phone/email ownership verification via OTP for third-party KOL contacts (format validation only).

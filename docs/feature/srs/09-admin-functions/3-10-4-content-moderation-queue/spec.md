> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.4 — Content Moderation Queue

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.4` |
| **Use Case ID** | `UC-131` |
| **Feature** | Content Moderation Queue |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Admin` |
| **Business Rules** | `BR-30, BR-33` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Verified against `AdminModerationController`, `InternalModerationController`, and `content_moderation_reviews`) |

## 1. Objective & Business Value

Provide system `Admin` with a prioritized Content Moderation Queue (`/admin?view=moderation`) to inspect AI-flagged or compliance-flagged captions, task drafts, and social posts (community safety, profanity, violence, hate speech — strictly excluding de-scoped copyright/plagiarism checks) and record binding `APPROVE`, `REJECT`, or `ESCALATE_STRIKE` decisions.

## 2. User Story

As an authorized `Admin`, I want to execute **Content Moderation Queue** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30, BR-33` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Community Safety Scope (`BR-33`):** Evaluates profanity, violence, hate speech, self-harm, illegal gambling/scams, and platform safety violations (aligned with FR 3.6.33 `Check Compliance Content`).
- **2. Atomic Decision & Author Feedback:** Recording a decision transitions `content_moderation_reviews.status`, unblocks or blocks downstream publishing, logs an immutable entry in `audit_logs`, and optionally notifies the author via `ModerationNotifyAuthorDialog` -> `user_notifications`.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`admin.moderation.{queue,detail,decision,categories,notifyAuthor}` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/admin/components/AdminModerationPanel.tsx`, `ModerationQueueList.tsx`, `moderation/{ModerationKanbanColumn,ModerationKanbanCard,ModerationDetailDialog,ModerationDecisionForm}.tsx`, `ModerationNotifyAuthorDialog.tsx` on Web and `src/screens/admin/AdminModerationScreen.tsx`, `AdminModerationDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/AdminModerationPanel.tsx`, `ModerationQueueList.tsx`, `moderation/{ModerationKanbanColumn,ModerationKanbanCard,ModerationDetailDialog,ModerationDecisionForm}.tsx`, `ModerationNotifyAuthorDialog.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminModerationScreen.tsx`, `AdminModerationDetailScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/admin/moderation?status={PENDING}&source={s}&page={1}&size={10}` | Bearer (`Admin`) | `AdminModerationController.list()` -> paginated queue of `content_moderation_reviews` |
| `GET /api/v1/admin/moderation/{id}` | Bearer (`Admin`) | `AdminModerationController.detail()` -> flagged text/media snapshot, matched safety categories, author & workspace metadata |
| `POST /api/v1/admin/moderation/{id}/decision` | Bearer (`Admin`) | `AdminModerationController.decide()` -> records `APPROVE` / `REJECT` (+ optional strike escalation & author notification) |
| `POST /api/v1/internal/moderation/flags & /eligibility` | `X-Internal-Service-Key` | `InternalModerationController` <- receives automated flags from `text_moderation_service.py` / compliance checks |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.10.5 — Update User Violation Status](../3-10-5-update-user-violation-status/spec.md) · [`rag-caption-moderation-and-humanizer`](../../../modules/05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).

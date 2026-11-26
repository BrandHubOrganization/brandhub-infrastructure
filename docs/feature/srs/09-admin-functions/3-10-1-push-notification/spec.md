> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.1 — Push Notification

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.1` |
| **Use Case ID** | `UC-128` |
| **Feature** | Push Notification |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Admin` |
| **Business Rules** | `BR-30, BR-31` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Verified against `AdminNotificationController`, `admin_notifications`, `user_notifications` (`LISTEN/NOTIFY`), and FCM/APNs dispatch) |

## 1. Objective & Business Value

Enable system `Admin` to compose, preview target audience counts, send immediately, schedule, update, or cancel platform-wide or segmented system notifications (`ALL_USERS`, `BY_ROLE`, `BY_PLAN`) across Web realtime inbox (`user_notifications` PostgreSQL `LISTEN/NOTIFY`) and Mobile push notifications (`expo-notifications` / FCM / APNs).

## 2. User Story

As an authorized `Admin`, I want to execute **Push Notification** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30, BR-31` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Audience Targeting & Live Estimation (`BR-31`):** Supports `ALL_USERS`, `BY_ROLE` (`Owner`, `Manager`, `Creator`, `Client`), and `BY_PLAN` (`STUDIO_FREE/PLUS/PRO`, `BASIC/PLUS/ENTERPRISE`), computing exact active-user count prior to confirmation.
- **2. Scheduled vs Immediate Fan-Out:** Immediate broadcasts fan out into `user_notifications` (triggering `pg_notify` realtime Web push) and mobile push channels; `SCHEDULED` broadcasts remain editable/cancellable (`rowVersion` checked) until dispatcher claim.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`admin.notifications.{title,compose,audienceCount,schedule,cancel}` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/admin/components/AdminNotificationsPanel.tsx`, `NotificationComposerDialog.tsx`, `AdminBroadcastDialog.tsx` on Web and `src/screens/admin/AdminNotificationsScreen.tsx`, `AdminNotificationComposeScreen.tsx`, `src/screens/notifications/NotificationsScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/AdminNotificationsPanel.tsx`, `NotificationComposerDialog.tsx`, `AdminBroadcastDialog.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminNotificationsScreen.tsx`, `AdminNotificationComposeScreen.tsx`, `src/screens/notifications/NotificationsScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/admin/notifications?page={1}&size={10}` | Bearer (`Admin`) | `AdminNotificationController.list()` -> paginated broadcast history & delivery statuses |
| `GET /api/v1/admin/notifications/audience-count?targetType={t}&targetValues={v}` | Bearer (`Admin`) | `AdminNotificationController.audienceCount()` -> live recipient count preview before sending |
| `GET /api/v1/admin/notifications/plans` | Bearer (`Admin`) | `AdminNotificationController.plans()` -> active subscription plan codes for `BY_PLAN` targeting |
| `POST /api/v1/admin/notifications` | Bearer (`Admin`) | `AdminNotificationController.create()` (`201 Created`) -> dispatches immediate or scheduled `admin_notifications` |
| `PUT /api/v1/admin/notifications/{id} & POST /{id}/cancel` | Bearer (`Admin`) | `AdminNotificationController` -> updates or cancels `SCHEDULED` broadcast with `rowVersion` optimistic lock |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [`realtime-notification-center`](../../../modules/02-agency-studio-plans/realtime-notification-center/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).

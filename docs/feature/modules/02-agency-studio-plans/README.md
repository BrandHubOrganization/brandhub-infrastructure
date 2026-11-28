# 02-agency-studio-plans — Agency, Personal Studio, Dashboards & Realtime Notifications (3 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.4 Agency & Workspace](../../srs/03-agency-workspace/README.md) · [SRS 3.9 Billing](../../srs/08-subscription-billing/README.md) · [BA Baseline](../../../ba/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Platform-wide multi-tenancy extensions covering the Dual-Line Subscription Catalog (`Personal Studio` + `Business Agency`), 3-tier role-specific analytics dashboards, Workspace UX & deep cloning, and PostgreSQL `LISTEN/NOTIFY` realtime in-app notifications.

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-business-service` (`SubscriptionPlanController`, `AdminSubscriptionPlanController`, `DashboardAnalyticsController`, `WorkspaceDuplicationServiceImpl`, `NotificationController`, `PgNotificationListener`), `brandhub-web` (`RoleWorkspaceOverview.tsx`, `/admin?view=plans`, `NotificationBell.tsx`), and `brandhub-mobile-app`.
- **Storage & Runtime State:**
  - **PostgreSQL 17:** `subscription_plans`, `billing_plan_versions`, `billing_plan_cycle_prices`, `agencies` (`is_personal_studio`), `workspaces` (`timezone_config`), `user_notifications` + `NOTIFY user_notifications_channel`.
  - **MongoDB 7.0:** Aggregated task/post analytics pipelines scoped by `agencyId` and `workspaceId`.
- **Related Canonical SRS Domains:** [03-agency-workspace (`3.4.1`–`3.4.26`)](../../srs/03-agency-workspace/README.md) · [08-subscription-billing (`3.9.1`–`3.9.6`)](../../srs/08-subscription-billing/README.md) · [09-admin-functions (`3.10.1`–`3.10.14`)](../../srs/09-admin-functions/README.md).

---

## 2. Consolidated Modules (`3`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `studio-and-agency-plan-catalog` | **Dual-Line Subscription Catalog (Personal Studio & Business Agency Plans) & Admin Plan Editor** | `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO` + `BASIC`, `PLUS`, `ENTERPRISE`; `1 / 3 / 6 / 12m` prepaid cycles; `/admin?view=plans` versioned editor | [Spec](./studio-and-agency-plan-catalog/spec.md) · [Plan](./studio-and-agency-plan-catalog/plan.md) · [Task](./studio-and-agency-plan-catalog/task.md) · [Test](./studio-and-agency-plan-catalog/test.md) |
| `role-based-dashboards-and-ux` | **Three-Tier Role-Based Dashboards, Workspace UX, Timezone Consistency & Duplicate Workspace** | `DashboardAnalyticsController` (`/overview`, `/items`, `/export.xlsx`), `POST /workspaces/{id}/duplicate`, `POST /workspaces/personal/bootstrap`, `timezone_config` | [Spec](./role-based-dashboards-and-ux/spec.md) · [Plan](./role-based-dashboards-and-ux/plan.md) · [Task](./role-based-dashboards-and-ux/task.md) · [Test](./role-based-dashboards-and-ux/test.md) |
| `realtime-notification-center` | **Realtime In-App Notification Center (PostgreSQL LISTEN/NOTIFY + WebSocket/SSE)** | `user_notifications` trigger -> `PgNotificationListener` -> live badge push, unread counters, mark-read & deep-link routing | [Spec](./realtime-notification-center/spec.md) · [Plan](./realtime-notification-center/plan.md) · [Task](./realtime-notification-center/task.md) · [Test](./realtime-notification-center/test.md) |

---

## 3. Architectural Invariants

1. All 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`) receive strictly scoped navigation trees and KPI cards without cross-tenant leakage.
2. Plan catalog edits create immutable `billing_plan_versions` snapshots so active `agency_subscriptions` preserve historical grandfathering until renewal or upgrade (`3.9.1`).

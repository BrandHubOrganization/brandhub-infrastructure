# 3.10 Admin Functions (14 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/09-admin-functions.md) · [Extension Modules](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical business specification, technical implementation plan, sequential task checklist, and verification suite for **3.10 Admin Functions** (`3.10.1 – 3.10.14`, **14 Atomic CRUD Functional Requirements** across `UC-128` to `UC-141`).

## Architectural Overview

- **System Role Enforcement:** Every `/api/v1/admin/**` and `/api/monitoring/**` administrative endpoint verifies `SystemRole.ADMIN` against the live database (`AdminAccountService.requireAdmin`) in addition to Spring Security route guards, recording immutable audit trails (`audit_logs`, `admin_account_operations`).
- **Controllers & Subsystems (`brandhub-business-service`):** `AdminNotificationController` (`3.10.1`), `AdminStatisticsController` (`3.10.2`), `MonitoringServerController` + `MonitoringHealthController` + `AdminBackupController` (`3.10.3`), `AdminModerationController` (`3.10.4`), `AdminController` + `AdminUserController` (`3.10.5–3.10.9`), `CreditPriceController` + `CreditPriceImportController` (`3.10.10–3.10.12`), `AdminRevenueController` (`3.10.13`), and `AdminReportController` (`3.10.14`).
- **Related Platform Modules:** [`studio-and-agency-plan-catalog`](../../modules/02-agency-studio-plans/studio-and-agency-plan-catalog/spec.md) (`/admin?view=plans`) · [`multiplatform-trend-crawler-pipeline`](../../modules/05-ai-rag-and-crawler/multiplatform-trend-crawler-pipeline/spec.md) · [`system-health-mongodb-refactor`](../../modules/07-billing-publisher-and-observability/system-health-mongodb-refactor/spec.md).

## Functional Requirements Matrix

| FR ID | UC ID | Function Name | Canonical Roles | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- |
| `3.10.1` | `UC-128` | **Push Notification** | `Admin` | [Spec](./3-10-1-push-notification/spec.md) · [Plan](./3-10-1-push-notification/plan.md) · [Task](./3-10-1-push-notification/task.md) · [Test](./3-10-1-push-notification/test.md) |
| `3.10.2` | `UC-129` | **Platform Statistics Overview** | `Admin` | [Spec](./3-10-2-platform-statistics-overview/spec.md) · [Plan](./3-10-2-platform-statistics-overview/plan.md) · [Task](./3-10-2-platform-statistics-overview/task.md) · [Test](./3-10-2-platform-statistics-overview/test.md) |
| `3.10.3` | `UC-130` | **System Health Monitoring** | `Admin` | [Spec](./3-10-3-system-health-monitoring/spec.md) · [Plan](./3-10-3-system-health-monitoring/plan.md) · [Task](./3-10-3-system-health-monitoring/task.md) · [Test](./3-10-3-system-health-monitoring/test.md) |
| `3.10.4` | `UC-131` | **Content Moderation Queue** | `Admin` | [Spec](./3-10-4-content-moderation-queue/spec.md) · [Plan](./3-10-4-content-moderation-queue/plan.md) · [Task](./3-10-4-content-moderation-queue/task.md) · [Test](./3-10-4-content-moderation-queue/test.md) |
| `3.10.5` | `UC-132` | **Update User Violation Status** | `Admin` | [Spec](./3-10-5-update-user-violation-status/spec.md) · [Plan](./3-10-5-update-user-violation-status/plan.md) · [Task](./3-10-5-update-user-violation-status/task.md) · [Test](./3-10-5-update-user-violation-status/test.md) |
| `3.10.6` | `UC-133` | **View User** | `Admin` | [Spec](./3-10-6-view-user/spec.md) · [Plan](./3-10-6-view-user/plan.md) · [Task](./3-10-6-view-user/task.md) · [Test](./3-10-6-view-user/test.md) |
| `3.10.7` | `UC-134` | **Create User** | `Admin` | [Spec](./3-10-7-create-user/spec.md) · [Plan](./3-10-7-create-user/plan.md) · [Task](./3-10-7-create-user/task.md) · [Test](./3-10-7-create-user/test.md) |
| `3.10.8` | `UC-135` | **Update User** | `Admin` | [Spec](./3-10-8-update-user/spec.md) · [Plan](./3-10-8-update-user/plan.md) · [Task](./3-10-8-update-user/task.md) · [Test](./3-10-8-update-user/test.md) |
| `3.10.9` | `UC-136` | **Deactivate User** | `Admin` | [Spec](./3-10-9-deactivate-user/spec.md) · [Plan](./3-10-9-deactivate-user/plan.md) · [Task](./3-10-9-deactivate-user/task.md) · [Test](./3-10-9-deactivate-user/test.md) |
| `3.10.10` | `UC-137` | **View AI Credit Price List** | `Owner, Admin` | [Spec](./3-10-10-view-ai-credit-price-list/spec.md) · [Plan](./3-10-10-view-ai-credit-price-list/plan.md) · [Task](./3-10-10-view-ai-credit-price-list/task.md) · [Test](./3-10-10-view-ai-credit-price-list/test.md) |
| `3.10.11` | `UC-138` | **Update AI Credit Price** | `Admin` | [Spec](./3-10-11-update-ai-credit-price/spec.md) · [Plan](./3-10-11-update-ai-credit-price/plan.md) · [Task](./3-10-11-update-ai-credit-price/task.md) · [Test](./3-10-11-update-ai-credit-price/test.md) |
| `3.10.12` | `UC-139` | **Import AI Credit Price CSV** | `Admin` | [Spec](./3-10-12-import-ai-credit-price-csv/spec.md) · [Plan](./3-10-12-import-ai-credit-price-csv/plan.md) · [Task](./3-10-12-import-ai-credit-price-csv/task.md) · [Test](./3-10-12-import-ai-credit-price-csv/test.md) |
| `3.10.13` | `UC-140` | **View Revenue Dashboard** | `Admin` | [Spec](./3-10-13-view-revenue-dashboard/spec.md) · [Plan](./3-10-13-view-revenue-dashboard/plan.md) · [Task](./3-10-13-view-revenue-dashboard/task.md) · [Test](./3-10-13-view-revenue-dashboard/test.md) |
| `3.10.14` | `UC-141` | **Export Report File PDF** | `Admin` | [Spec](./3-10-14-export-report-file-pdf/spec.md) · [Plan](./3-10-14-export-report-file-pdf/plan.md) · [Task](./3-10-14-export-report-file-pdf/task.md) · [Test](./3-10-14-export-report-file-pdf/test.md) |

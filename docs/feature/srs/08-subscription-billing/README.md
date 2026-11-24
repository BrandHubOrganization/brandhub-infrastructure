# 3.9 Subscription & Billing (6 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/08-subscription-billing.md) · [Extension Modules](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical business specification, technical implementation plan, sequential task checklist, and verification suite for **3.9 Subscription & Billing** (`3.9.1` – `3.9.6`, **6 Atomic CRUD Functional Requirements** across `UC-122` to `UC-127`).

---

## 1. Production Architecture & Persistence Mapping

- **Payment Gateway (Strictly SePay VietQR):** Dynamic VietQR bank-transfer checkout (`15-minute` order window + live `mm:ss` countdown in `AgencyPaymentPanel`) and authenticated SePay webhook reconciliation (`POST /api/v1/billing/webhooks/sepay`) with canonical business-fingerprint idempotency and `AB-10` double-payment review protection. No plan downgrade flow (`Upgrade Plan` `3.9.1` only).
- **Two-Line × Six-Plan Catalog:** Personal Studio line (`STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`) and Business Agency line (`BASIC`, `PLUS`, `ENTERPRISE`) supporting `1 / 3 / 6 / 12-month` prepaid billing cycles (`subscription_plans`, `billing_plan_versions`, `billing_plan_cycle_prices`, `agency_subscriptions`).
- **Unified Agency Wallet & Workspace Credit Ledger:** Single shared Agency wallet (`agency_credit_wallets`, `credit_grants` consumed in strict `PLAN -> PURCHASED -> DEV_SEED` priority) with `Owner`-configurable per-Workspace spending caps (`workspace_credit_limits`) and 3-phase `RESERVE -> SETTLE / RELEASE` accounting (`ai_credit_reservations`, `credit_operations`, `credit_entries`).
- **Core Backend Controllers (`brandhub-business-service`):** `BillingController`, `SePayWebhookController`, `InvoiceHistoryController`, `AdminInvoiceHistoryController`, `CreditBalanceController`, `CreditUsageController`, `WorkspaceCreditController`, and `AgencyCreditConfigurationController`.
- **Related Platform Modules:** [`studio-and-agency-plan-catalog`](../../modules/02-agency-studio-plans/studio-and-agency-plan-catalog/spec.md) · [`payment-java-runner`](../../modules/07-billing-publisher-and-observability/payment-java-runner/spec.md) · [`mobile-subscription-billing`](../../modules/08-mobile-application/mobile-subscription-billing/spec.md).

---

## 2. Functional Requirements Matrix (`3.9.1` – `3.9.6`)

| FR ID | UC ID | Function Name | Canonical Roles | Key Business Rules | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `3.9.1` | `UC-122` | **Upgrade Plan** | `Owner` | `BR-50`, `BR-51` | [Spec](./3-9-1-upgrade-plan/spec.md) · [Plan](./3-9-1-upgrade-plan/plan.md) · [Task](./3-9-1-upgrade-plan/task.md) · [Test](./3-9-1-upgrade-plan/test.md) |
| `3.9.2` | `UC-123` | **Make Payment (SePay)** | `Owner` | `BR-52`, `BR-53` | [Spec](./3-9-2-make-payment-sepay/spec.md) · [Plan](./3-9-2-make-payment-sepay/plan.md) · [Task](./3-9-2-make-payment-sepay/task.md) · [Test](./3-9-2-make-payment-sepay/test.md) |
| `3.9.3` | `UC-124` | **View Invoice History** | `Owner, Admin` | `BR-54` | [Spec](./3-9-3-view-invoice-history/spec.md) · [Plan](./3-9-3-view-invoice-history/plan.md) · [Task](./3-9-3-view-invoice-history/task.md) · [Test](./3-9-3-view-invoice-history/test.md) |
| `3.9.4` | `UC-125` | **View AI Credit Tracking** | `Owner, Manager, Creator` | `BR-55` | [Spec](./3-9-4-view-ai-credit-tracking/spec.md) · [Plan](./3-9-4-view-ai-credit-tracking/plan.md) · [Task](./3-9-4-view-ai-credit-tracking/task.md) · [Test](./3-9-4-view-ai-credit-tracking/test.md) |
| `3.9.5` | `UC-126` | **Buy Credit** | `Owner` | `BR-56` | [Spec](./3-9-5-buy-credit/spec.md) · [Plan](./3-9-5-buy-credit/plan.md) · [Task](./3-9-5-buy-credit/task.md) · [Test](./3-9-5-buy-credit/test.md) |
| `3.9.6` | `UC-127` | **Set Credit** | `Owner` | `BR-57` | [Spec](./3-9-6-set-credit/spec.md) · [Plan](./3-9-6-set-credit/plan.md) · [Task](./3-9-6-set-credit/task.md) · [Test](./3-9-6-set-credit/test.md) |

---

## 3. Financial Integrity Verification

- Automated ACID, webhook replay, and concurrency verification is maintained in `brandhub-business-service` (`src/test/java/com/brandhub/business/paymentqa`) and documented in [`payment-java-runner/test.md`](../../modules/07-billing-publisher-and-observability/payment-java-runner/test.md).

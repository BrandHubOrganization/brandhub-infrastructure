# 07-billing-publisher-and-observability — Billing Verification, Publisher Resilience & System Health Observability (3 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.8 Publishing](../../srs/07-publishing-social/README.md) · [SRS 3.9 Billing](../../srs/08-subscription-billing/README.md) · [SRS 3.10 Admin](../../srs/09-admin-functions/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Production reliability, financial ACID verification, RabbitMQ social publishing fault tolerance, and MongoDB-backed system health telemetry across `brandhub-business-service` and `brandhub-publisher-service`.

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-business-service` (`BillingController`, `SePayWebhookController`, `src/test/java/com/brandhub/business/paymentqa/*`, `MonitoringServerController`, `MonitoringHealthController`, `AdminBackupController`) and `brandhub-publisher-service` (`PublishJobConsumer`, `FacebookPublishServiceImpl`, `InstagramPublishServiceImpl`, `TikTokPublishServiceImpl`, `ThreadsPublishServiceImpl`).
- **Storage & Runtime State:**
  - **PostgreSQL 17:** `payment_transactions`, `subscription_invoices`, `agency_subscriptions`, `agency_credit_wallets`, `credit_grants`, `credit_entries`.
  - **RabbitMQ 3.13 + Redis 7.2:** `publisher.job.exchange` -> `publisher.job.queue` (`1m / 5m / 15m` TTL retry queues + `publisher.job.dlq`) + `processingPostIds:{postId}:{platform}` (`30m` Redis lock).
  - **MongoDB 7.0:** `monitoring_servers`, `monitoring_health_snapshots`, `monitoring_incidents`.
- **Related Canonical SRS Domains:** [07-publishing-social (`3.8.1`–`3.8.15`)](../../srs/07-publishing-social/README.md) · [08-subscription-billing (`3.9.1`–`3.9.6`)](../../srs/08-subscription-billing/README.md) · [09-admin-functions (`3.10.1`–`3.10.14`)](../../srs/09-admin-functions/README.md).

---

## 2. Consolidated Modules (`3`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `payment-java-runner` | **SePay Payment ACID Verification Suite, Java Benchmark Runner & Subscription Production Observability** | `mvn -Ppayment-api test`, concurrent SePay webhook replay/double-pay (`AB-10`) ACID harness, invoice & grant ledger reconciliation | [Spec](./payment-java-runner/spec.md) · [Plan](./payment-java-runner/plan.md) · [Task](./payment-java-runner/task.md) · [Test](./payment-java-runner/test.md) |
| `social-publisher-resilience` | **RabbitMQ Publisher Message Type Compatibility & Graceful Media Stream Disconnect Handling** | Cross-service Jackson `__TypeId__` tolerance on `PublishJobMessage`, `ClientAbortException` broken-pipe suppression on S3 media proxy | [Spec](./social-publisher-resilience/spec.md) · [Plan](./social-publisher-resilience/plan.md) · [Task](./social-publisher-resilience/task.md) · [Test](./social-publisher-resilience/test.md) |
| `system-health-mongodb-refactor` | **System Health MongoDB Persistence Refactor & BOM-Safe Monitoring Catalog Startup** | Migration of server monitoring catalog from PG to MongoDB `monitoring_*` collections, UTF-8 BOM-safe seed parser (`t10-baseline-snapshot.json`) | [Spec](./system-health-mongodb-refactor/spec.md) · [Plan](./system-health-mongodb-refactor/plan.md) · [Task](./system-health-mongodb-refactor/task.md) · [Test](./system-health-mongodb-refactor/test.md) |

---

## 3. Reliability Invariants

1. SePay webhook processing enforces business-fingerprint idempotency so duplicate webhook deliveries never mint duplicate `credit_grants` or extend `agency_subscriptions` twice.
2. Social publishing strictly targets the **4 supported platforms** (**Facebook, Instagram, TikTok, Threads**) with distributed Redis idempotency locks (`ADR-003`).

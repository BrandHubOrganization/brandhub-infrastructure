# Four-plan catalog migration

## Objective and acceptance criteria

Provide PERSONAL, BASIC, PLUS and ENTERPRISE version 1 in billing_plan_versions after the existing agency expand migration. Preserve existing rows and financial history. PERSONAL belongs to USER scope; other plans belong to AGENCY. Agency subscriptions, orders and periods must reject USER plans at the database boundary. New paid rows have unknown price and is_sellable=false; no personal subscriptions or wallets are activated. Personal proposal: one personal space, 20 GB, 1,000 monthly credits, one concurrent job, version/trash/activity retention 30/30/90 days. Personal does not grant agency workspaces, seats or clients.

## States and errors

Missing prerequisite migration fails atomically with a clear error. Repeat execution is a no-op through the migration registry. Failed DDL/data insertion rolls back all changes. Quotas are proposed catalog values, not proof that runtime capabilities exist. No UI or API change, so no new i18n or theme requirements.

## Out of scope

Applying to the running BrandHub database, production pricing, sale activation, Personal billing implementation, and changing the legacy subscription_plans catalog.

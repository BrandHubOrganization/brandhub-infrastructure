# Implementation plan

1. Create 2026-10-20-four-plan-catalog.sql using the existing psql migration registry, transaction, timeouts and shared advisory lock.
2. Require the agency expand migration. Expand the plan code CHECK to four values. Add generated billing_scope (PERSONAL -> USER, otherwise AGENCY) and a composite unique key.
3. Add fixed AGENCY plan_billing_scope columns and composite foreign keys on agency_subscriptions, billing_orders and agency_subscription_periods. Preserve their original foreign keys.
4. Insert four version-1 rows with ON CONFLICT DO NOTHING. Leave existing prices, quota, IDs and sale flags unchanged. Seed missing paid rows with NULL prices and false sale flags. Personal personal-space limit lives in features; agency workspace limit is zero.
5. Adapt the immutable-row trigger to exclude the generated scope from BEFORE-trigger comparisons; its source code stays immutable. Validate in a disposable PostgreSQL 17 container against all schema-only DDL extracted from the real export, without importing user data. Use synthetic users, agencies, subscriptions, orders and periods to check replay, FK scope rejection, immutable versions, preserved commercial terms, missing prerequisites and injected mid-migration failure with atomic DDL/data rollback.

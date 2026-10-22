# Database-backed subscription catalog

## Objective

Replace seeded plan cards at /subscription/plans with the four products from billing_plan_versions. Preserve the separate USER/AGENCY scopes and existing Basic-to-Plus payment policy. Do not change stored pricing, sellability or migration-review states.

## Acceptance criteria and contract

- Authenticated GET /api/v1/billing/plans returns ApiResponse<List<BillingPlanResponse>>, one highest-version row per code, including unsellable products. Stable display order Personal, Basic, Plus, Enterprise. Read-only; no catalog seeding from requests.
- Fields: id, code, version, displayName, billingScope, priceMonthly (nullable decimal string), currency, maxActiveWorkspaces, maxInternalMembers, maxClients, storageLimitBytes and monthlyAiCredits (decimal strings), maxConcurrentAiJobs, versionRetentionDays, trashRetentionDays, activityRetentionDays, maxPersonalSpaces (nullable integer from features), isSellable and checkoutEnabled.
- checkoutEnabled is true only for configured SePay checkout, a sellable positive-price Agency Plus row that matches the version used by the payment engine. Personal/Enterprise checkout stays disabled. Backend continues to revalidate orders.
- Cards, names, prices, scopes and quota numbers all come from the API. No fallback catalog or hardcoded entitlement values. Zero, unknown price and unsellable are distinct states.
- Current subscription query is independent and keyed by user/agency. Failed current-subscription lookup still permits viewing the catalog, but blocks upgrade. Agency switches must not show another agency's status.
- Catalog loading, empty, failure with retry, current plan, unavailable checkout and normal states are explicit. User-facing labels explain state rather than marking every disabled button as unsellable.
- Catalog empty/error never displays fake plans. Route stays owner-only under the existing route access checks.

## UI conventions

Follow brandhub-ui-design/BrandHubDesign.md, existing theme tokens and shared Button/Badge/Skeleton. Neutral cards with thin borders, no card shadows; 8px action corners, 44px minimum touch targets; monospace numeric prices and neutral feature icons. One orange primary CTA; 1/2/4-column responsive grid. Preserve existing page shell.

All new text uses parallel VI/EN subscription.catalog keys: loading, errorTitle, errorDescription, retry, emptyTitle, emptyDescription, personalScope, agencyScope, personalDescription, agencyDescription, free, pricePending, perMonth, notOnSale, currentPlan, subscriptionPending, checkoutUnavailable, changeUnavailable, upgrade, personalSpaces, workspaces, members, clients, storage, credits, concurrency, versionHistory, trashHistory, activityHistory. Existing plans.description is updated for both scopes. Light/dark use existing semantic tokens, no new palette.

## Verification and scope

Real PostgreSQL catalog tests, authenticated API/security tests, and Playwright with API-driven changed fixture values, failure/retry, latest rows, scope, sellability, stale agency status, VI/EN and 375/768/1440 layouts. Capture light/dark screenshots. Compile/build, verify deployed route/authentication boundaries and the live DB catalog after updating local processes. Check a real signed-in browser session only when normal login/session access is available; do not create a token from private signing keys for verification. No production deploy, new migrations, paid activation or FR downgrade.

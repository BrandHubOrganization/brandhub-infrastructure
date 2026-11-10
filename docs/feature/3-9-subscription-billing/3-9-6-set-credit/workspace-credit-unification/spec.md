# Agency wallet and Workspace credit — 2026-10-22

This decision supersedes member-limit and DA-974 wallet decisions, not unrelated Subscription/payment behavior. User approval: one Subscription wallet per Agency; Workspace caps, not personal caps; caps may overlap; NULL means no separate cap; zero blocks paid usage. Owner/Manager/Creator all consume the selected Workspace's budget. Actor identity remains for audit and request authorization. Only Owner changes caps.

Reserve against Agency available balance and Workspace used+reserved in its original usage period, atomically under the Agency lock. Usage resets with the Subscription cycle; cap configuration persists. Expired subscriptions may still spend non-expiring purchased credit. Plan credit is used before purchased credit. Preserve Admin fixed action prices and the four billable operation groups; do not invent rates or token/GPU billing. Other AI actions remain free.

Keep price/request snapshots, idempotency payload checks, durable results, unknown-outcome holds, late original-period settlement and asynchronous Video reconciliation. Subscription journals and grants are the single money source. A duplicate request/callback cannot charge twice. No provider calls inside financial transactions. Preserve editor/publish/content behavior and public AI responses.

DB: preserve teammates' migration files. Add the unified schema after Subscription expand/catalog/provider/observability; fresh init must produce the same schema. Local reset is separately authorized for Credit/Subscription/payment test data ONLY, while writers are stopped; preserve User, Agency, Workspace, Campaign, Task/Post, Mongo and AI content history. Do not ship fixed-ID repair scripts or silently convert/delete shared data. Do not fabricate paid orders, subscriptions or balances.

UI: replace member/default-limit controls with Workspace cap and period usage. Reuse existing BrandHub controls/theme and routes; NULL/unlimited must be distinct from zero. Namespace `credit.workspace.*` and affected errors have parallel VI/EN keys. Owner edits; authorized Workspace Manager/Creator read their Workspace, not other Workspaces' or the Agency's private funds. Loading/error/empty/stale-save states are explicit, accessible and light/dark responsive.

Missing external `tuan-research` source files are not inferred. Existing checked-in Subscription implementation plus the user decisions above govern this integration. No PayOS/SePay webhook, publishing, Mongo or Task workflow redesign.

## Confirmed pricing and API contract

Only CONTENT_GENERATE, AMBASSADOR_GENERATE, COMMERCIAL_IMAGE and VIDEO_GENERATE use Admin prices. CAPTION_VARIANTS (including refine/adapt), HASHTAG_GENERATE and CHARACTER_SHEET are free regardless of historic price rows. Free requests persist price_id=NULL, unit_credits=0 and rate_version=FREE_V1; paid requests require a frozen price reference. A paid action with no enabled price remains blocked. No prices are invented.

- GET /api/v1/agencies/{agencyId}/credit/workspaces: active Workspace budgets accessible to the actor. Owner sees its Agency; Manager/Creator see only their active Workspaces.
- PUT /api/v1/agencies/{agencyId}/credit/workspaces/{workspaceId}/limit: Owner only; body {cap: number|null, expectedRevision: number}. A missing limit row is revision 0; successful changes increment revision. NULL explicitly removes the cap, 0 prevents positive-cost requests. Lowering a cap does not rewrite past usage or cancel existing holds.
- Existing balance/actor-history and Admin price routes remain. Personal-policy/member-limit writes return CREDIT_PERSONAL_LIMIT_RETIRED (410), not successful no-ops. Reads report no personal ceiling for compatibility.
- Workspace AI balance reports workspaceLimit/workspaceUsed/workspaceHeld. Actor IDs remain on reservations; these fields are not personal quotas. The Agency wallet is the only funding source.

CreditGrantService is now a lookup of verified Subscription fulfillment, not a second issuer. BillingPeriodBenefits remains the Plan grant writer. Existing purchased grants become non-expiring; this change does not implement a new credit-top-up checkout or alter SePay processing. The old illustrative TopUpDialog is no longer offered by the Credit page.

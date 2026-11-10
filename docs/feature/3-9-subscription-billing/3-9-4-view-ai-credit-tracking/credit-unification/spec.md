# Unified AI Credit (DA-974)

## Objective and confirmed business rules
Use DA-974 accounting for every new billable AI request. Preserve Caption context, prompts, response fields, choice/history and Video content behavior. Admin configures fixed per-operation prices; token/GPU/Vast billing and Payment/Subscription provisioning are out of scope.

- Caption generate/refine/adapt all use CAPTION_VARIANTS; one successful request costs one frozen price, regardless of returned captions/platforms.
- Agency funds are shared. Owner has no personal ceiling; Manager/Creator inherit configured ceilings (system fallback 10). Client cannot generate. Plan funds are used first.
- Reserve before dispatch, settle once on usable success, release on definite failure. Unknown/timeout stays held, without automatic redispatch/refund.
- Technical retries use the same Idempotency-Key and request identity; different actions/payloads conflict. Missing/disabled prices block before dispatch; never invent prices.
- Preserve legacy tables/history without importing seeded usage or balances. Legacy Video jobs retain their original refund mechanism only; new jobs never charge the old ledger.

## API and acceptance criteria
Workspace Caption/Video POST routes require Idempotency-Key. Existing URLs/request bodies/response field names remain; credit amounts support bigint instead of int. New Video responses distinguish held credit from settled credit additively. Retries reuse persisted output and history IDs, including when server-generated context changes. No arbitrary upstream path is accepted from clients.

Workspace credits and Dashboard use DA-974. Dashboard retains deprecated calendar-month fields with calendar-month semantics, adds explicit subscription-period usage/bounds and an unavailable state. No fallback to legacy/fabricated zero when credit setup/schema is missing. Existing free styles/status/history/choice/trend-fit stay free.

## UI states
Reuse existing theme/components; no page redesign or mock Studio integration. Dashboard labels use parallel vi/en keys for subscription period and unavailable credit. Existing light/dark tokens, keyboard access and mobile layout remain. Credit caches are user scoped; workspace AI mutations invalidate the relevant reports.

## Definition of done
Compile/typecheck and isolated database/provider-fixture checks pass; delta/init parity and repeat application verified; no shared DB or real paid provider writes. Document remaining live deployment and Admin price prerequisites. No executable test artifacts committed.

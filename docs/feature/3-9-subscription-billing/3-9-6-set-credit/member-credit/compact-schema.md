# Compact Credit database baseline — 2026-10-20

This decision supersedes the eight-table schema described by earlier implementation notes. SQL/init and Business Credit stores/services now use the compact baseline, verified on isolated PostgreSQL. Do not deploy an earlier eight-table build against this schema. No shared database APPLY is included.

## Structure

| Location | Credit data |
| --- | --- |
| agencies | credit_default_member_limit, credit_policy_revision, credit_policy_updated_by/at, credit_cycle_anchor |
| agency_members | credit_limit_override, credit_limit_revision, credit_limit_updated_by/at |
| ai_credit_operation_prices | Immutable versioned operation prices |
| ai_credit_grants | Plan/purchased entitlements, amounts, used and held |
| ai_credit_reservations | Request identity, locked price, period, units and settlement state |
| ai_credit_allocations | Each reservation's share of each grant |

Four independent new tables, not eight. Existing legacy ledger/creator-limit tables are retained without automatic import or removal. Revisions start at zero; NULL limit inherits, explicit zero blocks use. NULL anchor means no authoritative cycle established; do not guess it from the migration execution time. No initial grants or prices are seeded.

## Business implementation (2026-10-20; not enforced by SQL alone)

- Read/update limits directly on Agency/membership with Credit-specific optimistic revisions and change metadata. Owner still bypasses only the personal ceiling.
- Configuration reads/writes, grant/reserve/settle and usage reads lock the Agency row before relevant membership/configuration queries and money mutations. Grant handoffs acquire that lock before reading entitlement/payment rows, avoiding shared-to-exclusive Agency lock upgrades. No provider calls occur inside these transactions. Accounting/grant methods explicitly request READ_COMMITTED; aggregate usage is queried after acquiring the lock in a subsequent statement. An outer Payment transaction must use compatible isolation and Agency-first lock ordering; annotations do not override an already active caller transaction.
- Derive usage per Agency/user/original period: SETTLED sums `unit_credits::numeric * successful_units`; RESERVED sums `unit_credits::numeric * units`. Cast before multiplying to avoid BIGINT overflow. RELEASED contributes zero. A period index supports this query. Missing rows mean zero usage, not an established cycle.
- Keep usage history tied to users and Agency, not deletable membership. Removing membership must not remove reservations or allocations. Rejoin treatment of a former member's override is not decided here; do not change membership lifecycle silently.
- Keep grant used/held totals and allocations synchronized atomically. SQL checks bounds but does not replace service authorization, payment proof, cross-Agency validation or concurrency control.
- Preserve established monthly anchor and late settlement against the request's original period. Payment/AI adapter integration remains pending.

## Apply rules

Existing DB without the former draft: reviewed revised 19/10, then revised 20/10, using `psql -v ON_ERROR_STOP=1 -f <file>`; each owns its transaction. Fresh DB: current init only. Do not apply init to existing data.

If any `ai_credit_policies`, `ai_credit_member_limits`, `ai_credit_accounts` or `ai_credit_member_usage` exists, both deltas stop before schema writes. A separate inventory/conversion must preserve configuration, anchors and accounting data. This revision deliberately does not implement a destructive conversion.

`IF NOT EXISTS` permits repeat application of the matching baseline; it does not prove that existing objects have matching definitions. Inspect schema before rollout. The compact schema has now passed 54 accounting, 41 configuration and 25 standalone MVC checks with real JDBC/Spring transactions (plus the earlier SQL harness). MVC verification does not exercise the JWT/Gateway security-filter chain or real providers/payment webhooks.

## API compatibility

Public URLs and JSON fields remain unchanged: policy, own/member limit, latest prices, balance and own/member period usage. Owner policy writes now update Agency fields; member writes update existing membership fields only (never insert/recreate membership). Revision zero is an initial row state, not a missing configuration-table row. Credit-specific change metadata is updated with the write. NULL values remain inherited; explicit zero stays zero. No public grant/reserve/settle route was added.

Schema checks inspect the new Agency/member columns and four Credit tables. Missing required schema returns CREDIT_SCHEMA_NOT_READY; an uninitialized/null cycle anchor returns CREDIT_ACCOUNT_NOT_READY. Reports derive used/held and per-operation breakdown from reservations, including original-period late settlements, with no summary-row creation or updates. No Web changes are required for this storage refactor. AI dispatch/reconciliation and Subscription/Payment hook calls remain pending.

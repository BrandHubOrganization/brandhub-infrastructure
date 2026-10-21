# Spec — webhook corrections

Objective: fix PAY-QA-001/TX-04 and PAY-QA-002/TX-09 without changing their expected results.

Accepted policy: authenticated SePay duplicate ID with equal business fingerprint is a no-op. A changed amount/content/reference/time/direction leaves durable conflict evidence, preserves the original event hash and financial effects, and is ACKed only after commit. Detect conflicts even if incoming content no longer resolves an order. Canonicalize numeric scale and equivalent timestamp offsets; retain exact legacy-hash compatibility.

A verified transfer with createdAt <= paidAt < expiresAt can fulfill PENDING_PAYMENT or EXPIRED equally, regardless of polling. Existing fulfillment/current plan/future-period conflicts remain manual review with a durable reason; never grant twice. Invalid/missing dates, wrong amount, outgoing transfers and paidAt >= expiresAt remain rejected/reviewed.

API unchanged. No UI or new schema. Database remains source of truth; event unique key (provider,merchant_account,event_key), agency/order locks, fulfillment/wallet/ledger/outbox transactions remain authoritative. Event key reservation, conflict evidence and fulfillment rollback together on persistence failure. No Redis or real bank transfer, no commit/push.

DoD: new in-repo PostgreSQL regression tests fail before fixes, pass after; existing service tests and QA webhook/rollback/concurrency gates verified. Out of scope: invoice UI, outbox delivery, refunds, provider reconciliation and historical data backfill.

Additional acceptance found by AB-10: a second distinct payment for an already fulfilled order remains stored for review, while the original successful attempt and financial effects stay unchanged. Never downgrade SUCCEEDED to UNKNOWN because an extra payment needs review.


# Agency Plus renewal

Extend create order request action default UPGRADE; snapshot action and cycle-scoped idempotency key; add Plus renewal to existing locked transaction. Extract period grant utility; lifecycle advance in checkout/webhook transaction and scheduled worker per agency. Keep CURRENT/FUTURE/ENDED rows, no schema migration. Subscription DTO adds paidThrough/renewalScheduled; popup/card displays expiry/renewal/queued and uses cycle/action scoped keys. VI/EN updates. Test real PG rollback/replay/early activation/lapsed renewal, UI action scope.

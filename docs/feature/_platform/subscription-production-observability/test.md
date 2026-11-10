# Test plan

Confirmed seams carried from payment work: HTTP API + actual isolated PostgreSQL, fake SePay and existing external monitoring probe boundary. No Selenium/Apache Bench required for observability feature itself; existing payment regression assertions remain.

Correlation: valid supplied ID preserved, absent/invalid/multiple regenerated, userid never used as correlation, success/auth rejection/unhandled error have header, billing response ID matches header, MDC restored between requests. Logs never contain credentials/query/raw payload; labels exclude IDs. Fulfillment success not emitted before rollback.

Store: migration rerun safe; unique issue fingerprint, repeat upsert occurrence, resolved/reopen lifecycle, subject-only resolution, bounded pagination; distributed lease one owner, TTL recovery and owner-only release. Admin stale/revoked role denied.

Local snapshot: healthy grant/ledger/wallet no alert; drift and missing current fulfillment/grant alert; scheduled future missing credit ignored; legitimate cancelled/unpaid expired orders ignored; no alert resolved from unscanned scope. Inject concurrent updates and verify consistent snapshot. Reconciliation does not modify financial rows.

Provider: matched positive transfer/missing local payment alerts; known recorded payment healthy; wrong amount/late/multiple transfers review; account/code mismatch filtered; UUID provider IDs not equated to numeric webhook IDs; incomplete pagination/outage/rate-limit leave coverage unknown and existing issues intact; request budget/backoff/cursor fairness; no transaction held during external call. No synthesized webhook/automatic credit.

Collector: only opted-in subscription targets, first2failures silent, third emits one alert, subsequent failures no spam, PASS emits one recovery; DB versus service classification; unavailable ingestion still emits alert; safe metadata only. Default existing monitoring tests unchanged.

Run full changed-repo suites after focused RED/GREEN tests and actual Testcontainers scenarios. Do not connect production DB/provider or send real notifications. Record actual counts/skips and unapplied migration/setup requirements.

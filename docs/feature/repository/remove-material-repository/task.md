# Remove Material — Execution Checklist

Blocked by Add/View. Đọc spec→plan→task→test, plan R1–R5.

- [ ] R01 [R1] Audit current Material/status/ledger/schema, references/callers/provider policy;
  thống nhất không DELETED upload status, không agency_id denormalization.
- [ ] R02 [R1] Mongo tombstone/purge journal fields/indexes staged migration, ledger reuse,
  checker dry-run/idempotency trên disposable DB.
- [ ] R03 [R2] DELETE required expectedVersion/query, operation-aware retry204, tombstone/audit
  CAS; no storage delete/usage delta khi soft-delete.
- [ ] R04 [R2] Trash predicate count/page capabilities reuse View, only Manager or own-created.
- [ ] R05 [R2] Restore version/lease/HEAD/parent/profile guard, no quota check; expiry bypass
  đúng route trong subscription filter.
- [ ] R06 [R3] Reference inventory/pins/backfill/reference writer guard, content consumer
  reads vẫn hoạt động; unknown legacy blocks purge.
- [ ] R07 [R3] Scheduler dry-run→bounded claim/lease/fence/backoff, no shifted purge_after.
- [ ] R08 [R3] Provider durable deletion + versions confirmation, proof journal, PG unique
  PURGE_RELEASE/pool release replay, no double decrement.
- [ ] R09 [R4] UI delete/trash/restore with safe retry token, stale/context handling và honest
  quota messaging; no direct permanent delete endpoint.
- [ ] R10 [R4] Cập nhật song song vi/library.json + en/library.json, key/namespace parity.
- [ ] R11 [R4] Kiểm light/dark mode, keyboard/focus375/768/1440, confirmation accessibility.
- [ ] R12 [R5] Chạy test.md/fault injection/multi-worker race; candidate report/rollout gate.
- [ ] R13 [R5] Document no-go/rollback/pending accounting, không enable purge production hay
  run shared migration/commit/push trong bước chuẩn bị tài liệu.

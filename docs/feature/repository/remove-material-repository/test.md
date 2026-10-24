# Remove Material — Verification Plan

**Status: NOT RUN.** Fixtures từ Add/View + clock controllable, deletedAt boundaries,
Post/Task/derived references, unknown legacy key reference, provider versions,2workers/fences.

| ID | Task | Scenario | Expected |
|---|---|---|---|
| TC-R01 | R03 | Manager deletes any scoped file, Creator/Client own vs other, OWNER-only | Correct ACL/no cross-tenant reveal;204 only permitted, no quota/storage mutation |
| TC-R02 | R03 | Delete retry token same vs restore/re-delete cycle, stale/missing version | Same delete204 giữ retention, khác cycle stale409/missing400; no accidental delete newly restored |
| TC-R03 | R04 | Trash2Client, count/page, claimed/DONE records | Only manageable own/Manager; no preview, claimed no restore, DONE hidden |
| TC-R04 | R05 | used35GiB quota20GiB expired, valid restore via gateway |200, same used/reserved/provider, tombstone clear/version increment, no quota422 |
| TC-R05 | R05 | Missing object, inactive profile, parent deleted, expectedVersion stale, claim race |409/no partial restore; cannot turn Client internal or resurrect purged object |
| TC-R06 | R07 |30days-1ms/at boundary, reference blocked/backoff repeated | Before boundary no claim, after eligible; purge_after fixed, next_attempt distinct |
| TC-R07 | R06/R07 | Post/Task/descendant/publish job references, unknown legacy | No delete/usage release, blocked reason, existing content reads per content ACL |
| TC-R08 | R06/R07 | New pin/source write racing purge claim on separate instances | Exactly pin first blocks purge OR claim first denies new pin; no dangling published reference |
| TC-R09 | R07/R08 | Two workers/lease expire/stale heartbeat/restore concurrent | One effective purge op, old fence cannot finalize, restore can't run under claim |
| TC-R10 | R08 | Storage timeout, delete success then crash before Mongo proof | Retry identity safely; not assume success on timeout, no release while uncertain |
| TC-R11 | R08 | PG down after object deleted; PG release committed but Mongo timeout | OBJECT_DELETED recovery, unique release exactly once/no negative counters; eventual DONE |
| TC-R12 | R08 | Versioned bucket delete marker vs actual version deletion | Marker alone not completion/pool freed; durable version policy proof required |
| TC-R13 | R08 | SYSTEM_S3 file after expiry, SYSTEM_GDRIVE after paid upgrade | Persisted provider only, no migration/fallback, user/pool usage reconcile correct |
| TC-R14 | R09 | Soft-delete messaging vs usedBytes unchanged, conflict/retry/switch workspace | No false freed quota, inputs/status correct, stale responses ignored |
| TC-R15 | R10/R11 | vi/en/light/dark/keyboard/responsive | Correct confirmation focus and restored row, key/contrast/layout pass |

Tests use Mongo replica set+PG real for pins/ledger CAS concurrency, test endpoints for
delete/version proof, deterministic clock/lease barrier. Unit mocks only error branches;
UI tests outside src. Purge gate TC-R07–R12 needs actual evidence before enable. Record
commands/commit/actual/results; dry-run production report never counted as delete test pass.

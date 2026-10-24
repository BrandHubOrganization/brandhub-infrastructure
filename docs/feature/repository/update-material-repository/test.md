# Update Material — Verification Plan

**Status: NOT RUN.** Same core fixture Add/View + RAW của CreatorA, derivative CreatorB,
ClientX/Y, nested descendants internal/shared, deleted/purge claimed và versions0/1/2.

| ID | Task | Scenario | Expected |
|---|---|---|---|
| TC-U01 | U02 | Omitted vs null fields, empty payload, unknown sensitive fields, missing version |400 bad input, omitted preserved, only Manager INTERNAL can clear profile |
| TC-U02 | U02 | Unicode/quotes/CRLF/slash/traversal/name>255/extension spoof | Safe consistent display, MIME/key/byte unchanged, no injected attachment filename downstream |
| TC-U03 | U03 | CreatorB PATCH CreatorA, CLIENT other/uploader, Manager, OWNER-only | CreatorB denied original, Client own only/read scope, Manager allowed, Owner403 |
| TC-U04 | U03 | NonManager send visibility/profile by manual request; inactive/foreign profile |403 forbidden field or400 invalid target, no partial name update |
| TC-U05 | U03 | RAW↔RETOUCHED/purpose, attempt WATERMARKED/set binary metadata | Allowed types only; no byte/object/provider/usage/creator/task mutation |
| TC-U06 | U02/U03 | Two same-version PATCH, stale no-op and valid no-op | One write wins/version+1; stale409; fresh no-op200 without version bump |
| TC-U07 | U04 | Restrict ancestor while child upload/reference writer reads old revision | No publish/URL under stale audience; same fence serialization, no wider descendant leak |
| TC-U08 | U04 | Parent INTERNAL→CLIENT or ClientX→ClientY with descendant restrictions | No auto-open descendants; effective ancestor intersection, unresolved descendants fail closed |
| TC-U09 | U04/U05 | Crash each cascade batch, lease expires/stale worker tries finalize | No silent STABLE on incomplete ACL; recovery same op, stale generation cannot commit |
| TC-U10 | U05 | Mongo commit success response lost; PG audit down/consumer twice | No double PATCH; durable audit intent retained, eventual single AuditLog operation |
| TC-U11 | U09 | Paid expired/overquota, PATCH through gateway/filter | Metadata success đúng ACL; used/reserved/provider unchanged, no create-route bypass |
| TC-U12 | U06 | Conflict inputs kept, filter change removes item, switch context during save | Reload option no overwrite; correct invalidation; stale response ignored |
| TC-U13 | U07/U08 | vi/en/dark/light/keyboard/375/768/1440 | No key/layout/contrast/focus regressions |

Integration cần real Mongo replica set transaction và PG audit/test user scope; concurrency
assert cả database fields/reference/access revisions, không chỉ status HTTP. UI Playwright
ngoài src web; property-style filename fixtures cho Unicode/header. Record command/commit/
expected/actual/evidence, redacted no signed URL. U07–U10 fail/not-run →no-go audience update.

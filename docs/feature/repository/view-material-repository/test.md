# View Material — Verification Plan

**Status: NOT RUN.** Dùng fixtures AgencyA/B, WsA1/A2/B1,2Client cùng workspace,
CREATOR/Manager/OWNER-only/ADMIN, user nhiều profile; data RAW/RETOUCHED/WATERMARKED,
purpose đôi, all upload statuses, deleted/claimed, lineage transitioning, unknown legacy key.

| ID | Task | Scenario | Expected |
|---|---|---|---|
| TC-V01 | V02 | CLIENT get/list/count/search của profile khác/Agency khác | Không tên/count/URL leak, list empty/scoped, single404, nonmember403 |
| TC-V02 | V02 | JWT login WS1 nhưng request WS2 membership active, revoke/Client profiles nhiều | Path+PG state mới quyết định, không cached role/jwt scope sai |
| TC-V03 | V03 | Same created_at nhiều rows, page0/1/size20, filters combinatorial | Stable id tie-break, array data+meta; no duplicate tại dataset bất biến; concurrent write không hứa snapshot |
| TC-V04 | V03/V04 | Invalid page/size/sort/regex injection/search prefixUnicode, huge dataset |400 invalid; prefix escaped; explain hợp lý, không load-all rồi filter |
| TC-V05 | V05 | Page20 ready images cả hai providers | Một list,0 HEAD per item/0 extra preview POST để render grid; inline URL TTL≤300 |
| TC-V06 | V05/V06 | NonREADY/deleted/purge claimed/legacy no key | No URL/capability phù hợp; no public fallback; metadata error state rõ |
| TC-V07 | V05 | One provider signing unavailable, normal other provider | Metadata200 with item unavailable reason, optional refresh503, không redirect provider/public |
| TC-V08 | V06 | Preview expire, permission revoked/audience transition trước refresh | Refresh reauth, no new URL nếu revoked, bounded retry; old URL expiry limitation documented |
| TC-V09 | V07/V09 | OWNER-only ownAgency vs otherAgency; CLIENT request usage | Own aggregate/breakdown only; other denied; không file IDs/names/URL; CLIENT không Agency total |
| TC-V10 | V07 | Quota expired/overlimit, used includes trash, usage >2^53, reconcile pending | Reads enabled; total catalog không+base; byte string không precision loss, stale không zero fake |
| TC-V11 | V08 | RAW/ref badges, MOV unsupported, PDF sandbox, no media data | Warning không block; fallback usable, metadata MIME/size đúng, no external Docs Viewer |
| TC-V12 | V08/V12 | Switch workspace/logout khi query inflight, old full-list picker consumer | No stale flash, no persisted URL; picker explicit pages không silently missingitems |
| TC-V13 | V10/V11 | vi/en long text, dark/light, keyboard,375/768/1440 | Parallel keys, labels/contrast/focus/layout đúng |

Seams: real API+Mongo query/PG ACL integration; read usage fixtures dùng ledger Add;
provider signature tests thực từ G0; browser network assertions cho N+1/persistence;
Mock unit cho unavailable branch không thay provider proof. Kiểm subscription filter qua
gateway, không chỉ gọi service bỏ filter. Run focused Maven/Playwright/build/lint theo
scripts repo, record command/commit/actual/evidence, không report pass mặc định.
Acceptance gate: TC-V01/05/09 bắt buộc chống leak/N+1/OWNER exposure; missing evidence→not done.

# Download Material — Verification Plan

**Status: NOT RUN.** Fixtures từ Add/View,2Agency/2Client/multipleworkspace/OWNER-only,
READY active/nonREADY/deleted/claimed, parent RAW+child WATERMARKED, private providers.
Map Dxx task; tests giữ acceptance D01–D12 trong spec tổng.

| ID | Task | Scenario | Expected |
|---|---|---|---|
| TC-D01 | D02 | Missing/expiredJWT/member inactive/OWNER-only/wrongworkspace |401/403/404 scoped, no signer; path membership mới không JWT initial scope |
| TC-D02 | D02 | CLIENT wrongprofile incl multi-profile, modified materialId/key payload | No names/key/URL leak; no arbitrary URL/provider input, otherprofile404 |
| TC-D03 | D02/D09 | Paid expired/used>quota qua gateway/subscription filter | Actor đủ ACL vẫn200, no quota ledger mutation |
| TC-D04 | D02 | UPLOADING/VALIDATING/REJECTED/FAILED/deleted/claimed/root transitioning | No link; status errors đúng (deleted404,notready409), no status DELETED enum |
| TC-D05 | D03 | HEAD missing vs403IAM/429/5xx/timeout, size/type identity changed |409 missing/mismatch or503 unavailable, no signer/public fallback |
| TC-D06 | D04 | Revoke/delete while HEAD pending; lease lost, revision changed | Re-read/re-auth before issuance; no link under stale fence, bounded retry |
| TC-D07 | D04 | Byte fixtures png/mp4/pdf, selected WATERMARKED or RETOUCHED child | Actual byte identity/hash/type/size correct; no convert/parent substitution |
| TC-D08 | D04 | Unicode/space/quote/CRLF/slash filename, attachment actual HTTP | Safe fallback+filename*, correct Content-Type/attachment, no header injection |
| TC-D09 | D04/D09 | Unsigned GET vs signed, maxTTL120/credential earlier expiry, Range | Unsigned denied, signed works/retry until expiry, no new requests past expiry; transfer begun may continue |
| TC-D10 | D05 | Audit store unavailable/consumer duplicate, response lost retry | No URL on intent failure, durable issuance audit not completed, no signed URL persisted/logged |
| TC-D11 | D06 | List/detail doubleclick, switch/unmount response race, storage navigation expiry | One in-flight issuance per action, stale response ignored, user xin fresh link, no fake saved toast |
| TC-D12 | D06 | Video download network/heap, auth headers to storage | Bytes direct storage, no whole blob/API route, no app JWT/cookies forwarded |
| TC-D13 | D09 | Post/Publish existing signer uses previous configuredTTL; provider upgrade/expiry | Existing consumer contract remains, material provider persisted independent plan |
| TC-D14 | D07/D08 | vi/en/error≥5s,dark/light,keyboard,responsive375/768/1440 | Keys/state/toast/focus/contrast/layout pass, quota banner không disable download |
| TC-D15 | D09 | New requests after revoke vs URL đã phát | New denied, old may work until expiry; không test revoke tức thì trái BR14 |

Use service/controller tests for guards, actual HEAD/sign/HTTP each enabled provider for08/09,
private test environment only; browser download event can assert test file hash but production
UI không được suy ra saved. APM/log scan assertions redacted. Focused Maven/Playwright/build/
lint theo scripts repo; evidence command/commit/config/version/expected/actual/result, tokens
redacted. Missing real-provider proof→NOT RUN/no-go download, không report pass từ mocks.

# Add Material — Verification Plan

**Execution status: PARTIAL; G0 NOT RUN / rollout NO-GO.** Kết quả thực thi và giới hạn nằm ở
[evidence.md](evidence.md); không coi toàn bộ case bên dưới đã pass.
Seam chính Material API + PG thật + Mongo replica set disposable + từng private storage test
endpoint. Mock unit dùng cho logic/error, không thay actual capability test. Clock injectable.

## Fixtures và isolation

AgencyA BASIC20GiB, AgencyB paid ACTIVE quota lấy catalog fixture, expired clock boundary;
hai workspace AgencyA, hai CLIENT profiles cùng workspace, MANAGER, CreatorA/B, OWNER-only,
CLIENT nhiều profiles, user membership revoked. TASK assigned active/finished/cancelled.
Files tiny valid samples + exact limit/beyond limit streaming fixtures (không buffer1GiB).
Ảnh bomb, fake MIME, Office OLE2/OOXML đổi đuôi, PDF malformed, MP4/MOV bounded structure.

| ID | Task/AC | Input / scenario | Expected |
|---|---|---|---|
| TC-A01 | A02/G0 | Each provider signed PUT/GET, unsigned access, HEAD/Range/metadata, TTL | Signed đúng object; unsigned denied, range206, type/size thực, expiry enforced |
| TC-A02 | A02/G0 | Validate ETag X, mutate staging to Y rồi conditional copy X | Copy fail; không READY/copy Y dưới kết quả validate X |
| TC-A03 | A02/G0 | Restart rclone/SSD full/network Drive429/403 ngay sau write ack | Không READY nếu chưa durable, retry bounded, không fallback S3 BASIC; chứng minh recovery bytes |
| TC-A04 | A03/A11 | OWNER-only, CLIENT other profile, user đổi workspace/JWT initial khác path | OWNER denied; scope theo path/member PG; không reserve hoặc phát URL trái phép |
| TC-A05 | A04–A06 | Migration dry-run/apply twice trên data legacy/duplicate indexes/unknown URLs | Dry-run no write, idempotent, invalid report, không drop data hoặc auto READY unknown |
| TC-A06 | A07 | BASIC/paid ACTIVE/period ended nhưng status stale ACTIVE | Quota21474836480 hoặc đúng catalog total, không cộng20GiB; effective clock đúng |
| TC-A07 | A08 | Hai upload tổng vượt còn trống trên nhiều instance | Chỉ reservation vừa quota thành công, used+reserved không vượt limit; không deadlock |
| TC-A08 | A08 | Agency sát20GiB, file vượt ranh giới paid vs BASIC | Whole-file S3 chỉ paid đủ quota, provider lưu cố định; BASIC422 |
| TC-A09 | A08 | Pool79/80/94/95%, projected peak vượt95, observation stale, create Agency |80 warn,95/projected cap block503, entitlement không overpromise, BASIC không overflow |
| TC-A10 | A09 | Repeated COMMIT/RELEASE/EXPIRED, commit rồi release retry | Unique op giữ ledger; reserved/used≥0, không release committed như chưa dùng |
| TC-A11 | A11 | Same clientRequestId same/different fingerprint | Same identity/session, diff409, no duplicate counters |
| TC-A12 | A11 | Legacy Mobile missing context, task missing/other assignee/finished | TASK semantics/video MOV1GiB giữ; invalid denied create và confirm, no null task bypass |
| TC-A13 | A12 | Types/size exact/+1, zero/negative, MIME spoof/container/image bomb | Reject invalid400, valid đúng BR12; Office/TXT/CSV reject dù đuôi đổi |
| TC-A14 | A12 | HEAD404 PUT chưa xong; confirm hai instance; lost permission/task cancelled | Retry trong expiry hoặc409; không READY khi revoked; session owner khác không lấy record |
| TC-A15 | A12 | Source overwrite after Range, old PUT reuse after READY | Same validated source identity frozen; READY canonical byte unchanged; no redirect public |
| TC-A16 | A12/A13 | Crash after PG reserve, Mongo insert, copy, PG COMMIT, before Mongo READY | Reconciler resumes/releases đúng state; không leak quota hoặc double material, không release COMMITTED |
| TC-A17 | A13 | Cancel session, delete staging rồi PUT cũ tái tạo trước expiry | Pool peak hold đến expiry+cleanup; quota release idempotent, staging không public |
| TC-A18 | A12 | Plan expires sau reserve trước confirm còn hạn | Không cấp thêm reservation, phiên đã cấp hợp lệ vẫn commit; ACL/task revoke vẫn reject |
| TC-A19 | A14 | Old WebP converted/foreignURL/missing object/legacy keys same across providers | Actual MIME/size, no original recovery claim, no public/SSRF fallback, no key collision migration |
| TC-A20 | A15 | Watermark PNG, parent shared then revoked, quota bound/result bytes | Correct output key/PNG/ACL/purpose/task; no overquota; parent revoke serialize, no wider child |
| TC-A21 | A16 | Browser PUT fails vs confirm times out; workspace switch/abort | Retry đúng stage/session, no JWT to storage, no READY toast/card before confirm |
| TC-A22 | A17/A18 | vi/en, long name, keyboard, dark/light,375/768/1440 | Key parallel, controls/focus/contrast/layout intact, type/limit/quota message rõ |

## Commands và result recording

Business: Maven focused Material/WorkspaceAccess/Billing/quota tests; integration profile
chỉ disposable endpoints/containers. Web: build/typecheck/lint theo package scripts và
Playwright feature tests ngoài src. Infra: migration checker trên PG/Mongo test, G0 integration
script dùng env secret không in stdout. Tên test class/command mới chốt khi implementation,
không ghi đã pass khi chưa có binary. Không load .env production hoặc chạy APPLY live.

Mỗi result ghi ID, commit, config version, command, actual, pass/fail/not-run, evidence
path; URL/query token phải redact. G0/G1 failed/not-run → NO-GO write provider. G1 gồm
TC-A07/10/16/17 kiểm ledger/counter/physical pool đối soát sau crash, không chỉ HTTP200.

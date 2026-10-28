# Add Material — Implementation Plan

**Input:** [spec.md](spec.md), BR01–BR25; ticket01. Đây là design cần implement, không phải hiện trạng.
**Dependencies:** không ticket blocker. Gate G0/G1 cần pass trước bật write production.
**Execution:** P0→P1→P2→P3→P4→P5→P6→P7→P8; không bỏ gate, không chạy migration live.

## P0 — Inventory và capability gate G0

Đọc rules repo, git status/HEAD, caller Material multipart/Mobile/editor/watermark/Post/Publish,
subscription request filter, storage clients, Mongo schema/index và PG billing migrations.
Xác nhận `billing_plan_versions.storage_limit_bytes` là field persistence cho quotaBytes;
resolve effective subscription theo lifecycle/period clock, không tin ACTIVE đã hết end.
Không sửa giá/quota paid catalog. BASIC20GiB là business requirement migration cần review.

G0 chạy trên endpoint/bucket test của từng provider, không production:
signed PUT/GET + HEAD/Range + attachment/inline + conditional copy source ETag mismatch
phải fail + copy metadata/MIME + delete/idempotency + restart/cache recovery/durable ack.
Phải chứng minh copy nguồn đã validate không đổi bytes, canonical không có presigned PUT;
storage trả success nhưng chỉ có byte trong SSD chưa durable thì không READY. Inject
Drive429/403/SSD-full/restart; không auto overflow BASIC sang S3. G0 chưa pass thì provider
không enabled, API trả503 trước reservation hoặc release reservation theo saga; không
đánh dấu feature hoàn tất khi chỉ mock. Ghi version/config/credentials type (không secret),
expected/observed trong test evidence. Đây là external gate nếu chưa có test endpoint.

## P1 — Module boundary và shared protocol

Reuse controller/service/FileStorageService; tách helper vừa đủ để MaterialService không
thành monolith: MaterialAccessPolicy, MaterialContentValidator, MaterialUploadCoordinator,
StorageQuotaService, StorageClientRouter (tên mới đề xuất). Không service mạng mới.

MaterialAccessPolicy resolve workspace path→PG membership/client profiles/account status;
trả immutable actor scope và mandatory Mongo predicate. OWNER fallback không cấp vận hành.
Mọi scoped query bắt buộc workspace, CLIENT thêm audience/profile. Không cache ACL.

Add cung cấp MaterialMutationLease dùng Mongo single-document CAS + token/generation/
leaseUntil cho root lineage và durable reference pin store. Mutation worker nhận lease
phải kiểm lease còn sống/generation trước mỗi commit; mất lease thì fail closed. Reference
writers/new derivatives và purge dùng cùng protocol. Mongo replica set transaction ngắn
được dùng khi commit root revision/pins/material cùng DB; không fallback multi-write không
atomic trên standalone. Không bao external I/O trong Mongo/PG transaction.
Read/preview/download recheck root accessRevision/access_state sau external call; mutation
đang chuyển audience thì tạm không cấp URL. Các ticket03/04 mở rộng protocol, không tự khóa khác.

## P2 — Schema expansion (G1: accounting invariant)

### PostgreSQL — đề xuất bổ sung sau inventory

| Relation | Khóa/field/constraint |
|---|---|
| agency_storage_usage | agency_id PK/FK agencies, used_bytes/reserved_bytes bigint≥0, version, updated_at; aggregate mọi workspace |
| agency_storage_reservations | id UUID PK, agency_id FK, workspace_id FK, material_id/session_id string, actor_id, request_key, fingerprint, provider, reserved_bytes>0, expires_at, state RESERVED/COMMITTED/RELEASED/EXPIRED, timestamps; unique(agency_id,actor_id,request_key), unique material/session operation |
| storage_usage_entries | operation_id UUID, agency_id FK, workspace_id FK cho workspace operations, reservation_id nullable FK, material_id, kind RESERVE/COMMIT/RELEASE/PURGE_RELEASE/RECONCILE, used_delta/reserved_delta, created_at; unique(agency_id,operation_key); append-only |
| system_storage_pools | provider PK, capacity_bytes>0, durable physical_used_bytes, reserved_peak_bytes≥0, observed_at, version; private endpoint health/config not secrets |

Nếu relation tương đương đã có thì dùng/extend thay vì duplicate. Quota resolve catalog
không copy quota vào ledger làm nguồn hiện hành. `material_id` là soft reference, không FK
cross-engine. Không ghi agency_id vào Mongo content. Migration idempotent/versioned,
check DB target, backup, dry-run, constraint/index preflight; update init templates và docs.

### Mongo

Giữ materials snake_case, existing IDs/task_id/watermark lineage. Optional expansion trước:
storage_provider, status, media_kind, purpose, visibility, client_profile_id, normalized_name,
version, deleted_at/by/purge_after, session_id/upload_context/session_expires_at, staging_key,
updated_by, access_revision/access_state, mutation lease fields; s3_key chỉ canonical khi READY.
Session record (material_upload_sessions) lưu immutable actor/workspace/task/parent/provider/
keys/declared size/MIME/fingerprint/expiry, progress/error và operation IDs; unique workspace+
actor+clientRequestId, key/session identity. Material row được tạo sau reservation bằng retry.
Reference pins dùng collection scoped material_references với unique(workspace,target,
sourceType,sourceId,operationId), root revision. Không Mongo TTL làm mất session trước release.
Indexes theo workspace/status/date/id, CLIENT profile, session identity, due cleanup;
partial unique(provider,s3_key) cho canonical đã xác minh. Không unique s3_key toàn provider.
Validators staged warn/optional→backfill→strict, không fresh init trên Atlas dùng chung.

## P3 — Accounting và routing

Lock order thống nhất: system_pool row trước agency row trong mọi write cần pool; ledger
và reservations cùng PG transaction ngắn. Billing hiện lock agency; không gọi lifecycle
nested với lock ngược, resolve/update lifecycle trong transaction theo cùng thứ tự nếu cần.
Không HTTP/HEAD/Range/copy trong tx giữ lock. Tất cả mutation counters có unique operationKey.

Reserve n bytes: resolve paid period đúng tại now (BASIC/expired=21474836480), kiểm
used+reserved+n≤quota. Chọn whole-file provider theo tổng sau reservation; vượt20GiB
chỉ paid ACTIVE đủ quota mới SYSTEM_S3. SYSTEM_GDRIVE giữ peakphysical đủ cả staging+
canonical dự kiến và existing physical overhead; kiểm projected physical≤95% pool,
warn≥80%. Headroom/stale observation không chứng minh capacity thì fail503, không đoán.
Agency creation entitlement path cùng guard capacity, không chỉ upload.

COMMIT: reservation RESERVED→COMMITTED, reserved-=n, used+=actual (actual phải bằng declared
đã reserve; khác size reject). RELEASE/EXPIRED chỉ RESERVED mới reserved-=n. Không thể
release COMMITTED; file bị bỏ sau commit đi compensating purge accounting operation,
không trừ used bằng counter update tùy ý. Trash tính used; purge unique release do04 dùng.

Peak physical reservation giữ tới PUT expiry + grace và cleanup xác nhận. Presigned PUT
dùng lại có thể tái tạo staging nên không release pool overhead sớm. Canonical durable
được reconcile vào physical_used, rollback/delete bền mới giải phóng. USER_GDRIVE rejected.

## P4 — Session saga, validation và immutability

Giữ TTL library10phút/TASK15phút theo compatibility spec, không đổi thành một giá trị ngầm.
Session hết hạn và confirm claim phải serialize: worker đang VALIDATING renew lease/reservation
trong processing deadline bounded; expiry job không release reservation đang được promote.
Quá deadline thì recovery claim checkpoint, không blind release khi canonical có thể đã tồn tại.

Create: authorize→reserve PG (idempotent fingerprint)→upsert Mongo session/material UPLOADING
→sign PUT. Nếu Mongo/sign lỗi, record retry/release; không chỉ dựa trên catch của request,
scheduler scan ledger orphan để release phiên hết hạn. Retry trả cùng identity, không dùng
URL expired; refresh target có attempt key riêng, reservation không double.

Confirm: lock claim session→reauthorize actor/task/profile/parent→HEAD(size/version/ETag)
→conditional bounded range with same identity→parser whitelist (JPEG/PNG/WebP, MP4/MOV,
PDF; chống decoded image bomb/resource limit)→conditional copy canonical→verify durable
destination→persist promotion checkpoint Mongo→PG COMMIT→Mongo READY transaction + pin
reference/parent check. Retry từ từng checkpoint, không copy public/upload old WebP path.
Concurrency409 khi claim khác đang valid; HEAD404 trước PUT xong giữ UPLOADING/retry trong hạn.
Terminal invalid type/state/revoked→REJECTED/FAILED và release/cleanup idempotent.

READY cần durable accounting commit; PG commit rồi Mongo timeout thì giữ VALIDATING,
reconciler finish READY hoặc comp cleanup; không release COMMITTED như reservation chưa dùng.
Epoch root parent ghi lúc promote; parent ACL đổi thì retry/reject, không leak child.
Gói hết hạn sau reserve không hủy capacity đã cấp nếu phiên còn hạn; confirm không tăng byte
ngoài reservation. Quota enforcement chỉ tạo mới; không sửa SubscriptionRequestFilter thành
bypass toàn bộ mutation. Chỉ miễn các read/metadata/restore routes theo BR20–21.

## P5 — Legacy và watermark compatibility

Inventory URL→known bucket/provider/key/workspace, HEAD verify mime/size; legacy public
object copy private và update reader/caller trước retire public origin. Unverifiable→FAILED
metadata, không public fallback. Backfill existing objects từng Agency vào usage ledger với
unique migration keys; reconciliation phải tính trash/derived, không reset counters khi live.
Writer pause/controlled cutover cho legacy accounting; reconcile-only không tự trừ dữ liệu.

Multipart5MiB reuse coordinator và validator; response compatible nhưng byte gốc không convert.
Mobile TASK thiếu context giữ task guard/video1GiB, legacy key chỉ map session actor đã lưu.
Sessions trước deployment hết hạn/tạo lại. Không sửa mobile repo trong scope này; nếu app
không xử lý expired response thì báo compatibility gate, không tuyên bố zero-change.

Watermark: read provider/key qua trusted storage, logoID/allowlist; quota reservation dựa
upper bound output cấu hình, encode PNG, verify actual≤reserved rồi commit actual/release
remainder trong một PG tx (chỉ derivative flow cho phép bound). PNG output/canonical MIME
size đúng, giữ audience/purpose/task/lineage, no key overwrite. Không expose URL arbitrary SSRF.

## P6 — Files/modules dự kiến

Repo paths bên dưới tương đối root từng repo; **mới** nghĩa chưa tồn tại, không phải reuse.

- Business existing: `controller/MaterialController`, `service/MaterialService`,
  `service/impl/MaterialServiceImpl`, `service/FileStorageService`, `impl/S3FileStorageServiceImpl`,
  `document/MaterialDocument`, `repository/MaterialMongoRepository`, Material DTOs,
  `security/SubscriptionRequestFilter`, `config/AwsProperties`, ErrorCode.
- Business new helpers ở service/ và config theo P1; không thêm interface vô consumer.
  Database access/quota JDBC theo pattern BillingPlanCatalogService/AgencySubscriptionLifecycle;
  audit reuse AuditLogRepository qua retryable outbox record, không log secret.
- Infra migrations mới `docs/database/migrations/<date>-repository-foundation.sql/.js`,
  migration checker/fresh-init/compose storage test profile và deployment/runbook config;
  tên date chốt lúc implementation, không apply vào DB shared trong task này.
- Web `src/services/materialService.ts`, `src/types/material.ts`, Library MediaUploadButton,
  upload form/hooks riêng feature và editor Dropzone consumer; reuse `src/lib/axios.ts`.
- Locale **`src/i18n/locales/vi/library.json` + `en/library.json`**, cùng i18n registration nếu
  namespace chưa map; vi.json/en.json root trong rule cũ không đúng tree hiện tại.
- Tests Business src/test, web tests ngoài src, infra migration tests/test fixtures.

## P7 — UI và integration

Metadata form + upload progress/confirm states; controls khóa CLIENT own profile, INTERNAL
default cho staff, RAW warning không biến thành blocker. Lỗi quota422/capacity503 phân biệt.
Không khóa upload chỉ vì usage==quota khi đang resume một reserved session hợp lệ;
request mới phải reserve lại. Abort browser không coi đã xóa object hay release accounting.
Query usage từ backend, không tự lấy tổng bằng list. Add có thể refresh bằng existing list
trong giai đoạn View chưa land, không cần implement View mock song song. i18n key groups
repository.upload*/validating/invalidType/sizeLimit*/quotaExceededError/poolCapacityError/
retryConfirm/clientRequired; user filename là data. Theme tokens, keyboard, responsive.

## P8 — Verify, rollout và rollback

Chạy test.md; schema expand→reader compatibility→ledger backfill→capability proof→new
writers→consumer private switch→retire public→strict validators. Feature flag write-provider
off đến G0/G1 pass; health check không leak credentials. Metrics reservation age, reconciliation
backlog, actual/ledger variance, pool physical, provider failures. Không bật Redis cache.
Rollback writer flag trước; không drop ledger/fields/data hoặc quay về public URL. Reader
rollback chỉ binary tương thích expanded schema. Báo gate chưa pass thay vì đánh dấu Done.

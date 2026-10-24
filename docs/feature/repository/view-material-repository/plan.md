# View Material — Implementation Plan

**Input:** spec.md, ticket02; **Blocked by:** Add foundation/schema/private storage/shared ACL.
Không tạo backend Repository khác. Ký hiệu V1–V6 dùng trong task/test.

## V1 — Inventory và query policy

Reuse MaterialController/Service/Document/MongoRepository, MaterialAccessPolicy của Add,
WorkspaceAccessService và RequireRoleAspect. Inspect callers `materialService.list/get`,
Library MediaTab, editor/watermark và legacy url usage; không đổi `data` array thành object.
Active actor scope tính từ workspace path + PG account/member/profiles, ADMIN vẫn scoped.
CLIENT query profile ngoài scope →empty (không403 tiết lộ profile tồn tại); single mismatch404.
OWNER billing-only bị403 Library; Owner có membership vận hành dùng vai trò workspace.

Build một scoped Criteria builder dùng chung list/count/get/preview: workspace + active/
trash + caller audience + access_state + root effective audience. Không findById unscoped.
Lineage transition fail closed, root revision rechecked trước trả URLs. Không filter hậu
pagination; data và total cùng predicate. Count và page là read-consistent best effort;
concurrent writes có thể thay count giữa request, không hứa snapshot multi-request.

## V2 — API/pagination và Mongo indexes

GET base page≥0,size1–100/default20, search≤100 prefix normalized escaped, mediaKind/type/
purpose/clientProfileId, deleted defaultfalse, sort newest/oldest. Stable sort(created_at,_id)
cùng chiều. Response ApiResponse<List<MaterialResponse>> + MetaBody(page,size,total), requestId.
Reject invalid enum/page/sort400. Bound offset theo DB int range, không silently clamp.

GET /{id} metadata/capabilities/preview nếu READY; deleted record không active detail.
Trash list chỉ enable khi Remove landed: Manager all, Creator/Client own-created trong ACL,
chưa DONE/purge unavailable; đó là predicate extension của Remove, không duplicate query.

Add migration đã có fields; View chỉ add index nếu explain cần: workspace/deleted/status/
created_at/_id và CLIENT audience/profile prefix; normalized_name index đo prefix query,
không assume case-insensitive substring tận dụng index. Projection metadata bounded, avoid
fetch toàn aggregate. Large/deep offset monitor, cursor future không đưa vào MVP.
MaterialResponse thêm fields version/type/purpose/mediaKind/visibility/clientProfileId/
rawWarning/previewUrl/previewExpiresAt/capabilities; không DTO s3Key/secret/staging URL.

## V3 — Preview và capability mapper

Inline signer options TTL≤300s theo provider persisted, MIME allowlist verified. Không HEAD
trong list/get mỗi item, không20 HTTP preview calls cho20 items. Không tạo thumbnail/video
poster worker trong scope. Images dùng signed original, video controls/range và fallback MOV,
PDF sandbox/viewer origin tách app; unsupported chỉ metadata. Legacy no verified key →no
preview + reconciliation flag, không public fallback. No-store control response.

Một provider disabled: metadata page vẫn trả nếu DB khỏe, item previewUrl null/canPreview=false
và previewUnavailableReason generic; optional refresh503. Không âm thầm cấp URL sai provider.
Đây là best-effort URL generation, không HEAD existence; missing có thể chỉ phát hiện lúc
media load/download. Frontend fallback thay retry storm. Không đổi lifecycle READY chỉ vì
credential signing lỗi tạm thời. Root revision/visibility đổi trong mapper thì bỏ URL/retry read.

Capabilities từ shared policy và feature flags: read/download READY active; rename/delete/
restore theo ownership; canChangeAudience Manager; không hứa endpoint chưa land. Không
khóa read theo quota. Refresh detail/POST preview phải reauthorize, ít nhất throttle in-flight
và bounded retry một lần cho expired URL, không persist signed URLs.

## V4 — Agency usage và OWNER exception

Add cung cấp PG used/reserved ledger + effective quota resolver. GET /api/v1/agencies/
{agencyId}/storage-usage kiểm PG owner_id (ADMIN support nếu policy hiện có), không role
claim/agencyId query untrusted. Response usedBytes/reservedBytes/quotaBytes, workspace
breakdown và updatedAt/reconciliationPending; không file ids/names/preview. Aggregate chỉ
Agency đích. Usage bytes dùng decimal-string DTO theo BillingPlanResponse convention để
không mất bigint precision JS; test ≥2^53. Workspace breakdown aggregate bằng ledger scope
workspace/session metadata Add, không phải material listing. Ticket Add cần entries mang
workspaceId để View aggregate không join content toàn hệ thống.

Workspace usage endpoint hiện có/đề xuất chỉ trả workspace slice cho Manager/Creator;
CLIENT không nhận tổng Agency/Client khác. Billing owner view separate, không sửa ROUTE_ACCESS
Library thêm OWNER. Quota snapshot đang reconcile ghi stale status, không zero usage giả.
SubscriptionRequestFilter allow list/get/preview/usage dù expired, không bypass auth/membership.

## V5 — Files và UI

- Business existing MaterialController, MaterialService/impl, MaterialMongoRepository,
  MaterialResponse/MetaBody/ApiResponse, subscription filter; new scoped query mapper và
  usage read facade chỉ nếu shared helpers chưa đủ, không storage duplicate.
- Infra Mongo index/checker nếu explain cần; Pg entries workspace projection dùng Add,
  không tạo usage table mirror.
- Web existing `src/pages/library/components/MediaTab.tsx`, MediaDetailPanel, `index.tsx`,
  `src/services/materialService.ts`, `src/types/material.ts`, `src/types/contentLibrary.ts`,
  `src/routes/access.ts` chỉ capability-compatible, Billing/Subscription panel hiện có.
- Locales chính xác `src/i18n/locales/vi/library.json` + `en/library.json`; usage billing
  dùng song song `vi/subscription.json` + `en/subscription.json`. Register namespace hiện có.
- Tests Business src/test, web tests ngoài src; không commit test files trong src web.

TanStack key includes workspace/client/filter/page/actor context; invalidate scoped after
mutation, abort on switch/logout; no Zustand/localStorage server-data copy. UI giữ brand,
primitives, available-width detail; loading/empty/filtered-empty/error/forbidden/validating/
previewUnsupported/previewExpired; RAW warning badge, purpose/reference labels; no mock success.
i18n groups repository.title/search*/filter*/rawWarning/purpose*/preview*/empty*/retry/
forbidden/usage*; vi/en parity, light/dark contrast, keyboard/focus,375/768/1440.

## V6 — Delivery và compatibility

Migrate consumers expecting full list to explicit paging, giữ old method return array và
add listPage metadata helper cho Library. Không để silent20-item truncation trong picker.
Integrate upload callback Add→new query list, no duplicate API. Action flags on03–05 land;
Remove cung cấp trash extension, View không implement restore sớm. Read canary trước enable
UI; rollback disable preview signer/UI query mới nhưng không fallback public object.
No Redis ACL/list/URL cache. Verify test.md, query explain, request counts và billing isolation.

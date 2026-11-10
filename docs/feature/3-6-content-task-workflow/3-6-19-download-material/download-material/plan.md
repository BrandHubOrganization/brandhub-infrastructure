# Download Material — Implementation Plan

**Input:** spec.md/ticket05. **Blocked by:** Add private canonical/provider/lease và View list/detail.
Update/Remove không blocker ticket, nhưng integration test revoke/delete phải chạy khi các
FR đó land; vẫn tự fixture deleted/transition trước đó để verify contract. D1→D5.

## D1 — Service contract và guard

Extend MaterialController/MaterialService bằng POST base/{id}/download, no request body,
ApiResponse<MaterialDownloadResponse> record filename/mimeType/fileSize/downloadUrl/expiresAt.
Frontend fileSize theo shared DTO convention; bytes từ immutable verified metadata và HEAD,
không từ request. RequestId fallback, no-store; error response không chứa bucket/key.

Shared MaterialAccessPolicy: PG account/workspace path membership active/profiles, scoped
material + effective root audience. OWNER no ops403; CLIENT mismatched404; ADMIN existing
support scoped/audit. No quota reservation/usage read dependency trong read path; effective
expired plan không chặn route trong SubscriptionRequestFilter.
READY + deleted_at null + purge_state NONE + root access_state STABLE. Không copy parent
or fallback url/provider; legacy chưa private-key verified trả unavailable/no signer.

## D2 — HEAD, race ordering và signer

Get provider/key stored immutable; key prefix allowlist/workspace validated, không URL parse
từ browser. Adapter HEAD có timeout/retry bounded; missing409 storage_missing, provider403/
429/5xx/timeout503 generic. Nếu HEAD size/MIME khác verified immutable material thì409
material unavailable+reconcile, không âm thầm đổi metadata hoặc tải object lạ.

Không giữ PG/Mongo transaction qua HEAD. Sau HEAD lấy short material/root lease/fence Add,
reauthorize/re-read status/version/root revision mới nhất trước ký. Delete/revoke dùng cùng
protocol; nếu trước acquire khác revision →retry read tối đa1 hoặc409, không unbounded loop.
Sign trong critical section ngắn (credentials refresh preflight ngoài lock), no file bytes
through Business. Nếu lease mất trước response fail503 và không trả signed URL.

FileStorageService overload options record (provider,key,TTL,disposition,type) reuse existing
S3 clients/router; cũ createPresignedDownloadUrl(key) giữ Post/Publish behavior/TTL3600 nếu
đang cần, không global đổi thành120. URL TTL min(120,credential remaining),expiresAt thực.
Response signed GET attachment, RFC filename* UTF-8 plus safe ASCII fallback, trusted MIME,
private/no-store overrides nếu provider hỗ trợ G0. Test actual HTTP không chỉ kiểm builder.
Sanitize qua FilenamePolicy Add/Update; don't encode entire Content-Disposition twice.
READY key immutable tránh HEAD/GET TOCTOU, provider có mutation outside app phải cảnh báo
operationally; storage identity mismatch fail closed, không coi ACL PG là IAM protection.

## D3 — Audit và secret handling

Sau guard/sign trước trả URL ghi DOWNLOAD_LINK_ISSUED durable outbox/audit intent bằng
shared Add mechanism operationId/requestId; không signed URL/signature/bucket credentials.
Audit failure503 no response URL. Retry xin link có thể tạo event cấp link mới, không suy
diễn one-time hoặc exactly-once download. Outbox duplicate consume giữ single AuditLog event.
Release lease after intent+state check; request ordering linearized tại issuance, URL cũ
sau revoke có thể dùng đến TTL. Không audit download completed/browser saved.
API/gateway logging/APM mask query string storage URLs, body redaction for downloadUrl;
không cache DTO signed URL trong Redis/localStorage/analytics/error tracker.

## D4 — Files và UI

- Business existing MaterialController/Service/impl, FileStorageService/impl/options/config,
  shared access/lease/filename/audit, ErrorCode + proposed MaterialDownloadResponse record,
  SubscriptionRequestFilter allow download route, audit schema mapping reused.
- Gateway existing protected route, logging redaction/correlation only khi cần; không route
  binary stream hoặc public exception cho download.
- Web `src/services/materialService.ts`, `src/types/material.ts`, MediaTab/MediaDetailPanel,
  proposed useMaterialDownload feature hook, shared API client; no axios auth to storage.
- Locales **`src/i18n/locales/vi/library.json` + `en/library.json`**, keys repository.download/
  preparingDownload/downloadStarted/downloadFailed/storageMissing/linkExpired/
  switchWorkspaceCancelled/unavailable; reuse equivalent keys thay duplicate texts.

Hook capture workspace/material/request generation, disable button during link request,
abort on unmount/switch and ignore stale response even if fetch abort race. Browser anchor/
navigation direct URL (attachment header quyết định download, không rely HTML download
cross-origin). Không `_blank` auth token, không fetch entire blob. Button accessible name,
aria-busy, state pending/retry,error≥5s; toast “Đã bắt đầu tải xuống”, no percent giả khi chỉ
navigation. Không hứa tự bắt được storage-expired navigation; bấm lại xin fresh link.
Vi/en, theme/light/dark, keyboard/responsive. Quota lock banner không disable Download.

## D5 — Verification và rollout

Test through gateway/subscription filter + provider actual G0 để kiểm unsigned denied,
attachment names/range/expiry/byte identity và network no API heap video. HEAD per download
là deliberate existence check, không tái dùng per-grid HEAD. Recheck parent selected
WATERMARKED/RETOUCHED đúng key; file legacy converted chỉ có actual stored original.
Run regress Post/Publish longer-lived signer, watermark private reads. Enable action only
khi endpoint/provider/audit ready; rollback disable issuance UI/API, link cũ expiry tự nhiên,
không đổi ACL policy public hoặc xóa data. Record test actual chưa chạy NOT RUN.

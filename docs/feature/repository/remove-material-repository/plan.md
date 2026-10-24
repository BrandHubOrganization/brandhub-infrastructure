# Remove Material — Implementation Plan

**Input:** spec.md/ticket04. **Blocked by:** Add reference/lease/ledger contract và View query/UI.
Không phụ thuộc Update ticket đã land nhưng bắt buộc cùng protocol để không race khi land sau.
R1→R2→R3→R4→R5; không Redis job queue hoặc microservice mới.

## R1 — Tombstone contract/schema

Reuse materials upload statuses; deleted_at/by, purge_after giữ nguyên retention30ngày.
purge_state NONE/CLAIMED/OBJECT_DELETED/DONE, purge_operation_id, lease_owner/until/generation,
next_purge_attempt_at, blocked_reason, last_error_redacted, object_deleted_at,
quota_released_at, purge_completed_at. NONE là chưa claim, không mặc định file active khi
deleted_at có giá trị. Không đưa DELETED/PURGED vào Material.status.

Mongo index workspace/deleted/date/id cho trash, partial due purge fields/next attempt;
generation/version CAS. Giữ minimal tombstone sau DONE, filter khỏi trash, không Mongo TTL
delete metadata trước binary/accounting hoàn tất. Add schema đủ thì không duplicate migration.
Audit intent/outbox dùng Add; PG storage_usage_entries PURGE_RELEASE unique agency+material/op
thay vì tạo material_quota_releases cạnh tranh. Immutable provider/key/size snapshot trong
purge journal để worker không xóa record bị đổi identity.

## R2 — Soft delete, trash và restore

DELETE base/{id}?expectedVersion=n required,204 no body (không ApiResponse JSON body204).
Authorize theo Add, scoped record READY, ownership Manager all hoặc Creator/Client own.
Lease/root protocol bảo vệ reference creation; CAS version, set tombstone và updatedAt,
version+1, audit intent. Retry đã deleted bởi operation tương thích trả204 trước stale
check nhưng không reset retention; nếu current operation khác như restore/redelete thì
stale409, không nuốt nhầm một delete mới. Dùng requestId/idempotency action token bền từ
client/server operation journal để phân biệt retry qua cycles; không thêm endpoint khác.

GET deleted=true mở rộng predicate View chỉ quản lý file mình có quyền mutate, áp trước
count/page. CLAIMED/object-deleted không có restore capability, hiển thị đang dọn; DONE
khỏi list. Deleted không preview/download mới. Existing Post/Task đã pin file có thể đọc
qua content permission route của riêng nó, không dùng Library URL bypass; canonical giữ
nguyên cho tới hết reference. Document/consumer không có đường đọc an toàn thì cutover gate.

POST /{id}/restore body expectedVersion required. Acquire same material/root lease với
purge, chặn CLAIMED/OBJECT_DELETED/DONE409; reauthorize current workspace/profile,
HEAD private object identity, check parent effective audience/access_state, recheck fence,
transaction clear tombstone+version++, audit. Không reserve/check quota; trash đang used,
usage giữ nguyên dù paid expired/vượt20GiB. Parent deleted/missing hoặc profile inactive
→409, không chuyển internal/root để lách. Quá30ngày mà chưa claimed vẫn có thể restore.

## R3 — Reference protection và purge saga

Per-material lease/fence/pins từ Add: pin registration và soft-delete/purge claim serialize.
New reference writer chỉ pin READY active, transaction pin+writer intent; nếu Mongo source
write khác bước, durable pin tạo trước, orphan pin giữ bảo thủ rồi reconciler xác minh.
Inventory Task input/attachments/editor versions, Post media/publish, watermark descendants,
AI/material refs, scheduled jobs; id nào lưu key thì map bằng provider+key đã inventory,
không unscoped string contains hoặc assumed materialId-only. Source references không xác minh
được phải block purge reason LEGACY_REFERENCE_UNVERIFIED, không interpret empty query là safe.

Scheduler bounded batch/keyset due candidates, claim atomic generation/lease + immutable
identity. Check pins và actual legacy refs, nếu còn reference bỏ claim về NONE, set
next_attempt/backoff và blocked_reason; giữ purge_after gốc. Descendant chưa purged cũng
pin parent; parent phải chờ child purge, tránh vòng lineage bằng validation Add.

Nếu không còn reference, commit claim dưới lease; mọi new pins thấy tombstone/claim bị chặn.
Release DB transactions trước provider I/O. Delete durable đúng provider/key và versions
theo configured retention; delete marker không đủ proof physical freed. Heartbeat lease
và fencing trước state/accounting writes. Worker stale lease không được release quota.
Nếu provider không có fenced-delete, canonical key immutable không tái sử dụng và restore
không được chạy khi claim; new worker chỉ cùng purge op, tránh delete object đã phục hồi.

States: CLAIMED→OBJECT_DELETED (persist proof provider/key/version/outcome)→PG PURGE_RELEASE
(idempotent used-=file_size, reserved không động)→Mongo DONE/quota_released_at/completed.
Crash sau delete trước checkpoint: retry cùng immutable key, verify provider missing và
journal identity; absence có thể complete only với purge claim hợp lệ/reference exclusion.
Object đã missing do external incident trước claim: reconciliation/manual verify, không
auto reduce quota vì một404 không đủ chứng minh deletion đúng material.

PG down giữ OBJECT_DELETED, retry ledger; ledger committed nhưng Mongo ack mất replay
đọc unique op để finish. Storage timeout giữ CLAIMED retry/backoff, không assume deleted.
Pool physical decrement chỉ sau actual delete/versions confirmation, không inferred từ
customer quota counter. Logical/pool release operation bền và idempotent riêng.

## R4 — Files, UI và errors

- Business MaterialController/Service/impl/scoped repository/DTO capabilities/shared lease,
  proposed MaterialRetentionCoordinator và scheduler extension; audit outbox/usage ledger Add.
- Reference writers: PostDraftFields/PostService/PostPublish, Task content/comment attachments,
  watermark/AI refs thực inventory; adapt contract before enabling irreversible purge.
- Infra incremental Mongo operational index/validator nếu thiếu, không duplicate PG ledger;
  runbook dry-run candidate report rồi canary purge enable flag defaultoff.
- Web Material service/types, MediaTab/MediaDetailPanel và Trash subview/hook trong Library;
  không xây Library thứ hai. Locales **vi/library.json + en/library.json**.

Error401/403/404 scoped;400 missing version;409 stale/profile/parent/missing/purge state;
503 provider. Không quota422 ở restore/delete. UI short delete confirmation, disabled/loading,
trash empty/error, purge date/referenced reason generic/restore conflict; soft delete không
hứa giải phóng dung lượng. Lưu action op token trong memory cho retry, no persisted URL.
Light/dark tokens, focus return/keyboard, responsive; i18n repository.delete*/trash*/restore*/
purgeDate/referenced/purgeInProgress/conflict. Subscription filter allow metadata/delete/restore.

## R5 — Safety gate, deployment và rollback

Before enable purge: inventory every reference writer + pins/backfill verified + read
consumer contract + nounknown references + durable deletion/usage replay tests pass.
Mặc định purge dry-run report IDs/counts không xóa; only disposable tests write trong
implementation development. Production APPLY/enable cần authorization riêng, không task doc.
Rollback disable scheduler claim, không clear active claims/object-deleted tombstones hoặc
resurrect missing binary. Reconcile finish accounting for already deleted before rollout
rollback. Metrics due/referenced/lease retries/delete errors/usage/pool variance. Không credit
release từ client local state; no automatic SQL counter rewrite từ uncertain Mongo totals.

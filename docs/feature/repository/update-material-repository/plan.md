# Update Material — Implementation Plan

**Input:** spec.md/ticket03. **Blocked by:** Add foundation + View detail/capability mapper.
Không schema/provider/usage duplicate. U1→U2→U3→U4→U5; APIs dùng shared ACL.

## U1 — Input semantics và naming

Reuse MaterialController/Service, mapper DTO, repository, parent access protocol Add.
New UpdateMaterialRequest record nếu chưa có; `expectedVersion: long≥0` required, sparse
name/type/purpose/visibility/clientProfileId. Phân biệt omitted vs explicit null bằng
DTO presence tracking/JsonNullable tương thích dependency hiện có hoặc custom deserializer
nhỏ, không model null như “giữ nguyên” cho mọi trường. Reject unknown sensitive fields
(key/provider/id/status/createdBy/lineage/taskId)400 trước side effect.

ExpectedVersion stale409 kể cả no-op. Payload không có field mutate400; value hợp lệ
nhưng giống hiện tại thì200 version giữ, audit có thể ghi no-op outcome không version increment.
Null name/type/purpose/visibility invalid; clear clientProfileId chỉ Manager INTERNAL.

Tên sanitize theo MaterialFilenamePolicy dùng chung với upload/download: Unicode NFC,
trim,1–255, reject/strip CRLF/control/slash/path traversal nhất quán, filename fallback
cho UI validation rõ. Canonical extension từ MIME verified, không đổi metadata MIME/bytes.
Không tạo cùng một cách sanitize khác cho HTTP attachment; download build header riêng.

## U2 — Authorization và atomic update

Path→PG active actor→scoped Mongo READY active/purge NONE→ownership guard. Manager all;
Creator/Client own-created trong quyền đọc; OWNER-only403. CLIENT profile active thuộc actor,
Manager audience target profile active workspace; không tin body workspace/profile ownership.
Only Manager thay audience sau tạo; type RAW↔RETOUCHED, no user WATERMARKED.
Purpose độc lập, không tự biến CLIENT reference thành INTERNAL. Creator B retouch A via Add.

Patch chỉ name/type/purpose: single-document compare-and-set gồm workspace/id/version/
deleted_at/purge_state, verify root revision cùng protocol lease Add trước commit. Set
updated_by/at/version+1, không key/provider/checksum/original_name/creator/task changes.
Root reference/purge writers share lease kể cả khi FR03/04 merge khác thứ tự. Không giữ
PG transaction trong Mongo call. Quota không được gọi reserve cho metadata.

## U3 — Audience lineage protocol và audit

Audience thay đổi phải lấy root-lineage lease/fence của Add, verify expectedVersion và
snapshot revision, mark access_state UPDATING theo Mongo transaction. Descendants/new refs/
derived uploads không được publish/cấp URL khi transition đang mở. Persist mutation operation
với idempotent operationId/rootId/before/desired/current stage và audit event, không link secret.

Restriction: update target audience, thu hẹp descendants đang rộng hơn; không tự mở lại
descendant private. Expansion target phải vẫn hợp ancestor, không auto expand descendants.
Không retarget parent từ ClientX sang ClientY mà để childX leak: enforce effective ancestor
intersection bằng read policy, child chưa resolve thành permission hợp lệ fail closed;
Manager cần explicit scope update hoặc giữ descendant restricted, không “guess owner”.
After bounded batches, verify descendants/new pins root revision; commit root revision+
access_state STABLE. Nếu crash giữ fail-closed, recovery resume cùng operation/fence;
không clear UPDATING bằng timeout rồi mở ACL chưa xong. Long transition có metrics/ops alert.

Material mutation và audit-intent cùng Mongo transaction khi mutation metadata committed;
PG AuditLog qua outbox consumer idempotent operationId, giữ full actor/workspace/before/after
field list phù hợp PII policy. Audit PG down không mất intent hoặc trả success rồi mất event.
DTO chỉ return sau commit; Mongo unknown commit retry read operation để phân biệt result,
không chạy patch hai lần. Giao dịch Mongo yêu cầu replica set đã là gate Add.

## U4 — Files và UI

- Business `controller/MaterialController.java`, `service/MaterialService.java`, impl,
  Material DTO request/response, scoped repository, proposed MaterialFilenamePolicy,
  MaterialAccessPolicy/lease/audit outbox của Add; ErrorCode reused.
- Mongo update operations/outbox/index operationKey nếu Add chưa có; migration metadata
  only, không backfill audience tự mở rộng, không PG usage change.
- Web `src/services/materialService.ts`, `src/types/material.ts`, MediaDetailPanel/
  feature metadata editor hook; reuse shared Inputs/Button/Select và returned capabilities.
- Locales **`src/i18n/locales/vi/library.json` + `en/library.json`**, keys repository.rename/
  nameLabel/save/cancel/typeLabel/purpose*/audience*/clientRequired/invalidName/conflict/
  reloadLatest/updateSuccess/updateFailed. Không hardcoded raw server English.

Inline/full-width edit, no long modal; user inputs giữ khi409, cho reload latest, không
auto-force-save. Pending disable duplicate submit, canChangeAudience chỉ Manager. Parent
metadata read-only, retouch action dùng Add flow. Save success update detail+invalidate list
filter scope; record rời filter sau type/purpose change là bình thường. Abort/context guard
không render response workspace cũ. Read revoked no info; vi/en, dark/light, keyboard,
Enter save/Escape cancel, focus management375/768/1440. Không đụng Billing quota UI.

## U5 — Integration và errors

PATCH base/{id}:200 ApiResponse metadata;400 invalid/empty/null;401 auth;403 actor có read
nhưng thiếu mutate/field quyền;404 unreadable/wrong scope;409 expectedVersion/state/
lineage transition;503 dependency. Không dùng code số mới trùng ErrorCode hiện có.
SubscriptionRequestFilter exempt metadata route đúng BR20–21, không bypass toàn `/materials/**`.
Tests gồm same-version conflict, parent revocation vs child upload/reference race, crash
audience cascade+audit consumer, byte/provider unchanged và expired plan success.
Rollback disable patch writer, resume/complete pending operations trước rollback reader;
không rollback bằng public URL hoặc clear transition fence khi chưa đối soát.

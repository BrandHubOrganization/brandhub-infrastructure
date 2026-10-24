# FR 3.6.14 — Remove Material Repository Specification

Trạng thái: nghiệp vụ BR01–BR25 đã chốt; tài liệu triển khai, chưa code/chưa test.
Nguồn chuẩn: [Repository BR](../../../../../tuan-research/REPOSITORY_SPEC.md).
Bản này đồng bộ lại spec cũ, giữ tombstone tách khỏi upload lifecycle và DELETE204.
Bản trước planning được giữ tại .scratch/repository/spec-before-planning để đối chiếu,
không là nguồn active. Các symbol mới bên dưới là đề xuất triển khai.

## Lifecycle và contract chuẩn

- Material.status chỉ UPLOADING/VALIDATING/READY/REJECTED/FAILED; soft-delete chỉ áp READY.
- deleted_at/deleted_by/purge_after là tombstone; purge_state NONE/CLAIMED/OBJECT_DELETED/DONE
  là trạng thái vận hành riêng. Không dùng DELETED/PURGED như upload status.
- purge_after = deleted_at +30 ngày giữ nguyên, next_purge_attempt_at ghi lịch retry;
  không dời retention gốc sau mỗi lần còn reference hoặc provider lỗi.
- expectedVersion bắt buộc cho DELETE qua query và restore qua body. Retry DELETE hợp lệ
  cùng tombstone trả204 trước xét stale version, không reset retention; mutation khác409.
- Restore lúc đã CLAIMED trả409; quá30 ngày nhưng chưa bị claim/purge vẫn có thể restore.
- Khi DONE giữ tombstone tối thiểu để idempotency/audit; không trả item purged trong trash.
- Reuse accounting ledger Add cho PURGE_RELEASE unique(materialId), không bảng release trùng.
- Không denormalize agency_id vào materials; resolve workspace→Agency từ PostgreSQL.
- Active reference writer phải lấy cùng per-material lease/fence với purge và thêm durable
  reference pin trước khi publish reference. Legacy không xác minh được reference phải
  chặn purge, không coi không tìm thấy ID trong URL là hết reference.

## UI/i18n

Reuse Library và common primitives; keys repository.trash/title/empty/delete/deleteConfirm/
restore/restoring/restoreFailed/purgeDate/referenced/purgeInProgress/versionConflict.
Thêm song song vi/library.json và en/library.json, register namespace hiện có; dùng semantic
light/dark tokens, keyboard/focus, 375/768/1440px. Không màu/font/palette mới.
States loading/empty/error/delete-confirm/deleting/trash/restoring/conflict/missing-object/
reference-blocked. Restore vượt quota không hiện upgrade gate.

## Chi tiết nghiệp vụ, flow và nghiệm thu

## Hiện trạng và scope

Library delete từng dùng mock; storage delete theo URL bất đồng bộ không chứng minh purge
thành công. Reuse Material service và job/accounting 01; không tạo cleanup microservice/Redis queue.
Scope soft delete/trash/restore/retention purge và retry; không làm Folder recursive delete,
bulk delete, overwrite versions, subscription downgrade UI hay tính lại quyền gói.

## Quyền và state

MANAGER xóa/restore mọi file workspace; CREATOR/CLIENT chỉ file mình tạo trong scope đọc.
OWNER không có membership vận hành không quản lý nội dung. Trash list không trở thành cách
CLIENT dò file khác profile; áp predicate trước count/page, không chỉ ẩn button.
deleted_at/deleted_by/purge_after=deletedAt+30 ngày, version tăng bằng atomic CAS.
Không dùng enum DELETED để thay lifecycle status đang có: tombstone tách khỏi READY state.
Deleted ngừng cấp preview/download URL mới; link đã phát có thể sống hết TTL BR14.

## API contract

Base `/api/v1/workspaces/{workspaceId}/materials`.

| Endpoint | Contract |
|---|---|
| DELETE /{id} | expectedVersion qua query validated; 204. Retry hợp lệ của cùng delete đã hoàn tất idempotent, không làm đổi deletedAt/purgeAfter |
| GET /?deleted=true | Reuse list/page/size/meta từ02 nhưng trả trash actor có quyền quản lý; không cấp preview/download cho deleted material |
| POST /{id}/restore | expectedVersion; 200 metadata/version mới, chỉ khi object còn và chưa purge, audience/profile/workspace còn hợp lệ |

Không tạo public hard-delete endpoint. 401 auth,403 quyền,404 sai scope/không nhìn được,
409 version/state/object missing/purge claimed;503 dependency. Hết quota hoặc paid expiry
không phải lỗi restore. Không tự đổi CLIENT thành INTERNAL để restore được.

## Flow và accounting

Soft delete: reauthorize→scoped record→CAS version/state→tombstone→audit→invalidate active/trash.
Không xóa S3, không giảm usedBytes, không release usage đang tính cho trash.
Restore: reauthorize→claim/CAS chống purge→verify provider/key/object và audience còn hợp lệ
→clear tombstone/version tăng→audit. Không reserve quota lần hai; không đổi provider hoặc
usage. Đã purge/đang purge thì409; DB/provider lỗi không báo restore thành công.

Purge scheduler: atomic claim có lease/retry nhiều instance; đến hạn mới xét. Kiểm references
Post/Task/Derivative bằng canonical Material ID; các consumer phải có contract xác minh
references, không dựa vào tìm chuỗi URL. Còn reference thì giữ record/object, báo lý do,
không giảm usage. Ngăn writer gắn reference mới vào file đã purge-claim/deleted bằng cùng
guard/state contract; recheck trước irreversible delete, không dùng check-then-delete racy.

Xóa binary theo provider/key đã lưu, kiểm kết quả; release usage exactly-once qua ledger
idempotency material/purge operation. Crash sau delete trước update ledger phải retry được:
object already missing chỉ hoàn tất release nếu đã xác minh operation/object identity.
Lỗi delete giữ retryable state; không Mongo TTL xóa record trước. Nếu provider versioned,
delete marker không đồng nghĩa physical bytes đã được giải phóng; phải đối soát policy
versions/retention trước giảm capacity physical và tuyên bố purge hoàn tất.
Không 2-phase transaction PG/Mongo/storage; state/reconciliation phải mô tả các crash points.

## UI và acceptance criteria

Confirmation ngắn tên file, không hứa giảm quota khi soft delete. Trash có thời gian xóa/
đến hạn, restore loading/error, thiếu object hoặc còn reference có giải thích không lộ dữ liệu.
Reuse query/cache/primitives; vi/en, dark/light, focus về action hợp lệ, keyboard/responsive.

- [ ] Soft delete idempotent, biến mất khỏi active và ngừng cấp URL mới, usedBytes giữ nguyên.
- [ ] Trash không leak tên/count giữa Client/workspace; mutate theo created_by/Manager đúng.
- [ ] Restore khi vượt quota hoặc gói hết hạn thành công nếu object/state/ACL hợp lệ; usage không tăng.
- [ ] Restore/delete/purge concurrent không làm sống record thiếu object hoặc release usage hai lần.
- [ ] File còn Post/Task/Derivative tham chiếu không purge; reference writer không race với purge.
- [ ] Đủ30 ngày mới eligible; provider failure/restart có retry; delete confirmed mới release accounting.
- [ ] File SYSTEM_S3 cũ không bị migrate/xóa chỉ vì downgrade; không làm hỏng nội dung đã sử dụng.
- [ ] UI confirm/trash/restore, i18n/theme/a11y và quota messaging đúng.

Tests: clock-controlled retention; two-worker claim; PG ledger/Mongo CAS; fault injection
delete success then process crash; provider timeout/missing; reference concurrency và
versioned deletion; API isolation/expiry; UI restore vượt quota. Done khi các invariant
data/accounting được chứng minh, cleanup báo cáo được; spec→plan→task→test trước code.

# Repository — Implementation document set

**Trạng thái:** chuẩn bị tài liệu hoàn tất; chưa implement/chưa chạy tests/migrations/provider probes.
Business authority: BR01–BR25 (`tuan-research/REPOSITORY_SPEC.md`).
Mỗi FR có đúng4file spec→plan→task→test, phải đọc đủ trước code. Ticket local map bên dưới;
không Jira issue nào được tạo. Spec per-FR đã đồng bộ planning contract, không coi ví dụ
numeric ErrorCode hoặc class mới trong source spec là code đã có.

| Order | FR | Spec | Plan | Task | Test | Implementation blocker |
|---|---|---|---|---|---|---|
|01|3.6.12 Add|[spec](../../../feature/srs/05-content-task-workflow/3-6-12-add-material-repository/spec.md)|[plan](../../../feature/srs/05-content-task-workflow/3-6-12-add-material-repository/plan.md)|[task](../../../feature/srs/05-content-task-workflow/3-6-12-add-material-repository/task.md)|[test](../../../feature/srs/05-content-task-workflow/3-6-12-add-material-repository/test.md)|G0 storage + G1 ledger trước enable writes |
|02|3.6.11 View|[spec](../../../feature/srs/05-content-task-workflow/3-6-11-view-material-repository/spec.md)|[plan](../../../feature/srs/05-content-task-workflow/3-6-11-view-material-repository/plan.md)|[task](../../../feature/srs/05-content-task-workflow/3-6-11-view-material-repository/task.md)|[test](../../../feature/srs/05-content-task-workflow/3-6-11-view-material-repository/test.md)|Add foundation ready |
|03|3.6.13 Update|[spec](../../../feature/srs/05-content-task-workflow/3-6-13-update-material-repository/spec.md)|[plan](../../../feature/srs/05-content-task-workflow/3-6-13-update-material-repository/plan.md)|[task](../../../feature/srs/05-content-task-workflow/3-6-13-update-material-repository/task.md)|[test](../../../feature/srs/05-content-task-workflow/3-6-13-update-material-repository/test.md)|Add+View; shared lineage lease/revision |
|04|3.6.14 Remove|[spec](../../../feature/srs/05-content-task-workflow/3-6-14-remove-material-repository/spec.md)|[plan](../../../feature/srs/05-content-task-workflow/3-6-14-remove-material-repository/plan.md)|[task](../../../feature/srs/05-content-task-workflow/3-6-14-remove-material-repository/task.md)|[test](../../../feature/srs/05-content-task-workflow/3-6-14-remove-material-repository/test.md)|Add+View; reference inventory trước purge |
|05|3.6.16 Download|[spec](../../../feature/srs/05-content-task-workflow/3-6-19-download-material/spec.md)|[plan](../../../feature/srs/05-content-task-workflow/3-6-19-download-material/plan.md)|[task](../../../feature/srs/05-content-task-workflow/3-6-19-download-material/task.md)|[test](../../../feature/srs/05-content-task-workflow/3-6-19-download-material/test.md)|Add+View; actual private provider + durable audit |

## Shared ownership và contract

Add owns storage router/options/validator, scoped actor policy, mutation lease/fence/root
revision/reference pins, upload saga, PG quota ledger/reservations/physical pool accounting,
session/Material migration, trusted private reader/watermark compatibility. Các FR khác chỉ
extend/call shared helpers. Không thêm Repository microservice, Mongo metadata mirror,
Redis ACL/list/URL cache hoặc USER_GDRIVE connector trong MVP.

Canonical providers SYSTEM_GDRIVE/SYSTEM_S3/USER_GDRIVE (last disabled); Material upload
status UPLOADING/VALIDATING/READY/REJECTED/FAILED. Soft deletion uses deleted_at, purge_state
separate. page/size+array data/meta; no preview public fallback; no claim S3-compatible100%.
Quota total catalog, BASIC20GiB, expired read/update/delete/restore/download allowed;
trash charged, release only confirmed purge, no double count staging+canonical logical usage.

## Gates chưa thực hiện

- G0: pinned rclone/private AWS test endpoints, presign/HEAD/Range/conditional copy,
  metadata/attachment/durable cache restart, throttling and capacity proof.
- G1: PG ledger/reservation+Mongo saga fault injection, lock order, retry/idempotency,
  session expiry vs VALIDATING claim, pool overhead after PUT expiry.
- Purge gate: complete reference-writer inventory/backfill, durable pin+claim serialization,
  crash replay storage delete→PG release→Mongo complete, versioned object retention proof.
- UI/integration: gateway subscription filter, Mobile legacy sessions/DTO paths, vi/en,
  dark/light/keyboard/responsive và all stale workspace response guards.

Gates là checklist thực thi, không lý do dừng chuẩn bị tài liệu. Không có credentials/
endpoint test thì ghi NOT RUN, không dùng mock thay external proof hoặc enable production.
Rollback disable new writer/purge flags, reconcile pending operations, giữ ledger/metadata,
không tự xóa DB, quay public ACL hay đổi quyết định BASIC overflow.

Specs trước normalization được giữ ở `.scratch/repository/spec-before-planning/` ngoài
repo infrastructure để đối chiếu, không là tài liệu active hoặc một bản spec cạnh tranh.

## Customer-owned Drive storage
The customer-drive-overflow feature adds Owner/Manager OAuth connection, private brandhub-[agency]/workspace_N folders, Drive-first material writes and active-paid-plan S3 overflow. USER_GDRIVE is enabled only by the explicit customer-drive feature gate; SYSTEM_GDRIVE remains a historical system-provider route. See [customer-drive-overflow/plan.md](../../../feature/modules/04-task-chat-vault/s3-folder-vault-security/plan.md) for staged schema, account-wide capacity reservations, private gateway streaming and rollout prerequisites.


## S3 5GB Free Default, Nested Folders, Drive Folder Import, Duplicate/File Version, Client Vault & Security Overhaul (2026-11-04)
- **Spec:** [s3-folder-vault-security/spec.md](../../../feature/modules/04-task-chat-vault/s3-folder-vault-security/spec.md)
- **Plan:** [s3-folder-vault-security/plan.md](../../../feature/modules/04-task-chat-vault/s3-folder-vault-security/plan.md)


---

## Archived Prototype Note — Agency Storage Onboarding (`?storagePreview=1`)

> Folded from `agency-storage-onboarding-prototype/` (`spec.md`, `plan.md`, `task.md`, `test.md`). Superseded in production by [`s3-folder-vault-security`](../../../feature/modules/04-task-chat-vault/s3-folder-vault-security/spec.md).

- **Design Question:** Evaluated whether a non-technical `Owner` or `Manager` could discover and complete storage onboarding directly from the Workspace Dashboard using three in-memory variants (`variant=A` prominent onboarding card, `variant=B` inline notice, `variant=C` setup checklist).
- **Outcome:** Variant A (guided dashboard card) was selected for real implementation (`agency_storage_usage` + `StorageAddonController` + `CustomerDriveController`), and the temporary `?storagePreview=1` simulation hooks were retired without committing throwaway UI controls.

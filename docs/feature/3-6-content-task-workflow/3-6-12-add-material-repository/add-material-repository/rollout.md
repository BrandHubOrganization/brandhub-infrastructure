# Add Material — activation and recovery

Status: **NO-GO for shared/production writes** until G0 provider evidence and legacy inventory are approved.
The application defaults `repository.storage.writes-enabled=false`; both provider `verified` flags default false.
Do not enable a provider just because its S3-compatible endpoint responds.

## Configuration

Bind these Spring properties through the deployment secret/config mechanism. Do not commit credentials:

```yaml
repository:
  storage:
    writes-enabled: false
    recovery-delay-ms: 60000
    system-gdrive:
      verified: false
      endpoint: https://<private-s3-gateway>
      region: ap-southeast-1
      bucket: <private-test-bucket>
      path-style: true
    system-s3:
      verified: false
      region: ap-southeast-1
      bucket: <private-test-bucket>
      path-style: false
```

Credentials use the SDK provider chain, or separate access-key/secret-key properties from secrets.
Avatar/logo/public publishing storage configuration is separate and unchanged.
Use HTTPS, private buckets, exact web-origin CORS PUT/GET/HEAD, Content-Type headers and exposed ETag.
Allow methods and range/copy only for application credentials; users receive signed staging PUT and inline GET.

## Gates before activation

1. Snapshot PG/Mongo, pause all legacy writers, run migration wrapper without `-Apply`, inspect SQL/JS.
   On disposable copies, exercise apply twice, conflicting indexes, legacy rows, rollback and writer compatibility.
   Mongo requires a replica set/sharded transaction-capable cluster. Run neither fresh init nor collection drops on live data.
2. Inventory existing objects, including derivatives and trash. Assign provider, actual size/MIME,
   INTERNAL audience when unknown, canonical identity and verified status; preserve IDs/task/lineage.
   Unknown/missing/private-inaccessible objects stay non-READY. Old WebP conversion cannot restore lost originals.
   Reconcile per-Agency usage before setting `agency_storage_usage.inventory_verified_at`.
   The expansion migration deliberately leaves existing agencies unverified; it is **not a legacy backfill**.
3. Run TC-A01–03 against **each real test provider**, preserving exact gateway/rclone/version/config evidence.
   Verify unsigned denial; signed PUT/GET expiry; original bytes; HEAD/range/ETag; failed conditional copy after source mutation;
   canonical durability after ack/restart; SSD-full, Drive 403/429, gateway timeout and restart recovery.
   A VFS write-back-cache acknowledgment is insufficient proof of a durable canonical object.
4. Verify gateway operation lifetimes are strictly bounded below 24 hours, including uploads admitted before URL expiry,
   delayed copies and rclone write-back flushes. Cleanup assumes that bound; a provider that cannot enforce it stays disabled.
   Enforce declared/max upload size at the gateway/signature policy; reject incorrect Content-Length and oversized PUTs.
   Application HEAD checks alone do not protect the physical pool from oversized unconfirmed uploads.
5. Publish an authoritative **durable physical Drive** inventory at least every 5 minutes to
   `system_storage_pools.physical_used_bytes/observed_at`; SSD-cache size is not physical Drive usage.
   No inventory updater is deployed by this ticket. Stale observation causes new Drive writes/Agency entitlement to fail closed.
6. Run full G1 crash/concurrency/ACL and UI tests, approve evidence, then canary with both schema and provider gates.
   Paid S3 must pass independently; BASIC never overflows to S3 during outage/capacity pressure.

## Reconciliation contract

PG serializes pool→Agency→reservation locks. Customer usage and physical holds are different counters.
Commit moves reserved to used once; release only cancels uncommitted usage. Trash remains charged.
Every promotion uses a unique token in its canonical key, preventing a late worker from overwriting another attempt.
READY replay returns persisted metadata and never resets a rename.

Recovery runs every 60 seconds when writes are enabled. It retries durable COPIED/COMMITTED checkpoints.
COPYING plus confirmed canonical object can proceed; timeout/5xx holds quota. Confirmed missing canonical after the
24-hour maximum-operation bound is deleted/HEAD-verified missing, then cancelled and released exactly once.
Unpublished invalid/mismatched canonical objects retain holds for operator investigation; never silently free their bytes.

Staging cleanup only starts 24 hours after PUT/session expiry for released or published operations.
Delete and HEAD-404 prove absence. Pool holds remain until a **newer authoritative inventory** than that cleanup proof;
then the hold is cleared once without subtracting canonical bytes from physical usage. Recovery must remain enabled
while in-flight operations drain; disabling writes also pauses the scheduled recovery worker.

Safe log dimensions are operationId/error code/exception class, never SDK messages, signed URLs or publish payloads.
Investigate repeated pending operations and long-lived holds by ID; do not manually zero the pool/Agency counters.

Post/Task media store stable `material_id`, not preview URLs. Reference pins and content save share a Mongo transaction.
Renderer/publisher resolves a fresh private URL after rechecking membership/lineage; revoked authors block scheduled use.
Future Update/Remove tickets must preserve the same `access_revision`/`access_state` mutation fence and reference protocol.

## Rollback

Stop new writes, drain or explicitly monitor pending sagas, keep schema/data and private binaries.
Do not return to a writer that trusts arbitrary keys or public URLs. Do not drop ledgers or delete canonical objects.
Readers require a separately reviewed legacy inventory/cutover; missing verification remains fail closed.

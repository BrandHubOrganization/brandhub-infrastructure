> **Navigation:** [← Category Index](../README.md) · [← Modules Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Kế hoạch kỹ thuật System Health MongoDB

Tham chiếu gốc: `tuan-research/system-health-mongodb-refactor/plan.md`.

## 1. Căn cứ code và điểm dễ bỏ sót

| Nguồn | Quan sát và hệ quả |
|---|---|
| brandhub-infrastructure/database/init/init-postgres-v2.sql:1112–1230 | 5 bảng, CHECK/FK, latest-only; chuyển Mongo phải thay bảo đảm đang do SQL thực hiện |
| brandhub-business-service/.../service/monitoring/HealthIngestionService.java | JPA lock target, kiểm tra collector, duplicate, ordering; không chỉ đổi annotation |
| brandhub-business-service/.../service/monitoring/ServerMonitoringService.java | Heartbeat dirty-check qua JPA; Mongo cần update tường minh, không replace document |
| brandhub-business-service/.../service/monitoring/MonitoringEnrollmentService.java | JdbcTemplate DELETE RETURNING + INSERT host cùng transaction |
| brandhub-business-service/.../service/monitoring/HealthQueryService.java | Page catalog trước, batch samples/collectors, status filter sau pagination |
| brandhub-business-service/.../service/monitoring/MonitoringHealthView.java | Tính freshness tại thời điểm đọc, không lưu status |
| brandhub-business-service/.../service/monitoring/MonitoringAccess.java | Current ADMIN đọc PostgreSQL; token hash so sánh constant-time |
| brandhub-monitoring/src/provision.mjs | Ghi SQL trực tiếp cả catalog trong một transaction; phải đổi cùng backend |
| brandhub-monitoring/src/main.mjs | Worker runtime gửi HTTP; không cần quyền ghi database catalog |
| brandhub-business-service/pom.xml, src/main/resources/application.yml | Đã có Spring Data MongoDB; cấu hình Mongo hiện hữu |

## 2. Model và Collections MongoDB

Dùng 4 collection thông thường trong database Mongo Business:

1. `monitoring_servers`:
   - `_id`: String (canonical UUID lowercase)
   - `name`: String
   - `ipAddress`: String (chuẩn hóa IPv4/IPv6)
   - `environment`: String
   - `deployedServices`: Array<String>
   - `agentTokenHash`: String
   - `cpuPercent`: Decimal128 / Double
   - `ramPercent`: Decimal128 / Double
   - `diskPercent`: Decimal128 / Double
   - `uptimeSeconds`: Long (Int64)
   - `lastSeenAt`: Date
   - `createdAt`: Date
   - `updatedAt`: Date

2. `monitoring_collectors`:
   - `_id`: String (UUID)
   - `name`: String
   - `serverId`: String (UUID)
   - `tokenHash`: String
   - `lastSeenAt`: Date
   - `createdAt`: Date
   - `updatedAt`: Date

3. `monitoring_health_targets`:
   - `_id`: String (UUID)
   - `name`: String
   - `kind`: String (SERVICE, CONTAINER, DATABASE, ENDPOINT)
   - `environment`: String
   - `serverId`: String (UUID)
   - `serviceName`: String
   - `instanceId`: String
   - `collectorId`: String (UUID)
   - `checkScope`: String
   - `probeType`: String (HTTP, DOCKER, POSTGRESQL, REDIS, MONGODB, NEO4J)
   - `probeConfig`: Object
   - `assertion`: Object
   - `credentialRef`: String
   - `intervalSeconds`: Integer
   - `timeoutSeconds`: Integer
   - `staleAfterSeconds`: Integer
   - `catalogVersion`: Long
   - `createdAt`: Date
   - `updatedAt`: Date
   - `latestResult`: Object null hoặc chứa mẫu mới nhất:
     - `checkId`: String (UUID)
     - `collectorId`: String (UUID)
     - `outcome`: String (PASS, FAIL, ERROR)
     - `checkedAt`: Date
     - `checkedAtMicros`: Long
     - `receivedAt`: Date
     - `latencyMs`: Decimal128
     - `reasonCode`: String
     - `httpStatus`: Integer
     - `runtimeState`: String
     - `runtimeHealth`: String

4. `monitoring_enrollments`:
   - `_id`: String (tokenHash hex 64)
   - `name`: String
   - `environment`: String
   - `expiresAt`: Date (TTL index: `expireAfterSeconds: 0`)

## 3. Persistence Seam & Storage Mode

- Thiết kế persistence seam qua interface `MonitoringStore` (hoặc các interfaces chuyên trách: `ServerMonitoringStore`, `HealthMonitoringStore`, `EnrollmentMonitoringStore`).
- Implement hai adapter:
  1. `PostgreSqlMonitoringStore`: giữ nguyên hành vi JDBC/JPA hiện tại cho fallback/rollback window.
  2. `MongoMonitoringStore`: sử dụng `MongoTemplate` cho conditional atomic updates (`$set`, `$unset`), transaction cho register, TTL và query projection.
- Cấu hình qua thuộc tính `monitoring.storage`: `postgres` (mặc định) hoặc `mongo`.
- Services (`ServerMonitoringService`, `HealthIngestionService`, `HealthQueryService`, `MonitoringEnrollmentService`) phụ thuộc vào Seam, không trực tiếp thao tác JPA/Jdbc/Mongo.

## 4. Concurrency và Transaction Rules

- **Heartbeat host/collector**: Conditional `$set` với `_id` và `tokenHash` trong query selector; không dùng upsert, không dùng read-then-save để tránh overwrite metadata/credentials.
- **Probe Result Ingestion**:
  - CAS update trên target: match `_id`, `collectorId`, `catalogVersion`, và điều kiện `latestResult` null HOẶC `latestResult.checkedAt` < request.checkedAt.
  - Phân loại lỗi chính xác: duplicate checkId -> return { duplicate: true }; older timestamp -> 409 CONFLICT; collector mismatch -> 403 FORBIDDEN; not found -> 404 NOT_FOUND.
- **Enrollment**:
  - `invite`: insert enrollment document với `_id=tokenHash`, TTL index trên `expiresAt`.
  - `register`: Mongo session transaction: `findOneAndDelete` enrollment còn hạn (`expiresAt > now`), `insert` server host. Nếu insert server lỗi, transaction tự rollback cả hai.

---

## Appendix: Cutover Runbook

### T9 — Cutover System Health sang MongoDB

Trạng thái: chuẩn bị, **chưa thực hiện cutover**. Database production vẫn phải giữ 5 bảng SQL trong rollback window.

## Bằng chứng trước cutover

- Atlas thật, database riêng `brandhub_monitoring_acceptance`: 5/5 integration test pass, 0 skipped.
- Rehearsal trên PostgreSQL database riêng cùng tên và Atlas acceptance: backfill/verify pass; thêm 2 hosts, thêm collector, consume enrollment, reassign target và ghi sample microsecond; reverse-sync và verify pass, 0 discrepancies.
- Manifest local: `tuan-research/system-health-mongodb-refactor/rehearsal-result.json`. PostgreSQL test và Atlas test giữ fixture sau rehearsal để kiểm tra, không reset tự động.
- Các revision HEAD hiện tại chưa chứa phần refactor chưa commit: Business `0fa2ba2`, infrastructure `b5f99dd`, worker `a8f145d`. Phải build/deploy đúng working changes đã nghiệm thu, không chỉ redeploy image cũ.

## Cấu hình release

Compose Business đã có `MONITORING_STORAGE: ${MONITORING_STORAGE:-postgres}`. Thêm biến vào file .env không tự đổi container đang chạy; cần recreate/deploy cả fleet từ image refactor. Default vẫn postgres để không chuyển traffic trước backfill.

Database Mongo production lấy từ cấu hình Business `MONGODB_DATABASE`. Không dùng database acceptance cho cutover. Provision worker dùng cùng database production và Mongo catalog mode. Không cấp quyền catalog-write cho runtime HTTP collector.

## Trình tự thực hiện trong cửa sổ bảo trì

1. Khóa release image/commit refactor cho tất cả Business replica và provisioning tool. Xác nhận backup PostgreSQL và Atlas phục hồi được; ghi danh sách replica/writers.
2. Freeze tất cả monitoring writers: host heartbeat, collector heartbeat, health-results, invite/register và operator provisioning. Drain requests. API write bị gate phải trả lỗi bảo trì, không nhận rồi bỏ dữ liệu.
3. Chạy schema APPLY vào database Mongo production xác nhận rõ tên. Không chạy suite Atlas vì suite xóa dữ liệu test. Nếu collection production đã có dữ liệu khác, dừng và đối chiếu nguồn, không blind overwrite.
4. Chạy backfill với PostgreSQL production chỉ đọc và Mongo production ghi, sau đó verify 0 discrepancies. Ghi manifest/count/thời gian. Chỉ thao tác khi writers đã freeze.
5. Deploy toàn bộ Business refactor với `MONITORING_STORAGE=mongo`, giữ các cấu hình PostgreSQL để auth ADMIN vẫn hoạt động. Chuyển operator provisioning cùng đợt. Xác nhận không replica SQL-mode còn nhận request.
6. Smoke ADMIN list, host/collector heartbeat, result duplicate/order và enrollment trên đối tượng smoke có danh tính riêng. Mở writers, quan sát ít nhất một chu kỳ host/collector/probe; kiểm UI dữ liệu mới không chỉ snapshot cũ.
7. Ghi cutover time, replica/image/config, verify và smoke result. T9 chỉ tick khi có bằng chứng thực thi đủ các bước trên.

## Rollback

Trước khi Mongo có write mới: chuyển toàn fleet về postgres theo gate.

Sau khi Mongo có write mới: freeze/drain, reverse-export Mongo production sang PostgreSQL trong transaction, verify 0 discrepancies, kiểm host mới/enrollment consumed/owner/result timestamp, rồi chuyển fleet và provisioning về postgres. Không chỉ flip flag vì SQL snapshot đã cũ. Không reverse-sync từ acceptance vào production.

## Sau cutover

Theo dõi ít nhất 24 giờ và giữ rollback window đề xuất 7 ngày. Ghi lỗi/p95/throughput và SQL monitoring writes so baseline; không suy giảm tải từ số bảng.

T11 chỉ thực hiện khi có T9/T10 và hết rollback window: backup cuối, xác nhận không consumer SQL/JPA recreate, gỡ adapter rồi retirement migration có guard, không CASCADE. **Không có lệnh DROP production trong phiên rehearsal này.**

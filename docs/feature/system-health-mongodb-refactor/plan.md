# Kế hoạch kỹ thuật System Health MongoDB

Tham chiếu gốc: [tuan-research/system-health-mongodb-refactor/plan.md](../../../../tuan-research/system-health-mongodb-refactor/plan.md).

## 1. Căn cứ code và điểm dễ bỏ sót

| Nguồn | Quan sát và hệ quả |
|---|---|
| brandhub-infrastructure/docs/database/init-postgres-v2.sql:1112–1230 | 5 bảng, CHECK/FK, latest-only; chuyển Mongo phải thay bảo đảm đang do SQL thực hiện |
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

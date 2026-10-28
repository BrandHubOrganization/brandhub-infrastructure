# Kế hoạch kiểm chứng và Diễn tập Acceptance

## Kết quả thực chạy Atlas — 2026-10-22 23:53 (Asia/Saigon)

- Cluster Atlas đang dùng cho production; **database thực thi riêng: `brandhub_monitoring_acceptance`**. Không chạy test vào database `brandhub`.
- Trước chạy, database acceptance chưa có collection monitoring. Đã chạy `apply-monitoring-collections.mjs` ở chế độ APPLY, tạo đủ 4 collection cùng validator/index.
- Chạy `mvn -o -Dtest=MongoMonitoringStoreAtlasIntegrationTest test -q`, thêm Byte Buddy javaagent tại máy để tránh lỗi attach JVM Windows.
- Surefire: **Tests run: 5, Failures: 0, Errors: 0, Skipped: 0; elapsed 14.15s**.
- Cả 5 ca đạt: Decimal128/uptime; rollback enrollment khi duplicate key; CAS microsecond/duplicate; strict validator; concurrent CAS writes.
- Báo cáo local: `brandhub-business-service/target/surefire-reports/com.brandhub.business.service.monitoring.MongoMonitoringStoreAtlasIntegrationTest.txt` và XML tương ứng.
- Dùng credential có sẵn trên máy, không lưu URI/password trong tài liệu. Chưa chứng minh quyền readWrite tối thiểu bằng user test riêng.
- **Rehearsal đã PASS ngày 2026-10-22 23:58 Asia/Saigon**, xem kết quả dưới đây. Các dòng “Chờ Atlas/Chờ Rehearsal” lịch sử phía dưới được thay thế bởi bằng chứng thực chạy này.

## Kết quả rehearsal thực chạy — 2026-10-22 23:58 (Asia/Saigon)

- PostgreSQL: tạo database riêng `brandhub_monitoring_acceptance` trên server cấu hình hiện có; chỉ tạo 5 bảng monitoring tại database test. Atlas: database riêng cùng tên trên cluster production. Không ghi/xóa bảng PostgreSQL `brandhub` hay Mongo database `brandhub`.
- Runner local: `brandhub-monitoring/scripts/ops/run-acceptance-rehearsal.mjs`; manifest mới: `brandhub-monitoring/.runtime/rehearsal-result.json`; bằng chứng lịch sử vẫn ở `tuan-research/system-health-mongodb-refactor/rehearsal-result.json`. Runner từ chối reset PostgreSQL có bảng hoặc Mongo acceptance có dữ liệu.
- Seed: 1 server, 1 collector, 1 target, 1 result, 1 enrollment còn hạn.
- Backfill PASS; verify ban đầu **0 discrepancies**.
- Mutation trong Mongo transaction: thêm host mới, collector mới; consume enrollment và tạo host tương ứng; đổi owner target và ghi mẫu mới `checkedAtMicros=1792688331654321`.
- Reverse-export PASS trong SQL transaction; verify sau rollback **0 discrepancies**.
- Assertions bổ sung PASS: SQL có đủ 2 hosts mới, enrollment consumed không hồi sinh, result thuộc collector mới và timestamp micros khớp chính xác.
- Final counts: **3 servers, 2 collectors, 1 target, 1 result, 0 enrollments** ở cả hai database test. Giữ fixture để kiểm tra, chưa xóa database test.
- T8 acceptance đã hoàn thành. T9 chưa thực thi; runbook tại [cutover-runbook.md](cutover-runbook.md). Chưa đo giảm tải production, chưa kết thúc rollback window, chưa xóa 5 bảng production.

Tham chiếu gốc: [tuan-research/system-health-mongodb-refactor/test.md](../../../../tuan-research/system-health-mongodb-refactor/test.md).

## 1. Test Matrix và Kịch bản

| ID | Nhóm | Tình huống kiểm thử | Kỳ vọng | Trạng thái |
|---|---|---|---|---|
| C01 | Contract | Replay API `/servers`, `/health-targets`, `/enrollments` | Giữ nguyên contract, envelope, error codes, UUID và nullability | [x] Đạt (Unit) |
| C02 | Auth | Kiểm tra quyền ADMIN và verify token | Constant-time token verification, fail-closed khi SQL role store unavailable | [x] Đạt (Unit) |
| W01 | Worker | Heartbeat server & collector | Conditional update, không overwrite metadata, lưu Decimal128 strict | [x] Đạt (Unit) / [ ] Chờ Atlas |
| W04 | Worker | Duplicate checkId | Return duplicate: true, không đổi receivedAt | [x] Đạt (Unit) / [ ] Chờ Atlas |
| W05 | Worker | Stale / older check | 409 CONFLICT, giữ mẫu mới | [x] Đạt (Unit) / [ ] Chờ Atlas |
| W06 | Worker | Concurrency first-write | Chỉ một write thành công, write sau fail CAS (checkedAtMicros) | [x] Đạt (Unit) / [ ] Chờ Atlas |
| E01 | Enrollment | Concurrent redeem invitation | Một redeem thành công, token chỉ dùng một lần | [x] Đạt (Unit) / [ ] Chờ Atlas |
| E03 | Enrollment | Transaction rollback khi insert host fail | Invitation không bị mất sau rollback nguyên tử trên replica set, tái sử dụng được | [ ] Chờ Atlas |
| P01 | Provision | Chạy provisioning lặp lại | Idempotent, BSON Long catalogVersion, kiểm tra host reference | [x] Đạt (Syntax/Unit) / [ ] Chờ Atlas |
| M01 | Migration | Backfill & verify | Dữ liệu đối soát khớp 100% giữa PostgreSQL và MongoDB (exact epoch ms & micros) | [ ] Chờ Rehearsal |
| M02 | Rollback | Reverse-sync sau đột biến & verify | Khôi phục PostgreSQL từ MongoDB bảo toàn microseconds, FK an toàn, đồng bộ host mới/đổi collector | [ ] Chờ Rehearsal |

---

## 2. Quy trình kiểm thử kết nối MongoDB Atlas thật (Live Integration Test)

File test: [MongoMonitoringStoreAtlasIntegrationTest.java](../../../../brandhub-business-service/src/test/java/com/brandhub/business/service/monitoring/MongoMonitoringStoreAtlasIntegrationTest.java)

### Cơ chế đảm bảo tính toàn vẹn kiểm thử:
- **Giữ nguyên Schema & Validator**: Suite kiểm tra validator strict (`validationAction: 'error'`, `validationLevel: 'strict'`) và xác nhận các thuộc tính cấu trúc trọng yếu đã liệt kê (required fields, pattern UUID, catalogVersion Int64, latencyMs Decimal128, checkedAtMicros Int64, pattern hash token) cho cả 4 collections (lưu ý: kiểm tra hiện xác nhận các thuộc tính đã liệt kê này, chưa phải so sánh toàn bộ schema giống migration). Các lượt test chỉ dọn documents (`remove(new Query(), ...)`), **không bao giờ `dropCollection`**, đảm bảo các bài test Decimal128 và kiểu dữ liệu luôn chạy dưới sự kiểm soát của validator nghiêm ngặt.
- **Rollback nghiêm ngặt**: Kiểm tra chính xác lỗi `DuplicateKeyException` khi cố tình tạo trùng ID host, xác minh host cũ hoàn toàn nguyên vẹn, enrollment token không bị mất và **chứng minh tái sử dụng thành công** bằng cách dùng chính token đó để đăng ký một host mới hợp lệ.
- **Concurrency chặt chẽ**: Đặt timeout 15s cho CountDownLatch, bắt và fail nếu có bất kỳ lỗi ngoài dự kiến (chỉ chấp nhận `MONITORING_CONFLICT`), đồng thời kiểm chứng kết quả cuối cùng trên document MongoDB ghi nhận chính xác `checkId` và timestamp microsecond của worker mới nhất.

### Chuẩn bị môi trường:
1. Database riêng trên Atlas: `brandhub_monitoring_acceptance` (tách biệt hoàn toàn khỏi database `brandhub`).
2. Database user: Chỉ cấp quyền `readWrite` trên `brandhub_monitoring_acceptance`.
3. Network Access: Thêm IP máy chạy test vào whitelist trên Atlas Dashboard.
4. Đặt biến môi trường trên máy (PowerShell):
   ```powershell
   $env:TEST_MONGODB_URI="mongodb+srv://<test_user>:<test_password>@<cluster>.mongodb.net/brandhub_monitoring_acceptance?retryWrites=true&w=majority"
   ```

### Các kịch bản được tự động kiểm chứng trên Atlas (5/5):
1. `testStrictSchemaValidatorRejectsInvalidDocumentOnAtlas`: Kiểm chứng MongoDB Schema Validator strict đang hoạt động, từ chối document sai UUID pattern hoặc thiếu trường bắt buộc.
2. `testAtomicEnrollmentRollbackOnFailureOnAtlas`: Tạo enrollment -> register gây trùng khóa server ID -> kiểm chứng rollback, server cũ nguyên vẹn và enrollment tái sử dụng được.
3. `testDecimal128AndUptimePersistenceOnAtlas`: Gửi heartbeat với số thực độ chính xác cao -> kiểm tra document lưu đúng BSON `Decimal128` (thỏa mãn strict schema validator).
4. `testSubMillisecondCasAndDuplicateDetectionOnAtlas`: Kiểm tra CAS theo `checkedAtMicros` (sub-millisecond ordering), chặn mẫu cũ 409 CONFLICT và duplicate checkId (`duplicate: true`).
5. `testConcurrentCasWritesOnSingleTargetAtlas`: Nhiều luồng gửi kết quả đồng thời có timeout 15s -> kiểm chứng CAS ngăn chặn lost updates và phản ánh đúng mẫu mới nhất.

### Thực thi test suite:
```powershell
cd D:\capstone\brandhub\brandhub-business-service
mvn test "-Dtest=MongoMonitoringStoreAtlasIntegrationTest"
```
*(Yêu cầu nghiệm thu: `Tests run: 5, Failures: 0, Errors: 0, Skipped: 0`)*

---

## 3. Quy trình Diễn tập Migration & Rollback (Rehearsal Runbook)

Diễn tập trên cặp database test độc lập:
- PostgreSQL: `brandhub_test` (chứa dữ liệu mẫu monitoring ban đầu)
- MongoDB Atlas: `brandhub_monitoring_acceptance`

### Bước 1: Khởi tạo Schema trên MongoDB Atlas test bằng tài khoản setup (Chế độ APPLY)
*Sử dụng tài khoản setup/admin có quyền quản trị schema (`collMod`, `createIndexes`):*
```powershell
cd D:\capstone\brandhub\brandhub-monitoring
$env:SETUP_MONGODB_URI="mongodb+srv://<setup_user>:<setup_password>@<cluster>.mongodb.net/brandhub_monitoring_acceptance?retryWrites=true&w=majority"
$env:MONITORING_COLLECTIONS_APPLY="true"
$env:MONITORING_MONGODB_DATABASE="brandhub_monitoring_acceptance"

# Cách 1: Chạy trực tiếp qua Node.js (khuyến nghị, không cần cài đặt mongosh)
node scripts/ops/apply-monitoring-collections.mjs

# Cách 2: Chạy qua mongosh (nếu máy đã có mongosh)
mongosh "$env:SETUP_MONGODB_URI" migrations\2026-10-22-monitoring-collections.js
```
*Kết quả mong đợi*: Output JSON trả về `"mode": "APPLY"` và khởi tạo hoặc cập nhật validator/index cho cả 4 collections trên `brandhub_monitoring_acceptance`.

### Bước 2: Diễn tập Backfill dữ liệu từ PostgreSQL test sang Atlas test
```powershell
cd D:\capstone\brandhub\brandhub-monitoring
$env:MONITORING_DATABASE_URL="postgresql://<user>:<pass>@<pg_host>:5432/brandhub_test"
$env:MONITORING_MONGODB_URI="$env:TEST_MONGODB_URI"
$env:MONITORING_MONGODB_DATABASE="brandhub_monitoring_acceptance"

node scripts/ops/backfill-postgres-to-mongo.mjs
```

### Bước 3: Đối soát sâu toàn bộ dữ liệu ban đầu (Exact Verification)
```powershell
node scripts/ops/verify-sync.mjs
```
*Yêu cầu*: 0 discrepancies, khớp từng trường cấu hình, metric host, và epoch microsecond.

### Bước 4: Tạo các đột biến trạng thái thực tế trên MongoDB trước Rollback
Mô phỏng các hoạt động vận hành phát sinh trong thời gian chạy trên MongoDB:
1. **Tạo host & collector mới**: Thêm 1 server mới và 1 collector mới vào MongoDB.
2. **Tiêu thụ enrollment**: Dùng 1 enrollment token hợp lệ để đăng ký host mới (xóa enrollment khỏi MongoDB, tạo server).
3. **Đổi collector cho target**: Cập nhật `collectorId` của 1 target sang collector mới tạo và xóa `latestResult` cũ (hoặc cập nhật sample mới).
4. **Ghi nhận sample mới**: Ghi kết quả kiểm tra mới với độ chính xác microseconds.

### Bước 5: Diễn tập Rollback Reverse Export (MongoDB -> PostgreSQL)
```powershell
node scripts/ops/reverse-export-mongo-to-postgres.mjs
```
*Yêu cầu kiểm chứng*:
- Thực hiện hoàn toàn trong 1 SQL transaction (`BEGIN ... COMMIT`).
- Trật tự xóa kết quả cũ trước khi đổi target owner giúp vượt qua ràng buộc khóa ngoại `fk_monitoring_result_owner`.
- Server mới, collector mới và sự thay đổi phân công collector của target được đồng bộ trọn vẹn vào PostgreSQL.
- Timestamp `checked_at` giữ nguyên microsecond thông qua `to_timestamp($checkedAtMicros / 1000000.0)`.

### Bước 6: Đối soát lại sau Rollback
```powershell
node scripts/ops/verify-sync.mjs
```
*Yêu cầu*: Hoàn thành với 0 discrepancies giữa MongoDB và PostgreSQL sau khi rollback.

---

## 4. Nhật ký kết quả diễn tập (Test Log)

*Sẽ được cập nhật sau khi operator chạy kịch bản kết nối Atlas:*

| Thời điểm | Kịch bản | Số bản ghi PG | Số bản ghi Atlas | Kết quả đối soát | Ghi chú |
|---|---|---|---|---|---|
| 2026-10-22 23:53 | Live Atlas Integration | - | - | 5 pass / 0 fail / 0 skip | 14.15s, CAS, rollback, Decimal128, strict validator 121, TTL |
| 2026-10-22 23:58 | Backfill Rehearsal | S:1, C:1, T:1, R:1, E:1 | S:1, C:1, T:1, R:1, E:1 | Đã backfill thành công | RunId: 2026-10-22T16:58:51.686Z |
| 2026-10-22 23:58 | Verify Deep Sync | S:1, C:1, T:1, R:1, E:1 | S:1, C:1, T:1, R:1, E:1 | Khớp 100% (0 discrepancies) | Đối soát sâu từng trường cấu hình, epoch micros |
| 2026-10-22 23:58 | State Mutations | - | S:+2, C:+1, E:-1, T:reassigned | Ghi nhận đột biến thực tế | Micros mẫu: 1792688331654321 |
| 2026-10-22 23:58 | Rollback Rehearsal | S:3, C:2, T:1, R:1, E:0 | S:3, C:2, T:1, R:1, E:0 | Rollback thành công | Transaction SQL, trật tự xóa FK an toàn, to_timestamp micros |
| 2026-10-22 23:58 | Post-Rollback Verify | S:3, C:2, T:1, R:1, E:0 | S:3, C:2, T:1, R:1, E:0 | Khớp 100% (0 discrepancies) | Đối soát 0 sai lệch; productionTablesChanged: false |

---

## 5. Nhật ký thực thi T9 Cutover — Chuẩn bị và Kiểm chứng Production (2026-10-23 00:30 Asia/Saigon)

### 5.1. Định danh hạ tầng và Topology
- **Host Target EC2**: `54.255.46.226` (Amazon Linux 2023 x86_64, 913 MiB RAM, 1 GiB swap, 4.8 GiB disk free).
- **Topology quyết định**: Giữ dependencies (PostgreSQL, Redis, RabbitMQ) tại cụm dịch vụ hiện có, không nhồi nhét lên máy ảo EC2 nhỏ 1GB RAM. EC2 chỉ chạy ứng dụng container hóa tối ưu bộ nhớ (`-Xmx384m -Xms192m`).
- **Kết nối Atlas**: Đã kiểm chứng handshake TLS từ EC2 trực tiếp tới cluster MongoDB Atlas `brandhub.dupoa3v.mongodb.net:27017` (`depth=3 CN=ISRG Root X1, verify return:1`).
- **Artifact Release**:
  - Build local artifact: `brandhub-business-service-0.0.1-SNAPSHOT.jar` (110 MiB).
  - Checksum SHA-256: `3c51106419f501bcdd2c2456f45c64cece2831309635b3799cec14cb4321a61b`.
  - EC2 Docker Image: `brandhub-business-service:refactor` (Digest `sha256:b50b9b868c243e30dd78280871034b615f4041cfaec8351ab6628b5799cf555e`, kích thước 323MB).
  - Unit test Business refactor: 12/12 unit tests pass (`MongoMonitoringStoreTest`).

### 5.2. Backup và Kiểm chứng Khôi phục
- **File dump**: `brandhub-monitoring/.runtime/backups/backup_monitoring_baseline_20261023.sql` (18,821 bytes, timestamp: `2026-10-23T00:25:27+07:00`).
- **Kiểm chứng phục hồi**: Đã nạp thành công vào database kiểm chứng độc lập `brandhub_backup_verify`, xác nhận đầy đủ 5 bảng monitoring, ràng buộc khóa ngoại và index.
- **Số lượng baseline**: Servers: 0, Collectors: 0, Targets: 0, Results: 0, Enrollments: 0.

### 5.3. Schema & Index trên MongoDB Atlas Production (`brandhub`)
- **Database đích**: `brandhub` (tuyệt đối không dùng `brandhub_monitoring_acceptance`).
- **Thực thi**: Chạy `apply-monitoring-collections.mjs` với `MONITORING_COLLECTIONS_APPLY=true`.
- **Kết quả xác nhận trên Atlas**:
  - `monitoring_servers`: validator strict (`validationAction: 'error'`, `validationLevel: 'strict'`) + indexes `idx_monitoring_servers_name_id`, `idx_monitoring_servers_env_name_id`.
  - `monitoring_collectors`: validator strict + index `idx_monitoring_collectors_server_id`.
  - `monitoring_health_targets`: validator strict + compound indexes `idx_monitoring_targets_name_id`, `idx_monitoring_targets_env_kind_name_id`, `idx_monitoring_targets_server_name_id`, `idx_monitoring_targets_collector_id`.
  - `monitoring_enrollments`: validator strict + TTL index `{ expiresAt: 1 }` (`expireAfterSeconds: 0`).

### 5.4. Backfill và Đối soát sâu Production
- **Backfill**: PostgreSQL `brandhub` -> MongoDB Atlas `brandhub` hoàn thành lúc `2026-10-22T17:28:09.066Z`.
- **Verify Deep Sync**: Chạy `verify-sync.mjs`:
  `Verification PASSED: Verified all servers (0), collectors (0), targets (0), results (0), and valid enrollments (0) field-by-field with 0 discrepancies.`

### 5.5. Quản lý Tunnel Bền vững & Tự động Phục hồi (Tunnel Supervisor)
- **Giám sát & Tự động Reconnect**: Đã triển khai tiến trình supervisor chuyên dụng [tunnel-supervisor.mjs](../../../../brandhub-monitoring/scripts/ops/tunnel-supervisor.mjs) chạy ngầm để bảo đảm kết nối SSH tunnel không bị đứt đoạn:
  - Tự động duy trì các cổng: `-R 127.0.0.1:5432` (Postgres), `-R 127.0.0.1:6379` (Redis), `-R 127.0.0.1:5672` (RabbitMQ), `-L 127.0.0.1:8081` (Forward Business HTTP).
  - Tần suất probe kiểm tra Actuator Health mỗi 10 giây; nếu rớt kết nối hoặc tiến trình SSH bị tắt, supervisor lập tức phát hiện trong vòng 2 giây và spawn lại SSH process mới.
  - Trạng thái runtime được cập nhật liên tục vào [tunnel-status.json](../../../../brandhub-monitoring/.runtime/tunnel-status.json) (file local được Git ignore).
- **Kiểm chứng Tự phục hồi Thực tế**:
  - Thực hiện lệnh cưỡng chế tắt tiến trình SSH (`taskkill /F /IM ssh.exe`).
  - Supervisor bắt sự kiện exit (`code=1`), chuyển trạng thái `RECONNECTING`, chờ 2 giây và tái lập thành công phiên SSH mới.
  - Trạng thái phục hồi ghi nhận: `status: "HEALTHY"`, `actuatorStatus: "UP"`, `reconnectCount: 1`, container `brandhub-business` trên EC2 tiếp tục xử lý các luồng bình thường mà không cần restart container.

### 5.6. Triển khai Native Host Agent & Collector trên AWS EC2 (Real Hardware Telemetry)
- **Khắc phục triệt để giả lập metrics**:
  - Đã loại bỏ hoàn toàn các giá trị gán cứng fallback trong [resources.mjs](../../../../brandhub-monitoring/src/resources.mjs); nếu không đọc được từ kernel host thì giữ nguyên `null`.
  - Đã dừng tiến trình worker local để đảm bảo 100% metrics được đo trực tiếp từ phần cứng máy chủ EC2 thật.
- **Cài đặt Host Agent qua luồng chuẩn (`install.sh` & `agent.py`) trên EC2**:
  - Admin sinh token mời chính thức qua API (`POST /api/monitoring/enrollments`): cấp token `89c7...` cho máy chủ `ec2-production-54-255-46-226`.
  - Thực thi lệnh cài đặt chính thức trên EC2: `curl -fsS http://127.0.0.1:8081/api/monitoring/install.sh | sudo bash -s -- http://127.0.0.1:8081 <TOKEN>`.
  - Cấu hình agent tự động lưu tại `/etc/brandhub-monitor-agent/config.json` (`serverId: 78838002-a308-4fe1-b7e9-d68c75b8403d`).
  - Dịch vụ systemd [brandhub-monitor-agent.service](file:///etc/systemd/system/brandhub-monitor-agent.service) được kích hoạt và khởi chạy tự động:
    - Trạng thái: `Active: active (running)`.
    - Tự động chạy lại khi boot/reboot (`enabled`).
    - Gửi số liệu thật từ `/proc/stat`, `/proc/meminfo`, `/proc/uptime`, và `statfs('/')` mỗi 15 giây.
- **Triển khai Collector Worker độc lập trên EC2**:
  - Sao chép bộ mã nguồn collector lên `/home/ec2-user/brandhub/monitoring`.
  - Cấu hình [config.json](file:///home/ec2-user/brandhub/monitoring/config.json) giám sát 2 endpoints:
    - Target 1: `78838002-a308-4fe1-b7e9-700000000001` (Actuator Health `http://127.0.0.1:8081/actuator/health`)
    - Target 2: `78838002-a308-4fe1-b7e9-700000000002` (Installer Endpoint `http://127.0.0.1:8081/api/monitoring/install.sh`)
  - Thiết lập dịch vụ systemd [brandhub-collector.service](file:///etc/systemd/system/brandhub-collector.service) trên EC2:
    - Trạng thái: `Active: active (running)`.
    - Chạy độc lập trong hệ điều hành EC2, tự khởi động lại khi gặp lỗi (`Restart=always`).
- **Bằng chứng Đo lường Thực tế trên EC2 qua các Chu kỳ Liên tiếp**:
  - *Chu kỳ 1 (18:15:11 UTC)*:
    - Server ID: `78838002-a308-4fe1-b7e9-d68c75b8403d`
    - IP thực tế EC2: `172.31.38.183`
    - CPU EC2 thật: `10.89%` (Decimal128)
    - RAM EC2 thật: `90.5%` (Decimal128 - tương ứng 913 MiB RAM khi chạy JVM và Docker)
    - Disk EC2 thật: `50.74%` (Decimal128 - dung lượng volume EBS 10 GiB)
    - Uptime EC2 thật: `3871 giây` (~1 giờ kể từ lúc khởi động EC2)
    - Target 1: `PASS`, latency: `2968.272ms`
    - Target 2: `PASS`, latency: `178.15ms`
  - *Chu kỳ 2 (18:15:56 UTC - 45 giây sau)*:
    - Server `lastSeenAt`: `2026-10-22T18:15:56.697Z` (cập nhật mới)
    - CPU EC2 thật: `1.43%` (Decimal128)
    - RAM EC2 thật: `89.15%` (Decimal128)
    - Uptime EC2 thật: `3916 giây` (+45s chính xác)
    - Target 1: `PASS`, latency: `4075.851ms`, `checkedAtMicros: 1792692948326000`
    - Target 2: `PASS`, latency: `4.089ms`, `checkedAtMicros: 1792692955262000`

### 5.7. Kiểm chứng Toàn vẹn Luồng ADMIN API & Invitation Sinh tự động
Chạy script kiểm thử tích hợp chuẩn REST [smoke-admin-api.mjs](../../../../brandhub-monitoring/scripts/ops/smoke-admin-api.mjs):
1. **Xác thực ADMIN (`POST /api/v1/auth/login`)**:
   - Đăng nhập tài khoản `admin@demo.brandhub.test`.
   - Business service xác thực người dùng và phân quyền `ROLE_ADMIN` qua bảng PostgreSQL `user_system_roles`.
   - Cấp phát JWT Access Token RS256 có hiệu lực.
2. **Admin tạo Invitation qua API (`POST /api/monitoring/enrollments`)**:
   - Gửi yêu cầu mời máy chủ mới `api-enrolled-worker-node` kèm `apiBaseUrl`.
   - API trả về HTTP 200, thời gian hết hạn (`expiresAt: 2026-10-22T18:21:22Z`), và câu lệnh cài đặt chứa mã token hex 64 ký tự.
   - Bản ghi token hash tương ứng được tự động lưu vào Atlas `monitoring_enrollments`.
3. **Đăng ký máy chủ tự động qua API (`POST /api/monitoring/register`)**:
   - Sử dụng raw token sinh từ API trên để gọi register: HTTP 200, khởi tạo thành công máy chủ `b761e7e8-34d3-4bdb-b3f9-7545055b6ffd`.
   - Token mời bị thu hồi/xóa tự động (single-use semantics).
4. **Admin truy vấn danh sách (`GET /api/monitoring/servers` & `GET /api/monitoring/health-targets`)**:
   - Admin gọi API lấy danh sách máy chủ: truy vấn trực tiếp từ MongoDB Atlas, xác nhận máy chủ `api-enrolled-worker-node` có mặt trong danh sách.
   - Admin gọi API lấy trạng thái targets: trả về dữ liệu thời gian thực được worker cập nhật (`UP`, kèm latency microsecond).

### 5.8. Bằng chứng Tuyệt đối "0 SQL Writes" qua Telemetry `pg_stat_user_tables`
Đối soát trực tiếp bộ đếm DML thống kê mức hạt nhân của PostgreSQL (`pg_stat_user_tables`) trước và sau toàn bộ các chu kỳ thu thập liên tục và luồng kiểm thử:
```text
          relname          | delta_ins | delta_upd | delta_del | delta_hot_upd 
---------------------------+-----------+-----------+-----------+---------------
 monitoring_collectors     |         0 |         0 |         0 |             0
 monitoring_enrollments    |         0 |         0 |         0 |             0
 monitoring_health_results |         0 |         0 |         0 |             0
 monitoring_health_targets |         0 |         0 |         0 |             0
 monitoring_servers        |         0 |         0 |         0 |             0
```
- **Kết luận**: Mọi thao tác ghi monitoring (heartbeat, collector heartbeat, health results, invitations, node registrations) phát sinh trong hệ thống được định tuyến 100% vào MongoDB Atlas. Tuyệt đối không có bất kỳ lệnh `INSERT`, `UPDATE`, hay `DELETE` nào chạm vào 5 bảng PostgreSQL.

### 5.9. Quản trị Bí mật & Che giấu Dữ liệu Nhạy cảm
- Loại bỏ hoàn toàn fallback credential/URI hardcode khỏi các script kiểm thử; yêu cầu biến môi trường `MONITORING_MONGODB_URI` hoặc file cấu hình bí mật.
- Toàn bộ log hiển thị dữ liệu đăng ký (`agentToken`, khóa kết nối) đều được che mặt định dạng `***MASKED***`.

### 5.10. Kiến trúc Phụ thuộc Tunnel và Định hướng Môi trường Độc lập
- **Hiện trạng Hybrid**:
  - Container Business chạy trên EC2 (`MONITORING_STORAGE=mongo`).
  - Toàn bộ tiến trình thu thập monitoring (`brandhub-monitor-agent.service` và `brandhub-collector.service`) chạy natively trên EC2, ghi thẳng vào MongoDB Atlas production độc lập với SSH tunnel.
  - SSH tunnel hiện tại chỉ trung chuyển các kết nối phụ thuộc chưa chuyển vùng (PostgreSQL cho auth, Redis, RabbitMQ) từ local lên EC2.
  - Khi hoàn thiện hạ tầng độc lập (RDS/Elasticache/CloudAMQP hoặc internal VPC subnet), Business sẽ kết nối thẳng qua private networking nội bộ AWS, loại bỏ hoàn toàn tunnel máy cá nhân.

### 5.11. Ràng buộc Mốc T9 & Cửa sổ Rollback 7 Ngày
- **Mốc T9**: Tiếp tục giữ nguyên `[ ] Chưa thực hiện` trong [task.md](task.md).
- **Cửa sổ Rollback 7 ngày**: Chưa bắt đầu tính (T10 vẫn mở).
- **PostgreSQL 5 bảng**: Tuyệt đối KHÔNG xóa, không truncate, giữ nguyên vẹn 100% để phục vụ cơ chế rollback dự phòng khi cần thiết.

### 5.12. Báo cáo Khắc phục và Kiểm chứng Nghiệm thu T9 (23/10/2026 11:35 Asia/Saigon)

#### 1. Khôi phục & Quản lý Bền vững Dependency Tunnel (Ports 5432, 6379, 5672)
- **Hiện tượng gốc**: Tunnel SSH đứt khiến các cổng loopback trên EC2 (5432 Postgres, 6379 Redis, 5672 RabbitMQ) bị đóng; Business Actuator `/actuator/health` timeout dẫn tới worker probe ghi `FAIL / TIMEOUT` vào MongoDB Atlas. File `tunnel-status.json` cũ từ hôm trước hiển thị `HEALTHY` không phản ánh runtime.
- **Khắc phục**:
  - Tái cấu trúc [tunnel-supervisor.mjs](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/tunnel-supervisor.mjs) với cơ chế **Heartbeat Lease động** (`heartbeatIntervalMs: 10000`, `leaseTtlMs: 30000`, trường `expiresAt` ISO UTC, ghi nhận `supervisorPid` và `sshPid`).
  - Tích hợp CLI verification (`node tunnel-supervisor.mjs --status`): kiểm tra sống còn của PID qua OS API (`process.kill(pid, 0)`) và hạn lease `expiresAt`. Nếu tiến trình chết hoặc hết hạn lease, trả về `DEAD` / `STALE` (thoát mã lỗi) thay vì báo giả `HEALTHY`.
  - Tích hợp Watchdog tự phục hồi: nếu Actuator health thất bại liên tiếp $\ge 3$ lần, tự động kill và tạo lại tiến trình SSH con.
  - Bổ sung runner giám sát [start-tunnel-supervisor.ps1](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/start-tunnel-supervisor.ps1) (`-Watchdog`, `-Status`, `-Stop`) đảm bảo supervisor tự hồi sinh nếu bị tắt.
- **Chứng minh thực nghiệm**:
  - Giết tiến trình SSH con $\rightarrow$ Supervisor lập tức chuyển `RECONNECTING` và tái tạo SSH trong 2 giây, trạng thái trở lại `HEALTHY`.
  - Giết tiến trình Supervisor $\rightarrow$ CLI `--status` báo ngay `DEAD`, Watchdog tự khởi động lại tiến trình supervisor mới.
  - Cả 3 cổng `5432`, `6379`, `5672` trên EC2 đều ở trạng thái `LISTEN`. Actuator health `/actuator/health` trên cả EC2 và Windows đều trả về `{"status":"UP"}` (HTTP 200).
  - Target probe trên MongoDB Atlas cập nhật tức thì sang `outcome: "PASS"`, HTTP 200, latency chính xác (`2836ms` cho actuator UP, `1.79ms` cho monitoring install script).

#### 2. Sửa Provisioning CAS (`catalogVersion` Bump)
- **Hiện tượng gốc**: [provision-ec2-worker.mjs](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/provision-ec2-worker.mjs) cập nhật cấu hình probe/assertion mà không so khớp hoặc tăng `catalogVersion`.
- **Khắc phục**:
  - Cập nhật nhánh `else` trong loop targets:
    ```javascript
    const res = await db.collection('monitoring_health_targets').updateOne(
      { _id: t._id, catalogVersion: currentVersion },
      {
        $set: { name: t.name, probeConfig: t.probeConfig, assertion: t.assertion, updatedAt: new Date() },
        $inc: { catalogVersion: new Long(1) }
      }
    );
    ```
  - Kiểm tra `matchedCount === 0` để phát hiện xung đột đồng thời.
- **Chứng minh thực nghiệm**:
  - Chạy `provision-ec2-worker.mjs`: `catalogVersion` tăng tuần tự từ $1 \rightarrow 2 \rightarrow 3$. Document trên Atlas xác nhận `catalogVersion: "3"`, các probe results sau đó được chấp nhận hợp lệ theo CAS.

#### 3. Chuẩn hóa Bảo mật & Loại bỏ Hardcoded Credential
- **Khắc phục**:
  - Loại bỏ hoàn toàn chuỗi kết nối Atlas hardcoded trong [provision-ec2-worker.mjs (dòng 4)](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/provision-ec2-worker.mjs:4).
  - Bắt buộc đọc từ biến môi trường `MONITORING_MONGODB_URI` hoặc `MONGODB_URI`, thoát lỗi ngay nếu thiếu.
  - Khuyến nghị Operator thực hiện xoay vòng mật khẩu (rotate credential) user `brandhub-mongo` trên Atlas Dashboard và cập nhật vào biến môi trường bí mật trên máy chủ.

#### 4. Thực thi ADMIN Smoke Test với SQL Telemetry Ràng Buộc Đủ 5 Bảng
- Nâng cấp [smoke-admin-api.mjs](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/smoke-admin-api.mjs) với hằng số `REQUIRED_MONITORING_TABLES = ['monitoring_servers', 'monitoring_collectors', 'monitoring_health_targets', 'monitoring_health_results', 'monitoring_enrollments']`.
- **Ràng buộc bắt buộc**: Kiểm tra `initialStats` và `finalStats` phải chứa đủ 5 bảng; nếu truy vấn trả thiếu bất kỳ bảng nào hoặc trả rỗng, script lập tức báo lỗi `CRITICAL TELEMETRY ERROR` thay vì âm thầm trả delta = 0.
- Thực thi [smoke-admin-api.mjs](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/smoke-admin-api.mjs) trong khi worker EC2 và tunnel đang hoạt động liên tục:
  1. Xác thực ADMIN qua PostgreSQL `user_system_roles` thành công.
  2. Tạo mã mời cài đặt node qua `POST /api/monitoring/enrollments` $\rightarrow$ lưu mã hash vào MongoDB Atlas.
  3. Đăng ký node qua `POST /api/monitoring/register` $\rightarrow$ sinh serverId mới `3d838180-1480-4d57-8123-c8eec7ea728e`, token mời bị thu hồi nguyên tử.
  4. ADMIN truy vấn `/api/monitoring/servers` và `/api/monitoring/health-targets` $\rightarrow$ đọc trực tiếp từ MongoDB Atlas, xác nhận trạng thái `UP` của 2 target EC2.
  5. Đối soát `pg_stat_user_tables` xác thực đủ 5 bảng:
     ```text
     ┌───────────────────────────┬───────────┬───────────┬───────────┐
     │ (index)                   │ delta_ins │ delta_upd │ delta_del │
     ├───────────────────────────┼───────────┼───────────┼───────────┤
     │ monitoring_servers        │ 0         │ 0         │ 0         │
     │ monitoring_collectors     │ 0         │ 0         │ 0         │
     │ monitoring_health_targets │ 0         │ 0         │ 0         │
     │ monitoring_health_results │ 0         │ 0         │ 0         │
     │ monitoring_enrollments    │ 0         │ 0         │ 0         │
     └───────────────────────────┴───────────┴───────────┴───────────┘
     ```
  - **Kết quả**: Xác nhận đầy đủ 5/5 bảng monitoring trong PostgreSQL. Zero DML writes trên cả 5 bảng. Toàn bộ chu trình hoạt động của worker và admin API đạt chuẩn 100% MongoDB Atlas.

#### 5. Khắc phục Vận hành: Xác Minh Danh Tính Supervisor & Ràng Buộc Đồng Thời (Strict AND) Cho SSH Child
- **Hiện tượng**: Phiên bản trước dùng điều kiện `OR` có thể vô tình dừng tiến trình SSH khác nếu trùng tham số khóa/IP.
- **Khắc phục triệt để**: Cập nhật [start-tunnel-supervisor.ps1](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/start-tunnel-supervisor.ps1):
  1. **Xác minh danh tính Supervisor**: Hàm `Test-VerifiedSupervisorProcess` kiểm tra tiến trình tại PID trong status file phải là `node.exe` VÀ `CommandLine` chứa `tunnel-supervisor.mjs`. Nếu không đúng, từ chối tin cậy và không can thiệp.
  2. **Ràng buộc đồng thời (Strict AND, loại bỏ hoàn toàn OR)**: Hàm `Test-VerifiedBrandHubSshChild` chỉ chấp nhận dừng SSH nếu thỏa mãn **đồng thời 100% các điều kiện**:
     - `ProcessId == $SshPid`
     - `ParentProcessId == $VerifiedSupervisorPid` (bắt buộc là con của supervisor đã xác minh)
     - `Name == 'ssh.exe'`
     - `CommandLine` chứa khóa `key_sing_404.pem`
     - `CommandLine` chứa đích `54.255.46.226`
     - `CommandLine` chứa reverse forwarding `-R *5432:127.0.0.1:5432*`
  3. Bất kỳ tiến trình SSH độc lập nào khác của người dùng đều không thỏa mãn `ParentProcessId == $VerifiedSupervisorPid` nên hoàn toàn được bảo vệ.

#### 6. Snapshot & Backup Dữ Liệu Monitoring Trên Atlas Hiện Tại
- Đã tạo script sao lưu [backup-atlas-monitoring.mjs](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/backup-atlas-monitoring.mjs) đọc trực tiếp từ cụm Atlas hiện tại (`${MONGODB_URI:[REDACTED_URI]`).
- **Kết quả thực thi**: Lưu file snapshot độc lập tại [backup_monitoring_atlas_20261023.json](file:///d:/capstone/brandhub/brandhub-monitoring/.runtime/backups/backup_monitoring_atlas_20261023.json) bao gồm:
  - `monitoring_servers`: 10 documents
  - `monitoring_collectors`: 6 documents
  - `monitoring_health_targets`: 8 documents (với `catalogVersion: 3`, latency microsecond, assertions)
  - `monitoring_enrollments`: 0 documents
- Toàn bộ trạng thái và cấu hình trên Atlas trước cutover đã được lưu trữ làm bằng chứng phục hồi.

#### 7. Quy Trình Xoay Vòng Credential Atlas & Recreate Container
- **Lưu ý kỹ thuật Docker**: `docker update` hoặc `docker restart` không thể thay đổi biến môi trường đã gán cho container. Việc cập nhật `MONGODB_URI` bắt buộc phải **recreate container** (`docker stop` $\rightarrow$ `docker rm` $\rightarrow$ `docker run`).
- **Quy trình thực thi**:
  1. Trên MongoDB Atlas Console (hoặc Atlas Cloud API): Tạo credential mới cho user `brandhub-mongo` (hoặc tạo user mới `brandhub-app` có quyền `readWrite` trên `brandhub`).
  2. Trên EC2 (`54.255.46.226`): Recreate container `brandhub-business` (`brandhub-business-service:refactor`) với biến môi trường `MONGODB_URI` mới.
  3. Cập nhật file `.env` cục bộ cho các công cụ runner/smoke test.
  4. Xác nhận Business `/actuator/health` UP và chạy lại smoke test bằng credential mới.
  5. Thu hồi / vô hiệu hóa credential cũ `3TfyH74Nz.gxmZH` trên Atlas Console và kiểm chứng kết nối bằng credential cũ bị từ chối (`AuthenticationFailed`).

#### 8. Tình Trạng Nghiệm Thu T9
- **Mốc T9**: Đánh dấu **[x] Hoàn thành cutover chức năng**.
  - Runtime container `brandhub-business` trên EC2 chạy ổn định với `MONITORING_STORAGE=mongo`.
  - 5 bảng PostgreSQL giữ nguyên 100% dữ liệu, xác nhận 0 DML writes với telemetry đủ cả 5 bảng.
  - Dependency tunnel supervisor chạy chế độ lease động kèm watchdog, kiểm tra quyền sở hữu bằng strict AND.
  - Backup snapshot Atlas lưu tại [backup_monitoring_atlas_20261023.json](file:///d:/capstone/brandhub/brandhub-monitoring/.runtime/backups/backup_monitoring_atlas_20261023.json).
  - **Tồn đọng ghi nhận riêng**: Credential rotation Atlas chưa hoàn tất (chờ người dùng cập nhật trên Atlas Console và cung cấp credential mới).

---

## 6. Giai Đoạn T10 — Theo Dõi Vận Hành System Health Sau Cutover

### 6.1. Thời Điểm Khởi Động & Mốc Thời Gian
* **Thời điểm bắt đầu chính thức**: **`2026-10-23 12:29:43 Asia/Saigon`** (`2026-10-23T05:29:43.577Z UTC`).
  * *Ghi chú chuẩn*: Không tính lùi thời gian khi chưa có bằng chứng liên tục. Mốc 12:29:43 là thời điểm hoàn tất xác minh credential rotation, recreate container với credential mới, Actuator UP, smoke test pass và chụp baseline snapshot chuẩn.
* **Cửa sổ rollback bắt buộc**: Tối thiểu 7 ngày $\rightarrow$ duy trì đến ít nhất **`2026-10-30 12:29:43 Asia/Saigon`**.
* **Thời điểm sớm nhất có thể đánh giá T10**: Sau tối thiểu 24 giờ theo dõi liên tục $\rightarrow$ **`2026-10-24 12:29:43 Asia/Saigon`** (với điều kiện không phát sinh regression và telemetry hoàn toàn lành mạnh).
* **Cam kết rollback window**: Giữ nguyên vẹn 100% cả 5 bảng PostgreSQL monitoring; tuyệt đối không thực hiện DROP/TRUNCATE hoặc chuyển sang T11.

### 6.2. Bằng Chứng Xác Minh Credential Rotation (Đã Che Secrets)
Theo yêu cầu nghiêm ngặt của T9/T10, toàn bộ chu trình credential rotation đã được thực hiện và kiểm chứng độc lập:
1. **Business và các consumer sử dụng credential mới**:
   * Secret credential mới (`brandhub-mongo:***MASKED***`) đã được cấu hình trong `brandhub-business-service/.env` và EC2 `/home/ec2-user/brandhub/business/.env`.
   * Container `brandhub-business` đã được recreate hoàn toàn trên EC2 (Container ID mới: `46fcf416de72`).
   * Host agent và collector trên EC2 kết nối qua Local HTTP API (`http://127.0.0.1:8081`) bằng collector/agent token, không trực tiếp giữ Atlas connection string.
2. **Recreation, Health và Smoke Test Đạt**:
   * Spring Boot khởi động thành công và thiết lập kết nối replica set tới MongoDB Atlas (`ac-s1fevvp-shard-00-02.dupoa3v.mongodb.net:27017, type=REPLICA_SET_PRIMARY, ok=true`).
   * Endpoint Actuator Health `http://127.0.0.1:8081/actuator/health` trả HTTP 200 `{"status":"UP"}`.
   * Smoke test `smoke-admin-api.mjs` pass 100%: Login admin JWT, tạo invitation enrollment, đăng ký worker node mới, query 11 servers và 8 targets từ MongoDB Atlas thành công.
3. **Credential cũ bị từ chối xác thực**:
   * Kiểm tra độc lập kết nối bằng credential cũ (`brandhub:***MASKED***`) tới cluster Atlas:
   * Kết quả: **`REJECTED`** với lỗi `MongoServerError: bad auth : Authentication failed.` (`code: 8000, codeName: 'AtlasError'`).
   * Xác nhận credential cũ đã bị thu hồi/xóa hoàn toàn trên MongoDB Atlas.

### 6.3. Baseline Đo Đạc Khởi Động T10 (Chụp lúc 12:29:43 23/10/2026 Asia/Saigon)
Snapshot chi tiết lưu tại [t10-baseline-snapshot.json](file:///d:/capstone/brandhub/brandhub-infrastructure/docs/feature/system-health-mongodb-refactor/t10-baseline-snapshot.json).

#### 1. EC2 Container & Tài Nguyên Hệ Thống
* **Container `brandhub-business`**:
  * Image: `brandhub-business-service:refactor` (Container ID: `46fcf416de72`)
  * Trạng thái: `running` | StartedAt: `2026-10-23T05:25:32.085Z`
  * RestartCount: **9** (tính cả các lần stop/recreate và restart thử nghiệm) | OOMKilled: **false**
  * Tải tài nguyên container: CPU: **3.75%** | RAM: **442.0 MiB / 913.1 MiB (48.41%)**
* **Tài nguyên EC2 Host (Amazon Linux 2023, 1 vCPU, 1 GiB RAM)**:
  * Uptime host: 12h19m | Load average: **0.14, 0.56, 0.39**
  * RAM: Total 913 MiB, Used 689 MiB, Free 63 MiB, Buff/Cache 159 MiB, Available 90 MiB
  * Swap: 1.0 GiB (Used 240 MiB, Free 783 MiB)
  * Ổ đĩa `/`: Size 8.0 GiB, Used 4.1 GiB (51%), Avail 3.9 GiB
* **Systemd Services**:
  * `brandhub-monitor-agent`: `active (running)`, `enabled`
  * `brandhub-collector`: `active (running)`, `enabled`

#### 2. Dependency Tunnel Supervisor & Watchdog
* Tiến trình: Supervisor PID **35304** (`node.exe tunnel-supervisor.mjs`), SSH PID **37076** (`ssh.exe`)
* Cơ chế bảo vệ:
  * Watchdog background tự động khởi động lại supervisor khi gặp sự cố bất ngờ.
  * Xác minh tiến trình nghiêm ngặt: Đồng thời thỏa mãn điều kiện AND (`ProcessId` + `ParentProcessId` + `Name == ssh.exe` + CommandLine chứa key và forward port của BrandHub). Loại bỏ triệt để việc dừng ssh.exe diện rộng.
  * Ngưỡng failure tolerance: Tăng lên 12 lần (120 giây) để tránh ngắt reverse tunnel khi Spring Boot thực hiện cold boot/recreate.
* Trạng thái: `HEALTHY` | Lease TTL: 30000ms | `expiresAt` cập nhật đều đặn mỗi 10s
* Phụ thuộc cục bộ: PostgreSQL (5432): **OK**, Redis (6379): **OK**, RabbitMQ (5672): **OK**
* Actuator Health: `http://127.0.0.1:8081/actuator/health` trả về `{"status":"UP"}` (HTTP 200).

#### 3. Telemetry PostgreSQL 5 Bảng Monitoring
Kiểm tra bắt buộc đầy đủ 5/5 bảng trong `pg_stat_user_tables`:
```text
┌───────────────────────────┬───────────┬───────────┬───────────┬────────────┬────────────┐
│ relname                   │ n_tup_ins │ n_tup_upd │ n_tup_del │ n_live_tup │ n_dead_tup │
├───────────────────────────┼───────────┼───────────┼───────────┼────────────┼────────────┤
│ monitoring_servers        │ 0         │ 0         │ 0         │ 0          │ 0          │
│ monitoring_collectors     │ 0         │ 0         │ 0         │ 0          │ 0          │
│ monitoring_health_targets │ 0         │ 0         │ 0         │ 0          │ 0          │
│ monitoring_health_results │ 0         │ 0         │ 0         │ 0          │ 0          │
│ monitoring_enrollments    │ 0         │ 0         │ 0         │ 0          │ 0          │
└───────────────────────────┴───────────┴───────────┴───────────┴────────────┴────────────┘
```
* **Xác nhận**: Zero DML writes (`delta_ins = 0, delta_upd = 0, delta_del = 0`) trên toàn bộ 5 bảng PostgreSQL.

#### 4. Trạng Thái Heartbeat & Target Probe Trên MongoDB Atlas
* **EC2 Host Heartbeat** (`monitoring_servers`, serverId: `78838002-a308-4fe1-b7e9-d68c75b8403d`):
  * `cpuPercent`: ~0.4%, `ramPercent`: ~54%, `diskPercent`: 51%, `uptimeSeconds`: > 44000s
  * `lastSeenAt`: Cập nhật mỗi 15s (độ tươi $\le 15$ giây, `isFresh: true`)
* **EC2 Collector Heartbeat** (`monitoring_collectors`, collectorId: `c011ec70-0000-0000-0000-000000000001`):
  * `lastSeenAt`: Cập nhật mỗi 15s (độ tươi $\le 15$ giây, `isFresh: true`)
* **EC2 Health Targets** (`monitoring_health_targets`):
  * Target 1 (`EC2 Business Actuator Health`): `catalogVersion: 3`, outcome: **`PASS`**, HTTP 200, latency ~`1950ms`, `isFresh: true`
  * Target 2 (`EC2 Business Monitoring Installer Endpoint`): `catalogVersion: 3`, outcome: **`PASS`**, HTTP 200, latency ~`5.11ms`, `isFresh: true`

#### 5. Dung Lượng Lưu Trữ MongoDB Atlas
* `monitoring_servers`: 11 documents, size 4.75 KB, storageSize 36.86 KB, totalIndexSize 110.59 KB
* `monitoring_collectors`: 6 documents, size 1.46 KB, storageSize 36.86 KB, totalIndexSize 73.72 KB
* `monitoring_health_targets`: 8 documents, size 6.81 KB, storageSize 36.86 KB, totalIndexSize 147.45 KB
* `monitoring_enrollments`: 0 documents, size 0 KB, storageSize 36.86 KB, totalIndexSize 73.72 KB

#### 6. Ghi Nhận Giới Hạn Về Baseline Trước Cutover
* **Giới hạn số đo trước cutover**: Hệ thống không có số đo baseline hiệu năng PostgreSQL (QPS/IOPS/p95 latency) được đo đạc trước cutover; không thể và không được suy đoán rằng việc chuyển 5 bảng sang Mongo giúp giảm tải PostgreSQL. Mọi đánh giá p95 sẽ so sánh trực tiếp trong chu kỳ 24h của T10.

### 6.4. Thiết Lập Tự Động Hóa Giám Sát T10 (`monitor-t10-telemetry.mjs`)
* Script tự động [monitor-t10-telemetry.mjs](file:///d:/capstone/brandhub/brandhub-monitoring/scripts/ops/monitor-t10-telemetry.mjs) được thiết lập để theo dõi định kỳ trong suốt 24 giờ.
* **Quy tắc cảnh báo không gây nhiễu**:
  * Khi toàn bộ hệ thống bình thường: Chỉ ghi một dòng log JSON ngắn gọn `status: "HEALTHY"`, không lặp cảnh báo khi trạng thái không đổi.
  * Chỉ phát cảnh báo `status: "ALERT"` (mã lỗi non-zero) khi phát hiện sự cố:
    1. Actuator health trả khác 200 hoặc khác `UP`.
    2. Dependency tunnel bị đứt, lease hết hạn hoặc cổng dependency đóng.
    3. Host/collector heartbeat quá 60s không cập nhật.
    4. Target probe trả FAIL/TIMEOUT hoặc quá `staleAfterSeconds`.
    5. Phát hiện bất kỳ thao tác INSERT/UPDATE/DELETE nào trên 5 bảng PostgreSQL.





## PostgreSQL monitoring retirement — 2026-10-23 12:42 Asia/Saigon

- Operator explicitly requested immediate removal of monitoring SQL tables, overriding the previous seven-day retention instruction. T10 observation remains open; full T11 cleanup is not claimed complete.
- Database/container: `brandhub` / `brandhub-postgres`. All five tables contained zero rows. Foreign keys referenced only the monitoring tables.
- Pre-drop backup: `brandhub-monitoring/.runtime/backups/pre_drop_monitoring_20261023.sql` (18,202 bytes, ignored by Git). SHA-256: `1E9C85D2A7E111BBFB7BAD102CFAAD2E65F7A7407DCB70A635D938D130ECC953`.
- Backup restored successfully into temporary database `brandhub_monitoring_drop_verify`: five tables verified; temporary database then removed.
- Migration: `brandhub-monitoring/migrations/2026-10-23-drop-postgres-monitoring.sql`. Transaction committed five DROP TABLE statements with RESTRICT, lock timeout, target-database check, and nonempty-table guard.
- `MongoMonitoringSchemaConfig` excludes only the five legacy monitoring tables from Hibernate schema management when `monitoring.storage=mongo`. Build/package succeeded. Local Business restarted; EC2 deployed image `brandhub-business-service:monitoring-retirement-20261023` preserving container configuration. Previous EC2 container retained stopped as `brandhub-business-before-sql-retirement`; do not restart it before restoring SQL tables or applying the schema filter.
- Post-start checks: PostgreSQL monitoring table count = 0; gateway 8080 returns 11 monitoring servers; EC2 actuator health UP; host agent and collector active.
- Rollback now requires restoring the SQL backup, reverse-exporting current MongoDB data and verifying sync before switching storage to postgres. Monitoring SQL adapters/entities and historical fresh-init SQL remain pending cleanup. Old smoke/telemetry scripts that query removed SQL tables must be updated before reuse; they must not be treated as operational acceptance gates after retirement.

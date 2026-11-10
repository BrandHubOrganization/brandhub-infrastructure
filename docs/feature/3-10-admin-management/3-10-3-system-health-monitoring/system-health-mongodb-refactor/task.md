# Task triển khai và phụ thuộc

> Cập nhật thực chạy 2026-10-22 23:53 Asia/Saigon: Atlas integration trên database riêng `brandhub_monitoring_acceptance` thuộc cluster production đã đạt **5 tests, 0 failures, 0 errors, 0 skipped** (14.15s). Xem test.md. T8 acceptance đã hoàn thành sau rehearsal thành công lúc 23:58; xem bản cập nhật mới trong test.md. Các ghi chú cũ “chưa chạy replica set thật” phía dưới được thay thế bởi kết quả này; chưa cutover.

Tham chiếu gốc: [tuan-research/system-health-mongodb-refactor/task.md](../../../../tuan-research/system-health-mongodb-refactor/task.md).

## Revisions snapshot ban đầu (2026-10-22):
- `brandhub-business-service`: `0fa2ba2`
- `brandhub-infrastructure`: `b5f99dd`
- `brandhub-monitoring`: `a8f145d`
- `brandhub-web`: `f705c4d`

| ID | Phụ thuộc | Công việc và đầu ra | Trạng thái |
|---|---|---|---|
| T0 | — | Đưa spec/plan/task/test vào feature docs tập trung; ghi repo revisions | [x] Hoàn thành |
| T1 | T0 | Baseline schema/topology, chốt ID representation và time precision converters | [x] Hoàn thành |
| T2 | T1 | Tạo schema Mongo/index/validator idempotent (`brandhub-monitoring/migrations/2026-10-22-monitoring-collections.js`), bảo vệ JPA transaction manager | [x] Hoàn thành |
| T3 | T2 | Tạo persistence seam (`MonitoringStore`), Postgres adapter và Mongo server/collector adapter | [x] Hoàn thành |
| T4 | T3 | Mongo result CAS, duplicate/ordering, catalogVersion và query projection | [x] Hoàn thành |
| T5 | T3 | Mongo enrollment transaction bắt buộc không nuốt lỗi, atomic register | [x] Hoàn thành |
| T6 | T4,T5 | Cập nhật Node provisioning script (`provision.mjs`) sang MongoDB session transaction, xử lý conflict path và validation | [x] Hoàn thành |
| T7 | T4,T5,T6 | Script backfill (`backfill-postgres-to-mongo.mjs`), verify đối soát sâu (`verify-sync.mjs`) và reverse-sync an toàn FK (`reverse-export-mongo-to-postgres.mjs`) | [x] Hoàn thành |
| T8 | T7 | Atlas 5/5 live pass; rehearsal backfill, mutations, rollback, verify 0 discrepancies | [x] Hoàn thành acceptance |
| T9 | T8 | Operator chạy cutover theo runbook; ghi timestamps, manifest, smoke và gate fleet nhất quán | [x] Hoàn thành cutover chức năng (đã hoàn tất credential rotation) |
| T10 | T9 | So số đo 24 giờ, theo dõi rollback window đề xuất 7 ngày, xác nhận vận hành | [ ] Đang thực hiện (bắt đầu 12:29:43 23/10/2026 Asia/Saigon) |
| T11 | T10 | Gỡ SQL adapter/entities monitoring, retirement migration và fresh init sau rollback window | [ ] Một phần: đã DROP theo yêu cầu operator; schema filter chống recreate; chưa gỡ SQL adapter/entities và cập nhật fresh init |

## Checklist theo mốc
- [x] T1: ID representation chốt chuỗi canonical UUID lowercase, checkedAtMicros Int64 epoch micros bảo toàn microsecond.
- [x] T2: Mongo collections có validator schema với `validationAction: 'error'` và `validationLevel: 'strict'`. JPA `transactionManager` được giữ làm `@Primary`. Đăng ký `Decimal128` converters và `@Field(targetType = FieldType.DECIMAL128)` cho metric/latency.
- [x] T3: Persistence seam `MonitoringStore` che giấu hoàn toàn Mongo/JPA khỏi controller; role ADMIN tiếp tục xác thực qua PostgreSQL.
- [x] T4: Mọi thao tác accept result là conditional update CAS dựa trên `checkedAtMicros`, duplicate trả duplicate=true không đổi receivedAt.
- [x] T5: Enrollment register bắt buộc transaction không nuốt lỗi; lỗi insert rollback hoàn toàn.
- [x] T6: `provision.mjs` kiểm tra ràng buộc timing/probeType, xác minh tham chiếu `target.serverId`, dùng `Long.fromInt(1)` cho `catalogVersion`, tách biệt `$set` và `$setOnInsert` cho `latestResult`, giữ pg dependency.
- [x] T7: Script `reverse-export-mongo-to-postgres.mjs` xóa result SQL trước khi đổi target owner và dùng `to_timestamp` epoch micros tránh mất microsecond; `verify-sync.mjs` đối soát sâu từng trường (probeConfig, assertion, host metrics, expiry, timestamps, checkedAtMicros).
- [x] T8: Atlas 5/5 pass và rehearsal với PostgreSQL test đã pass; xem test.md và rehearsal-result.json.
- [x] T9: Hoàn thành cutover chức năng. Đã xác minh hoàn tất credential rotation: Credential cũ bị MongoDB Atlas từ chối (`bad auth : Authentication failed`, code 8000); Business service trên EC2 được cấp credential mới; container `brandhub-business` đã recreate thành công, Actuator trả HTTP 200 UP; smoke test admin/enrollment/register pass và telemetry 5 bảng PostgreSQL xác nhận 0 DML.
- [ ] T10: Đang thực hiện theo dõi liên tục tối thiểu 24 giờ bắt đầu từ 12:29:43 23/10/2026 Asia/Saigon (thời điểm hoàn tất rotation và chụp baseline chuẩn). Snapshot baseline lưu tại `t10-baseline-snapshot.json`; script tự động `monitor-t10-telemetry.mjs`; thời điểm sớm nhất đánh giá hoàn thành: 12:29:43 24/10/2026 Asia/Saigon; cửa sổ rollback 7 ngày tới 12:29:43 30/10/2026. Ngoại lệ theo yêu cầu trực tiếp của operator lúc 12:42 ngày 23/10/2026: đã retirement sớm 5 bảng PostgreSQL sau backup/restore verification; rollback hiện cần restore schema trước. T10 vẫn chưa hoàn thành.
- [ ] T11: SQL dump lịch sử giữ nguyên; fresh boot không recreate 5 bảng.


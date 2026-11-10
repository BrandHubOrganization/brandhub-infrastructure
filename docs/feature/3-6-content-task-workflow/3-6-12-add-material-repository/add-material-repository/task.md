# Add Material — Execution Checklist

Đọc spec.md→plan.md→file này→test.md trước code. Chưa tick nghĩa **chưa thực hiện**.
Task ID Axx map plan Pxx và test TC-Axx, không phải Jira IDs.

Implementation local và kết quả kiểm tra: [evidence.md](evidence.md). G0/legacy inventory chưa đạt,
ticket chưa Done; checkbox giữ mở với các mục chỉ hoàn thành một phần.

## P0 — Trước implementation

- [x] A01 Inventory HEAD/rules/callers/schema/permissions, ghi baseline và phát hiện drift.
- [ ] A02 Chuẩn bị endpoint/bucket disposable + rclone pinned config, hoàn tất G0 capability
  suite TC-A01–A03; nếu chưa có environment ghi NOT RUN, không enable provider.

## P1/P2 — Shared foundation

- [ ] A03 Chốt scope resolver/predicate, lease/fence/reference pin contract theo P1; test
  CLIENT/OWNER/multi-workspace trước mở annotation role.
- [ ] A04 Viết PG migration usage/reservations/entries/pool có constraints/unique và checker;
  reuse relation tương đương nếu inventory tìm thấy, không apply shared DB.
- [ ] A05 Viết Mongo expansion/session/reference schema/index/validator, migration dry-run;
  preserve IDs/taskId, legacy unknown không READY.
- [ ] A06 Kiểm expand compatibility/fresh-init/idempotent migration trên disposable DB.

## P3 — Quota

- [ ] A07 Implement effective quota resolver catalog/period; BASIC20GiB, no base+paid.
- [ ] A08 Implement lock order + atomic reserve/routing/pool guard80/95 và Agency entitlement
  capacity check; test concurrent Agency uploads và deadlock avoidance.
- [ ] A09 Implement COMMIT/RELEASE/EXPIRED/PURGE_RELEASE idempotent ledger, dùng actual bytes
  đúng nguyên tắc upload vs derivative bound; không negative/double count.

## P4 — Upload saga

- [ ] A10 Expand FileStorageService/router/config HEAD/Range/conditional copy/presign by provider;
  reject USER_GDRIVE, timeouts bounded, no external I/O trong PG/Mongo tx.
- [ ] A11 Implement create idempotency/server session authority, Mobile TASK/LIBRARY guards.
- [ ] A12 Implement bounded validators và confirm claim/versioned promotion→usage→READY.
- [ ] A13 Implement reconciliation/cleanup checkpoints, pool overhead đến expiry+cleanup;
  process restart không lệch quota, no catch-only compensation.

## P5/P6/P7 — Compatibility và UI

- [ ] A14 Migrate legacy object/key/provider/metadata/accounting trong test, audit reports;
  writer cutover plan, private readers, no public fallback, không delete legacy mù quáng.
- [ ] A15 Watermark trusted-read/PNG/quota/ACL/lineage; regress avatar/public logos unchanged.
- [ ] A16 Replace mock upload với typed session/PUT/confirm helper và progress/retry/abort;
  update editor consumer `url`→preview signed compatibility.
- [x] A17 Cập nhật song song `src/i18n/locales/vi/library.json` + `en/library.json`, key parity.
- [ ] A18 Kiểm light/dark mode, keyboard/focus/aria labels, 375/768/1440px; không theme mới.

## P8 — Kết thúc

- [ ] A19 Chạy test.md và regressions liên quan; fault injection và G1 accounting evidence.
- [ ] A20 Ghi expected/actual/command/environment/result từng gate, canary/rollback/readiness;
  không tick Done nếu G0 external chưa chạy hoặc stale schema/contract chưa giải quyết.
- [x] A21 Review diff theo rules; không commit/push/migration live khi chưa có yêu cầu riêng.

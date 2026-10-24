# View Material — Execution Checklist

Blocked by Add migration/access/storage/accounting. Đọc đủ spec/plan/task/test trước code.

- [ ] V01 [V1] Inventory Material callers/HEAD/rules; xác nhận Add readiness, không assume deploy.
- [ ] V02 [V1] Shared query predicate scoped list/count/detail/preview + root revision guard;
  test ownership/multi-profile/multi-workspace/OWNER exception.
- [ ] V03 [V2] page/size/filter/sort validation, normalized prefix query + projection;
  giữ List data + MetaBody, invalid inputs400.
- [ ] V04 [V2] Explain trên dataset đại diện, chỉ migration indexes cần; no load-all/filter RAM.
- [ ] V05 [V3] DTO/capability mapper và signer inline TTL≤300, per-provider unavailable fallback
  metadata không public URL; no per-item HEAD.
- [ ] V06 [V3] Detail/refresh reauthorize, access_state guard, deleted/nonREADY không URL.
- [ ] V07 [V4] Usage Agency OWNER ownership read facade + workspace-only usage cho ops;
  bigint-safe output, count trash và quota effective đúng, không leak material metadata.
- [ ] V08 [V5] Replace Library list/detail mock, typed listPage helper, chuyển consumer full-list;
  cache keys/cancel-switch/optional signed preview refresh và codec fallback.
- [ ] V09 [V5] Billing usage panel cho OWNER, giữ Library OWNER denied nếu no ops membership.
- [ ] V10 [V5] Cập nhật vi/library.json + en/library.json; usage keys vi/subscription.json +
  en/subscription.json, kiểm key parity/namespace registration.
- [ ] V11 [V5] Kiểm light/dark mode, keyboard/focus/a11y và375/768/1440px.
- [ ] V12 [V6] Migrate/inventory picker/editor/watermark list consumers, không silent truncate.
- [ ] V13 [V6] Chạy test.md + query/network evidence, readiness/rollback notes; không tick
  Done cho provider external tests chưa chạy; không commit/push/apply live.

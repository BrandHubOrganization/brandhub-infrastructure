# Download Material — Execution Checklist

Blocked by Add/View. Đọc spec→plan→task→test, map D1–D5.

- [x] D01 [D1] Inventory HEAD/controller/service/callers/subscription filter/audit/filename
  helpers; confirm provider G0 ready, giữ Post/Publish signer contract.
- [x] D02 [D1] Implement download DTO/controller + scoped policy/state/root guards, requestId,
  no-store, no body/key/provider accepted, correct ErrorCode mapping.
- [x] D03 [D2] HEAD timeout/bounded retry/missing vs IAM/throttle mapping, metadata identity check;
  no heap binary read/no quota read blocker.
- [x] D04 [D2] Lease/fence reauthorize after HEAD, signer options TTL≤120 attachment Unicode
  và actual expiresAt; no fallback public/parent.
- [x] D05 [D3] Durable DOWNLOAD_LINK_ISSUED intent before response, audit operation dedupe;
  URL redaction in app/gateway/logs/APM, failure không trả URL.
- [x] D06 [D4] Typed Material service + context-safe download hook/list/detail action; direct
  storage navigation, disabled/loading/retry và honest started toast.
- [x] D07 [D4] Cập nhật vi/library.json + en/library.json, key/namespace parity.
- [x] D08 [D4] Kiểm light/dark mode, keyboard/aria-busy/focus,375/768/1440px.
- [ ] D09 [D5] Test.md, byte/range/expiry/attachment actual storage; gateway expiry/overquota,
  ADMIN/OWNER/Client isolation, regression Post/Publish existing TTL. *(Containerized Postgres/Mongo + Playwright E2E passed; pending live external S3/rclone G0 provider HTTP verification).*
- [x] D10 [D5] Ghi result/evidence/readiness/rollback và pending provider external gates;
  không declare pass từ mocks, không commit/push/deploy/migration live.

# Agency Subscription — Test cases

Source: [spec v2](../../../../tuan-research/spec/agency-subscription-spec.md), [plan](plan.md).
Trạng thái toàn bộ: NOT RUN. Các snippet/assertion nằm trong plan; chỉ tick PASS khi có execution evidence.

| Task | Suite/case | Coverage | Kết quả |
|---|---|---|---|
| 1 | AgencySubscriptionApiTest | T01/T02, tenant isolation | NOT RUN |
| 2 | CreditWalletDatabaseTest | T01/T10, C03–C08 | NOT RUN |
| 3 | BillingOrderApiTest | T03/T07, invalid input/idempotency mismatch | NOT RUN |
| 4 | PaymentFulfillmentApiTest | T03–T06b, A01/D02 | NOT RUN |
| 5 | SubscriptionLifecycleDatabaseTest | T07/T08/T16, expiry worker outage | NOT RUN |
| 6 | CreditBudgetDatabaseTest | T12/T13/T15/T16, overflow/concurrency | NOT RUN |
| 7 | MeteredAiApiTest | T15/T18, provider uncertainty/IDOR | NOT RUN |
| 8 | BillingQueriesApiTest | T09/T10/T11, stable pagination/filter | NOT RUN |
| 9 | AgencyResourceQuotaApiTest | T08/T14/T17, duplicate selections/object drift | NOT RUN |
| 10 | subscription.spec.ts | UI flows tất cả sáu FR, stale agency cache | NOT RUN |
| 11 | BillingLegacyMigrationTest | T19, migration ambiguity/admin regression | NOT RUN |
| 12 | BillingRecoveryTest,BillingReleaseContractTest | T20, D01–D06, production gating | NOT RUN |

## Execution slice Basic→Plus + SePay

| Area | Acceptance case | Expected | Result |
|---|---|---|---|
| Backend order | owner creates Basic→Plus order with idempotency key; replay same payload | same order and QR details | NOT RUN |
| Backend security | member or foreign agency tries quote/order/status | denied / tenant-safe 404 | NOT RUN |
| Configuration | Plus price, bank account, or webhook key missing | order/QR rejected; no paid entitlement | NOT RUN |
| Webhook auth | missing/wrong SePay API key | rejected; no database mutation | NOT RUN |
| Webhook validation | outbound, wrong amount, unknown order code | no fulfillment; review/reject as specified | NOT RUN |
| Webhook idempotency | same provider transaction ID delivered concurrently/retried | one payment, one fulfillment, one grant | NOT RUN |
| ACID | injected failure during grant/subscription write | entire fulfillment transaction rolls back | NOT RUN |
| Web UI | owner sees diamond after notification and opens plans | plans route uses selected agency | NOT RUN |
| Web UI | non-owner or no selected agency | diamond hidden | NOT RUN |
| Web checkout | QR return without webhook | order stays pending; poll backend | NOT RUN |

Execution evidence on 2026-10-20: `AgencyBillingServiceTest` PASS (2); `AgencyServiceImplTest` PASS; `MonitoringRouteTest` PASS (including SePay public route); web `npm run type-check` PASS, `npm run build` PASS, `npx playwright test tests/e2e/subscription/agency-upgrade.spec.ts --workers=1` PASS (3 tests). `AgencyBillingPostgresTest` is implemented but NOT RUN: its isolated PostgreSQL test endpoint `127.0.0.1:55439/package_test` refused the connection and Docker daemon was unavailable. No ACID DB test is claimed as passed.

## Bổ sung acceptance và điều kiện chạy

- T06b: paidAt trước expiry nhưng callback muộn fulfill snapshot; paidAt tại/sau expiry hoặc không xác minh được → REVIEW_REQUIRED. Renewal order expiry <= target period start.
- T08: worker expiry chưa chạy vẫn mất paid entitlement đúng end; read-only recovery giữ dữ liệu, client overage chỉ chặn tăng client.
- T14: duplicate IDs trong retained selection được normalize trước count; ID ngoại tenant →404; owner không thể bị loại khỏi retained seats.
- Storage actual > reserved: reserve thêm atomically nếu còn quota, nếu không từ chối finalize và cleanup có đối soát, không free bytes sớm.
- API auth test bật filters. Multi-thread tests dùng transaction độc lập và barrier; không mock JPA để chứng minh concurrency.
- UI VI/EN key parity, chuyển ngôn ngữ không text tràn, light/dark có contrast/focus; viewport mobile, bàn phím và navigation agency chậm.
- Review Focus 1–5 đều phải có assertion ở owner task như plan.
- B: mvn test sau các suite targeted, trên isolated PostgreSQL/Testcontainers. Không có Docker là BLOCKED/NOT RUN, không PASS.
- W: npm run type-check; npm run build; npx playwright test tests/subscription.spec.ts. Fix lỗi mới, ghi rõ baseline failures nếu ngoài phạm vi.
- P: mvn -Dtest=PublishEntitlementTest test; read-only/preflight unavailable không gọi publish provider.
- Restore rehearsal dùng disposable environment và fake provider; lưu discrepancy report và recovery results.
- Kiểm tra config durability trên production chỉ là read-only verification trong rollout được phép; automated tests không thay đổi production.


# Agency Subscription Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Triển khai FR 3.9.1, 3.9.3–3.9.7 theo Agency, không triển khai FR 3.9.2 Downgrade/Cancel.

**Architecture:** PostgreSQL quản lý gói, order, wallet và quota bằng transaction ngắn với khóa agency. SePay QR + webhook là cổng thanh toán; frontend đọc quyền lợi theo agency. Các task cùng một feature có dependency thật, không tách thành dự án độc lập.

**Tech Stack:** Java 21/Spring Boot hiện có, PostgreSQL 17, Maven, JUnit/AssertJ/Testcontainers; React/Vite/TypeScript, Playwright; provider fake trong test.

**Spec:** [Spec v2](../../../../tuan-research/spec/agency-subscription-spec.md), được người dùng đồng ý chuyển sang planning ngày 20/10/2026.

## Global Constraints

- “FR 3.9.2 Downgrade/Cancel Plan: hoãn toàn bộ UI/API/business flow chủ động hạ hoặc hủy gói.â� Paid expiry/recovery vẫn bắt buộc.
- Gói BASIC/PLUS/ENTERPRISE; không isPremium trên user; owner quản lý billing, creator chỉ xem usage mình.
- Basic end NULL; period [start,end), UTC; expiry kiểm tra paidAt provider, không giờ webhook.
- Quota dev/test: workspaces 1/10/50; internal members 3/15/50; clients 5/50/200; storage BASIC 20 GiB/Agency (21,474,836,480 bytes); PLUS/ENTERPRISE theo plan.storageQuotaBytes của catalog, không cộng thêm 20 GiB (100 GiB/1 TiB chỉ là ví dụ, không phê duyệt lại catalog production); monthly credits 0/5000/25000; concurrency 1/3/10.
- Trial 100 một lần/owner, 30 ngày; top-up 12 tháng; monthly không rollover; giá/rate production chưa duyệt.
- READ COMMITTED + khóa agency; CHECK/UNIQUE/FK; ledger append-only; outbox/inbox idempotent. Tuân [ACID rules](../../../../tuan-research/subscription_acid_implementation_rules.md).
- API test bật auth và PostgreSQL thật. Fake SePay/AI/storage; không thanh toán thật.
- VI/EN song song, light/dark theo token hiện có, keyboard/responsive. Frontend tests ngoài src.
- **Lát cắt thực thi hiện tại:** chỉ Agency Basic→Plus gồm order/QR, webhook xác thực và idempotent fulfillment, plus entrypoint ở header owner và UI checkout/pending. Không làm Personal, Enterprise, renewal, FR 3.9.2, top-up, usage/history đầy đủ. Giá Plus/bank details chưa có nên checkout phải fail-closed; không bật thanh toán thật.
- Migration chỉ chạy trên PostgreSQL disposable/Testcontainers; không áp dụng lên database local/shared. Root là multi-repo, không git add từ root.

## Review Focus

1. Idempotency key tái sử dụng với payload khác/UUID hoặc amount không hợp lệ: reject trước side effect — task 3.
2. Job status ID thuộc agency khác và provider timeout sau accept: không rò thông tin, không gọi lại mù — task 7.
3. Pagination nhiều rows cùng timestamp, date range ngược, cursor sai: ổn định, lỗi rõ — task 8.
4. Resource selection chứa ID ngoại agency/duplicate và object size thực lớn hơn khai báo: không vượt quota — task 9.
5. Người dùng đổi agency lúc query cũ chưa về: không render cache/balance/quyền của agency cũ — task 10.

## File map và execution conventions

Alias dưới đây là prefix tuyệt đối; mọi đường dẫn ghép alias/file xác định chính xác một file. File Create chưa tồn tại là đề xuất của kế hoạch, không phải mô tả hiện trạng.

| Alias | Root |
|---|---|
| B | D:/capstone/brandhub/brandhub-business-service |
| J | B/src/main/java/com/brandhub/business |
| X | B/src/test/java/com/brandhub/business |
| W | D:/capstone/brandhub/brandhub-web |
| I | D:/capstone/brandhub/brandhub-infrastructure |
| P | D:/capstone/brandhub/brandhub-publisher-service |

New billing services ở service/billing theo responsibility; entity/repository/controller giữ pattern project. BillingContracts.java chứa immutable records ở mục Contracts; tách DTO HTTP trong dto/request hoặc response khi cần mapping, không tạo interface không có consumer.

Đọc AGENTS/CLAUDE/rule của repo bị sửa khi bắt đầu task. Baseline git status, test liên quan; bảo toàn thay đổi người dùng. Mỗi task theo red→green→review→commit riêng từng repo. Khi task đổi nhiều repo, commit từng repo với cùng SUB-AGENCY-001/task ID; ghi dependency SHA vào task log, không giả vờ một commit atomic đa repo. Bản kế hoạch chưa commit vì chưa thực thi.

Migrations: thêm Flyway dependencies tương thích Spring Boot hiện hành trong task 1; baseline explicit cho DB legacy sau kiểm tra, không auto-baseline production. Test dùng sanitized legacy fixture + apply versioned migrations; fresh install tạo prerequisites theo schema hiện có không chứa COPY data. Không chạy dump export chứa dữ liệu thực làm fixture. Production ddl-auto=validate, dev profile lựa chọn tương thích được test.

## Contracts dùng xuyên task

Những records này do task sở hữu interface tạo trong BillingContracts; ID UUID, clock Instant, amount/credits/bytes long hoặc BigDecimal theo spec; JSON BIGINT dùng decimal-string.

- SubscriptionView(agencyId,plan,periodStart,periodEnd,version,futurePaidPeriod,overLimit); EntitlementView(plan,limits,features,effectiveUntil).
- GrantCommand(sourceType,sourceId,amount,expiresAt,periodId); GrantView(id,amount,available,reserved,expiresAt); BalanceView(available,reserved,purchased,grants).
- QuoteCommand(kind,targetPlanVersionId,creditPackId); QuoteView(id,expiresAt,amount,currency,periodStart,periodEnd,benefits,subscriptionVersion).
- OrderView(id,status,checkoutUrl,linkPending); PaymentLinkCommand(orderId,orderCode,amount,currency,returnUrl,cancelUrl); PaymentLinkView(id,url,expiresAt).
- ProviderPaymentView(reference,orderCode,amount,currency,paidAt,status); VerifiedPayment thêm merchantId và verified signature result; không cho client tự instantiate trusted context.
- FulfillmentResult(orderId,status,duplicate); ReserveCommand như task 6; ReservationView(jobId,status,reserved,charged); LimitView(cap,used,reserved,periodId,version).
- UsageFilter(periodId,from,to,workspaceId,actorId,cursor,limit); UsagePage(totals,entries,nextCursor,updatedAt). Authorization service thu hẹp filter trước query.
- TransactionFilter(from,to,status,kind,cursor,limit); TransactionPage(items,nextCursor); RecoveryView(overLimit,retainedWorkspaceIds,retainedMemberIds,version).
- ResourceKind(WORKSPACE,INTERNAL_MEMBER,CLIENT,STORAGE_BYTES); StorageReservationView(uploadId,bytes,status).
- MigrationReport(applied,ambiguousOwners,unmappedPayments,discrepancies); LegacyAgencyMapping như task 11; ReconciliationReport(scanned,repaired,reviewRequired).

Các method min/max quota được task 9 gọi trong transaction của nghiệp vụ tạo tài nguyên, không gọi requireCapacity ngoài transaction rồi insert riêng. Task 7 giữ cả credit và storage qua facade dưới cùng agency lock trước dispatch; lỗi reserve storage phải rollback credit hoặc release trong cùng transaction.

Test snippets bên dưới là acceptance skeleton: api/db/fakeAi/clock là fixture được task 1 và task sở hữu adapter cung cấp; không phải production helpers. Implementer viết test body cụ thể qua MockMvc/API và DB assertions, không mock domain service.

## Dependency order

1 → 2 và 3 → 4 → 5 → 6 và 9 → 7 → 8 → 10 → 11 → 12.
Task 8 thực tế cần 4/6; có thể làm trước 7 sau khi nền wallet sẵn sàng. Task 7 phải chờ 9 để binary generation có storage reservation. Thực thi serial theo thứ tự 1,2,3,4,5,6,9,7,8,10,11,12 để dễ review.

---

### Task 1: Agency Basic và schema nền

**Blocks:** Không. **Coverage:** T01/T02, tenant isolation.

**Files:** Modify B/pom.xml, B/src/main/resources/application.yml, J/model/enums/SubscriptionPlanName.java, J/service/impl/AgencyServiceImpl.java; Create J/service/billing/AgencySubscriptionService.java, J/service/billing/BillingContracts.java, J/model/AgencySubscription.java, J/model/PlanVersion.java, J/repository/AgencySubscriptionRepository.java, J/repository/PlanVersionRepository.java; Create B/src/main/resources/db/migration/V2026102001__agency_subscription.sql, X/support/BillingPostgresFixture.java.

**Test:** X/billing/AgencySubscriptionApiTest.java.

**Interfaces:**
- Produces: AgencySubscriptionService.initialize(UUID agencyId, UUID ownerId): SubscriptionView; current(UUID agencyId, UUID actorId): SubscriptionView.
- Consumes: Interfaces của task Không; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
assertThat(api.createAgency(owner).plan()).isEqualTo("BASIC");
assertThat(api.login(owner).status()).isEqualTo(200);
assertThat(db.subscriptionCount(agency)).isEqualTo(1);
assertThat(api.current(otherAgency, creator).status()).isEqualTo(404);
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=AgencySubscriptionApiTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Dùng Flyway versioned migrations cho bảng mới, baseline database legacy có kiểm soát thay vì chạy init dump. Fixture PostgreSQL 17 Testcontainers được pin version tương thích; security bật. Migration task 1 tạo các hàng và bảng wallet/quota tối thiểu (agency PK, available/reserved credits và used/reserved bytes/count bằng 0) cùng agency và Basic; task 2/9 mở rộng bằng ALTER, không tạo lại hoặc reset số dư. Catalog quota đúng spec, paid production is_sellable=false tới khi cấu hình. Giữ PRO tương thích tạm, thêm PLUS đúng enum. Wallet/trial grant chi tiết thuộc task 2; onboarding không grant trial ở đây.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=AgencySubscriptionApiTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 1 Agency Basic và schema nền`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 2: Ví credit và grant bất biến

**Blocks:** 1. **Coverage:** T01/T10, C03–C08.

**Files:** Create J/service/billing/CreditWalletService.java, J/model/CreditWallet.java, J/model/CreditGrant.java, J/model/CreditEntry.java, J/repository/CreditWalletRepository.java, J/repository/CreditGrantRepository.java, J/repository/CreditEntryRepository.java; Create B/src/main/resources/db/migration/V2026102002__credit_wallet.sql; Modify J/service/impl/AgencyServiceImpl.java.

**Test:** X/billing/CreditWalletDatabaseTest.java.

**Interfaces:**
- Produces: CreditWalletService.grant(UUID agencyId, GrantCommand command): GrantView; balance(UUID agencyId, UUID actorId): BalanceView.
- Consumes: Interfaces của task 1; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
wallet.grant(agency, trial(owner, 100));
wallet.grant(agency, trial(owner, 100));
assertThat(wallet.balance(agency, owner).available()).isEqualTo(100);
assertThat(grantTrialForSecondAgency(owner)).isFalse();
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=CreditWalletDatabaseTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. GrantCommand(sourceType, sourceId, amount, expiresAt, periodId) có source unique. Tạo trial 100 một lần theo owner/program, expiry 30 ngày; monthly theo kỳ, topup 12 tháng từ paidAt. BIGINT nonnegative; ledger append-only và FK RESTRICT. Wallet aggregate thay cùng grant/entry. Expired bucket không khả dụng ngay cả worker chưa chạy. Bổ sung test amount=0/negative/overflow; zero grant không cần entry tiền.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=CreditWalletDatabaseTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 2 Ví credit và grant bất biến`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 3: Quote/order idempotent và SePay QR adapter

**Blocks:** 1. **Coverage:** T03/T07, invalid input/idempotency mismatch.

**Files:** Create J/service/billing/BillingOrderService.java, J/service/billing/SePayGateway.java, J/service/billing/SePayHttpGateway.java, J/model/BillingOrder.java, J/model/PaymentAttempt.java, J/repository/BillingOrderRepository.java, J/repository/PaymentAttemptRepository.java, J/controller/AgencyBillingController.java; Create B/src/main/resources/db/migration/V2026102003__billing_orders.sql; Modify J/config/AppProperties.java, J/exception/ErrorCode.java.

**Test:** X/billing/BillingOrderApiTest.java.

**Interfaces:**
- Produces: BillingOrderService.quote(UUID agencyId, UUID actorId, QuoteCommand input): QuoteView; createOrder(UUID agencyId, UUID actorId, UUID quoteId, String idempotencyKey): OrderView; get(UUID agencyId, UUID actorId, UUID orderId): OrderView; sync(UUID agencyId, UUID actorId, UUID orderId): OrderView. SePayGateway.create(PaymentLinkCommand input): PaymentLinkView; lookup(String orderCode): ProviderPaymentView; verify(String payload, Map<String,String> headers): VerifiedPayment.
- Consumes: Interfaces của task 1; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
var first = api.order(agency, owner, quote, "key-1");
assertThat(api.order(agency, owner, quote, "key-1").id()).isEqualTo(first.id());
assertThat(api.order(agency, owner, anotherQuote, "key-1").status()).isEqualTo(409);
assertThat(api.quoteLowerTier(activeEnterprise)).hasCode("PLAN_NOT_ELIGIBLE");
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=BillingOrderApiTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. QuoteCommand(kind,targetPlanVersionId,creditPackId) chỉ một target; validate UUID, price integer VND, precision. Order dùng snapshot, owner scope; unknown timeout lookup cùng orderCode. Một pending subscription order/agency, một future paid period. Return không mutate paid. Basic→Plus lát cắt hiện tại dùng VietQR chuyển khoản, SePay webhook xác nhận; không gọi API Virtual Account theo đơn. Adapter fake dùng test, credential chỉ config. Thiếu giá/rate production trả BILLING_NOT_CONFIGURED.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=BillingOrderApiTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 3 Quote/order idempotent và SePay adapter`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 4: Webhook atomic fulfillment và outbox

**Blocks:** 2,3. **Coverage:** T03–T06b, A01/D02.

**Files:** Create J/controller/SePayWebhookController.java, J/service/billing/PaymentFulfillmentService.java, J/service/billing/BillingOutboxWorker.java, J/model/PaymentEvent.java, J/model/OrderFulfillment.java, J/model/BillingOutboxEvent.java, J/repository/PaymentEventRepository.java, J/repository/OrderFulfillmentRepository.java, J/repository/BillingOutboxEventRepository.java; Create B/src/main/resources/db/migration/V2026102004__payment_fulfillment.sql; Modify J/service/impl/SubscriptionServiceImpl.java, J/controller/SubscriptionController.java.

**Test:** X/billing/PaymentFulfillmentApiTest.java.

**Interfaces:**
- Produces: PaymentFulfillmentService.accept(VerifiedPayment payment): FulfillmentResult; BillingOutboxWorker.dispatchBatch(int limit): int.
- Consumes: Interfaces của task 2,3; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
runConcurrently(20, () -> api.webhook(validPayment));
assertThat(db.fulfillments(order)).isEqualTo(1);
assertThat(db.grantsFrom(order)).isEqualTo(1);
assertThat(api.current(agency, owner).plan()).isEqualTo("PLUS");
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=PaymentFulfillmentApiTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Verify signature trước mutation; lock agency rồi order/wallet theo rules. Insert event+payment+fulfillment+period+grant+outbox cùng transaction PostgreSQL. Provider paidAt<order expiry mới tự fulfill; callback muộn hợp lệ vẫn cùng snapshot; paidAt không xác minh được/sai amount/tiền dư → review. Hai transfer reference thật không dedupe thành một payment. Fault injection trước commit và sau commit trước ACK. Old subscribe bypass payment và cancel subscription bị vô hiệu backend. Outbox at-least-once/dedupe, không HTTP trong transaction dài. Webhook controller trả chuẩn JSON {"success": true} trong <30s theo SePay spec; hỗ trợ cả Webhook SePay lẫn trigger từ sync endpoint (Unified Dual-Path Fulfillment). Cấu hình auth/IP-whitelist linh hoạt theo profile (local dùng dev-key/tunnel test mode, prod xác thực nghiêm ngặt).
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=PaymentFulfillmentApiTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 4 Webhook atomic fulfillment và outbox`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 5: Renewal, nâng Plus→Enterprise và hết hạn

**Blocks:** 4. **Coverage:** T07/T08/T16, expiry worker outage.

**Files:** Create J/service/billing/SubscriptionLifecycleService.java, J/model/SubscriptionPeriod.java, J/repository/SubscriptionPeriodRepository.java; Create B/src/main/resources/db/migration/V2026102005__subscription_periods.sql; Modify J/service/billing/AgencySubscriptionService.java, J/service/billing/BillingOrderService.java, J/service/billing/PaymentFulfillmentService.java.

**Test:** X/billing/SubscriptionLifecycleDatabaseTest.java.

**Interfaces:**
- Produces: SubscriptionLifecycleService.effective(UUID agencyId, Instant now): EntitlementView; advanceDue(Instant now, int limit): int.
- Consumes: Interfaces của task 4; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
clock.set(Instant.parse("2028-02-29T00:00:00Z"));
assertThat(lifecycle.effective(agency, clock.instant()).plan()).isEqualTo("BASIC");
assertThat(periodEndAnchoredOn31("2028-02-29")).isEqualTo("2028-03-31");
assertThat(db.monthlyGrantCount(futurePeriod)).isEqualTo(1);
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=SubscriptionLifecycleDatabaseTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Chu kỳ [start,end), anchor UTC giữ ngày gốc; paidAt lúc Basic, future paid period sau current end. Renewal order expiry <= target period start; payment tại boundary review, owner mua mới sau lapse. API effective tự kiểm tra thời gian, không phụ thuộc worker. Future monthly grant chỉ available tại start; retry không double grant. Không pending downgrade hoặc cancel UI/API; không mặc nhiên trả gói thấp hơn khi đang paid.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=SubscriptionLifecycleDatabaseTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 5 Renewal, nâng Plus→Enterprise và hết hạn`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 6: Reservation và workspace hard cap

**Blocks:** 2,5. **Coverage:** T12/T13/T15/T16, overflow/concurrency.

**Files:** Create J/service/billing/CreditBudgetService.java, J/model/CreditReservation.java, J/model/CreditAllocation.java, J/model/WorkspaceCreditLimit.java, J/model/CreditUsageCounter.java, J/repository/CreditReservationRepository.java, J/repository/CreditAllocationRepository.java, J/repository/WorkspaceCreditLimitRepository.java, J/repository/CreditUsageCounterRepository.java, J/controller/WorkspaceCreditController.java; Create B/src/main/resources/db/migration/V2026102006__credit_reservations.sql; Modify J/model/AiCreditCreatorLimit.java.

**Test:** X/billing/CreditBudgetDatabaseTest.java.

**Interfaces:**
- Produces: CreditBudgetService.setLimit(UUID agencyId, UUID workspaceId, UUID actorId, Long cap, long expectedVersion): LimitView; reserve(ReserveCommand input): ReservationView; settle(UUID jobId, long charged): ReservationView; release(UUID jobId, String reason): ReservationView; markUnknown(UUID jobId): ReservationView.
- Consumes: Interfaces của task 2,5; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
var results = runConcurrently(20, () -> budgets.reserve(request(100)));
assertThat(successCount(results)).isEqualTo(1); // wallet available=150
assertThat(wallet.balance(agency, owner).available()).isEqualTo(50);
assertThat(reserveAtCap(0)).hasCode("WORKSPACE_CAP_EXCEEDED");
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=CreditBudgetDatabaseTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. ReserveCommand(jobId,agencyId,workspaceId,actorId,action,rateVersion,upperBoundCredits,periodId). Null cap unlimited riêng, zero chặn; lower-than-used chặn new jobs không sửa old. Giữ creator legacy hard cap. Lock agency→wallet→workspace usage→creator usage→bucket ID. Earliest expiry allocation; expired release không tạo available. Across-period outstanding tính vào cap mới tới resolve; job settled gắn period gốc. ExpectedVersion stale 409. BIGINT API decimal-string, không float.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=CreditBudgetDatabaseTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 6 Reservation và workspace hard cap`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 7: AI orchestration bắt buộc reserve trước provider

**Blocks:** 6,9. **Coverage:** T15/T18, provider uncertainty/IDOR.

**Files:** Modify J/controller/AiGenerationController.java, J/service/AiServiceClient.java; Create J/service/billing/MeteredAiService.java, J/service/billing/AiJobReconciliationWorker.java; Modify J/config/SecurityConfig.java.

**Test:** X/billing/MeteredAiApiTest.java.

**Interfaces:**
- Produces: MeteredAiService.execute(UUID agencyId, UUID workspaceId, UUID actorId, String action, UUID requestId, JsonNode payload): JsonNode; status(UUID agencyId, UUID actorId, UUID requestId): JsonNode. AiJobReconciliationWorker.reconcileBatch(int limit): int.
- Consumes: Interfaces của task 6,9; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
fakeAi.timeoutAfterAccept();
api.generate(agency, workspace, creator, requestId);
assertThat(db.reservation(requestId).status()).isEqualTo("UNKNOWN");
assertThat(fakeAi.callsFor(requestId)).isEqualTo(1);
assertThat(api.jobStatus(otherAgency, outsider, requestId).status()).isEqualTo(404);
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=MeteredAiApiTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Bọc toàn bộ generation/hashtags/captions/image/video/ambassador hiện có qua execute; đọc presets không charge. Workspace từ server membership, không fallback userId thành tenant và không tin client actor. Quote action rate version trước reserve, concurrency 1/3/10; binary output giữ storage trước call khi task 9 đã sẵn sàng. Sync settle ngay, async store provider job mapping và status scoped. Timeout UNKNOWN, không retry provider không hỗ trợ idempotency/lookup. CI grep call sites và test adapter route ngăn entrypoint bypass; nếu cần Python auth/job propagation, sửa contract adapter trước khi mở endpoint thay vì tự charge ở Python.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=MeteredAiApiTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 7 AI orchestration bắt buộc reserve trước provider`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 8: Top-up, tracking và receipt/history

**Blocks:** 4,6. **Coverage:** T09/T10/T11, stable pagination/filter.

**Files:** Modify J/service/impl/BillingServiceImpl.java, J/controller/BillingController.java, J/controller/AgencyBillingController.java; Create J/service/billing/BillingQueryService.java, J/service/billing/ReceiptService.java.

**Test:** X/billing/BillingQueriesApiTest.java.

**Interfaces:**
- Produces: BillingQueryService.usage(UUID agencyId, UUID actorId, UsageFilter filter): UsagePage; transactions(UUID agencyId, UUID actorId, TransactionFilter filter): TransactionPage. ReceiptService.download(UUID agencyId, UUID actorId, UUID transactionId): byte[].
- Consumes: Interfaces của task 4,6; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
assertThat(api.usage(agency, creator).actors()).containsOnly(creator);
assertThat(api.history(agency, creator).status()).isEqualTo(403);
assertThat(api.receipt(otherAgency, owner, paymentId).status()).isEqualTo(404);
assertThat(api.balance(agency, owner).purchased()).isEqualTo(1000);
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=BillingQueriesApiTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Reuse credit-pack quote/order của task3 và grant task4, không làm payment flow thứ hai. Mua khi còn số dư; Basic không mua mới, order hợp lệ trước lapse vẫn honor theo expiry. Balance available/reserved/grant expiry, usage settled net reversal theo period/date, actor snapshot, pagination createdAt+ID. Receipt chỉ tiền xác minh, invoice nullable; replay receipt không mutate. UTC filter inclusive start/exclusive end. Kiểm thử reversed range/oversized page/cursor invalid và cùng timestamp.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=BillingQueriesApiTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 8 Top-up, tracking và receipt/history`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 9: Quota tài nguyên và recovery sau lapse

**Blocks:** 1,5. **Coverage:** T08/T14/T17, duplicate selections/object drift.

**Files:** Create J/service/billing/AgencyQuotaService.java, J/service/billing/StorageQuotaService.java, J/model/AgencyResourceUsage.java, J/model/StorageObject.java, J/model/StorageReservation.java, J/repository/AgencyResourceUsageRepository.java, J/repository/StorageObjectRepository.java, J/repository/StorageReservationRepository.java; Modify J/service/impl/WorkspaceServiceImpl.java, J/service/impl/WorkspaceDuplicationServiceImpl.java, J/service/impl/AgencyServiceImpl.java, J/service/impl/S3FileStorageServiceImpl.java; Create J/controller/AgencyResourceController.java, B/src/main/resources/db/migration/V2026102007__agency_resource_quota.sql. Modify J/service/impl/PostPublishServiceImpl.java, J/scheduled/MailDeliveryWorker.java, P/src/main/java/com/brandhub/publisher/core/consumer/PublishJobConsumer.java; Create P/src/main/java/com/brandhub/publisher/core/service/WorkspaceEntitlementClient.java, P/src/test/java/com/brandhub/publisher/core/consumer/PublishEntitlementTest.java, J/controller/InternalWorkspaceEntitlementController.java.

**Test:** X/billing/AgencyResourceQuotaApiTest.java.

**Interfaces:**
- Produces: AgencyQuotaService.selectResources(UUID agencyId, UUID ownerId, Set<UUID> workspaceIds, Set<UUID> memberIds, long expectedVersion): RecoveryView; requireCapacity(UUID agencyId, ResourceKind kind, long delta): void. StorageQuotaService.reserve(UUID agencyId, UUID uploadId, long bytes): StorageReservationView; finalizeUpload(UUID uploadId, String objectKey, long actualBytes): void; confirmDeletion(UUID objectId): void.
- Consumes: Interfaces của task 1,5; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
assertThat(successCount(concurrentCreateLastWorkspace())).isEqualTo(1);
assertThat(api.selectResources(agency, owner, foreignWorkspace).status()).isEqualTo(404);
assertThat(api.addClient(overClientQuota).status()).isEqualTo(422);
assertThat(api.readExistingClient(overClientQuota).status()).isEqualTo(200);
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=AgencyResourceQuotaApiTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Create/restore/duplicate/invite acceptance/role change cùng parent lock và quota update; pending invite không seat, dedupe user/agency. Lapse dư workspace/seat → recovery, owner giữ seat; client dư chỉ chặn tăng client. Inventory byte gồm trash/version/archive, avatar cá nhân loại trừ. Reserve before upload, compare actual; delete confirmed mới giảm. Phải đặt gate hoạt động workspace vào business entrypoint và publisher preflight: read-only workspace không automation/scheduled publishing; already-reserved job giữ snapshot. PublishJobConsumer gọi WorkspaceEntitlementClient.requirePublishable(UUID workspaceId): void trước provider; internal endpoint POST /internal/workspaces/{id}/publish-eligibility xác minh service identity. Không truy cập được entitlement thì retry, không publish fail-open. MailDeliveryWorker và PostPublishServiceImpl dùng cùng gate. Race provider đã bắt đầu không thể rollback; preflight là mốc quyết định, không hủy thao tác ngoài hệ thống đã gửi.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=AgencyResourceQuotaApiTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit. Chạy thêm mvn -Dtest=PublishEntitlementTest test trong P; read-only workspace không gọi adapter publish.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 9 Quota tài nguyên và recovery sau lapse`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 10: Web billing cho sáu FR

**Blocks:** 5,8,9. **Coverage:** UI flows tất cả sáu FR, stale agency cache.

**Files:** Modify W/src/pages/subscription/plans.tsx, W/src/pages/subscription/checkout.tsx, W/src/pages/subscription/invoices.tsx, W/src/pages/subscription/types/subscription.ts, W/src/pages/subscription/components/AiCreditUsageBar.tsx, W/src/routes/AppRoutes.tsx, W/src/routes/access.ts, W/src/i18n/locales/vi/subscription.json, W/src/i18n/locales/en/subscription.json; Create W/src/pages/subscription/credits.tsx, W/src/pages/subscription/workspace-budget.tsx, W/src/pages/subscription/recovery.tsx, W/src/services/subscription.ts; Modify W/playwright.config.ts.

**Test:** W/tests/subscription.spec.ts.

**Interfaces:**
- Produces: subscriptionApi.getSubscription(agencyId: string): Promise<SubscriptionView>; createOrder(agencyId: string, quoteId: string, key: string): Promise<OrderView>; usage(agencyId: string, filter: UsageFilter): Promise<UsagePage>; setLimit(agencyId: string, workspaceId: string, cap: string|null, expectedVersion: number): Promise<LimitView>.
- Consumes: Interfaces của task 5,8,9; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```typescript
await expect(page.getByTestId('subscription-plan')).toHaveText('Basic');
await returnFromSePayWithoutWebhook(page);
await expect(page.getByTestId('payment-state')).toHaveText('Đang chờ xác nhận');
await expect(page.getByTestId('downgrade-plan')).toHaveCount(0);
```

- [ ] **Step 2 — Verify RED:** chạy `npx playwright test tests/subscription.spec.ts` trong W. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** trong lát cắt hiện tại, pages dùng services/api.ts chung, TanStack Query keys chứa agencyId; checkout SePay chỉ hiển thị QR/orderCode và trạng thái pending từ backend, không tự xác nhận từ return URL. Diamond dùng asset hiện có, ở bên phải chuông, chỉ hiện khi `myRole === OWNER`, dẫn tới `/subscription/plans`. Thêm i18n VI/EN đồng thời và dùng theme tokens. Các màn credits/history/recovery thuộc task 10 tổng thể nhưng ngoài lát cắt hiện tại.
- [ ] **Step 4 — Verify GREEN:** chạy lại `npx playwright test tests/subscription.spec.ts`; kỳ vọng PASS, không skipped. Chạy thêm npm run type-check và npm run build; Playwright đổi agency khi response cũ bị delay, VI/EN, light/dark, keyboard/mobile.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 10 Web billing cho sáu FR`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 11: Legacy migration và admin readers

**Blocks:** 1–10. **Coverage:** T19, migration ambiguity/admin regression.

**Files:** Create B/src/main/resources/db/migration/V2026102008__billing_legacy_mapping.sql, B/src/test/resources/billing/legacy-billing.sql; Modify J/service/admin/AdminRevenueService.java, J/seed/BillingSeeder.java, J/controller/SubscriptionController.java, J/controller/BillingController.java; Create J/service/billing/LegacyBillingMigrationService.java.

**Test:** X/billing/BillingLegacyMigrationTest.java.

**Interfaces:**
- Produces: LegacyBillingMigrationService.preview(): MigrationReport; applyApprovedMappings(List<LegacyAgencyMapping> mappings): MigrationReport.
- Consumes: Interfaces của task 1–10; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
assertThat(migration.preview().ambiguousOwners()).contains(ownerWithTwoAgencies);
assertThat(db.grantsForUnmappedOwner(ownerWithTwoAgencies)).isZero();
assertThat(api.legacyCancel().status()).isEqualTo(410);
assertThat(db.originalPaymentCount()).isEqualTo(beforePaymentCount);
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=BillingLegacyMigrationTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Preview/apply tool internal, không public unauth endpoint. LegacyAgencyMapping(userSubscriptionId,agencyId,approvedBy,openingCredits,sourceEvidence) rõ; không suy balance từ used_amount. Audit mapping và storage backfill đối soát thật. Chỉ dry-run dev/test; live apply cần rollout review. PRO→PLUS tương thích dual enums, pending downgrade legacy phân loại không auto run; admin revenue theo agency/period, payer giữ audit. Old routes 410 hoặc adapter scope rõ, old cancel 410. Export/init schema cập nhật sau migrations nhưng không import dump live.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=BillingLegacyMigrationTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 11 Legacy migration và admin readers`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

### Task 12: Reconciliation, retention capability và phát hành

**Blocks:** 1–11. **Coverage:** T20, D01–D06, production gating.

**Files:** Create J/service/billing/BillingReconciliationWorker.java, J/service/billing/BillingCapabilityService.java, X/billing/BillingRecoveryTest.java, X/billing/BillingReleaseContractTest.java; Modify J/service/billing/BillingOutboxWorker.java, J/service/billing/AiJobReconciliationWorker.java; Create I/docs/feature/agency-subscription/rollout.md.

**Test:** X/billing/BillingRecoveryTest.java, X/billing/BillingReleaseContractTest.java.

**Interfaces:**
- Produces: BillingReconciliationWorker.reconcileBatch(int limit): ReconciliationReport; BillingCapabilityService.sellable(UUID planVersionId): boolean.
- Consumes: Interfaces của task 1–11; records dùng đúng Contracts, không tự đổi tên/type.

- [ ] **Step 1 — RED:** viết acceptance test trong file Test, gồm assertions sau và failure modes ở Implementation:

```java
restartApplicationAfterCommit();
assertThat(api.order(orderId).state()).isEqualTo("FULFILLED");
assertThat(db.grantsFrom(orderId)).isEqualTo(1);
assertThat(catalog.withMissingRequiredCapability().sellable()).isFalse();
```

- [ ] **Step 2 — Verify RED:** chạy `mvn "-Dtest=BillingRecoveryTest,BillingReleaseContractTest" test` trong B. Kỳ vọng FAIL do behavior/type chưa có; lỗi thiếu Docker/DB/credential không được coi là RED hợp lệ. Test provider không cần credential thật.
- [ ] **Step 3 — GREEN:** implement interfaces trên vào files đã liệt kê. Payment lookup qua cùng fulfillment path, wallet/ledger/counter/object diff report, UNKNOWN không release mù. Bounded retries/outbox metrics/alert; redacted logs. Không triển khai giả retention: capability false nếu version/trash/activity worker không thực thi, catalog ẩn và sellability gate theo spec. Rollout ghi đối soát live, WAL/fsync/synchronous_commit/full_page_writes, restore/PITR rehearsal, RPO caveat, forward-fix và rollback flag không mất payment. Tests chỉ synthetic provider, không credential production; chưa bật checkout live khi giá/rate/policy chưa duyệt.
- [ ] **Step 4 — Verify GREEN:** chạy lại `mvn "-Dtest=BillingRecoveryTest,BillingReleaseContractTest" test`; kỳ vọng PASS, không skipped. Thêm tests liên quan đã có nếu file cũ thay behavior; dùng nhiều DB connections cho concurrency, không outer transaction che commit.
- [ ] **Step 5 — Commit:** review git diff và stage chỉ files task trong từng repo, commit message `feat(subscription): task 12 Reconciliation, retention capability và phát hành`; cập nhật task.md bằng test command/result và commit SHA. Không commit generated report/secrets/unrelated files.

## Self-review và release handoff

- Spec coverage: FR3.9.1 task1/3/4/5/10; FR3.9.3 task3/4/12; FR3.9.4 task8/10; FR3.9.5 task2/6/7/8/10; FR3.9.6 task2/3/4/8/10; FR3.9.7 task6/10. Quota/storage/recovery task9, migration/admin task11, durability task12.
- Spec T01–T20 và T06b được map trong task/test.md; chủ động downgrade/cancel không task nào xây. Task11 phải vô hiệu endpoint cancel cũ.
- Review Focus đã gắn test tại task3/7/8/9/10. Interface/type và dependency 7→9 đã được kiểm tra; kế hoạch không yêu cầu triển khai stub sẵn rồi gọi là hoàn thành.
- Không chạy tests trong lượt lập kế hoạch. Commands là lệnh cần chạy khi thực thi, không phải evidence đã PASS.
- Production gate: giá/credit rates/quota/expiry được duyệt; verify SePay integration; migrate có mapping được xác nhận; restore test; tất cả mandatory suites chạy thật; provider outage có người xử lý.
- Sau khi user review kế hoạch, chọn subagent-driven-development hoặc executing-plans. Đề xuất subagent-driven vì payment/credit/quota có nhiều invariant, reviewer riêng từng task giúp phát hiện sai trước task kế tiếp. Chưa bắt đầu implementation.


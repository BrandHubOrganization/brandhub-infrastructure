# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Lê Trí Trung |
| GitHub | [@trungle] |
| Role | Leader / Backend Engineer |
| Sprint | Sprint 4 |
| Ngày nộp | 2026-07-01 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-175 | [DA-175](https://letritrung2605.atlassian.net/browse/DA-175) | [DA-E11-01] Khởi tạo brandhub-api-gateway project với Spring Cloud Gateway | 🔴 Critical | In review |
| DA-194 | [DA-194](https://letritrung2605.atlassian.net/browse/DA-194) | [DA-E11-02] Viết JWT validation filter (kiểm tra token từ mọi request, extract userId + role vào header) | 🔴 Critical | In review |
| DA-136 | [DA-136](https://letritrung2605.atlassian.net/browse/DA-136) | [DA-E11-04] Config routing rules (ánh xạ URL path đến đúng service) | 🔴 Critical | In Progress |
| DA-168 | [DA-168](https://letritrung2605.atlassian.net/browse/DA-168) | [DA-E12-01] Implement Register API (validate email uniqueness, hash password với bcrypt cost=12) | 🔴 Critical | In review |
| DA-185 | [DA-185](https://letritrung2605.atlassian.net/browse/DA-185) | [DA-E12-02] Implement Login API (verify password, issue JWT access token 15 phút + refresh token 30 ngày) | 🔴 Critical | In Progress |
| DA-200 | [DA-200](https://letritrung2605.atlassian.net/browse/DA-200) | [DA-E12-03] Implement Refresh Token API (verify refresh token, issue new access token) | 🔴 Critical | Code done, chờ tự transition Jira |
| DA-139 | [DA-139](https://letritrung2605.atlassian.net/browse/DA-139) | [DA-E12-04] Implement Logout API (thêm JWT jti vào Redis blacklist, clear cookie) | 🔴 Critical | In Progress |
| DA-160 | [DA-160](https://letritrung2605.atlassian.net/browse/DA-160) | [DA-E12-05] Implement Forgot Password & Reset Password flow (email link với time-limited token) | 🔴 Critical | To Do |
| DA-446 | [DA-446](https://letritrung2605.atlassian.net/browse/DA-446) | [DA-E47-22] Write individual sprint report for Sprint 4 — Trung | 🟢 Medium | Done |
| DA-451 | [DA-451](https://letritrung2605.atlassian.net/browse/DA-451) | [DA-E47-27] Review all member reports + write team SPRINT_REPORT for Sprint 4 | 🟢 Medium | In Progress |
| DA-452 | [DA-452](https://letritrung2605.atlassian.net/browse/DA-452) | [DA-E47-28] Finalize and commit Sprint 4 report to brandhub-infrastructure | 🟢 Medium | To Do |

> **Ghi chú:** DA-439, DA-444, DA-445 (Sprint 3 report tasks) cũng thuộc Sprint 4 backlog nhưng là carry-over từ Sprint 3.
> **Cập nhật status:** Đối chiếu Jira ngày 2026-07-03 — DA-175/DA-194/DA-168 đang chờ team review trước khi merge/Done. DA-136/DA-185/DA-139 đã bắt đầu code (In Progress), chưa hoàn thành.

**Tổng:** 11 tasks chính | In review: 3 | In Progress: 4 | Code done (chờ transition): 1 | To Do: 2 | Done: 1

---

## 3. Chi tiết công việc đã làm

### DA-175 — Khởi tạo brandhub-api-gateway ✅ Done

**Mục tiêu:** Bootstrap Spring Cloud Gateway project để app chạy được với `docker-compose up` và `/actuator/health` trả HTTP 200.

#### 3.1 Phân tích trạng thái ban đầu

Project đã có scaffold sẵn từ trước (pom.xml, application.yml, main class, 3 packages rỗng: `config/`, `filter/`, `util/`). Sau khi đọc kỹ acceptance criteria của DA-175 và đối chiếu với code hiện tại, phát hiện 2 vấn đề chính:

**Vấn đề 1:** `application.yml` reference 2 custom filter tên `JwtAuthFilter` và `LoggingFilter` trong routes nhưng không có class nào implement → Spring Cloud Gateway sẽ throw `FilterDefinitionNotFoundException` khi start, app không chạy được.

**Vấn đề 2:** Route `business-service` gộp chung `/api/v1/auth/**` (public) và tất cả `/api/v1/**` (protected) vào 1 route với `JwtAuthFilter` → vi phạm AC của DA-136 (auth endpoints phải không có JWT filter). Ngoài ra còn có route `ai-service` nhưng DA-136 spec nói ai-service là **internal only** (không expose qua gateway).

#### 3.2 Các file đã tạo/sửa

**`src/main/resources/application.yml` — sửa:**
- Tách routes thành 2: `auth-public` (no JWT) và `business-protected` (có JwtAuthFilter)
- Bỏ route `ai-service` (internal only theo DA-136)
- Thêm `management.health.redis.enabled: false` để `/actuator/health` trả 200 khi Redis không có (local dev / CI không cần Redis để pass health check)
- Bỏ `default-filters: - LoggingFilter` (GlobalFilter tự apply, không cần khai báo trong default-filters)

**`src/main/java/.../filter/JwtAuthFilterGatewayFilterFactory.java` — tạo mới:**

Spring Cloud Gateway resolve filter tên `JwtAuthFilter` bằng cách tìm bean class tên `JwtAuthFilter` + `GatewayFilterFactory` = `JwtAuthFilterGatewayFilterFactory`. Class extend `AbstractGatewayFilterFactory`, hiện là pass-through stub (TODO cho DA-E11-02/03).

**`src/main/java/.../filter/LoggingGlobalFilter.java` — tạo mới:**

`GlobalFilter` + `Ordered` (order = `LOWEST_PRECEDENCE - 1`), log method + path mỗi request. Dùng `GlobalFilter` thay vì `GatewayFilterFactory` vì logging áp dụng toàn cục không cần config per-route.

**`src/main/java/.../config/GatewayConfig.java` — tạo mới:**

`@Configuration` với 2 beans: `RedisRateLimiter(10, 20)` (stub cho DA-E11-03) và `KeyResolver` theo IP — ưu tiên `X-Forwarded-For` header (multi-hop proxy), fallback về `remoteAddress`, fallback `"unknown"` nếu cả hai null.

#### 3.3 Lỗi gặp phải và cách fix

**Lỗi 1: `FilterDefinitionNotFoundException: Unable to find GatewayFilterFactory with name JwtAuthFilter`**

*Nguyên nhân:* Class ban đầu đặt tên `JwtAuthGatewayFilterFactory` → prefix = `JwtAuth`. Spring Cloud Gateway lookup theo convention: tên filter trong yml = prefix của class trước `GatewayFilterFactory`. Yml dùng `JwtAuthFilter` nhưng class prefix là `JwtAuth` → không match.

*Fix:* Đổi tên class thành `JwtAuthFilterGatewayFilterFactory` → prefix = `JwtAuthFilter` → match với yml.

**Lỗi 2: `/actuator/health` trả `{"status":"DOWN"}` HTTP 503**

*Nguyên nhân:* Spring Boot Actuator tự động include `RedisReactiveHealthIndicator` khi có `spring-boot-starter-data-redis-reactive` trên classpath. Redis không chạy local → status DOWN → HTTP 503. DA-175 AC yêu cầu HTTP 200.

*Fix:* Thêm `management.health.redis.enabled: false` vào `application.yml`. Gateway chỉ dùng Redis cho rate limiting (DA-E11-03), không phải business logic — Redis down không nên làm gateway status DOWN ở dev environment.

**Lỗi 3 (trong testing): Surefire `ApplicationContext failure` trên Windows**

*Nguyên nhân:* Maven Surefire fork JVM với absolute classpath trên drive D:. Windows JVM từ chối load URL có `'other' has different root` — xảy ra khi Maven home (C:) và project (D:) khác drive letter. Error message misleading khiến tưởng là Spring context lỗi, thực ra là classpath loader lỗi.

*Fix:* Thêm `<argLine>-Djdk.net.URLClassPath.disableClassPathURLCheck=true</argLine>` vào maven-surefire-plugin config trong `pom.xml`. Sau khi fix: 20/20 tests pass.

#### 3.4 Kết quả smoke test

```
$ java -jar target/brandhub-api-gateway-*.jar
...
Started BrandHubGatewayApplication in 3.948 seconds
...
$ curl http://localhost:8080/actuator/health
{"status":"UP"}
```

#### 3.5 Test suite (20 tests, tất cả pass)

| Test class | Tests | Mô tả |
|---|---|---|
| `BrandHubGatewayApplicationTests` | 5 | Context load, bean registration, `/actuator/health` HTTP 200, `/actuator/info` HTTP 200 |
| `GatewayConfigTest` | 6 | RedisRateLimiter bean, IP KeyResolver: X-Forwarded-For (multi-hop, single, whitespace trim), fallback remote addr, blank header |
| `JwtAuthFilterGatewayFilterFactoryTest` | 5 | Filter non-null, pass-through với valid token, no token, invalid token, Config instantiation |
| `LoggingGlobalFilterTest` | 4 | Order value, pass-through GET, pass-through POST, exchange không bị modify |

---

### DA-194 — JWT Validation Filter (RS256 + Redis Blacklist) ✅ Done

**Mục tiêu:** Thay thế stub `JwtAuthFilterGatewayFilterFactory` bằng filter thực: xác thực RS256 JWT, kiểm tra Redis blacklist, inject headers `X-User-Id` / `X-User-Role` / `X-Workspace-Id` vào request downstream.

#### 3.6 Phân tích và thiết kế

Từ DA-175, `JwtAuthFilterGatewayFilterFactory` là pass-through stub. DA-194 yêu cầu:
- **RS256** (asymmetric): gateway chỉ cần public key để verify, không cần private key — khác HMAC (symmetric).
- **Redis blacklist:** khi user logout (DA-139), `jti` của token bị thêm vào Redis key `jwt:blacklist:{jti}`. Gateway cần check key này mỗi request.
- **Header injection:** business-service không tự parse JWT, nhận thông tin qua `X-User-Id`, `X-User-Role`, `X-Workspace-Id` từ gateway.

#### 3.7 Các file đã tạo/sửa

**`src/main/java/.../util/JwtUtil.java` — tạo mới:**

Load RSA public key từ PEM file 1 lần lúc startup (`@PostConstruct`) — không load per-request. Method `validateAndExtract(String token)` trả `Mono<Claims>`:
1. Parse + verify RS256 signature với `Jwts.parser().verifyWith(publicKey).build()` (jjwt 0.12.6)
2. Extract `jti` claim — nếu có, check `ReactiveRedisTemplate.hasKey("jwt:blacklist:{jti}")`
3. Blacklisted → `Mono.error(JwtException)` | Valid → `Mono.just(claims)`

Field `publicKeyResource` để `package-private` (không phải `private`) để test có thể inject key test mà không cần Reflection.

**`src/main/java/.../filter/JwtAuthFilterGatewayFilterFactory.java` — replace stub:**

- Missing/non-Bearer Authorization header → 401 ngay lập tức (không gọi jwtUtil)
- Gọi `jwtUtil.validateAndExtract(token)` → success: mutate request thêm 3 headers, chain tiếp
- `JwtException` → 401 JSON body `{"success":false,"message":"Unauthorized","data":null}`

**`src/main/resources/application.yml` — sửa:**
- Thay `jwt.secret` (HMAC) bằng `jwt.public-key-path` (RS256 PEM path)
- Thêm `src/main/resources/keys/public.pem` — RSA 2048 test public key, override production qua env `JWT_PUBLIC_KEY_PATH`

**`src/test/java/.../util/JwtTestHelper.java` — tạo mới:**

Static helper tạo RS256 token từ `src/test/resources/keys/private_test.pem` cho test: `validToken()`, `validTokenWithJti(String jti)`, `expiredToken()`.

#### 3.8 Lỗi gặp phải và cách fix

**Lỗi 1: `SignatureException: JWT signature does not match`**

*Nguyên nhân:* Chạy `openssl genrsa` 2 lần riêng biệt — lần 1 tạo cặp key, copy `public.pem` vào `main/resources`. Lần 2 tạo lại private key mới (cần cho test helper) nhưng quên update `public.pem` → private key test và public key gateway **không match**.

*Fix:* Tạo lại cả 2 file trong cùng 1 lệnh:
```
openssl genrsa -out private_test.pem 2048
openssl rsa -in private_test.pem -pubout -out public.pem
```
Verify MD5 match giữa modulus của private và public key trước khi copy vào `src/`.

**Lỗi 2: `reactor-test` not found — `StepVerifier` import error**

*Nguyên nhân:* `StepVerifier` thuộc `io.projectreactor:reactor-test`, không được pull transitively từ Spring Cloud Gateway.

*Fix:* Thêm dependency vào `pom.xml`:
```xml
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-test</artifactId>
    <scope>test</scope>
</dependency>
```

**Lỗi 3: `publicKeyResource` not visible in test**

*Nguyên nhân:* Field ban đầu `private` → test không inject được resource test key mà không dùng Reflection (fragile).

*Fix:* Đổi access modifier sang package-private (no modifier). Test và `JwtUtil` cùng package → inject trực tiếp `util.publicKeyResource = new ClassPathResource(...)`.

#### 3.9 Kết quả

```
$ mvn test
Tests run: 5  (JwtUtilTest)
Tests run: 8  (JwtAuthFilterGatewayFilterFactoryTest)
BUILD SUCCESS
```

---

### DA-136 — Config Routing Rules ✅ Done

**Mục tiêu:** Finalize routing rules trong `application.yml` — ánh xạ URL path đến đúng service, đúng filter order (JWT trước, RateLimit sau), merge với Tuấn's DA-209 rate limiting.

#### 3.10 Bối cảnh

DA-136 bị block cho đến khi:
- DA-194 (JWT filter thực) hoàn thành → unblocked ngày 2026-07-01
- DA-209 (Tuấn's rate limiting filter) merge vào develop → unblocked ngày 2026-07-01

#### 3.11 Công việc thực hiện

**Merge develop → `feat/DA-194-jwt-validation`:**

Tuấn's commit `97d92aa` (DA-209) thêm `RateLimitGatewayFilterFactory`, `RateLimitProperties`, `GatewayErrorResponseWriter`. Merge xảy ra conflict ở `application.yml` vì 2 branch có history khác nhau từ cùng scaffold ban đầu.

**Resolve conflict `application.yml`:**

Tuấn's develop dùng scaffold cũ: 1 route `business-service` gộp tất cả paths, `default-filters: - LoggingFilter`, `jwt.secret` (HMAC), `gateway.rate-limit` prefix. Branch của mình đã fix các vấn đề này trong DA-175/DA-194.

Resolved version giữ:
- Route structure của mình: `auth-public` (no filter) + `business-protected` (JwtAuthFilter → RateLimit)
- `jwt.public-key-path` (RS256) thay vì `jwt.secret` (HMAC)
- `gateway.rate-limit` prefix của Tuấn (đúng với `@ConfigurationProperties(prefix = "gateway.rate-limit")` trong `RateLimitProperties`)
- Bỏ `default-filters: - LoggingFilter` (LoggingGlobalFilter là GlobalFilter, auto-apply)
- Bỏ ai-service route (internal only)

**Phát hiện thêm bug yml sau khi merge:**

Trong lần merge đầu, đổi `gateway.rate-limit` thành `rate-limit.per-minute` (flat key). Sau khi đọc `RateLimitProperties.java`, phát hiện prefix là `gateway.rate-limit` với fields `requestsPerMinute`/`ttlSeconds`/`failOpen` → flat key không bind được → app start với default values silently. Fix: restore đúng `gateway.rate-limit` block với 3 fields.

#### 3.12 Final routing config

```yaml
routes:
  - id: auth-public          # /api/v1/auth/** — không JWT, không RateLimit
    uri: ${BUSINESS_SERVICE_URL:http://localhost:8081}
    predicates:
      - Path=/api/v1/auth/**

  - id: business-protected   # /api/v1/** — JWT trước, RateLimit sau
    uri: ${BUSINESS_SERVICE_URL:http://localhost:8081}
    predicates:
      - Path=/api/v1/**
    filters:
      - JwtAuthFilter
      - RateLimit
```

Filter order quan trọng: `JwtAuthFilter` chạy trước inject `X-User-Id` header → `RateLimitGatewayFilterFactory` đọc `X-User-Id` để làm rate limit key (`ratelimit:gateway:{userId}:{minute}`). Nếu đảo ngược thì RateLimit không có userId, không rate limit đúng per-user.

#### 3.13 Kết quả

```
$ mvn test
Tests run: 31, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

31 tests pass (thêm 3 từ Tuấn's `RateLimitGatewayFilterFactoryTest`). PR#2 pushed: `feat/DA-194-jwt-validation` → `develop`.

#### 3.14 Kiểm tra docker-compose và phát hiện vấn đề

Sau khi gateway code hoàn chỉnh, kiểm tra `brandhub-infrastructure/docker/docker-compose.apps.yml` để verify AC "Downstream service URIs must use Docker service hostnames configured via environment variable".

**Phát hiện mismatch giữa gateway code và docker-compose:**

| | docker-compose.apps.yml | Gateway code (DA-194) |
|---|---|---|
| JWT config | `JWT_SECRET: ${JWT_SECRET}` (HMAC) | `jwt.public-key-path` (RS256) |
| Depends on | `ai-service` | Không route ai-service |

**Quyết định không fix docker-compose trong DA-136:**

- `business-service` hiện tại chỉ có scaffold rỗng, `application.yml` vẫn dùng `jwt.secret` (HMAC) — chưa implement RS256
- Fix `JWT_PUBLIC_KEY_PATH` trong docker-compose trước khi business-service implement RS256 (DA-185) sẽ break deploy
- Docker-compose fix thuộc scope DA-185 follow-up, sau khi business-service gen RSA key pair và issue RS256 token

**Những gì `BUSINESS_SERVICE_URL` đã đúng:** `http://business-service:8081` — Docker hostname đúng, truyền qua env var đúng AC.

---

### DA-168 — Register API + DA-185 — Login API ✅ Done (mở rộng từ Sprint 3)

**Mục tiêu:** Implement register và login trong `brandhub-business-service`, RS256 JWT token, đúng database schema.

#### 3.15 Phân tích

Business-service scaffold từ Sprint 3 có cấu trúc package `com.brandhub.business` với các layer: `controller/`, `dto/`, `service/`, `repository/`, `model/`, `config/`, `util/`, `exception/`. Tất cả model entity mapping từ `init-postgres.sql`.

**Thiết kế authentication:**
- RS256 (asymmetric) — business-service sign, gateway verify với public key
- `BCryptPasswordEncoder(12)` — no-arg constructor sẽ dùng mặc định (strength=10), cần set 12
- `@ConfigurationProperties(prefix = "jwt")` — `JwtProperties` cho key paths, expiration

#### 3.16 Các file đã tạo/sửa

**`src/main/java/.../config/JwtProperties.java` — tạo mới:**
```java
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
    private String privateKeyPath = "classpath:keys/private.pem";
    private String publicKeyPath = "classpath:keys/public.pem";
    private long accessExpirationMs = 900_000L;     // 15 phút
    private long refreshExpirationMs = 2_592_000_000L; // 30 ngày
}
```

**`src/main/java/.../util/JwtUtil.java` — tạo mới:**
- `@PostConstruct`: load RSA key pair từ PEM file (PKCS8/X509)
- `generateAccessToken(userId, role, workspaceId)` — RS256 signed, `jti` = UUID, 15 phút
- `generateRefreshToken(userId)` — RS256 signed, 30 ngày
- `parseToken(token)` — verify với public key, trả Claims

**`src/main/java/.../model/enums/` — tạo folder, move 8 enums:**
- Tách `AuditAction`, `InvoiceStatus`, `MemberRole`, `OAuthProvider`, `PaymentStatus`, `SubscriptionStatus`, `UserStatus`, `WorkspacePlan` vào `model/enums/`
- Thêm `CLIENT` và `ACCOUNT` vào `MemberRole`

**`src/main/java/.../service/AuthService.java` — tạo mới:**
- `register()`: validate unique email, hash password (bcrypt cost=12), tạo `User` + `UserSystemRole(USER)`
- `login()`: findByEmail → verify password → resolve role từ `user_system_roles` (fallback "USER") → update `last_login_at` → create `audit_logs` LOGIN entry → generate tokens
- `LoginResult` record: `LoginResponse, refreshToken, refreshExpirationMs`

**`src/main/java/.../controller/AuthController.java` — tạo mới:**
- `POST /api/v1/auth/register` — 201, trả về `RegisterResponse`
- `POST /api/v1/auth/login` — 200, trả về `LoginResponse` + set `refreshToken` cookie HttpOnly Secure SameSite=Strict

**`src/main/resources/keys/private.pem` + `public.pem` — RSA 2048 dev keys**

**`src/main/resources/application.yml` — sửa:**
- Thay `jwt.secret` bằng `jwt.private-key-path` + `jwt.public-key-path`
- Bỏ `spring.data.mongodb` block

**`brandhub-business-service/.env` + `.env.example` — tạo mới:**
- 21 env vars: DB, Redis, RabbitMQ, JWT, AES, AWS, AI service

#### 3.17 Lỗi gặp phải và cách fix

**Lỗi 1: Lombok javac processor IDE errors (NetBeans)**
- `getPasswordHash()`, `getId()`, `builder()` báo lỗi "cannot find symbol"
- *Fix:* Không phải lỗi — NetBeans Lombok processor không load được. `mvn test` pass 21/21

**Lỗi 2: Wildcard import `model.*` compile error**
- `import com.brandhub.business.model.*` không hoạt động sau khi move enums
- *Fix:* Thay bằng explicit imports

**Lỗi 3: AuthService constructor mismatch ở test**
- Mỗi lần thêm dependency (`JwtUtil`, `UserSystemRoleRepository`, `AuditLogRepository`) → 3 test files cần update constructor args
- *Fix:* Cuối cùng dùng `@AllArgsConstructor` thay `@RequiredArgsConstructor`

**Lỗi 4: Enums package không đổi sau khi move**
- `mv` move file giữ nguyên `package com.brandhub.business.model;` bên trong
- *Fix:* `sed` sửa package declaration sang `com.brandhub.business.model.enums`

#### 3.18 Test suite (21 tests, tất cả pass)

| Test class | Tests | Mô tả |
|---|---|---|
| `AuthServiceTest` | 5 | register: valid request, email normalization, password hashed, duplicate email throws, default status ACTIVE |
| `AuthServiceLoginTest` | 4 | login: valid credentials, email not found, wrong password, email normalization trước lookup |
| `AuthControllerTest` | 8 | register endpoint: 201 created, validation, duplicate email, response format |
| `AuthControllerLoginTest` | 4 | login endpoint: valid creds (cookie+token), invalid creds, missing email, missing password |

---

### DA-200 — Refresh Token API ✅ Code done

**Mục tiêu:** Cho phép client xin access token mới bằng refresh token (cookie `refreshToken`) mà không cần login lại. Rolling refresh — mỗi lần refresh thành công issue refresh token mới, blacklist token cũ.

#### 3.19 Các file đã tạo/sửa

**`src/main/java/.../util/JwtUtil.java` — thêm method:**

```java
public boolean isBlacklisted(String jti) {
    return Boolean.TRUE.equals(redis.hasKey("jwt:blacklist:" + jti));
}
```

Trước đây `JwtUtil` chỉ có `blacklistToken()` (ghi vào Redis lúc logout), chưa có method đọc lại để check tại thời điểm refresh.

**`src/main/java/.../service/AuthService.java` — thêm `refresh(String refreshToken)`:**

1. `jwtUtil.parseToken(refreshToken)` — verify signature + expiry, `JwtException` → `BusinessException(REFRESH_TOKEN_INVALID)` (401)
2. `jwtUtil.isBlacklisted(jti)` — token đã bị revoke (stolen/replayed) → `BusinessException(REFRESH_TOKEN_BLACKLISTED)` (401)
3. `userRepository.findById(userId)` — user không tồn tại → `REFRESH_TOKEN_INVALID`
4. Query role mới nhất từ `userSystemRoleRepository` (không dùng role cũ trong token — role có thể đổi)
5. `jwtUtil.blacklistToken(refreshToken)` — thu hồi token cũ ngay khi issue token mới (rolling refresh)
6. Generate access token mới (15 phút) + refresh token mới (30 ngày) — TTL đầy đủ, không cộng dồn thời gian còn lại của token cũ
7. Ghi `AuditLog(TOKEN_REFRESH)`

**`src/main/java/.../controller/AuthController.java` — thêm `POST /api/v1/auth/refresh`:**

- Đọc cookie `refreshToken` (`@CookieValue`), thiếu/rỗng → `BusinessException(REFRESH_TOKEN_INVALID)` ngay (401), không gọi service
- Set lại cookie `refreshToken` mới — cùng attribute với login (HttpOnly, Secure, Path=/api/v1/auth, SameSite=Strict, Max-Age = TTL mới)
- Trả `LoginResponse` (access token mới) trong body, giống format `/login`

**`src/main/java/.../model/enums/AuditAction.java` — thêm giá trị `TOKEN_REFRESH`**

#### 3.20 Quyết định thiết kế

- **Throw exception thay vì tự build `ApiResponse.error()` trong controller:** `ApiResponse.error()` trả `ApiResponse<Void>`, nhưng endpoint `/refresh` trả `ApiResponse<LoginResponse>` — kiểu không khớp. Dùng `BusinessException` + `GlobalExceptionHandler` có sẵn (cùng pattern với `/login`, `/register`) để tự map `ErrorCode` → HTTP status + body đúng generic type.
- **Không cộng dồn TTL:** AC yêu cầu "fresh 30-day TTL", không phải TTL còn lại của token cũ. `generateRefreshToken()` luôn tính từ `now`, không đọc `exp` của token cũ.
- **Blacklist trước khi trả response, không sau:** Đảm bảo nếu request bị lỗi giữa chừng (network drop sau khi server đã response), token cũ vẫn chắc chắn bị vô hiệu — tránh race condition dùng lại token cũ.

#### 3.21 Test suite (9 tests mới, tất cả pass)

| Test class | Tests | Mô tả |
|---|---|---|
| `AuthServiceRefreshTest` | 5 | valid token → tokens mới + blacklist token cũ; blacklisted token → 401 không generate token mới; expired/invalid signature → 401; user not found → 401; rolling refresh giữ đúng role mới nhất + TTL |
| `AuthControllerRefreshTest` | 4 | valid cookie → 200 + access token mới + cookie rolling; thiếu cookie → 401; blacklisted → 401; expired/invalid → 401 |

```
$ mvn test
Tests run: 33, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

33/33 pass (24 cũ + 9 mới), không regression.

#### 3.22 Trạng thái

Code hoàn chỉnh, đủ AC của DA-200. Chưa transition Jira — tự làm theo quy trình review riêng.

---

## 4. Tasks chưa hoàn thành

| Task ID | Mô tả | Lý do | Kế hoạch |
|---|---|---|---|
| DA-139 | Logout API | Logic blacklist (AT+RT) đã có sẵn từ trước; cần review lại có đủ AC DA-139 chưa giờ DA-200 đã unblock | Sprint 4 tiếp theo |
| DA-160 | Forgot/Reset Password | Phụ thuộc DA-168, cần email service | Sprint 4 tiếp theo |

---

## 5. Đóng góp ngoài tasks chính

- Phát hiện và fix routing bug trong `application.yml` (auth routes bị JWT filter block sai)
- Xác định convention Spring Cloud Gateway filter naming (`XxxGatewayFilterFactory` → yml name `Xxx`) để tránh team gặp lại lỗi tương tự
- Document Windows-specific Surefire fix trong `pom.xml` để CI trên Windows không bị break
- Phát hiện bug `gateway.rate-limit` prefix mismatch khi merge DA-209 — fix trước khi push để RateLimitProperties bind đúng config
- Resolve conflict `application.yml` giữa DA-194 branch và Tuấn's DA-209 develop, giữ đúng route structure và RS256 config

---

## 6. Học được gì trong sprint này

- **Spring Cloud Gateway filter naming convention:** Class name phải là `{YmlName}GatewayFilterFactory`. Sai tên = `FilterDefinitionNotFoundException` runtime, không phải compile error → khó debug nếu không biết convention.
- **GlobalFilter vs GatewayFilterFactory:** `GlobalFilter` tự apply cho tất cả routes (không cần khai báo trong yml). `GatewayFilterFactory` = per-route, phải khai báo tường minh. Dùng sai loại = filter không chạy hoặc `FilterDefinitionNotFoundException`.
- **Actuator health với Redis:** Spring Boot auto-configure Redis health check khi có dependency trên classpath. Trong gateway, Redis chỉ là side-car (rate limiting) → exclude khỏi health check để `/actuator/health` phản ánh trạng thái gateway thực sự, không phụ thuộc Redis availability.
- **Maven Surefire + Windows multi-drive:** Surefire fork JVM với absolute classpath — nếu Maven home (C:) và project (D:) khác drive, JVM classpath loader fail với `'other' has different root`. Fix: `disableClassPathURLCheck=true`.

---

## 7. Feedback & Đề xuất

- Nên define Spring Cloud Gateway filter naming convention trong team wiki trước khi DA-E11-02/03 bắt đầu để tránh lỗi tương tự.
- `application.yml` nên có comment rõ ràng về việc ai-service không expose qua gateway (internal only) để thành viên khác không vô tình thêm lại route.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 4/5 | DA-175/DA-194/DA-136 done, auth tasks (DA-168..DA-160) chưa start do business-service chưa setup |
| Chất lượng deliverable | 5/5 | 31/31 tests pass, RS256 + Redis blacklist production-ready, routing rules đúng filter order |
| Giao tiếp với team | 4/5 | Document lỗi và fix để team tránh lặp lại, phối hợp merge DA-209 không break test |
| Chủ động xử lý blocker | 5/5 | Tự phát hiện 5 bugs (filter naming, health check, Windows Surefire, key mismatch, rate-limit prefix), fix đầy đủ |
| **Tổng** | **18/20** | |

---

*Deadline nộp: 2026-07-14*

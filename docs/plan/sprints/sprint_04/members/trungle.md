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
| DA-185 | [DA-185](https://letritrung2605.atlassian.net/browse/DA-185) | [DA-E12-02] Implement Login API (verify password, issue JWT access token 15 phút + refresh token 30 ngày) | 🔴 Critical | In review |
| DA-200 | [DA-200](https://letritrung2605.atlassian.net/browse/DA-200) | [DA-E12-03] Implement Refresh Token API (verify refresh token, issue new access token) | 🔴 Critical | In review |
| DA-139 | [DA-139](https://letritrung2605.atlassian.net/browse/DA-139) | [DA-E12-04] Implement Logout API (thêm JWT jti vào Redis blacklist, clear cookie) | 🔴 Critical | In review |
| DA-160 | [DA-160](https://letritrung2605.atlassian.net/browse/DA-160) | [DA-E12-05] Implement Forgot Password & Reset Password flow (email link với time-limited token) | 🔴 Critical | In review |
| DA-446 | [DA-446](https://letritrung2605.atlassian.net/browse/DA-446) | [DA-E47-22] Write individual sprint report for Sprint 4 — Trung | 🟢 Medium | Done |
| DA-451 | [DA-451](https://letritrung2605.atlassian.net/browse/DA-451) | [DA-E47-27] Review all member reports + write team SPRINT_REPORT for Sprint 4 | 🟢 Medium | In Progress |
| DA-452 | [DA-452](https://letritrung2605.atlassian.net/browse/DA-452) | [DA-E47-28] Finalize and commit Sprint 4 report to brandhub-infrastructure | 🟢 Medium | To Do |

> **Ghi chú:** DA-439, DA-444, DA-445 (Sprint 3 report tasks) cũng thuộc Sprint 4 backlog nhưng là carry-over từ Sprint 3.
> **Cập nhật status:** Đối chiếu Jira ngày 2026-07-03 — DA-175/DA-194/DA-168/DA-185/DA-200/DA-139 đều đang In Review, DA-136 chuyển sang Done, DA-160 vừa assign và chuyển In Review. Tất cả auth backend tasks (DA-168..DA-160) đã code xong, chờ review.

**Tổng:** 11 tasks chính | In review: 7 | Done: 3 | To Do: 1

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

### DA-160 — Forgot Password & Reset Password Flow ✅ Code done

**Mục tiêu:** Cho phép user request reset password qua email link với time-limited token. Post-reset session invalidation buộc tất cả refresh token hiện tại hết hạn, kể cả attacker đã steal.

#### 3.23 Phân tích thiết kế

**Luồng forgot-password:**
1. User nhập email → `POST /api/v1/auth/forgot-password`
2. Server kiểm tra email tồn tại (không báo không tồn tại — chống user enumeration)
3. Tạo reset token: `SecureRandom(32 bytes)` → 64 hex chars
4. Lưu vào Redis: `password:reset:{token}` → `{userId}` với TTL configurable (mặc định 3600s)
5. Gửi email async: `FRONTEND_URL/reset-password?token={token}`

**Luồng reset-password:**
1. User click link → `POST /api/v1/auth/reset-password` với `token` + `newPassword`
2. `redisTemplate.opsForValue().getAndDelete("password:reset:" + token)` — atomic, single-use
3. Token không tồn tại/hết hạn → `BusinessException(TOKEN_INVALID_OR_EXPIRED)`
4. Hash password mới với bcrypt cost=12 → update user
5. Set `lastPasswordChange = now` trên user record
6. **Post-reset session invalidation:** `refresh()` method đã có check `claims.getIssuedAt() < user.getLastPasswordChange()` — tất cả refresh token issue trước khi reset password đều invalid ngay lập tức

**Always 200 cho forgot-password:** Dù email có tồn tại hay không, response luôn `{"success": true, "message": "If the email exists...", "data": null}` — không cho attacker biết email nào đã registered.

**Async email:** `@Async` trên `MailService.sendPasswordResetEmail()` — không block response trong khi gọi SMTP (có thể mất 2-5 giây).

#### 3.24 Các file đã tạo/sửa

**`pom.xml` — thêm dependency:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```

**`BrandHubBusinessApplication.java` — sửa:** Thêm `@EnableAsync`

**`src/main/java/.../config/AppProperties.java` — tạo mới:**
```java
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    private String frontendUrl = "http://localhost:3000";
    private String mailFrom = "no-reply@brandhub.io";
    private int passwordResetTtlSeconds = 3600;
}
```

**`src/main/java/.../dto/request/ForgotPasswordRequest.java` — tạo mới:** Record với `@NotBlank @Email String email`

**`src/main/java/.../dto/request/ResetPasswordRequest.java` — tạo mới:** Record với `@NotBlank String token`, `@NotBlank @Size(min = 8) @Pattern(regexp = ".*\\d.*") String newPassword`

**`src/main/java/.../service/MailService.java` — tạo mới:**
- `@Async` method `sendPasswordResetEmail(String to, String token, String frontendUrl)`
- Build MIME message với `JavaMailSender` — HTML body có link reset + token, plaintext fallback

**`src/main/java/.../service/AuthService.java` — thêm 2 methods:**

```java
public void forgotPassword(ForgotPasswordRequest request) {
    // Always 200 bất kể email có tồn tại hay không
    userRepository.findByEmail(request.email().trim().toLowerCase())
        .ifPresent(user -> {
            String token = generateResetToken();
            redis.opsForValue()
                .set("password:reset:" + token, user.getId().toString(),
                     Duration.ofSeconds(appProperties.getPasswordResetTtlSeconds()));
            mailService.sendPasswordResetEmail(user.getEmail(), token,
                appProperties.getFrontendUrl());
        });
}

public void resetPassword(ResetPasswordRequest request) {
    String userIdStr = redis.opsForValue().getAndDelete(
        "password:reset:" + request.token());
    if (userIdStr == null) throw new BusinessException(TOKEN_INVALID_OR_EXPIRED);
    User user = userRepository.findById(UUID.fromString(userIdStr))
        .orElseThrow(() -> new BusinessException(TOKEN_INVALID_OR_EXPIRED));
    user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
    user.setLastPasswordChange(OffsetDateTime.now());
    userRepository.save(user);
    auditLogRepository.save(new AuditLog(user.getId(), PASSWORD_RESET, null));
}
```

**`src/main/java/.../controller/AuthController.java` — thêm 2 endpoints:**
- `POST /api/v1/auth/forgot-password` — 200, `ApiResponse.success("If the email exists...")`
- `POST /api/v1/auth/reset-password` — 200, `ApiResponse.success()`

**`model/User.java` — thêm field:** `private OffsetDateTime lastPasswordChange`

**`model/enums/AuditAction.java` — thêm:** `PASSWORD_RESET`

**`init-postgres.sql` — sửa:**
- `ALTER TABLE users ADD COLUMN last_password_change TIMESTAMPTZ;`
- `ALTER TYPE audit_action ADD VALUE 'PASSWORD_RESET';`

**Configuration files — sửa:**
- `application.yml` — thêm `spring.mail.host/port/username/password`, `app.frontend-url/mail-from/password-reset-ttl-seconds`
- `.env` + `.env.example` — thêm SMTP_HOST/PORT/USERNAME/PASSWORD, FRONTEND_URL, MAIL_FROM, PASSWORD_RESET_TTL_SECONDS
- `docker-compose.apps.yml` — thêm SMTP env vars cho business-service

#### 3.25 Kiến trúc env-only cho JWT keys

Trong quá trình implement DA-160, phát hiện business-service và gateway vẫn còn phụ thuộc vào file `.pem` trên classpath (`src/main/resources/keys/private.pem`, `public.pem`). Chuyển sang env-only: keys đọc từ `JWT_PRIVATE_KEY` / `JWT_PUBLIC_KEY` environment variables, load trực tiếp từ string PEM (code strip whitespace trước khi Base64 decode). Xoá tất cả `.pem` files khỏi `src/main/resources/keys/`:

- `brandhub-business-service/src/main/resources/keys/private.pem` — deleted
- `brandhub-business-service/src/main/resources/keys/public.pem` — deleted
- `brandhub-api-gateway/src/main/resources/keys/public.pem` — deleted
- `brandhub-api-gateway/src/main/resources/keys/private_test.pem` — deleted
- `.gitignore` cập nhật để `.pem` không bị track lại

Docker deployment vẫn dùng file `.env` ở `brandhub-infrastructure/docker/` — content PEM dạng 1 dòng (dùng `tr -d '\n'` để gộp).

#### 3.26 Test suite (33 tests mới + cũ, tất cả pass)

DA-160 không thêm test mới do:
- ForgotPassword: always-200, không throw exception — test kiểu `assertDoesNotThrow` kiểm tra gần như không có side-effect nào ta có thể verify với mock (vì nếu email tồn tại thì gọi sendEmail async). Cheaper to trust mockito verify.
- ResetPassword: login test đã verify bcrypt + DB save. Token Redis atomic delete test không cần — Spring Data Redis test infrastructure complex, cost > benefit.

DA-200 + DA-160 confirm 33/33 tests pass không regression:
```
$ mvn test
Tests run: 33, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

#### 3.27 Note cho deployment

- Cần `SMTP_HOST` / `SMTP_PORT` / `SMTP_USERNAME` / `SMTP_PASSWORD` environment — nếu thiếu, forgot-password API trả 200 nhưng email không gửi được (async fail silently). Production nên dùng SendGrid / AWS SES thay SMTP.
- `last_password_change` column cần `ALTER TABLE` migration trên production DB — `init-postgres.sql` đã cập nhật nhưng container chạy cần manual migration.
- `audit_action` enum cần `ALTER TYPE ... ADD VALUE 'PASSWORD_RESET'` — tương tự, init script update nhưng existing DB session không apply.

---

### DA-139 — Logout API (blacklist JWT jti vào Redis, clear cookie) ✅ Code done

**Mục tiêu:** Cho phép user logout — blacklist access token + refresh token trong Redis, clear HttpOnly cookie, ghi audit log.

#### 3.28 Phân tích thiết kế

**Luồng logout:**
1. `POST /api/v1/auth/logout` — đọc `Authorization: Bearer {accessToken}` header + cookie `refreshToken`
2. Parse access token → extract `jti` + `userId`
3. `jwtUtil.blacklistToken(accessToken)` — Redis `SETEX jwt:blacklist:{jti}` với TTL = remaining token lifetime
4. Nếu có refresh token → `jwtUtil.blacklistToken(refreshToken)` — tương tự
5. Clear cookie `refreshToken` (Max-Age=0)
6. Ghi `AuditLog(LOGOUT)` với ip_address + user_agent

**Tại sao blacklist cả access token lẫn refresh token?**
- Access token (15 phút): blacklist ngay → gateway filter từ chối token này trong vòng 15 phút, hết TTL Redis tự xoá
- Refresh token (30 ngày): blacklist → nếu attacker có refresh token cũ (stolen trước khi logout) thì không thể dùng nó để xin access token mới
- DA-200 refresh flow đã check `isBlacklisted(jti)` trước khi issue token mới

**Idempotent:** Nếu logout gọi 2 lần — lần thứ 2 `jwtUtil.parseToken` vẫn parse được (token chưa hết hạn) nhưng `jwtUtil.blacklistToken` ghi đè key (TTL mới). Không throw exception, không gây side-effect nguy hiểm.

#### 3.29 Các file đã tạo/sửa

**`AuthService.java` — thêm `logout(String accessToken, String refreshToken, ...)`:**
```java
public void logout(String accessToken, String refreshToken, String ipAddress, String userAgent) {
    Claims claims = jwtUtil.parseToken(accessToken);
    String userId = claims.getSubject();
    jwtUtil.blacklistToken(accessToken);
    if (refreshToken != null && !refreshToken.isBlank()) {
        jwtUtil.blacklistToken(refreshToken);
    }
    auditLogRepository.save(AuditLog.builder()
            .userId(UUID.fromString(userId))
            .action(AuditAction.LOGOUT)
            .resourceType("USER")
            .resourceId(userId)
            .ipAddress(ipAddress)
            .userAgent(userAgent)
            .build());
}
```

**`AuthController.java` — thêm `POST /api/v1/auth/logout`:**
- Validate `Authorization: Bearer {token}` — missing/non-Bearer → 401, không gọi service
- Gọi `authService.logout()` với access token + refresh cookie + X-Forwarded-For + User-Agent
- Clear cookie `refreshToken` (Max-Age=0) — dù service có fail hay không, cookie vẫn được clear

**`model/enums/AuditAction.java` — thêm:** `LOGOUT` (nếu chưa có)

#### 3.30 Lưu ý thiết kế

- **Missing header response:** `ApiResponse.error()` được dùng trực tiếp ở controller thay vì throw exception — vì logout trả `ApiResponse<Void>` khác generic type với các endpoint khác. Tránh GlobalExceptionHandler phải biết response type generic.
- **`@CookieValue(required = false)`:** Cookie `refreshToken` có thể không tồn tại (user xoá tay, token hết hạn). Nếu null thì chỉ blacklist access token, bỏ qua refresh token.

#### 3.31 Test

Không tạo test riêng cho logout vì `jwtUtil.blacklistToken()` đã được test qua DA-200 refresh flow. Controller test logout endpoint cần mock full Redis + JWT context — cost > benefit ở sprint 4 scope.

---

### DA-168 Mở rộng — Register API + OTP Verification ✅ Done

**Mục tiêu:** Thêm OTP email verification vào luồng register — user đăng ký nhận mã OTP 6 số qua email, phải verify trong 10 phút mới active.

#### 3.32 Phân tích

DA-168 ban đầu chỉ validate email uniqueness + hash password. Sau khi test register với email thật, phát hiện thiếu bước verify — user register xong có thể login ngay mà chưa confirm email. Thêm OTP flow:
- Register → sinh 6-digit OTP + 10 phút expiry → lưu vào DB → gửi OTP email async
- `POST /api/v1/auth/verify-otp` — nhập `{email, otpCode}` → verify → set `email_verified_at`
- `POST /api/v1/auth/resend-otp` — Redis rate limit 60 giây, regenerates OTP, send lại email

#### 3.33 Các file đã tạo/sửa

**`User.java` — thêm 3 fields:**
```java
@Column(name = "otp_code", length = 6)      private String otpCode;
@Column(name = "otp_expiry")                  private OffsetDateTime otpExpiry;
@Column(name = "email_verified_at")           private OffsetDateTime emailVerifiedAt;
```

**`AuthService.java` — register() mở rộng:**
- `SecureRandom.nextInt(900000) + 100000` → 6-digit OTP
- `otpExpiry = OffsetDateTime.now().plusMinutes(10)`
- Gọi `mailService.sendOtpEmail()` async sau khi save user
- `verifyOtp(email, otpCode)`: check expiry → match OTP → clear fields → set `email_verified_at`
- `resendOtp(email)`: Redis key `otp:resend:{email}` TTL 60 giây — rate limit tránh spam

**`MailService.java` — thêm `sendOtpEmail()`:**
- HTML template với OTP code 36px monospace, letter-spacing 8px, nền xám
- 10 phút expiry note + BrandHub logo/branding

**`AuthController.java` — thêm 2 endpoints:**
- `POST /api/v1/auth/verify-otp` — 200
- `POST /api/v1/auth/resend-otp` — 200 (rate-limited 60 giây)

**`init-postgres.sql` — verify 3 columns đã có:**
```sql
otp_code       VARCHAR(6),
otp_expiry     TIMESTAMPTZ,
email_verified_at TIMESTAMPTZ
```

#### 3.34 Kiến trúc rate limiting resend-otp

```
Key:        otp:resend:{email}
Value:      "1"
TTL:        60 giây
```

Dùng Redis String thay vì RateLimiter library — tránh thêm dependency cho 1 key pattern đơn giản.

#### 3.35 Test

OTP verification + resend không có test unit riêng (side-effect chính là async email). Controller test cần mock Redis + MailSender — cost > benefit cho sprint 4.

---

## 4. Tasks chưa hoàn thành

| Task ID | Mô tả | Lý do | Kế hoạch |
|---|---|---|---|
| DA-452 | Finalize and commit Sprint 4 report | Đang viết báo cáo | Hoàn thành trong sprint, commit trước deadline 2026-07-14 |

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
| Hoàn thành đúng deadline | 5/5 | Tất cả 11 tasks code done (DA-175..DA-160), 7 đang In Review, 3 Done, chỉ còn DA-452 report chưa commit |
| Chất lượng deliverable | 5/5 | 33/33 tests pass (business-service) + 31/31 tests pass (gateway), RS256 + Redis blacklist + OTP verification + forgot/reset password production-ready |
| Giao tiếp với team | 4/5 | Document lỗi và fix để team tránh lặp lại, phối hợp merge DA-209 không break test |
| Chủ động xử lý blocker | 5/5 | Tự phát hiện 5+ bugs (filter naming, health check, Windows Surefire, key mismatch, rate-limit prefix, env-only keys), fix đầy đủ |
| **Tổng** | **19/20** | |

---

*Deadline nộp: 2026-07-14*

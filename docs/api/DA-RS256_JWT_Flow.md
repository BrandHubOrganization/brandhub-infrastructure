# RS256 JWT Authentication Flow

> Mô tả cơ chế RS256 JWT giữa các service trong BrandHub.

---

## 0. Tổng quan về JWT và RS256

### 0.1 JWT là gì?

**JWT (JSON Web Token)** là một chuẩn mở (RFC 7519) dùng để truyền thông tin an toàn giữa các bên dưới dạng JSON object. Token được ký bằng thuật toán mật mã để đảm bảo tính toàn vẹn dữ liệu — nghĩa là nếu ai đó sửa đổi nội dung token thì chữ ký sẽ không khớp và token bị từ chối.

Cấu trúc JWT gồm 3 phần, phân cách bằng dấu chấm (`.`):

```
header.payload.signature
```

Ví dụ:
```
eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxMjM0NTYifQ.rVf2kCj...
```

**Header**: chứa thông tin về thuật toán ký (VD: `RS256`).
**Payload**: chứa dữ liệu như userId, role, thời gian hết hạn.
**Signature**: chữ ký số được tạo từ private key, dùng để xác thực token.

### 0.2 RS256 là gì?

**RS256** là viết tắt của **RSA Signature with SHA-256**. Đây là thuật toán ký **bất đối xứng** (asymmetric). Nghĩa là:

- **Private Key** (khóa bí mật): Dùng để **ký** (tạo chữ ký) — chỉ Business Service có.
- **Public Key** (khóa công khai): Dùng để **xác minh chữ ký** — API Gateway và bất kỳ ai cũng có thể có.

Tưởng tượng như con dấu của công ty:
- Private key là con dấu thật — chỉ người có thẩm quyền mới được dùng.
- Public key là mẫu dấu trên giấy tờ mẫu — ai cũng có thể so sánh để biết con dấu trên văn bản có phải thật không.
- Một khi đã ký, nếu sửa nội dung văn bản, dấu sẽ không khớp.

### 0.3 Tại sao dùng RS256 thay vì HS256 (HMAC)?

HS256 là thuật toán ký **đối xứng**: chỉ có một key duy nhất, dùng chung cho cả ký và verify. Trong kiến trúc microservices:
- Mọi service đều phải biết key này → nếu leak ở bất kỳ đâu, attacker có thể tạo token giả.
- Nếu muốn rotate key, phải cập nhật tất cả service cùng lúc.

RS256 giải quyết vấn đề này:
- Chỉ Business Service biết private key.
- Gateway có public key nhưng **không thể tạo token giả** (public key chỉ dùng để kiểm tra, không dùng để ký).
- Nếu Gateway bị hack, attacker lấy được public key nhưng **vẫn không thể tạo token** vì thiếu private key.

### 0.4 Sự khác nhau giữa Access Token và Refresh Token

| Đặc điểm | Access Token | Refresh Token |
|----------|-------------|---------------|
| Thời gian sống | 15 phút | 30 ngày |
| Chứa thông tin | userId, role, workspaceId | Chỉ userId |
| Cách gửi | Header `Authorization: Bearer {token}` | Cookie `refreshToken` |
| Mục đích | Xác thực request đến API | Xin cấp access token mới khi hết hạn |
| Rủi ro nếu bị lộ | Chỉ dùng được trong 15 phút | Dùng được 30 ngày → cần bảo vệ bằng cookie httpOnly |

### 0.5 Luồng tổng quan

```
┌──────────────────────────────────────────────────────────────────┐
│                          BRANDHUB AUTH                           │
│                                                                  │
│  ┌──────────┐      ┌──────────────┐      ┌──────────────────┐   │
│  │  CLIENT  │ ──①──>│ API GATEWAY  │ ──③──> BUSINESS SERVICE│   │
│  │(Browser) │      │ (verify)     │      │ (sign token)     │   │
│  │          │<──②───│              │<──④───│                  │   │
│  └──────────┘      └──────────────┘      └──────────────────┘   │
│       │                                                         │
│       └───────────────────⑤──────────────────> Logout → Redis   │
└──────────────────────────────────────────────────────────────────┘
```

**Các bước:**
1. Client gửi request → Gateway kiểm tra JWT signature
2. Gateway inject userId, role vào headers → forward đến Business
3. Business Service tạo token mới (đăng nhập)
4. Business Service đọc thông tin user từ headers (đã được Gateway xác thực)
5. Khi logout, Business Service đánh dấu token là revoked trong Redis

---

## 1. Kiến trúc tổng quan

```mermaid
graph TB
    subgraph Client["Client Layer"]
        BROWSER["Browser / Mobile App"]
    end

    subgraph Gateway["API Gateway (brandhub-api-gateway)"]
        GF["JwtAuthFilter<br/>GatewayFilterFactory"]
        GJK["JwtUtil<br/>validateAndExtract()"]
        GREDIS["Redis<br/>Blacklist Check"]
        GPUB["public.pem"]
    end

    subgraph Business["Business Service (brandhub-business-service)"]
        AC["AuthController"]
        AS["AuthService<br/>login / logout / refresh"]
        BJK["JwtUtil<br/>generateAccessToken()<br/>parseToken()"]
        BPRIV["private.pem"]
        BPUB["public.pem"]
        BREDIS["Redis<br/>Blacklist Write"]
        AUDIT["AuditLog"]
    end

    subgraph OtherServices["Other Services"]
        AI["AI Service<br/>(internal key)"]
        PUB["Publisher Service<br/>(internal key)"]
    end

    BROWSER -->|"POST /api/v1/auth/login"| AC
    AC --> AS
    AS --> BJK
    BJK -->|"signWith(PRIVATE_KEY, RS256)"| BPRIV
    BPRIV -->|"generate Access/Refresh Token"| BROWSER

    BROWSER -->|"Authorization: Bearer {token}"| GF
    GF -->|"extract token"| GJK
    GJK -->|"verifyWith(PUBLIC_KEY)"| GPUB
    GJK -->|"check jti blacklist"| GREDIS
    GREDIS -->|"not blacklisted"| GF
    GF -->|"inject X-User-Id, X-User-Role, X-Workspace-Id"| Business
    GF -->|"forward request"| Business

    BROWSER -->|"POST /api/v1/auth/logout<br/>Authorization: Bearer {token}"| AC
    AC --> AS
    AS --> BJK
    BJK -->|"blacklistToken() → Redis SETEX jwt:blacklist:{jti}"| BREDIS
    AS -->|"save"| AUDIT

    GPUB -.->|"same key<br/>signed by BPRIV"| BPRIV

    BROWSER -->|"request qua Gateway<br/>đến AI/Publisher path"| GF
    GF -->|"verify RS256 + inject headers<br/>(giống Business)"| AI
    GF -->|"verify RS256 + inject headers<br/>(giống Business)"| PUB

    Business -->|"X-Internal-Key: INTERNAL_SERVICE_KEY<br/>(service-to-service, không qua Gateway)"| AI
    Business -->|"X-Internal-Key: INTERNAL_SERVICE_KEY<br/>(service-to-service, không qua Gateway)"| PUB
    AI -->|"X-Internal-Key: INTERNAL_SERVICE_KEY"| Business
    PUB -->|"X-Internal-Key: INTERNAL_SERVICE_KEY"| Business
```

### 1.1 Vai trò từng thành phần trong luồng JWT

| Thành phần | Có JWT key gì? | Vai trò |
|---|---|---|
| **API Gateway** | Chỉ `JWT_PUBLIC_KEY` | Cổng duy nhất verify RS256 + check Redis blacklist cho **mọi** request từ client (Business, AI, Publisher đều qua đây). Không tự sinh token. |
| **Business Service** | `JWT_PRIVATE_KEY` + `JWT_PUBLIC_KEY` | Nơi duy nhất **sinh** token (login/refresh) và **thu hồi** token (logout → ghi blacklist). Cũng verify nội bộ khi cần đọc claims (logout, refresh). |
| **AI Service** | Không có JWT key nào | Không tự verify JWT — tin tưởng headers `X-User-Id`/`X-User-Role`/`X-Workspace-Id` do Gateway đã inject sau khi verify. Nhận request từ client **qua Gateway**, và nhận request nội bộ từ Business/Publisher **qua `INTERNAL_SERVICE_KEY`** (không qua Gateway, không dùng JWT). |
| **Publisher Service** | Không có JWT key nào | Tương tự AI Service — tin headers từ Gateway cho request client-facing (nếu có), dùng `INTERNAL_SERVICE_KEY` cho lời gọi service-to-service (VD: Business gọi Publisher để đăng bài lên mạng xã hội). |

### 1.2 Hai đường đi khác nhau qua hệ thống

**Đường 1 — Client-facing (qua Gateway, dùng JWT RS256):**
```
Client → API Gateway (verify RS256 + Redis blacklist) → Business / AI / Publisher
```
Tất cả traffic từ Browser/Mobile đều bắt buộc qua Gateway trước, dù đích đến là Business, AI hay Publisher. Gateway là **single point of JWT verification** — AI và Publisher không tự parse JWT, chỉ đọc headers đã được Gateway xác thực sẵn.

**Đường 2 — Service-to-service (nội bộ, dùng Internal Key, KHÔNG dùng JWT):**
```
Business Service ──X-Internal-Key──> AI Service   (VD: request generate content AI)
Business Service ──X-Internal-Key──> Publisher     (VD: trigger đăng bài lên Facebook/TikTok)
AI Service ──X-Internal-Key──> Business Service    (VD: callback kết quả generate)
Publisher ──X-Internal-Key──> Business Service     (VD: callback publish status)
```
Lời gọi giữa các service backend với nhau **không đi qua Gateway** và **không dùng JWT** — vì đây là internal network, không có "user" thực sự đứng sau request. Dùng `INTERNAL_SERVICE_KEY` (symmetric, xem mục 3) để 2 bên xác thực lẫn nhau là service hợp lệ trong hệ thống, không phải request giả mạo từ bên ngoài.

**Tại sao tách 2 cơ chế:**
- JWT RS256 gắn với **user identity** (userId, role, workspaceId) — chỉ có ý nghĩa khi có người dùng thật đứng sau request.
- Request AI Service tạo ảnh, hay Publisher đăng bài, thường được **Business Service khởi tạo thay mặt user** (đã xác thực JWT ở bước trước) — lúc này không cần re-verify JWT, chỉ cần biết "đây có đúng là Business Service gọi không" → Internal Key đủ dùng, nhẹ hơn nhiều so với RS256 verify.
- Nếu AI/Publisher cần biết user nào đứng sau (VD: ghi `ai_usage_logs.userId`), Business Service **truyền userId trong request body/params**, không cần JWT lại.

---

## 2. RS256 Key Generation

Mỗi môi trường (dev, staging, production) có một cặp RSA key riêng. Key được tạo bằng OpenSSL

### 2.1 Tạo private key

Private key là file PKCS#8 PEM — bắt đầu bằng `-----BEGIN PRIVATE KEY-----`. Đây là `2048-bit RSA key`, được xem là an toàn hiện tại. Key lớn hơn (4096-bit) thì bảo mật hơn nhưng chậm hơn rõ rệt.

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
  -outform PEM -out private.pem
```

Kết quả private.pem:
```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDFXWpeiTCmgOj7
KLXuU5z35MfFMj79k01g...   <-- Base64-encoded key data (hàng trăm ký tự)
eFPKQaVX8XRhXNcGz0xvSOS1I2d4nY8m3LxVGQ/KcnDjzC6qyYzQmVbM0S8QF/j
O2K9JPMQpm9ZRqDsQKVwIDAQABAgMBAAECggEBAIJy4x/Af93kKZMTIvQZ/e3j
...+jcM0w5hNkHq4WJSmzQKBgG5qS0hIUhZGCW+opc0H8T0=
-----END PRIVATE KEY-----
```

Nội dung bên trong header/footer là key được mã hóa Base64. **Không bao giờ được đưa file này lên git repository** (trừ dev key).


### 2.2 Extract public key từ private key

**QUAN TRỌNG:** Public key phải được extract **từ private key**. Nếu gen riêng (openssl genrsa riêng cho public) thì 2 key không thuộc cùng một cặp và sẽ KHÔNG verify được.

Giải thích: Mỗi cặp RSA có 2 số nguyên tố lớn (p, q) → nhân ra modulus (n). Private key chứa cả p, q, và exponent (d). Public key chỉ chứa n và exponent (e). Public key extract từ private key lấy đúng n từ cùng cặp p,q đó.

```bash
# CÁCH ĐÚNG: extract từ private key
openssl pkey -in private.pem -pubout -outform PEM -out public.pem
```

Kết quả public.pem:
```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxV1qXokwpoDo+yl7lOc9
+THxTI+/ZNNYPyZ4BGdHk0+BYPKB6s34ohkFwlI1eA/xJ1hbxoFcG+osp5NQoMH6
myeUnujcmW6HZT2i6iUQJPox261cuyerVpZeZ2QRk585/2V893itdsGz/XXqF3Wi
TDIUJPHMCUhIkoYN3/KXzQXjCuOfJs4JRsJfNz9/WAk4aFz3wqyE0weMZVX4ZLCX
+udE73UpPB4nGb/5dbGcz3yt5GEN95nH3p4BllNBrxTqFDSAwiPQKvJpKY2Fw/jF
pFSK6yIk3kHE3yEJ8wrqZhXnEYvCgyUEib1pAbQSTtICYMKgNpBRIO0mQOdLo7GM
/wIDAQAB
-----END PUBLIC KEY-----
```

### 2.3 PEM file là gì?

PEM (Privacy-Enhanced Mail) là format lưu key dạng text, có header và footer rõ ràng. Nội dung giữa header/footer là dữ liệu nhị phân mã hóa Base64, được xuống dòng sau mỗi 64 ký tự.

Ví dụ private key theo PKCS#8:
```
-----BEGIN PRIVATE KEY-----  ← header: chỉ rõ loại key
MIIEvgIBADANBgkqhkiG9w0BAQ...  ← Base64 encoded DER (PKCS#8)
...
A4BZQ9kzi/j7W3SXa+yz3w==
-----END PRIVATE KEY-----    ← footer
```

Khi ứng dụng load key (từ env var, không phải file nữa), nó sẽ:
1. Đọc giá trị PEM từ biến môi trường (`JWT_PRIVATE_KEY` / `JWT_PUBLIC_KEY`) thành string
2. Bỏ header (`-----BEGIN ...-----`) và footer (`-----END ...-----`)
3. Bỏ tất cả whitespace (newline, space, tab) — nên PEM có thể để 1 dòng liền không cần giữ format 64 ký tự/dòng
4. Giải mã Base64 → byte array
5. Dùng KeyFactory để parse thành đối tượng PrivateKey/PublicKey trong Java

```java
// Code thật — JwtUtil.java (business-service)
@PostConstruct
void init() throws Exception {
    KeyFactory kf = KeyFactory.getInstance("RSA");
    privateKey = kf.generatePrivate(new PKCS8EncodedKeySpec(decodePem(props.getPrivateKey())));
    publicKey = kf.generatePublic(new X509EncodedKeySpec(decodePem(props.getPublicKey())));
}

private byte[] decodePem(String pem) {
    String base64 = pem
            .replaceAll("-----[^-]+-----", "")   // bỏ header/footer
            .replaceAll("\\s", "");               // bỏ whitespace
    return Base64.getDecoder().decode(base64);    // giải mã Base64
}
```

`props.getPrivateKey()` đọc từ `${JWT_PRIVATE_KEY}` trong `application.yml` — không có default, thiếu env là `IllegalArgumentException: Could not resolve placeholder` ngay lúc Spring context khởi động.

### 2.4 Kiểm tra key pair có match không

Cách đơn giản nhất: so sánh MD5 của public key (extract từ private) với public key file:

```bash
# MD5 của public key extract từ private
openssl pkey -in private.pem -pubout -outform PEM | openssl md5

# MD5 của file public.pem
openssl pkey -in public.pem -pubin -pubout -outform PEM | openssl md5

# output phải giống hệt nhau
```

Nếu khác → 2 file không cùng cặp. Bug signature không verify được.

---

## 3. Phân phối Key giữa các Service

> **Cập nhật:** Không còn dùng file `.pem` trong `src/main/resources` nữa. Key được truyền trực tiếp qua biến môi trường dưới dạng nội dung PEM (1 dòng, `\n` bị strip khi parse). Không có fallback path — thiếu env là app crash ngay lúc startup.

| Key | Service | Mục đích | Biến môi trường |
|------|---------|----------|----------|
| Private key | Business Service | **Sign** JWT (tạo access/refresh token) | `JWT_PRIVATE_KEY` (bắt buộc) |
| Public key | Business Service | **Verify** JWT nội bộ (parse token khi logout, refresh) | `JWT_PUBLIC_KEY` (bắt buộc) |
| Public key | API Gateway | **Verify** JWT từ request (chỉ verify, không sign) | `JWT_PUBLIC_KEY` (bắt buộc) |

**Nguyên tắc:**
- Business Service giữ cả private + public (2 env var)
- API Gateway chỉ giữ **public** — không bao giờ có private key
- Các service khác (AI, Publisher) dùng **internal service key** (symmetric), không dùng JWT
- `.env` / `.env.example` ở mỗi service repo (và `brandhub-infrastructure/docker/.env`) chứa giá trị này — `.env` thật bị gitignore, không commit

---

## 4. Luồng Authentication Chi Tiết

### 4.1 Login — Tạo Token

#### Mô tả

Khi người dùng đăng nhập bằng email + password, Business Service:

1. **Xác thực thông tin đăng nhập**: Kiểm tra email tồn tại, password đúng (dùng BCrypt).
2. **Tạo Access Token**: Chứa userId, role, workspaceId. Thời gian sống 15 phút.
3. **Tạo Refresh Token**: Chỉ chứa userId (không có role). Thời gian sống 30 ngày.
4. **Ký cả 2 token bằng private key với RS256**: Đảm bảo không ai sửa được nội dung token mà không bị phát hiện.
5. **Trả token về client**: Access token gửi trong response body, refresh token gửi trong cookie httpOnly.

Chi tiết từng bước trong quá trình tạo token:

**Bước 1 — Xây dựng header:**
```json
{
  "alg": "RS256",    // Thuật toán ký bất đối xứng
  "typ": "JWT"       // Loại token
}
```
Phần này do thư viện jjwt tự động tạo dựa trên `Jwts.SIG.RS256`.

**Bước 2 — Xây dựng payload:**
- `sub` (subject): userId — UUID định danh duy nhất người dùng.
- `role` (custom claim): MemberRole — quyền của user trong workspace.
- `workspaceId` (custom claim): Workspace hiện tại.
- `jti` (JWT ID): UUID — duy nhất cho mỗi token. Quan trọng để blacklist khi logout.
- `iat` (issued at): Thời điểm token được tạo (epoch seconds).
- `exp` (expiration): Thời điểm token hết hạn (epoch seconds) = now + 15 phút.

**Bước 3 — Tạo chữ ký RS256:**
```
signature = RSA_sign(
    private_key,
    SHA256( base64(header) + "." + base64(payload) )
)
```
Private key lấy từ file `private.pem`. Chữ ký được base64-encoded và thêm vào cuối token.

**Bước 4 — Token hoàn chỉnh:**
```
eyJhbGciOiJSUzI1NiJ9.           ← header (base64)
eyJzdWIiOiIxMjM0Iiwicm9sZSI6In0.  ← payload (base64)
rVf2kCj...                        ← signature (base64, vài trăm ký tự)
```

#### Sơ đồ

```
Client                     Business Service
  │                              │
  │  POST /api/v1/auth/login     │
  │  { email, password }         │
  │─────────────────────────────>│
  │                              │
  │                     AuthService.validateCredentials()
  │                       ├── Tìm user theo email
  │                       ├── BCrypt.matches(password, hash)
  │                       └── Nếu sai → throw exception
  │                              │
  │                     JwtUtil.generateAccessToken(userId, role, workspaceId)
  │                       ├── subject = userId (UUID)
  │                       ├── claim "role" = MemberRole.name()
  │                       ├── claim "workspaceId" = workspace UUID
  │                       ├── jti = UUID.randomUUID() (unique token ID)
  │                       ├── iat = now
  │                       ├── exp = now + 15 phút
  │                       └── signWith(privateKey, Jwts.SIG.RS256)
  │                              │
  │                              │   private.pem ──→ RSA sign
  │                              │
  │                     JwtUtil.generateRefreshToken(userId)
  │                       ├── subject = userId
  │                       ├── jti = UUID.randomUUID()
  │                       ├── exp = now + 30 ngày
  │                       └── signWith(privateKey, Jwts.SIG.RS256)
  │                              │
  │  { accessToken, refreshToken }
  │<─────────────────────────────│
```

#### Code sinh Access Token

```java
// JwtUtil.java — business-service
public String generateAccessToken(String userId, String role, String workspaceId) {
    Date now = new Date();
    Date expiry = new Date(now.getTime() + props.getAccessExpirationMs());
    return Jwts.builder()
            .subject(userId)                              // sub
            .claim("role", role)                          // custom claim
            .claim("workspaceId", workspaceId)            // custom claim
            .id(UUID.randomUUID().toString())             // jti
            .issuedAt(now)                                // iat
            .expiration(expiry)                           // exp
            .signWith(privateKey, Jwts.SIG.RS256)         // RS256 sign
            .compact();                                   // → JWT string
}
```

### 4.2 Request — Gateway Verify Token

Đây là phần quan trọng nhất của cơ chế: **xác minh chữ ký RS256 tại Gateway**. Gateway không cần private key, chỉ cần public key.

#### Mô tả chi tiết

Khi client gửi request đến API Gateway với `Authorization: Bearer {accessToken}`, Gateway thực hiện các bước sau:

**Bước 1 — Trích xuất token từ header:**
- Lấy header `Authorization` từ HTTP request.
- Kiểm tra có bắt đầu bằng "Bearer " không.
- Cắt bỏ "Bearer " để lấy chuỗi JWT.
- Nếu header không tồn tại hoặc không đúng format → trả về 401 ngay lập tức.

**Bước 2 — Parse và verify chữ ký RS256:**
- JWT được tách thành 3 phần: `header.payload.signature`.
- Header được decode để biết thuật toán là RS256.
- Gateway tính lại chữ ký từ header + payload:
  ```
  expected_signature = RSA_verify(
      public_key,
      SHA256( base64(header) + "." + base64(payload) )
  )
  ```
- So sánh với signature trong token. Nếu không khớp → `SignatureException`.
- Nếu payload bị sửa (dù chỉ 1 ký tự), chữ ký tính lại sẽ khác → verify fail.
- Nếu token hết hạn (exp < now) → `ExpiredJwtException`.

**Bước 3 — Kiểm tra Redis blacklist:**
- Lấy `jti` (JWT ID) từ claims.
- Kiểm tra Redis key `jwt:blacklist:{jti}`.
- Nếu tồn tại → token đã bị thu hồi (logout).
- Nếu không tồn tại → token còn hiệu lực.

**Bước 4 — Inject thông tin user vào request:**
- Lấy `sub` (userId), `role`, `workspaceId` từ claims.
- Thêm vào request headers: `X-User-Id`, `X-User-Role`, `X-Workspace-Id`.
- Forward request đến downstream service (business-service, v.v.).

**Bước 5 — Business Service nhận request:**
- Không cần xác thực lại JWT.
- Đọc userId từ header `X-User-Id`.
- Toàn bộ logic chỉ dùng headers mà Gateway đã inject.

#### Giải thích về quá trình verify RS256

Khi Gateway nhận được JWT:

```
JWT:          eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxMjM0In0.rVf2kCj...

Tách ra:      header = eyJhbGciOiJSUzI1NiJ9
              payload = eyJzdWIiOiIxMjM0In0
              signature = rVf2kCj... (256 bytes cho RSA 2048-bit)

Giải mã:      header → {"alg": "RS256"}
              payload → {"sub": "1234", "exp": 1689005400, ...}

Verify:       1. Lấy header + payload: "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxMjM0In0"
              2. Băm SHA-256 → hash
              3. Giải mã signature bằng public key → hash gốc
              4. So sánh 2 hash: nếu bằng nhau → chữ ký hợp lệ
```

Nếu ai đó sửa payload thành `{"sub": "9999"}`:
- Chữ ký cũ không còn khớp với nội dung mới.
- Signature verification thất bại.
- Gateway trả về 401.

Nếu dùng HS256 (đối xứng):
- Gateway phải biết secret key giống Business Service.
- Nếu Gateway bị hack → mất luôn secret → attacker tạo token giả.

Với RS256:
- Gateway chỉ có public key → không thể tạo token giả dù có public key.
- Business Service giữ an toàn private key.

#### Sơ đồ

```
Client                     API Gateway                      Business Service
  │                              │                                  │
  │  GET /api/v1/...             │                                  │
  │  Authorization: Bearer {AT}  │                                  │
  │─────────────────────────────>│                                  │
  │                              │                                  │
  │                     JwtAuthFilter.apply()                       │
  │                       │                                         │
  │                       ├── Lấy header Authorization              │
  │                       ├── null hoặc không Bearer? → 401         │
  │                       ├── Cắt "Bearer " → token                 │
  │                       │                                         │
  │                       └── jwtUtil.validateAndExtract(token)     │
  │                              │                                  │
  │                     JwtUtil.validateAndExtract()                 │
  │                       ├── parseSignedClaims → verify RS256      │
  │                       │   ├── public.pem decrypt signature      │
  │                       │   ├── so sánh hash                      │
  │                       │   ├── không khớp → JwtException         │
  │                       │   └── hết hạn → JwtException            │
  │                       │                                         │
  │                       ├── extract jti = claims.id               │
  │                       │                                         │
  │                       ├── Nếu có jti:                           │
  │                       │   └── Redis EXISTS jwt:blacklist:{jti}  │
  │                       │       ├── true → token revoked → 401    │
  │                       │       └── false → OK                    │
  │                       │                                         │
  │                       └── return Claims                         │
  │                              │                                  │
  │                     mutate request headers                      │
  │                       ├── X-User-Id = claims.sub                │
  │                       ├── X-User-Role = claims.role             │
  │                       ├── X-Workspace-Id = claims.workspaceId   │
  │                       └── X-Request-ID                          │
  │                              │                                  │
  │                     forward với headers                         │
  │────────────────────────────────────────────────────────────────>│
  │                              │                                  │
  │                              │   handle request                  │
  │                              │   @RequestHeader("X-User-Id")    │
  │<────────────────────────────────────────────────────────────────│
```

#### Code — JwtAuthFilter (Gateway)

```java
// JwtAuthFilterGatewayFilterFactory.java
@Override
public GatewayFilter apply(Config config) {
    return (exchange, chain) -> {
        String authHeader = exchange.getRequest().getHeaders()
                .getFirst(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
            return unauthorized(exchange);  // → 401
        }

        String token = authHeader.substring(BEARER_PREFIX.length());

        return jwtUtil.validateAndExtract(token)  // RS256 verify + Redis check
                .flatMap(claims -> {
                    // Inject user info vào downstream headers
                    ServerHttpRequest mutated = exchange.getRequest().mutate()
                            .header("X-User-Id", claims.getSubject())
                            .header("X-User-Role", getClaimString(claims, "role"))
                            .header("X-Workspace-Id", getClaimString(claims, "workspaceId"))
                            .build();
                    return chain.filter(exchange.mutate().request(mutated).build());
                })
                .onErrorResume(JwtException.class, e -> unauthorized(exchange));
    };
}
```

**Giải thích filter:**
- `exchange`: Đối tượng ServerWebExchange chứa request/response.
- `chain.filter(...)`: Cho phép request đi tiếp trong Gateway pipeline.
- `onErrorResume(JwtException.class, ...)`: Bắt lỗi JWT → trả 401.
- `mutate()`: Clone request và thêm headers (immutable pattern).

#### Code — JwtUtil.validateAndExtract (Gateway)

```java
// JwtUtil.java (gateway)
public Mono<Claims> validateAndExtract(String token) {
    Claims claims;
    try {
        claims = Jwts.parser()
                .verifyWith(publicKey)  // RS256 verify bằng public key
                .build()
                .parseSignedClaims(token)
                .getPayload();
    } catch (JwtException e) {
        return Mono.error(e);  // signature sai / hết hạn
    }

    String jti = claims.getId();
    if (jti == null || jti.isBlank()) {
        return Mono.just(claims);  // không có jti → skip blacklist
    }

    return redisTemplate.hasKey(BLACKLIST_PREFIX + jti)
            .flatMap(blacklisted -> {
                if (Boolean.TRUE.equals(blacklisted)) {
                    return Mono.error(new JwtException("Token has been revoked"));
                }
                return Mono.just(claims);
            });
}
```

**Giải thích validateAndExtract:**
- `Jwts.parser().verifyWith(publicKey)`: Tạo parser với public key để verify RS256.
- `parseSignedClaims(token)`: Parse + verify trong 1 lần. Ném exception nếu không hợp lệ.
- `claims.getId()`: Lấy jti từ claims. Nếu null → skip (refresh token không có jti cũng skip).
- `redisTemplate.hasKey(...)`: Reactive Redis call, không blocking.
- `Mono.error(...)`: Trả về lỗi → upstream filter bắt và trả 401.
- `Mono.just(claims)`: Trả về claims thành công → filter inject headers.

### 4.3 Logout — Thu hồi Token

#### Mô tả

Khi người dùng logout, client gửi access token (qua Authorization header) và refresh token (qua cookie). Business Service thực hiện:

1. **Parse và verify access token**: Dùng public key (nội bộ) để giải mã và verify chữ ký.
2. **Lấy jti từ cả access token và refresh token**: Mỗi token có jti riêng.
3. **Blacklist cả 2 token vào Redis**: Redis key `jwt:blacklist:{jti}` với TTL = thời gian sống còn lại của token.
4. **Ghi audit log**: Logout event với IP, user-agent để theo dõi.

**Tại sao phải blacklist token thay vì chỉ xóa ở client?**
- Client-side deletion không đáng tin: attacker có thể đã copy token trước khi logout.
- Server-side blacklist đảm bảo token thực sự vô hiệu, bất kể client có làm gì.
- Vì access token chỉ sống 15 phút, TTL tự cleanup Redis → không cần cron job.

**Chi tiết blacklist:**
- TTL = `claims.getExpiration().getTime() - System.currentTimeMillis()`
- Nếu token còn 300 giây → Redis tự động xóa key sau 300 giây.
- Gateway kiểm tra Redis ở mỗi request → token bị blacklist sẽ bị từ chối ngay.

#### Sơ đồ

```
Client                     Business Service                     Redis
  │                              │                               │
  │  POST /api/v1/auth/logout    │                               │
  │  Authorization: Bearer {AT}  │                               │
  │  Cookie: refreshToken={RT}   │                               │
  │─────────────────────────────>│                               │
  │                              │                               │
  │                     AuthService.logout()                     │
  │                              │                               │
  │                       ├── jwtUtil.parseToken(AT)             │
  │                       │   ├── verifyWith(publicKey)          │
  │                       │   └── claims.getSubject() → userId   │
  │                       │                                     │
  │                       ├── jwtUtil.blacklistToken(AT)        │
  │                       │   ├── lấy jti từ claims             │
  │                       │   ├── tính TTL = exp - now           │
  │                       │   └── SETEX jwt:blacklist:{jti} TTL  │
  │                       │                                   ──>│
  │                       │                                     │
  │                       ├── jwtUtil.blacklistToken(RT) nếu có  │
  │                       │   ├── lấy jti từ claims             │
  │                       │   ├── tính TTL = exp - now           │
  │                       │   └── SETEX jwt:blacklist:{jti} TTL  │
  │                       │                                   ──>│
  │                       │                                     │
  │                       └── save AuditLog(LOGOUT)              │
  │                           ├── userId, ipAddress, userAgent   │
  │                           └── action = AUDIT_ACTION.LOGOUT   │
  │                              │                               │
  │  clear refreshToken cookie   │                               │
  │  200 OK { message: "ok" }    │                               │
  │<─────────────────────────────│                               │
```

#### Code — AuthService.logout

```java
// AuthService.java — business-service
public void logout(String accessToken, String refreshToken,
                   String ipAddress, String userAgent) {
    // 1. Parse + verify access token
    Claims claims = jwtUtil.parseToken(accessToken);  // tự verify nội bộ
    String userId = claims.getSubject();

    // 2. Blacklist access token
    jwtUtil.blacklistToken(accessToken);

    // 3. Blacklist refresh token (nếu có)
    if (refreshToken != null && !refreshToken.isBlank()) {
        jwtUtil.blacklistToken(refreshToken);
    }

    // 4. Ghi audit log
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

#### Code — blacklistToken

```java
// JwtUtil.java — business-service
public void blacklistToken(String token) {
    Claims claims = parseToken(token);          // verify RS256 trước
    String jti = claims.getId();                 // lấy unique token ID
    long ttl = claims.getExpiration().getTime() - System.currentTimeMillis();
    if (ttl > 0) {
        redis.opsForValue().set(
            "jwt:blacklist:" + jti,   // key
            "true",                     // value (không quan trọng)
            ttl,                        // TTL = thời gian còn lại của token
            TimeUnit.MILLISECONDS
        );
    }
}
```

### 4.4 Refresh Token

```
Client                     Business Service
  │                              │
  │  POST /api/v1/auth/refresh   │
  │  Cookie: refreshToken={RT}   │
  │─────────────────────────────>│
  │                              │
  │                     AuthService.refreshToken()
  │                       ├── parseToken(RT) → verify RS256
  │                       ├── validate: chưa hết hạn, user còn active
  │                       ├── blacklistToken(RT) → thu hồi refresh cũ
  │                       ├── generateAccessToken(userId, role, workspaceId)
  │                       └── generateRefreshToken(userId)
  │                              │
  │  { newAccessToken, newRefreshToken }
  │<─────────────────────────────│
```

---

## 5. Cấu trúc Token (Payload)

### 5.1 Access Token

Access token là JWT được ký RS256, dùng để xác thực request vào API. Chứa đầy đủ thông tin user.

**Header (do jjwt tự tạo):**
```json
{
  "alg": "RS256",
  "typ": "JWT"
}
```

**Payload (do application tự xây dựng):**
```json
{
  "sub": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "role": "OWNER",
  "workspaceId": "w1234567-89ab-cdef-0123-456789abcdef",
  "jti": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "iat": 1689000000,
  "exp": 1689005400
}
```

**Giải thích từng field:**

| Claim | Ý nghĩa | Ví dụ | Dùng để |
|-------|---------|-------|---------|
| `sub` | User ID (UUID) | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` | Xác định user duy nhất trong hệ thống |
| `role` | MemberRole trong workspace | `OWNER` | Phân quyền: OWNER, CREATOR, VIEWER, CLIENT, ACCOUNT |
| `workspaceId` | Workspace hiện tại | `w1234567-89ab-cdef-0123-456789abcdef` | Xác định workspace user đang làm việc |
| `jti` | Unique token ID | `f47ac10b...` | Blacklist khi logout, mỗi access token có 1 jti khác nhau |
| `iat` | Issued at (epoch seconds) | `1689000000` | Thời điểm token được tạo |
| `exp` | Expiration (epoch seconds) | `1689005400` | Token hết hạn lúc nào (Gateway từ chối nếu quá hạn) |

**Thời gian sống:**
- **Access Token**: 15 phút (`accessExpirationMs = 900000`)

Tại sao 15 phút? User thao tác liên tục nên access token short-lived là chuẩn. Nếu bị lộ, attacker chỉ dùng được trong thời gian ngắn. Khi hết hạn, client dùng refresh token để xin cấp access mới.

### 5.2 Refresh Token

Refresh token là JWT được ký RS256, dùng để xin cấp access token mới. **Không dùng để xác thực request API**, chỉ gửi qua cookie httpOnly.

```json
{
  "sub": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "jti": "b81d4eae-7dec-11d0-a765-00a0c91e6bf6",
  "iat": 1689000000,
  "exp": 1691592000
}
```

**Khác biệt với Access Token:**
- Chỉ chứa `sub` + `jti`, không có `role` hay `workspaceId`.
- Thời gian sống dài hơn: 30 ngày.
- Được lưu trong cookie httpOnly (không thể đọc bằng JavaScript).
- Khi refresh: Business verify refresh token → nếu OK → tạo access token mới + refresh token mới.

Tại sao refresh token không chứa role/workspace?
- Role có thể thay đổi trong 30 ngày (admin thay đổi quyền user).
- Khi refresh, Business Service sẽ query role mới nhất từ database.
- Dùng role cũ trong refresh token là không chính xác.

### 5.3 Cấu trúc hoàn chỉnh của JWT

```
JWT = Base64URL(Header) + "." + Base64URL(Payload) + "." + Base64URL(Signature)

Ví dụ:
eyJhbGciOiJSUzI1NiJ9.                       ← header
eyJzdWIiOiIxMjM0Iiwicm9sZSI6Ik9XTkVSIn0.    ← payload  
qJkG3X...                                     ← RS256 signature
```

**Signature** là phần quan trọng nhất:
- Được tạo từ private key (Business Service)
- Được verify bằng public key (Gateway)
- Bất kỳ sửa đổi nào ở header hoặc payload đều làm signature không khớp
- Ngăn chặn tấn công: attacker không thể tự tạo token (vì không có private key)
- Ngăn chặn tấn công: attacker không thể sửa token có sẵn (vì signature sẽ fail)

---

## 6. Redis Blacklist — Cơ chế thu hồi token

### 6.1 Tại sao cần blacklist?

JWT là stateless — không lưu session trên server. Một khi token được ký, server không thể "thu hồi" nó trừ khi kiểm tra danh sách đen. Đây là cơ chế bắt buộc của JWT-based auth.

### 6.2 Cách hoạt động

Khi logout hoặc refresh token, Business Service lưu `jti` vào Redis với TTL = thời gian còn lại của token:

```
Redis key format: jwt:blacklist:{jti}
Redis value:      "true"  (không quan trọng, chỉ cần tồn tại)
Redis TTL:        token.exp - System.currentTimeMillis() (ms)
Redis command:    SETEX jwt:blacklist:f47ac10b... 300000 true
```

**Giải thích chi tiết:**
- `jti` (JWT ID) là UUID duy nhất cho mỗi token.
- Khi tạo token, jti được sinh random bằng `UUID.randomUUID()`.
- Khi logout, Business Service parse token, lấy jti, SETEX vào Redis.
- Khi request đến Gateway, `validateAndExtract()` kiểm tra Redis EXISTS key này.
- Nếu EXISTS → token đã bị thu hồi → 401.
- TTL được set đúng bằng thời gian sống còn lại của token → tự động cleanup, không cần cron.

### 6.3 Ví dụ

Token được tạo lúc 10:00, hết hạn lúc 10:15.
User logout lúc 10:05.
→ Redis SETEX `jwt:blacklist:{jti}` 600000 (600 giây = 10 phút còn lại).
→ Redis tự động xóa key lúc 10:15.

Token còn 0 giây → TTL <= 0 → không blacklist (token đã hết hạn tự nhiên).

### 6.4 Tại sao không dùng database?

- Redis in-memory → kiểm tra nhanh (~1ms), không ảnh hưởng đến latency.
- TTL tự động xóa → không cần scheduled cleanup.
- Redis có sẵn trong infrastructure (dùng cho rate limiting).
- Database query mỗi request sẽ chậm hơn và tải DB hơn.

### 6.5 Rủi ro và cách giảm thiểu

| Rủi ro | Tác động | Cách giảm thiểu |
|---------|----------|-----------------|
| Redis down | Blacklist check fail → token revoked (fail closed) | Redis cluster + replication |
| Memory đầy | Key bị evict (nếu policy cho phép) | Redis maxmemory-policy: noeviction cho blacklist keys |
| Token có jti null | Skip blacklist check | Code handle: if jti null → skip (refresh token không có jti)

---

## 7. Docker Deployment

> **Cập nhật:** Không còn volume mount `.pem` nữa. Key content đi thẳng qua biến môi trường `JWT_PRIVATE_KEY` / `JWT_PUBLIC_KEY`.

### Environment (docker-compose.apps.yml)

```yaml
services:
  api-gateway:
    environment:
      JWT_PUBLIC_KEY: ${JWT_PUBLIC_KEY}

  business-service:
    environment:
      JWT_PRIVATE_KEY: ${JWT_PRIVATE_KEY}
      JWT_PUBLIC_KEY: ${JWT_PUBLIC_KEY}
```

Giá trị `JWT_PRIVATE_KEY` / `JWT_PUBLIC_KEY` được set trong `brandhub-infrastructure/docker/.env` (gitignored, không commit) — nội dung PEM gộp thành 1 dòng, ví dụ:

```
JWT_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----MIIEvgIBADANBgkq...-----END PRIVATE KEY-----
JWT_PUBLIC_KEY=-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0...-----END PUBLIC KEY-----
```

### Environment Variables

| Variable | Service | Bắt buộc? | Ghi chú |
|----------|---------|-----------|---------|
| `JWT_PRIVATE_KEY` | business | Có, không có default | Nội dung PEM private key, 1 dòng |
| `JWT_PUBLIC_KEY` | business | Có, không có default | Nội dung PEM public key, 1 dòng |
| `JWT_PUBLIC_KEY` | gateway | Có, không có default | Cùng giá trị public key với business |
| `JWT_ACCESS_EXPIRATION_MS` | business | Không, default `900000` | |
| `JWT_REFRESH_EXPIRATION_MS` | business | Không, default `2592000000` | |

Thiếu `JWT_PRIVATE_KEY`/`JWT_PUBLIC_KEY` → Spring context fail lúc startup với `IllegalArgumentException: Could not resolve placeholder`. Không có fallback path, không silent-skip.

---

## 8. RS256 vs HMAC (HS256) — Phân tích chi tiết

### 8.1 Bảng so sánh

| Tính chất | RS256 (Asymmetric) | HS256 (Symmetric) |
|-----------|-------------------|-------------------|
| Key | RSA key pair (private + public) | Single shared secret |
| Signer | Business Service (private key) | Any service with secret |
| Verifier | Gateway (public key) | Any service with secret |
| Bảo mật | Private key không bao giờ rời Business Service | Secret phải share cho mọi service |
| Rủi ro | Leak public key = vô hại (không thể sign) | Leak secret = ai cũng tạo được token giả |
| Performance | Chậm hơn (RSA 2048-bit math) | Nhanh hơn (HMAC-SHA256) |
| Key rotation | Chỉ cần update public key ở gateway | Phải update secret ở mọi service |
| Multi-instance | Dễ dàng: tất cả gateway instance dùng chung public key | An toàn: secret phải được share an toàn |

### 8.2 Ví dụ cụ thể

**Với HS256 (nếu BrandHub dùng):**
```
Secret: "brandhub-secret-key-123"
         ↑ mọi service đều biết secret này

Business Service ký:     JWT = sign("brandhub-secret-key-123", payload)
Gateway verify:          check = verify("brandhub-secret-key-123", JWT)
AI Service verify:       check = verify("brandhub-secret-key-123", JWT)

Nếu Gateway bị hack → attacker lấy được "brandhub-secret-key-123"
→ Attacker tạo token giả với role = "OWNER" → toàn bộ hệ thống compromised
```

**Với RS256:**
```
Private key: "-----BEGIN PRIVATE KEY-----..."   ← chỉ Business Service biết
Public key:  "-----BEGIN PUBLIC KEY-----..."     ← Gateway có thể public

Business Service ký:     JWT = sign(privateKey, payload)
Gateway verify:          check = verify(publicKey, JWT)

Nếu Gateway bị hack → attacker lấy được public key
→ Public key chỉ dùng để VERIFY, không thể ký
→ Attacker KHÔNG thể tạo token giả
→ Chỉ cần regenerate key pair + deploy lại public key cho Gateway
```

### 8.3 Tại sao BrandHub dùng RS256?

- **Gateway chỉ cần public key để verify** — không thể tạo token giả dù có public key.
- **Nếu Gateway bị compromise**, attacker không thể sign token mới (thiếu private key).
- **Business Service giữ private key an toàn** trong classpath/resources, không gửi qua mạng.
- **Kiến trúc microservices**: Nhiều Gateway instances đều dùng chung public key.
- **Key rotation dễ dàng**: Tạo cặp key mới, deploy lại public key cho Gateway, không cần restart Business.

### 8.4 Khi nào nên dùng HS256?

- Application monolithic (1 service duy nhất, không có gateway riêng).
- Internal communication giữa trusted services (same security domain).
- Performance-critical path (HS256 nhanh hơn RS256 ~10x).
- Nhưng BrandHub dùng microservices với API Gateway riêng → RS256 là lựa chọn đúng.

### 8.5 Benchmark — So sánh hiệu năng thực tế

Tham khảo bài benchmark độc lập từ [devops.vn](https://devops.vn/posts/hs256-vs-rs256-vs-es256-benchmark-jwt-verification/) — kiểm tra JWT verification với 3 thuật toán ở các mức tải khác nhau:

#### Kết quả Micro-Benchmark (thời gian verify 1 token)

| Thuật toán | Thời gian verify | CPU cần cho 30k RPS |
|-----------|-----------------|---------------------|
| **HS256** (HMAC-SHA256) | **~2–6 µs** | ~0.15 core |
| **RS256** (RSA-2048 + SHA256) | **~60–140 µs** | ~3 cores |
| **ES256** (ECDSA P-256 + SHA256) | **~90–220 µs** | ~4.8 cores |

#### Kết quả End-to-End ở 30k RPS (~800 concurrent)

| Thuật toán | p95 Latency thêm | p99 Latency thêm | CPU Server | Lỗi |
|-----------|-----------------|------------------|------------|------|
| **HS256** | ~0.2–0.4ms | ~0.6–1.0ms | ~35–45% | ~0% |
| **RS256** | ~1.5–2.8ms | ~3.5–6.0ms | ~75–90% | ~0–0.2% |
| **ES256** | ~2.2–3.8ms | ~5.0–9.0ms | ~90–100% | ~0.2–0.6% |

#### Kết quả Stress Test ở 50k RPS

| Thuật toán | Trạng thái |
|-----------|-----------|
| **HS256** | Ổn định: CPU ~65–75%, p99 ~2–4ms |
| **RS256** | **Bắt đầu timeout lác đác**, p99 auth ~8–15ms |
| **ES256** | **Dễ chạm trần CPU**, lỗi tăng, p99 auth ~12–25ms |

#### Phân tích kết quả benchmark

**HS256 nhanh nhất (~30-70x nhanh hơn RS256)** vì chỉ là HMAC-SHA256 — một phép hash đơn giản. Nhưng HS256 dùng chung 1 secret cho cả ký và verify → nếu Gateway bị hack, attacker tạo được token giả ngay lập tức. Không phù hợp với kiến trúc microservices tách biệt Gateway và Business Service.

**RS256 chậm hơn HS256 rõ rệt** (~60-140µs/verify) do phải tính toán RSA 2048-bit — giải mã signature bằng public key. Tuy nhiên vẫn "dễ sống nếu scale hợp lý": ở 30k RPS, RS256 thêm ~1.5-2.8ms p95 latency. Với BrandHub hiện tại (dự kiến < 1k RPS ở giai đoạn đầu), chi phí này hoàn toàn chấp nhận được — thời gian verify JWT (~0.1ms) nhỏ hơn nhiều so với tổng latency của request (bao gồm database query, business logic, network).

**ES256 chậm hơn cả RS256** dù được quảng cáo là "hiện đại hơn". Verify ECDSA P-256 đắt hơn RSA verify một chút do cách hoạt động của thuật toán (xem giải thích bên dưới). Token ES256 nhỏ hơn (64 bytes signature so với 256 bytes của RSA) nhưng lợi ích này không đáng kể với hệ thống server-to-server.

#### Tại sao ES256 verify chậm hơn RS256 dù key nhỏ hơn?

ECDSA P-256 dùng key 256-bit (nhỏ hơn RSA 2048-bit) nhưng **phép toán trên đường cong elliptic (EC point multiplication)** lại nặng hơn phép lũy thừa modulo của RSA. Cụ thể:

- **RSA verify**: Dùng public exponent nhỏ (thường là 65537, tức 2^16+1) → chỉ cần 17 phép nhân modulo → verify nhanh.
- **ECDSA verify**: Phải tính **scalar multiplication** trên đường cong elliptic — mỗi lần verify cần 2 phép nhân điểm EC → tổng chi phí cao hơn RSA verify.

Nói cách khác: RSA ký chậm nhưng verify nhanh. ECDSA ký nhanh nhưng verify chậm. Trong mô hình JWT, **verify xảy ra ở mỗi request** (tần suất cao), còn ký chỉ xảy ra khi login/refresh (tần suất thấp). → RS256 phù hợp hơn ES256 cho pattern này.

### 8.6 Kết luận — Tại sao BrandHub chọn RS256

**Quyết định:** Dùng RS256 cho toàn bộ JWT authentication trong BrandHub.

**Lý do chính (theo thứ tự ưu tiên):**

1. **Bảo mật phân tách (Separation of Concerns):**
   - Business Service giữ private key → ký token.
   - Gateway chỉ có public key → verify, **không thể tạo token giả**.
   - Đây là ưu điểm quyết định của asymmetric cryptography trong microservices.
   - Với HS256: một service bị hack → mất secret → toàn bộ hệ thống compromised.
   - Với RS256: Gateway bị hack → attacker chỉ có public key → **vẫn không tạo được token giả**.

2. **Hiệu năng chấp nhận được ở quy mô dự kiến:**
   - BrandHub giai đoạn đầu < 1k RPS, sau này < 10k RPS.
   - Mỗi request mất ~0.1ms để verify RS256 — không đáng kể so với database query (vài ms đến vài chục ms).
   - Gateway có thể scale ngang khi traffic tăng — thêm instance, không cần thay đổi kiến trúc.
   - Ở 30k RPS, RS256 thêm ~1.5-2.8ms p95 — vẫn trong ngưỡng chấp nhận được cho hầu hết API.

3. **Key Rotation linh hoạt:**
   - Cần rotate key (định kỳ hoặc sau sự cố): tạo cặp key mới → deploy public key cho Gateway → xong.
   - Không cần restart Business Service nếu public key được load từ file được mount.
   - Với HS256, rotate key = cập nhật tất cả service cùng lúc, dễ gây downtime.

4. **Tiêu chuẩn ngành & hệ sinh thái:**
   - RS256 là thuật toán phổ biến nhất cho JWT trong microservices.
   - Được hỗ trợ tốt bởi mọi thư viện JWT (jjwt, auth0-jwt, nimbus-jose).
   - Java standard library (`java.security.KeyFactory`, `X509EncodedKeySpec`) hỗ trợ RSA tốt.
   - Dễ dàng tích hợp OIDC/IdP nếu sau này cần.

5. **Không chọn ES256 vì:**
   - Verify chậm hơn RS256 (ngược với suy nghĩ thông thường là "key nhỏ hơn thì nhanh hơn").
   - Ở stress test 50k RPS, ES256 chạm trần CPU sớm nhất.
   - Token nhỏ hơn (64 bytes signature) không phải lợi ích đáng kể với server-to-server.
   - Hệ sinh thái Java hỗ trợ ECDSA không tốt bằng RSA (mặc dù vẫn dùng được).

**Đánh đổi đã chấp nhận:**
- RS256 chậm hơn HS256 ~30-70x → chấp nhận vì **bảo mật > hiệu năng thô** trong hệ thống xác thực.
- Signature 256 bytes (so với 32 bytes của HS256) → HTTP header tăng vài trăm bytes, không đáng kể.
- CPU cao hơn khi tải lớn → giải pháp: scale Gateway ngang, không phải đổi thuật toán.

**Khi nào cần xem xét lại:**
- BrandHub đạt > 30k RPS thường xuyên → cân nhắc thêm **caching layer** cho JWT verification (cache kết quả verify theo jti trong ~5 giây).
- Latency trở thành bottleneck → tối ưu trước khi đổi thuật toán: JWKS caching, connection pooling, async verify pipeline.
- **Không khuyến nghị chuyển sang HS256 chỉ vì hiệu năng** — đánh đổi bảo mật quá lớn (một service bị hack là mất toàn bộ hệ thống).

---

## 9. Cơ chế load Public Key tại Gateway

### 9.1 Mô tả

Gateway load public key từ biến môi trường một lần duy nhất lúc startup (qua `@PostConstruct`). Không load per-request vì:
- Public key không thay đổi trong runtime (trừ khi deploy lại).
- KeyFactory.generatePublic() là operation tương đối nặng.

Không còn đọc từ file `.pem`/`Resource` — env var là nguồn duy nhất, không có fallback.

### 9.2 Code

```java
@Component
public class JwtUtil {
    private static final Logger log = LoggerFactory.getLogger(JwtUtil.class);

    @Value("${jwt.public-key}")
    String publicKeyPem;

    private PublicKey publicKey;

    @PostConstruct
    public void loadPublicKey() throws Exception {
        String base64 = publicKeyPem
                .replace("-----BEGIN PUBLIC KEY-----", "")
                .replace("-----END PUBLIC KEY-----", "")
                .replaceAll("\\s", "");
        byte[] decoded = Base64.getDecoder().decode(base64);
        publicKey = KeyFactory.getInstance("RSA")
                .generatePublic(new X509EncodedKeySpec(decoded));
        log.info("JWT RS256 public key loaded from env JWT_PUBLIC_KEY");
    }
}
```

### 9.3 Cấu hình (application.yml)

```yaml
jwt:
  public-key: ${JWT_PUBLIC_KEY}
```

Không có default — thiếu `JWT_PUBLIC_KEY` là Spring context fail ngay lúc khởi động (`Could not resolve placeholder`), không start silently với key sai/thiếu.

### 9.4 Quy trình load key

```
Spring Boot start
  → @PostConstruct JwtUtil.loadPublicKey()
    → Đọc giá trị từ env JWT_PUBLIC_KEY (bắt buộc, không default)
    → Parse PEM: bỏ header/footer, decode Base64
    → KeyFactory.getInstance("RSA").generatePublic(spec)
    → publicKey sẵn sàng cho toàn bộ vòng đời application
    → 
  Request đến
    → JwtUtil.validateAndExtract(token)
      → Jwts.parser().verifyWith(publicKey)  ← dùng publicKey đã load
      → parseSignedClaims → verify RS256
```

---

## 11. Public Paths — Các Route Không Bị JWT Chặn

Public paths không qua `JwtAuthFilter` — cấu hình trong `application.yml`:

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: auth-public
          uri: lb://business-service
          predicates:
            - Path=/api/v1/auth/**
          filters:
            - StripPrefix=1
            # Không có JwtAuthFilter — public
```

Các path public:
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/forgot-password` (future)
- `POST /api/v1/auth/reset-password` (future)

Internal services (AI, Publisher) dùng `INTERNAL_SERVICE_KEY` (symmetric shared key) thay vì JWT.

---

## 12. Tóm tắt Luồng

```
1. [Login]     Client → POST /api/v1/auth/login
               Business Service:
                 ├── Xác thực email + password
                 ├── generateAccessToken() → RS256 sign với private.pem
                 ├── generateRefreshToken() → RS256 sign với private.pem
                 └── { accessToken (15 phút), refreshToken (30 ngày) }

2. [Request]   Client → GET /api/v1/... Authorization: Bearer {AT}
               API Gateway:
                 ├── JwtAuthFilter bắt header
                 ├── JwtUtil.validateAndExtract()
                 │   ├── RS256 verify với public.pem
                 │   ├── Redis EXISTS jwt:blacklist:{jti}
                 │   └── OK → claims
                 ├── Inject: X-User-Id, X-User-Role, X-Workspace-Id
                 └── Forward request đến Business Service

3. [Logout]    Client → POST /api/v1/auth/logout
               Business Service:
                 ├── parseToken(AT) → RS256 verify
                 ├── blacklistToken(AT) → Redis SETEX jwt:blacklist:{jti}
                 ├── blacklistToken(RT) → Redis SETEX jwt:blacklist:{jti}
                 └── AuditLog(LOGOUT)

4. [Refresh]   Client → POST /api/v1/auth/refresh
               Business Service:
                 ├── parseToken(RT) → RS256 verify
                 ├── blacklistToken(RT) → thu hồi refresh cũ
                 ├── generateAccessToken(userId, role, workspaceId)
                 └── generateRefreshToken(userId)

```

Ba service tham gia:

```
┌──────────┐     Token     ┌──────────────┐     Headers     ┌──────────────────┐
│  Client  │ ─────────────>│ API Gateway  │ ───────────────>│ Business Service │
│ (Browser)│               │ (verify RS256│                 │ (sign RS256)     │
│    giữ   │               │  + Redis)    │                 │  private.pem     │
│  token   │<─────────────│  public.pem  │<────────────────│  + public.pem    │
└──────────┘     Token     └──────────────┘    Response     └──────────────────┘
```

**Nguyên tắc bảo mật quan trọng:**
- Private key chỉ có ở Business Service — không bao giờ gửi qua mạng.
- Public key có ở Gateway và Business — leak public key là vô hại.
- Redis blacklist là cơ chế bắt buộc vì JWT stateless không thể revoked.
- Access token short-lived (15 phút) giảm thiểu rủi ro nếu token bị lộ.

---

## 13. Verification Commands

Các lệnh dưới thao tác trên file `.pem` tạm thời (lúc generate key mới) — key thật không lưu file lâu dài, chỉ tồn tại trong biến môi trường (mục 7, 9).

Kiểm tra key pair có match không:

```bash
# Lấy public key từ private key
openssl pkey -in private.pem -pubout -outform PEM | openssl md5

# MD5 của file public.pem hiện tại
openssl pkey -in public.pem -pubin -pubout -outform PEM | openssl md5

# Hai MD5 phải giống nhau
```

Gen test token để verify:

```bash
# Gen RS256 test token (dùng jwt-cli hoặc jose)
jose jws sig -I '{"sub":"test"}' -k private.pem -a RS256 -c

# Verify bằng public key
jose jws ver -I <token> -k public.pem
```

### Đưa key mới vào env sau khi generate

```bash
# Nén PEM thành 1 dòng (bỏ newline) rồi gán vào .env
PRIV_ONELINE=$(tr -d '\n' < private.pem)
PUB_ONELINE=$(tr -d '\n' < public.pem)
echo "JWT_PRIVATE_KEY=$PRIV_ONELINE"   # dán vào business-service/.env
echo "JWT_PUBLIC_KEY=$PUB_ONELINE"     # dán vào business-service/.env + api-gateway/.env + docker/.env

# Sau khi copy vào .env, xoá file .pem tạm — không giữ lại trên disk
rm private.pem public.pem
```

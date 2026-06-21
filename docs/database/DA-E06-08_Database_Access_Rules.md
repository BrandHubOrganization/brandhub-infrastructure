# DA-E06-08 — Database Access Rules

> **Task:** Document mandatory data access rules as a non-negotiable implementation contract.  
> **Owner:** Trung (Leader) | **Priority:** 🔴 Critical  
> **Blocks:** DA-E07-01 | **Blocked by:** DA-E06-02, DA-E06-03

---

## Mục đích

Document này là **implementation contract** — không phải guideline tùy chọn. Mọi developer viết query MongoDB phải tuân thủ tuyệt đối. Vi phạm = data leak giữa các workspace/client.

---

## Rule 1 — workspaceId bắt buộc trong mọi MongoDB query

> **Mọi query trên multi-tenant collection đều phải có `{ workspaceId: <value> }` làm filter condition. Không có ngoại lệ.**

### 1.1 Các collection bắt buộc có workspaceId filter

| Collection | workspaceId field | Ghi chú |
|---|---|---|
| `users` | `workspace_id` | ADMIN có thể query by `_id`/`email` không cần workspace filter |
| `workspace_members` | `workspace_id` | |
| `clients` | `workspace_id` | |
| `social_accounts` | `workspace_id` | |
| `posts` | `workspace_id` | |
| `content_requests` | `workspace_id` | |
| `knowledge_documents` | `workspace_id` | |
| `notifications` | `workspace_id` | Filter thêm `user_id` — user chỉ thấy notification của mình |
| `publish_logs` | `workspace_id` | |
| `ai_usage_logs` | `workspace_id` | |
| `report_jobs` | `workspace_id` | |

> **Collection không áp dụng Rule 1:**
> - `workspaces` — query chính nó bằng `_id`, không có field `workspace_id` nội tại
> - `audit_logs` (PostgreSQL) — ADMIN-level, `workspace_id` nullable
> - `subscription_plans` (PostgreSQL) — master data toàn cục, không có workspace scope

### 1.2 Code example — Java / Spring Data MongoDB

```java
// ❌ SAI — không có workspaceId, leak data toàn bộ hệ thống
List<Post> findByStatus(PostStatus status);

// ✅ ĐÚNG — luôn filter theo workspaceId
List<Post> findByWorkspaceIdAndStatus(String workspaceId, PostStatus status);
```

```java
// ❌ SAI — custom query thiếu workspaceId
@Query("{ 'status': ?0 }")
List<Post> findByStatusRaw(String status);

// ✅ ĐÚNG
@Query("{ 'workspace_id': ?0, 'status': ?1 }")
List<Post> findByWorkspaceIdAndStatusRaw(String workspaceId, String status);
```

```java
// ❌ SAI — ReactiveMongoTemplate không có workspaceId
Query query = new Query(Criteria.where("status").is(PostStatus.PUBLISHED));
mongoTemplate.find(query, Post.class);

// ✅ ĐÚNG
Query query = new Query(
    Criteria.where("workspace_id").is(workspaceId)
            .and("status").is(PostStatus.PUBLISHED)
);
mongoTemplate.find(query, Post.class);
```

---

## Rule 2 — BRAND_CLIENT thêm clientId filter bắt buộc

> **Mọi query thực hiện trong context của role `BRAND_CLIENT` phải có thêm `{ clientId: <value> }` bên cạnh `workspaceId`. BRAND_CLIENT chỉ được đọc data của client mình.**

### 2.1 Lý do

`BRAND_CLIENT` là portal user của client — họ thuộc một workspace nhưng chỉ được xem data của brand mình, không được xem data của các brand khác trong cùng workspace.

```
Workspace A
├── Client X  (BRAND_CLIENT: user_x)  → chỉ thấy posts của Client X
├── Client Y  (BRAND_CLIENT: user_y)  → chỉ thấy posts của Client Y
└── ACCOUNT_MANAGER                   → thấy tất cả clients trong workspace
```

### 2.2 Collections cần thêm clientId filter cho BRAND_CLIENT

| Collection | clientId field | Ghi chú |
|---|---|---|
| `posts` | `client_id` | |
| `content_requests` | `client_id` | |
| `social_accounts` | `client_id` | |
| `report_jobs` | `client_id` | |
| `knowledge_documents` | `client_id` | |
| `notifications` | `user_id` | Không filter `client_id` — filter `user_id = ctx.userId()` thay thế |

### 2.3 Code example — Java / Spring Data MongoDB

```java
// ❌ SAI — BRAND_CLIENT đọc được post của tất cả clients trong workspace
@Query("{ 'workspace_id': ?0, 'status': ?1 }")
List<Post> findPosts(String workspaceId, String status);

// ✅ ĐÚNG — thêm clientId khi role = BRAND_CLIENT
@Query("{ 'workspace_id': ?0, 'client_id': ?1, 'status': ?2 }")
List<Post> findPostsByClient(String workspaceId, String clientId, String status);
```

```java
// ✅ ĐÚNG — service layer tự inject filter theo role
public Flux<Post> getPosts(SecurityContext ctx, PostStatus status) {
    Criteria criteria = Criteria.where("workspace_id").is(ctx.getWorkspaceId())
                                .and("status").is(status);

    // Thêm clientId filter nếu là BRAND_CLIENT
    if (ctx.getRole() == UserRole.BRAND_CLIENT) {
        criteria = criteria.and("client_id").is(ctx.getClientId());
    }

    return mongoTemplate.find(new Query(criteria), Post.class);
}
```

---

## Rule 3 — workspaceId lấy từ JWT, không từ request body

> **`workspaceId` phải được extract từ JWT claim, không được nhận từ client request body hay query param.**

### 3.1 Flow

```
Client request
    ↓
api-gateway: validate JWT → extract workspaceId, userId, role, clientId
    ↓ set header
X-Workspace-Id: <workspaceId>
X-User-Id: <userId>
X-User-Role: <role>
X-Client-Id: <clientId>   ← có giá trị khi role = BRAND_CLIENT, null với role khác
    ↓
business-service: đọc từ header, không tin request body
```

> **JWT claim phải chứa `clientId`** khi user có role `BRAND_CLIENT`. Claim này được set lúc login và không thay đổi trong suốt session. api-gateway forward qua header `X-Client-Id`.

### 3.2 Code example — Spring Security Context

```java
// SecurityContext — inject vào mọi request
public record SecurityContext(
    String userId,
    String workspaceId,
    String clientId,      // null nếu không phải BRAND_CLIENT
    UserRole role
) {}

// Filter extract từ header (set bởi api-gateway)
@Component
public class WorkspaceContextFilter implements WebFilter {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String workspaceId = exchange.getRequest().getHeaders()
                                     .getFirst("X-Workspace-Id");
        String userId      = exchange.getRequest().getHeaders()
                                     .getFirst("X-User-Id");
        String role        = exchange.getRequest().getHeaders()
                                     .getFirst("X-User-Role");

        String clientId = exchange.getRequest().getHeaders()
                                     .getFirst("X-Client-Id"); // null nếu không phải BRAND_CLIENT
        SecurityContext ctx = new SecurityContext(userId, workspaceId, clientId, UserRole.valueOf(role));
        return chain.filter(exchange)
                    .contextWrite(Context.of("securityContext", ctx));
    }
}
```

```java
// ❌ SAI — tin workspaceId từ request body
@PostMapping("/posts")
public Mono<Post> createPost(@RequestBody CreatePostRequest req) {
    return postService.create(req.getWorkspaceId(), req);  // client tự khai workspaceId!
}

// ✅ ĐÚNG — lấy từ SecurityContext
@PostMapping("/posts")
public Mono<Post> createPost(
    @RequestAttribute("securityContext") SecurityContext ctx,
    @RequestBody CreatePostRequest req
) {
    return postService.create(ctx.workspaceId(), req);
}
```

---

## Rule 4 — Enforcement tại Repository layer (không phải Service)

> **Filter workspaceId phải được enforce tại repository layer, không để từng developer tự nhớ thêm vào service layer.**

### 4.1 Pattern — Base Repository với workspaceId built-in

```java
// Base repository tự inject workspaceId vào mọi query
public abstract class WorkspaceScopedRepository<T> {

    protected final ReactiveMongoTemplate mongoTemplate;
    protected final Class<T> entityClass;

    // Mọi find đều bắt buộc có workspaceId
    protected Flux<T> findAll(String workspaceId, Criteria additionalCriteria) {
        Criteria criteria = Criteria.where("workspace_id").is(workspaceId)
                                    .andOperator(additionalCriteria);
        return mongoTemplate.find(new Query(criteria), entityClass);
    }

    protected Mono<T> findOne(String workspaceId, Criteria additionalCriteria) {
        Criteria criteria = Criteria.where("workspace_id").is(workspaceId)
                                    .andOperator(additionalCriteria);
        return mongoTemplate.findOne(new Query(criteria), entityClass);
    }
}

// PostRepository kế thừa — không thể query thiếu workspaceId
@Repository
public class PostRepository extends WorkspaceScopedRepository<Post> {

    public Flux<Post> findByStatus(String workspaceId, PostStatus status) {
        return findAll(workspaceId, Criteria.where("status").is(status));
    }
}
```

### 4.2 Pattern — @Query với SpEL inject workspaceId tự động

```java
// Dùng Spring Security SpEL để inject từ SecurityContext
@Query("{ 'workspace_id': ?#{@securityService.currentWorkspaceId()}, 'status': ?0 }")
Flux<Post> findByStatus(PostStatus status);
```

---

## Rule 5 — PostgreSQL: workspace_id trong mọi query financial

> **Mọi query trên `invoices`, `payments`, `workspace_subscriptions` phải có `workspace_id` trong WHERE clause.**

```java
// ❌ SAI
invoiceRepository.findAll();

// ✅ ĐÚNG
invoiceRepository.findByWorkspaceId(ctx.workspaceId());
```

```sql
-- ❌ SAI
SELECT * FROM invoices WHERE status = 'PAID';

-- ✅ ĐÚNG
SELECT * FROM invoices WHERE workspace_id = $1 AND status = 'PAID';
```

---

## Tóm tắt — Decision matrix

| Role | Cần workspaceId | Cần clientId | Collections bị giới hạn |
|---|---|---|---|
| `ADMIN` | ❌ (global access) | ❌ | Không — truy cập toàn hệ thống |
| `AGENCY_OWNER` | ✅ | ❌ | Tất cả trong workspace |
| `ACCOUNT_MANAGER` | ✅ | ❌ | Tất cả trong workspace |
| `CONTENT_CREATOR` | ✅ | ❌ | Tất cả trong workspace |
| `BRAND_CLIENT` | ✅ | ✅ | posts, content_requests, social_accounts, report_jobs, knowledge_documents |

---

## Acceptance Criteria

- [x] Rule 1: workspaceId bắt buộc trong mọi MongoDB query — documented với code example vi phạm vs đúng
- [x] Rule 2: BRAND_CLIENT thêm clientId filter — documented với code example
- [x] Rule 3: workspaceId lấy từ JWT/header, không từ request body
- [x] Rule 4: Enforcement tại repository layer, không để service tự nhớ
- [x] Rule 5: PostgreSQL financial tables cũng cần workspace_id filter
- [x] Code examples theo Java/Spring Data style
- [x] Decision matrix theo role

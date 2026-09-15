# DA-E06-08 — Database Access Rules V2

> **STATUS: DESIGN** — cập nhật theo schema V2 (Agency → Workspace → Media Package → Media Campaign → Task), chưa áp dụng vào code `business-service` thật.
> **Task:** Document mandatory data access rules as a non-negotiable implementation contract.
> **Owner:** Trung (Leader) | **Priority:** 🔴 Critical
> **Nguồn:** `docs/database/database-strategy.md`, `docs/ba/11-data-entities-glossary.md`

---

## Mục đích

Document này là **implementation contract** — không phải guideline tùy chọn. Mọi developer viết query MongoDB phải tuân thủ tuyệt đối. Vi phạm = data leak giữa các workspace/client.

### Thay đổi lớn nhất so với V1

- `CLIENT` không còn là bảng `clients` riêng — giờ là `workspace_members.role = 'CLIENT'` liên kết `client_profile_id`. Filter theo `clientProfileId`, không phải `clientId` như V1.
- Thêm tầng Agency phía trên Workspace — khi Owner truy vấn xuyên nhiều Workspace (toàn Agency), cần Rule mới (Rule 6).
- Danh sách collection thay đổi hoàn toàn theo entity V2 (`tasks`/`task_approvals`/`posts` đổi nghĩa, thêm `material_repository`/`brand_collections`/`hashtag_collections`/`content_versions`).

---

## Rule 1 — workspaceId bắt buộc trong mọi MongoDB query

> **Mọi query trên multi-tenant collection đều phải có `{ workspaceId: <value> }` làm filter condition. Không có ngoại lệ.**

### 1.1 Các collection bắt buộc có workspaceId filter

| Collection | workspaceId field | Ghi chú |
|---|---|---|
| `tasks` | `workspaceId` | |
| `task_approvals` | — (không trực tiếp) | Filter qua `taskId` → phải verify `task.workspaceId` trước khi trả kết quả |
| `posts` | `workspaceId` | Chỉ bài đã publish (đổi nghĩa V2) |
| `content_requests` | `workspaceId` | |
| `material_repository` | `workspaceId` | |
| `brand_collections` | `workspaceId` | |
| `hashtag_collections` | `workspaceId` | |
| `content_versions` | — (không trực tiếp) | Filter qua `taskId` → verify `task.workspaceId` |
| `social_accounts` | `workspaceId` | |
| `notifications` | `workspaceId` | Filter thêm `userId` — user chỉ thấy notification của mình |

> **Collection không áp dụng Rule 1:**
> - `knowledge_documents`, `ai_usage_logs` (ai-service) — vẫn filter `workspaceId`, không đổi so với V1
> - `publish_logs` (publisher-service) — vẫn filter `workspaceId`, không đổi
> - `audit_logs` (PostgreSQL) — ADMIN-level, `agency_id` nullable (đổi từ `workspace_id` V1 vì audit giờ theo Agency)

### 1.2 Code example — Java / Spring Data MongoDB

```java
// ❌ SAI — không có workspaceId, leak data toàn bộ hệ thống
List<Task> findByStatus(TaskStatus status);

// ✅ ĐÚNG — luôn filter theo workspaceId
List<Task> findByWorkspaceIdAndStatus(String workspaceId, TaskStatus status);
```

```java
// ❌ SAI — custom query thiếu workspaceId
@Query("{ 'status': ?0 }")
List<Task> findByStatusRaw(String status);

// ✅ ĐÚNG
@Query("{ 'workspaceId': ?0, 'status': ?1 }")
List<Task> findByWorkspaceIdAndStatusRaw(String workspaceId, String status);
```

```java
// task_approvals: KHÔNG có workspaceId trực tiếp — phải verify qua taskId trước
public Flux<TaskApproval> getApprovals(SecurityContext ctx, String taskId) {
    return taskRepository.findByIdAndWorkspaceId(taskId, ctx.getWorkspaceId())
        .flatMapMany(task -> taskApprovalRepository.findByTaskId(taskId));
    // Nếu task không tồn tại trong workspace hiện tại → Mono rỗng → không leak
}
```

---

## Rule 2 — CLIENT thêm clientProfileId filter bắt buộc (ĐỔI V2 từ clientId)

> **Mọi query thực hiện trong context của role `CLIENT` phải có thêm filter theo `clientProfileId` bên cạnh `workspaceId`. CLIENT chỉ được đọc data liên quan tới mình.**

### 2.1 Lý do (đổi khái niệm V2)

`CLIENT` giờ là 1 giá trị `role` trong `workspace_members` (liên kết `client_profile_id`), KHÔNG còn bảng `clients` riêng như V1. `client_profiles` là entity **tái sử dụng xuyên nhiều Agency/Workspace** — cùng 1 `clientProfileId` có thể xuất hiện ở nhiều Workspace khác nhau (của các Agency khác nhau), nhưng mỗi lần chỉ filter trong phạm vi `workspaceId` hiện tại + `clientProfileId` của chính họ.

```
Workspace A (Agency FPT)
├── workspace_members: role=CLIENT, client_profile_id=X  → chỉ thấy Task/Content của mình trong Workspace A
├── workspace_members: role=CLIENT, client_profile_id=Y  → chỉ thấy Task/Content của mình trong Workspace A
└── workspace_members: role=MANAGER                       → thấy tất cả Client trong Workspace A

Workspace B (Agency Sunrise) — client_profile_id=X CÓ THỂ xuất hiện lại ở đây (tái sử dụng profile)
└── workspace_members: role=CLIENT, client_profile_id=X   → 1 profile, quyền độc lập theo TỪNG Workspace
```

### 2.2 Collections cần thêm clientProfileId filter cho CLIENT

| Collection | Field liên kết Client | Ghi chú |
|---|---|---|
| `tasks` | — (không trực tiếp) | Task không có field Client trực tiếp — CLIENT chỉ thấy Task ở bước `CLIENT_REVIEW` mà `sourceRefId` (Campaign) thuộc `workspace_media_package` mà họ tham gia đàm phán, HOẶC Task sinh từ `content_requests.createdByClientProfileId` của chính họ |
| `content_requests` | `createdByClientProfileId` | CLIENT chỉ thấy Content Request do chính mình tạo |
| `posts` | — (không trực tiếp) | Filter qua `task.workspaceId`, CLIENT chỉ xem Post publish trong Workspace mình tham gia — không cần filter theo profile vì Post là kết quả công khai của Campaign |
| `notifications` | `userId` | Filter `userId = ctx.userId()` — Client phải có `linked_user_id` set (đã tự đăng ký) mới nhận notification |

> **Khác biệt quan trọng V2:** CLIENT không filter Task theo "sở hữu" trực tiếp như `posts.clientId` V1 — vì Task giờ thuộc về Campaign/Workspace chung, CLIENT chỉ nhìn thấy Task khi tới lượt họ duyệt (`status = CLIENT_REVIEW`) hoặc do chính họ tạo qua Content Request.

### 2.3 Code example — Java / Spring Data MongoDB

```java
// ❌ SAI — CLIENT đọc được mọi content_request trong workspace
@Query("{ 'workspaceId': ?0 }")
List<ContentRequest> findRequests(String workspaceId);

// ✅ ĐÚNG — thêm clientProfileId khi role = CLIENT
@Query("{ 'workspaceId': ?0, 'createdByClientProfileId': ?1 }")
List<ContentRequest> findRequestsByClient(String workspaceId, String clientProfileId);
```

```java
// ✅ ĐÚNG — service layer tự inject filter theo role, khác logic Task vs ContentRequest
public Flux<Task> getTasksForReview(SecurityContext ctx) {
    if (ctx.getRole() == WorkspaceRole.CLIENT) {
        // CLIENT chỉ thấy Task đang chờ CHÍNH HỌ duyệt
        return taskRepository.findByWorkspaceIdAndStatus(
            ctx.getWorkspaceId(), TaskStatus.CLIENT_REVIEW);
    }
    return taskRepository.findByWorkspaceId(ctx.getWorkspaceId());
}
```

---

## Rule 3 — workspaceId lấy từ JWT, không từ request body

> **`workspaceId` phải được extract từ JWT claim, không được nhận từ client request body hay query param.**

### 3.1 Flow (cập nhật claim V2: thêm agencyId, đổi clientId → clientProfileId)

```
Client request
    ↓
api-gateway: validate JWT → extract workspaceId, agencyId, userId, role, clientProfileId
    ↓ set header
X-Workspace-Id: <workspaceId>
X-Agency-Id: <agencyId>          ← MỚI V2, cần khi Owner query xuyên Workspace (Rule 6)
X-User-Id: <userId>
X-User-Role: <role>              ← role theo TỪNG Workspace, không cố định
X-Client-Profile-Id: <clientProfileId>  ← ĐỔI TÊN V2 từ X-Client-Id, có giá trị khi role = CLIENT
    ↓
business-service: đọc từ header, không tin request body
```

> **JWT claim `role` giờ luôn phải kèm `workspaceId` context** — vì role không còn cố định theo User như V1 (`SystemRole` chỉ có ADMIN/USER), mà thay đổi theo TỪNG Workspace user đang truy cập. Token phải re-issue hoặc re-lookup role khi user chuyển Workspace.

### 3.2 Code example — Spring Security Context

```java
// SecurityContext — inject vào mọi request, ĐỔI V2: thêm agencyId, đổi tên clientId
public record SecurityContext(
    String userId,
    String agencyId,           // MỚI V2
    String workspaceId,
    String clientProfileId,    // ĐỔI TÊN V2 từ clientId — null nếu không phải CLIENT
    WorkspaceRole role         // role trong workspaceId hiện tại, KHÔNG cố định toàn cục
) {}

@Component
public class WorkspaceContextFilter implements WebFilter {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        var headers = exchange.getRequest().getHeaders();
        String workspaceId      = headers.getFirst("X-Workspace-Id");
        String agencyId         = headers.getFirst("X-Agency-Id");
        String userId           = headers.getFirst("X-User-Id");
        String role             = headers.getFirst("X-User-Role");
        String clientProfileId  = headers.getFirst("X-Client-Profile-Id");

        SecurityContext ctx = new SecurityContext(
            userId, agencyId, workspaceId, clientProfileId, WorkspaceRole.valueOf(role));
        return chain.filter(exchange)
                    .contextWrite(Context.of("securityContext", ctx));
    }
}
```

```java
// ❌ SAI — tin workspaceId từ request body
@PostMapping("/tasks")
public Mono<Task> createTask(@RequestBody CreateTaskRequest req) {
    return taskService.create(req.getWorkspaceId(), req);  // client tự khai workspaceId!
}

// ✅ ĐÚNG — lấy từ SecurityContext
@PostMapping("/tasks")
public Mono<Task> createTask(
    @RequestAttribute("securityContext") SecurityContext ctx,
    @RequestBody CreateTaskRequest req
) {
    return taskService.create(ctx.workspaceId(), req);
}
```

---

## Rule 4 — Enforcement tại Repository layer (không phải Service)

> **Filter workspaceId phải được enforce tại repository layer, không để từng developer tự nhớ thêm vào service layer.** (Không đổi nguyên tắc so với V1.)

### 4.1 Pattern — Base Repository với workspaceId built-in

```java
public abstract class WorkspaceScopedRepository<T> {
    protected final ReactiveMongoTemplate mongoTemplate;
    protected final Class<T> entityClass;

    protected Flux<T> findAll(String workspaceId, Criteria additionalCriteria) {
        Criteria criteria = Criteria.where("workspaceId").is(workspaceId)
                                    .andOperator(additionalCriteria);
        return mongoTemplate.find(new Query(criteria), entityClass);
    }

    protected Mono<T> findOne(String workspaceId, Criteria additionalCriteria) {
        Criteria criteria = Criteria.where("workspaceId").is(workspaceId)
                                    .andOperator(additionalCriteria);
        return mongoTemplate.findOne(new Query(criteria), entityClass);
    }
}

// TaskRepository kế thừa — không thể query thiếu workspaceId
@Repository
public class TaskRepository extends WorkspaceScopedRepository<Task> {
    public Flux<Task> findByStatus(String workspaceId, TaskStatus status) {
        return findAll(workspaceId, Criteria.where("status").is(status));
    }
}
```

### 4.2 Pattern MỚI V2 — Repository cho collection không có workspaceId trực tiếp

`task_approvals` và `content_versions` không có `workspaceId` trực tiếp (chỉ có `taskId`) — bắt buộc verify qua `Task` trước:

```java
@Repository
public class TaskApprovalRepository {
    private final TaskRepository taskRepository;
    private final ReactiveMongoTemplate mongoTemplate;

    // Bắt buộc đi qua verify này — KHÔNG expose method query trực tiếp theo taskId
    public Flux<TaskApproval> findByTaskIdScoped(String workspaceId, String taskId) {
        return taskRepository.findByIdAndWorkspaceId(taskId, workspaceId)
            .flatMapMany(task -> mongoTemplate.find(
                new Query(Criteria.where("taskId").is(taskId)), TaskApproval.class))
            .switchIfEmpty(Flux.empty()); // Task không tồn tại trong workspace → rỗng, không leak
    }
}
```

### 4.3 Pattern — @Query với SpEL inject workspaceId tự động

```java
@Query("{ 'workspaceId': ?#{@securityService.currentWorkspaceId()}, 'status': ?0 }")
Flux<Task> findByStatus(TaskStatus status);
```

---

## Rule 5 — PostgreSQL: workspace_id / agency_id trong mọi query thương mại (MỞ RỘNG V2)

> **Mọi query trên `workspace_media_packages`, `media_campaigns`, `transactions`, `ai_credit_ledgers` phải có `workspace_id` hoặc `agency_id` (tuỳ bảng) trong WHERE clause.**

| Table | Filter bắt buộc |
|---|---|
| `workspace_media_packages` | `workspace_id` |
| `media_campaigns` | qua JOIN `workspace_media_packages.workspace_id` |
| `transactions` | `user_id` (gắn cấp User/Owner, không phải Workspace — đổi V2) |
| `ai_credit_ledgers` | `agency_id` (MỚI V2 — gắn cấp Agency, không phải Workspace) |
| `third_party_collaborators` | `agency_id` (MỚI V2) |
| `campaign_collaborators` | qua JOIN `media_campaigns` → `workspace_media_packages.workspace_id` |

```java
// ❌ SAI
transactionRepository.findAll();

// ✅ ĐÚNG — transactions filter theo user_id (Owner), KHÔNG phải workspace_id (đổi V2)
transactionRepository.findByUserId(ctx.userId());
```

```sql
-- ❌ SAI
SELECT * FROM ai_credit_ledgers WHERE month = '2026-09';

-- ✅ ĐÚNG
SELECT * FROM ai_credit_ledgers WHERE agency_id = $1 AND month = $2;
```

---

## Rule 6 — MỚI V2: Owner truy vấn xuyên Workspace phải qua agencyId, không lưu agencyId trong MongoDB

> **Khi Owner cần dữ liệu tổng hợp TOÀN Agency (nhiều Workspace), flow bắt buộc 2 bước: (1) query PostgreSQL lấy danh sách `workspaceId` thuộc `agencyId`, (2) query MongoDB với `$in` trên danh sách đó. KHÔNG lưu `agencyId` trực tiếp trong MongoDB content collection (tránh denormalize 2 tầng — xem Hard Rule 3, `docs/database/database-strategy.md`).**

```java
// ✅ ĐÚNG — 2 bước, không denormalize agencyId vào MongoDB
public Flux<Task> getAllTasksForAgency(SecurityContext ctx) {
    // Bước 1: PostgreSQL — lấy danh sách Workspace thuộc Agency
    return workspaceRepository.findWorkspaceIdsByAgencyId(ctx.agencyId())
        .collectList()
        .flatMapMany(workspaceIds ->
            // Bước 2: MongoDB — $in trên danh sách workspaceId
            mongoTemplate.find(
                new Query(Criteria.where("workspaceId").in(workspaceIds)),
                Task.class));
}
```

---

## Tóm tắt — Decision matrix (cập nhật V2)

| Role | Cần workspaceId | Cần clientProfileId | Cần agencyId (query xuyên Workspace) | Collections bị giới hạn |
|---|---|---|---|---|
| `ADMIN` (system) | ❌ (global access) | ❌ | ❌ | Không — truy cập toàn hệ thống |
| `OWNER` (theo Workspace) | ✅ | ❌ | ✅ khi xem tổng Agency (Rule 6) | Tất cả trong Workspace, hoặc toàn Agency qua Rule 6 |
| `MANAGER` (theo Workspace) | ✅ | ❌ | ❌ | Tất cả trong Workspace mình quản lý |
| `CREATOR` (theo Workspace) | ✅ | ❌ | ❌ | Tất cả trong Workspace, giới hạn thao tác theo Task được giao |
| `CLIENT` (theo Workspace) | ✅ | ✅ | ❌ | `content_requests` (tạo bởi mình), `tasks` (chỉ bước CLIENT_REVIEW), `posts` (xem công khai trong Workspace) |

---

## Acceptance Criteria

- [x] Rule 1: workspaceId bắt buộc — cập nhật danh sách collection theo entity V2 (`tasks`, `task_approvals`, `posts` đổi nghĩa, 4 collection mới)
- [x] Rule 2: CLIENT filter — đổi từ `clientId` (bảng `clients` V1) sang `clientProfileId` (bảng `client_profiles` tái sử dụng V2), giải thích rõ khác biệt logic Task vs ContentRequest
- [x] Rule 3: JWT claim — thêm `agencyId`, đổi `X-Client-Id` → `X-Client-Profile-Id`, nhấn mạnh role theo Workspace không cố định
- [x] Rule 4: Enforcement repository layer — thêm pattern cho collection không có `workspaceId` trực tiếp (`task_approvals`, `content_versions`)
- [x] Rule 5: PostgreSQL — mở rộng cho bảng thương mại V2 (Package/Campaign/Transaction/AI Credit/Collaborator), lưu ý `transactions` gắn `user_id` không phải `workspace_id`
- [x] Rule 6 (MỚI): Owner truy vấn xuyên Workspace toàn Agency — flow 2 bước, không denormalize `agencyId` vào MongoDB
- [x] Decision matrix cập nhật đầy đủ 5 role V2

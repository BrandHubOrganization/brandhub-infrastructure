# DA-E07-05 — OpenAPI YAML Specification for business-service

**Status:** Done  
**Priority:** High  
**Blocked by:** DA-E07-01 ✓, DA-E07-04 ✓  
**Blocks:** None

---

## 1. Deliverables

| Artifact | Path | Size |
|---|---|---|
| OpenAPI 3.1 YAML | `brandhub-business-service/docs/openapi.yaml` | ~3250 lines |
| SpringDoc dependency | `brandhub-business-service/pom.xml` | Added v2.6.0 |

---

## 2. Spec Coverage

**70 endpoints across 11 tags:**

| Tag | Endpoints | HTTP Methods |
|---|---|---|
| Auth | 8 | POST ×6, GET ×2 |
| User | 6 | GET ×2, PUT ×3, DELETE ×1 |
| Workspace | 10 | POST ×3, GET ×3, PUT ×3, DELETE ×1 |
| Client | 8 | POST ×2, GET ×2, PUT ×3, DELETE ×1 |
| Post | 9 | POST ×5, GET ×2, PUT ×1, DELETE ×1 |
| ContentRequest | 6 | POST ×3, GET ×2, PUT ×1 |
| SocialAccount | 5 | GET ×2, POST ×1, DELETE ×1, (GET callback) |
| Analytics | 3 | GET ×3 |
| Report | 3 | POST ×1, GET ×2 |
| Subscription | 6 | POST ×3, GET ×2, (POST webhook) |
| Admin | 6 | GET ×3, PUT ×2, POST ×1 |

---

## 3. Schema Components

**Reusable schemas defined (30+):**
- Envelope: `ApiResponseSuccess`, `ApiResponseError`
- Auth: `RegisterRequest`, `LoginRequest`, `TokenPair`, `RefreshRequest`, `LogoutRequest`, `ForgotPasswordRequest`, `ResetPasswordRequest`
- User: `UserProfile`, `UpdateProfileRequest`, `ChangePasswordRequest`, `SessionInfo`
- Workspace: `CreateWorkspaceRequest`, `WorkspaceSummary`, `WorkspaceMember`, `InviteMemberRequest`, `UpdateMemberRoleRequest`
- Client: `CreateClientRequest`, `ClientSummary`, `ServicePackageRequest`, `PortalAccessRequest`
- Post: `CreatePostRequest`, `PostSummary`, `PostDetail`, `RejectPostRequest`, `SchedulePostRequest`
- ContentRequest: `CreateContentRequestRequest`, `ContentRequestSummary`, `AssignContentRequestRequest`, `ContentRequestStatusRequest`, `ContentRequestComment`
- Social: `SocialAccount`
- Analytics: `WorkspaceStats`, `ClientStats`, `AIUsageStats`
- Report: `CreateReportRequest`, `ReportJob`
- Subscription: `Plan`, `SubscribeRequest`, `Subscription`, `Invoice`
- Admin: `AdminUserSummary`, `UpdateUserStatusRequest`, `SystemStats`, `CreatePlanRequest`

**Reusable responses:** `Unauthorized`, `Forbidden`, `NotFound`, `ValidationError`

**Reusable parameters:** `WorkspaceId` (header), `PageParam`, `SizeParam`

---

## 4. API Design Decisions

### 4.1 ApiResponse envelope
Every response body wraps in `ApiResponse<T>` per DA-E07-04:
```yaml
success: boolean
data: T | null
error: ErrorBody | null
meta: MetaBody | null    # only paginated responses
requestId: string (UUID)
version: "v1"
timestamp: ISO8601 UTC
```

### 4.2 Gateway-injected headers
Documented as `in: header` on each secured endpoint but **not sent by client**:
- `X-User-Id` — UUID from decoded JWT
- `X-User-Role` — RBAC role string
- `X-Workspace-Id` — validated workspace UUID
- `X-Request-Id` — UUID for distributed tracing

### 4.3 MongoDB ObjectId vs UUID
- Posts, ContentRequests, SocialAccounts: `type: string` (no format) with description "MongoDB ObjectId"
- Users, Workspaces, Clients, Plans: `type: string, format: uuid`

### 4.4 204 Never Used
All endpoints return `200` with `data: null` instead of 204 (per DA-E07-04 Rule #8).

### 4.5 Pagination
Paginated endpoints include `meta: { page, size, total }` in response.
Query params: `page` (0-based), `size` (1-100, default 20).

---

## 5. SpringDoc Integration

### 5.1 Dependency added to pom.xml
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.6.0</version>
</dependency>
```

### 5.2 Swagger UI auto-served at
```
http://localhost:8080/swagger-ui.html
http://localhost:8080/v3/api-docs        ← raw JSON spec
http://localhost:8080/v3/api-docs.yaml   ← raw YAML spec
```

### 5.3 Controller annotations
For the YAML to be auto-generated from code, annotate controllers with:
```java
@Tag(name = "Auth", description = "Registration, login, token refresh, OAuth 2.0")
public class AuthController {

    @Operation(
        summary = "Login with email and password",
        operationId = "login"
    )
    @ApiResponse(responseCode = "200", description = "Login successful")
    @ApiResponse(responseCode = "401", description = "Invalid credentials")
    public ResponseEntity<ApiResponse<TokenPair>> login(...) { ... }
}
```

### 5.4 Recommended application.yml config
```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: alpha
    tagsSorter: alpha
  pre-loading-enabled: true
```

### 5.5 Security config — exclude Swagger paths
```java
.requestMatchers(
    "/v3/api-docs/**",
    "/swagger-ui/**",
    "/swagger-ui.html"
).permitAll()
```

---

## 6. Key Error Codes per Endpoint Group

| Domain | Sample Codes |
|---|---|
| Auth | `EMAIL_ALREADY_EXISTS`, `INVALID_CREDENTIALS`, `REFRESH_TOKEN_INVALID`, `RESET_TOKEN_INVALID`, `OAUTH_STATE_INVALID` |
| User | `WRONG_CURRENT_PASSWORD`, `FILE_TOO_LARGE`, `INVALID_FILE_TYPE` |
| Workspace | `WORKSPACE_SLUG_TAKEN`, `WORKSPACE_ACCESS_DENIED`, `MEMBER_ALREADY_EXISTS` |
| Post | `POST_NOT_EDITABLE`, `SCHEDULE_TOO_SOON`, `POST_NOT_APPROVABLE` |
| ContentRequest | `INVALID_STATUS_TRANSITION` |
| SocialAccount | `UNSUPPORTED_PLATFORM`, `PLATFORM_REAUTH_REQUIRED`, `OAUTH_STATE_INVALID` |
| Analytics | `INVALID_DATE_RANGE` |
| Report | `JOB_NOT_FOUND`, `REPORT_LIMIT_EXCEEDED` |
| Subscription | `PLAN_DOWNGRADE_NOT_ALLOWED`, `WEBHOOK_SIGNATURE_INVALID`, `PAYMENT_FAILED` |
| Admin | `CANNOT_SUSPEND_ADMIN` |

---

## 7. Validation Checklist

- [ ] Paste `brandhub-business-service/docs/openapi.yaml` into [editor.swagger.io](https://editor.swagger.io) — must render with 0 errors
- [ ] All 70 endpoints from DA-E07-01 present
- [ ] All gateway-injected headers (`X-User-Id`, `X-User-Role`, `X-Workspace-Id`) documented
- [ ] Every error response uses code from DA-E07-04 error catalogue
- [ ] No 204 responses — all use 200 with `data: null`
- [ ] Paginated responses reference `MetaBody` structure
- [ ] SpringDoc renders at `/swagger-ui.html` when service runs

---

## 8. File Reference

```
brandhub-business-service/
├── docs/
│   └── openapi.yaml          ← primary YAML spec (3250 lines)
└── pom.xml                   ← springdoc-openapi-starter-webmvc-ui added

brandhub-infrastructure/
└── docs/api/
    └── DA-E07-05_OpenAPI_Spec.md   ← this file
```

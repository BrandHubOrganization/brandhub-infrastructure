# Task Checklist — API Integration Tests

## Preparation
- [x] Check Docker daemon status and running containers.
- [x] Update `brandhub-business-service/pom.xml`:
  - [x] Add `testcontainers-bom` to `dependencyManagement`
  - [x] Add `org.testcontainers:mongodb` dependency

## Base Architecture
- [x] Create `com.brandhub.business.integration.BaseIntegrationTest`:
  - [x] Configure PostgreSQL, MongoDB, Redis containers with static lifecycle / resilient local fallback
  - [x] Configure `@DynamicPropertySource`
  - [x] Provide helper seeders & HTTP header builders (supporting HTTP PATCH via JdkClientHttpRequestFactory)

## Test Suites Implementation
- [x] Create `AuthIntegrationTest`:
  - [x] Register test (`POST /api/v1/auth/register`)
  - [x] Login test (`POST /api/v1/auth/login`)
  - [x] Profile test (`GET /api/v1/auth/me`)
  - [x] Token refresh test (`POST /api/v1/auth/refresh`)
  - [x] Logout test (`POST /api/v1/auth/logout`)
- [x] Create `RbacIntegrationTest`:
  - [x] CLIENT role denied from MANAGER endpoints (403)
  - [x] CREATOR / normal user denied from ADMIN endpoints (403)
  - [x] ADMIN role allowed on ADMIN endpoints (200)
- [x] Create `WorkspaceIsolationIntegrationTest`:
  - [x] Cross-tenant data isolation verification between Workspace A and Workspace B
  - [x] Unauthorized cross-workspace resource access denied (403/404)

## Validation & Documentation
- [x] Run and pass all integration tests (5/5 tests passed 100%).
- [x] Update `AI/intergrace.md` with Done status for `[DA-E42-03]`.

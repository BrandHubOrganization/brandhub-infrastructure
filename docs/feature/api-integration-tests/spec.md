# Specification — API Integration Tests (Business Service)

## 1. Objective & Context
Validate the full request lifecycle through real database and cache layers to catch integration bugs that unit tests cannot detect.
Target service: `brandhub-business-service` (Spring Boot 3.3.5, Java 21, PostgreSQL + JPA, MongoDB, Redis).

## 2. Scope & Target Scenarios
Task `[DA-E42-03]` focuses on core security, identity, role-based access control, and tenant isolation:
1. **Full Authentication Flow**:
   - `POST /api/v1/auth/register` (creates user, validates password & email)
   - `POST /api/v1/auth/login` (generates JWT access token + refresh token cookie)
   - `GET /api/v1/auth/me` (retrieves current authenticated user with Bearer token)
   - `POST /api/v1/auth/refresh` (exchanges valid refresh token for new access token)
   - `POST /api/v1/auth/logout` (revokes session/token, clears cookie)
2. **RBAC Enforcement**:
   - `CLIENT` role trying to call manager/owner endpoints returns `403 FORBIDDEN`.
   - `CREATOR` or non-admin roles calling admin endpoints (`/api/v1/admin/**`) returns `403 FORBIDDEN`.
3. **Workspace Isolation**:
   - Member of Workspace A attempting to read or modify resources in Workspace B (e.g. `/api/v1/workspaces/{workspaceBId}/**`) returns `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`.

## 3. Infrastructure & Test Architecture
- **Framework**: `@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)` with `TestRestTemplate`.
- **Containers (Testcontainers)**:
  - Real PostgreSQL container (`postgres:17-alpine`) for transactional entities, relational users, workspaces, and memberships.
  - Real MongoDB container (`mongo:7.0` via `MongoDBContainer`) for document storage.
  - Real Redis container (`redis:7.2-alpine` via `GenericContainer`) for cache, rate-limits, and token/session stores.
- **Dynamic Configuration**: `@DynamicPropertySource` dynamically binds datasource URLs, Mongo URIs, and Redis host/ports to Spring context.
- **Context Management**: Clean database states between tests, `@DirtiesContext` when necessary to isolate test classes.

## 4. Definition of Done
- All testcontainers dependencies properly declared in `pom.xml`.
- Reusable base class `BaseIntegrationTest` providing container lifecycle and `TestRestTemplate`.
- Integration test classes verifying:
  - Auth lifecycle (`AuthIntegrationTest`)
  - Role-based authorization (`RbacIntegrationTest`)
  - Tenant/Workspace isolation (`WorkspaceIsolationIntegrationTest`)
- All tests pass against real containerized PostgreSQL, MongoDB, and Redis without mocks for persistence.

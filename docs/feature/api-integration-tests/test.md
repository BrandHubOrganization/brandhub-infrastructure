# Test Plan & Test Cases — API Integration Tests

## 1. Environment Requirements
- Docker runtime active (Docker Desktop / engine).
- Maven 3.9+ / Java 21.

## 2. Test Cases Specification

### Suite 1: Authentication Lifecycle (`AuthIntegrationTest`)
- **TC-AUTH-01**: Registration with valid payload returns HTTP 201 Created and persists User in PostgreSQL.
- **TC-AUTH-02**: Login with valid credentials returns HTTP 200 OK, returns `accessToken` in body, and sets HTTP-only `refreshToken` cookie.
- **TC-AUTH-03**: `GET /api/v1/auth/me` with valid Bearer token returns HTTP 200 OK with correct user profile (`email`, `fullName`).
- **TC-AUTH-04**: `POST /api/v1/auth/refresh` with refresh token returns HTTP 200 OK and a fresh access token.
- **TC-AUTH-05**: `POST /api/v1/auth/logout` invalidates the active tokens and returns HTTP 200 OK with cleared cookie.
- **TC-AUTH-06**: Subsequent access to `/api/v1/auth/me` with revoked token or unauthenticated returns HTTP 401 Unauthorized.

### Suite 2: Role-Based Access Control (`RbacIntegrationTest`)
- **TC-RBAC-01**: User with `CLIENT` role calling manager-restricted workspace operations (e.g., adding/modifying workspace members or suppression lists) returns HTTP 403 Forbidden.
- **TC-RBAC-02**: User with `CREATOR` role attempting to access `/api/v1/admin/users` returns HTTP 403 Forbidden.
- **TC-RBAC-03**: User with `ADMIN` system role calling `/api/v1/admin/users` successfully receives HTTP 200 OK.

### Suite 3: Tenant & Workspace Isolation (`WorkspaceIsolationIntegrationTest`)
- **TC-ISO-01**: User member of Workspace A attempting to read members of Workspace B returns HTTP 403 / 404 (Workspace access denied).
- **TC-ISO-02**: User member of Workspace A attempting to modify or create resources under Workspace B is rejected with Access Denied.
- **TC-ISO-03**: User accessing their own Workspace A resources successfully executes and returns HTTP 200 OK.

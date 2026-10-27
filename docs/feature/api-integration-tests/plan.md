# Technical Implementation Plan — API Integration Tests

## 1. Maven Dependency Enhancements (`brandhub-business-service/pom.xml`)
- Add `testcontainers-bom` to `<dependencyManagement>`.
- Add `org.testcontainers:mongodb` to `<dependencies>` with `<scope>test</scope>`.
- Ensure `org.testcontainers:postgresql` and `org.testcontainers:junit-jupiter` are present.

## 2. Reusable Integration Base Class
Create `com.brandhub.business.integration.BaseIntegrationTest`:
- Starts singleton / static containers:
  - `PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:17-alpine");`
  - `MongoDBContainer MONGO = new MongoDBContainer("mongo:7.0");`
  - `GenericContainer<?> REDIS = new GenericContainer<>(DockerImageName.parse("redis:7.2-alpine")).withExposedPorts(6379);`
- Injects dynamic configuration via `@DynamicPropertySource`:
  - `spring.datasource.url = POSTGRES.getJdbcUrl()`
  - `spring.datasource.username = POSTGRES.getUsername()`
  - `spring.datasource.password = POSTGRES.getPassword()`
  - `spring.data.mongodb.uri = MONGO.getConnectionString() + "/brandhub_test"`
  - `spring.data.redis.host = REDIS.getHost()`
  - `spring.data.redis.port = REDIS.getMappedPort(6379)`
- Injects `TestRestTemplate`, `JdbcTemplate`, `MongoTemplate`, `RedisTemplate`.
- Helper methods for registering users, creating workspaces, generating auth headers, and cleaning database state.

## 3. Test Suites Implementation
1. **`AuthIntegrationTest`**:
   - `testRegisterSuccess`: Verify 201 Created and user record in PostgreSQL.
   - `testLoginSuccess`: Verify JWT accessToken, refreshToken cookie, user info.
   - `testGetMe`: Authenticated request with Bearer token returns 200 OK with correct user profile.
   - `testRefreshToken`: Cookie or body refresh token exchanges for fresh access token.
   - `testLogout`: Invalidates session, access token / refresh cookie cleared.

2. **`RbacIntegrationTest`**:
   - `testClientAccessingManagerEndpoint_forbidden`: User with `CLIENT` role calling `/api/v1/workspaces/{workspaceId}/members` returns 403 Forbidden.
   - `testCreatorAccessingAdminEndpoint_forbidden`: User with `CREATOR` role calling `/api/v1/admin/users` returns 403 Forbidden.
   - `testAdminAccessingAdminEndpoint_success`: User with `ADMIN` role succeeds.

3. **`WorkspaceIsolationIntegrationTest`**:
   - Create Workspace A and Workspace B with separate owners/members.
   - User A (member of Workspace A) requests `/api/v1/workspaces/{workspaceB.id}/members` -> returns 403 / 404 (Workspace access denied).
   - User A requests `/api/v1/workspaces/{workspaceB.id}/tasks` or `/mail/templates` -> denied.
   - User A requests `/api/v1/workspaces/{workspaceA.id}/...` -> succeeds.

## 4. Execution and Verification
- Run tests with Docker running.
- Ensure zero regression in existing unit tests.

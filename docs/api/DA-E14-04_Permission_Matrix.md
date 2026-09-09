# DA-E14-04 — Role-Based Access Control (RBAC) Permission Matrix

**Document Status:** Draft / Pending Sign-off  
**Owner:** Phước (Publisher)  
**Reviewer:** Trung (Leader)  
**Target Sprint:** Sprint 6 Sign-off  
**Single Source of Truth:** RBAC & Permission Mapping for Epics E12–E24

---

## 1. Executive Summary

This document defines the authoritative **Role-Based Access Control (RBAC) Matrix** mapping all 6 platform roles across every API endpoint in the `brandhub-business-service` (Epics E12–E24).

Any discrepancy between this document and code-level annotations (`@PreAuthorize`, `@Secured`, or custom Security Interceptors) is treated as a **critical bug**.

---

## 2. Platform Roles & Definitions

| Role Code         | Role Name             | Description & Scope                                                                                                                      |
| ----------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `ADMIN`           | System Administrator  | Full global access across all tenant workspaces, system settings, subscription management, and platform audit logs.                      |
| `AGENCY_OWNER`    | Agency Owner          | Root owner of a workspace/agency account. Full management of workspace members, billing, brand clients, and all content workflows.       |
| `ACCOUNT_MANAGER` | Account Manager       | Manages clients, campaigns, and content workflows within assigned workspace context. Cannot access billing or alter workspace ownership. |
| `CONTENT_CREATOR` | Content Creator       | Creates and edits post drafts, submits content requests, and views assigned client assets. Cannot approve or publish posts.              |
| `PUBLISHER`       | Content Publisher     | Reviews, approves, schedules, and triggers publication for social posts. Manages social account connections and OAuth tokens.            |
| `BRAND_CLIENT`    | External Brand Client | Restricted view-only access to review assigned posts, approve content requests, and view client-specific analytics.                      |

---

## 3. RBAC Permission Matrix (Epics E12 – E24)

### Legend

- ✅ **Allowed**: Direct access granted.
- 🔒 **Conditional**: Access granted with scope checks (e.g., must belong to active `workspaceId` or assigned `clientId`).
- ❌ **Forbidden**: Returns `403 Forbidden`.
- 🌐 **Public / Auth**: Handled via JWT authentication without specific role restriction.

---

### 3.1. Auth & User Profile (`/api/v1/auth`, `/api/v1/users`)

| Method | Endpoint Path           | Description                           | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| ------ | ----------------------- | ------------------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `POST` | `/api/v1/auth/register` | Register new user account             |  🌐   |      🌐      |       🌐        |       🌐        |    🌐     |      🌐      |
| `POST` | `/api/v1/auth/login`    | Authenticate user & issue tokens      |  🌐   |      🌐      |       🌐        |       🌐        |    🌐     |      🌐      |
| `POST` | `/api/v1/auth/refresh`  | Refresh JWT access token              |  🌐   |      🌐      |       🌐        |       🌐        |    🌐     |      🌐      |
| `POST` | `/api/v1/auth/logout`   | Revoke active session (blacklist JWT) |  ✅   |      ✅      |       ✅        |       ✅        |    ✅     |      ✅      |
| `GET`  | `/api/v1/users/me`      | Fetch current user profile            |  ✅   |      ✅      |       ✅        |       ✅        |    ✅     |      ✅      |
| `PUT`  | `/api/v1/users/me`      | Update current user profile           |  ✅   |      ✅      |       ✅        |       ✅        |    ✅     |      ✅      |

---

### 3.2. Workspace & Member Management (`/api/v1/workspaces`) — Epic E12

| Method   | Endpoint Path                              | Description                         | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| -------- | ------------------------------------------ | ----------------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `POST`   | `/api/v1/workspaces`                       | Create new agency workspace         |  ✅   |      ✅      |       ❌        |       ❌        |    ❌     |      ❌      |
| `GET`    | `/api/v1/workspaces`                       | List accessible workspaces for user |  ✅   |      ✅      |       ✅        |       ✅        |    ✅     |      🔒      |
| `GET`    | `/api/v1/workspaces/{id}`                  | Get workspace details               |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `PUT`    | `/api/v1/workspaces/{id}`                  | Update workspace settings           |  ✅   |      🔒      |       ❌        |       ❌        |    ❌     |      ❌      |
| `DELETE` | `/api/v1/workspaces/{id}`                  | Archive/delete workspace            |  ✅   |      🔒      |       ❌        |       ❌        |    ❌     |      ❌      |
| `GET`    | `/api/v1/workspaces/{id}/members`          | List workspace members              |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      ❌      |
| `POST`   | `/api/v1/workspaces/{id}/members/invite`   | Invite new member to workspace      |  ✅   |      🔒      |       🔒        |       ❌        |    ❌     |      ❌      |
| `DELETE` | `/api/v1/workspaces/{id}/members/{userId}` | Remove member from workspace        |  ✅   |      🔒      |       ❌        |       ❌        |    ❌     |      ❌      |

---

### 3.3. Brand Client Management (`/api/v1/clients`) — Epic E13

| Method   | Endpoint Path          | Description               | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| -------- | ---------------------- | ------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `POST`   | `/api/v1/clients`      | Create new brand client   |  ✅   |      🔒      |       🔒        |       ❌        |    ❌     |      ❌      |
| `GET`    | `/api/v1/clients`      | List clients in workspace |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      ❌      |
| `GET`    | `/api/v1/clients/{id}` | Get client profile        |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `PUT`    | `/api/v1/clients/{id}` | Update client information |  ✅   |      🔒      |       🔒        |       ❌        |    ❌     |      ❌      |
| `DELETE` | `/api/v1/clients/{id}` | Soft delete brand client  |  ✅   |      🔒      |       ❌        |       ❌        |    ❌     |      ❌      |

---

### 3.4. Post Lifecycle & Scheduling (`/api/v1/posts`) — Epics E14, E15, E16

| Method   | Endpoint Path                 | Description                                | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| -------- | ----------------------------- | ------------------------------------------ | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `GET`    | `/api/v1/posts`               | List posts (filtered by workspace/client)  |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `POST`   | `/api/v1/posts`               | Create new post draft                      |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      ❌      |
| `GET`    | `/api/v1/posts/{id}`          | Get detailed post preview                  |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `PUT`    | `/api/v1/posts/{id}`          | Edit post draft                            |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      ❌      |
| `DELETE` | `/api/v1/posts/{id}`          | Delete post draft                          |  ✅   |      🔒      |       🔒        |       🔒        |    ❌     |      ❌      |
| `POST`   | `/api/v1/posts/{id}/submit`   | Submit draft for review (`PENDING_REVIEW`) |  ✅   |      🔒      |       🔒        |       🔒        |    ❌     |      ❌      |
| `POST`   | `/api/v1/posts/{id}/approve`  | Approve post draft (`APPROVED`)            |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      🔒      |
| `POST`   | `/api/v1/posts/{id}/reject`   | Reject post draft with review feedback     |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      🔒      |
| `POST`   | `/api/v1/posts/{id}/schedule` | Schedule post publication (`SCHEDULED`)    |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      ❌      |
| `POST`   | `/api/v1/posts/{id}/publish`  | Trigger immediate publication to RabbitMQ  |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      ❌      |

---

### 3.5. Content Request Workflow (`/api/v1/content-requests`) — Epic E17

| Method | Endpoint Path                   | Description                   | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| ------ | ------------------------------- | ----------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `POST` | `/api/v1/content-requests`      | Create content request        |  ✅   |      🔒      |       🔒        |       ❌        |    ❌     |      🔒      |
| `GET`  | `/api/v1/content-requests`      | List content requests         |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `GET`  | `/api/v1/content-requests/{id}` | Get request details           |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `PUT`  | `/api/v1/content-requests/{id}` | Update content request status |  ✅   |      🔒      |       🔒        |       🔒        |    ❌     |      🔒      |

---

### 3.6. Social Account Connections & OAuth (`/api/v1/social-accounts`) — Epic E18

| Method   | Endpoint Path                                | Description                             | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| -------- | -------------------------------------------- | --------------------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `GET`    | `/api/v1/social-accounts`                    | List connected social channels          |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `GET`    | `/api/v1/social-accounts/connect/{platform}` | Initiate OAuth flow                     |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      ❌      |
| `POST`   | `/api/v1/social-accounts/callback`           | Complete OAuth & store encrypted tokens |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      ❌      |
| `DELETE` | `/api/v1/social-accounts/{id}`               | Disconnect social channel               |  ✅   |      🔒      |       🔒        |       ❌        |    🔒     |      ❌      |

---

### 3.7. Analytics & Async Reports (`/api/v1/analytics`, `/api/v1/reports`) — Epics E19, E20, E21

| Method | Endpoint Path                   | Description                             | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| ------ | ------------------------------- | --------------------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `GET`  | `/api/v1/analytics/overview`    | Fetch workspace analytics overview      |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `GET`  | `/api/v1/analytics/posts/{id}`  | Get post engagement performance         |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `POST` | `/api/v1/reports/export`        | Request async PDF/CSV report generation |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |
| `GET`  | `/api/v1/reports/download/{id}` | Download generated report file          |  ✅   |      🔒      |       🔒        |       🔒        |    🔒     |      🔒      |

---

### 3.8. Subscriptions & Billing (`/api/v1/subscriptions`) — Epics E22, E23

| Method | Endpoint Path                    | Description                              | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| ------ | -------------------------------- | ---------------------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `GET`  | `/api/v1/subscriptions/current`  | View current workspace subscription plan |  ✅   |      🔒      |       🔒        |       ❌        |    ❌     |      ❌      |
| `POST` | `/api/v1/subscriptions/checkout` | Create Stripe checkout session           |  ✅   |      🔒      |       ❌        |       ❌        |    ❌     |      ❌      |
| `POST` | `/api/v1/subscriptions/cancel`   | Cancel active workspace subscription     |  ✅   |      🔒      |       ❌        |       ❌        |    ❌     |      ❌      |
| `POST` | `/api/v1/subscriptions/webhook`  | Stripe webhook processing endpoint       |  🌐   |      🌐      |       🌐        |       🌐        |    🌐     |      🌐      |

---

### 3.9. Platform Administration (`/api/v1/admin`) — Epic E24

| Method | Endpoint Path                     | Description                      | ADMIN | AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR | PUBLISHER | BRAND_CLIENT |
| ------ | --------------------------------- | -------------------------------- | :---: | :----------: | :-------------: | :-------------: | :-------: | :----------: |
| `GET`  | `/api/v1/admin/users`             | Platform-wide user management    |  ✅   |      ❌      |       ❌        |       ❌        |    ❌     |      ❌      |
| `PUT`  | `/api/v1/admin/users/{id}/status` | Change user account status       |  ✅   |      ❌      |       ❌        |       ❌        |    ❌     |      ❌      |
| `GET`  | `/api/v1/admin/workspaces`        | System workspace management      |  ✅   |      ❌      |       ❌        |       ❌        |    ❌     |      ❌      |
| `GET`  | `/api/v1/admin/audit-logs`        | Query global security audit logs |  ✅   |      ❌      |       ❌        |       ❌        |    ❌     |      ❌      |

---

## 4. Verification & Bug Reporting Process

1. **Spring Security Enforcement:**  
   In `brandhub-business-service`, security rules must be validated against `X-User-Role` passed down by `brandhub-api-gateway`.
2. **Discrepancy Resolution:**  
   If an endpoint returns `200 OK` for a role marked as `❌ Forbidden` in this matrix, a **Severity P1 Bug** must be logged referencing task `DA-E14-04`.

# UC 08 — Admin Management (UC-97 → UC-106)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [09-admin-management.md](../09-admin-management.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`
> **Toàn bộ actor:** ADMIN — tách biệt hoàn toàn khỏi cấu trúc Agency→Workspace.

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-97 | Send System-Wide Notification | ADMIN | 3.10.1 |
| UC-98 | View Platform Statistics Overview | ADMIN | 3.10.2 |
| UC-99 | Monitor System Health | ADMIN | 3.10.3 |
| UC-100 | Review Content Moderation Queue | ADMIN | 3.10.4 |
| UC-101 | View User List | ADMIN | 3.10.6 |
| UC-102 | Create User | ADMIN | 3.10.7 |
| UC-103 | Update User | ADMIN | 3.10.8 |
| UC-104 | Deactivate/Disable User | ADMIN | 3.10.5, 3.10.9 |
| UC-105 | View Revenue Dashboard | ADMIN | 3.10.11 |
| UC-106 | Export PDF Report | ADMIN | 3.10.12 |

> **Ghi chú số hiệu FR:** CSV gốc nhảy từ 3.10.9 sang 3.10.11 (không có 3.10.10) — giữ nguyên, không tự đánh số lại.

---

## UC-97 — Send System-Wide Notification

- **Actor(s):** ADMIN
- **Description:** Create and send notifications to the entire system, optionally segmented by user group.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN composes a notification, optionally targets a user segment.
  2. System broadcasts the notification (push/in-app).

## UC-98 — View Platform Statistics Overview

- **Actor(s):** ADMIN
- **Description:** View an overview dashboard (users, revenue, active agencies) with charts.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN opens the Platform Statistics dashboard.
  2. System displays charts: user growth, revenue, active Agencies.

## UC-99 — Monitor System Health

- **Actor(s):** ADMIN
- **Description:** Monitor resource usage (%CPU, %RAM...) and the live status of servers within the microservice system.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN opens System Health dashboard.
  2. System displays live resource metrics and up/down status per microservice.

## UC-100 — Review Content Moderation Queue

- **Actor(s):** ADMIN
- **Description:** View and review content created by Creators that was flagged by the system's moderation policy.
- **Precondition:** At least one content item auto-flagged by Compliance Check (see [04-content-task-workflow.md](04-content-task-workflow.md) UC-72).
- **Main Flow:**
  1. ADMIN opens the Content Moderation Queue.
  2. Reviews each flagged item, confirms or overturns the system's automated decision.
- **Note:** Admin reviews the system's existing flag decision — not performing moderation from scratch.

## UC-101 — View User List

- **Actor(s):** ADMIN
- **Description:** View the list of users in the system.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN opens User Management.
  2. System lists all users with search/filter.

## UC-102 — Create User

- **Actor(s):** ADMIN
- **Description:** Create a new user account in the system.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN fills new user details, submits.
  2. System creates the account.

## UC-103 — Update User

- **Actor(s):** ADMIN
- **Description:** Update an existing user's information.
- **Precondition:** Target user exists.
- **Main Flow:**
  1. ADMIN edits user fields, submits.
  2. System persists changes.

## UC-104 — Deactivate/Disable User

- **Actor(s):** ADMIN
- **Description:** Verify, disable, or delete a user account.
- **Precondition:** Target user exists.
- **Main Flow:**
  1. ADMIN selects a status action (verify/disable/delete) on the target user.
  2. System applies the state transition directly.
- **Business Rule:** Deliberately kept as one combined FR (not split into separate verify/disable/delete FRs) to reduce endpoint count.
- **Open Question:** Can an Admin deactivate/delete another Admin? Is there a max Admin count? **[OPEN QUESTION]** — unresolved in source CSV, needs decision before RBAC design finalized for this action.

## UC-105 — View Revenue Dashboard

- **Actor(s):** ADMIN
- **Description:** View system revenue generated from subscription plans and credit purchases.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN opens Revenue Dashboard.
  2. System displays revenue breakdown by Plan tier and AI Credit purchases.

## UC-106 — Export PDF Report

- **Actor(s):** ADMIN
- **Description:** Export a PDF report for the User Management, Revenue, and other admin pages.
- **Precondition:** User is ADMIN, viewing an exportable admin page.
- **Main Flow:**
  1. ADMIN selects Export PDF on the current page.
  2. System generates and downloads a PDF report of the current data view.

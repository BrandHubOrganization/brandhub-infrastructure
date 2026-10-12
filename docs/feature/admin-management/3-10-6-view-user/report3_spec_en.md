**3.10.6 View User (User Directory, Filtering, Search & Strike Counters)**

**Function Trigger**

Begins when an authenticated Administrator (ADMIN) navigates to /admin/users.

**Function Description**

- **Actors / Roles**: ADMIN. Platform Administrator overseeing platform user accounts and membership governance.
- **Purpose**: Search and filter users by actual account status, system role, catalog plan and active strike state; show Agency roles separately.
- **Interface**: User Management Directory Screen (SCR-ADM-06), featuring search input, multidimensional filter dropdowns, tabulated data grid, and contextual action menus.
- **Data Processing**: Verify ADMIN, query paginated profiles with current status, activation flags and subscription catalog, and derive counters using FR 3.10.5 state instead of creation-time TTL.

**Screen Layout**

Figure — User Management Directory Screen (SCR-ADM-06):

- Left/Header: Admin sidebar navigation; Top header with title "User Governance Directory" and user count summary badge.
- Center: Search email/name; filters: ACTIVE, PENDING_VERIFICATION, FLAGGED, DEACTIVATED, DELETED and any retained legacy SUSPENDED state; ADMIN/USER; catalog plan; active strike severity. Rows show profile, system role, Agency ownership separately, current/pending plan, active YELLOW/ORANGE/RED counters, activation state and sanction end time. ORANGE threshold is x/3.
- Buttons: Button "+ Provision New User" (primary button top right), Button "Apply Filters", Button "Reset Filters", Row three-dot action menu (View Details, Manage Violations & Strikes, Edit Profile).
- Footer: Pagination: 10/20/50 rows per page, page navigation and total count; default page size 20.

**Function Details**

- **Data Specifications**
    - **Input required**: None (defaults to page=1, limit=20, sortBy=createdAt, sortOrder=DESC).
    - **Input optional**: page, limit, search, status, systemRole (ADMIN/USER), strikeFilter (ALL/HAS_YELLOW/HAS_ORANGE/HAS_RED/CLEAN), planId (catalog), sortBy, sortOrder.
    - **System data**: users table, user_system_roles, workspace_members, subscription_plans, user_violations.
    - **Output**: Paginated user list payload { items: [...], total, page, limit, totalPages } with HTTP 200 OK.

- **Business Rules**
    - **BR-63**: Only ADMIN accesses the platform directory.
    - **BR-82**: System roles are ADMIN and USER only. Agency/Workspace membership roles are managed separately. Subscription plan identifiers come from the existing catalog (currently BASIC, PRO, ENTERPRISE), not a second hardcoded catalog.
    - **BR-94**: Use active/converted/pardoned/expired strike states from FR 3.10.5. Active counters and historical counts must not be confused; ORANGE displays x/3.
    - **BR-15**: PENDING_VERIFICATION means email not verified. DEACTIVATED shows the sanction deadline. DELETED remains a separate self-service lifecycle.
    - **BR-65**: Preserve pagination, search and filter URL state; allowlisted sorting and parameter validation are required. Never return password hashes, tokens or authenticator secrets.

- **Validation**
    - Missing ADMIN authority → MSG39.
    - No matching user accounts → empty table with MSG122.

**Functionalities**

- **Normal Flow**
    1. Administrator navigates to /admin/users.
    2. System validates ADMIN authorization (BR-35).
    3. System queries database with default pagination parameters (page=1, limit=20).
    4. System renders screen SCR-ADM-06 displaying user records, status pills, and active strike counters.
    5. Administrator may enter search keywords or apply status / strike filters.
    6. System recalculates query and updates the table instantaneously.

- **Abnormal Cases**
    - 1.a1: Missing ADMIN authority → MSG39.
    - 5.a1: No matching users → empty state with MSG122; preserve current filters.

**Post-Conditions**

- Paginated directory reflects activation/sanction status, catalog plans and strike lifecycle consistently.
- Search and filters remain in URL query parameters.

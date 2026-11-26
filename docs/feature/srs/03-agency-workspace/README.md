# 3.4 Agency & Workspace (26 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/03-agency-workspace.md) · [Organization Structure](../../../ba/01-organization-structure.md) · [Use Cases](../../../ba/use-cases/02-agency-workspace.md) · [Module Specs Index](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical specification, technical implementation plan, task breakdown, and unit/acceptance test verification suite for **3.4 Agency & Workspace** (`3.4.1 – 3.4.26`, **26 Atomic CRUD Functional Requirements**).

---

## 1. Domain Architecture Overview

Domain `3.4` implements BrandHub's multi-tenant organizational hierarchy (**Agency → Workspace → Role-Scoped Membership**), supporting both multi-client **Agency Mode** (`WorkspaceMode.AGENCY`) and solo **Personal Studio Mode** (`WorkspaceMode.PERSONAL`):

- **Two-Tier Multi-Tenancy & Canonical Roles:**
  - **Agency Tier (`agencies`, `agency_members`, `agency_invitations`):** Owned by `Owner` (`agencies.owner_id`). Supports profile branding (logo/banner on AWS S3), soft-deletion with a 30-day restore window (`EntityStatus.SOFT_DELETED`), email invitation lifecycle (`PENDING` -> `ACCEPTED` / `DECLINED` / `REVOKED`), and subscription entitlement enforcement (`AgencyPlanEntitlementService`).
  - **Workspace Tier (`workspaces`, `workspace_members`, `workspace_invitations`, `workspace_templates`):** Scoped under an Agency (`workspaces.agency_id`) with strict tenant isolation (`@RequireRole` + `WorkspaceIsolationHelper` + `WorkspaceAccessService`). Operational Workspace roles are strictly `Manager` (at most 1 active `Manager` per Workspace, `BR-21`), `Creator`, and `Client` (attached via `workspace_members.client_profile_id`).
- **Role-Based Dashboards & Real-Time Analytics (`3.4.2`, `3.4.13`):**
  - `AgencyController.getStats` (`GET /api/v1/agencies/{agencyId}/stats`), `WorkspaceController.getDashboard` (`GET /api/v1/workspaces/{workspaceId}/dashboard`), and `DashboardAnalyticsController` (`GET /api/v1/analytics/agencies/{agencyId}[/overview|/items|/export.xlsx]` and `GET /api/v1/analytics/workspaces/{workspaceId}[/overview|/items]`) compute server-side KPIs, 7/30/90-day period deltas, 0–100 efficiency scores, attention strips, drill-down item drawers, and Owner `.xlsx` exports without client-side mock data.
- **Workspace Provisioning, Duplication & Templates (`3.4.14`, `3.4.19`–`3.4.22`):**
  - Supports blank creation (`POST /api/v1/workspaces`), personal studio bootstrap (`POST /api/v1/workspaces/personal/bootstrap`), idempotent workspace duplication with selective member & canonical `timezone_config` copying (`POST /api/v1/workspaces/{workspaceId}/duplicate` via `WorkspaceDuplicationServiceImpl`), and reusable Workspace Templates (`WorkspaceTemplateController` `/api/v1/workspace-templates/**`, including Admin global templates).
- **Client Surfaces (`brandhub-web` & `brandhub-mobile-app`):**
  - **Web (`brandhub-web`):** `src/pages/agency/*` (`index.tsx`, `create.tsx`, `detail.tsx`, `members.tsx`, `invitations.tsx`, `accept.tsx`, `dashboard/index.tsx`), `src/pages/workspace/*` (`index.tsx`, `create.tsx`, `dashboard.tsx`, `detail.tsx`, `members.tsx`, `clients.tsx`, `templates.tsx`), `src/components/dashboard/*`.
  - **Mobile (`brandhub-mobile-app`):** `src/screens/workspace/{WorkspacePickerScreen,ManagedWorkspacesScreen,WorkspaceDetailScreen,WorkspaceMembersScreen,WorkspaceInviteMemberScreen}.tsx`, `src/screens/dashboard/{DashboardScreen,HomeDashboardScreen}.tsx`, `src/screens/settings/WorkspaceSettingsScreen.tsx`.

---

## 2. Functional Requirements Matrix

| FR ID | UC ID | Function Name | Canonical Roles | Status | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `3.4.1` | `UC-014` | **List Agency** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-4-1-list-agency/spec.md) · [Plan](./3-4-1-list-agency/plan.md) · [Task](./3-4-1-list-agency/task.md) · [Test](./3-4-1-list-agency/test.md) |
| `3.4.2` | `UC-015` | **View Agency Dashboard** | `Owner` | Implemented | [Spec](./3-4-2-view-agency-dashboard/spec.md) · [Plan](./3-4-2-view-agency-dashboard/plan.md) · [Task](./3-4-2-view-agency-dashboard/task.md) · [Test](./3-4-2-view-agency-dashboard/test.md) |
| `3.4.3` | `UC-016` | **Create Agency** | `Owner, Manager, Creator` | Implemented | [Spec](./3-4-3-create-agency/spec.md) · [Plan](./3-4-3-create-agency/plan.md) · [Task](./3-4-3-create-agency/task.md) · [Test](./3-4-3-create-agency/test.md) |
| `3.4.4` | `UC-017` | **View Agency Profile** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-4-view-agency-profile/spec.md) · [Plan](./3-4-4-view-agency-profile/plan.md) · [Task](./3-4-4-view-agency-profile/task.md) · [Test](./3-4-4-view-agency-profile/test.md) |
| `3.4.5` | `UC-018` | **Update Agency Profile** | `Owner` | Implemented | [Spec](./3-4-5-update-agency-profile/spec.md) · [Plan](./3-4-5-update-agency-profile/plan.md) · [Task](./3-4-5-update-agency-profile/task.md) · [Test](./3-4-5-update-agency-profile/test.md) |
| `3.4.6` | `UC-019` | **Remove Agency** | `Owner` | Implemented | [Spec](./3-4-6-remove-agency/spec.md) · [Plan](./3-4-6-remove-agency/plan.md) · [Task](./3-4-6-remove-agency/task.md) · [Test](./3-4-6-remove-agency/test.md) |
| `3.4.7` | `UC-020` | **Invite Agency Member** | `Owner` | Implemented | [Spec](./3-4-7-invite-agency-member/spec.md) · [Plan](./3-4-7-invite-agency-member/plan.md) · [Task](./3-4-7-invite-agency-member/task.md) · [Test](./3-4-7-invite-agency-member/test.md) |
| `3.4.8` | `UC-021` | **View Agency Invitation Status** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-8-view-agency-invitation-status/spec.md) · [Plan](./3-4-8-view-agency-invitation-status/plan.md) · [Task](./3-4-8-view-agency-invitation-status/task.md) · [Test](./3-4-8-view-agency-invitation-status/test.md) |
| `3.4.9` | `UC-022` | **Accept Agency Invitation** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-9-accept-agency-invitation/spec.md) · [Plan](./3-4-9-accept-agency-invitation/plan.md) · [Task](./3-4-9-accept-agency-invitation/task.md) · [Test](./3-4-9-accept-agency-invitation/test.md) |
| `3.4.10` | `UC-023` | **Decline Agency Invitation** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-10-decline-agency-invitation/spec.md) · [Plan](./3-4-10-decline-agency-invitation/plan.md) · [Task](./3-4-10-decline-agency-invitation/task.md) · [Test](./3-4-10-decline-agency-invitation/test.md) |
| `3.4.11` | `UC-024` | **Remove Agency Member** | `Owner` | Implemented | [Spec](./3-4-11-remove-agency-member/spec.md) · [Plan](./3-4-11-remove-agency-member/plan.md) · [Task](./3-4-11-remove-agency-member/task.md) · [Test](./3-4-11-remove-agency-member/test.md) |
| `3.4.12` | `UC-025` | **List Workspace** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-12-list-workspace/spec.md) · [Plan](./3-4-12-list-workspace/plan.md) · [Task](./3-4-12-list-workspace/task.md) · [Test](./3-4-12-list-workspace/test.md) |
| `3.4.13` | `UC-026` | **View Workspace Dashboard** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-13-view-workspace-dashboard/spec.md) · [Plan](./3-4-13-view-workspace-dashboard/plan.md) · [Task](./3-4-13-view-workspace-dashboard/task.md) · [Test](./3-4-13-view-workspace-dashboard/test.md) |
| `3.4.14` | `UC-027` | **Create Workspace** | `Owner` | Implemented | [Spec](./3-4-14-create-workspace/spec.md) · [Plan](./3-4-14-create-workspace/plan.md) · [Task](./3-4-14-create-workspace/task.md) · [Test](./3-4-14-create-workspace/test.md) |
| `3.4.15` | `UC-028` | **View Workspace Profile** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-15-view-workspace-profile/spec.md) · [Plan](./3-4-15-view-workspace-profile/plan.md) · [Task](./3-4-15-view-workspace-profile/task.md) · [Test](./3-4-15-view-workspace-profile/test.md) |
| `3.4.16` | `UC-029` | **Update Workspace Profile** | `Owner, Manager` | Implemented | [Spec](./3-4-16-update-workspace-profile/spec.md) · [Plan](./3-4-16-update-workspace-profile/plan.md) · [Task](./3-4-16-update-workspace-profile/task.md) · [Test](./3-4-16-update-workspace-profile/test.md) |
| `3.4.17` | `UC-030` | **Delete Workspace** | `Owner` | Implemented | [Spec](./3-4-17-delete-workspace/spec.md) · [Plan](./3-4-17-delete-workspace/plan.md) · [Task](./3-4-17-delete-workspace/task.md) · [Test](./3-4-17-delete-workspace/test.md) |
| `3.4.18` | `UC-031` | **Leave Workspace** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-18-leave-workspace/spec.md) · [Plan](./3-4-18-leave-workspace/plan.md) · [Task](./3-4-18-leave-workspace/task.md) · [Test](./3-4-18-leave-workspace/test.md) |
| `3.4.19` | `UC-032` | **Save Workspace Template** | `Owner` | Implemented | [Spec](./3-4-19-save-workspace-template/spec.md) · [Plan](./3-4-19-save-workspace-template/plan.md) · [Task](./3-4-19-save-workspace-template/task.md) · [Test](./3-4-19-save-workspace-template/test.md) |
| `3.4.20` | `UC-033` | **View Workspace Templates** | `Owner` | Implemented | [Spec](./3-4-20-view-workspace-templates/spec.md) · [Plan](./3-4-20-view-workspace-templates/plan.md) · [Task](./3-4-20-view-workspace-templates/task.md) · [Test](./3-4-20-view-workspace-templates/test.md) |
| `3.4.21` | `UC-034` | **Apply Workspace Template** | `Owner` | Implemented | [Spec](./3-4-21-apply-workspace-template/spec.md) · [Plan](./3-4-21-apply-workspace-template/plan.md) · [Task](./3-4-21-apply-workspace-template/task.md) · [Test](./3-4-21-apply-workspace-template/test.md) |
| `3.4.22` | `UC-035` | **Delete Workspace Template** | `Owner` | Implemented | [Spec](./3-4-22-delete-workspace-template/spec.md) · [Plan](./3-4-22-delete-workspace-template/plan.md) · [Task](./3-4-22-delete-workspace-template/task.md) · [Test](./3-4-22-delete-workspace-template/test.md) |
| `3.4.23` | `UC-036` | **View Workspace Members** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-4-23-view-workspace-members/spec.md) · [Plan](./3-4-23-view-workspace-members/plan.md) · [Task](./3-4-23-view-workspace-members/task.md) · [Test](./3-4-23-view-workspace-members/test.md) |
| `3.4.24` | `UC-037` | **Add Workspace Member** | `Owner, Manager` | Implemented | [Spec](./3-4-24-add-workspace-member/spec.md) · [Plan](./3-4-24-add-workspace-member/plan.md) · [Task](./3-4-24-add-workspace-member/task.md) · [Test](./3-4-24-add-workspace-member/test.md) |
| `3.4.25` | `UC-038` | **Update Workspace Member Role** | `Owner, Manager` | Implemented | [Spec](./3-4-25-update-workspace-member-role/spec.md) · [Plan](./3-4-25-update-workspace-member-role/plan.md) · [Task](./3-4-25-update-workspace-member-role/task.md) · [Test](./3-4-25-update-workspace-member-role/test.md) |
| `3.4.26` | `UC-039` | **Remove Workspace Member** | `Owner, Manager` | Implemented | [Spec](./3-4-26-remove-workspace-member/spec.md) · [Plan](./3-4-26-remove-workspace-member/plan.md) · [Task](./3-4-26-remove-workspace-member/task.md) · [Test](./3-4-26-remove-workspace-member/test.md) |

---

## 3. Core Business Rules & Tenant Invariants

- **`BR-15` & `BR-58` (Ownership & Plan Quotas):** Only the `Owner` may update/remove an Agency, invite/remove Agency members, or manage Agency-scoped Workspace Templates. Agency & Workspace creation enforces active subscription plan limits (`AgencyPlanEntitlementService`).
- **`BR-16` (30-Day Soft Delete & Restore Window):** Removed Agencies and deleted Workspaces transition to `EntityStatus.SOFT_DELETED` with `deleted_at = now()`, allowing `Owner` restoration within 30 days (`410 RESTORE_WINDOW_EXPIRED` thereafter).
- **`BR-17` & `BR-19` (Invitation TTL & Cascading Revocation):** Pending invitations expire automatically (`PENDING` -> `EXPIRED`), support localized email rendering (`vi`/`en`), and removing an Agency member revokes their active internal Workspace memberships across that Agency.
- **`BR-20` & `BR-21` (Strict Workspace Isolation & Single-Manager Rule):** Every Workspace query/mutation validates active membership (`@RequireRole` + `WorkspaceAccessService`), and each Workspace maintains at most one active `Manager` (`409 MANAGER_ALREADY_ASSIGNED`).
- **`BR-22`–`BR-24` (Canonical Timezone & Template Reusability):** Workspace timezone defaults to `Asia/Ho_Chi_Minh` via canonical `timezone_config`, sole `Manager` cannot leave without replacement (`BR-23`), and Workspace Templates snapshot reusable settings without leaking Client credentials or social tokens (`BR-24`).

## 4. Cross-References

- **BA Domain Specification:** [03-agency-workspace.md](../../../ba/03-agency-workspace.md) · [01-organization-structure.md](../../../ba/01-organization-structure.md)
- **BA System Overview:** [BA Overview](../../../ba/README.md)
- **Consolidated Feature Modules:** [Module Specs Index](../../modules/README.md)

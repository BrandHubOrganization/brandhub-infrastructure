# UC 02 — Agency & Workspace (UC-13 → UC-31)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [03-agency-workspace-management.md](../03-agency-workspace-management.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-13 | View Agency List & Dashboard | OWNER | 3.4.1, 3.4.2 |
| UC-14 | Create Agency | OWNER | 3.4.3 |
| UC-15 | View Agency Profile | OWNER | 3.4.4 |
| UC-16 | Update Agency Profile | OWNER | 3.4.5 |
| UC-17 | Delete Agency | OWNER | 3.4.6 |
| UC-18 | Invite Agency Member | OWNER | 3.4.7 |
| UC-19 | View Agency Invitation Status | OWNER | 3.4.8 |
| UC-20 | Remove Agency Member | OWNER | 3.4.9 |
| UC-21 | View Workspace List & Dashboard | OWNER/MEMBER | 3.4.10, 3.4.11 |
| UC-22 | Create Workspace | OWNER/MANAGER | 3.4.12 |
| UC-23 | View Workspace Profile | OWNER/MANAGER | 3.4.13 |
| UC-24 | Update Workspace Profile | OWNER/MANAGER | 3.4.14 |
| UC-25 | Delete Workspace | OWNER | 3.4.15 |
| UC-26 | Leave Workspace | MEMBER | 3.4.16 |
| UC-27 | Save Workspace Template | OWNER | 3.4.17 |
| UC-28 | View Workspace Members | OWNER/MANAGER | 3.4.18 |
| UC-29 | Add Workspace Member | OWNER/MANAGER | 3.4.19 |
| UC-30 | Update Workspace Member Role | OWNER/MANAGER | 3.4.20 |
| UC-31 | Remove Workspace Member | OWNER/MANAGER | 3.4.21 |

---

## UC-13 — View Agency List & Dashboard

- **Actor(s):** OWNER
- **Description:** View the list of Agencies owned and the overview dashboard for each Agency.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. OWNER opens Agency List screen.
  2. System lists all Agencies where `owner_id` = current user.
  3. OWNER selects an Agency → system shows Agency Dashboard (overview stats).

## UC-14 — Create Agency

- **Actor(s):** OWNER (any USER becomes OWNER upon creation)
- **Description:** Create a new Agency, linked to the owner's account.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. USER opens Create Agency form, enters Agency name/profile info.
  2. System creates Agency with `owner_id` = current user (1:1).
- **Postcondition:** New Agency exists; creator becomes its unique OWNER.

## UC-15 — View Agency Profile

- **Actor(s):** OWNER
- **Description:** View the Agency's representative profile information.
- **Precondition:** OWNER of the Agency.
- **Main Flow:**
  1. OWNER opens Agency Profile screen.
  2. System displays Agency profile fields (used to represent the Agency to Clients).

## UC-16 — Update Agency Profile

- **Actor(s):** OWNER
- **Description:** Update the Agency's representative profile information.
- **Precondition:** OWNER of the Agency.
- **Main Flow:**
  1. OWNER edits Agency profile fields, submits.
  2. System validates and persists changes.

## UC-17 — Delete Agency

- **Actor(s):** OWNER
- **Description:** Soft-delete an Agency with confirmation; recoverable within 30 days.
- **Precondition:** OWNER of the Agency.
- **Main Flow:**
  1. OWNER requests Agency deletion, confirms via modal.
  2. System soft-deletes Agency (all Workspaces/members lose access).
- **Postcondition:** Agency recoverable for 30 days, then permanently purged.

## UC-18 — Invite Agency Member

- **Actor(s):** OWNER
- **Description:** Invite a new member into the Agency via email/notification.
- **Precondition:** OWNER of the Agency.
- **Main Flow:**
  1. OWNER enters invitee email, sends invitation.
  2. System notifies invitee via email + in-app notification.
  3. Invitee accepts → becomes Agency Member (no role yet — role only exists at Workspace level).
- **Alternate Flow:**
  - A1. Invitation not accepted within 3 days → auto-expires.

## UC-19 — View Agency Invitation Status

- **Actor(s):** OWNER, USER (invited)
- **Description:** Track the status of a sent invitation (invitation expires after 3 days).
- **Precondition:** An invitation exists.
- **Main Flow:**
  1. Either OWNER or the invited USER opens Invitation Status view.
  2. System shows status: Pending / Accepted / Rejected / Expired.

## UC-20 — Remove Agency Member

- **Actor(s):** OWNER
- **Description:** Remove an existing member from the Agency.
- **Precondition:** OWNER of the Agency; target is an existing Agency Member.
- **Main Flow:**
  1. OWNER selects member, confirms removal.
  2. System removes Agency membership (member loses access to all Workspaces of this Agency).
- **Business Rule:** Resources the removed member created remain (shared asset) — re-adding restores continued access.

## UC-21 — View Workspace List & Dashboard

- **Actor(s):** OWNER/MEMBER
- **Description:** View the list of Workspaces and the overview/statistics for each Workspace.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. OWNER: system lists all Workspaces under their Agency.
  2. MEMBER: system lists only Workspaces the member currently belongs to.
  3. User selects a Workspace → Workspace Dashboard shown.

## UC-22 — Create Workspace

- **Actor(s):** OWNER/MANAGER
- **Description:** Create a new Workspace and assign a Manager to it.
- **Precondition:** OWNER of the parent Agency.
- **Main Flow:**
  1. OWNER opens Create Workspace form.
  2. OWNER assigns exactly one Manager (may self-assign).
  3. System creates Workspace, sets `created_by`, assigns the chosen Manager as the sole `MANAGER` MemberRole.
- **Business Rule:** Exactly 1 Manager per Workspace at all times — no co-management; reassigning Manager revokes the previous one's Manager role.

## UC-23 — View Workspace Profile

- **Actor(s):** OWNER/MANAGER
- **Description:** View the Workspace's profile information, including Timezone configuration.
- **Precondition:** MANAGER of the Workspace, or OWNER of parent Agency.
- **Main Flow:**
  1. User opens Workspace Profile screen.
  2. System displays Workspace fields including Timezone config (used to optimize post-scheduling by location).

## UC-24 — Update Workspace Profile

- **Actor(s):** OWNER/MANAGER
- **Description:** Update the Workspace's profile information, including Timezone configuration.
- **Precondition:** MANAGER of the Workspace.
- **Main Flow:**
  1. MANAGER edits Workspace fields (name, timezone, etc.), submits.
  2. System validates and persists changes.

## UC-25 — Delete Workspace

- **Actor(s):** OWNER
- **Description:** Delete a Workspace (recoverable within 30 days), moving related data to an inactive state.
- **Precondition:** OWNER of the parent Agency.
- **Main Flow:**
  1. OWNER requests Workspace deletion, confirms via modal.
  2. System soft-deletes Workspace; all members lose access; related data set inactive.
- **Postcondition:** Recoverable within 30 days.

## UC-26 — Leave Workspace

- **Actor(s):** MEMBER
- **Description:** A member leaves a specific Workspace while remaining part of the Agency.
- **Precondition:** User is a member of the target Workspace.
- **Main Flow:**
  1. MEMBER selects Leave Workspace, confirms.
  2. System removes the member's Workspace-level role; Agency membership unaffected.

## UC-27 — Save Workspace Template

- **Actor(s):** OWNER
- **Description:** Save the current Workspace configuration as a template for reuse.
- **Precondition:** OWNER of parent Agency.
- **Main Flow:**
  1. OWNER selects Save as Template on an existing Workspace.
  2. System stores a reusable Workspace Template (config snapshot).
- **Postcondition:** Template available for future Workspace creation (see UC-22 alternate entry point).

## UC-28 — View Workspace Members

- **Actor(s):** OWNER/MANAGER (any MEMBER can view per FR 3.4.18)
- **Description:** View the list of members belonging to a Workspace.
- **Precondition:** User is a member of the Workspace, or OWNER of parent Agency.
- **Main Flow:**
  1. User opens Workspace Members screen.
  2. System lists members with their Workspace-level role (MANAGER/MEMBER/CLIENT).

## UC-29 — Add Workspace Member

- **Actor(s):** OWNER/MANAGER
- **Description:** Add an Agency member into a Workspace with an assigned role.
- **Precondition:** Target user is already an Agency Member.
- **Main Flow:**
  1. MANAGER selects an existing Agency Member, assigns a Workspace role.
  2. System creates the Workspace membership with that role.
- **Alternate Flow:**
  - A1. Target user is not yet an Agency Member → blocked; must be invited to Agency first (UC-18).

## UC-30 — Update Workspace Member Role

- **Actor(s):** OWNER/MANAGER
- **Description:** Update the role of an existing Workspace member.
- **Precondition:** Target is an existing Workspace member.
- **Main Flow:**
  1. MANAGER selects member, changes assigned role.
  2. System updates the Workspace-level role (role change applies only to this Workspace).

## UC-31 — Remove Workspace Member

- **Actor(s):** OWNER/MANAGER
- **Description:** Remove a member from the Workspace.
- **Precondition:** Target is an existing Workspace member.
- **Main Flow:**
  1. MANAGER selects member, confirms removal.
  2. System removes Workspace-level membership only (Agency membership unaffected).

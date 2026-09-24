# 3.4.9 Remove Member

## Function Trigger
The Owner of an Agency opens the Member list of that Agency (`/agencies/:agencyId/members`), selects Remove on a member row and confirms.

## Function Description
- **Actors / Roles:** Agency Owner.
- **Purpose:** Let the Owner take a member out of the Agency so that person loses access, while everything they produced while working there stays with the Agency as shared property.
- **Interface:** Member list page (`/agencies/:agencyId/members`) with a Remove action on each member row and a confirmation step.
- **Data Processing:** The system loads the Agency, confirms the caller is its Owner, locates the member record inside that Agency, refuses the removal when the record is the Owner, and otherwise removes the member record. Removing the record ends the person's access to every Workspace of the Agency at once, while the resources they created remain in place, owned by the Agency as before.

## Screen Layout
Figure — Member list:
- One row per member with their name, email and member role.
- A Remove action on each row behind a confirmation step, not offered for the Owner row.
- On success the row disappears and the list refreshes.

## Function Details
### Data Specifications
- **Input required:** The Agency identifier (`agencyId`), the member record identifier (`memberId`) and a signed-in session as the Agency Owner.
- **Input optional:** None.
- **System data:** The Agency record and its Owner identifier (access check), and the member record with its Agency and its role.
- **Output:** No data is returned. The member record is removed and the person loses access to the Agency and to all of its Workspaces.

### Business Rules
- **BR-28:** Remove member: only Owner/Manager-equivalent (here, the Agency Owner) may remove; the last remaining OWNER cannot be removed. Anybody other than the Owner is refused with `403 NOT_AGENCY_OWNER`.
- The identifier used is the member record of the Agency, not the person's user identifier. A record that does not exist, or belongs to another Agency, is refused with `404 NOT_FOUND`.
- The Owner's own member record can never be removed, whatever the caller attempts (BR-28, "the last remaining OWNER cannot be removed"). The attempt is refused with `409 CANNOT_REMOVE_OWNER`. There is no ownership transfer, so the Owner cannot hand the Agency over before stepping away.
- Removing a member ends their access to every Workspace of the Agency at once, including Workspaces where they held a manager or member role, because access everywhere rests on the member record that has just been removed.
- The resources the removed member created — tasks, materials, content and the like — are not removed and do not change owner. They stay with the Workspace and the Agency as shared property.
- When the person is invited back into the Agency later, they can edit and continue using the resources they created before, because that work never stopped belonging to the Agency.
- Work assigned to the removed member is not reassigned automatically. A manager has to handle it by hand.

### Validation
- Caller is not the Agency Owner → Display: MSG39
- The member record does not exist, or belongs to another Agency → Display: MSG38
- The member record is the Owner's own → Display: MSG37, and nothing is removed.

## Functionalities
### Normal Flow
1. The Owner opens the Member list of an Agency.
2. The Owner selects Remove on a member row other than their own and confirms.
3. The client submits the removal with the member record identifier.
4. The system loads the Agency and confirms the caller is its Owner.
5. The system locates the member record inside that Agency.
6. The system removes the member record.
7. The client drops the row and shows a confirmation; toast MSG36. The person loses access to the Agency and to every one of its Workspaces immediately.
8. The resources that person created stay in the Workspace and the Agency, unchanged and still usable.

### Abnormal Cases
- 4.a1: Caller is not the Agency Owner (BR-28) → `403 NOT_AGENCY_OWNER`, toast MSG39; nothing is removed. 4.a2: The caller returns to the Agency list and opens an Agency they own.
- 5.a1: The member record does not exist, or belongs to another Agency → `404 NOT_FOUND`, toast MSG38. 5.a2: The Owner refreshes the Member list.
- 5.b1: Remove selected on the Owner's own row (BR-28) → `409 CANNOT_REMOVE_OWNER`, toast MSG37; nothing is removed. 5.b2: The Owner accepts that self-removal is not available and, if stepping away, contacts support since there is no ownership transfer.
- 6.a1: The removed member had work in progress assigned to them in a Workspace → the work is not unassigned automatically; no error, no toast. 6.a2: A manager handles the reassignment by hand, because that work still belongs to the Workspace.

## Post-Conditions
- The member record no longer exists, and the person loses access to the Agency and to all of its Workspaces immediately.
- The resources the person created remain with the Workspace and the Agency, and stay usable by anyone holding access.
- Work assigned to the person remains assigned until a manager handles it.

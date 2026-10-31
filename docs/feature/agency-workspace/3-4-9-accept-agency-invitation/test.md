# Test Specification — FR 3.4.9: Accept Agency Invitation

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.9` |
| **Function Name** | Accept Agency Invitation |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Manager, Creator, Client` |
| **Target Class & Method** | `AgencyServiceImpl.acceptInvitation()` (141 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Validate a PENDING, non-expired invitation token, mark it ACCEPTED, and create agency and workspace membership records |
| **Preconditions** | Can connect with server; Invitation token is PENDING and not expired |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token)` | 200 OK - AgencyMemberResponse returned and AgencyMember(role=MEMBER) saved | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token, clientProfileId)` | 200 OK - Invitation status set to ACCEPTED and acceptedAt=OffsetDateTime.now() | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `workspace-linked invitation token`, `request` = `AcceptInvitationRequest(token)` | 200 OK - WorkspaceMember created with role=CREATOR when workspaceId is present | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `workspace-linked invitation token`, `request` = `AcceptInvitationRequest(token, clientProfileId)` | 200 OK - WorkspaceMember created with role=MANAGER after assertNoManagerYet check | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); Invitation includes workspaceId and role assignment (CREATOR, MANAGER, or CLIENT) | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token, newClientProfile)` | 200 OK - CLIENT invitation links owned ClientProfile to WorkspaceMember without AgencyMember row | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); Invitation includes workspaceId and role assignment (CREATOR, MANAGER, or CLIENT) | `token` = `workspace-linked invitation token`, `request` = `AcceptInvitationRequest(token, newClientProfile)` | 200 OK - CLIENT invitation creates new ClientProfile when newClientProfile payload provided | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token)` | 200 OK - Fallback workspace_invitations token accepted and AgencyMember auto-created | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token, clientProfileId)` | 200 OK - Existing active WorkspaceMember skipped idempotently without duplicate row | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); Invitation is at exact 72h boundary before expiresAt | `token` = `boundary 72h pending token`, `request` = `idempotent existing workspace member` | 200 OK - Token accepted at exact expiresAt boundary before expiration | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); Invitation is at exact 72h boundary before expiresAt | `token` = `boundary 72h pending token`, `request` = `idempotent existing workspace member` | 200 OK - Case-insensitive email match (equalsIgnoreCase) succeeds | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token, newClientProfile)` | 200 OK - Trimmed newClientProfile.displayName persisted on Client accept | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); Invitation status is REVOKED/ACCEPTED or expiresAt is in the past | `token` = `expired or revoked token`, `request` = `AcceptInvitationRequest(token)` | INVALID_INVITATION - 400 Invitation token not found, not PENDING, or expired | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); Invitation status is REVOKED/ACCEPTED or expiresAt is in the past | `token` = `non-existent token`, `request` = `AcceptInvitationRequest(token)` | INVALID_INVITATION - 400 Invited email does not match authenticated user email | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Authenticated user email does not match invitation invitedEmail | `token` = `valid agency invitation token`, `request` = `AcceptInvitationRequest(token)` | ALREADY_AGENCY_MEMBER - 409 User is already a member of this agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `expired or revoked token`, `request` = `already agency member user` | MANAGER_ALREADY_ASSIGNED - 409 Target workspace already has an active Manager | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is authenticated (Owner, Manager, Creator, or Client); AgencyInvitation or WorkspaceInvitation exists in PENDING status before expiresAt | `token` = `non-existent token`, `request` = `CLIENT invite without profile` | CLIENT_PROFILE_REQUIRED_FOR_ACCEPT - 400 Client invite requires clientProfileId or newClientProfile | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.9`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

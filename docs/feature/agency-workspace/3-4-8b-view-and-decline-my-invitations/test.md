# Test Specification — FR 3.4.10: Decline Agency Invitation

> Note: This specification maps to official **FR 3.4.10 — Decline Agency Invitation** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-10-decline-agency-invitation/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.10` |
| **Function Name** | Decline Agency Invitation |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Manager, Creator, Client` |
| **Target Class & Method** | `AgencyServiceImpl.declineInvitation()` (13 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Validate a PENDING agency invitation token before expiration and transition its status to REVOKED |
| **Preconditions** | Can connect with server; Invitation token is PENDING and not expired |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `valid pending invitation token`, `request` = `DeclineInvitationRequest(token)` | 200 OK - Invitation status transitioned from PENDING to REVOKED | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `valid pending invitation token`, `request` = `decline before login` | 200 OK - agencyInvitationRepository.save(invitation) persists terminal REVOKED status | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `workspace-assigned pending token`, `request` = `DeclineInvitationRequest(token)` | 200 OK - No AgencyMember record created for declined invitation | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `workspace-assigned pending token`, `request` = `decline before login` | 200 OK - No WorkspaceMember record created for workspace-linked invitation | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; User has not yet accepted the invitation | `token` = `valid pending invitation token`, `request` = `decline CLIENT invitation` | 200 OK - CLIENT role invitation declined cleanly without creating ClientProfile | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; User has not yet accepted the invitation | `token` = `workspace-assigned pending token`, `request` = `decline CLIENT invitation` | 200 OK - Declined invitation shown as REVOKED in Owner listInvitations view | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `valid pending invitation token`, `request` = `DeclineInvitationRequest(token)` | 200 OK - Owner can send a fresh invitation to the same email after decline | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `valid pending invitation token`, `request` = `decline before login` | 200 OK - Other pending invitations for the same email in other agencies unaffected | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation is at exact 72h boundary before expiresAt | `token` = `boundary 72h pending token`, `request` = `decline at 72h boundary` | 200 OK - Decline succeeds right before expiresAt timestamp boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation is at exact 72h boundary before expiresAt | `token` = `boundary 72h pending token`, `request` = `decline at 72h boundary` | 200 OK - Decline of invitation with null note and null workspaceId succeeds | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `valid pending invitation token`, `request` = `decline CLIENT invitation` | 200 OK - Decline of MANAGER-targeted workspace invitation leaves Manager slot open | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is already ACCEPTED or REVOKED, or expiresAt has passed | `token` = `already ACCEPTED/REVOKED token`, `request` = `DeclineInvitationRequest(token)` | INVALID_INVITATION - 400 Invitation status is already ACCEPTED (not PENDING) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is already ACCEPTED or REVOKED, or expiresAt has passed | `token` = `non-existent token UUID`, `request` = `DeclineInvitationRequest(token)` | INVALID_INVITATION - 400 Invitation token not found in agency_invitations | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Token does not exist in agency_invitations table | `token` = `valid pending invitation token`, `request` = `DeclineInvitationRequest(token)` | INVALID_INVITATION - 400 Invitation status is already REVOKED | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `already ACCEPTED/REVOKED token`, `request` = `expired invitation token` | INVALID_INVITATION - 400 Invitation has expired (expiresAt < now) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; AgencyInvitation exists in agency_invitations table; Invitation status is PENDING and expiresAt is after OffsetDateTime.now() | `token` = `non-existent token UUID`, `request` = `blank / unknown token` | VALIDATION_ERROR - 400 DeclineInvitationRequest token must not be blank | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

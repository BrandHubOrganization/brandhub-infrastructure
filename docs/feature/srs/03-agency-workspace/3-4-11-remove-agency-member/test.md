> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.4.11: Remove Agency Member

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.11` |
| **Function Name** | Remove Agency Member |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyServiceImpl.removeMember()` (24 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to remove a non-Owner member from the agency while preserving created assets |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 2, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency; Target is MANAGER member | `agencyId` = `existing id`, `memberId` = `manager member id` | 204 - agency member row deleted | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency; Target is CREATOR member | `agencyId` = `existing id`, `memberId` = `creator member id` | 204 - agency member row deleted | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency; Target is CLIENT member | `agencyId` = `existing id`, `memberId` = `client member id` | 204 - agency member row deleted | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency; Agency has 3 members | `agencyId` = `existing id`, `memberId` = `creator member id` | 204 - 2 members remain | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Removed member also in other agency | `agencyId` = `existing id`, `memberId` = `creator member id` | 204 - only this agency row deleted | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Target member in workspace of agency | `agencyId` = `existing id`, `memberId` = `creator member id` | 204 - agency member row deleted | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; User is OWNER of agency; Agency has owner and 1 member | `agencyId` = `existing id`, `memberId` = `only member id` | 204 - only owner remains | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is OWNER of agency; Target is the newest member | `agencyId` = `existing id`, `memberId` = `newest member id` | 204 - agency member row deleted | — | **Passed** |
| `UTCID09` | `A` | Can connect with server; User is OWNER of agency; Target is OWNER member row | `agencyId` = `existing id`, `memberId` = `owner member id` | CANNOT_REMOVE_OWNER: Cannot remove the owner of the agency | — | **Passed** |
| `UTCID10` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `memberId` = `non-existing id` | NOT_FOUND: resource not found | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User is OWNER of agency; Member belongs to another agency | `agencyId` = `existing id`, `memberId` = `other agency member id` | NOT_FOUND: resource not found | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id`, `memberId` = `creator member id` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member role MANAGER | `agencyId` = `existing id`, `memberId` = `creator member id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member role CREATOR | `agencyId` = `existing id`, `memberId` = `creator member id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is not related to agency | `agencyId` = `existing id`, `memberId` = `creator member id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member removing self | `agencyId` = `existing id`, `memberId` = `own member id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `memberId` = `null` | NOT_FOUND: resource not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.4.11`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `DELETE /api/v1/agencies/{agencyId}/members/{memberId}` (`AgencyController.removeMember()` -> `AgencyServiceImpl.removeMember()`) returns standardized `ApiResponse` payloads and `ErrorCode` statuses (`400 CANNOT_REMOVE_OWNER`, `403 FORBIDDEN`, `404 MEMBER_NOT_FOUND` / `AGENCY_NOT_FOUND`).
- **Multi-Tenant Isolation:** Verified unauthorized callers and cross-Agency/cross-Workspace requests are rejected (`403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale keys (`agency.members.remove.*`) and `Light` / `Dark` semantic theme rendering on `src/pages/agency/members.tsx`, `src/pages/agency/components/{RemoveAgencyMemberDialog,MemberProfileDrawer}.tsx`, `src/services/agencyService.ts`.
- **Traceability:** Linked to [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md).

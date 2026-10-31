# Test Specification — FR 3.4.2: View Agency Dashboard

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.2` |
| **Function Name** | View Agency Dashboard |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyServiceImpl.getStats()` (95 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Aggregate agency-wide KPI statistics: active workspaces, members by role, campaign progress, and credit consumption |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 5, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency; Agency has members, workspaces, posts | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - AgencyStatsResponse with totals, membersByRole, workspacesByIndustry, contentByStatus | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of agency (not owner); Agency has data | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - AgencyStatsResponse | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency; Agency has data | `agencyId` = `existing id`, `from` = `2026-01-01`, `to` = `2026-06-30` | 200 - stats filtered to date range | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency; Agency has PUBLISHED posts | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - postsPublishedByMonth grouped yyyy-MM | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Agency has members joined in different months | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - memberGrowthByMonth grouped by month | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Agency has workspaces with industry | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - workspacesByIndustry counts | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; User is OWNER of agency; Agency has no workspaces | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - totalWorkspaces=0, no Mongo query, empty content maps | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is OWNER of agency; Agency has only the owner member | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | 200 - totalMembers=1, membersByRole={OWNER:1} | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is OWNER of agency; Member joined exactly on from date | `agencyId` = `existing id`, `from` = `joinedAt date`, `to` = `null` | 200 - member included (inclusive bound) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency; Member joined exactly on to date | `agencyId` = `existing id`, `from` = `null`, `to` = `joinedAt date` | 200 - member included (inclusive bound) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is OWNER of agency; Agency has data | `agencyId` = `existing id`, `from` = `only from set`, `to` = `null` | 200 - open-ended range filter applied | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is OWNER of agency; Agency has data | `agencyId` = `existing id`, `from` = `not-a-date`, `to` = `null` | 200 - invalid date ignored, full-range stats | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id`, `from` = `null`, `to` = `null` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is not related to agency | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User has CLIENT access only to agency workspace | `agencyId` = `existing id`, `from` = `null`, `to` = `null` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is OWNER of agency; Range excludes all data | `agencyId` = `existing id`, `from` = `2000-01-01`, `to` = `2000-01-31` | 200 - all counts 0, empty maps | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.6.23: Update Hashtag Collection

> Note: This specification maps to official **FR 3.6.23 — Update Hashtag Collection** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-23-update-hashtag-collection/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.23` |
| **Function Name** | Update Hashtag Collection |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `HashtagServiceImpl.updateHashtag()` (30 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/HashtagServiceImplTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Update a hashtag collection's name, category, and normalized hashtag list while preventing duplicate collection names |
| **Preconditions** | Can connect with server; Hashtag collection exists in workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 0, `Failed`: 0, `Untested`: 19) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `#newtag` | 200 OK - updated hashtag (tag changed) | Hashtag updated | **Untested** |
| `UTCID02` | `N` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `purpose` = `campaign` | 200 OK - updated hashtag (purpose changed) | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; Hashtag exists in workspace; User is CLIENT who created hashtag | `workspaceId` = `valid`, `hashtagId` = `valid`, `isRequired` = `true` | 200 OK - isRequired=true | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; Hashtag exists in workspace; User is CLIENT who created hashtag | `workspaceId` = `valid`, `hashtagId` = `valid`, `isRequired` = `false` | 200 OK - isRequired=false | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `#newtag`, `purpose` = `trending`, `isRequired` = `false` | 200 OK - all 3 fields updated | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace; Hashtag applied to many old Tasks | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `#newtag` | 200 OK - old Tasks keep previous tag value | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `same tag as current` | 200 OK - unchanged hashtag returned | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - unchanged hashtag returned (empty patch) | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `1 char after #` | 200 OK - shortest tag | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `max length tag` | 200 OK - longest tag | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `max length + 1 chars` | 400 VALIDATION_ERROR (tag too long) | — | **Untested** |
| `UTCID12` | `B` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `empty` | 400 VALIDATION_ERROR (tag cannot be empty) | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; Hashtag exists in workspace; User is not the creator and has no permission | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `#newtag` | 403 FORBIDDEN | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is the creator of the hashtag; Hashtag does not exist | `workspaceId` = `valid`, `hashtagId` = `non-existent` | 404 HASHTAG_NOT_FOUND | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is the creator of the hashtag; Hashtag is removed | `workspaceId` = `valid`, `hashtagId` = `removed` | 404 HASHTAG_NOT_FOUND | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace; Another hashtag has the same tag | `workspaceId` = `valid`, `hashtagId` = `valid`, `tag` = `duplicate tag` | 409 HASHTAG_ALREADY_EXISTS | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; User is the creator of the hashtag; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid`, `purpose` = `unknown` | 400 VALIDATION_ERROR (invalid purpose) | — | **Untested** |
| `UTCID18` | `A` | Can connect with server; User is the creator of the hashtag; Workspace does not exist | `workspaceId` = `non-existent`, `hashtagId` = `valid` | 404 WORKSPACE_NOT_FOUND | — | **Untested** |
| `UTCID19` | `A` | Can connect with server; User is the creator of the hashtag; Hashtag belongs to another workspace | `workspaceId` = `valid`, `hashtagId` = `other workspace hashtag` | 404 HASHTAG_NOT_FOUND | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.23`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.6.35: Chat Realtime

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.35` |
| **Function Name** | Chat Realtime |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `ChatServiceImpl.send()` (46 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ChatServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Send, persist, and broadcast real-time workspace chat messages and attachments over STOMP WebSocket with workspace isolation |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 25** (`Passed`: 25, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 10, `Boundary (B)`: 4, `Abnormal (A)`: 11 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID25`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `Hello team`, `clientMessageId` = `new uuid` | ChatMessageResponse - saved, senderRole from membership | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `padded text`, `clientMessageId` = `new uuid` | ChatMessageResponse - content trimmed | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is active workspace member; User is MANAGER of workspace | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid` | ChatMessageResponse - senderRole=MANAGER | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is active workspace member; User is CLIENT of workspace | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid` | ChatMessageResponse - senderRole=CLIENT | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is active workspace member; User is CREATOR of workspace | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid` | ChatMessageResponse - senderRole=CREATOR | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is active workspace member; Media package belongs to workspace | `contextType` = `MEDIA_PACKAGE`, `content` = `About package`, `clientMessageId` = `new uuid`, `contextId` = `package id in workspace` | ChatMessageResponse - contextType=MEDIA_PACKAGE | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is active workspace member; Media campaign belongs to workspace | `contextType` = `MEDIA_CAMPAIGN`, `content` = `About campaign`, `clientMessageId` = `new uuid`, `contextId` = `campaign id in workspace` | ChatMessageResponse - contextType=MEDIA_CAMPAIGN | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is active workspace member; Message with same clientMessageId already saved | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `existing uuid` | ChatMessageResponse - existing message returned, no insert | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is active workspace member; Concurrent insert hits DuplicateKeyException | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `same uuid` | ChatMessageResponse - existing saved message returned | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `<b>bold</b>`, `clientMessageId` = `new uuid` | ChatMessageResponse - stored as plain text, no HTML render | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `1 char`, `clientMessageId` = `new uuid` | ChatMessageResponse - saved | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `4000 chars`, `clientMessageId` = `new uuid` | ChatMessageResponse - saved | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `4001 chars`, `clientMessageId` = `new uuid` | CHAT_MESSAGE_INVALID (400): Chat message must contain between 1 and 4000 characters | — | **Passed** |
| `UTCID14` | `B` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `4000 chars plus surrounding spaces`, `clientMessageId` = `new uuid` | ChatMessageResponse - saved after trim | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `empty`, `clientMessageId` = `new uuid` | CHAT_MESSAGE_INVALID (400): Chat message must contain between 1 and 4000 characters | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `only spaces`, `clientMessageId` = `new uuid` | CHAT_MESSAGE_INVALID (400): Chat message must contain between 1 and 4000 characters | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `null`, `clientMessageId` = `new uuid` | CHAT_MESSAGE_INVALID (400): Chat message must contain between 1 and 4000 characters | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is active workspace member | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid`, `contextId` = `some uuid` | CHAT_CONTEXT_INVALID (400): Chat context does not belong to this workspace | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is active workspace member | `contextType` = `MEDIA_PACKAGE`, `content` = `Hello`, `clientMessageId` = `new uuid`, `contextId` = `null` | CHAT_CONTEXT_INVALID (400): Chat context does not belong to this workspace | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is active workspace member | `contextType` = `MEDIA_PACKAGE`, `content` = `Hello`, `clientMessageId` = `new uuid`, `contextId` = `package of another workspace` | CHAT_CONTEXT_INVALID (400): Chat context does not belong to this workspace | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is active workspace member | `contextType` = `MEDIA_CAMPAIGN`, `content` = `Hello`, `clientMessageId` = `new uuid`, `contextId` = `non-existent campaign` | CHAT_CONTEXT_INVALID (400): Chat context does not belong to this workspace | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; User is active workspace member; Rate limit exceeded | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid` | CHAT_RATE_LIMIT_EXCEEDED (429): Chat message rate limit exceeded | — | **Passed** |
| `UTCID23` | `A` | Can connect with server; User is not active member of workspace | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid` | WORKSPACE_ACCESS_DENIED (403): You do not have access to this workspace | — | **Passed** |
| `UTCID24` | `A` | Can connect with server; Member was removed from workspace | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `new uuid` | WORKSPACE_ACCESS_DENIED (403): You do not have access to this workspace | — | **Passed** |
| `UTCID25` | `A` | Can connect with server; User is not active member of workspace | `contextType` = `GENERAL`, `content` = `Hello`, `clientMessageId` = `existing uuid` | WORKSPACE_ACCESS_DENIED (403): You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.35`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

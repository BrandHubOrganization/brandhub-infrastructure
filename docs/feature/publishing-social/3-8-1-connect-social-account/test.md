# Test Specification — FR 3.8.1: Connect Social Account

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.1` |
| **Function Name** | Connect Social Account |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `SocialAccountServiceImpl.syncAccount()` (54 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/SocialAccountServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Connect a Facebook, Instagram, TikTok, or Threads account via OAuth 2.0, enforce plan channel limits, and encrypt tokens with AES-256 |
| **Preconditions** | Can connect with server; Caller is Client, Owner, or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `valid code`, `state` = `valid state` | 200 - accountId, platform=FACEBOOK, displayName | Social account connected | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CLIENT of workspace | `platform` = `instagram`, `code` = `valid code`, `state` = `valid state` | 200 - accountId, platform=INSTAGRAM, displayName | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CLIENT of workspace | `platform` = `tiktok`, `code` = `valid code`, `state` = `valid state` | 200 - accountId, platform=TIKTOK, displayName | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CLIENT of workspace | `platform` = `threads`, `code` = `valid code`, `state` = `valid state` | 200 - accountId, platform=THREADS, displayName | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CLIENT of workspace; Account previously disconnected | `platform` = `facebook`, `code` = `valid code`, `state` = `valid state` | 200 - old record reactivated, post history kept | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `valid code`, `state` = `valid state` | 200 - access token persisted in encrypted form | Token encrypted before save | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook` | 302 - redirect to OAuth consent URL (connect step) | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CLIENT of workspace | `platform` = `FACEBOOK`, `code` = `valid code`, `state` = `valid state` | 200 - platform matched case-insensitively | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `1 char`, `state` = `valid state` | 200 - connected (code of minimum length accepted) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CLIENT of workspace; Token response has no refresh token | `platform` = `facebook`, `code` = `valid code`, `state` = `valid state` | 200 - connected, refresh token empty | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `myspace`, `code` = `valid code`, `state` = `valid state` | UNSUPPORTED_PLATFORM: This social platform is not supported | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `null`, `code` = `valid code`, `state` = `valid state` | UNSUPPORTED_PLATFORM: This social platform is not supported | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `null`, `state` = `valid state` | OAUTH_CODE_INVALID: OAuth authorization code exchange failed | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `expired code`, `state` = `valid state` | OAUTH_CODE_INVALID: OAuth authorization code exchange failed | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `valid code`, `state` = `wrong state` | OAUTH_STATE_INVALID: OAuth state is invalid or has expired | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `valid code`, `state` = `expired state` | OAUTH_STATE_INVALID: OAuth state is invalid or has expired | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CLIENT of workspace; Platform account already connected | `platform` = `facebook`, `code` = `valid code`, `state` = `valid state` | ACCOUNT_ALREADY_CONNECTED: A social account for this platform is already connected | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CLIENT of workspace | `platform` = `facebook`, `code` = `user cancelled consent` | OAUTH_CODE_INVALID: OAuth authorization code exchange failed | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is not CLIENT | `platform` = `facebook`, `code` = `valid code`, `state` = `valid state` | FORBIDDEN: access denied | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.7.14: Suggest Hashtag Trend

> Note: This specification maps to official **FR 3.7.14 — Suggest Hashtag Trend** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-7-14-suggest-hashtag-trend/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.14` |
| **Function Name** | Suggest Hashtag Trend |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `contextual_hashtag_service.suggest_hashtags()` (38 LOC) |
| **Unit Test File** | `brandhub-ai-service/tests/unit/services/test_contextual_hashtag_service.py` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Suggest high-momentum trending hashtags matched to post caption context and workspace industry via AI service |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5` | 200 - 5 hashtags mixed from topic and trends | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `tiktok`, `clientId` = `c1`, `count` = `5` | 200 - hashtags optimized for tiktok | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `10` | 200 - 10 hashtags | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5`, `brand_name` = `BrandHub` | 200 - hashtags include brand hashtag | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5`, `trend_name` = `summer sale` | 200 - hashtags include trend name | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5`, `category` = `fashion` | 200 - trends filtered by category fashion | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Redis trend cache populated | `topic` = `thoi trang mua he (accented)`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5`, `strip_accents` = `true` | 200 - hashtags without Vietnamese accents | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; 6h trends empty, 24h trends populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5` | 200 - uses 24h trends as fallback | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `1` | 200 - exactly 1 hashtag | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `null` | 200 - default 5 hashtags | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `0` | 200 - default 5 hashtags (count <= 0 falls back) | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `-1` | 200 - default 5 hashtags | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Trend cache empty | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5` | 200 - hashtags from topic only, empty trend list no error | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Redis connection fails | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5` | 200 - hashtags from topic only (warning logged) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Redis trend cache populated | `topic` = `gibberish no match`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5` | 200 - minimal hashtag list, no error | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Redis trend cache populated | `topic` = `null`, `platform` = `instagram`, `clientId` = `c1`, `count` = `5` | 422 Validation error (topic required) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Redis trend cache populated | `topic` = `summer fashion`, `platform` = `instagram`, `clientId` = `null`, `count` = `5` | 422 Validation error (clientId required) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.14`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

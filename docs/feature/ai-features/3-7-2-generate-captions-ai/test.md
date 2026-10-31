# Test Specification — FR 3.7.6: Generate Caption

> Note: This specification maps to official **FR 3.7.6 — Generate Caption** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-7-6-generate-caption/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.6` |
| **Function Name** | Generate Caption |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `AiCaptionService.generate()` (58 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AiCaptionServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Generate brand-aligned social captions via Hybrid GraphRAG (ChromaDB + Neo4j + LLM) with atomic AI credit deduction and refund |
| **Preconditions** | Can connect with server; Workspace has sufficient AI credits |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 200 - 3 caption variants (HOOK_DRIVEN, STORYTELLING, DIRECT_CTA) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `professional`, `platform` = `facebook`, `length` = `medium` | 200 - 3 variants with professional tone | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `tiktok`, `length` = `medium` | 200 - 3 variants for tiktok | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `linkedin`, `length` = `long` | 200 - 3 long variants for linkedin | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `short` | 200 - 3 short variants | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium`, `language` = `en` | 200 - 3 English variants | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium`, `target_audience` = `Gen Z`, `brand_context` = `brand voice`, `trend_context` = `trend keywords` | 200 - variants use audience, brand and trend context | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Creator has enough AI credit | `topic` = `10 chars exact`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 200 - 3 variants (topic min length 10) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Creator has enough AI credit | `topic` = `1000 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 200 - 3 variants (topic max length 1000) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium`, `target_audience` = `500 chars` | 200 - 3 variants (audience max 500) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Creator has enough AI credit | `topic` = `9 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 422 Validation error (topic < 10 chars) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Creator has enough AI credit | `topic` = `1001 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 422 Validation error (topic > 1000 chars) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Creator has enough AI credit | `topic` = `null`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 422 Validation error (topic required) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `sarcastic`, `platform` = `facebook`, `length` = `medium` | 422 Validation error (invalid tone) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `youtube`, `length` = `medium` | 422 Validation error (unsupported platform) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Creator has enough AI credit | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `huge` | 422 Validation error (invalid length) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; LLM provider fails (LLMQualityError) | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 502 Caption generation failed | — | **Passed** |
| `UTCID18` | `A` | Request has invalid internal API key | `topic` = `valid topic 40 chars`, `tone` = `friendly`, `platform` = `facebook`, `length` = `medium` | 403 Forbidden (invalid internal key) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

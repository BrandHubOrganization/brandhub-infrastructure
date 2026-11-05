# Test Specification — FR 3.7.12: Export File

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.12` |
| **Function Name** | Export File |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `AssetExportService.exportAsset()` (34 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Convert and export generated AI media assets into platform-optimized formats (MP4, WebM, PNG, JPG, WEBP) and aspect ratios at zero credit cost |
| **Preconditions** | Can connect with server; AI asset exists in workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 0, `Failed`: 0, `Untested`: 17) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `png` | 200 - PNG binary stream | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `jpg` | 200 - JPG binary stream | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; Asset is video owned by workspace | `assetId` = `valid video asset`, `format` = `mp4` | 200 - mp4 binary stream | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; Asset is video owned by workspace | `assetId` = `valid video asset`, `format` = `webm` | 200 - webM binary stream | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; Asset has no watermark applied | `assetId` = `valid image asset`, `format` = `png` | 200 - file without watermark | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; Watermark applied before export | `assetId` = `watermarked asset`, `format` = `png` | 200 - file keeps applied watermark | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `PNG` | 200 - format is case-insensitive | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; Asset is video owned by workspace | `assetId` = `valid video asset`, `format` = `mp4` | 200 - Content-Disposition attachment header | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `jpg` | 200 - original resolution preserved | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; Asset is video owned by workspace | `assetId` = `largest video asset`, `format` = `mp4` | 200 - large file streamed | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `empty` | 200 - default format of the asset | — | **Untested** |
| `UTCID12` | `A` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `mp4` | 400 UNSUPPORTED_EXPORT_FORMAT | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; Asset is video owned by workspace | `assetId` = `valid video asset`, `format` = `png` | 400 UNSUPPORTED_EXPORT_FORMAT | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; Asset is image owned by workspace | `assetId` = `valid image asset`, `format` = `xyz` | 400 UNSUPPORTED_EXPORT_FORMAT | — | **Untested** |
| `UTCID15` | `A` | Can connect with server | `assetId` = `non-existent id`, `format` = `png` | 404 Asset not found | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; Asset belongs to another workspace | `assetId` = `other workspace asset`, `format` = `png` | 403 FORBIDDEN | — | **Untested** |
| `UTCID17` | `A` | User is not authenticated | `assetId` = `valid image asset`, `format` = `png` | 401 UNAUTHORIZED | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.12`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

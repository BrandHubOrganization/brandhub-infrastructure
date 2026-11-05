# Test Specification — FR 3.6.18: Apply Watermark

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.18` |
| **Function Name** | Apply Watermark |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MaterialServiceImpl.applyWatermark()` (56 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/MaterialServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Overlay a brand logo or brand text watermark (position, scale, rotation, opacity) onto an image and save as a new material |
| **Preconditions** | Can connect with server; Target image material exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 201 Created - {id, url} of new watermarked file | Watermark applied | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `top-left`, `opacity` = `0.5` | 201 Created - new file with top-left watermark | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `center`, `opacity` = `0.5` | 201 Created - new file with centered watermark | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `1.0` | 201 Created - fully opaque watermark | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 201 Created - original image not overwritten | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 201 Created - new material id differs from original | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Image format is PNG | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 201 Created - output format kept | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0` | 201 Created - fully transparent watermark | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `1` | 201 Created - max opacity accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `1.01` | 400 VALIDATION_ERROR (opacity > 1) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `-0.01` | 400 VALIDATION_ERROR (opacity < 0) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched | `materialId` = `valid`, `logoAssetId` = `non-existent`, `position` = `bottom-right`, `opacity` = `0.5` | 400 LOGO_NOT_FOUND | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Brand Collection has no logo | `materialId` = `valid`, `logoAssetId` = `any`, `position` = `bottom-right`, `opacity` = `0.5` | 400 LOGO_NOT_FOUND (client must upload a logo first) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR in workspace; Logo exists in Client Brand Collection; Material does not exist | `materialId` = `non-existent`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR in workspace; Logo exists in Client Brand Collection; Material is a video | `materialId` = `video file`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 400 VALIDATION_ERROR (only images supported) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Material is an image marked retouched; Logo exists in Client Brand Collection; User is CLIENT | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `bottom-right`, `opacity` = `0.5` | 403 FORBIDDEN | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `valid`, `position` = `invalid`, `opacity` = `0.5` | 400 VALIDATION_ERROR (invalid position) | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CREATOR in workspace; Material is an image marked retouched; Logo exists in Client Brand Collection | `materialId` = `valid`, `logoAssetId` = `null`, `position` = `bottom-right`, `opacity` = `0.5` | 400 VALIDATION_ERROR (logoAssetId required) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.18`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.7.11: Generate Video

> Note: This specification maps to official **FR 3.7.11 — Generate Video** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-7-11-generate-video/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.11` |
| **Function Name** | Generate Video |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `AiVideoService.generate()` (62 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AiVideoServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Submit asynchronous short-form AI video generation job (Veo) with style template and reference image and atomic credit handling |
| **Preconditions** | Can connect with server; Workspace has sufficient AI credits |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `a product showcase video`, `client_id` = `c1`, `mode` = `TEXT_TO_VIDEO` | 202 - jobId, status=PENDING, estimated_wait_seconds=120 | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `c1`, `mode` = `REFERENCE_TO_VIDEO`, `reference_image_base64` = `valid image` | 202 - jobId, status=PENDING | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `c1`, `aspect_ratio` = `9:16` | 202 - portrait video job created | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `c1`, `template_key` = `anime` | 202 - job created with style template | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `c1`, `task_id` = `task-1` | 202 - job linked to task | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Video job completed | `job_id` = `existing job completed` | 200 - status=COMPLETED, video_url present | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Video job processing | `job_id` = `existing job processing` | 200 - status=PROCESSING | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `10 chars exact`, `client_id` = `c1` | 202 - jobId (prompt min length 10) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `1000 chars`, `client_id` = `c1` | 202 - jobId (prompt max length 1000) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `128 chars` | 202 - jobId (client_id max 128) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `9 chars`, `client_id` = `c1` | 422 Validation error (prompt < 10) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `1001 chars`, `client_id` = `c1` | 422 Validation error (prompt > 1000) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `empty` | 422 Validation error (client_id required) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `c1`, `mode` = `REFERENCE_TO_VIDEO`, `reference_image_base64` = `null` | 422 reference_image_base64 is required for REFERENCE_TO_VIDEO | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Creator has enough AI credit; Veo API key configured | `prompt` = `valid prompt text`, `client_id` = `c1`, `aspect_ratio` = `1:1` | 422 Validation error (aspect_ratio) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Veo API key not configured | `prompt` = `valid prompt text`, `client_id` = `c1` | 503 VeoProviderError: GOOGLE_VEO_API_KEY or GEMINI_API_KEY is not configured | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Veo API key configured; Creator has no AI credit | `prompt` = `valid prompt text`, `client_id` = `c1` | 402 INSUFFICIENT_AI_CREDIT | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Job id does not exist in Redis | `job_id` = `unknown job id` | 404 Job {jobId} not found | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Video job failed or timed out | `job_id` = `existing job failed` | 200 - status=FAILED, error_code, error_message | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.11`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

# Test Specification — FR 3.7.4: Upload Brand Knowledge Document

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.4` |
| **Function Name** | Upload Brand Knowledge Document |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `rag.upload_document()` (118 LOC) |
| **Unit Test File** | `brandhub-ai-service/tests/unit/routers/test_rag_router.py` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Validate file extension, 10MB size limit, magic bytes, and PDF/DOCX/URL security before uploading to S3 and queueing RAG ingestion |
| **Preconditions** | Can connect with server; Valid internal API key and S3/ChromaDB available |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-001`, `upload_source` = `valid PDF file (Brand_Guide.pdf, 2MB)` | 200 OK - IngestionResponse(documentId, clientId, s3Key='rag/{clientId}/{docId}/Brand_Guide.pdf', status='processing') | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-001`, `upload_source` = `valid DOCX/TXT file (Tone.docx, 500KB)` | 200 OK - DOCX file validated by validate_magic_bytes and scan_docx_payload and uploaded to S3 | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-002`, `upload_source` = `valid PDF file (Brand_Guide.pdf, 2MB)` | 200 OK - TXT/HTML file uploaded to S3 and background chunking+embedding task scheduled | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-002`, `upload_source` = `valid DOCX/TXT file (Tone.docx, 500KB)` | 200 OK - External URL validated against SSRF, sanitized against XSS, and saved as webpage.txt | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; AWS S3 bucket and BackgroundTasks ingestion pipeline are available | `client_id` = `client-tenant-001`, `upload_source` = `valid HTTPS URL (https://brand.vn/about)` | 200 OK - PDF file scanned by scan_pdf_payload for embedded JS/Launch actions before S3 upload | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; AWS S3 bucket and BackgroundTasks ingestion pipeline are available | `client_id` = `client-tenant-002`, `upload_source` = `valid HTTPS URL (https://brand.vn/about)` | 200 OK - Background task extracts text, chunks via LangChain, embeds (384d), and upserts to ChromaDB | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-001`, `upload_source` = `valid PDF file (Brand_Guide.pdf, 2MB)` | 200 OK - Multi-tenant S3 key strictly prefixed with rag/{client_id}/{document_id}/ | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-001`, `upload_source` = `valid DOCX/TXT file (Tone.docx, 500KB)` | 200 OK - Unique UUID4 generated for documentId on each upload | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is at exact 10MB (10,485,760 bytes) boundary | `client_id` = `client-boundary-10mb`, `upload_source` = `exact 10MB PDF file boundary` | 200 OK - File at exact MAX_FILE_SIZE (10MB = 10,485,760 bytes) accepted at boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is at exact 10MB (10,485,760 bytes) boundary | `client_id` = `client-boundary-10mb`, `upload_source` = `exact 10MB PDF file boundary` | 200 OK - Uppercase extension (.PDF, .DOCX) normalized via ext.lower() and accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-tenant-001`, `upload_source` = `valid HTTPS URL (https://brand.vn/about)` | 200 OK - Sanitized URL content at 10MB boundary encoded as UTF-8 and saved to S3 | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; File exceeds 10MB, has unsupported extension, fails magic-byte/PDF/DOCX/SSRF scan, or both file & url missing | `client_id` = `client-invalid-upload`, `upload_source` = `valid PDF file (Brand_Guide.pdf, 2MB)` | 400 Bad Request - Must provide either file or URL (when both file and url are None) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; File exceeds 10MB, has unsupported extension, fails magic-byte/PDF/DOCX/SSRF scan, or both file & url missing | `client_id` = `client-s3-failure`, `upload_source` = `valid PDF file (Brand_Guide.pdf, 2MB)` | 400 Bad Request - Unsupported extension (only .pdf, .docx, .txt, .html, .htm allowed) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; S3 upload_file raises storage exception | `client_id` = `client-tenant-001`, `upload_source` = `valid PDF file (Brand_Guide.pdf, 2MB)` | 500 Internal Server Error - Failed to save document to S3 storage | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-invalid-upload`, `upload_source` = `oversized >10MB file or .exe extension` | 400 Bad Request - File or extracted webpage size exceeds the limit of 10MB | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Uploaded file is .pdf, .docx, .txt, .html, or .htm (<= 10MB) or valid external HTTPS URL | `client_id` = `client-s3-failure`, `upload_source` = `malicious PDF/DOCX payload or SSRF URL` | 400 Bad Request - Security scanner rejected spoofed magic bytes, PDF script, DOCX macro, or SSRF URL | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

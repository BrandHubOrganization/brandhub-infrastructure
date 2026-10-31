# Test Specification — FR 3.7.5: Delete Brand Knowledge Document

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.5` |
| **Function Name** | Delete Brand Knowledge Document |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `rag.delete_document()` (52 LOC) |
| **Unit Test File** | `brandhub-ai-service/tests/unit/routers/test_rag_router.py` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Delete raw brand guideline files from S3 under rag/{clientId}/{documentId}/ and purge matching vectors from ChromaDB |
| **Preconditions** | Can connect with server; Document exists in S3 or ChromaDB |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id='client-001'` | 200 OK - DocumentDeleteResponse(documentId, message='Document deleted successfully', status='deleted') | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id=None (scan under rag/)` | 200 OK - S3 objects under rag/{client_id}/{document_id}/ deleted via delete_objects_by_prefix | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (global scan)`, `client_id` = `client_id='client-001'` | 200 OK - Matching vectors deleted from ChromaDB via delete_document_vectors(document_id, client_id) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (global scan)`, `client_id` = `client_id=None (scan under rag/)` | 200 OK - Deleted S3 key list and deletedVectorCount returned accurately in response | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; client_id query parameter is provided (or omitted for cross-tenant prefix scan) | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id with multiple S3 files` | 200 OK - When client_id is None, scans 'rag/' for '/{document_id}/' and deletes matching prefixes | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; client_id query parameter is provided (or omitted for cross-tenant prefix scan) | `document_id` = `existing doc UUID (global scan)`, `client_id` = `client_id with multiple S3 files` | 200 OK - ChromaDB deletion uses $and filter on clientId and documentId when client_id is given | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id='client-001'` | 200 OK - Other documents belonging to the same client_id remain intact in S3 and ChromaDB | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id=None (scan under rag/)` | 200 OK - Deletion audit info logged with deleted S3 key count and vector count | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists only in ChromaDB (0 S3 keys) or only in S3 (0 ChromaDB vectors) | `document_id` = `doc UUID in Chroma only (0 S3 keys)`, `client_id` = `client_id with 1 vector chunk` | 200 OK - Document with 0 S3 files but >=1 ChromaDB vectors succeeds and returns deletedS3Keys=[] | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists only in ChromaDB (0 S3 keys) or only in S3 (0 ChromaDB vectors) | `document_id` = `doc UUID in Chroma only (0 S3 keys)`, `client_id` = `client_id with 1 vector chunk` | 200 OK - Document with >=1 S3 files but 0 ChromaDB vectors succeeds and returns deletedVectorCount=0 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id with multiple S3 files` | 200 OK - Document with 1 S3 file and 1 vector chunk deleted at minimum boundary | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Neither S3 objects nor ChromaDB vectors exist for document_id | `document_id` = `non-existent doc UUID`, `client_id` = `client_id='client-001'` | 404 Not Found - Document with ID '{document_id}' not found (0 S3 keys and 0 vectors) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Neither S3 objects nor ChromaDB vectors exist for document_id | `document_id` = `already deleted doc UUID`, `client_id` = `client_id='client-001'` | 404 Not Found - Repeat delete on already deleted document_id returns 404 | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Invalid or missing X-Internal-Key header | `document_id` = `existing doc UUID (S3 + Chroma)`, `client_id` = `client_id='client-001'` | 403/401 Forbidden - Missing or invalid X-Internal-Key header | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `non-existent doc UUID`, `client_id` = `client_id with no matching doc` | 404 Not Found - Document exists under another client_id but not the requested client_id | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Valid X-Internal-Key header verified by verify_internal_key dependency; Document exists in S3 under rag/{client_id}/{document_id}/ and/or in ChromaDB | `document_id` = `already deleted doc UUID`, `client_id` = `unauthenticated request` | 422 Unprocessable Entity - Missing required path parameter | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

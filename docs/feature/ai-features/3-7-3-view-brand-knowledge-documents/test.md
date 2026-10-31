# Test Specification — FR 3.7.3: View Brand Knowledge Documents

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.3` |
| **Function Name** | View Brand Knowledge Documents |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `VectorStoreService.query_similar_chunks()` (51 LOC) |
| **Unit Test File** | `brandhub-ai-service/tests/unit/services/test_rag_ingestion.py` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Query similar brand guideline vector chunks in ChromaDB using HNSW ANN search with mandatory multi-tenant clientId filtering |
| **Preconditions** | Can connect with server; ChromaDB collection is initialized |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=5, where_filter={'clientId': 'c1'}` | List[Dict] - Returns top_k matching chunks with id, document, metadata, and distance | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=3, where_filter=None` | List[Dict] - collection.query called with query_embeddings=[query_embedding] and n_results=top_k | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `brand tone 384d embedding vector`, `query_params` = `top_k=5, where_filter={'clientId': 'c1'}` | List[Dict] - where_filter passed in query_kwargs['where'] for multi-tenant isolation | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `brand tone 384d embedding vector`, `query_params` = `top_k=3, where_filter=None` | List[Dict] - Omitting where_filter queries collection without 'where' key | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; where_filter scopes query to a specific tenant clientId | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=10, where_filter={'$and': [{'clientId': 'c1'}, {'fileType': 'pdf'}]}` | List[Dict] - Compound $and metadata filter scopes results to clientId and fileType | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; where_filter scopes query to a specific tenant clientId | `query_embedding` = `brand tone 384d embedding vector`, `query_params` = `top_k=10, where_filter={'$and': [{'clientId': 'c1'}, {'fileType': 'pdf'}]}` | List[Dict] - Result dicts normalize missing document/metadata/distance fields to safe defaults | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=5, where_filter={'clientId': 'c1'}` | List[Dict] - get_or_create_collection configures HNSW space, construction_ef, and M from settings | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=3, where_filter=None` | List[Dict] - Multiple chunks from same document ordered by ascending distance | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection has 0 matching vectors or ChromaDB client is unavailable (None) | `query_embedding` = `normalized unit 384d vector`, `query_params` = `top_k=1 (minimum boundary)` | List[Dict] - Boundary top_k=1 returns single nearest neighbor chunk | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection has 0 matching vectors or ChromaDB client is unavailable (None) | `query_embedding` = `normalized unit 384d vector`, `query_params` = `top_k=1 (minimum boundary)` | List[Dict] - Empty ChromaDB query result (ids=[[]]) returns empty list [] | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=10, where_filter={'$and': [{'clientId': 'c1'}, {'fileType': 'pdf'}]}` | List[Dict] - Missing distances array in ChromaDB response defaults distance to 0.0 | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; ChromaDB collection.query raises an unexpected runtime exception | `query_embedding` = `embedding when ChromaDB unavailable`, `query_params` = `top_k=5, where_filter={'clientId': 'c1'}` | Graceful [] fallback - Returns [] and logs warning when get_chroma_client() is None | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; ChromaDB collection.query raises an unexpected runtime exception | `query_embedding` = `embedding triggering query error`, `query_params` = `top_k=5, where_filter={'clientId': 'c1'}` | Graceful [] fallback - Returns [] and logs error when get_or_create_collection() raises Exception | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller passes custom collection name or empty result set | `query_embedding` = `valid 384d float embedding vector`, `query_params` = `top_k=5, where_filter={'clientId': 'c1'}` | Graceful [] fallback - Returns [] and logs error when collection.query() raises Exception | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `embedding when ChromaDB unavailable`, `query_params` = `empty collection (0 matches)` | ValueError - upsert_trend_chunks raises ValueError when postId is missing | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; ChromaDB client is connected and collection 'brandhub_rag' is initialized with HNSW metadata; Collection contains 384d vector chunks tagged with clientId, documentId, fileName, fileType | `query_embedding` = `embedding triggering query error`, `query_params` = `ChromaDB client is None / query exception` | Graceful 0 fallback - delete_document_vectors returns 0 when collection is unavailable | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

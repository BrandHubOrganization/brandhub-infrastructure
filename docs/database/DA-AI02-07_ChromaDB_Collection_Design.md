# DA-AI02-07 - ChromaDB Collection Design

**Task:** Document ChromaDB collection design: collection naming per clientId, metadata schema, and query patterns.  
**Owner:** Tuan (AI) | **Priority:** High  
**Blocked by:** DA-AI02-01  
**Blocks:** DA-AI03-02, DA-AI03-03, DA-AI03-04

---

## 1. Purpose

This document is the implementation contract for storing and querying BrandHub RAG chunks in ChromaDB.

ChromaDB is only the vector store for semantic search. It is not the primary document registry. Raw document content and document lifecycle metadata remain in MongoDB `knowledge_documents`; ChromaDB stores chunk text, embeddings, chunk IDs, and searchable metadata used by `ai-service`.

> Compatibility note: older database strategy notes mention workspace-level collections such as `brand_embeddings_{workspaceId}`. For DA-AI02-07 and the downstream RAG pipeline, the accepted convention is client-level collection isolation with `client_{clientId}`.

---

## 2. Collection Naming Convention

### 2.1 Pattern

```text
client_{clientId}
```

Example:

```text
client_9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11
```

### 2.2 Rationale

Brand knowledge is scoped to a client. A collection-per-client design gives the RAG pipeline a clear isolation boundary:

- prevents accidental context leakage between clients;
- keeps semantic search focused on one brand/client at a time;
- matches the RAG request shape, where `clientId` is required;
- makes delete operations safer because each document is deleted inside its owning client collection.

`workspaceId` remains important in MongoDB and authorization checks, but ChromaDB collection selection is based on `clientId`.

---

## 3. Stored Chunk Contract

Each chunk stored in ChromaDB must use a deterministic ID:

```text
{documentId}:{chunkIndex}
```

Example:

```text
doc_123:0
doc_123:1
doc_123:2
```

This makes re-indexing idempotent and makes document deletion easier because all chunk IDs can be derived or fetched by `documentId`.

### 3.1 Metadata Schema

Every ChromaDB chunk must include exactly these required metadata fields:

| Field | Type | Example | Purpose |
|---|---|---|---|
| `documentId` | `str` | `doc_123` | Links the chunk back to MongoDB `knowledge_documents` |
| `clientId` | `str` | `9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11` | Required tenant/client filter for RAG search |
| `chunkIndex` | `int` | `0` | Preserves chunk order inside a document |
| `source` | `str` | `brand-guidelines.pdf` | Human-readable source file name or URL |
| `uploadedAt` | `str` | `2026-07-01T08:30:00Z` | ISO8601 UTC timestamp for traceability |

Canonical example:

```json
{
  "documentId": "doc_123",
  "clientId": "9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11",
  "chunkIndex": 0,
  "source": "brand-guidelines.pdf",
  "uploadedAt": "2026-07-01T08:30:00Z"
}
```

---

## 4. Write Pattern

When the embedding pipeline stores chunks:

1. Validate the request has `clientId` and `documentId`.
2. Get or create the ChromaDB collection named `client_{clientId}`.
3. Split the document text into chunks in DA-AI03-02.
4. Embed each chunk in DA-AI03-03.
5. Store each chunk with:
   - ID: `{documentId}:{chunkIndex}`;
   - document text: chunk text;
   - embedding: generated vector;
   - metadata: schema from section 3.1.
6. Store the generated chunk IDs back in MongoDB `knowledge_documents.chunkIds`.

ChromaDB must not store the full original document as the source of truth. MongoDB remains the source for document listing, title, upload status, file location, and deletion state.

---

## 5. Query Patterns

### 5.1 Top-K Semantic Search for One Client

Use the client collection and always include a `clientId` metadata filter.

Default `topK` is `5`. Callers may override it when the API explicitly accepts `topK`.

```python
collection_name = f"client_{client_id}"
collection = chroma_client.get_collection(name=collection_name)

results = collection.query(
    query_texts=[query],
    n_results=top_k or 5,
    where={"clientId": {"$eq": client_id}},
)
```

Exact ChromaDB metadata filter syntax:

```python
where={"clientId": {"$eq": client_id}}
```

Expected use cases:

- `/api/v1/ai/rag/query` retrieves top-K chunks for a client.
- DA-AI03-04 semantic search uses the returned chunks as input for the RAG context builder.
- LLM generation only receives chunks returned from this client-scoped search.

### 5.2 Optional Document-Scoped Search

When debugging or rebuilding context for one document, combine filters with `$and`:

```python
results = collection.query(
    query_texts=[query],
    n_results=5,
    where={
        "$and": [
            {"clientId": {"$eq": client_id}},
            {"documentId": {"$eq": document_id}},
        ]
    },
)
```

Use this only when the caller intentionally scopes search to one document. Normal RAG search should search all indexed documents for the client.

---

## 6. Delete Pattern

Do not delete blindly by collection. Delete chunks for one document by fetching IDs first, then deleting those IDs.

```python
collection_name = f"client_{client_id}"
collection = chroma_client.get_collection(name=collection_name)

matches = collection.get(
    where={"documentId": {"$eq": document_id}},
    include=[],
)

chunk_ids = matches.get("ids", [])

if chunk_ids:
    collection.delete(ids=chunk_ids)
```

MongoDB and S3 cleanup are handled by the document deletion endpoint in later RAG tasks. This document only defines the ChromaDB side:

- find chunk IDs by `documentId`;
- delete those IDs from the `client_{clientId}` collection;
- do not remove unrelated chunks from the same client collection.

---

## 7. ChromaDB Limitations

ChromaDB does not support cross-collection queries.

Because BrandHub uses one collection per client:

- searching across multiple clients requires one query per client collection;
- listing all documents for a client should use MongoDB `knowledge_documents`, not ChromaDB query results;
- listing all documents across all clients requires a MongoDB/API-level list operation, not one ChromaDB query;
- collection-level operations must handle missing collections gracefully when a client has no indexed documents yet.

ChromaDB should not be used as a primary document registry. It is a retrieval index only.

---

## 8. Downstream Contract

DA-AI02-07 unblocks the following tasks:

| Task | Dependency on this document |
|---|---|
| DA-AI03-02 | Chunking must output ordered chunks that can map to `chunkIndex` |
| DA-AI03-03 | Embedding pipeline must store chunks in `client_{clientId}` with the required metadata schema |
| DA-AI03-04 | Semantic search must use top-K retrieval filtered by `clientId` with exact ChromaDB `where` syntax |

---

## 9. Acceptance Criteria

- [x] Collection naming convention is documented as `client_{clientId}`.
- [x] Collection-per-client isolation rationale is documented.
- [x] Metadata schema includes `documentId`, `clientId`, `chunkIndex`, `source`, and `uploadedAt`.
- [x] Top-K semantic search pattern is documented.
- [x] Exact ChromaDB filter syntax is documented: `{"clientId": {"$eq": client_id}}`.
- [x] Delete-by-document pattern fetches chunk IDs first, then deletes by IDs.
- [x] Cross-collection query limitation is documented.
- [x] MongoDB `knowledge_documents` remains the primary document registry.
- [x] Blocks section names DA-AI03-02, DA-AI03-03, and DA-AI03-04.

> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.3 — View Brand Knowledge Documents

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.3` |
| **Use Case ID** | `UC-090` |
| **Feature** | View Brand Knowledge Documents |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager`, `Creator`, `Client` |
| **Business Rules** | `BR-20`, `BR-46` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Enable `Owner`, `Manager`, `Creator`, and `Client` members of a Workspace to view indexed Brand Guideline documents and execute live semantic similarity previews against the Workspace-isolated ChromaDB vector store (`brand_docs_{workspace_id}`, `BR-20`, `BR-46`). This provides full transparency into which brand tone rules, product specifications, and compliance policies ground AI Caption and Image/Video generation.

## 2. User Story

As an `Owner`, `Manager`, `Creator`, or `Client` in a Workspace, I want to inspect all uploaded Brand Knowledge documents, their vectorization status (`PENDING`, `INDEXED`, `FAILED`), chunk counts, and semantic retrieval relevance scores so that I can verify AI grounding accuracy before generating campaign assets.

## 3. Acceptance Criteria

1. **Workspace Tenant Isolation (`BR-20`, `BR-46`):** Only authenticated members (`Owner`, `Manager`, `Creator`, `Client`) of `{workspaceId}` can list documents or run semantic preview queries; every ChromaDB lookup binds server-verified `workspace_id` collection scope (`brand_docs_{workspace_id}`) and never trusts client-supplied collection names (`MSG07`).
2. **Document Inventory & Indexing Metadata:** Each listed document displays filename, MIME type (`PDF`, `DOCX`, `TXT`, `MD`), file size, uploader display name, `createdAt`, indexing status (`PENDING`, `INDEXED`, `FAILED`), and embedded chunk count (`chunkCount`).
3. **Semantic Retrieval Preview (`SemanticSearchBar.tsx`):** Users can enter a test query (e.g., *"chính sách bảo hành sản phẩm"*) to inspect top-`k` (`k <= 5`) matching chunks with cosine similarity score (`>= 0.70` grounding threshold indicator) without consuming AI Credits.
4. **Role-Gated Mutation Affordances:** `Creator` sees read-only document list and semantic search; Upload (FR 3.7.4) and Delete (FR 3.7.5) buttons render only for `Owner`, `Manager`, and `Client`.
5. **Internationalization (`vi.json` + `en.json`):** All table headers, indexing status badges, semantic search placeholders, and empty states use synchronized keys under `aiStudio.knowledgeBase.*` in `vi.json` and `en.json`.
6. **Light & Dark Mode Compliance:** `pages/ai-studio/knowledge-base/index.tsx`, `DocumentList.tsx`, and `SemanticSearchBar.tsx` use semantic surface/border/badge tokens supporting both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Route:** `/workspaces/:workspaceId/ai-studio/knowledge-base` (`pages/ai-studio/knowledge-base/index.tsx`, `DocumentList.tsx`, `SemanticSearchBar.tsx`).
- **UI States:**
  - **Loading:** Skeleton rows for document list + disabled search input during fetch.
  - **Empty:** Guided onboarding card explaining how Brand RAG prevents LLM hallucination, with CTA to FR 3.7.4 for `Owner`/`Manager`/`Client`.
  - **Indexing In Progress:** Live status pill (`PENDING`) polling until chunk embedding completes (`INDEXED`) or surfaces failure reason (`FAILED`).
  - **Error:** `AiStudioErrorBanner.tsx` displaying localized message mapped from `ErrorCode` (`MSG03`, `MSG07`).

## 5. API Contract

| Method & Endpoint | Caller Role | Handler | Notes |
| :--- | :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/ai/knowledge/documents` | `Owner, Manager, Creator, Client` | Business RAG proxy -> `ai-service` `rag.py` | Paginated list of workspace brand documents + indexing status |
| `POST /api/v1/workspaces/{workspaceId}/ai/knowledge/query` | `Owner, Manager, Creator, Client` | `VectorStoreService.query_similar_chunks()` | Zero-credit semantic similarity preview (`topK <= 5`) |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): User is not an active member of `{workspaceId}`.
- `INVALID_SEARCH_QUERY` (`400`, `MSG02`): Blank semantic query or query exceeding `500` characters.
- `VECTOR_STORE_UNAVAILABLE` (`503`, `MSG03`): ChromaDB connection failure; metadata list from PostgreSQL/MongoDB still renders with a warning banner that semantic preview is temporarily unavailable.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.4 — Upload Brand Knowledge Document](../3-7-4-upload-brand-knowledge-document/spec.md) · [FR 3.7.5 — Delete Brand Knowledge Document](../3-7-5-delete-brand-knowledge-document/spec.md) · [FR 3.7.6 — Generate Caption](../3-7-6-generate-caption/spec.md)
- **Consolidated Extension Module:** [`rag-caption-moderation-and-humanizer`](../../../modules/05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Strict `brand_docs_{workspace_id}` collection isolation verified in unit/integration tests, semantic preview UI wired with `vi`/`en` i18n and Light/Dark tokens, all test cases in [test.md](./test.md) passing.
- **Out of Scope:** Editing raw text inside embedded PDF/DOCX chunks (users re-upload updated documents via FR 3.7.4).

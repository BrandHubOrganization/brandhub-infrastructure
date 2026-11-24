> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.4 — Upload Brand Knowledge Document

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.4` |
| **Use Case ID** | `UC-091` |
| **Feature** | Upload Brand Knowledge Document |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager`, `Client` |
| **Business Rules** | `BR-20`, `BR-46`, `BR-47` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07`, `MSG14` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Allow `Owner`, `Manager`, and `Client` actors in a Workspace to upload official Brand Guidelines, product catalogs, and tone-of-voice playbooks (`PDF`, `DOCX`, `TXT`, `MD`) into the Workspace Brand Knowledge Base (`BR-46`, `BR-47`). Uploaded files are virus/MIME-validated, stored in S3 under the workspace namespace, parsed, chunked with overlap, embedded, and indexed into ChromaDB (`brand_docs_{workspace_id}`) so downstream AI generation stays strictly grounded in factual brand data.

## 2. User Story

As an `Owner`, `Manager`, or `Client`, I want to upload Brand Knowledge documents into my Workspace so that AI-generated captions, product descriptions, and creative prompts accurately reflect official product specs, brand voice, and mandatory disclaimers without hallucination.

## 3. Acceptance Criteria

1. **Role & Workspace Scope (`BR-20`):** Only `Owner`, `Manager`, and `Client` members of `{workspaceId}` may upload Brand Knowledge documents; `Creator` and non-members receive `403 FORBIDDEN` (`MSG07`).
2. **File Format, Magic-Byte & Size Validation (`BR-47`):** Accepts `.pdf`, `.docx`, `.txt`, and `.md` up to `20 MB` per file (and within Agency plan storage/document entitlements). Executables, macro-enabled `.docm`, password-encrypted PDFs, empty (`0 byte`) files, or image-only scanned PDFs with zero extractable text are rejected deterministically (`MSG02`, `MSG14`).
3. **Chunking & Vector Ingestion Pipeline:** `brandhub-ai-service` (`app/api/v1/endpoints/rag.py`, `app/utils/extractor.py`, `VectorStoreService`) extracts UTF-8 NFC normalized text, splits into `500–800` token semantic chunks (`100` token overlap), computes embeddings, and upserts vectors tagged with `{workspace_id, document_id, filename, chunk_index}` into ChromaDB collection `brand_docs_{workspace_id}`.
4. **Atomic Rollback on Failure:** If text extraction or ChromaDB upsert fails, partial chunks for `document_id` are purged and document status is marked `FAILED` with actionable error code (`MSG03`) rather than leaving ghost vectors.
5. **Internationalization (`vi.json` + `en.json`):** Upload dropzone, file size/type hints, progress bar, and validation error messages use key-parallel `aiStudio.knowledgeBase.upload.*` keys in `vi.json` and `en.json`.
6. **Light & Dark Mode Compliance:** Dropzone hover/drag states, file queue cards, and progress indicators adhere to semantic Light/Dark theme tokens.

## 4. UI / UX & Screen States

- **Web Surface:** `/workspaces/:workspaceId/ai-studio/knowledge-base` upload dialog & dropzone (`pages/ai-studio/knowledge-base/index.tsx`).
- **UI States:**
  - **Idle / Drag-Over:** Clear MIME & `20 MB` limit hint; accessible keyboard file trigger.
  - **Uploading & Embedding:** Determinate upload progress followed by `PENDING -> INDEXED` vectorization badge; upload button disabled against double-submit.
  - **Success:** Toast notification showing extracted `chunkCount` + automatic `TanStack Query` invalidation of FR 3.7.3 document list.
  - **Error:** Inline per-file rejection reason (oversize, unsupported format, scanned PDF with no text).

## 5. API Contract

| Method & Endpoint | Auth | Request | Response |
| :--- | :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/ai/knowledge/documents` | Bearer (`Owner, Manager, Client`) | `multipart/form-data` (`file`, optional `category`, `title`) | `201 ApiResponse<BrandDocumentResponse>` |
| `POST /api/v1/ai/rag/documents` | `X-Internal-Api-Key` (`business -> ai`) | `RagDocumentIngestRequest` (S3 key / bytes + `workspace_id` + `document_id`) | `200 RagIngestResult` (`chunk_count`, `collection_name`) |

## 6. Error Handling & Edge Cases

- `PAYLOAD_TOO_LARGE` (`413`, `MSG14`): File exceeds `20 MB` limit or Agency storage quota (`agency_storage_usage`).
- `UNSUPPORTED_DOCUMENT_FORMAT` (`415` / `400`, `MSG02`): Disallowed extension or mismatched magic bytes.
- `EMPTY_EXTRACTABLE_TEXT` (`422`, `MSG02`): Scanned image PDF without OCR text layer; returns clear localized instruction to upload searchable PDF/DOCX/TXT.
- **Duplicate Filename in Same Workspace:** Preserves distinct `documentId` or prompts version replacement without corrupting existing chunks.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.3 — View Brand Knowledge Documents](../3-7-3-view-brand-knowledge-documents/spec.md) · [FR 3.7.5 — Delete Brand Knowledge Document](../3-7-5-delete-brand-knowledge-document/spec.md) · [FR 3.7.6 — Generate Caption](../3-7-6-generate-caption/spec.md)
- **Consolidated Extension Module:** [`rag-caption-moderation-and-humanizer`](../../../modules/05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Multipart validation, S3 persistence, text extraction (`PDF/DOCX/TXT/MD`), ChromaDB `brand_docs_{workspace_id}` indexing, rollback cleanup, `vi`/`en` i18n, and Light/Dark UI verified against [test.md](./test.md).
- **Out of Scope:** Optical Character Recognition (OCR) on handwritten/scanned image PDFs; copyright/plagiarism scanning (explicitly de-scoped in SRS).

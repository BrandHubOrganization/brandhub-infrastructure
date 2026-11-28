> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.5 — Delete Brand Knowledge Document

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.5` |
| **Use Case ID** | `UC-092` |
| **Feature** | Delete Brand Knowledge Document |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager`, `Client` |
| **Business Rules** | `BR-20`, `BR-46` |
| **Message Codes** | `MSG01`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Enable authorized `Owner`, `Manager`, and `Client` actors to permanently remove obsolete or superseded Brand Knowledge documents from a Workspace (`BR-20`, `BR-46`), atomically purging all embedded vector chunks (`where={"document_id": documentId}`) from ChromaDB (`brand_docs_{workspace_id}`), deleting the backing S3 object, releasing storage quota, and ensuring future AI prompts never cite outdated pricing or policies.

## 2. User Story

As an `Owner`, `Manager`, or `Client`, I want to delete an outdated Brand Guideline or product sheet from my Workspace Knowledge Base so that the AI Caption and Creative Studio immediately stops referencing retired brand claims while preserving previously generated historical Task content snapshots.

## 3. Acceptance Criteria

1. **Authorization & Cross-Tenant Guard (`BR-20`):** Only `Owner`, `Manager`, and `Client` members of `{workspaceId}` may invoke `DELETE /api/v1/workspaces/{workspaceId}/ai/knowledge/documents/{documentId}`. `Creator` and users from other Workspaces receive `403 FORBIDDEN` (`MSG07`), and `documentId` belonging to a different Workspace returns `404 NOT_FOUND` (`MSG01`).
2. **Complete Vector & Storage Purge (`BR-46`):** Deletion invokes `brandhub-ai-service` `DELETE /api/v1/ai/rag/documents/{documentId}` scoped to `brand_docs_{workspace_id}` to remove 100% of associated chunks, deletes the raw file in S3, and removes/archives metadata + updates `agency_storage_usage`.
3. **Historical Snapshot Preservation:** Existing `ai_caption_generations` and `task_content_snapshots` that previously cited the deleted document remain intact for auditability; only new RAG retrievals exclude the purged vectors.
4. **Destructive Confirmation UX:** Web UI presents a confirmation dialog displaying the document name and chunk count before executing `DELETE`.
5. **Internationalization (`vi.json` + `en.json`):** Confirmation dialog title, warning copy, cancel/confirm buttons, and toast notifications use synchronized `aiStudio.knowledgeBase.delete.*` keys in `vi.json` and `en.json`.
6. **Light & Dark Mode Compliance:** Destructive confirmation modal and danger button tokens render with proper contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surface:** `DocumentList.tsx` row action menu + confirmation dialog on `/workspaces/:workspaceId/ai-studio/knowledge-base`.
- **UI States:**
  - **Confirming:** Modal warns that AI generations will no longer ground on this document; Focus trap + `Escape` support.
  - **Deleting:** Row spinner + disabled confirm button to prevent duplicate `DELETE` requests.
  - **Success:** Document disappears from list, storage usage meter updates, localized success toast shown.
  - **Error:** If ChromaDB purge fails (`MSG03`), document remains visible in retryable state so no silent zombie vectors remain in RAG.

## 5. API Contract

| Method & Endpoint | Auth | Handler | Response |
| :--- | :--- | :--- | :--- |
| `DELETE /api/v1/workspaces/{workspaceId}/ai/knowledge/documents/{documentId}` | Bearer (`Owner, Manager, Client`) | Business RAG service -> `ai-service` `rag.py` | `200 ApiResponse<Void>` |
| `DELETE /api/v1/ai/rag/documents/{document_id}?workspace_id=...` | `X-Internal-Api-Key` | `VectorStoreService.delete_document_chunks()` | `200 {"deleted_chunks": N}` |

## 6. Error Handling & Edge Cases

- `DOCUMENT_NOT_FOUND` (`404`, `MSG01`): Document already deleted or belongs to another Workspace.
- `FORBIDDEN` (`403`, `MSG07`): `Creator` attempts deletion or caller lacks Workspace membership.
- `VECTOR_PURGE_FAILED` (`503`, `MSG03`): ChromaDB unreachable; Business transaction aborts metadata deletion so operator/user can retry cleanly without leaving unreferenced vectors in ChromaDB.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.3 — View Brand Knowledge Documents](../3-7-3-view-brand-knowledge-documents/spec.md) · [FR 3.7.4 — Upload Brand Knowledge Document](../3-7-4-upload-brand-knowledge-document/spec.md) · [FR 3.7.6 — Generate Caption](../3-7-6-generate-caption/spec.md)
- **Consolidated Extension Module:** [`rag-caption-moderation-and-humanizer`](../../../modules/05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified zero residual chunks in ChromaDB after delete, S3 object cleanup, cross-workspace tamper rejection, `vi`/`en` i18n parity, and Light/Dark modal verification per [test.md](./test.md).
- **Out of Scope:** Soft-delete trash bin for RAG embeddings (Brand Knowledge deletions immediately stop grounding).

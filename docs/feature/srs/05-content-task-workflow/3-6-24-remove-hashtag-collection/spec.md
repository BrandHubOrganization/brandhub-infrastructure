> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.24 — Remove Hashtag Collection

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.24` |
| **Use Case ID** | `UC-076` |
| **Feature** | Remove Hashtag Collection |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-39` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xóa mềm bộ sưu tập Hashtag khỏi danh sách hoạt động của Workspace (Remove Hashtag Collection — /workspaces/:id/hashtags/:collectionId). Áp dụng cơ chế xóa mềm (Soft Delete): ẩn bộ sưu tập khỏi danh sách chọn mới nhưng giữ nguyên toàn bộ các hashtag đã được chèn vào các bài viết trước đó (BR-39).

**Consolidated Implementation Scope:** Soft-deletes a Workspace hashtag (`deleted_at = now()`, `BR-39`) for authorized `Owner, Manager, Creator` actors so it no longer appears in collection pickers or triggers uniqueness collisions when re-added later, while keeping historical Post captions intact.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **Remove Hashtag Collection** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-39` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `DELETE /api/v1/workspaces/{workspaceId}/hashtags/{hashtagId}`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-39`):** `HashtagService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on PostgreSQL `hashtags` (`deleted_at = now()`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`403 FORBIDDEN`, `404 HASHTAG_NOT_FOUND` (`BR-39`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`hashtags.remove.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/hashtag-groups/components/RemoveHashtagDialog.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts`) and Mobile (`src/services/hashtagService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/hashtag-groups/components/RemoveHashtagDialog.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/services/hashtagService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `DELETE /api/v1/workspaces/{workspaceId}/hashtags/{hashtagId}`
- **Controllers (`brandhub-business-service`):** `HashtagController.remove()`
- **Services:** `HashtagService`
- **Repositories / Stores:** HashtagRepository (PostgreSQL `hashtags`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `403 FORBIDDEN`, `404 HASHTAG_NOT_FOUND` (`BR-39`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

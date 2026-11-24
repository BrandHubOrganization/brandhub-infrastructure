> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.20 — Apply Hashtag

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.20` |
| **Use Case ID** | `UC-072` |
| **Feature** | Apply Hashtag |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-39` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Chọn và chèn nhanh một hoặc nhiều thẻ Hashtag từ bộ sưu tập của Workspace vào nội dung bài đăng đang soạn thảo (Apply Hashtag — /workspaces/:id/tasks/:taskId/editor). Tự động chuẩn hóa định dạng tiền tố '#', loại bỏ các hashtag bị trùng lặp trong cùng bài viết và kiểm tra giới hạn số lượng hashtag theo quy định của từng mạng xã hội (BR-39).

**Consolidated Implementation Scope:** Folds in `api-hashtag-suggestions`, `contextual-hashtag-suggestions`, and `workspace-context-hashtag-suggestions`: lets `Owner, Manager, Creator` pick individual or grouped hashtags from the Workspace Hashtag Collection or generate contextual AI hashtag suggestions (`sourceWorkspace` / `sourceTrend` / `sourceGenerated`) directly into a Post draft with automatic `#` normalization, case-insensitive deduplication, and per-platform count warnings (`BR-39`) without mutating the saved Workspace collection.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **Apply Hashtag** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-39` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/hashtags · POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/post · PATCH /api/v1/workspaces/{workspaceId}/posts/{postId}`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-39`):** `HashtagService, HashtagSuggestionContext, TaskPostService, PostService` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on PostgreSQL `hashtags`; MongoDB `posts` (`hashtags` array) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR` (platform hashtag count/format limit), `403 FORBIDDEN`, `409 TASK_REVIEW_CONTENT_LOCKED` (`BR-39`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`editor.hashtagInput.* / hashtags.apply.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/hashtag-groups/components/ApplyHashtagToPostButton.tsx`, `src/pages/editor/components/HashtagTagList.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts`) and Mobile (`src/screens/content-writing/ContentWritingEditorScreen.tsx`, `src/services/hashtagService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/hashtag-groups/components/ApplyHashtagToPostButton.tsx`, `src/pages/editor/components/HashtagTagList.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content-writing/ContentWritingEditorScreen.tsx`, `src/services/hashtagService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/hashtags · POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/post · PATCH /api/v1/workspaces/{workspaceId}/posts/{postId}`
- **Controllers (`brandhub-business-service`):** `HashtagController.list(), TaskPostController.save(), PostController.updateDraft(), AiCaptionController`
- **Services:** `HashtagService, HashtagSuggestionContext, TaskPostService, PostService`
- **Repositories / Stores:** HashtagRepository (PostgreSQL `hashtags`), PostMongoRepository (MongoDB `posts`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR` (platform hashtag count/format limit), `403 FORBIDDEN`, `409 TASK_REVIEW_CONTENT_LOCKED` (`BR-39`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

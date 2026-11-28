> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.33 — Check Compliance Content

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.33` |
| **Use Case ID** | `UC-085` |
| **Feature** | Check Compliance Content |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-42` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Kiểm tra mức độ tuân thủ tiêu chuẩn cộng đồng của nội dung bài đăng trước khi xuất bản (Check Compliance Content — /workspaces/:id/tasks/:taskId/compliance). Gọi API kiểm duyệt an toàn nội dung để rà soát ngôn từ bạo lực, nhạy cảm, từ khóa bị cấm trên các nền tảng mạng xã hội và hình ảnh dung tục; trả về bảng phân tích chi tiết các đoạn vi phạm kèm gợi ý chỉnh sửa giúp Creator khắc phục ngay để bài viết không bị bóp tương tác hoặc từ chối đăng (BR-42).

**Consolidated Implementation Scope:** Evaluates draft captions and post text prior to submission/publishing (`BR-42`) for community safety violations, profanity, violence, deceptive claims, and banned social-platform keywords across Facebook, Instagram, TikTok, and Threads, returning structured `issues` (`code`, `message`, offending `excerpt`) and severity (`PASSED`, `WARNING`, `BLOCKED`) without consuming extra AI generation credits.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **Check Compliance Content** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-42` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `POST /api/v1/workspaces/{workspaceId}/ai/captions/moderate`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-42`):** `AiCaptionService.moderate(), CaptionComplianceCheck` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on Stateless pre-publish moderation returning `CaptionComplianceCheck.Result` (`PASSED | WARNING | BLOCKED | NOT_CHECKED`, `issues[{code, message, excerpt}]`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR` (blank/oversized text), `403 FORBIDDEN`, `503 AI_PROVIDER_UNAVAILABLE` (`BR-42`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`editor.compliance.* / moderation.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/services/textModerationService.ts`, `src/pages/editor/index.tsx`, `src/pages/task-editor/index.tsx`) and Mobile (`src/screens/content-writing/ContentWritingEditorScreen.tsx`, `src/utils/editorModeration.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/services/textModerationService.ts`, `src/pages/editor/index.tsx`, `src/pages/task-editor/index.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content-writing/ContentWritingEditorScreen.tsx`, `src/utils/editorModeration.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `POST /api/v1/workspaces/{workspaceId}/ai/captions/moderate`
- **Controllers (`brandhub-business-service`):** `AiCaptionController.moderate()`
- **Services:** `AiCaptionService.moderate(), CaptionComplianceCheck`
- **Repositories / Stores:** WorkspaceAccessService (stateless real-time AI/rule compliance evaluation)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR` (blank/oversized text), `403 FORBIDDEN`, `503 AI_PROVIDER_UNAVAILABLE` (`BR-42`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

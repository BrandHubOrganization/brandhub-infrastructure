> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.25 — Create Survey

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.25` |
| **Use Case ID** | `UC-077` |
| **Feature** | Create Survey |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-40` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Tạo biểu mẫu khảo sát tương tác phục vụ sự kiện, workshop hoặc thu thập ý kiến khách hàng trong chiến dịch (Create Survey — /workspaces/:id/surveys/new). Hỗ trợ thiết kế tiêu đề khảo sát, mô tả, thời hạn đóng biểu mẫu và danh sách câu hỏi đa dạng (Trắc nghiệm 1 lựa chọn, Nhiều lựa chọn, Thang điểm đánh giá, Câu trả lời văn bản tự do) kèm đường dẫn công khai để chia sẻ (BR-40).

**Consolidated Implementation Scope:** Implemented end-to-end in `SurveyServiceImpl` (`BR-40`): `Owner, Manager, Creator` builds and publishes multi-question forms (`TEXT`, `SINGLE_CHOICE`, `MULTIPLE_CHOICE`, `RATING` 1–5, file/attachment answers) on `SURVEY` or `WORKSHOP` tasks (enforcing `SectionPolicy` on `SURVEY.FORM` / `WORKSHOP.REGISTRATION`), automatically provisions a linked Google Spreadsheet via `GoogleSheetsService`, generates a public shareable link (`/public/surveys/{token}`), and appends public `Guest` submissions to both MongoDB `survey_responses` and Google Sheets.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator`), I want to execute **Create Survey** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-40` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey · GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey · GET /api/v1/public/surveys/{token} · POST /api/v1/public/surveys/{token}/submit`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-40`):** `SurveyServiceImpl, GoogleSheetsService, SectionService (`SURVEY.FORM` / `WORKSHOP.REGISTRATION`)` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `surveys` (`SurveyDocument`: `taskId`, `workspaceId`, `publicToken`, `questions`, `spreadsheetId`, `spreadsheetUrl`, `published`), `survey_responses` (`SurveyResponseDocument`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 VALIDATION_ERROR` (answer length / rating bounds `1..5`), `403 FORBIDDEN` (section editor policy), `404 SURVEY_NOT_FOUND` / `TASK_NOT_FOUND` (`BR-40`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`survey.editor.* / survey.public.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/survey-editor/index.tsx`, `src/pages/public-survey/index.tsx`, `src/pages/public-survey/components/{PublicSurveyHeader,PublicQuestionCard,PublicSurveySuccess}.tsx`, `src/services/surveyService.ts`) and Mobile (`src/screens/content/TaskSurveySummaryScreen.tsx`, `src/services/taskService.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/survey-editor/index.tsx`, `src/pages/public-survey/index.tsx`, `src/pages/public-survey/components/{PublicSurveyHeader,PublicQuestionCard,PublicSurveySuccess}.tsx`, `src/services/surveyService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskSurveySummaryScreen.tsx`, `src/services/taskService.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey · GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey · GET /api/v1/public/surveys/{token} · POST /api/v1/public/surveys/{token}/submit`
- **Controllers (`brandhub-business-service`):** `SurveyController.saveOrPublishSurvey() / getSurveyByTask(), PublicSurveyController.getPublicSurvey() / submitSurvey()`
- **Services:** `SurveyServiceImpl, GoogleSheetsService, SectionService (`SURVEY.FORM` / `WORKSHOP.REGISTRATION`)`
- **Repositories / Stores:** SurveyMongoRepository, SurveyResponseMongoRepository, TaskMongoRepository

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 VALIDATION_ERROR` (answer length / rating bounds `1..5`), `403 FORBIDDEN` (section editor policy), `404 SURVEY_NOT_FOUND` / `TASK_NOT_FOUND` (`BR-40`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

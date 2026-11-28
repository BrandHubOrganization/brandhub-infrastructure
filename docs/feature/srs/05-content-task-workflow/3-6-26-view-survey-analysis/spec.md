> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.26 — View Survey Analysis

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.26` |
| **Use Case ID** | `UC-078` |
| **Feature** | View Survey Analysis |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-40` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Xem báo cáo thống kê và phân tích kết quả phản hồi của biểu mẫu khảo sát (View Survey Analysis — /workspaces/:id/surveys/:surveyId/analytics). Hiển thị tổng số lượt phản hồi, tỷ lệ hoàn thành, biểu đồ phân bổ câu trả lời cho từng câu hỏi trắc nghiệm và danh sách chi tiết các ý kiến đóng góp để đánh giá hiệu quả sự kiện/workshop (BR-40).

**Consolidated Implementation Scope:** Aggregates real-time survey analytics (`SurveyAnalysisResponse`, `BR-40`) for `Owner, Manager, Client`: total response count, average `BigDecimal` rating distributions (`1..5`), option frequency/percentage breakdowns for single/multiple-choice questions, paginated open-text responses, and direct external link to the live synced Google Spreadsheet (`spreadsheetUrl`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **View Survey Analysis** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-40` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey/analysis · GET /api/v1/workspaces/{workspaceId}/surveys`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-40`):** `SurveyServiceImpl (`getSurveyAnalysis`, `listWorkspaceSurveys`)` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `surveys`, `survey_responses` return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 SURVEY_NOT_FOUND` (`BR-40`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`survey.analysis.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/tasks/survey-editor/index.tsx`, `src/components/charts/StatCharts.tsx`, `src/services/surveyService.ts`) and Mobile (`src/screens/content/TaskSurveySummaryScreen.tsx`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/tasks/survey-editor/index.tsx`, `src/components/charts/StatCharts.tsx`, `src/services/surveyService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/content/TaskSurveySummaryScreen.tsx`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey/analysis · GET /api/v1/workspaces/{workspaceId}/surveys`
- **Controllers (`brandhub-business-service`):** `SurveyController.getSurveyAnalysis(), WorkspaceSurveyController.listWorkspaceSurveys()`
- **Services:** `SurveyServiceImpl (`getSurveyAnalysis`, `listWorkspaceSurveys`)`
- **Repositories / Stores:** SurveyMongoRepository, SurveyResponseMongoRepository

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 SURVEY_NOT_FOUND` (`BR-40`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).

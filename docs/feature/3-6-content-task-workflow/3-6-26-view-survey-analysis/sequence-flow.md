# Sequence Flow — View Survey Analysis

> Supplements `spec.md` (FR 3.6.26). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Client / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `SurveyAnalysisDashboard (UI)`.
- **System** — `SurveyTaskController` / `SurveyTaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: View Survey Analysis

1. creatorclientmanager -> surveyanalysisdashbo: `Select "Survey Analysis" tab on Task Details`
2. surveyanalysisdashbo -> surveytaskcontroller: `GET /api/v1/workspaces/{wId}/tasks/{taskId}/survey/analysis`
3. surveytaskcontroller -> surveytaskserviceimp: `getSurveyAnalysis(workspaceId, taskId)`
4. surveytaskserviceimp -> surveyrepository: `findByTaskId(taskId)`
5. surveyrepository --> surveytaskserviceimp: `return Survey`
6. surveytaskserviceimp -> surveyresponsereposi: `findBySurveyId(survey.getId())`
7. surveyresponsereposi --> surveytaskserviceimp: `return List Survey`
8. surveytaskserviceimp -> surveyanalysisrespon: `toEmptyAnalysisResponse(survey)`
9. surveyanalysisrespon --> surveytaskserviceimp: `return emptyAnalysis`
10. surveytaskserviceimp --> surveytaskcontroller: `return emptyAnalysis`
11. surveytaskcontroller --> surveyanalysisdashbo: `return 200 OK (Empty count, zero statistics)`
12. surveyanalysisdashbo --> creatorclientmanager: `Display empty state ("No survey responses collected yet") with public link CTA`
13. surveytaskserviceimp -> surveytaskserviceimp: `aggregateMetrics(survey.getQuestions(), responses)`
14. surveytaskserviceimp -> surveyanalysisrespon: `toSurveyAnalysisResponse(survey, aggregatedMetrics)`
15. surveyanalysisrespon --> surveytaskserviceimp: `return analysisResponse`
16. surveytaskserviceimp --> surveytaskcontroller: `return analysisResponse`
17. surveytaskcontroller --> surveyanalysisdashbo: `return 200 OK (Aggregated metrics, question breakdowns, chart datasets)`
18. surveyanalysisdashbo --> creatorclientmanager: `Render visual charts (Bar/Pie charts, average ratings, response volume summary)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

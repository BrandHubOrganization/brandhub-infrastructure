# Sequence Flow — Export Report File PDF

> Supplements `spec.md` (FR 3.10.12). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminReportPage (UI)`.
- **System** — `ReportController` / `ReportService`.

---

## Flow A — Luồng thực thi chính: Export Report File PDF

1. admin -> adminreportpageui: `configures report parameters, clicks "Generate Report"`
2. adminreportpageui -> reportcontroller: `POST /api/v1/admin/reports/generate (GenerateReportRequest)`
3. reportcontroller -> reportservice: `generateReport(adminId, request)`
4. reportservice -> pdfgeneratorservice: `generate(reportData)`
5. pdfgeneratorservice --> reportservice: `pdfBytes`
6. reportservice -> reportrepository: `save(reportRecord with expiresAt=NOW()+7days)`
7. reportrepository --> reportservice: `savedReport(reportId, downloadUrl)`
8. reportservice --> reportcontroller: `201 Created (ReportResponse)`
9. reportcontroller --> adminreportpageui: `201 Created (downloadUrl)`
10. adminreportpageui --> admin: `Display download link`
11. admin -> adminreportpageui: `clicks "Download PDF"`
12. adminreportpageui -> reportcontroller: `GET /api/v1/admin/reports/{reportId}/download`
13. reportcontroller -> reportservice: `downloadReport(reportId)`
14. reportservice -> reportrepository: `findById(reportId)`
15. reportrepository --> reportservice: `null / expired`
16. reportservice --> reportcontroller: `404 Not Found (REPORT_EXPIRED)`
17. reportcontroller --> adminreportpageui: `404 Not Found`
18. adminreportpageui --> admin: `Show error "Report expired or not found"`
19. reportrepository --> reportservice: `reportRecord`
20. reportservice --> reportcontroller: `200 OK (pdfStream)`
21. reportcontroller --> adminreportpageui: `200 OK (Content-Disposition: attachment)`
22. adminreportpageui --> admin: `PDF downloaded`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

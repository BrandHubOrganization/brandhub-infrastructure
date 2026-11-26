**3.10.12 Export Report File PDF**

**Function Trigger**

Begins when an Administrator (ADMIN) clicks the "Export PDF Report" button on administrative management screens.

**Function Description**

- **Actors / Roles**: ADMIN. System administrator authorized to export official report documents for archiving and compliance auditing.
- **Purpose**: Export A4 reports of finance, user/strike state, moderation versions and platform overview using the same definitions and timezone as their source screens. Monitoring scope remains owned by FR 3.10.3.
- **Interface**: Export PDF Report Modal (SCR-ADM-11), featuring report type selector, date range picker, data field toggles, and direct file download trigger.
- **Data Processing**: The system verifies ADMIN role authority (BR-35, BR-65), accepts report classification and temporal boundaries, queries source datasets, formats document into standard A4 PDF layout with header logo, page numbers, and timestamps, stores temporary file, and returns a secure download URL (BR-16).

**Screen Layout**

Figure — Export Report File PDF Modal (SCR-ADM-11, centered dialog window 560px):

- Left/Header: Modal Header title "Export System PDF Report" with document icon.
- Center: Report type revenue/user/moderation/platform, date range, timezone UTC / Asia/Ho_Chi_Minh, sections/charts and summary preview. User report distinguishes active, converted, pardoned and expired strikes; finance report separates MRR/ARR from receipts/refunds.
- Buttons: Button "Download PDF File" (green/navy), Button "Cancel".
- Footer: BrandHub confidential document notice and temporary download URL expiration timeframe (24 hours).

**Function Details**

- **Data Specifications**
    - **Input required**: reportType (enum: "revenue", "user", "moderation", "platform"), startDate (YYYY-MM-DD), endDate (YYYY-MM-DD).
    - **Input optional**: includeCharts, sections, timezone (UTC/Asia/Ho_Chi_Minh, default Asia/Ho_Chi_Minh), source-screen filters.
    - **System data**: adminId (UUID of requesting Admin), generatedReportId (UUID), downloadUrl (temporary download link), expiresAt (24-hour expiration timestamp).
    - **Output**: JSON response object containing { reportId, downloadUrl, fileName, fileSize, expiresAt } with HTTP status code 200 OK.

- **Business Rules**
    - **BR-65**: Only ADMIN may request/export platform reports.
    - **BR-35**: Verify authority before querying and before authorized download access.
    - **BR-16**: Audit report type, requester, filters, period, timezone, asOf, generated file and expiry.
    - **BR-80**: Match source-screen definitions in FR 3.10.2/5/6/9/11: active strike states, conversion lineage, account sanction deadlines, MRR/ARR and gross/refund/net receipts; never substitute Trust Score.
    - **BR-65**: Reporting stores timestamps in UTC and supports UTC or Asia/Ho_Chi_Minh (default). Resolve date boundaries and daily/monthly buckets in the selected timezone; include timezone in responses, exports and cache keys.
    - **BR-65**: Preserve A4 layout, Vietnamese glyph support, header, page numbering and secure 24-hour download URL. Do not invent historical Monitoring data or extend FR 3.10.3 scope.

- **Validation**
    - User does not possess ADMIN role permissions → Display: MSG39
    - No records exist within the selected date range → Display: MSG122

**Functionalities**

- **Normal Flow**
    1. Admin clicks "Export PDF Report" button on the administrative navigation bar or screen.
    2. System displays configuration modal SCR-ADM-11.
    3. Admin selects Report Type, specifies Date Range, and selects desired content sections.
    4. Admin clicks "Download PDF File".
    5. System verifies administrative authority (BR-35, BR-65) and queries corresponding datasets for the selected timeframe.
    6. System synthesizes standard A4 PDF document based on standardized template.
    7. System generates a secure temporary download link and triggers client browser to download the PDF file to Admin workstation.
    8. System closes modal and records the operation in the audit log (BR-16).

- **Abnormal Cases**
    - 1.a1: If user does not possess ADMIN role, system rejects request and displays MSG39.
    - 5.a1: If no records exist in selected date range, system displays MSG122 and halts empty file generation.

**Post-Conditions**

- Report PDF document is generated successfully and cached temporarily on the server for 24 hours.
- Admin browser downloads PDF file to local storage.
- An export audit record is persisted in audit_logs cataloging report parameters and Admin identity (BR-16).

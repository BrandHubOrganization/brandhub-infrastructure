# Sequence Flow — Create Media Package

> Supplements `spec.md` (FR 3.5.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **AgencyOwner** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `MediaPackageUI`.
- **System** — `MediaPackageController` / `MediaPackageService`.

---

## Flow A — Luồng thực thi chính: Create Media Package

1. agencyowner -> mediapackageui: `clicks "Browse Templates" or opens package catalog`
2. mediapackageui -> mediapackagecontroll: `GET /api/v1/media-package-templates`
3. mediapackagecontroll -> mediapackageservice: `listTemplates()`
4. mediapackageservice -> mediapackagereposito: `findAllByIsTemplateTrueOrderByCreatedAtAsc()`
5. mediapackagereposito --> mediapackageservice: `templatePackages`
6. mediapackageservice --> mediapackagecontroll: `List<MediaPackageResponse>`
7. mediapackagecontroll --> mediapackageui: `200 OK (templatePackages)`
8. mediapackageui --> agencyowner: `render global template cards`
9. agencyowner ->> mediapackageui: `fills package form (name, type, durationWeeks/budget, scope, optional sourceTemplateId) & submits`
10. mediapackageui ->> mediapackagecontroll: `POST /api/v1/agencies/{agencyId}/media-package-custom (CreateCustomMediaPackageRequest)`
11. mediapackagecontroll ->> mediapackageservice: `createCustomPackage(agencyId, currentUser, request)`
12. mediapackageservice ->> agencyrepository: `findById(agencyId)`
13. agencyrepository ->> mediapackageservice: `agency`
14. mediapackageservice --> mediapackagecontroll: `throw BusinessException (403 NOT_AGENCY_OWNER)`
15. mediapackagecontroll --> mediapackageui: `403 Forbidden (NOT_AGENCY_OWNER)`
16. mediapackageui --> agencyowner: `show error toast ('Access denied: Agency Owner role required')`
17. mediapackageservice ->> mediapackagereposito: `findById(sourceTemplateId)`
18. mediapackagereposito --> mediapackageservice: `nonTemplatePackage (isTemplate=false)`
19. mediapackageservice --> mediapackagecontroll: `throw BusinessException (400 MEDIA_PACKAGE_TEMPLATE_REQUIRED)`
20. mediapackagecontroll --> mediapackageui: `400 Bad Request (MEDIA_PACKAGE_TEMPLATE_REQUIRED)`
21. mediapackageui --> agencyowner: `show validation error ('Source package must be a system template')`
22. mediapackageservice --> mediapackagecontroll: `throw BusinessException (400 INVALID_MEDIA_PACKAGE_CONFIGURATION)`
23. mediapackagecontroll --> mediapackageui: `400 Bad Request (INVALID_MEDIA_PACKAGE_CONFIGURATION)`
24. mediapackageui --> agencyowner: `show validation error ('Duration or budget is required based on type')`
25. mediapackageservice ->> mediapackagereposito: `findById(sourceTemplateId)`
26. mediapackagereposito --> mediapackageservice: `sourceTemplate (isTemplate=true)`
27. mediapackageservice ->> mediapackagereposito: `save(mediaPackage)`
28. mediapackagereposito --> mediapackageservice: `savedMediaPackage`
29. mediapackageservice --> mediapackagecontroll: `MediaPackageResponse`
30. mediapackagecontroll --> mediapackageui: `201 Created (MediaPackageResponse)`
31. mediapackageui --> agencyowner: `show success toast & display new package in Agency catalogue`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

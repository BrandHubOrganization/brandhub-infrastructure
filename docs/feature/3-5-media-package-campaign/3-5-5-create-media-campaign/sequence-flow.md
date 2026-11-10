# Sequence Flow — Create Media Campaign

> Supplements `spec.md` (FR 3.5.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `MediaCampaignUI`.
- **System** — `MediaCampaignController` / `MediaPackageService`.

---

## Flow A — Luồng thực thi chính: Create Media Campaign

1. mediapackageservice -> mediapackageservice: `initCampaign(status: DRAFT, contentVersion: 1, workItems)`
2. manager -> mediacampaignui: `fills campaign form (name, strategyDetail, brandGuideline, timeline, workItems JSONB) & submits`
3. mediacampaignui -> mediacampaigncontrol: `POST /api/v1/media-campaigns (CreateMediaCampaignRequest)`
4. mediapackageservice -> workspacemediapackag: `findById(request.workspaceMediaPackageId)`
5. workspacemediapackag --> mediapackageservice: `workspacePackage`
6. mediacampaigncontrol -> mediapackageservice: `createCampaign(currentUser, request)`
7. mediapackageservice --> mediacampaigncontrol: `throw BusinessException (404 WORKSPACE_PACKAGE_NOT_FOUND)`
8. mediacampaigncontrol --> mediacampaignui: `404 Not Found (WORKSPACE_PACKAGE_NOT_FOUND)`
9. mediacampaignui --> manager: `show error toast ('Workspace package not found')`
10. mediapackageservice --> mediacampaigncontrol: `throw BusinessException (400 PACKAGE_NOT_APPROVED)`
11. mediacampaigncontrol --> mediacampaignui: `400 Bad Request (PACKAGE_NOT_APPROVED)`
12. mediacampaignui --> manager: `show error toast ('Cannot create campaign from unapproved package')`
13. mediapackageservice --> mediacampaigncontrol: `throw BusinessException (403 WORKSPACE_ACCESS_DENIED)`
14. mediacampaigncontrol --> mediacampaignui: `403 Forbidden (WORKSPACE_ACCESS_DENIED)`
15. mediacampaignui --> manager: `show error toast ('Access denied: Manager or Owner role required')`
16. mediapackageservice --> mediacampaigncontrol: `throw BusinessException (400 INVALID_WORK_ITEMS)`
17. mediacampaigncontrol --> mediacampaignui: `400 Bad Request (INVALID_WORK_ITEMS)`
18. mediacampaignui --> manager: `show validation error ('Each work item must contain id, name, type POST|LIVESTREAM|SURVEY, and dueDate')`
19. mediapackageservice ->> mediapackagereposito: `save(mediaCampaign)`
20. mediapackagereposito --> mediapackageservice: `savedCampaign`
21. mediapackageservice --> mediacampaigncontrol: `MediaCampaignResponse`
22. mediacampaigncontrol --> mediacampaignui: `201 Created (MediaCampaignResponse)`
23. mediacampaignui --> manager: `show success toast & display new Campaign in workspace list`
24. manager ->> mediacampaignui: `clicks campaign card or opens campaign detail view`
25. mediacampaignui ->> mediacampaigncontrol: `GET /api/v1/media-campaigns/{campaignId}`
26. mediacampaigncontrol ->> mediapackageservice: `getCampaign(campaignId)`
27. mediapackageservice ->> mediapackagereposito: `findById(campaignId)`
28. mediapackagereposito --> mediapackageservice: `mediaCampaign`
29. mediapackageservice --> mediacampaigncontrol: `throw BusinessException (404 CAMPAIGN_NOT_FOUND)`
30. mediacampaigncontrol --> mediacampaignui: `404 Not Found (CAMPAIGN_NOT_FOUND)`
31. mediacampaignui --> manager: `show error toast ('Campaign not found')`
32. mediapackageservice --> mediacampaigncontrol: `MediaCampaignResponse`
33. mediacampaigncontrol --> mediacampaignui: `200 OK (MediaCampaignResponse)`
34. mediacampaignui --> manager: `render campaign overview, workItems timeline & approval status`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

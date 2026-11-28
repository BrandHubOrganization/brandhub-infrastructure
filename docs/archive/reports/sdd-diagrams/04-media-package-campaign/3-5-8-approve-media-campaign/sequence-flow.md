# Sequence Flow — Approve Media Campaign

> Supplements `spec.md` (FR 3.5.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User (Client / Manager)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `MediaCampaignUI`.
- **System** — `MediaCampaignController` / `MediaCampaignService`.

---

## Flow A — Luồng thực thi chính: Approve Media Campaign

1. userclientmanager -> mediacampaignui: `reviews campaign work items & clicks "Approve Campaign"`
2. mediacampaignservice -> mediacampaignservice: `set approvedByClientAt = now`
3. mediacampaignservice -> mediacampaignservice: `set approvedByAgencyAt = now`
4. mediacampaignservice -> mediacampaignservice: `set status = IN_PROGRESS`
5. mediacampaignui -> mediacampaigncontrol: `POST /api/v1/media-campaigns/{campaignId}/approve`
6. mediacampaigncontrol -> mediacampaignservice: `approveCampaign(campaignId, currentUser)`
7. mediacampaignservice -> mediacampaignreposit: `findByIdForUpdate(campaignId)`
8. mediacampaignreposit --> mediacampaignservice: `campaign`
9. mediacampaignservice --> mediacampaigncontrol: `throw BusinessException (404 CAMPAIGN_NOT_FOUND)`
10. mediacampaigncontrol --> mediacampaignui: `404 Not Found (CAMPAIGN_NOT_FOUND)`
11. mediacampaignui --> userclientmanager: `show error toast ('Campaign not found')`
12. mediacampaignservice --> mediacampaigncontrol: `throw BusinessException (400 CAMPAIGN_ALREADY_ACTIVE)`
13. mediacampaigncontrol --> mediacampaignui: `400 Bad Request (CAMPAIGN_ALREADY_ACTIVE)`
14. mediacampaignui --> userclientmanager: `show error toast ('Campaign is already in progress or completed')`
15. mediacampaignservice --> mediacampaigncontrol: `throw BusinessException (403 WORKSPACE_ACCESS_DENIED)`
16. mediacampaigncontrol --> mediacampaignui: `403 Forbidden (WORKSPACE_ACCESS_DENIED)`
17. mediacampaignui --> userclientmanager: `show error toast ('Access denied: Client or Agency Manager role required')`
18. mediacampaignservice ->> mediacampaignreposit: `save(campaign)`
19. mediacampaignreposit --> mediacampaignservice: `savedCampaign`
20. mediacampaignservice --> mediacampaigncontrol: `MediaCampaignResponse (approved timestamp recorded)`
21. mediacampaigncontrol --> mediacampaignui: `200 OK (partially approved)`
22. mediacampaignui --> userclientmanager: `show toast ('Approval recorded. Awaiting confirmation from second party')`
23. mediacampaignservice ->> taskrepositorymongod: `upsertTask({campaignId, campaignWorkItemId: workItem.id}, taskData)`
24. taskrepositorymongod --> mediacampaignservice: `upsertedTaskDocument`
25. mediacampaignservice ->> mediacampaignreposit: `save(campaign)`
26. mediacampaignreposit --> mediacampaignservice: `savedCampaign (status: IN_PROGRESS)`
27. mediacampaignservice --> mediacampaigncontrol: `MediaCampaignResponse (status: IN_PROGRESS)`
28. mediacampaigncontrol --> mediacampaignui: `200 OK (MediaCampaignResponse)`
29. mediacampaignui --> userclientmanager: `show success modal ('Campaign fully approved! Work items deployed to Task Backlog')`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

# Sequence Flow — Request Media package

> Supplements `spec.md` (FR 3.5.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `MediaPackagePage (UI)`.
- **System** — `MediaPackageController` / `MediaPackageService`.

---

## Flow A — Luồng thực thi chính: Request Media package

1. user -> mediapackagepageui: `selects campaign & media package, clicks "Request"`
2. mediapackagepageui -> mediapackagecontroll: `POST /api/v1/media-packages/request (RequestMediaPackageRequest)`
3. mediapackagecontroll -> mediapackageservice: `requestMediaPackage(userId, request)`
4. mediapackageservice -> campaignrepository: `findById(campaignId)`
5. campaignrepository --> mediapackageservice: `Optional.empty()`
6. mediapackageservice --> mediapackagecontroll: `404 Not Found (CAMPAIGN_NOT_FOUND)`
7. mediapackagecontroll --> mediapackagepageui: `404 Not Found`
8. mediapackagepageui --> user: `Show error "Campaign not found"`
9. campaignrepository --> mediapackageservice: `Optional<Campaign>`
10. mediapackageservice -> mediapackagereposito: `existsByUserIdAndCampaignIdAndStatus(userId, campaignId, PENDING)`
11. mediapackagereposito --> mediapackageservice: `false`
12. mediapackageservice -> mediapackagereposito: `save(newMediaPackageRequest)`
13. mediapackagereposito --> mediapackageservice: `savedRequest`
14. mediapackageservice --> mediapackagecontroll: `MediaPackageResponse(requestId, status=PENDING)`
15. mediapackagecontroll --> mediapackagepageui: `201 Created (MediaPackageResponse)`
16. mediapackagepageui --> user: `"Media package requested — awaiting approval"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |

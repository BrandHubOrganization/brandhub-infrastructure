# UC — View Hastag Collection

| | |
|---|---|
| FR Code | 3.6.18 |
| Feature | View Hastag Collection |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Kho hashtag riêng cho từng Workspace — Creator tự thêm tự do, Client thêm mang tính đặc thù bắt buộc dùng, AI recommend thêm.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn xem kho hashtag của Workspace,
để tái sử dụng hashtag phù hợp cho bài đăng mới.

## 3. Acceptance Criteria

- List hashtag theo Workspace, phân loại theo mục đích sử dụng (xem FR 3.6.19).
- Hashtag do Client thêm được đánh dấu **bắt buộc dùng** cho sự kiện tương ứng — khác hashtag Creator tự thêm (tùy chọn).
- Có tích hợp gợi ý từ AI (xem [06-ai-features.md](../../BA/06-ai-features.md) FR 3.7.10 Suggest Hashtag Trend).

## 4. UI / UX

- Trang `/workspaces/:id/hashtags`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/hashtags
→ 200 { "success": true, "data": [{ "id", "tag", "purpose", "addedBy", "isRequired" }] }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- List hiển thị đúng phân loại required/optional.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../BA/05-content-task-workflow.md)

## Implementation contract — 2026-10-10

The revised `tuan-research/spec` FR takes precedence over the legacy role table above.
This delivery covers Add + View + Remove. One row represents one hashtag, not a named group.
Active CREATOR, CLIENT and MANAGER members may view and add in an active workspace;
client-profile membership is supported. Owner/admin status alone grants no content access.
No Apply, Update, AI call or Post mutation is included. Remove soft-deletes the collection
entry and records deletedBy/deletedAt; Manager may remove any entry, Creator may remove
own ordinary entries or any required Client entry, and Client may remove own entries.

POST `/api/v1/workspaces/{workspaceId}/hashtags` accepts `tag`, `purpose`.
Purpose values: BRAND, CAMPAIGN, TRENDING, EVENT_SPECIFIC. EVENT_SPECIFIC is a required
Client tag scoped to one MediaCampaign belonging to the workspace.
Tags: trim, remove one leading #, NFC Unicode normalization, letters/marks/digits/underscore,
1–100 characters; retain accents and display case, lowercase ROOT for duplicate matching.
An active normalized tag is unique within its workspace. Duplicate races return 409
HASHTAG_ALREADY_EXISTS. Creator identity/time comes from the server.
GET uses q (max 100), purpose, isRequired, page (default 0), size (default 20, max 100).
Response data contains items, page, size, totalElements and totalPages. Each item includes
id, workspaceId, tag, purpose, addedBy, addedByName, isRequired, campaignId, version,
createdAt. `version` supports reconfirmation if an entry changes before removal.
DELETE `/api/v1/workspaces/{workspaceId}/hashtags/{hashtagId}` accepts optional
`expectedVersion`; successful removal returns 200 with null data. Removed entries no longer
appear in the active collection and existing post snapshots remain unchanged.
Bad input returns 400; unauthenticated returns 401; unauthorized/inactive workspace returns 403.

UI: collection page and Library hashtag tab use the same real collection feature.
Existing hashtag-groups URL remains compatible; `/workspaces/:id/hashtags` is canonical.
Loading, empty, filtered-empty, retry, saving, duplicate and denied states are distinct.
A workspace switch resets local form/filters and query keys include workspace and account.
Successful creation refreshes that workspace collection. Failed saves retain input.

All labels use parallel vi/en keys under `hashtagGroups.collection`: title, description,
add, tag, purpose, purposes.*, required, optional, creator, createdAt, search, all,
allRequirements, empty, noResults, loading, retry, loadError, saveError, duplicate,
invalid, denied, selectWorkspace, save, cancel, added, previous, next, page.
Use semantic theme tokens in light/dark, labeled inputs and keyboard-operable controls.

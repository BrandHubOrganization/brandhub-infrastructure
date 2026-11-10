# UC — Add Hastag Collection

| | |
|---|---|
| FR Code | 3.6.19 |
| Feature | Add Hastag Collection |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Thêm hashtag mới vào Collection, phân loại rõ mục đích sử dụng.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn thêm hashtag mới vào kho,
để dùng lại cho các bài đăng sau.

## 3. Acceptance Criteria

- Form nhập `tag`, chọn `purpose` (ví dụ: brand, campaign, trending, event-specific).
- Client thêm → tự động `isRequired=true` nếu đánh dấu đặc thù sự kiện.

## 4. UI / UX

- Nút 'Thêm hashtag' trong `/workspaces/:id/hashtags`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/hashtags
{ "tag": "string", "purpose": "string", "isRequired"?: boolean }
→ 201 { "success": true, "data": { "id", "tag" } }
```

## 6. Error Handling

- Hashtag trùng đã tồn tại trong Workspace → 409 `HASHTAG_ALREADY_EXISTS`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Thêm thành công, phân loại đúng purpose.

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
Purpose values: BRAND, CAMPAIGN, TRENDING, EVENT_SPECIFIC. In this delivery,
EVENT_SPECIFIC means a required tag scoped to a MediaCampaign, since the repository has no
Event entity. Only CLIENT may create one. The backend verifies its campaign belongs to the
requested workspace; this mapping should move to Event if/when that entity is introduced.
Tags: trim, remove one leading #, NFC Unicode normalization, letters/marks/digits/underscore,
1–100 characters; retain accents and display case, lowercase ROOT for duplicate matching.
An active normalized tag is unique within its workspace. Duplicate races return 409
HASHTAG_ALREADY_EXISTS. Creator identity/time comes from the server.
GET uses q (max 100), purpose, isRequired, page (default 0), size (default 20, max 100).
POST also accepts isRequired and campaignId for an event-specific required tag. GET accepts
campaignId as an optional scope filter. Response data contains items, page, size,
totalElements and totalPages. Each item includes id, workspaceId, tag, purpose, addedBy,
addedByName, isRequired, campaignId, version and createdAt. `version` supports
reconfirmation if an entry changes before removal.
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

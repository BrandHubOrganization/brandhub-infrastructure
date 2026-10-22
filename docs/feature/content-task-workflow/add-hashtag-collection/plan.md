# Add/View hashtag implementation plan

Read spec.md first. Shared implementation serves FR 3.6.18 and 3.6.19.
Business: Hashtag entity/JPA repository, request/response records, HashtagService,
HashtagServiceImpl and thin HashtagController. Reuse WorkspaceAccessService for active
membership including ClientProfile; verify workspace active status in this service.
PostgreSQL migration adds workspace_hashtags and its active normalized-tag unique index.
The migration is required before restart because Hibernate uses ddl-auto=validate.
No distributed transaction or provider is involved. Use short local transactions.

Web: feature-local collection service/types/query hook and Add dialog + collection view.
Reuse this feature from the Library tab. Replace the hashtag-groups page's mock entry point.
Use shared api, TanStack Query, workspace context, semantic primitives and parallel keys in
src/i18n/locales/{vi,en}/hashtagGroups.json. Add CLIENT to collection route access.
Keep unrelated mock templates/material pages outside this delivery.

Validation: API-level tests for normalization, roles, scope, validation and duplicate errors;
PostgreSQL verification of migration/index/concurrency where a test DB is available;
Playwright network-boundary tests for Add -> View, filters, error retention, locales/themes.
Scope mapping for this delivery: EVENT_SPECIFIC required tags use an existing MediaCampaign
as the workspace-owned scope because this repository has no Event entity. Only CLIENT may
create these tags; the API verifies that the campaign resolves through its media package
to the requested workspace. Change this mapping if/when a dedicated Event model is added.

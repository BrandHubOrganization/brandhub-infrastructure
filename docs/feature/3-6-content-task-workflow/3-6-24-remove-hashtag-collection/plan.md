# Remove hashtag collection plan

Read `spec.md` first. Reuse the workspace hashtag model, API and collection from FR
3.6.18/3.6.19. Remove through `DELETE /api/v1/workspaces/{workspaceId}/hashtags/{id}`.
The service checks active workspace membership, scoped active record, the role/ownership
matrix and optional expected version before setting `deletedAt` and `deletedBy`.
The existing partial unique index then permits a later re-add of the same normalized tag.
No post/task data is changed.

The UI exposes Remove only for roles/entries allowed by the contract, opens a confirmation
dialog, and shows required status plus MediaCampaign scope before confirmation. On success,
invalidate the current workspace collection. A stale version or prior removal returns a
specific conflict and keeps the dialog open for refresh/review.

Database migration adds nullable `deleted_by`; Hibernate version remains the stale-confirm
guard. No new table or hard-delete path is needed.

Validation: API tests cover soft removal, active-list exclusion, repeated removal, stale
version, workspace scope and permission matrix. Web build and a Playwright flow cover
confirmation and preservation of the removed record/post snapshots. PostgreSQL migration
validation requires a configured test database.

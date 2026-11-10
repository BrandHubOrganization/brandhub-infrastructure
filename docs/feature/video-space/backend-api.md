# Video Space backend implementation notes

The business service implements authenticated, owner-private project APIs. These notes describe source changes only; no live database migration or provider call was performed.

## HTTP contract

Base: `/api/v1/workspaces/{workspaceId}/video-projects`. Workspace, project and asset IDs are UUIDs. The current authenticated owner must have usable account/workspace access; CLIENT and admin-support access are denied. Agency/manager access does not grant another owner's project.

| Operation | Request | `ApiResponse.data` |
|---|---|---|
| GET base | `page=0&size=20`, maximum size 50 | Summary array; `meta` contains page/size/total |
| GET `/{projectId}` | — | `{id,revision,updated_at,snapshot,assets}` |
| PUT `/{projectId}` | `{expected_revision,snapshot}` | Exact newly committed project revision |
| POST `/{projectId}/media/{assetId}/upload-session` | `{fileName,contentType,sizeBytes,sha256,metadata}` | `{sessionId,uploadUrl,headers,expiresAt}` |
| POST corresponding `/upload-complete` | `{sessionId}` | `{id,name,mime_type,sha256,metadata}` |
| POST corresponding `/upload-abort` | `{sessionId}` | null |
| GET `/{projectId}/media/{assetId}` | — | Original bytes, inline, MIME preserved, private/no-store and nosniff |

The host PUTs the File directly to the returned upload URL using the returned headers and no JWT. A null upload URL means that the immutable original already exists; complete is idempotent and returns the original descriptor. Same asset/SHA preserves the first filename and metadata. A different SHA is a 409 conflict. Uploading media atomically claims a hidden revision-0 draft before a first snapshot exists.

`GET /api/v1/workspaces/{workspaceId}/ai/videos/{jobId}/content` checks workspace/account access and persisted job ownership/completion, then reads the persisted key through `FileStorageService`. It does not refresh a job, invoke the AI provider or use credit services. It returns MP4 bytes with private/no-store, inline disposition and nosniff. Client URLs/keys/buckets are not accepted.

Limits remain 128 MiB per original, 512 KiB per uploaded metadata object, 4 MiB serialized snapshot, 1000 inventory IDs and 200 characters per project name. Accepted descriptor manifests are additionally bounded to 8 MiB, keeping the single snapshot + manifest document below MongoDB's 16 MiB limit. Existing global multipart limits remain 5 MB/6 MB.

## Persistence and indexes

All collections use string UUIDs and `Instant` dates. Arbitrary snapshot and media metadata JSON is serialized into bounded strings; nested editor keys are preserved. Mongo writes to these collections use the existing majority write-concern resolver.

The following index commands are deployment notes, **not an applied migration**. Use the existing Mongo migration process and inspect the target database before applying them.

The same indexes are packaged in [2026-10-29-video-projects-indexes.js](../../database/migration-mongo/2026-10-29-video-projects-indexes.js). Its default DRY_RUN inspects collection/index metadata only. An operator can set `globalThis.VIDEO_PROJECT_INDEXES_APPLY = true` after reviewing the selected database. It creates indexes without modifying existing documents and stops on an existing index with a different definition. This migration has not been applied by the integration task.

```javascript
db.video_projects.createIndex(
  { workspaceId: 1, ownerId: 1, updatedAt: -1, _id: -1 },
  { name: "idx_video_projects_owner_list", partialFilterExpression: { revision: { $gt: 0 } } }
);
db.video_project_assets.createIndex(
  { workspaceId: 1, ownerId: 1, projectId: 1, state: 1, assetId: 1 },
  { name: "idx_video_project_assets_scope" }
);
db.video_project_assets.createIndex(
  { workspaceId: 1, state: 1 },
  { name: "idx_video_project_assets_usage" }
);
db.video_project_upload_sessions.createIndex(
  { workspaceId: 1, ownerId: 1, projectId: 1, assetId: 1 },
  { name: "idx_video_project_upload_sessions_scope" }
);
```

Primary `_id` uniqueness provides the correctness lock: projects use `workspace:project`, assets use `workspace:project:asset`, and upload attempts use the quota reservation UUID. Separate upload-attempt records retain old staging/copy checkpoints after an abort/retry. No existing MaterialDocument is created.

Projects store accepted snapshot and descriptor manifest in one revision CAS. A rejected stale save cannot publish newly staged uploads. GET project uses its accepted manifest rather than reading the mutable staging inventory. Media registry entries become immutable after READY.

## Storage lifecycle and setup

The existing repository storage write switch, verified provider configuration, agency quota schema/inventory and storage-pool readiness apply. Existing deployments must already satisfy those guards; the feature does not bypass or provision them.

Provider CORS must permit the real host origin to PUT with the returned Content-Type header, as for existing direct Repository uploads. Capability URLs for customer Drive continue to use the existing repository-drive route. No additional editor server is required.

Reservations have `video-space:` request keys. The shared recovery sweep dispatches that namespace to private video recovery, and storage reconciliation adds private READY originals to material bytes. Both paths retain existing bounded recovery scans and quota accounting.

Direct upload goes to `repository-staging/{workspace}/{reservation}/object`. Confirmation reads the reserved provider, checks head/length/MIME and full SHA with ETag-bound bounded ranges, then conditionally copies to an unguessable canonical key. Copy checkpoints precede quota commit and private publication. An ambiguous copy retains quota for recovery. Abort releases only reservations before copy; an in-progress copy returns a conflict. Staging cleanup verifies absence before allowing the shared physical-pool hold to be cleared.

The old AI source reader uses the existing legacy S3 bucket routing. Verify the business service default S3 bucket matches the AI service video output bucket; generated video keys use the configurable Veo prefix (default `ai-videos`). This reader currently uses the existing buffered legacy download method; project originals stream in bounded ranges.

No planner/edit-plan endpoint or DemoVideo integration is included.

## Verification

Verified 2026-10-29 on local branch `feature/video-space-integration-20261028`:

- Feature tests: 30 tests across 13 new suites; zero failures/errors/skips in the final full-suite reports.
- Focused feature plus existing storage/access regressions: 64 tests; zero failures/errors/skips (before five final additional feature cases).
- Default complete suite: 1,283 tests; zero failures, zero errors, 82 skipped. BUILD SUCCESS in 1 minute 24 seconds, finished `2026-10-29T00:46:02+07:00`.
- Compilation occurs in the Maven test lifecycle and succeeded. `git diff --check` succeeded.
- Test evidence: business service `target/video-space-full-suite.log` and `target/surefire-reports/TEST-*.xml`.

Exact final command from the business-service directory (PowerShell):

```powershell
& 'C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11-bin\6mqf5t809d9geo83kj4ttckcbc\apache-maven-3.9.11\bin\mvn.cmd' -o -ntp '-Dmaven.repo.local=C:\Users\ADMIN\.m2\repository' test
```

Focused test selector used with the same Maven invocation:

```text
-Dtest=Video*Test,AiVideoContentTest,Material*Test,WorkspaceAccessServiceTest,ContentRequestStoreTest,S3GeneratedMediaTest
```

Maven needed permission to access its dependency cache, and missing Ant plugin dependencies were downloaded once before the final offline runs. Initially stale/interrupted incremental compiler output required resetting only generated compiler status; the subsequent full rebuild and default suite succeeded. No unresolved baseline test failure remains. Environment-gated live DB/API checks and E2E tests were not enabled.

No live SQL/Mongo migration, database fixture write, paid generation or real storage upload was performed for these unit/MockMvc checks. Real provider configuration/CORS and database index deployment remain operational setup, not claims established by mocked storage tests. Root owns host/browser verification and the four central feature documents.

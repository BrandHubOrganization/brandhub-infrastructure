# DA-E07-01 — Business & Publisher Service Endpoint Reference

> Navigation: [← Knowledge Base Hub](../index.md) · [← API Contracts Index](./README.md) · [Business OpenAPI Spec](./openapi-spec-business-service.md) · [AI OpenAPI Spec](./openapi-spec-ai-service.md) · [API Response Format](./api-response-format.md) · [BA 9 Domains](../ba/README.md)

Authoritative, code-verified REST and STOMP WebSocket endpoint reference for **`brandhub-business-service` (`:8081`)** and **`brandhub-publisher-service` (`:8083`)**, routed through **`brandhub-api-gateway` (`:8080` / `https://api.brandhub.id.vn`)**.

- **Functional Coverage**: All **9 SRS Functional Domains (`141` FRs, `3.2.1`–`3.10.14`)** + STOMP real-time collaboration + infrastructure health monitoring.
- **Canonical System Roles**: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` ([Roles & Permissions Matrix](../ba/10-roles-permissions-matrix.md)).
- **Response Envelope**: Every REST endpoint returns `ApiResponse<T>` (`204 No Content` is never used — see [API Response Format](./api-response-format.md)).

---

## 1. Domain 3.2 — Authentication, Sessions & 2FA (`/api/v1/auth/**`)

Controllers: `AuthController`, `GoogleOAuthController`, `AccountActivationController` ([BA Spec](../ba/02-authentication-profile.md)).

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/register` | `Guest` | Register new user account with email/password (`FR 3.2.1`) |
| `POST` | `/api/v1/auth/verify-otp` · `/resend-otp` | `Guest` | Verify email registration / recovery OTP or resend code |
| `POST` | `/api/v1/auth/activation/verify` · `/complete` | `Guest` | Complete one-time `account_activation_tokens` onboarding (`Admin` / invite flow) |
| `POST` | `/api/v1/auth/login` | `Guest` | Authenticate credentials; returns RS256 `accessToken` (`15m`) + HttpOnly `refreshToken` (`30d`) or 2FA challenge (`FR 3.2.2`) |
| `GET` | `/api/v1/auth/oauth/google` · `/callback` | `Guest` | Initiate and complete Google OAuth 2.0 login (`FR 3.2.3`) |
| `GET` | `/api/v1/auth/oauth/google/link` | Authenticated | Link Google OAuth identity to an existing signed-in account (`user_oauth_providers`) |
| `POST` | `/api/v1/auth/refresh` | `Guest` (Cookie) | Rotate HttpOnly refresh token and blacklist prior `jti` in Redis |
| `POST` | `/api/v1/auth/logout` | Authenticated | Revoke current access `jti` (`jwt:blacklist:{jti}`) and delete refresh session (`FR 3.2.8`) |
| `GET` | `/api/v1/auth/me` | Authenticated | Resolve current user profile, system role, and active session context |
| `POST` | `/api/v1/auth/forgot-password` · `/reset-password` | `Guest` | Request password reset link/OTP and set new password (`FR 3.2.4`) |
| `POST` | `/api/v1/auth/change-password` · `/change-password/send-otp` · `/change-password/otp` | Authenticated | Change current password (direct or OTP-verified, `FR 3.2.5`) |
| `POST` | `/api/v1/auth/set-password` · `/unlink/oauth` | Authenticated | Set password on OAuth-created account or unlink external OAuth provider |
| `POST` | `/api/v1/auth/link/phone` · `/verify-phone-otp` · `/unlink/phone` | Authenticated | Bind or remove verified phone number (`FR 3.2.6`) |
| `POST` | `/api/v1/auth/2fa/setup` · `/2fa/confirm` · `/2fa/verify` · `/2fa/disable` | Authenticated | Configure, verify, or disable TOTP Two-Factor Authentication (`FR 3.2.7`) |
| `GET` | `/api/v1/auth/sessions` | Authenticated | List active device refresh sessions (`user_refresh_tokens`) |
| `POST` | `/api/v1/auth/sessions/revoke-others` | Authenticated | Terminate all other active device sessions |
| `POST` | `/api/v1/auth/deactivate/send-otp` · `/deactivate` | `Owner`, `Manager`, `Creator`, `Client` | Self-deactivate user account after OTP confirmation (`FR 3.2.9`) |

---

## 2. Domain 3.3 — User Profile, Notifications & Client Profile

Controllers: `UserController`, `UserNotificationController`, `ClientProfileController`, `ProfileMatchingController` ([BA Spec](../ba/02-authentication-profile.md)).

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `PUT` | `/api/v1/users/me` | Authenticated | View (`FR 3.3.1`) and update (`FR 3.3.2`) personal profile |
| `POST` | `/api/v1/users/me/avatar` · `/me/banner` | Authenticated | Upload public profile avatar or cover banner (`s3://.../image/*`) |
| `GET` | `/api/v1/users/lookup` · `/me/completeness` | Authenticated | Lookup user by email for invitations; inspect profile completeness score |
| `GET` | `/api/v1/notifications/me` | Authenticated | List in-app inbox rows (`user_notifications`, pushed live via `/user/queue/notifications`) |
| `POST` | `/api/v1/notifications/me/{id}/read` · `/me/read-all` | Authenticated | Mark single or all in-app notifications as read |
| `GET` · `POST` | `/api/v1/client-profile/mine` · `/api/v1/client-profile` | `Owner`, `Manager`, `Client` | List reusable `Client` profiles or create a new `client_profiles` record (`FR 3.3.3`) |
| `GET` · `PUT` · `DELETE` | `/api/v1/client-profile/{profileId}` | `Owner`, `Manager`, `Client` | View (`FR 3.3.3`), update (`FR 3.3.4`, fixed email), or delete reusable `Client` profile |
| `POST` | `/api/v1/client-profile/logo` · `/{profileId}/logo` | `Owner`, `Manager`, `Client` | Upload draft or bound brand logo for a `Client` profile |

---

## 3. Domain 3.4 — Agency, Personal Studio & Workspace (`26` FRs)

Controllers: `AgencyController`, `WorkspaceController`, `WorkspaceTemplateController`, `DashboardAnalyticsController`, `AnalyticsController` ([BA Spec](../ba/03-agency-workspace.md)).

### 3.1 Agency & Personal Studio Endpoints (`/api/v1/agencies/**`)

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` | `/api/v1/agencies` | `Owner`, `Manager`, `Creator` | List joined companies or create a new `AGENCY` / `PERSONAL` company (`FR 3.4.1`–`3.4.2`) |
| `GET` · `PUT` · `DELETE` | `/api/v1/agencies/{agencyId}` | `Owner` (read: members) | View details (`FR 3.4.2`), update company profile (`FR 3.4.3`), or soft-delete company (`FR 3.4.4`) |
| `POST` | `/api/v1/agencies/{agencyId}/restore` | `Owner` | Restore soft-deleted Agency within retention grace window |
| `POST` | `/api/v1/agencies/{agencyId}/logo` · `/banner` | `Owner` | Upload Agency logo and banner |
| `GET` | `/api/v1/agencies/{agencyId}/stats` · `/workspace-members` | `Owner` | Cross-workspace Agency overview metrics & roster (`FR 3.4.5`) |
| `GET` · `DELETE` | `/api/v1/agencies/{agencyId}/members` · `/members/{memberId}` | `Owner` | List Agency members (`FR 3.4.6`) or remove non-`Owner` member (`FR 3.4.9`, capped at `1` on `PERSONAL`) |
| `GET` | `/api/v1/agencies/{agencyId}/members/{userId}/profile` · `/activity` | `Owner` | View member profile and cross-workspace contribution log |
| `GET` · `POST` · `DELETE` | `/api/v1/agencies/{agencyId}/invitations` · `/{invitationId}` | `Owner` | List, send (`FR 3.4.7`, 30-day token), or cancel Agency invitations |
| `GET` · `POST` | `/api/v1/agencies/invitations/{preview,my-pending,accept,decline}` | Authenticated | Preview, list, accept (`FR 3.4.8`), or decline pending Agency invitations |

### 3.2 Workspace, Templates & Role Dashboards (`/api/v1/workspaces/**`)

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` | `/api/v1/workspaces` · `/my-managed` | `Owner`, `Manager`, `Creator`, `Client` | List accessible workspaces (`FR 3.4.11`) or create a new Workspace (`Owner`, `FR 3.4.10`) |
| `POST` | `/api/v1/workspaces/personal/bootstrap` | `Owner` | One-click Personal Studio + default personal workspace bootstrap (`STUDIO_FREE`) |
| `GET` · `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}` · `/settings` | `Owner`, `Manager` (read: all members) | View workspace, update settings/timezone/report schedule (`FR 3.4.12`), or soft-delete (`Owner`, `FR 3.4.13`) |
| `POST` | `/api/v1/workspaces/{workspaceId}/restore` · `/logo` · `/banner` | `Owner`, `Manager` | Restore deleted workspace (`Owner`) or upload workspace branding |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/duplicate-options` · `/duplicate` | `Owner` | Clone workspace structure, templates, and settings (`FR 3.4.25`) |
| `GET` | `/api/v1/workspaces/{workspaceId}/dashboard` | `Owner`, `Manager`, `Creator`, `Client` | Role-tailored workspace operational dashboard (`FR 3.4.26`) |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/members` · `/members/invite` · `/members/assign` | `Owner`, `Manager` | View workspace roster (`FR 3.4.14`), invite external user (`FR 3.4.15`), or assign existing Agency member |
| `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}/members/{memberId}/role` · `/members/{memberId}` · `/leave` | `Owner`, `Manager`, Member | Update workspace role (`MANAGER` \| `CREATOR`, `FR 3.4.17`), remove member (`FR 3.4.18`), or leave (`BR-19` >= 1 active `Manager`) |
| `POST` · `PATCH` | `/api/v1/workspaces/{workspaceId}/clients` · `/clients/me` | `Owner`, `Manager`, `Client` | Attach `Client` profile to workspace (`FR 3.4.19`) or switch active `Client` persona |
| `GET` · `POST` | `/api/v1/workspaces/invitations/{my-pending,accept,decline}` | Authenticated | List, accept (`FR 3.4.16`), or decline workspace invitations |
| `GET` · `POST` · `DELETE` | `/api/v1/workspace-templates` · `/{templateId}` · `/{templateId}/apply/{workspaceId}` · `/global` | `Owner`, `Manager`, `Admin` (`/global`) | Save, list, apply, or delete reusable Workspace Templates (`FR 3.4.20`–`3.4.24`) |
| `GET` | `/api/v1/analytics/{overview,me,me/overview,me/items}` · `/agencies/{id}{,/overview,/items,/export.xlsx}` · `/workspaces/{id}{,/overview,/items}` | `Owner`, `Manager`, `Creator`, `Client` | Personal, workspace, and cross-workspace Agency analytics + Excel export |

---

## 4. Domain 3.5 — Media Package, Media Campaign & Content Requests (`13` FRs)

Controllers: `MediaPackageController`, `WorkspacePackagePlanningController`, `PackageNegotiationHistoryController`, `MediaPackageShareController`, `MediaCampaignController`, `WorkspaceCampaignController`, `CampaignTimelineController`, `CampaignCollaboratorController`, `CampaignClosureController`, `ContentRequestController`, `ContentRequestReviewController` ([BA Spec](../ba/04-media-package-campaign.md)).

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` | `/api/v1/media-package-templates` · `/api/v1/workspaces/{workspaceId}/media-packages` | `Owner`, `Manager`, `Client` | Browse `Admin` global templates and workspace-eligible Media Packages (`FR 3.5.1`) |
| `GET` · `POST` · `PATCH` | `/api/v1/agencies/{agencyId}/media-package-custom` · `/media-packages/{packageId}/availability` | `Owner`, `Manager` | Create custom Agency/Workspace Media Package (`offering_details JSONB`, `FR 3.5.2`) and toggle availability |
| `GET` · `POST` · `PUT` | `/api/v1/workspaces/{workspaceId}/media-package` | `Owner`, `Manager`, `Client` | Select, inspect, or save `Manager`-led workspace Media Package configuration |
| `PATCH` · `POST` · `GET` | `/api/v1/workspaces/{workspaceId}/media-package/negotiate` · `/approve` · `/history` | `Owner`, `Manager`, `Client` | Negotiate terms (resets counterparty approval atomically, `FR 3.5.3`), dual-party approve (`FR 3.5.4`), and audit history |
| `POST` · `GET` | `/api/v1/workspaces/{workspaceId}/media-package/impact` · `/preparation` · `/preparation/retry` | `Owner`, `Manager` | Preview package change impact and track automated campaign/task preparation |
| `GET` | `/api/v1/public/media-packages/{token}` | `Guest` | Controlled read-only `Guest` share link for Media Package presentation |
| `GET` · `PATCH` | `/api/v1/workspaces/{workspaceId}/campaigns` · `/{campaignId}` · `/{campaignId}/brief` | `Owner`, `Manager`, `Creator`, `Client` | List/view Media Campaigns (`FR 3.5.5`), update deliverables (`FR 3.5.6`), and edit strategy brief |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/feedback` · `/versions` · `/approve` | `Owner`, `Manager`, `Client` | Submit review feedback (`FR 3.5.7`), inspect `campaign_versions`, and dual-approve campaign (`FR 3.5.8`) |
| `POST` · `GET` | `/api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/deploy` · `/deployment` · `/undeploy` · `/complete` · `/completion-check` | `Owner`, `Manager` | Materialize approved campaign items into MongoDB `tasks` (`campaign_deployments`, `FR 3.5.9`) and close completed campaigns |
| `GET` · `POST` · `PUT` | `/api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/timeline` · `/timeline/tasks` · `/timeline/reorder-tasks` | `Owner`, `Manager`, `Creator` | Manage Gantt/timeline dates and task ordering |
| `GET` · `POST` · `PUT` · `DELETE` | `/api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/collaborators` · `/{linkId}` | `Owner`, `Manager` | Link/update/unlink external partners (`campaign_collaborators`) on a campaign |
| `POST` · `GET` · `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}/content-requests` · `/{requestId}` | `Client` (create/edit/cancel), `Owner`, `Manager` | Create (`FR 3.5.10`), list/view (`FR 3.5.11`), update, or cancel (`PENDING`) `Client` Content Requests |
| `POST` · `GET` | `/api/v1/workspaces/{workspaceId}/content-requests/{requestId}/{receive,accept,deny,task}` | `Owner`, `Manager` | Transition `PENDING -> IN_PROGRESS -> ACCEPTED / DENIED` (`FR 3.5.12`–`3.5.13`) and spawn linked `Task` |

---

## 5. Domain 3.6 — Content, Task Workflow, Repository, Vault, Surveys, Mail, Video Space & Chat (`35` FRs)

Controllers: `Task*Controller`, `Material*Controller`, `CustomerDrive*Controller`, `RepositoryEncryptedMediaController`, `ClientVaultController`, `WatermarkPresetController`, `HashtagController`, `SurveyController`, `PublicSurveyController`, `Mail*Controller`, `PublicMailController`, `Video*Controller`, `WorkspaceReferenceController`, `Chat*Controller` ([BA Spec](../ba/05-content-task-workflow.md)).

### 5.1 Tasks, Subtasks, Role Sections & 3-Tier Approval (`/api/v1/workspaces/{workspaceId}/tasks/**`)

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` · `DELETE` | `/api/v1/workspaces/{workspaceId}/tasks` · `/standalone` · `/{taskId}` | `Owner`, `Manager`, `Creator`, `Client` | List/filter backlog (`FR 3.6.1`), create campaign or standalone `Task` (`FR 3.6.2`), view detail, or delete (`FR 3.6.4`) |
| `GET` | `/api/v1/task-catalog/{taskType}` | Authenticated | Fetch schema/section metadata for `POST`, `SURVEY`, `SHORT_VIDEO`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER` |
| `POST` · `PATCH` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/{assign,start,status,priority,assignee,detail,field,partners,schedule}` | `Owner`, `Manager`, `Creator` | Assign `Creator` & optional QC `Creator` (`FR 3.6.3`), start work, update status/priority/fields, and attach partner contacts |
| `GET` · `POST` · `PATCH` · `PUT` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/subtasks` · `/{id}` · `/{id}/status` · `/reorder` | `Owner`, `Manager`, `Creator` | CRUD, status transitions, and ordering for role-tagged subtasks |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/content` · `/content/snapshot` · `/content/versions` · `/content/versions/{snapshotId}{,/restore}` | `Owner`, `Manager`, `Creator`, `Client` | Read/snapshot Yjs collaborative rich-text content (`FR 3.6.10`) and browse/restore immutable version snapshots (`FR 3.6.34`) |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/review` · `/approvals` · `/submit` · `/withdraw` · `/approve` · `/reject` · `/self-approve` | `Creator`, `Manager`, `Client`, `Owner` | Execute 3-tier approval sequence (`Creator -> [QC] -> Manager -> Client`, `FR 3.6.5`–`3.6.9`; rejection requires reason & resets to `Creator` keeping append-only `task_approvals`) |
| `GET` · `PATCH` · `POST` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/sections` · `/{sectionKey}` · `/{sectionKey}/{submit,approve,return,reopen,versions,restore/{versionNo}}` | `Manager`, `Creator`, `Client` | Multi-role Task Section authoring, per-section approval/return, and version history (`DA-1274`) |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/comments` · `/comment-uploads` · `/comment-uploads/{uploadId}/content` | `Owner`, `Manager`, `Creator`, `Client` | Threaded task comments with `@mentions` and image/file attachments |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/post` · `/export` | `Owner`, `Manager`, `Creator`, `Client` | Bind social post draft to `Task` or export deliverable (`PDF`/`DOCX`/`TXT`, `FR 3.7.12`) |

### 5.2 Encrypted Material Repository, Google Drive, Client Vault, Watermarks & Moodboard

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` · `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}/materials` · `/browser` · `/brand-assets` · `/{materialId}` · `/{materialId}/{move,promote,preview,download,restore,purge,watermark}` · `/trash/purge` · `/storage-usage` | `Owner`, `Manager`, `Creator`, `Client` | Browse/upload/tag RAW vs Retouched & Brand Reference assets (`FR 3.6.11`–`3.6.17`), apply watermark (`FR 3.6.18`), soft-delete/restore/purge (`FR 3.6.14`), and inspect quota |
| `POST` · `DELETE` | `/api/v1/workspaces/{workspaceId}/materials/upload-session` · `/multipart` · `/{sessionId}/parts` · `/confirm` · `/{sessionId}` | `Owner`, `Manager`, `Creator` | Bounded multipart/streaming upload sessions backed by `agency_storage_reservations` |
| `POST` · `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}/materials/folders` · `/folders/{folderId}{,/move,/restore,/purge}` | `Owner`, `Manager`, `Creator` | Hierarchical folder CRUD and trash recovery (`material_folders`) |
| `GET` · `POST` · `DELETE` | `/api/v1/workspaces/{workspaceId}/materials/{materialId}/versions` · `/{versionId}/{download,restore}` · `/{versionId}` | `Owner`, `Manager`, `Creator` | Multi-version asset history and rollback (`material_versions`) |
| `PUT` · `GET` | `/api/v1/repository-media` · `/api/v1/repository-drive/media` | Capability Token | Streaming `RepositoryEnvelopeCrypto` (`aws-esdk-v1`) upload/download endpoints (`Range` supported) |
| `GET` · `POST` · `DELETE` | `/api/v1/workspaces/{workspace}/storage/drive{,/authorize,/complete}` · `/materials/drive-import{,/config,/{jobId},/{jobId}/cancel}` | `Owner`, `Manager` | Connect Google Drive OAuth and run asynchronous folder imports (`FR 3.6.19`) |
| `GET` · `POST` · `PATCH` · `DELETE` | `/api/v1/client-vault/{browser,storage-usage,folders,folders/{id},folders/{id}/move,folders/{id}/restore}` · `/api/v1/workspaces/{workspaceId}/client-vault/{browser,shares,shares/{shareId}}` | `Client`, `Manager`, `Owner` | Personal `Client` Vault storage management and controlled workspace asset sharing (`client_vault_shares`) |
| `GET` · `POST` · `PUT` · `DELETE` | `/api/v1/workspaces/{workspaceId}/watermark-presets` · `/{presetId}` · `/{presetId}/set-default` | `Owner`, `Manager`, `Creator` | Manage workspace watermark presets (`FR 3.6.18`) |
| `GET` · `POST` · `PATCH` · `PUT` · `DELETE` | `/api/v1/workspaces/{workspaceId}/hashtags` · `/{hashtagId}` | `Owner`, `Manager`, `Creator` | Workspace hashtag bank CRUD (`FR 3.6.20`–`3.6.24`) |
| `GET` · `POST` · `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}/references/{recommend,unfurl,moodboard,moodboard/{itemId}}` | `Owner`, `Manager`, `Creator`, `Client` | AI reference recommendations, link unfurling, and collaborative workspace moodboard |

### 5.3 Surveys, Outbound Mail / Newsletters, Video Space & Realtime Chat

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/survey` · `/survey/analysis` · `/api/v1/workspaces/{workspaceId}/surveys` | `Owner`, `Manager`, `Creator`, `Client` | Author/publish task survey (`FR 3.6.25`) and view aggregated response analytics (`FR 3.6.27`) |
| `GET` · `POST` | `/api/v1/public/surveys/{token}` · `/{token}/submit` | `Guest` | Public token-gated survey rendering and high-throughput submission (`FR 3.6.26`) |
| `GET` · `POST` · `PATCH` · `DELETE` | `/api/v1/workspaces/{workspaceId}/mail-templates` · `/{templateId}` · `/{templateId}/{preview,send,send-test}` · `/attachments` · `/images` | `Owner`, `Manager`, `Creator` | Workspace email template CRUD, preview, and test/batch dispatch (`FR 3.6.28`–`3.6.32`) |
| `GET` · `POST` · `DELETE` | `/api/v1/workspaces/{workspaceId}/{mail-recipients,mail-recipient-groups,mail-quota,mail-suppressions,mail-batches}` · `/tasks/{taskId}/newsletter/{send,send-test,report}` | `Owner`, `Manager`, `Creator` | Recipient groups, daily quota check, suppression list, batch delivery CSV export, and Newsletter task dispatch |
| `GET` · `POST` | `/api/v1/public/mail/unsubscribe` | `Guest` | RFC one-click / footer unsubscribe endpoint updating `mail_suppressions` |
| `GET` · `PUT` · `POST` | `/api/v1/workspaces/{workspaceId}/video-projects` · `/{projectId}` · `/{projectId}/edit-plans` · `/{projectId}/media/{assetId}{,/upload-session,/upload-complete,/upload-abort}` · `/{projectId}/auto-edits{,/{jobId},/{jobId}/content}` · `/{projectId}/auto-edit-memory` | `Owner`, `Manager`, `Creator` | Video Space timeline projects, S3 media upload sessions, and AI server auto-editing |
| `GET` · `POST` · `PATCH` · `PUT` · `DELETE` | `/api/v1/workspaces/{workspaceId}/chat/{channels,messages,read,unread-count,preferences,scheduled-messages,calls}` (+ `/channels/{channelId}/{messages,attachments,reactions,pin,read,members}`) | `Owner`, `Manager`, `Creator`, `Client` | Multi-channel workspace chat (`FR 3.6.35`), file/repository attachments, reactions, pins, scheduled messages, DND preferences, and Agora voice/video calls |

---

## 6. Domain 3.7 — AI Features & Third-Party Collaborators (`19` FRs)

Controllers: `AiCaptionController`, `AiGenerationController`, `AiVideoController`, `ProductVideoController`, `WorkspaceTrendController`, `AiTrendController`, `CollaboratorController`, `DirectoryPartnerController` ([BA Spec](../ba/06-ai-features.md)).

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` | `/api/v1/workspaces/{workspaceId}/trends` · `/trends/matrix` · `/trends/history` · `/api/v1/ai/trending-topics{,/boards/{source}}` | `Owner`, `Manager`, `Creator`, `Client` | Discover trending topics, platform boards, and Knowledge Graph insights (`FR 3.7.1`–`3.7.2`) |
| `POST` | `/api/v1/workspaces/{workspaceId}/ai/captions` · `/captions/refine` · `/captions/adapt` · `/captions/{generationId}/choice` · `/captions/moderate` | `Owner`, `Manager`, `Creator` | 3-variant Brand Hybrid GraphRAG caption generation (`HOOK_DRIVEN`, `STORYTELLING`, `DIRECT_CTA`, `FR 3.7.6`), refinement, platform adaptation, choice tracking, and compliance check (`FR 3.6.33`) |
| `GET` | `/api/v1/workspaces/{workspaceId}/ai/trend-fit` · `/ai/credits` | `Owner`, `Manager`, `Creator` | Score workspace brand-trend fit and query remaining workspace AI credit budget |
| `POST` | `/api/v1/ai/content/generate` · `/api/v1/ai/content/hashtags` · `/api/v1/ai/content/captions/generate` | `Owner`, `Manager`, `Creator` | Quick editor AI post generation and hashtag trend suggestions (`FR 3.7.6`, `FR 3.7.14`) |
| `GET` · `POST` | `/api/v1/ai/ambassadors/presets` · `/ambassadors/generate` · `/ambassadors/character-sheet` | `Owner`, `Manager`, `Creator` | List presets and generate Virtual Brand Ambassador portraits & 3-angle character sheets (`FR 3.7.7`) |
| `POST` | `/api/v1/ai/image/commercial/generate` | `Owner`, `Manager`, `Creator` | Generate commercial advertising imagery combining Ambassador, Product, and Style Preset (`FR 3.7.8`–`3.7.9`) |
| `GET` · `POST` | `/api/v1/workspaces/{workspaceId}/ai/video-styles` · `/ai/videos` · `/ai/videos/{jobId}{,/content}` · `/api/v1/ai/video/{generate,{jobId}/status}` | `Owner`, `Manager`, `Creator` | Browse video style templates (`FR 3.7.10`) and run 15–20s **Wan 2.2 Fun VACE 14B** video generation jobs (`FR 3.7.11`) |
| `POST` · `GET` | `/api/v1/workspaces/{workspaceId}/ai/video-productions/plan` · `/{id}` · `/{id}/generate` · `/{id}/scenes/{sceneId}/retry` · `/{id}/render-retry` · `/{id}/{editing-bundle,content}` | `Owner`, `Manager`, `Creator` | Durable multi-scene Product Video Production coordinator (`product_video_*`) with per-scene retry and Video Space handoff |
| `GET` · `POST` · `PATCH` · `PUT` · `DELETE` | `/api/v1/agencies/{agencyId}/collaborators{,/{id},/{id}/deactivate,/recommend}` · `/api/v1/collaborators{,/agencies/{agencyId},/agencies/{agencyId}/recommend,/assign,/campaign/{id}/cooperation}` | `Owner`, `Manager` | Third-party collaborator directory (KOL/KOC, Press, Banner, TV — `FR 3.7.15`–`3.7.18`) and AI partner recommendation (`FR 3.7.19`) |

---

## 7. Domain 3.8 — Social Accounts & Multi-Platform Publishing (`15` FRs)

Controllers: `SocialAccountController`, `PostController`, `PostTemplateController` (`business-service`), plus `SocialOAuthController` (`publisher-service` `:8083`) ([BA Spec](../ba/07-publishing-social.md)). Supported platforms are strictly **Facebook, Instagram, TikTok, and Threads**.

| Service | Method | Path | Actors | Description & SRS Alignment |
| :---: | :---: | :--- | :--- | :--- |
| `publisher` | `POST` | `/api/v1/social/{platform}/connect-url` | `Owner`, `Manager` | Issue OAuth authorization URL + `bh_oauth_state` cookie + `60s` single-use browser ticket (`FR 3.8.1`) |
| `publisher` | `GET` | `/api/v1/social/{platform}/authorize` · `/{platform}/callback` | `Guest` (Ticket/Cookie) | Browser handoff and OAuth code exchange for `facebook`, `instagram`, `tiktok`, `threads`; encrypts token (`AES-256-GCM`) and syncs to `business-service` |
| `publisher` | `GET` · `POST` | `/api/v1/social/accounts/status` · `/tokens/refresh` · `/tokens/revoke` | `Owner`, `Manager` | Inspect live token health, trigger manual token refresh (`FR 3.8.3`), or revoke platform grant |
| `business` | `GET` · `DELETE` | `/api/v1/social-accounts` · `/api/v1/social-accounts/{id}` | `Owner`, `Manager`, `Creator`, `Client` | List connected workspace social accounts (`FR 3.8.2`) or disconnect account (`FR 3.8.4`) |
| `business` | `GET` · `POST` · `PATCH` | `/api/v1/workspaces/{workspaceId}/posts` · `/{postId}` · `/{postId}/{detail,status,comments}` · `/dashboard` · `/schedule` · `/recommended-times` | `Owner`, `Manager`, `Creator`, `Client` | Create/update social post drafts, view publishing calendar & optimal times, and track live status (`FR 3.8.5`–`3.8.7`) |
| `business` | `PATCH` · `POST` | `/api/v1/workspaces/{workspaceId}/posts/{postId}/reschedule` · `/submit` · `/publish` | `Owner`, `Manager`, `Creator` | Schedule, reschedule, or enqueue immediate RabbitMQ publish across Facebook, Instagram, TikTok, and Threads (`FR 3.8.6`, `FR 3.8.8`–`3.8.15`) |
| `business` | `GET` · `POST` · `DELETE` | `/api/v1/workspaces/{workspaceId}/post-templates` · `/{templateId}` | `Owner`, `Manager`, `Creator` | Manage reusable workspace social post templates (`workspace_post_templates`) |

---

## 8. Domain 3.9 — Subscription, SePay (VietQR) Billing, Credits & Storage Add-Ons (`6` FRs)

Controllers: `PublicBillingPlanController`, `BillingPlanController`, `SubscriptionController`, `BillingController`, `InvoiceHistoryController`, `CreditBalanceController`, `CreditUsageController`, `AgencyCreditConfigurationController`, `WorkspaceCreditController`, `CreditPriceController`, `StorageAddonController` ([BA Spec](../ba/08-subscription-billing.md)).

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` | `/api/v1/public/billing/plans` · `/api/v1/billing/plans` · `/api/v1/subscription/plans` | `Guest`, Authenticated | Public & authenticated pricing catalog for all 6 active plans (`STUDIO_FREE/PLUS/PRO`, `BASIC/PLUS/ENTERPRISE`) + 3/6/12-month cycle discounts |
| `GET` · `POST` | `/api/v1/billing/agencies/{agencyId}/subscription` · `/upgrade-quote` · `/orders` · `/orders/{orderId}` | `Owner` | View active Agency/Studio subscription (`FR 3.9.3`), preview prorated upgrade quote (`FR 3.9.1`, upgrade-only), and create **SePay (VietQR)** order (`FR 3.9.2`) |
| `POST` | `/api/v1/billing/webhooks/sepay` | SePay Webhook | Idempotent SePay bank-transfer webhook verifying API key/signature, marking `billing_orders` `PAID`, and fulfilling plan/credit entitlements (`FR 3.9.2`) |
| `GET` | `/api/v1/billing/agencies/{agencyId}/invoices` · `/{orderId}` · `/{orderId}/receipt` · `/{orderId}/sepay-transactions` · `/api/v1/billing/transactions{,/{id}}` | `Owner` | View billing history, downloadable payment receipts, and SePay transaction reconciliation (`FR 3.9.3`) |
| `POST` · `GET` | `/api/v1/billing/agencies/{agencyId}/credits/orders` · `/credits/summary` · `/api/v1/billing/credits/buy` · `/api/v1/credit/prices` | `Owner`, `Manager` | Purchase top-up AI credit packs via SePay (`FR 3.9.4`), inspect wallet grants (`FR 3.9.5`), and view per-operation AI credit unit prices |
| `GET` · `PUT` | `/api/v1/agencies/{agencyId}/credit/{balance,policy,usage/me,members/me,members/{memberId}/limit,members/{memberId}/usage,workspaces,workspaces/{workspaceId}/limit}` | `Owner`, `Manager`, `Creator` | Configure Agency credit policy and set monthly AI credit caps per Workspace / member (`FR 3.9.6 Set Credit`) |
| `GET` · `POST` | `/api/v1/storage/addons` · `/addons/checkout` · `/addons/orders/{orderId}` | `Owner`, `Client` | Purchase recurring S3 storage add-on packs (`storage_addon_plans`) for Agency Repository or `Client` Personal Vault |

---

## 9. Domain 3.10 — Platform Admin Governance, Backups & System Monitoring (`14` FRs)

Controllers: `Admin*Controller`, `CreditPriceImportController`, `SubscriptionOperationsController`, `Monitoring*Controller` ([BA Spec](../ba/09-admin-functions.md)).

| Method | Path | Actors | Description & SRS Alignment |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` · `PATCH` | `/api/v1/admin/users` · `/{userId}` · `/{userId}/{status,activation,violations,sanction}` | `Admin` | List/create/inspect users, manage strikes & sanctions, and activate/suspend non-`Admin` accounts (`FR 3.10.1`–`3.10.2`) |
| `GET` · `POST` · `DELETE` | `/api/monitoring/{enrollments,servers,servers/{id},health-targets}` (+ machine POST `/api/monitoring/{register,heartbeat,collectors/heartbeat,health-results}`) | `Admin` / Collector Agent | Infrastructure & service health monitoring across EC2 hosts and MongoDB `monitoring_*` (`FR 3.10.3`) |
| `GET` · `POST` | `/api/v1/admin/moderation` · `/{id}` · `/{id}/decision` | `Admin` | Review flagged content moderation queue and issue approve/block/strike decisions (`FR 3.10.4`) |
| `GET` · `PUT` · `POST` | `/api/v1/admin/billing/plans` · `/{code}` · `/{code}/sale` · `/{code}/history` · `/api/v1/admin/billing/{invoices,operations/issues,operations/status,operations/reconcile}` | `Admin` | Edit immutable subscription plan catalog (`billing_plan_change_log`, `FR 3.10.5`–`3.10.6`), audit invoices, and reconcile subscriptions |
| `GET` · `POST` | `/api/v1/admin/statistics` · `/api/v1/admin/revenue` · `/api/v1/admin/reports` · `/reports/{id}/file` | `Admin` | Platform-wide KPIs, SePay revenue analytics, and downloadable administrative reports (`FR 3.10.7`–`3.10.9`) |
| `PUT` · `POST` | `/api/v1/admin/credit/prices/{operation}` · `/prices/import/preview` · `/prices/import/apply` | `Admin` | Configure and bulk-import `ai_credit_operation_prices` (`FR 3.10.10`–`3.10.12`) |
| `GET` · `POST` · `PUT` | `/api/v1/admin/notifications` · `/plans` · `/audience-count` · `/{id}` · `/{id}/cancel` | `Admin` | Broadcast or schedule system-wide / plan-targeted notifications (`FR 3.10.13`) |
| `GET` · `PATCH` · `POST` · `PUT` | `/api/v1/admin/ai/{crawl-config,crawl-runs,crawl-cookie,trends,trend-graph/**,trend-pipeline/**,trend-replays/**}` | `Admin` | Configure social trend crawler schedules (`FR 3.7.13`, `FR 3.10.14`), upload session cookies, inspect Neo4j Trend Graph, and run replays |
| `GET` · `POST` | `/api/v1/admin/backups/status` · `/backups/run` · `/backups/restore` | `Admin` | Inspect 30-day S3 backup history, trigger immediate dumps, or run point-in-time restores via `db-backup` (`:8090`) |
| `GET` · `POST` · `PATCH` · `DELETE` | `/api/v1/admin/{mail-templates,mail-batches,mail-suppressions,client-reports/{workspaceId}/send}` | `Admin` | Manage system-wide engagement mail templates (`M1`–`M5`), mail batches, and scheduled `Client` PDF report dispatches |

---

## 10. STOMP over WebSocket Endpoints (`WebSocketConfig.java`)

| Handshake Path | Auth Mechanism | Client Publish (`@MessageMapping`) | Broker Subscriptions (`/topic`, `/user/queue`) | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `/ws/tasks` | `WsJwtHandshakeInterceptor` (`16 KB` frame limit) | `/app/tasks/{taskId}/content`<br>`/app/tasks/{taskId}/awareness` | `/topic/tasks/{taskId}/content`<br>`/topic/tasks/{taskId}/awareness` | Real-time Yjs CRDT collaborative task editing (`FR 3.6.10`) with sequence numbers persisted in `task_content_operations` + ephemeral cursor awareness |
| `/ws/chat` | `ChatInboundChannelInterceptor` (STOMP `CONNECT` JWT) | `/app/workspaces/{workspaceId}/chat.send` | `/topic/workspaces/{workspaceId}/chat/**`<br>`/user/queue/notifications` | Workspace real-time chat (`FR 3.6.35`), call signaling, and instant in-app notification pushes triggered by PostgreSQL `LISTEN user_notification` |

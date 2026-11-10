# Feature docs — mục lục theo FR

Tổ chức: domain → FR chuẩn (141 FR) → tính năng mở rộng. Quy tắc: [`docs/rule/feature-workflow.md`](../rule/feature-workflow.md).
Danh sách FR chuẩn: `brandhub-docs-portal/src/data/frs/domain-*.json`. File này sinh tự động, cập nhật khi thêm thư mục.

## 3.2 Authentication & Authorization — [`3-2-authentication/`](3-2-authentication/)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.2.1 | [Sign Up](3-2-authentication/3-2-1-sign-up/) |  |
| 3.2.2 | [Sign In with Email](3-2-authentication/3-2-2-sign-in-with-email/) |  |
| 3.2.3 | [Sign In with Google OAuth](3-2-authentication/3-2-3-sign-in-with-google-oauth/) |  |
| 3.2.4 | [Reset Password](3-2-authentication/3-2-4-reset-password/) |  |
| 3.2.5 | [Change Password](3-2-authentication/3-2-5-change-password/) |  |
| 3.2.6 | [OTP Verification](3-2-authentication/3-2-6-otp-verification/) |  |
| 3.2.7 | [Two-Factor Authentication (2FA, TOTP)](3-2-authentication/3-2-7-two-factor-authentication-2fa-totp/) |  |
| 3.2.8 | [Logout](3-2-authentication/3-2-8-logout/) |  |
| 3.2.9 | [Delete Account](3-2-authentication/3-2-9-delete-account/) |  |

## 3.3 User & Client Profile — [`3-3-profile/`](3-3-profile/)

Tài liệu chung: [report4_class_diagram_3_3.puml](3-3-profile/report4_class_diagram_3_3.puml)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.3.1 | [View User Profile](3-3-profile/3-3-1-view-user-profile/) |  |
| 3.3.2 | [Update User Profile](3-3-profile/3-3-2-update-user-profile/) |  |
| 3.3.3 | [View Client Profile](3-3-profile/3-3-3-view-client-profile/) |  |
| 3.3.4 | [Update Client Profile](3-3-profile/3-3-4-update-client-profile/) |  |

## 3.4 Agency & Workspace — [`3-4-agency-workspace/`](3-4-agency-workspace/)

Tài liệu chung: [report4_class_diagram_3_4.puml](3-4-agency-workspace/report4_class_diagram_3_4.puml)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.4.1 | [List Agency](3-4-agency-workspace/3-4-1-list-agency/) |  |
| 3.4.2 | [View Agency Dashboard](3-4-agency-workspace/3-4-2-view-agency-dashboard/) |  |
| 3.4.3 | [Create Agency](3-4-agency-workspace/3-4-3-create-agency/) | [personal-agency-transition](3-4-agency-workspace/3-4-3-create-agency/personal-agency-transition/) |
| 3.4.4 | [View Agency Profile](3-4-agency-workspace/3-4-4-view-agency-profile/) |  |
| 3.4.5 | [Update Agency Profile](3-4-agency-workspace/3-4-5-update-agency-profile/) |  |
| 3.4.6 | [Remove Agency](3-4-agency-workspace/3-4-6-remove-agency/) |  |
| 3.4.7 | [Invite Agency Member](3-4-agency-workspace/3-4-7-invite-agency-member/) |  |
| 3.4.8 | [View Agency Invitation Status](3-4-agency-workspace/3-4-8-view-agency-invitation-status/) |  |
| 3.4.9 | [Accept Agency Invitation](3-4-agency-workspace/3-4-9-accept-agency-invitation/) |  |
| 3.4.10 | [Decline Agency Invitation](3-4-agency-workspace/3-4-10-decline-agency-invitation/) |  |
| 3.4.11 | [Remove Agency Member](3-4-agency-workspace/3-4-11-remove-agency-member/) |  |
| 3.4.12 | [List Workspace](3-4-agency-workspace/3-4-12-list-workspace/) |  |
| 3.4.13 | [View Workspace Dashboard](3-4-agency-workspace/3-4-13-view-workspace-dashboard/) | [media-workspace-ux](3-4-agency-workspace/3-4-13-view-workspace-dashboard/media-workspace-ux/) |
| 3.4.14 | [Create Workspace](3-4-agency-workspace/3-4-14-create-workspace/) | [duplicate-workspace](3-4-agency-workspace/3-4-14-create-workspace/duplicate-workspace/) |
| 3.4.15 | [View Workspace Profile](3-4-agency-workspace/3-4-15-view-workspace-profile/) |  |
| 3.4.16 | [Update Workspace Profile](3-4-agency-workspace/3-4-16-update-workspace-profile/) | [workspace-timezone-consistency](3-4-agency-workspace/3-4-16-update-workspace-profile/workspace-timezone-consistency/) |
| 3.4.17 | [Delete Workspace](3-4-agency-workspace/3-4-17-delete-workspace/) |  |
| 3.4.18 | [Leave Workspace](3-4-agency-workspace/3-4-18-leave-workspace/) |  |
| 3.4.19 | [Save Workspace Template](3-4-agency-workspace/3-4-19-save-workspace-template/) |  |
| 3.4.20 | [View Workspace Templates](3-4-agency-workspace/3-4-20-view-workspace-templates/) |  |
| 3.4.21 | [Apply Workspace Template](3-4-agency-workspace/3-4-21-apply-workspace-template/) |  |
| 3.4.22 | [Delete Workspace Template](3-4-agency-workspace/3-4-22-delete-workspace-template/) |  |
| 3.4.23 | [View Workspace Members](3-4-agency-workspace/3-4-23-view-workspace-members/) |  |
| 3.4.24 | [Add Workspace Member](3-4-agency-workspace/3-4-24-add-workspace-member/) |  |
| 3.4.25 | [Update Workspace Member Role](3-4-agency-workspace/3-4-25-update-workspace-member-role/) |  |
| 3.4.26 | [Remove Workspace Member](3-4-agency-workspace/3-4-26-remove-workspace-member/) |  |

## 3.5 Media Package & Media Campaign — [`3-5-media-package-campaign/`](3-5-media-package-campaign/)

Tài liệu chung: [README.md](3-5-media-package-campaign/README.md), [campaign-cleanup-proposal.md](3-5-media-package-campaign/campaign-cleanup-proposal.md), [campaign-delivery-plan.md](3-5-media-package-campaign/campaign-delivery-plan.md), [class-diagram.md](3-5-media-package-campaign/class-diagram.md), [implementation-roadmap.md](3-5-media-package-campaign/implementation-roadmap.md), [test-setup.md](3-5-media-package-campaign/test-setup.md)

Thư mục chung: [phase-1-design](3-5-media-package-campaign/phase-1-design/), [remaining-work](3-5-media-package-campaign/remaining-work/)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.5.1 | [Create Media Package](3-5-media-package-campaign/3-5-1-create-media-package/) | [offering-models](3-5-media-package-campaign/3-5-1-create-media-package/offering-models/), [package-quantity-input](3-5-media-package-campaign/3-5-1-create-media-package/package-quantity-input/), [package-simplification](3-5-media-package-campaign/3-5-1-create-media-package/package-simplification/) |
| 3.5.2 | [View Template Media Package](3-5-media-package-campaign/3-5-2-view-template-media-package/) |  |
| 3.5.3 | [Request Media Package](3-5-media-package-campaign/3-5-3-request-media-package/) |  |
| 3.5.4 | [Approve Media Package](3-5-media-package-campaign/3-5-4-approve-media-package/) |  |
| 3.5.5 | [Create Media Campaign](3-5-media-package-campaign/3-5-5-create-media-campaign/) | [package-driven-campaign-tasks](3-5-media-package-campaign/3-5-5-create-media-campaign/package-driven-campaign-tasks/) |
| 3.5.6 | [View Media Campaign](3-5-media-package-campaign/3-5-6-view-media-campaign/) | [campaign-navigation-corrections](3-5-media-package-campaign/3-5-6-view-media-campaign/campaign-navigation-corrections/), [campaign-task-ux](3-5-media-package-campaign/3-5-6-view-media-campaign/campaign-task-ux/), [guest-sharing-manager-led](3-5-media-package-campaign/3-5-6-view-media-campaign/guest-sharing-manager-led/), [ui-refresh](3-5-media-package-campaign/3-5-6-view-media-campaign/ui-refresh/), [workspace-campaign-summary](3-5-media-package-campaign/3-5-6-view-media-campaign/workspace-campaign-summary/) |
| 3.5.7 | [Update Media Campaign](3-5-media-package-campaign/3-5-7-update-media-campaign/) | [campaign-collaborators](3-5-media-package-campaign/3-5-7-update-media-campaign/campaign-collaborators/) |
| 3.5.8 | [Approve Media Campaign](3-5-media-package-campaign/3-5-8-approve-media-campaign/) |  |
| 3.5.9 | [Complete Media Campaign](3-5-media-package-campaign/3-5-9-complete-media-campaign/) | [campaign-closure](3-5-media-package-campaign/3-5-9-complete-media-campaign/campaign-closure/) |
| 3.5.10 | [Create Content Request](3-5-media-package-campaign/3-5-10-create-content-request/) |  |
| 3.5.11 | [Track Request Status](3-5-media-package-campaign/3-5-11-track-request-status/) | [request-completion-validation](3-5-media-package-campaign/3-5-11-track-request-status/request-completion-validation/) |
| 3.5.12 | [Update Request](3-5-media-package-campaign/3-5-12-update-request/) |  |
| 3.5.13 | [Cancel Request](3-5-media-package-campaign/3-5-13-cancel-request/) |  |

## 3.6 Content & Workflow — [`3-6-content-task-workflow/`](3-6-content-task-workflow/)

Tài liệu chung: [task-comments-implementation-2026-10-17.md](3-6-content-task-workflow/task-comments-implementation-2026-10-17.md), [task-detail-assignment-comments-roadmap.md](3-6-content-task-workflow/task-detail-assignment-comments-roadmap.md), [task-workflow-contract.md](3-6-content-task-workflow/task-workflow-contract.md), [task-workflow-phase-1.md](3-6-content-task-workflow/task-workflow-phase-1.md), [task-workflow-phase-2-3.md](3-6-content-task-workflow/task-workflow-phase-2-3.md)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.6.1 | [Identify Task Detail](3-6-content-task-workflow/3-6-1-identify-task-detail/) | [task-five-state-inline-edit](3-6-content-task-workflow/3-6-1-identify-task-detail/task-five-state-inline-edit/), [task-structure-simplification](3-6-content-task-workflow/3-6-1-identify-task-detail/task-structure-simplification/) |
| 3.6.2 | [Assign Task to Creator](3-6-content-task-workflow/3-6-2-assign-task-to-creator/) | [task-creator-assignment](3-6-content-task-workflow/3-6-2-assign-task-to-creator/task-creator-assignment/) |
| 3.6.3 | [Add Comments on Task](3-6-content-task-workflow/3-6-3-add-comments-on-task/) |  |
| 3.6.4 | [List Task View](3-6-content-task-workflow/3-6-4-list-task-view/) | [workspace-task-real-data](3-6-content-task-workflow/3-6-4-list-task-view/workspace-task-real-data/) |
| 3.6.5 | [Calendar Task View](3-6-content-task-workflow/3-6-5-calendar-task-view/) |  |
| 3.6.6 | [Gantt Timeline Task View](3-6-content-task-workflow/3-6-6-gantt-timeline-task-view/) | [campaign-timeline](3-6-content-task-workflow/3-6-6-gantt-timeline-task-view/campaign-timeline/) |
| 3.6.7 | [Kanban Board Task View](3-6-content-task-workflow/3-6-7-kanban-board-task-view/) |  |
| 3.6.8 | [View Task Filter](3-6-content-task-workflow/3-6-8-view-task-filter/) |  |
| 3.6.9 | [Approval Sequence (Creator -> Manager -> Client)](3-6-content-task-workflow/3-6-9-approval-sequence-creator-manager-client/) | [subtask-role-workspaces](3-6-content-task-workflow/3-6-9-approval-sequence-creator-manager-client/subtask-role-workspaces/), [task-approval-simplification](3-6-content-task-workflow/3-6-9-approval-sequence-creator-manager-client/task-approval-simplification/) |
| 3.6.10 | [Content Writing View](3-6-content-task-workflow/3-6-10-content-writing-view/) | [editor-ai-content-popover](3-6-content-task-workflow/3-6-10-content-writing-view/editor-ai-content-popover/), [mobile-video-task-sync](3-6-content-task-workflow/3-6-10-content-writing-view/mobile-video-task-sync/), [task-unsaved-confirmation](3-6-content-task-workflow/3-6-10-content-writing-view/task-unsaved-confirmation/), [task-write-start](3-6-content-task-workflow/3-6-10-content-writing-view/task-write-start/) |
| 3.6.11 | [View Material Repository](3-6-content-task-workflow/3-6-11-view-material-repository/) | [client-folder-sharing](3-6-content-task-workflow/3-6-11-view-material-repository/client-folder-sharing/), [library-simple-ux](3-6-content-task-workflow/3-6-11-view-material-repository/library-simple-ux/), [material-preview-recovery](3-6-content-task-workflow/3-6-11-view-material-repository/material-preview-recovery/), [media-disconnect-handling](3-6-content-task-workflow/3-6-11-view-material-repository/media-disconnect-handling/), [s3-folder-vault-security](3-6-content-task-workflow/3-6-11-view-material-repository/s3-folder-vault-security/), [view-material-repository](3-6-content-task-workflow/3-6-11-view-material-repository/view-material-repository/) |
| 3.6.12 | [Add Material Repository](3-6-content-task-workflow/3-6-12-add-material-repository/) | [add-material-repository](3-6-content-task-workflow/3-6-12-add-material-repository/add-material-repository/), [mp4-upload-detection](3-6-content-task-workflow/3-6-12-add-material-repository/mp4-upload-detection/), [pre-s3-encryption](3-6-content-task-workflow/3-6-12-add-material-repository/pre-s3-encryption/) |
| 3.6.13 | [Update Material Repository](3-6-content-task-workflow/3-6-13-update-material-repository/) | [update-material-repository](3-6-content-task-workflow/3-6-13-update-material-repository/update-material-repository/) |
| 3.6.14 | [Remove Material Repository](3-6-content-task-workflow/3-6-14-remove-material-repository/) | [manual-trash-purge](3-6-content-task-workflow/3-6-14-remove-material-repository/manual-trash-purge/), [remove-material-repository](3-6-content-task-workflow/3-6-14-remove-material-repository/remove-material-repository/), [trash-bulk-selection](3-6-content-task-workflow/3-6-14-remove-material-repository/trash-bulk-selection/) |
| 3.6.15 | [Connect Google Drive Storage](3-6-content-task-workflow/3-6-15-connect-google-drive-storage/) | [agency-storage-onboarding](3-6-content-task-workflow/3-6-15-connect-google-drive-storage/agency-storage-onboarding/), [agency-storage-onboarding-prototype](3-6-content-task-workflow/3-6-15-connect-google-drive-storage/agency-storage-onboarding-prototype/), [customer-drive-overflow](3-6-content-task-workflow/3-6-15-connect-google-drive-storage/customer-drive-overflow/) |
| 3.6.16 | [Sync Material from Google Drive](3-6-content-task-workflow/3-6-16-sync-material-from-google-drive/) | [customer-drive-workspace-sync](3-6-content-task-workflow/3-6-16-sync-material-from-google-drive/customer-drive-workspace-sync/), [drive-import-authorization](3-6-content-task-workflow/3-6-16-sync-material-from-google-drive/drive-import-authorization/) |
| 3.6.17 | [Disconnect Google Drive Storage](3-6-content-task-workflow/3-6-17-disconnect-google-drive-storage/) | [customer-drive-disconnect](3-6-content-task-workflow/3-6-17-disconnect-google-drive-storage/customer-drive-disconnect/) |
| 3.6.18 | [Apply Watermark](3-6-content-task-workflow/3-6-18-apply-watermark/) |  |
| 3.6.19 | [Download Material](3-6-content-task-workflow/3-6-19-download-material/) | [download-material](3-6-content-task-workflow/3-6-19-download-material/download-material/) |
| 3.6.20 | [Apply Hashtag](3-6-content-task-workflow/3-6-20-apply-hashtag/) | [api-hashtag-suggestions](3-6-content-task-workflow/3-6-20-apply-hashtag/api-hashtag-suggestions/), [apply-hashtag-to-post](3-6-content-task-workflow/3-6-20-apply-hashtag/apply-hashtag-to-post/), [contextual-hashtag-suggestions](3-6-content-task-workflow/3-6-20-apply-hashtag/contextual-hashtag-suggestions/), [workspace-context-hashtag-suggestions](3-6-content-task-workflow/3-6-20-apply-hashtag/workspace-context-hashtag-suggestions/) |
| 3.6.21 | [View Hashtag Collection](3-6-content-task-workflow/3-6-21-view-hashtag-collection/) | [view-hashtag-collection](3-6-content-task-workflow/3-6-21-view-hashtag-collection/view-hashtag-collection/) |
| 3.6.22 | [Add Hashtag Collection](3-6-content-task-workflow/3-6-22-add-hashtag-collection/) | [add-hashtag-collection](3-6-content-task-workflow/3-6-22-add-hashtag-collection/add-hashtag-collection/) |
| 3.6.23 | [Update Hashtag Collection](3-6-content-task-workflow/3-6-23-update-hashtag-collection/) |  |
| 3.6.24 | [Remove Hashtag Collection](3-6-content-task-workflow/3-6-24-remove-hashtag-collection/) | [remove-hashtag-collection](3-6-content-task-workflow/3-6-24-remove-hashtag-collection/remove-hashtag-collection/) |
| 3.6.25 | [Create Survey](3-6-content-task-workflow/3-6-25-create-survey/) |  |
| 3.6.26 | [View Survey Analysis](3-6-content-task-workflow/3-6-26-view-survey-analysis/) |  |
| 3.6.27 | [Generate Meeting Link](3-6-content-task-workflow/3-6-27-generate-meeting-link/) |  |
| 3.6.28 | [View Mail Template](3-6-content-task-workflow/3-6-28-view-mail-template/) |  |
| 3.6.29 | [Create Mail Template](3-6-content-task-workflow/3-6-29-create-mail-template/) |  |
| 3.6.30 | [Update Mail Template](3-6-content-task-workflow/3-6-30-update-mail-template/) |  |
| 3.6.31 | [Delete Mail Template](3-6-content-task-workflow/3-6-31-delete-mail-template/) |  |
| 3.6.32 | [Send Email via Template](3-6-content-task-workflow/3-6-32-send-email-via-template/) |  |
| 3.6.33 | [Check Compliance Content](3-6-content-task-workflow/3-6-33-check-compliance-content/) | [caption-text-moderation](3-6-content-task-workflow/3-6-33-check-compliance-content/caption-text-moderation/) |
| 3.6.34 | [View Content History](3-6-content-task-workflow/3-6-34-view-content-history/) |  |
| 3.6.35 | [Chat Realtime](3-6-content-task-workflow/3-6-35-chat-realtime/) | [chat-attachments](3-6-content-task-workflow/3-6-35-chat-realtime/chat-attachments/), [chat-mention-inbox](3-6-content-task-workflow/3-6-35-chat-realtime/chat-mention-inbox/), [chat-rich-composer](3-6-content-task-workflow/3-6-35-chat-realtime/chat-rich-composer/), [chat-scheduled-messages](3-6-content-task-workflow/3-6-35-chat-realtime/chat-scheduled-messages/), [chat-thread-layout](3-6-content-task-workflow/3-6-35-chat-realtime/chat-thread-layout/), [chat-voice-calls](3-6-content-task-workflow/3-6-35-chat-realtime/chat-voice-calls/), [workspace-chat-collaboration](3-6-content-task-workflow/3-6-35-chat-realtime/workspace-chat-collaboration/) |

## 3.7 AI Features — [`3-7-ai-features/`](3-7-ai-features/)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.7.1 | [View Trending Topics Suggestions](3-7-ai-features/3-7-1-view-trending-topics-suggestions/) | [admin-trend-data-view](3-7-ai-features/3-7-1-view-trending-topics-suggestions/admin-trend-data-view/), [internal-trends-fetch](3-7-ai-features/3-7-1-view-trending-topics-suggestions/internal-trends-fetch/), [trend-fit](3-7-ai-features/3-7-1-view-trending-topics-suggestions/trend-fit/), [trend-viewer](3-7-ai-features/3-7-1-view-trending-topics-suggestions/trend-viewer/), [workspace-trend-explorer](3-7-ai-features/3-7-1-view-trending-topics-suggestions/workspace-trend-explorer/) |
| 3.7.2 | [View AI Trend Knowledge Graph](3-7-ai-features/3-7-2-view-ai-trend-knowledge-graph/) | [trend-graph-core](3-7-ai-features/3-7-2-view-ai-trend-knowledge-graph/trend-graph-core/), [trend-graph-ui](3-7-ai-features/3-7-2-view-ai-trend-knowledge-graph/trend-graph-ui/) |
| 3.7.3 | [View Brand Knowledge Documents](3-7-ai-features/3-7-3-view-brand-knowledge-documents/) |  |
| 3.7.4 | [Upload Brand Knowledge Document](3-7-ai-features/3-7-4-upload-brand-knowledge-document/) |  |
| 3.7.5 | [Delete Brand Knowledge Document](3-7-ai-features/3-7-5-delete-brand-knowledge-document/) |  |
| 3.7.6 | [Generate Caption](3-7-ai-features/3-7-6-generate-caption/) | [brand-trend-caption-quality](3-7-ai-features/3-7-6-generate-caption/brand-trend-caption-quality/), [caption-credit-request](3-7-ai-features/3-7-6-generate-caption/caption-credit-request/), [caption-neo4j-context](3-7-ai-features/3-7-6-generate-caption/caption-neo4j-context/), [caption-trend-retrieval](3-7-ai-features/3-7-6-generate-caption/caption-trend-retrieval/), [content-humanizer](3-7-ai-features/3-7-6-generate-caption/content-humanizer/) |
| 3.7.7 | [Generate Ambassador](3-7-ai-features/3-7-7-generate-ambassador/) | [ambassador-portrait-ui](3-7-ai-features/3-7-7-generate-ambassador/ambassador-portrait-ui/), [qwen-ambassador-docker](3-7-ai-features/3-7-7-generate-ambassador/qwen-ambassador-docker/) |
| 3.7.8 | [View Image Style Template](3-7-ai-features/3-7-8-view-image-style-template/) |  |
| 3.7.9 | [Generate Image](3-7-ai-features/3-7-9-generate-image/) | [commercial-image-presets](3-7-ai-features/3-7-9-generate-image/commercial-image-presets/) |
| 3.7.10 | [View Video Style Template](3-7-ai-features/3-7-10-view-video-style-template/) |  |
| 3.7.11 | [Generate Video](3-7-ai-features/3-7-11-generate-video/) |  |
| 3.7.12 | [Export File](3-7-ai-features/3-7-12-export-file/) |  |
| 3.7.13 | [Crawl Schedule Config](3-7-ai-features/3-7-13-crawl-schedule-config/) | [admin-crawler-management](3-7-ai-features/3-7-13-crawl-schedule-config/admin-crawler-management/), [admin-multiplatform-trend-pipeline](3-7-ai-features/3-7-13-crawl-schedule-config/admin-multiplatform-trend-pipeline/), [admin-trend-pipeline-now](3-7-ai-features/3-7-13-crawl-schedule-config/admin-trend-pipeline-now/), [admin-trend-source-config](3-7-ai-features/3-7-13-crawl-schedule-config/admin-trend-source-config/), [crawler-bounded-memory](3-7-ai-features/3-7-13-crawl-schedule-config/crawler-bounded-memory/), [trend-cold-storage](3-7-ai-features/3-7-13-crawl-schedule-config/trend-cold-storage/), [trend-s3-daily-replay](3-7-ai-features/3-7-13-crawl-schedule-config/trend-s3-daily-replay/), [update-trend-flow](3-7-ai-features/3-7-13-crawl-schedule-config/update-trend-flow/) |
| 3.7.14 | [Suggest Hashtag Trend](3-7-ai-features/3-7-14-suggest-hashtag-trend/) |  |
| 3.7.15 | [View Collaborator Directory](3-7-ai-features/3-7-15-view-collaborator-directory/) | [partner-directory](3-7-ai-features/3-7-15-view-collaborator-directory/partner-directory/) |
| 3.7.16 | [Create Collaborator Profile](3-7-ai-features/3-7-16-create-collaborator-profile/) |  |
| 3.7.17 | [Update Collaborator Profile](3-7-ai-features/3-7-17-update-collaborator-profile/) |  |
| 3.7.18 | [Remove Collaborator Profile](3-7-ai-features/3-7-18-remove-collaborator-profile/) |  |
| 3.7.19 | [Recommend Collaborator](3-7-ai-features/3-7-19-recommend-collaborator/) |  |

## 3.8 Publishing & Social — [`3-8-publishing-social/`](3-8-publishing-social/)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.8.1 | [Connect Social Account](3-8-publishing-social/3-8-1-connect-social-account/) | [connect-facebook-instagram](3-8-publishing-social/3-8-1-connect-social-account/connect-facebook-instagram/), [connect-threads](3-8-publishing-social/3-8-1-connect-social-account/connect-threads/), [connect-tiktok](3-8-publishing-social/3-8-1-connect-social-account/connect-tiktok/) |
| 3.8.2 | [Disconnect Account](3-8-publishing-social/3-8-2-disconnect-account/) |  |
| 3.8.3 | [View Dashboard Post](3-8-publishing-social/3-8-3-view-dashboard-post/) |  |
| 3.8.4 | [View Posted Detail](3-8-publishing-social/3-8-4-view-posted-detail/) | [view-comment-detail-list](3-8-publishing-social/3-8-4-view-posted-detail/view-comment-detail-list/) |
| 3.8.5 | [Preview Post](3-8-publishing-social/3-8-5-preview-post/) |  |
| 3.8.6 | [Schedule Platform Post](3-8-publishing-social/3-8-6-schedule-platform-post/) | [publisher-message-type-compatibility](3-8-publishing-social/3-8-6-schedule-platform-post/publisher-message-type-compatibility/) |
| 3.8.7 | [Track Post Status](3-8-publishing-social/3-8-7-track-post-status/) |  |
| 3.8.8 | [Publish Facebook Post](3-8-publishing-social/3-8-8-publish-facebook-post/) |  |
| 3.8.9 | [Publish Facebook Story](3-8-publishing-social/3-8-9-publish-facebook-story/) |  |
| 3.8.10 | [Publish Facebook Reels](3-8-publishing-social/3-8-10-publish-facebook-reels/) |  |
| 3.8.11 | [Publish Instagram Post](3-8-publishing-social/3-8-11-publish-instagram-post/) |  |
| 3.8.12 | [Publish Instagram Reels](3-8-publishing-social/3-8-12-publish-instagram-reels/) |  |
| 3.8.13 | [Publish Instagram Story](3-8-publishing-social/3-8-13-publish-instagram-story/) |  |
| 3.8.14 | [Publish TikTok Video](3-8-publishing-social/3-8-14-publish-tiktok-video/) |  |
| 3.8.15 | [Publish Threads Post](3-8-publishing-social/3-8-15-publish-threads-post/) |  |

## 3.9 Subscription & Billing — [`3-9-subscription-billing/`](3-9-subscription-billing/)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.9.1 | [Upgrade Plan](3-9-subscription-billing/3-9-1-upgrade-plan/) | [agency-plus-renewal](3-9-subscription-billing/3-9-1-upgrade-plan/agency-plus-renewal/), [agency-plus-style](3-9-subscription-billing/3-9-1-upgrade-plan/agency-plus-style/), [agency-subscription](3-9-subscription-billing/3-9-1-upgrade-plan/agency-subscription/), [subscription-catalog-api-ui](3-9-subscription-billing/3-9-1-upgrade-plan/subscription-catalog-api-ui/), [subscription-four-plan-catalog](3-9-subscription-billing/3-9-1-upgrade-plan/subscription-four-plan-catalog/) |
| 3.9.2 | [Make Payment (SePay)](3-9-subscription-billing/3-9-2-make-payment-sepay/) | [payment-qr-countdown](3-9-subscription-billing/3-9-2-make-payment-sepay/payment-qr-countdown/), [subscription-auto-checkout](3-9-subscription-billing/3-9-2-make-payment-sepay/subscription-auto-checkout/), [subscription-payment-dialog](3-9-subscription-billing/3-9-2-make-payment-sepay/subscription-payment-dialog/), [subscription-webhook-corrections](3-9-subscription-billing/3-9-2-make-payment-sepay/subscription-webhook-corrections/) |
| 3.9.3 | [View Invoice History](3-9-subscription-billing/3-9-3-view-invoice-history/) | [admin-invoice-history](3-9-subscription-billing/3-9-3-view-invoice-history/admin-invoice-history/), [subscription-invoice-history](3-9-subscription-billing/3-9-3-view-invoice-history/subscription-invoice-history/) |
| 3.9.4 | [View AI Credit Tracking](3-9-subscription-billing/3-9-4-view-ai-credit-tracking/) | [ai-credit-balance](3-9-subscription-billing/3-9-4-view-ai-credit-tracking/ai-credit-balance/), [credit-unification](3-9-subscription-billing/3-9-4-view-ai-credit-tracking/credit-unification/) |
| 3.9.5 | [Buy Credit](3-9-subscription-billing/3-9-5-buy-credit/) |  |
| 3.9.6 | [Set Credit](3-9-subscription-billing/3-9-6-set-credit/) | [member-credit](3-9-subscription-billing/3-9-6-set-credit/member-credit/), [workspace-credit-unification](3-9-subscription-billing/3-9-6-set-credit/workspace-credit-unification/) |

## 3.10 Admin Functions — [`3-10-admin-management/`](3-10-admin-management/)

Tài liệu chung: [confirmed-decisions-2026-10-01.md](3-10-admin-management/confirmed-decisions-2026-10-01.md), [implementation-status-2026-10-02.md](3-10-admin-management/implementation-status-2026-10-02.md), [plan.md](3-10-admin-management/plan.md), [task.md](3-10-admin-management/task.md)

| FR | Tên | Tính năng mở rộng |
|---|---|---|
| 3.10.1 | [Push Notification](3-10-admin-management/3-10-1-push-notification/) |  |
| 3.10.2 | [Platform Statistics Overview](3-10-admin-management/3-10-2-platform-statistics-overview/) | [admin-ui-consistency](3-10-admin-management/3-10-2-platform-statistics-overview/admin-ui-consistency/) |
| 3.10.3 | [System Health Monitoring](3-10-admin-management/3-10-3-system-health-monitoring/) | [system-health](3-10-admin-management/3-10-3-system-health-monitoring/system-health/), [system-health-mongodb-refactor](3-10-admin-management/3-10-3-system-health-monitoring/system-health-mongodb-refactor/) |
| 3.10.4 | [Content Moderation Queue](3-10-admin-management/3-10-4-content-moderation-queue/) |  |
| 3.10.5 | [Update User Violation Status](3-10-admin-management/3-10-5-update-user-violation-status/) |  |
| 3.10.6 | [View User](3-10-admin-management/3-10-6-view-user/) |  |
| 3.10.7 | [Create User](3-10-admin-management/3-10-7-create-user/) |  |
| 3.10.8 | [Update User](3-10-admin-management/3-10-8-update-user/) |  |
| 3.10.9 | [Deactivate User](3-10-admin-management/3-10-9-deactivate-user/) |  |
| 3.10.10 | [View AI Credit Price List](3-10-admin-management/3-10-10-view-ai-credit-price-list/) |  |
| 3.10.11 | [Update AI Credit Price](3-10-admin-management/3-10-11-update-ai-credit-price/) |  |
| 3.10.12 | [Import AI Credit Price CSV](3-10-admin-management/3-10-12-import-ai-credit-price-csv/) | [credit-price-csv-import](3-10-admin-management/3-10-12-import-ai-credit-price-csv/credit-price-csv-import/) |
| 3.10.13 | [View Revenue Dashboard](3-10-admin-management/3-10-13-view-revenue-dashboard/) | [admin-revenue-invoices](3-10-admin-management/3-10-13-view-revenue-dashboard/admin-revenue-invoices/), [admin-sepay-revenue](3-10-admin-management/3-10-13-view-revenue-dashboard/admin-sepay-revenue/) |
| 3.10.14 | [Export Report File PDF](3-10-admin-management/3-10-14-export-report-file-pdf/) |  |

## Ngoài FR

- [`_platform/`](_platform/) — hạ tầng, CI, deploy, seed, monitoring, việc xuyên nhiều FR: [ai-env-cleanup](_platform/ai-env-cleanup/), [ai-service-ci](_platform/ai-service-ci/), [definition](_platform/definition/), [deploy-provider-migration](_platform/deploy-provider-migration/), [frontend-ci-repair](_platform/frontend-ci-repair/), [gateway-ci-jwt](_platform/gateway-ci-jwt/), [local-credit-seed](_platform/local-credit-seed/), [mobile-native-enhancements](_platform/mobile-native-enhancements/), [mobile-nav-role-parity](_platform/mobile-nav-role-parity/), [mongo-seed-stabilization](_platform/mongo-seed-stabilization/), [monitoring-json-startup](_platform/monitoring-json-startup/), [navigation-ux-linked-demo-data](_platform/navigation-ux-linked-demo-data/), [payment-java-runner](_platform/payment-java-runner/), [payment-tests-in-repository](_platform/payment-tests-in-repository/), [postgres-demo-seed-integrity](_platform/postgres-demo-seed-integrity/), [postgres-schema-gap-repair](_platform/postgres-schema-gap-repair/), [remove-live-mock-fallbacks](_platform/remove-live-mock-fallbacks/), [runtime-integration-recovery](_platform/runtime-integration-recovery/), [subscription-production-observability](_platform/subscription-production-observability/), [workspace-hashtag-demo-seed](_platform/workspace-hashtag-demo-seed/)
- [`_archive/descoped/`](_archive/descoped/) — FR đã bỏ khỏi phạm vi (livestream, copyright, downgrade plan, PayOS): [3-6-22-write-livestream-idea](_archive/descoped/3-6-22-write-livestream-idea/), [3-6-23-write-livestream-script](_archive/descoped/3-6-23-write-livestream-script/), [3-6-24-track-livestream-status](_archive/descoped/3-6-24-track-livestream-status/), [3-6-34-check-copyright-infringement](_archive/descoped/3-6-34-check-copyright-infringement/), [3-7-11-generate-livestream-script](_archive/descoped/3-7-11-generate-livestream-script/), [3-9-2-downgrade-plan](_archive/descoped/3-9-2-downgrade-plan/), [3-9-3-make-payment-payos](_archive/descoped/3-9-3-make-payment-payos/)
- [`_archive/legacy-numbering/`](_archive/legacy-numbering/) — bản tài liệu theo số FR cũ, trùng tên với bản chuẩn khi gộp; giữ để tra cứu.
- Tổng quan nhiều domain: [3.2-3.3-3.4-All-FR-Spec.md](3.2-3.3-3.4-All-FR-Spec.md), [3.3-3.4-Profile-Agency-Workspace-Spec.docx](3.3-3.4-Profile-Agency-Workspace-Spec.docx)

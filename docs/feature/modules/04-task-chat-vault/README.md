# 04-task-chat-vault — Task Workflow, Realtime Workspace Chat, Reference Hub & Encrypted S3 Vault (4 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.6 Content & Workflow](../../srs/05-content-task-workflow/README.md) · [BA Domain Spec](../../../ba/05-content-task-workflow.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Core daily collaboration and asset security architecture uniting the 5-state inline Task workflow, multi-channel STOMP Workspace Chat with 1:1 Agora RTC voice calls, and KMS AES-256-GCM envelope-encrypted S3 Material Vaults with Google Drive import.

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-business-service` (`TaskController`, `TaskWorkflowController`, `TaskSectionController`, `ChatChannelController`, `ChatMessageController`, `ChatCallController`, `MaterialController`, `MaterialFolderController`, `RepositoryEnvelopeCrypto`, `ClientVaultController`, `DriveFolderImportController`, `CustomerDriveController`) and `brandhub-web`.
- **Storage & Runtime State:**
  - **PostgreSQL 17:** `storage_addon_packages`, `agency_storage_addons`, `client_vault_folders`, `client_vault_shares`, `workspace_hashtags`.
  - **MongoDB 7.0:** `tasks`, `task_versions`, `materials`, `material_folders`, `chat_channels`, `chat_messages`, `chat_threads`, `scheduled_chat_messages`.
  - **AWS S3 + KMS:** Envelope-encrypted repository blobs served via short-lived capability URLs (`/api/v1/repository-media/*`) so `Admin` / Dev operators cannot inspect raw tenant media.
- **Related Canonical SRS Domain:** [05-content-task-workflow (`3.6.1`–`3.6.35`)](../../srs/05-content-task-workflow/README.md).

---

## 2. Consolidated Modules (`4`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `task-subtask-and-inline-workflow` | **Five-State Inline Task Editing, Role-Scoped Subtasks & Sectioned Specialized Editors** | `TODO -> IN_PROGRESS -> INTERNAL_REVIEW -> CLIENT_REVIEW -> APPROVED` workflow, role-locked subtasks, specialized Post/Survey/Video task sections | [Spec](./task-subtask-and-inline-workflow/spec.md) · [Plan](./task-subtask-and-inline-workflow/plan.md) · [Task](./task-subtask-and-inline-workflow/task.md) · [Test](./task-subtask-and-inline-workflow/test.md) |
| `reference-hub-and-algorithmic-curation` | **Smart Reference Hub, Shared Moodboard & Client-Side Algorithmic Curation Engine** | `WorkspaceReferenceController`, MongoDB `workspace_moodboard_items`, `ReferencePreviewModal` (TextRank), Content Kit Tripartite Pairing, Facet Clustering, CIELAB $\Delta E$ Color Harmony, Storyboard B-roll Assigner & Session Rocchio + MMR | [Spec](./reference-hub-and-algorithmic-curation/spec.md) · [Plan](./reference-hub-and-algorithmic-curation/plan.md) · [Task](./reference-hub-and-algorithmic-curation/task.md) · [Test](./reference-hub-and-algorithmic-curation/test.md) |
| `workspace-chat-and-voice-calls` | **Workspace Realtime Chat Channels, Threads, Mentions, Slash References, Scheduled Messages & 1:1 Voice Calls** | STOMP `/ws/chat`, `PUBLIC` / `PRIVATE` / `DIRECT` channels, `/task` & `/material` rich cards, `@mentions` inbox, DND mute, `ChatCallController` 1:1 voice | [Spec](./workspace-chat-and-voice-calls/spec.md) · [Plan](./workspace-chat-and-voice-calls/plan.md) · [Task](./workspace-chat-and-voice-calls/task.md) · [Test](./workspace-chat-and-voice-calls/test.md) |
| `s3-folder-vault-security` | **Encrypted S3 Material Repository, Storage Add-Ons, Client Folder Vault & Google Drive Sync** | `RepositoryEnvelopeCrypto` (`AES-256-GCM`), 5 GB free + add-on quota (`StorageQuotaService`), `Client` cross-workspace Vault share, Google Drive tree import | [Spec](./s3-folder-vault-security/spec.md) · [Plan](./s3-folder-vault-security/plan.md) · [Task](./s3-folder-vault-security/task.md) · [Test](./s3-folder-vault-security/test.md) |

---

## 3. Security & Collaboration Invariants

1. Tenant repository binaries encrypted via `RepositoryEnvelopeCrypto` use per-object DEKs wrapped by AWS KMS/master keys; `Admin` accounts are explicitly blocked from decrypting workspace/client vault media.
2. Approval state transitions preserve audit trails (`BR-35`) and enforce `Manager` internal review before `Client` sign-off when two-tier approval is configured.

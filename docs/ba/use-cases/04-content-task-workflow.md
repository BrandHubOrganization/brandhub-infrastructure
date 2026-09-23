# UC 04 — Content & Task Workflow (UC-42 → UC-73)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [05-content-task-workflow.md](../05-content-task-workflow.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`
> **Nguồn gốc Task trong backlog (3 nguồn):** Media Campaign approve, Content Request accepted, Manager thêm thủ công.

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-42 | Define Task Detail | MANAGER | 3.6.1 |
| UC-43 | Assign Task to Creator | MANAGER | 3.6.2 |
| UC-44 | Comment on Task | CREATOR/CLIENT/MANAGER | 3.6.3 |
| UC-45 | View Tasks in Multiple Views | CREATOR/CLIENT/MANAGER | 3.6.4–3.6.7 |
| UC-46 | Filter & Search Tasks | CREATOR/CLIENT/MANAGER | 3.6.8 |
| UC-47 | Task Approval Sequence | CREATOR/CLIENT/MANAGER | 3.6.9 |
| UC-48 | Write Content | CREATOR | 3.6.10 |
| UC-49 | View Content Version History | CREATOR | 3.6.35 |
| UC-50 | View Material Repository | CREATOR/CLIENT | 3.6.11 |
| UC-51 | Add Material to Repository | CREATOR/CLIENT | 3.6.12 |
| UC-52 | Update Material in Repository | CREATOR/CLIENT | 3.6.13 |
| UC-53 | Delete Material from Repository | CREATOR/CLIENT | 3.6.14 |
| UC-54 | Apply Watermark to Material | CREATOR | 3.6.15 |
| UC-55 | Download Material | CREATOR/CLIENT | 3.6.16 |
| UC-56 | Apply Hashtag to Post | CREATOR | 3.6.17 |
| UC-57 | View Hashtag Collection | CREATOR/CLIENT | 3.6.18 |
| UC-58 | Add Hashtag to Collection | CREATOR | 3.6.19 |
| UC-59 | Update Hashtag Collection | CREATOR | 3.6.20 |
| UC-60 | Delete Hashtag from Collection | CREATOR | 3.6.21 |
| UC-61 | Write Livestream Idea | MANAGER/CREATOR | 3.6.22 |
| UC-62 | Write Livestream Script | CREATOR | 3.6.23 |
| UC-63 | Track Livestream Status | MANAGER | 3.6.24 |
| UC-64 | Create Survey | CREATOR/MANAGER | 3.6.25 |
| UC-65 | View Survey Analysis | CREATOR/MANAGER | 3.6.26 |
| UC-66 | Generate Meeting Link | CREATOR | 3.6.27 |
| UC-67 | View Email Template | MANAGER/CREATOR | 3.6.28 |
| UC-68 | Create Email Template | MANAGER/CREATOR | 3.6.29 |
| UC-69 | Update Email Template | MANAGER/CREATOR | 3.6.30 |
| UC-70 | Delete Email Template | MANAGER/CREATOR | 3.6.31 |
| UC-71 | Send Email via Template | MANAGER/CREATOR | 3.6.32 |
| UC-72 | Check Content Compliance | CREATOR/CLIENT | 3.6.33 |
| UC-73 | Check Copyright Infringement | CREATOR/CLIENT | 3.6.34 |

---

## UC-42 — Define Task Detail

- **Actor(s):** MANAGER
- **Description:** Add full details (due date, detailed requirements) to a task pulled from the backlog.
- **Precondition:** Task exists in backlog with only name/title/output requirement (no assignee/detail yet).
- **Main Flow:**
  1. MANAGER opens a backlog Task.
  2. Fills in assignee-pending detail fields: due date, detailed requirements, and type-specific fields (Post/Livestream/Survey).
  3. System saves the detailed Task, ready for assignment (UC-43).

## UC-43 — Assign Task to Creator

- **Actor(s):** MANAGER
- **Description:** Assign a defined task to the Creator responsible for it.
- **Precondition:** Task detail defined (UC-42).
- **Main Flow:**
  1. MANAGER selects a Creator to execute the task.
  2. Optionally assigns a second Creator as QC (quality-control reviewer).
  3. System notifies the assigned Creator(s).

## UC-44 — Comment on Task

- **Actor(s):** CREATOR/CLIENT/MANAGER
- **Description:** Add comments and edit requests on a task.
- **Precondition:** Task exists and actor has access (assignee, workspace member, or client with visibility).
- **Main Flow:**
  1. Actor writes a comment or edit request on the Task thread.
  2. System notifies relevant participants (assignee/manager/client).

## UC-45 — View Tasks in Multiple Views

- **Actor(s):** CREATOR/CLIENT/MANAGER
- **Description:** View the task list as List, Calendar, Gantt Timeline, or Kanban Board.
- **Precondition:** User has access to the Workspace.
- **Main Flow:**
  1. User selects a view mode: List (Jira-style), Calendar (drag-drop, Google Calendar-style), Gantt Timeline (waterfall), or Kanban Board (drag between status columns).
  2. System renders tasks accordingly, live-synced across all views.

## UC-46 — Filter & Search Tasks

- **Actor(s):** CREATOR/CLIENT/MANAGER
- **Description:** Filter, sort, and search tasks by any data field across all view types.
- **Precondition:** User is viewing a Task view (UC-45).
- **Main Flow:**
  1. User applies filter/sort/search criteria (assignee, status, date, type, etc.).
  2. System narrows displayed tasks across the current view.

## UC-47 — Task Approval Sequence

- **Actor(s):** CREATOR/CLIENT/MANAGER
- **Description:** Approve tasks in a hierarchy of Creator → Manager → Client; a rejection sends it back to the initial Creator step.
- **Precondition:** Task work has been submitted by the assigned Creator.
- **Main Flow:**
  1. Creator completes the work, submits for review.
  2. (Optional) QC Creator reviews — only if a QC was assigned at UC-43.
  3. Manager reviews and approves/rejects.
  4. Client reviews and approves/rejects — only if the task requires client approval.
  5. All steps pass → Task marked complete.
- **Alternate Flow:**
  - A1. Any step rejects → the entire sequence restarts from the original Creator step (not from the rejecting step).

## UC-48 — Write Content

- **Actor(s):** CREATOR
- **Description:** Write text content with automatic font conversion for publishing.
- **Precondition:** Task assigned to Creator (Post-type task).
- **Main Flow:**
  1. CREATOR writes content in a vector-text editor (Google Docs-style).
  2. System auto-converts font encoding to the platform-correct standard on publish (removes manual Unikey/Yantext conversion step).
- **Postcondition:** Content saved with a new version snapshot (see UC-49).

## UC-49 — View Content Version History

- **Actor(s):** CREATOR
- **Description:** View and restore previous versions of written content.
- **Precondition:** Content has at least one prior saved version.
- **Main Flow:**
  1. CREATOR opens Version History for a content item.
  2. System lists versions with editor + timestamp.
  3. CREATOR selects a version to restore.

## UC-50 — View Material Repository

- **Actor(s):** CREATOR/CLIENT
- **Description:** View the repository of materials (raw/retouched photos, client-provided brand assets).
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. User opens Material Repository.
  2. System lists materials tagged raw/retouched, plus Client-provided Brand Assets (separate category from Creator-produced Material).
- **Note:** Raw (unprocessed) material shows a warning if selected for publishing.

## UC-51 — Add Material to Repository

- **Actor(s):** CREATOR/CLIENT
- **Description:** Upload a new material into the repository.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. User uploads a file, tags it raw/retouched (or Brand Asset if Client-provided).
  2. System stores the material in the repository.

## UC-52 — Update Material in Repository

- **Actor(s):** CREATOR/CLIENT
- **Description:** Update an existing material's information in the repository.
- **Precondition:** Material exists.
- **Main Flow:**
  1. User edits material metadata (tags, description, processing status).
  2. System persists changes.

## UC-53 — Delete Material from Repository

- **Actor(s):** CREATOR/CLIENT
- **Description:** Remove a material from the repository.
- **Precondition:** Material exists.
- **Main Flow:**
  1. User selects Delete, confirms.
  2. System removes the material from the repository.

## UC-54 — Apply Watermark to Material

- **Actor(s):** CREATOR
- **Description:** Apply a brand watermark onto a material.
- **Precondition:** Material has been retouched/edited; Client-provided logo available.
- **Main Flow:**
  1. CREATOR selects a material and the Client's brand logo.
  2. System applies watermark overlay (img2go-style tool), saves the watermarked output.

## UC-55 — Download Material

- **Actor(s):** CREATOR/CLIENT
- **Description:** Download a material from the repository to a local device.
- **Precondition:** Material exists and user has access.
- **Main Flow:**
  1. User selects Download on a material.
  2. System streams the file to the user's device.
- **Note:** All Workspace roles (Creator/Client/Manager) can perform this action.

## UC-56 — Apply Hashtag to Post

- **Actor(s):** CREATOR
- **Description:** Attach one or more hashtags to a post or campaign.
- **Precondition:** Post/campaign draft exists.
- **Main Flow:**
  1. CREATOR selects hashtags from the Workspace Hashtag Collection (or types new ones).
  2. System attaches hashtags to the post/campaign.

## UC-57 — View Hashtag Collection

- **Actor(s):** CREATOR/CLIENT
- **Description:** View the Workspace's saved hashtag collection.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. User opens Hashtag Collection.
  2. System lists saved hashtags, including AI-recommended suggestions.

## UC-58 — Add Hashtag to Collection

- **Actor(s):** CREATOR
- **Description:** Add a new hashtag to the Workspace's hashtag collection.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. CREATOR enters a new hashtag, tags its intended usage/category.
  2. System stores it in the collection.
- **Note:** Client-added hashtags are event-specific and mandatory-use per FR 3.6.18; Creator additions are free-form.

## UC-59 — Update Hashtag Collection

- **Actor(s):** CREATOR
- **Description:** Update an existing hashtag in the collection.
- **Precondition:** Hashtag exists in the collection.
- **Main Flow:**
  1. CREATOR edits hashtag text/category.
  2. System persists changes.

## UC-60 — Delete Hashtag from Collection

- **Actor(s):** CREATOR
- **Description:** Soft-delete a hashtag from the collection.
- **Precondition:** Hashtag exists.
- **Main Flow:**
  1. CREATOR selects Delete, confirms.
  2. System soft-deletes the hashtag — already-applied usages on old posts remain unaffected.

## UC-61 — Write Livestream Idea

- **Actor(s):** MANAGER/CREATOR
- **Description:** Fill in the initial idea/concept for a livestream session.
- **Precondition:** Livestream-type Task assigned.
- **Main Flow:**
  1. MANAGER/CREATOR fills in idea, target goal for the livestream.
  2. System saves the idea as the livestream session's initial state.

## UC-62 — Write Livestream Script

- **Actor(s):** CREATOR
- **Description:** Write the full script for a livestream session.
- **Precondition:** Livestream idea exists (UC-61).
- **Main Flow:**
  1. CREATOR writes the full script (talking points, timing, risk considerations, shot list).
  2. System saves the script tied to the livestream session.

## UC-63 — Track Livestream Status

- **Actor(s):** MANAGER
- **Description:** Track the progress/status of a livestream session.
- **Precondition:** Livestream session exists with script ready.
- **Main Flow:**
  1. MANAGER opens the livestream tracker.
  2. System displays current state: `PRE_LIVE → LIVE → POST_LIVE → DONE/CANCEL`.
- **Alternate Flow:**
  - A1. Session cancelled at any pre-completion state → moves to `CANCEL`.

## UC-64 — Create Survey

- **Actor(s):** CREATOR/MANAGER
- **Description:** Create a survey for a workshop or campaign.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. User builds survey questions with time slots (form-builder style), previews the form.
  2. System saves and publishes the survey.

## UC-65 — View Survey Analysis

- **Actor(s):** CREATOR/MANAGER
- **Description:** View the overall analysis of survey results.
- **Precondition:** Survey has received responses.
- **Main Flow:**
  1. User opens Survey Analysis.
  2. System displays aggregated results/statistics.

## UC-66 — Generate Meeting Link

- **Actor(s):** CREATOR
- **Description:** Automatically generate a Google Meet link for a meeting.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. CREATOR requests a meeting link for a scheduled session.
  2. System calls Google Meet API, returns a generated link.

## UC-67 — View Email Template

- **Actor(s):** MANAGER/CREATOR
- **Description:** View the list of saved email templates.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. User opens Email Template list.
  2. System displays saved templates.
- **Note:** Role assignment for this FR group is an **[OPEN QUESTION]** in the source CSV — not finalized.

## UC-68 — Create Email Template

- **Actor(s):** MANAGER/CREATOR
- **Description:** Create a new email template.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. User composes a new template (subject, body, placeholders).
  2. System saves the template.

## UC-69 — Update Email Template

- **Actor(s):** MANAGER/CREATOR
- **Description:** Update an existing email template.
- **Precondition:** Template exists.
- **Main Flow:**
  1. User edits template content.
  2. System persists changes.

## UC-70 — Delete Email Template

- **Actor(s):** MANAGER/CREATOR
- **Description:** Delete an existing email template.
- **Precondition:** Template exists.
- **Main Flow:**
  1. User selects Delete, confirms.
  2. System removes the template.

## UC-71 — Send Email via Template

- **Actor(s):** MANAGER/CREATOR
- **Description:** Send an email to a recipient using a selected template.
- **Precondition:** Template exists.
- **Main Flow:**
  1. User selects a template, fills recipient + placeholder values.
  2. System sends the email.

## UC-72 — Check Content Compliance

- **Actor(s):** CREATOR/CLIENT
- **Description:** Check content for plagiarism, violence, or explicit imagery via a third-party API.
- **Precondition:** Content draft ready for review.
- **Main Flow:**
  1. User triggers compliance check.
  2. System calls third-party moderation API, returns a flagged-terms/segments analysis.
  3. User reviews flagged items and revises before publishing (avoids platform policy violations / trending suppression).

## UC-73 — Check Copyright Infringement

- **Actor(s):** CREATOR/CLIENT
- **Description:** Check images/brand assets for copyright infringement via a third-party API.
- **Precondition:** Image/brand asset ready for review.
- **Main Flow:**
  1. User triggers copyright check on an image/asset.
  2. System calls third-party API, returns infringement analysis.
- **Note:** Technical detail **[OPEN QUESTION]** — source notes "needs clarification", not yet fully specified.

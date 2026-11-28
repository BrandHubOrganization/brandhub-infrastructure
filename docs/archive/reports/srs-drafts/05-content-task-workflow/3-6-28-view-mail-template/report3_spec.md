**3.6.28 View Mail Template**

**Function Trigger**

A Workspace member (OWNER, MANAGER or CREATOR) opens `/workspaces/:id/mail-templates` to browse the saved email templates, optionally including the system starter templates.

**Function Description**

- **Actors / Roles**: OWNER, MANAGER, CREATOR of the Workspace. CLIENT is not allowed.
- **Purpose**: Let a member find a template to reuse, clone, edit or send.
- **Interface**: A list page with search and pagination showing template name, subject preview, creation date, type (Workspace / System) and attachment count. System templates carry a "System" chip and only offer "Use template" (clone).
- **Data Processing**: The system queries non-deleted `mail_templates` of the Workspace and, when requested, the `SYSTEM_DEFAULT` templates, then returns a paged list.

**Screen Layout**

Figure — Mail Template List View:

- Search box, "Include system templates" toggle.
- Table/list: name, subject preview (120 chars), type chip, attachment count, created date.
- "Create Template" button (entry point to 3.6.29).
- Per-row actions: Edit, Delete (entry points to 3.6.30/3.6.31), Send (entry point to 3.6.32), Use template (system rows).
- Link to the send history page (batches).

**Function Details**
- **Data Specifications**
    - **Input required**: Workspace identifier (path param).
    - **Input optional**: `includeSystem`, `q`, `page`, `size`.
    - **System data**: `mail_templates` (MongoDB) scoped to the Workspace plus `SYSTEM_DEFAULT` rows.
    - **Output**: paged list `[{id, name, subject, type, attachmentCount, createdAt}]`.

- **Business Rules**
    - Only OWNER/MANAGER/CREATOR members of the Workspace may view.
    - Soft-deleted templates (`deletedAt != null`) never appear.
    - System templates are visible to every Workspace and are read-only there.

- **Validation**
    - No access → 403 `FORBIDDEN`.

**Functionalities**
- **Normal Flow**
    - 1. A member opens `/workspaces/:id/mail-templates`.
    - 2. The system verifies the member's role in the Workspace.
    - 3. The system returns the paged template list (with system templates when requested).
    - 4. The page renders the list with loading, empty and error states.

- **Abnormal Cases**
    - 2.a1: Caller is not a permitted member (including CLIENT) → 403 `FORBIDDEN`.
    - 3.a1: No templates → empty state with a "Create Template" prompt.

**Post-Conditions**

- None — read-only view.

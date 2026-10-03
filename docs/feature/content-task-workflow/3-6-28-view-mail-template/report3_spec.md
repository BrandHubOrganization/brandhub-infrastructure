**3.6.28 View Mail Template**

**Function Trigger**

A Workspace member opens `/workspaces/:id/mail-templates` to see the list of saved email templates.

**Function Description**

- **Actors / Roles**: Member (default MANAGER; may extend to CREATOR).
- **Purpose**: Let a Workspace member browse previously created email templates for reuse when emailing a Client.
- **Interface**: A list page showing template name, subject preview, and creation date.
- **Data Processing**: The system queries Mail Templates scoped to the Workspace and returns them as a list.

**Screen Layout**

Figure — Mail Template List View:

- Table/list of templates: name, subject preview, created date.
- "Create Template" button at the top (entry point to 3.6.29).
- Per-row Edit/Delete actions (entry points to 3.6.30/3.6.31).

**Function Details**
- **Data Specifications**
    - **Input required**: Workspace identifier (path param).
    - **Input optional**: none.
    - **System data**: `MailTemplate` entity scoped to Workspace (`name`, `subject`, `body`).
    - **Output**: list `[{id, name, subject}]`.

- **Business Rules**
    - Only Workspace members with the permitted role can view the list.

- **Validation**
    - No access → 403 `FORBIDDEN`.

**Functionalities**
- **Normal Flow**
    - 1. A member opens `/workspaces/:id/mail-templates`.
    - 2. The system lists the Workspace's Mail Templates (name, subject preview, created date).

- **Abnormal Cases**
    - 2.a1: Caller lacks permission → 403 `FORBIDDEN`.

**Post-Conditions**

- None — read-only view.

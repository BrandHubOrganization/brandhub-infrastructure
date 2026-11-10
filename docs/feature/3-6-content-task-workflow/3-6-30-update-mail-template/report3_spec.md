**3.6.30 Update Mail Template**

**Function Trigger**

A member clicks Edit on a Mail Template row in the list.

**Function Description**

- **Actors / Roles**: The template's creator, or OWNER/MANAGER of the Workspace.
- **Purpose**: Keep a template's name, subject, body and attachments current.
- **Interface**: The same form as Create, pre-filled with the current values.
- **Data Processing**: The system patches only the supplied fields, re-sanitizes the body and updates `updatedAt`.

**Screen Layout**

Figure — Edit Mail Template Form:

- Same fields as Create, pre-filled; Save / Cancel.
- System templates show a read-only notice and a "Use template" action instead of Save.

**Function Details**
- **Data Specifications**
    - **Input required**: `templateId` (path param).
    - **Input optional**: `name`, `subject`, `bodyHtml`, `attachmentIds[]` — any subset (PATCH semantics).
    - **System data**: `mail_templates` document.
    - **Output**: the updated template.

- **Business Rules**
    - Only the creator or OWNER/MANAGER may update; a CREATOR cannot edit another member's template.
    - System templates cannot be modified from a Workspace (Admin only, via the admin API).
    - Updating a template never changes batches that were already sent or scheduled (they hold a snapshot).

- **Validation**
    - Not permitted → 403 `FORBIDDEN`.
    - System template → 403 `SYSTEM_TEMPLATE_READ_ONLY`.
    - Not found / deleted → 404 `TEMPLATE_NOT_FOUND`.
    - Provided `subject` or `bodyHtml` empty → 400 `VALIDATION_ERROR`.

**Functionalities**
- **Normal Flow**
    - 1. A member clicks Edit on a row.
    - 2. The member changes the fields.
    - 3. The system validates, sanitizes and persists the change.
    - 4. The list refreshes with the updated template.

- **Abnormal Cases**
    - 3.a1: Caller lacks permission → 403 `FORBIDDEN`.
    - 3.a2: System template → 403 `SYSTEM_TEMPLATE_READ_ONLY`.
    - 3.a3: Template missing → 404 `TEMPLATE_NOT_FOUND`.

**Post-Conditions**

- The targeted `mail_templates` document is updated in place; existing batches are unaffected.

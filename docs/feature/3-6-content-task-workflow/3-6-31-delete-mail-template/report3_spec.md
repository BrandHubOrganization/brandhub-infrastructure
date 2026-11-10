**3.6.31 Delete Mail Template**

**Function Trigger**

A member clicks Delete on a Mail Template row and confirms the dialog.

**Function Description**

- **Actors / Roles**: The template's creator, or OWNER/MANAGER of the Workspace.
- **Purpose**: Remove an unused template while keeping send history intact.
- **Interface**: A Delete action in the list row with a confirm dialog.
- **Data Processing**: The system soft-deletes the template by setting `deletedAt`.

**Screen Layout**

Figure — Delete Mail Template Confirm Dialog:

- Template name, warning text, Cancel / Delete buttons.

**Function Details**
- **Data Specifications**
    - **Input required**: `templateId` (path param).
    - **Input optional**: none.
    - **System data**: `mail_templates` document.
    - **Output**: `null` data payload on success.

- **Business Rules**
    - Delete is soft (`deletedAt`), never a hard removal; there is no restore.
    - Batches already sent or scheduled and the send history are not affected.
    - System templates are not deletable from a Workspace.

- **Validation**
    - Not permitted → 403 `FORBIDDEN`; system template → 403 `SYSTEM_TEMPLATE_READ_ONLY`.
    - Not found → 404 `TEMPLATE_NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    - 1. A member clicks Delete and confirms.
    - 2. The system verifies ownership/role and soft-deletes the template.
    - 3. The template disappears from the list.

- **Abnormal Cases**
    - 2.a1: Caller lacks permission → 403 `FORBIDDEN`.
    - 2.a2: Template missing or already deleted → 404 `TEMPLATE_NOT_FOUND`.

**Post-Conditions**

- The `mail_templates` document is marked deleted and excluded from lists; related batches and deliveries remain.

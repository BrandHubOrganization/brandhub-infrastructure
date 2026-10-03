**3.6.31 Delete Mail Template**

**Function Trigger**

A Workspace member clicks Delete on a Mail Template row, confirming via dialog.

**Function Description**

- **Actors / Roles**: Member (same role as 3.6.28).
- **Purpose**: Let a Workspace member remove an unused email template to keep the list tidy.
- **Interface**: A Delete action in the list row with a confirm dialog.
- **Data Processing**: The system soft-deletes a `MailTemplate` row, consistent with other delete patterns in the system.

**Screen Layout**

Figure — Delete Mail Template Confirm Dialog:

- Confirm dialog: template name, warning text, Cancel / Delete buttons.

**Function Details**
- **Data Specifications**
    - **Input required**: `templateId` (path param).
    - **Input optional**: none.
    - **System data**: `MailTemplate` entity.
    - **Output**: `null` data payload on success.

- **Business Rules**
    - Delete is soft (consistent with other delete patterns in the system), not a hard row removal.

- **Validation**
    - Caller lacks permission → 403 `FORBIDDEN`.

**Functionalities**
- **Normal Flow**
    - 1. A member clicks Delete on a Mail Template row and confirms via dialog.
    - 2. The system soft-deletes the template.

- **Abnormal Cases**
    - 2.a1: Caller lacks permission → 403 `FORBIDDEN`.

**Post-Conditions**

- The targeted `MailTemplate` row is marked deleted (soft delete) and excluded from the list view.

**3.6.30 Update Mail Template**

**Function Trigger**

A Workspace member clicks Edit on a Mail Template row in the list.

**Function Description**

- **Actors / Roles**: Member (same role as 3.6.28).
- **Purpose**: Let a Workspace member edit an existing email template's name/subject/body to keep content current.
- **Interface**: An edit form (same fields as create) opened from the list's Edit action.
- **Data Processing**: The system patches an existing `MailTemplate` row.

**Screen Layout**

Figure — Edit Mail Template Form:

- Same fields as Create (`name`, `subject`, `body`), pre-filled with the current values.
- Save / Cancel actions.

**Function Details**
- **Data Specifications**
    - **Input required**: `templateId` (path param).
    - **Input optional**: `name`, `subject`, `body` — any subset (PATCH semantics).
    - **System data**: `MailTemplate` entity.
    - **Output**: the updated template object.

- **Business Rules**
    - Only a caller with the permitted role may update a template.

- **Validation**
    - Caller lacks permission → 403 `FORBIDDEN`.

**Functionalities**
- **Normal Flow**
    - 1. A member clicks Edit on a Mail Template row.
    - 2. The member changes `name`/`subject`/`body`.
    - 3. The system persists the change and returns the updated template.

- **Abnormal Cases**
    - 2.a1: Caller lacks permission → 403 `FORBIDDEN`.

**Post-Conditions**

- The targeted `MailTemplate` row is updated in place.

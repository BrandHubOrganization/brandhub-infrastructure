**3.6.29 Create Mail Template**

**Function Trigger**

A Workspace member clicks "Create Template" on `/workspaces/:id/mail-templates`.

**Function Description**

- **Actors / Roles**: Member (same role as 3.6.28).
- **Purpose**: Let a Workspace member create a new email template (optionally cloned from an Admin-provided starter template) to standardize Client communication.
- **Interface**: A create form with `name`, `subject`, `body` (rich text/HTML) fields, with an optional "clone from template" starting point.
- **Data Processing**: The system persists a new `MailTemplate` row scoped to the Workspace.

**Screen Layout**

Figure — Create Mail Template Form:

- Fields: `name`, `subject`, `body` (rich text/HTML editor).
- Optional "Use existing template" selector listing Admin-provided starter templates to clone from.
- Save / Cancel actions.

**Function Details**
- **Data Specifications**
    - **Input required**: `name`, `subject`, `body`.
    - **Input optional**: a source template ID to clone from (if an Admin-provided one exists).
    - **System data**: `MailTemplate` entity.
    - **Output**: `{id}` of the created template.

- **Business Rules**
    - A template may be cloned from an Admin-supplied starter template, then customized.

- **Validation**
    - `subject`/`body` empty → 400 `VALIDATION_ERROR`.

**Functionalities**
- **Normal Flow**
    - 1. A member clicks "Create Template" on the Mail Template list.
    - 2. The member fills `name`/`subject`/`body`, optionally starting from a cloned Admin template.
    - 3. The system creates the `MailTemplate` and returns its id.

- **Abnormal Cases**
    - 2.a1: `subject` or `body` left empty → 400 `VALIDATION_ERROR`.

**Post-Conditions**

- A new `MailTemplate` row is created, scoped to the Workspace.

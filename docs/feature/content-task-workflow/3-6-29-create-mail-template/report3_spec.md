**3.6.29 Create Mail Template**

**Function Trigger**

A member clicks "Create Template" on `/workspaces/:id/mail-templates`, or "Use template" on a system template.

**Function Description**

- **Actors / Roles**: OWNER, MANAGER, CREATOR of the Workspace.
- **Purpose**: Let a member create a standard email with variables, optionally cloned from a system or existing template, with attachments and inline images.
- **Interface**: A create form with `name`, `subject`, a TipTap rich-text editor for `bodyHtml` (insert variable, insert image), attachment upload and a "Use system template" selector.
- **Data Processing**: The system sanitizes `bodyHtml` with an allow-list, validates the attachments, and persists a new `mail_templates` document scoped to the Workspace.

**Screen Layout**

Figure — Create Mail Template Form:

- Fields: `name` (≤120), `subject` (≤200), `bodyHtml` (≤100KB, TipTap).
- Toolbar actions: insert `{{variable}}`, insert image.
- Attachments: upload up to 3 files (5MB each, 10MB total).
- "Use system template" selector; Save / Cancel.

**Function Details**
- **Data Specifications**
    - **Input required**: `name`, `subject`, `bodyHtml`.
    - **Input optional**: `attachmentIds[]`, `cloneFromId`.
    - **System data**: `mail_templates` document (`workspaceId`, `type=CUSTOM`, `clonedFromId`, `createdBy`, timestamps).
    - **Output**: the created template (`201`).

- **Business Rules**
    - `bodyHtml` is sanitized server-side (no script, style, event handlers, `javascript:`; images only from the system bucket).
    - Cloning copies content and attachments from a system template or from a template of the same Workspace; the clone is always `CUSTOM`.
    - Attachments must belong to the same Workspace; allowed types `pdf, png, jpg, gif, docx, xlsx, pptx`, magic bytes verified.

- **Validation**
    - `subject` or `bodyHtml` empty → 400 `VALIDATION_ERROR`.
    - Invalid attachment → 400 `MAIL_ATTACHMENT_INVALID`.
    - `cloneFromId` not visible to the Workspace → 404 `TEMPLATE_NOT_FOUND`.

**Functionalities**
- **Normal Flow**
    - 1. The member clicks "Create Template" (optionally selects a system template to clone).
    - 2. The member fills the form, inserts variables/images and uploads attachments.
    - 3. The system validates and sanitizes the content.
    - 4. The system creates the template and returns it.

- **Abnormal Cases**
    - 3.a1: Empty subject/body → 400 `VALIDATION_ERROR`; the form keeps the entered data.
    - 3.a2: Attachment rejected → 400 `MAIL_ATTACHMENT_INVALID`.
    - 1.a1: Caller lacks permission → 403 `FORBIDDEN`.

**Post-Conditions**

- A new `mail_templates` document exists for the Workspace.

**3.6.32 Send Email via Template**

**Function Trigger**

A Workspace member clicks "Send Email" in a Mail Template's detail view, or directly from a Client page.

**Function Description**

- **Actors / Roles**: Member (same role as 3.6.28).
- **Purpose**: Let a Workspace member send an actual email to a Client using a chosen Mail Template, with placeholder variables (e.g. `{{clientName}}`) filled in.
- **Interface**: A send form/button offering template selection, recipient (Client) selection, and placeholder fields.
- **Data Processing**: The system renders the template's body with the supplied variables and dispatches it via the email service, logging the send.

**Screen Layout**

Figure — Send Email via Template View:

- Template selector (pre-filled when launched from a template's detail view).
- Recipient picker scoped to the Workspace's Clients.
- Placeholder variable fields (e.g. `{{clientName}}`), auto-detected from the template body.
- "Send" action.

**Function Details**
- **Data Specifications**
    - **Input required**: `templateId` (path param), `recipientEmail`.
    - **Input optional**: `variables` — a key/value map for placeholder substitution (e.g. `{{clientName}}`).
    - **System data**: `MailTemplate` entity, the Workspace's Client list (recipient picker source), send-history log.
    - **Output**: `{messageId}`.

- **Business Rules**
    - Recipient must be a Client belonging to the Workspace.
    - Placeholder variables in the body (e.g. `{{clientName}}`) are substituted before sending.
    - Every send is logged to history.

- **Validation**
    - Email service failure → 502 `EMAIL_SERVICE_UNAVAILABLE`.

**Functionalities**
- **Normal Flow**
    - 1. A member opens a Mail Template's detail view (or a Client page) and clicks "Send Email".
    - 2. The member selects/confirms the recipient Client and fills any placeholder values.
    - 3. The system substitutes placeholders into the template body and sends the email via the email service.
    - 4. The system logs the send to history.

- **Abnormal Cases**
    - 3.a1: Email service is down → 502 `EMAIL_SERVICE_UNAVAILABLE`.

**Post-Conditions**

- An email is dispatched to the Client, and a send-history entry is recorded.

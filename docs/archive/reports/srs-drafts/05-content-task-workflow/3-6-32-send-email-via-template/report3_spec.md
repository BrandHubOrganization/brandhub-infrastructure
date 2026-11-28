**3.6.32 Send Email via Template**

**Function Trigger**

A member clicks "Send" on a Mail Template (list or detail), or "Send email" on a Client page.

**Function Description**

- **Actors / Roles**: OWNER, MANAGER, CREATOR of the Workspace.
- **Purpose**: Send an email built from a template to a Client or to a list of recipients (for example a campaign's target customers), immediately or at a scheduled time, within Gmail-safe sending limits.
- **Interface**: A send modal with template selector, recipient input (paste or CSV upload with column mapping), variable fields auto-detected from the template, attachment toggle, preview, "Send test to me", schedule picker and a quota indicator.
- **Data Processing**: The system validates and renders each recipient row, rejects invalid rows, checks the remaining daily quota, stores a batch with one delivery per recipient, and a background worker sends them through SMTP with throttling and retry. A batch can be scheduled; the content is snapshotted at schedule time.

**Screen Layout**

Figure — Send Email via Template Modal:

- Template selector (pre-filled from the launch point).
- Recipients: paste area / CSV upload (first column `email`, other columns become variables), list of rejected rows.
- Variables: auto-detected `{{name}}`, filled from CSV columns or shared fields.
- Attachments: defaults from the template, removable/addable (limits 3 files, 5MB each, 10MB total).
- Actions: Preview, Send test to me, Schedule (date/time, 5 min – 30 days), Send now; quota remaining today.

**Function Details**
- **Data Specifications**
    - **Input required**: `templateId` (path param), `recipients[]` (`email`, optional `name`, `variables`).
    - **Input optional**: `variables` (shared), `attachmentIds[]`, `scheduledAt`.
    - **System data**: `mail_templates`, `mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, Workspace clients/members.
    - **Output**: `202 {batchId, status, total, accepted, rejected[], scheduledAt}`.

- **Business Rules**
    - Up to 200 recipients per send; duplicates (case-insensitive) and invalid emails are rejected row by row.
    - Missing variable in a row → that row is rejected; variable values are HTML-escaped; a sent mail never contains a raw `{{...}}`.
    - Limits: 450 mails/day system-wide, 100/day per Workspace, 20 mails/minute. Send-now above the remaining Workspace quota is refused with 429; scheduled batches are accepted and deferred to the next day when the quota runs out.
    - Recipients that are Clients or active members of the Workspace are treated as transactional (no unsubscribe footer). All others get a footer and `List-Unsubscribe` headers and are skipped when suppressed (per Workspace).
    - From is the system mail-from; Reply-To is the sender's email.
    - Each delivery is retried up to 5 times with backoff; failures are isolated per recipient.
    - The sender is notified in-app when the batch completes or fails; history is kept for 12 months.

- **Validation**
    - Empty/over-limit recipients, all rows rejected → 400 `VALIDATION_ERROR`.
    - `scheduledAt` outside [now+5 min, now+30 days] → 400 `MAIL_SCHEDULE_OUT_OF_RANGE`.
    - Quota exceeded → 429 `MAIL_QUOTA_EXCEEDED`.
    - Template not found/deleted → 404 `TEMPLATE_NOT_FOUND`; not permitted → 403 `FORBIDDEN`.
    - Test send with SMTP down → 502 `EMAIL_SERVICE_UNAVAILABLE`.

**Functionalities**
- **Normal Flow**
    - 1. A member opens the modal from a template or a Client page.
    - 2. The member provides recipients and variables, previews, optionally sends a test.
    - 3. The member sends now or schedules.
    - 4. The system returns 202 with the batch id and any rejected rows.
    - 5. The worker delivers each email and updates the delivery status; the batch completes and the sender is notified.

- **Abnormal Cases**
    - 3.a1: Quota would be exceeded for a send-now → 429; the member can schedule instead.
    - 4.a1: Some rows invalid/missing variables → returned in `rejected[]`, the rest are sent.
    - 5.a1: One recipient fails SMTP → retried, then marked `FAILED`; other recipients are unaffected.
    - 5.a2: Recipient is suppressed → delivery `SUPPRESSED`, nothing is sent.
    - 5.a3: Quota exhausted at run time → remaining deliveries wait and are sent the next day.

**Post-Conditions**

- A batch and its deliveries are recorded; emails are dispatched (now or at the scheduled time); history, counters and quota usage are updated.

**3.10.1 Push Notification**

**Function Trigger**

Begins when an Administrator (ADMIN) navigates to /admin/notifications and clicks the "Compose Notification" button.

**Function Description**

- **Actors / Roles**: ADMIN. System administrator with full administrative authority to issue and broadcast notifications across the platform.
- **Purpose**: Compose and send system notifications by EMAIL, immediately or on a schedule. In-app and FCM delivery are deferred.
- **Interface**: System Notification Screen (SCR-ADM-01), with email composition, audience criteria, draft/schedule controls and delivery history.
- **Data Processing**: Verify ADMIN, validate message and audience criteria, persist draft/schedule, and resolve recipients at actual send time. Dispatch through the email service and record delivery outcomes and audit events; protect dispatch against concurrent edit/cancel and duplicate retries.

**Screen Layout**

Figure — System Push Notification Screen (SCR-ADM-01, full-width admin form layout):

- Left/Header: Sidebar Admin Navigation; Top Header displaying page title "System Notification Management" and button "Compose New Notification".
- Center: Title (5–200 characters), body (10–5,000), type (System/Maintenance/Update/Promotion), audience ALL/BY_PLAN/BY_ROLE, catalog plan selector or ADMIN/USER selector, optional action URL, schedule time and timezone. Show estimated recipients separately from final recipients.
- Buttons: Send Now, Schedule Delivery, Save Draft; edit/cancel only DRAFT or SCHEDULED. Sent messages cannot be recalled.
- Footer: History and pagination; status DRAFT, SCHEDULED, SENT, FAILED or CANCELLED; delivery counts and failure details. SENT records completed dispatch, not proof that recipients read the email.

**Function Details**

- **Data Specifications**
    - **Input required**: title (5–200), content (10–5,000), type (SYSTEM, MAINTENANCE, UPDATE, PROMOTION), targetType (ALL, BY_PLAN, BY_ROLE).
    - **Input optional**: targetPlans (catalog IDs, required for BY_PLAN), targetRoles (ADMIN/USER, required for BY_ROLE), scheduledAt (ISO timestamp with offset), actionUrl.
    - **System data**: notificationId, senderId, channel=EMAIL, status (DRAFT, SCHEDULED, SENT, FAILED, CANCELLED), createdAt, sentAt, recipientCount, deliveryResults.
    - **Output**: Created notification record payload with HTTP status code 201 Created.

- **Business Rules**
    - **BR-35**: All broadcast operations require authenticated ADMIN authority.
    - **BR-57**: This phase sends EMAIL only; title is 5–200 and content 10–5,000 characters. In-app and FCM are outside this phase.
    - **BR-65**: Resolve recipients at actual send time using the saved audience criteria. Preview counts are estimates; an empty audience completes with recipientCount=0.
    - **BR-82**: BY_ROLE accepts ADMIN/USER only; BY_PLAN uses the existing subscription catalog. Agency membership roles are not system roles.
    - **BR-57**: Only DRAFT and SCHEDULED may be edited/cancelled. Cancel sets CANCELLED and prevents dispatch. Sending locks the revision; sent email cannot be recalled. Record partial failures and retry only unsent recipients.
    - **BR-16**: Audit creation, editing, scheduling, cancellation and dispatch with actor, criteria, timestamps and final recipient counts.

- **Validation**
    - User does not possess ADMIN role permissions → Display: MSG39
    - Notification title or content is empty → Display: MSG02
    - Notification title or content length exceeds allowed boundaries → Display: MSG03
    - Scheduled delivery timestamp is invalid or set in the past → Display: MSG45
    - Notification dispatched or scheduled successfully → Display: MSG144

**Functionalities**

- **Normal Flow**
    1. Admin opens SCR-ADM-01 and composes an email notification.
    2. Admin selects audience criteria and saves a draft, sends now or schedules a future timestamp.
    3. System validates content, catalog values and ADMIN authority; persists the chosen action and audit event.
    4. Admin may edit/cancel while DRAFT or SCHEDULED; worker verifies the current revision before sending.
    5. At actual dispatch, resolve recipients using current roles/plans and send email.
    6. Record delivery results, final recipient count, status and audit; refresh history.

- **Abnormal Cases**
    - 1.a1: Missing ADMIN authority → MSG39; invalid mandatory fields → MSG02/MSG03.
    - 2.a1: Schedule in the past or missing audience criteria → validation error; no dispatch.
    - 4.a1: Edit/cancel after dispatch started or on SENT/FAILED/CANCELLED → conflict; do not recall sent email.
    - 5.a1: Email outage/partial failure → retain delivery results and allow safe delivery retry without resending successful recipients.

**Post-Conditions**

- Notification content, audience criteria, lifecycle status and delivery outcomes are persisted.
- Only eligible recipients at dispatch time receive EMAIL; cancelled jobs do not dispatch.
- Every administrative change and dispatch has an immutable audit trail.

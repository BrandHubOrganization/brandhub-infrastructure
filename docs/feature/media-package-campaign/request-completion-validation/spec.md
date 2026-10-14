# Confirmed rules — 2026-10-14

Later 2026-10-14 confirmation: see ../campaign-closure/spec.md. Completion now blocks on all nonterminal Tasks and IN_PROGRESS Requests. Newly accepted Request Tasks belong to current Campaign; the earlier allowance for post-completion IN_PROGRESS processing no longer allows Task creation after closure. PENDING automatic cancellation remains.

User confirmation supersedes the 2026-10-13 rule that kept PENDING editable after completion. Manager marking Campaign COMPLETED blocks new Requests and automatically cancels only PENDING Requests, with history; IN_PROGRESS continues. Calendar expiry alone does not complete a Campaign.

Create/update deadlines must fall between max(today in Workspace timezone, Campaign startDate) and Campaign endDate, inclusive. No deadline inside this interval means no valid submission. Cancellation is exempt from deadline validation.

UI refinement confirmed 2026-10-14: constrain the native date/time picker using this same inclusive interval. Fetch current Campaign dates and Workspace timezone when create/edit opens; convert Workspace day boundaries to browser-local date/time for min/max without changing the existing input timezone convention. Show the available interval and input timezone. Loading/missing/invalid dates or no remaining interval disables saving with explanation/retry; never silently expand dates or clamp the user's value. Refresh bounds on focus and periodically across day rollover. Manual typing is checked by native validity and inline error; API remains authoritative for concurrent changes/bypasses. Parallel vi/en requests.deadline* labels; existing semantic theme tokens.

Agency partner directory supports Vietnam and international telephone formats. Validate format, not real ownership: optional phone, formatted spaces/hyphens/parentheses, optional leading +, 7–15 digits; no arbitrary long digit strings. A leading + cannot be followed by country code 0. Local forms are not assumed to belong to a particular country. Optional email and HTTP(S) website are validated server-side and client-side. Existing arbitrary contact JSON keys are preserved.

UI retains existing layout/themes. Add parallel vi/en collaborators.invalidPhone/invalidEmail/invalidWebsite; errors adjacent to fields. Request dueDate errors use existing field-error UI. Authentication 401 diagnosis only: no shared auth modifications.

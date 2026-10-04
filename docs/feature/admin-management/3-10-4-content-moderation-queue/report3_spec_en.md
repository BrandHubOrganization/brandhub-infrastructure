**3.10.4 Content Moderation Queue**

**Function Trigger**

Admin opens /admin/content-moderation to review flagged post content or submissions from FLAGGED users.

**Function Description**

- **Actors / Roles**: ADMIN. Content moderation administrator with executive authority to approve publications or block violating content.
- **Purpose**: Review post content at a specific version. ADMIN approval is required for flagged users; blocking one version permits a revised version to be submitted.
- **Interface**: Content Moderation Queue Screen (SCR-ADM-04), comprising a pending moderation table, split-pane comparison review drawer (side-by-side original copy vs. suspect snippet), verdict action buttons, and justification note field.
- **Data Processing**: The content/publishing integration supplies postId, contentVersionId, author and content snapshot/reason to create PENDING_MODERATION. Hold scheduled publications when the author becomes FLAGGED. At dispatch, check current account status, version and ADMIN verdict again. APPROVE permits the normal publication workflow/schedule; BLOCK blocks that version and records a selected strike through FR 3.10.5. RED/three ORANGE creates a review request, never an automatic lock.

**Screen Layout**

Figure — Content Moderation Queue Screen (SCR-ADM-04, list and modal review interface):

- Left/Header: Sidebar Admin Navigation; Top Header displaying title "Content Moderation Queue", pending review count, and violation type filter (Policy, Copyright).
- Center: Queue: Post ID, version, author, active YELLOW/ORANGE/RED counters, flag source, reason and time. Review drawer compares the submitted content snapshot and evidence; choose strike severity for confirmed violations and enter justification.
- Buttons: Button "Confirm Violation & Record Strike" (red), Button "Override Warning & Allow Publication" (green), Justification Note input (mandatory when overriding warning), Button "Close".
- Footer: Table pagination controls (10, 20, 50 rows/page) and daily resolved content items counter.

**Function Details**

- **Data Specifications**
    - **Input required**: moderationId, postId, contentVersionId, decision (approve/block); note at least 10 characters for approve; strikeLevel and justification for block.
    - **Input optional**: violationCategory, evidence references.
    - **System data**: creatorId, reviewerId, content snapshot, current account status, activeStrikeCounts, moderation state and revision, reviewedAt.
    - **Output**: Moderation adjudication outcome JSON payload with HTTP status code 200 OK.

- **Business Rules**
    - **BR-64**: Moderate post content by immutable version; embedded asset evidence is not an independent approval of every asset.
    - **BR-35**: Only ADMIN may approve this queue. Manager/Client workflow approval does not satisfy this requirement.
    - **BR-64**: FLAGGED holds existing scheduled posts and future submissions for ADMIN review. A queued job must recheck status and the exact approved version before dispatch.
    - **BR-64**: BLOCK applies to the reviewed version; author may revise and resubmit a new version. APPROVE does not immediately publish or bypass schedule and other workflow gates.
    - **BR-94**: YELLOW is a warning. An active ORANGE strike sets FLAGGED and requires ADMIN approval for publishing; login remains available. RED or three active ORANGE strikes creates a sanction review request under FR 3.10.9; only Admin confirmation deactivates the account.
    - **BR-95**: Three active, unconverted YELLOW strikes of any violation category produce one independent ORANGE strike. Mark all three source strikes converted and retain their linkage. A fourth YELLOW starts the next batch; six qualifying YELLOW strikes produce two ORANGE strikes. A direct ORANGE can also be recorded. Pardoning a source YELLOW does not pardon the derived ORANGE.
    - **BR-96**: Each new violation restarts the account clean period of 30 consecutive days without violations. Still-active strikes expire after that clean period, not individually 30 days after creation. Expired or pardoned strikes are not revived; conversion does not count as a second violation. Expiration and pardon preserve immutable history. Removing the last active ORANGE restores publishing eligibility only if no deactivation or activation restriction remains.
    - **BR-16**: Audit reviewer, post/version, evidence, verdict, strike linkage and justification; concurrent or repeated decisions must not duplicate strikes.

- **Validation**
    - Missing ADMIN authority → MSG39 (403).
    - Post/version or moderation item does not exist → MSG38 (404).
    - Item already resolved or submitted version changed → conflict (409); reload current state.
    - APPROVE note missing or shorter than 10 characters → MSG80; BLOCK without severity/justification → validation error.
    - Approval saved → MSG42; reviewed version blocked → MSG43.

**Functionalities**

- **Normal Flow**
    1. Integration creates or reuses a pending moderation entry for the post version.
    2. Admin inspects the content snapshot, reason, author status and evidence.
    3. Admin approves with a note of at least 10 characters, or blocks with severity and justification.
    4. System atomically validates the pending revision, saves the verdict, records the strike if blocked and audits the action.
    5. Notify the author by email. Approved versions may continue the normal workflow; blocked versions require revision and a new review.
    6. Publisher rechecks the exact version and current account/moderation restrictions before dispatch.

- **Abnormal Cases**
    - 1.a1: Missing post/version → not found; repeated event → reuse the same pending entry.
    - 3.a1: Missing ADMIN authority or insufficient approval note → MSG39/MSG80.
    - 4.a1: Another Admin resolved the item or the submitted version changed → conflict; reload, do not apply the old verdict to the new version.
    - 6.a1: Account becomes FLAGGED/DEACTIVATED or approved version no longer matches → hold publication and re-evaluate the gate.

**Post-Conditions**

- Verdict is attached to the reviewed version, with immutable audit and strike linkage.
- FLAGGED publications, including previously scheduled posts, require ADMIN approval.
- BLOCKED_CONFIRMED versions cannot publish; revised versions can re-enter PENDING_MODERATION.
- No RED or ORANGE threshold deactivates an account without FR 3.10.9 Admin confirmation.

**3.3.4 Update Client Profile**

**Function Trigger**

Begins when a user acting as a Client saves edits to their Client Profile form in the context of a specific Agency.

**Function Description**

- **Actors / Roles**: A user acting as a Client in a workspace of an Agency; the update applies only to the Agency currently in context.
- **Purpose**: Let a Client keep the information one Agency sees up to date. The email address cannot be changed — it is the fixed identity of the user and is not held on the Client Profile.
- **Interface**: The Client Profile screen (3.3.3) in edit mode, scoped to the Agency currently in context. Editable fields: display name (required), company, phone number, note, logo, website, industry, location, description, social links. No email field in the form.
- **Data Processing**: The system resolves the caller's identity from the access token only, looks up the Client Profile by the pair (user, agency), creates it when absent (upsert), writes the complete submitted field set over the record, stamps the update time, and persists. The same record backs every workspace of that Agency, so a change is visible in all of them at once.

**Screen Layout**

Figure — Client Profile Screen (/client-profile, edit mode, Agency context):

- Header: page title "Client Profile" and the Agency currently in context.
- Center: display name input (required), company, phone number, note, logo, website, industry, location, description, social links inputs.
- Buttons: Save (primary); Cancel — discards the changes.
- Footer: none.
- No email field is present in the form.

**Function Details**
- **Data Specifications**
    - **Input required**: displayName; the Agency identifier.
    - **Input optional**: company, phone, note, logoUrl, website, industry, location, description, socialLinks.
    - **System data**: client_profiles, keyed by (userId, agencyId) — id, userId, agencyId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, createdAt, updatedAt.
    - **Output**: The complete Client Profile field set after the record is created or updated.

- **Business Rules**
    - The action is an upsert: when no Client Profile exists for the (user, agency) pair, the system creates one instead of returning 404.
    - The update is a full overwrite, not a partial patch — fields left out are written as empty.
    - **BR-38**: Client access is scoped by clientId (agencyId); the update always applies to a single Agency and does not affect other Agencies' records.
    - **BR-19**: Email and role are not mutable via this action; the request carries no email field.
    - Because every workspace of the same Agency reads the same record, a successful update is reflected immediately in all workspaces of that Agency.
    - displayName is mandatory and must not be blank.

- **Validation**
    - displayName empty or blank → Display: **MSG02**.
    - Missing Agency identifier → Display: **MSG02**.
    - Missing, expired, or invalid access token → Display: **MSG22**.

**Functionalities**
- **Normal Flow**
    1. The user edits the Client Profile form in the context of the current Agency and clicks Save.
    2. The application submits the complete set of Client Profile fields that should be kept.
    3. The system resolves the caller's identity from the access token.
    4. The system looks up the Client Profile by the pair (user, agency).
    5. When the record exists it is updated; when it does not, the system creates it (upsert).
    6. The system writes the submitted fields over the record (full overwrite) and stamps the update time.
    7. The system persists the record and returns the complete Client Profile field set.
    8. The application confirms success and refreshes the display immediately; the new values appear in every workspace of that Agency at once; toast **MSG26**.

- **Abnormal Cases**
    - 1.a1: displayName submitted empty or blank, the system displays **MSG02**. 1.a2: The user re-enters a display name and saves again.
    - 2.a1: No Agency identifier is supplied, the system displays **MSG02**. 2.a2: The user selects an Agency context and retries.
    - 5.a1: First update for an Agency with no Client Profile yet, the record is created (upsert), not a 404. 5.a2: The application saves the submitted fields as a new record.
    - 8.a1: The Client updates their display name while tasks are pending approval in several workspaces of the same Agency, the update still succeeds. 8.a2: The new name applies immediately everywhere in that Agency.
    - 8.b1: An email address is submitted, it cannot be carried by the update request. 8.b2: The field is silently ignored; the record is saved without an email change.
    - N.a1: Missing, expired, or invalid access token at any step, the system displays **MSG22**. N.a2: The user signs in again at /login (3.2.2).

**Post-Conditions**

- A Client Profile exists for the (user, agency) pair and holds exactly the submitted field values; fields left out are empty (full overwrite, not a partial patch).
- The updated values are visible in every workspace of the same Agency.
- Records belonging to other Agencies are unchanged.

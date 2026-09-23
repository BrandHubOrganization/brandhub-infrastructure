# 3.3.4 Update Client Profile

## Function Trigger

Begins when a user acting as a Client saves edits to their Client Profile form in the context of a specific Agency.

## Function Description

- **Actors / Roles:** A user acting as a Client in a workspace of an Agency; the update applies only to the Agency currently in context.
- **Purpose:** Let a Client keep the information one Agency sees up to date. The email address cannot be changed — it is the fixed identity of the user and is not held on the Client Profile. Keeping it fixed lets the Agency always identify the Client correctly.
- **Interface:** The Client Profile screen (3.3.3) in edit mode, scoped to the Agency currently in context. Editable fields: display name (required), company, phone number, note, logo, website, industry, location, description, and social links. There is no email field in the form. Saving submits an update of the Client Profile for the current Agency.
- **Data Processing:** The system resolves the caller's identity from the access token only, looks up the Client Profile by the pair (user, agency), creates it when absent (upsert), writes the complete submitted field set over the record, stamps the update time, and persists. The same record backs every workspace of that Agency, so a change is visible in all of them at once.

## Screen Layout

Figure — Client Profile Screen (`/client-profile`, edit mode, Agency context):

- Header: page title "Client Profile" and the Agency currently in context.
- Center: the Client Profile card in edit mode — display name input (required), and company, phone number, note, logo, website, industry, location, description, and social links inputs.
- Buttons: Save (primary) — submits the update; Cancel — discards the changes.
- Footer: none.
- No email field is present in the form.

## Function Details

### Data Specifications

- **Input required:** `displayName`; and the Agency identifier.
- **Input optional:** `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`.
- **System data:** `client_profiles`, keyed by the pair (userId, agencyId) — `id`, `userId`, `agencyId`, `displayName`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`, `createdAt`, `updatedAt`.
- **Output:** The complete Client Profile field set after the record is created or updated.

### Business Rules

- **BR-01:** The action is an upsert — when no Client Profile exists for the (user, agency) pair, the system creates one instead of returning 404. A Client Profile is therefore created either when a Client invitation is accepted or on the first update for that Agency; both paths are valid.
- **BR-02:** The update is a full overwrite, not a partial patch — every call must submit all fields that should be kept, because fields left out are written as empty.
- **BR-03:** The update always applies to a single Agency; editing the Client Profile for Agency A does not affect the record held for Agency B.
- **BR-04:** The update request carries no email field, so an email address cannot be submitted through this action. There is no dedicated error code for this case — it is structurally impossible rather than explicitly rejected.
- **BR-05:** Because every workspace of the same Agency reads the same (user, agency) record, a successful update is reflected immediately in all workspaces of that Agency, with no manual synchronization.
- **BR-06:** `displayName` is mandatory and must not be blank.

### Validation

- `displayName` empty or blank → 400 `VALIDATION_ERROR`.
- Missing Agency identifier → 400 `VALIDATION_ERROR`.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`.

## Functionalities

### Normal Flow

1. The user edits the Client Profile form in the context of the current Agency and clicks Save.
2. The application submits the complete set of Client Profile fields that should be kept.
3. The system resolves the caller's identity from the access token.
4. The system looks up the Client Profile by the pair (user, agency).
5. When the record exists it is updated; when it does not, the system creates it (BR-01).
6. The system writes the submitted fields over the record (BR-02) and stamps the update time.
7. The system persists the record and returns the complete Client Profile field set.
8. The application confirms success and refreshes the display immediately; because all workspaces of the Agency share this record, the new values appear everywhere in that Agency at once (BR-05).

### Abnormal Cases

- `displayName` empty or blank → 400 `VALIDATION_ERROR`.
- Missing Agency identifier → 400 `VALIDATION_ERROR`.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`.
- First update for an Agency that has no Client Profile yet → the record is created (upsert), not a 404.
- The Client updates their display name while tasks are pending approval in several workspaces of the same Agency → the new name applies immediately everywhere in that Agency, without manual synchronization (BR-05).
- An email address is submitted → it cannot be carried by the update request, so it is never applied (BR-04).

## Post-Conditions

- A Client Profile exists for the (user, agency) pair and holds exactly the submitted field values; fields left out are empty (BR-02).
- The updated values are visible in every workspace of the same Agency.
- Records belonging to other Agencies are unchanged.

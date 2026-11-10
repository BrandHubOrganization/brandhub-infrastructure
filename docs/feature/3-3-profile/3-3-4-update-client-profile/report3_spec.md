**3.3.4 Update Client Profile**

> V2 (2026-10-02): ClientProfile reworked — owned by the User, independent of any Agency.

**Function Trigger**

Begins when a user creates a new Client Profile or saves edits to one of their existing Client Profiles, on the "My Brand Profiles" screen (/client-profiles).

**Function Description**

- **Actors / Roles**: Any signed-in user, editing a Client Profile they own.
- **Purpose**: Let a user keep the brand information they represent up to date, or add a new brand profile. The email address cannot be set on a Client Profile — it is always the fixed identity of the owning user.
- **Interface**: The "My Brand Profiles" screen (3.3.3) in create/edit mode. Editable fields: display name (required), company, phone number, note, logo, website, industry, location, description, social links, plus brand fields. No email field for the owner's own identity, and no Agency selector anywhere in the form.
- **Data Processing**: The system resolves the caller's identity from the access token. For create, it inserts a new client_profiles row owned by the caller. For update, it looks up the profile by id, verifies userId matches the caller, writes the complete submitted field set over the record, stamps the update time, and persists. The record is never scoped to an Agency, so the update is visible wherever that profile is linked at once.

**Screen Layout**

Figure — Brand Profile form (/client-profiles, create/edit):

- Center: display name input (required), company, phone number, note, logo, website, industry, location, description, social links, and brand-field inputs.
- Buttons: Save (primary); Cancel; Delete (edit mode only, blocked while linked to an active workspace membership).
- No email field is present in the form.

**Function Details**
- **Data Specifications**
    - **Input required**: displayName.
    - **Input optional**: company, phone, note, logoUrl, website, industry, location, description, socialLinks, plus brand fields (contactName, contactEmail, companySize, instagramUrl, taxCode, address, tagline, foundedYear, budgetRange).
    - **System data**: client_profiles — id, userId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, plus the brand fields above, createdAt, updatedAt.
    - **Output**: The complete Client Profile field set after the record is created or updated.

- **Business Rules**
    - Create and update are separate requests (POST / PUT by id), not an upsert keyed by any (user, agency) pair.
    - The update is a full overwrite, not a partial patch — fields left out are written as empty.
    - **BR-38 (reworked)**: A Client Profile is never scoped to a single Agency — editing it updates the one record everywhere it is linked.
    - **BR-19**: Email and role are not mutable via this action; the request carries no email field for the owner's own account.
    - displayName is mandatory and must not be blank.
    - A Client Profile cannot be deleted while linked to an active workspace membership — CLIENT_PROFILE_IN_USE.

- **Validation**
    - displayName empty or blank → Display: **MSG02**.
    - Update/delete on a profile not owned by the caller → 403 CLIENT_PROFILE_NOT_OWNED.
    - Delete while linked to an active workspace membership → 409 CLIENT_PROFILE_IN_USE.
    - Missing, expired, or invalid access token → Display: **MSG22**.

**Functionalities**
- **Normal Flow**
    1. The user opens "My Brand Profiles", fills the form, and clicks Save.
    2. The application submits the complete set of Client Profile fields.
    3. The system resolves the caller's identity from the access token.
    4. For update, the system looks up the profile by id and verifies ownership.
    5. The system writes the submitted fields over the record and stamps the update time.
    6. The system persists the record and returns the complete Client Profile field set.
    7. The application confirms success and refreshes the list; the new values appear everywhere the profile is linked at once.

- **Abnormal Cases**
    - 1.a1: displayName submitted empty or blank, the system displays **MSG02**. 1.a2: The user re-enters a display name and saves again.
    - 4.a1: The profile id belongs to a different user → 403 CLIENT_PROFILE_NOT_OWNED. 4.a2: The application shows an access-denied error.
    - 7.a1: An email address is submitted for the owner's own identity, it cannot be carried by the request. 7.a2: The field is silently ignored.
    - Delete.a1: The profile is linked to an active workspace membership → 409 CLIENT_PROFILE_IN_USE. Delete.a2: The user removes it from every workspace first.
    - N.a1: Missing, expired, or invalid access token at any step, the system displays **MSG22**. N.a2: The user signs in again at /login (3.2.2).

**Post-Conditions**

- The Client Profile holds exactly the submitted field values; fields left out are empty (full overwrite, not a partial patch).
- The updated values are visible wherever the profile is currently linked, across every Agency.
- Other Client Profiles owned by the same or different users are unchanged.

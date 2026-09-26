**3.3.3 View Client Profile**

**Function Trigger**

Begins when a user acting as a Client opens the Client Profile screen in the context of a specific Agency, or when an Agency member opens the Agency's Client list while adding a Client to a workspace.

**Function Description**

- **Actors / Roles**: A user acting as a Client in a workspace of an Agency; Agency members (Owner/Manager) when viewing the Agency's Client list.
- **Purpose**: Show the Client Profile held for one specific Agency, independently of the user's own User Profile (3.3.1), so the Client can confirm what that Agency sees and details can be reused within the same Agency.
- **Interface**: The Client Profile screen at /client-profile, scoped to the Agency currently in context (taken from the page context / URL). Shows a read-only card. A separate Client list view, also Agency-scoped, shows every Client Profile held by that Agency and is used as a picker when adding a Client to a workspace. The Agency identifier must always be supplied by the caller.
- **Data Processing**: The system resolves the caller's identity from the access token only, looks up the Client Profile by the pair (user, agency), and returns the complete field set. For the list view, the system returns every Client Profile belonging to the given Agency.

**Screen Layout**

Figure — Client Profile Screen (/client-profile, Agency context):

- Header: page title "Client Profile" and the Agency currently in context.
- Center: read-only card — display name, company, phone number, note, logo, website, industry, location, description, social links, created and last-updated dates.
- Buttons: Edit — routes to Update Client Profile (3.3.4).
- Footer: none.
- When no Agency is in context, the screen shows a clear error instead of requesting data.

Figure — Client List (Agency context):

- Center: list of the Agency's Client Profiles — display name, company, contact details.
- Used when adding a Client to a workspace, so an existing Client Profile can be reused.

**Function Details**
- **Data Specifications**
    - **Input required**: The Agency identifier, for both the Client Profile view and the Agency Client list.
    - **Input optional**: None.
    - **System data**: client_profiles, keyed by (userId, agencyId) — id, userId, agencyId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, createdAt, updatedAt.
    - **Output**: The complete Client Profile field set for one Agency, or the list of Client Profiles held by an Agency.

- **Business Rules**
    - **BR-41**: A client account is a member of type CLIENT with read-only + approve/reject scope, never workspace admin. A Client Profile is keyed by (user, agency) and is never global.
    - Reuse of a Client Profile applies only within the same Agency; a new workspace of the same Agency reuses the existing record, while a different Agency uses a separate record.
    - A Client Profile is created only when a Client invitation is accepted, or on the first update for that Agency (upsert — see 3.3.4). Viewing never creates a record.
    - The Agency identifier is mandatory; no default Agency is assumed.
    - **BR-38**: Client access is scoped by clientId (agencyId). A Client Profile is independent of the user's own User Profile — one user may hold both.
    - A user who is a Client of Agency A and Agency B holds two independent records; no data is shared between them.

- **Validation**
    - Missing Agency identifier → Display: **MSG02**.
    - No Client Profile exists for the (user, agency) pair → Display: **MSG38**.
    - Missing, expired, or invalid access token → Display: **MSG22**.

**Functionalities**
- **Normal Flow**
    1. The user opens the Client Profile screen in the context of a specific Agency.
    2. The application determines the Agency identifier from the current context.
    3. The application requests the signed-in user's Client Profile for that Agency.
    4. The system resolves the caller's identity from the access token.
    5. The system looks up the Client Profile by the pair (user, agency).
    6. The system returns the complete Client Profile field set.
    7. The application renders the Client Profile for the Agency currently in context.
    8. Alternatively, an Agency member opens the Agency's Client list; the system returns every Client Profile held by that Agency for selection.

- **Abnormal Cases**
    - 2.a1: No Agency identifier is supplied, the system displays **MSG02**. 2.a2: The user selects an Agency context and retries.
    - 5.a1: No Client Profile exists for the (user, agency) pair, the system displays **MSG38**; viewing never creates one. 5.a2: The user is offered Update Client Profile (3.3.4) to create the record.
    - N.a1: Missing, expired, or invalid access token at any step, the system displays **MSG22**. N.a2: The user signs in again at /login (3.2.2).
    - 7.a1: The user owns Agency A while also being a Client of Agency B, both profiles exist independently. 7.a2: The interface makes clear which context is being viewed.
    - 7.b1: The user is a Client of both Agency A and Agency B, two independent records exist. 7.b2: The application displays each record only within its own Agency context.

**Post-Conditions**

- The Client Profile for the requested Agency is displayed with the values currently stored for that pair.
- No data is changed; the operation is read-only.

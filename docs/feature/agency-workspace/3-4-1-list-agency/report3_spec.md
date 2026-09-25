**3.4.1 List Agency**

**Function Trigger**

Begins when a signed-in user navigates to the Agencies page (/agencies), the default landing page for a user who already owns or belongs to at least one Agency.

**Function Description**

- **Actors / Roles**: Agency Owner or Agency Member.
- **Purpose**: Show every Agency the current user owns or belongs to, so the user can pick one to manage.
- **Interface**: Agencies page — a grid of Agency cards showing name, logo and category, with an empty state and a "Create new Agency" call to action when the user has none.
- **Data Processing**: The system merges the Agencies the user owns with the Agencies where the user holds a Member record, de-duplicates, excludes soft-deleted Agencies, and returns the combined list with each Agency's full profile.

**Screen Layout**

Figure — Agencies page:

- A card per Agency, showing name, logo and category.
- Selecting a card moves the user into that Agency; the Agency Dashboard (3.4.2) has no screen yet, so the Agency Profile (3.4.4) is shown in the meantime.
- Empty state with a "Create new Agency" call to action.

**Function Details**
- **Data Specifications**
    - **Input required**: none.
    - **Input optional**: none.
    - **System data**: Agency profile — id, name, ownerId, logoUrl, description, category, companySize, website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, status (ACTIVE / SOFT_DELETED), createdAt, updatedAt.
    - **Output**: list of Agencies matching the current user, each with the full profile; empty list when the user has none.

- **Business Rules**
    - **BR-29**: Multi-tenancy — list is scoped to Agencies the user owns or belongs to as a Member, whatever the role.
    - Soft-deleted Agencies are excluded from the list.
    - The result carries no pre-computed workspace count.
    - Selecting an Agency leads to the Agency Dashboard (3.4.2); the Agency Profile (3.4.4) stands in until that screen exists.

- **Validation**
    - None — the operation always returns a list, empty or not.

**Functionalities**
- **Normal Flow**
    1. The user opens the Agencies page.
    2. The client requests the Agency list of the signed-in user.
    3. The system gathers owned and member Agencies, merges and de-duplicates, drops soft-deleted entries, and returns the result.
    4. The client renders one card per Agency.
    5. The user selects a card to move into that Agency.

- **Abnormal Cases**
    - 3.a1: User owns and belongs to no Agency → an empty list is returned, no error. 3.a2: The client shows the empty state with the "Create new Agency" call to action.
    - 2.a1: No signed-in session → 401 UNAUTHORIZED before any Agency logic runs.

**Post-Conditions**

- The list reflects exactly the Agencies the current user owns or belongs to, soft-deleted ones excluded.
- No Agency data is created, changed or removed.

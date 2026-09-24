# 3.4.1 List Agency

## Function Trigger
The user navigates to the Agencies page (`/agencies`) after signing in. This is the default landing page when the user already owns or belongs to at least one Agency.

## Function Description
- **Actors / Roles:** Signed-in user (Agency Owner or Agency Member).
- **Purpose:** Present every Agency the current user owns or belongs to, so the user can pick one to manage.
- **Interface:** Agencies page (`/agencies`) — a grid of Agency cards showing name, logo and category, plus an empty state with a "Create new Agency" call to action when the user owns or belongs to no Agency.
- **Data Processing:** The system merges the Agencies where the user is the Owner with the Agencies where the user holds an Agency Member record, de-duplicates the two sources, excludes soft-deleted Agencies, and returns the combined list together with the full profile of each Agency.

## Screen Layout
Figure — Agencies page:
- A card per Agency, each showing name, logo and category.
- Selecting a card moves the user into that Agency. The Agency Dashboard (3.4.2) has no screen of its own yet, so the Agency Profile (3.4.4) is shown in the meantime.
- Empty state with a "Create new Agency" call to action when the user owns or belongs to no Agency.

## Function Details
### Data Specifications
- **Input required:** None — the request carries no parameters and no filters.
- **Input optional:** None.
- **System data:** Agency profile — id (UUID), name, ownerId (UUID), logoUrl, description, category (AgencyCategory: MARKETING, FNB, FASHION, BEAUTY, TECHNOLOGY, REAL_ESTATE, EDUCATION, HEALTHCARE, RETAIL, FINANCE, ENTERTAINMENT, OTHER), companySize (CompanySize: SIZE_1_10, SIZE_11_50, SIZE_51_200, SIZE_201_500, SIZE_500_PLUS), website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, status (EntityStatus: ACTIVE / SOFT_DELETED), createdAt, updatedAt.
- **Output:** The list of Agencies that match the current user, each with the full profile above; an empty list when the user owns or belongs to none.

### Business Rules
- **BR-29:** Multi-tenancy — the list is scoped to the current user: the Agencies where the user is the Owner, plus the Agencies where the user holds an Agency Member record (whatever the role). A user with no active membership or ownership sees nothing beyond that scope.
- Agencies whose status is SOFT_DELETED are left out of the list.
- The result carries no pre-computed workspace count.
- Selecting an Agency leads to the Agency Dashboard (3.4.2). That screen has no data source of its own yet, so the Agency Profile (3.4.4) stands in until it is built.

### Validation
- None — the operation returns a list for every signed-in user, including an empty one.

## Functionalities
### Normal Flow
1. The user opens the Agencies page.
2. The client requests the Agency list of the signed-in user.
3. The system gathers the Agencies owned by the user and the Agencies where the user holds a membership, merges and de-duplicates both sources, drops soft-deleted entries, and returns the result.
4. The client renders one card per Agency, showing name, logo and category.
5. The user selects a card to move into that Agency.

### Abnormal Cases
- The user owns and belongs to no Agency: an empty list is returned rather than an error, and the client shows the empty state with the "Create new Agency" call to action.
- No signed-in session: the request is rejected with `401 UNAUTHORIZED` before any Agency logic runs.

## Post-Conditions
- The list reflects exactly the Agencies the current user owns or belongs to, with soft-deleted Agencies excluded.
- No Agency data is created, changed or removed.

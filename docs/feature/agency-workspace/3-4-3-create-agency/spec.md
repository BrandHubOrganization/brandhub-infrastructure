# 3.4.3 Create Agency

## Function Trigger
A signed-in user submits the Create Agency form — from the Agencies page (`/agencies/create`) or from a dialog opened on that page.

## Function Description
- **Actors / Roles:** Signed-in user, who becomes the Owner of the Agency being created.
- **Purpose:** Let a user open a new Agency on BrandHub and start running their communications company from it.
- **Interface:** Create Agency page (`/agencies/create`) or a dialog on the Agencies page — a form with a required name field and a set of optional branding fields (logo, description, category, company size, website, phone, location, brand colour, logo icon, tagline, founded year, and the Facebook, LinkedIn and Instagram links).
- **Data Processing:** The system validates the submitted form, stores a new Agency with the current user as its Owner and the status ACTIVE, and records the same user as an Agency Member with the OWNER role in the same operation, so the Agency and its creator are permanently paired. The logo is uploaded afterwards through the Agency logo upload, once the Agency has an identifier.

## Screen Layout
Figure — Create Agency form:
- Name (required) and the optional branding fields listed above.
- A logo picker: the file is uploaded after the Agency is created, not through the form itself.
- A submit action; on success the user is taken into the newly created Agency.
- The form is reachable from the Agencies page, where an empty state also offers the same call to action.

## Function Details
### Data Specifications
- **Input required:** Name of the Agency.
- **Input optional:** logoUrl, description, category (AgencyCategory: MARKETING, FNB, FASHION, BEAUTY, TECHNOLOGY, REAL_ESTATE, EDUCATION, HEALTHCARE, RETAIL, FINANCE, ENTERTAINMENT, OTHER), companySize (CompanySize: SIZE_1_10, SIZE_11_50, SIZE_51_200, SIZE_201_500, SIZE_500_PLUS), website, phone, location, brandColor (hex, at most 9 characters), logoIcon, tagline (at most 140 characters), foundedYear, facebookUrl, linkedinUrl, instagramUrl.
- **System data:** The Agency record — id, name, ownerId, logoUrl, description, category, companySize, website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, status (EntityStatus: ACTIVE / SOFT_DELETED), createdAt, updatedAt — and the Agency Member record that pairs the Agency with its Owner at the OWNER role.
- **Output:** The profile of the newly created Agency, including its identifier, its Owner and the status ACTIVE. The Agency is created as a new resource; the logo upload returns the same profile with the logo filled in.

### Business Rules
- **BR-24 (analogous):** Creating an Agency inserts the creator as an Agency Member with `role = OWNER`, mirroring the workspace-creation rule (BR-24) that auto-inserts the creator as `workspace_members` with `role = OWNER`. Name is mandatory; an empty name is refused with `400 VALIDATION_ERROR`.
- Brand colour is limited to 9 characters and the tagline to 140 characters; a longer value is refused with `400 VALIDATION_ERROR`.
- The creator becomes the Owner of the Agency, and an Agency Member record with the OWNER role is created for the same user. The pairing is fixed and cannot be reassigned by any other feature in the current scope.
- The logo is not part of the main form. It is uploaded as a file through the Agency logo upload once the Agency identifier exists. A logo URL may still be passed as text, but the standard journey uploads the file separately.
- On success the user is taken into the newly created Agency.
- A user may own any number of Agencies; no creation limit is applied in the current scope. A limit may later come from the subscription plan.

### Validation
- Name empty → Display: MSG02
- Brand colour longer than 9 characters, or tagline longer than 140 characters → Display: MSG03
- No signed-in session → `401 UNAUTHORIZED` before any Agency logic runs.

## Functionalities
### Normal Flow
1. The user opens the Create Agency form and fills in the name and, optionally, the branding fields.
2. The client submits the form.
3. The system validates the values against the rules above.
4. The system stores a new Agency with the current user as its Owner and the status ACTIVE.
5. The system stores an Agency Member record with the OWNER role for that same user.
6. The system returns the profile of the new Agency and the client moves the user into it; toast MSG31.
7. The user optionally uploads a logo file for the Agency; the system stores the file, fills in the logo of the Agency, and returns the updated profile; toast MSG94.

### Abnormal Cases
- 3.a1: Name left empty → `400 VALIDATION_ERROR`, Display: MSG02; nothing is created. 3.a2: The user fills in the name and resubmits.
- 3.b1: Brand colour or tagline over its limit → `400 VALIDATION_ERROR`, Display: MSG03; nothing is created. 3.b2: The user shortens the field and resubmits.
- 1.a1: No signed-in session → `401 UNAUTHORIZED`, toast MSG22. 1.a2: The user signs in again and retries.
- 7.a1: The logo file fails to be read during the logo upload → `400 FILE_READ_ERROR`, toast MSG29; the Agency itself remains created. 7.a2: The user selects a valid file and retries the upload.

## Post-Conditions
- A new Agency exists with the current user as its Owner and the status ACTIVE.
- An Agency Member record with the OWNER role exists for that user, pairing the Agency with its creator.
- If a logo was uploaded, the Agency profile carries the logo URL and a refreshed update timestamp.

# 3.4.5 Update Agency Profile

## Function Trigger
The Owner of an Agency opens the Agency Profile in edit mode (`/agencies/:agencyId/profile/edit`), changes one or more fields and submits the form; or uploads a new logo file while on that screen.

## Function Description
- **Actors / Roles:** Agency Owner.
- **Purpose:** Let the Owner keep the profile of the Agency up to date — its name, branding and company information.
- **Interface:** Edit Agency Profile page (`/agencies/:agencyId/profile/edit`) — the same field set as the Create Agency form, pre-filled with the current values, plus a logo picker that uploads a new logo file.
- **Data Processing:** The system loads the Agency by its identifier, confirms the caller is its Owner, validates the submitted values, and then replaces the stored profile with the submitted values in full — every field that is not sent in the request is cleared. The logo is uploaded separately, as a file, and the system fills in the logo of the Agency with the stored location.

## Screen Layout
Figure — Edit Agency Profile page:
- The full field set of the Agency profile, pre-filled from the current values, with the name marked as required.
- A logo picker; the chosen file is uploaded separately from the form.
- A save action; on success the user stays on the screen and sees the refreshed values.
- Because the save replaces the whole profile, every field that must survive has to be present in the form when it is submitted.

## Function Details
### Data Specifications
- **Input required:** Name of the Agency.
- **Input optional:** logoUrl, description, category (AgencyCategory), companySize (CompanySize), website, phone, location, brandColor (hex, at most 9 characters), logoIcon, tagline (at most 140 characters), foundedYear, facebookUrl, linkedinUrl, instagramUrl. The logo file itself is sent through the separate logo upload.
- **System data:** The Agency record — id, name, ownerId, logoUrl, description, category, companySize, website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, status, createdAt, updatedAt — and the Owner identifier used for the access check.
- **Output:** The updated profile of the Agency. After a logo upload, the same profile with the new logo location and a refreshed update timestamp.

### Business Rules
- **BR-25 (analogous):** Updating the Agency profile is Owner-only, mirroring the rule that workspace settings can only be updated by an authorized role (BR-25, adapted: Agency profile has a single Owner rather than OWNER/MANAGER). Anybody else is refused with `403 NOT_AGENCY_OWNER`.
- The save replaces the whole profile rather than patching individual fields: a field that is not sent in the request is cleared. The client must therefore send back every current value, including the ones that did not change.
- Name is mandatory; an empty name is refused with `400 VALIDATION_ERROR`.
- The logo is uploaded as a file through the Agency logo upload, not through the logo URL field of the form.
- A logo file that cannot be read is refused with `400 FILE_READ_ERROR` rather than an internal failure; the stored profile stays untouched in that case.

### Validation
- Caller is not the Agency Owner → Display: MSG39
- Name empty → Display: MSG02
- Agency does not exist → Display: MSG38
- Logo upload by a caller who is not the Agency Owner → Display: MSG39
- Logo file cannot be read → Display: MSG29

## Functionalities
### Normal Flow
1. The Owner opens the Agency Profile in edit mode; the form loads with the current values.
2. The Owner changes the fields that need updating and leaves the rest as they are.
3. The client submits the full profile.
4. The system loads the Agency by its identifier and confirms the caller is its Owner.
5. The system validates the submitted values against the rules above.
6. The system replaces the stored profile with the submitted values and returns the updated profile; toast MSG26.
7. The Owner optionally picks a new logo file; the system stores the file, fills in the logo of the Agency, and returns the updated profile; toast MSG94.
8. The client shows a confirmation and refreshes the form and the logo preview.

### Abnormal Cases
- 4.a1: Agency does not exist → `404 AGENCY_NOT_FOUND`, toast MSG38. 4.a2: The Owner returns to the Agency list.
- 4.b1: Caller is not the Agency Owner → `403 NOT_AGENCY_OWNER`, toast MSG39; nothing is changed. 4.b2: The caller returns to the Agency list.
- 5.a1: Name left empty → `400 VALIDATION_ERROR`, Display: MSG02; nothing is changed. 5.a2: The Owner fills in the name and resubmits.
- 7.a1: Logo file cannot be read → `400 FILE_READ_ERROR`, toast MSG29; the profile keeps its previous values. 7.a2: The Owner selects a valid file and retries the upload.
- 3.a1: A field that the form fails to send back is cleared, because the save replaces the whole profile — no error, this is expected behaviour. 3.a2: The Owner reviews the saved profile and re-submits any field found missing.

## Post-Conditions
- The profile of the Agency carries the submitted values and a refreshed update timestamp.
- After a logo upload, the Agency profile carries the new logo location and a refreshed update timestamp.

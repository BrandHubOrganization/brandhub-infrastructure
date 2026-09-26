**3.4.14 Update Workspace Profile**

**Function Trigger**

Begins when the MANAGER of a Workspace submits changes to the Workspace profile or settings.

**Function Description**

- **Actors / Roles**: The MANAGER of the Workspace, and only that role.
- **Purpose**: Lets the Workspace MANAGER keep the Workspace's details and settings accurate with day-to-day operations.
- **Interface**: Workspace settings screen - the same page that displays the profile (FR 3.4.13); the edit form and logo control appear on it directly.
- **Data Processing**: The system loads the Workspace, merges the supplied fields into the record and settings, and returns the updated Workspace profile.

**Screen Layout**

Figure - Workspace Settings Screen, edit section:

- Logo block, shown only when the caller can manage the Workspace; client-side accepts image/jpeg, image/png, image/webp and rejects files over 5 MB before calling the upload endpoint.
- Form pre-filled with the current name, timezone, default platforms, report frequency, industry, company size, website, phone, and location.
- A "Save" action; on success a confirmation toast is shown and the form keeps the newly entered values.
- Out of scope for this FR but on the same screen: a "Save as Template" dialog (FR 3.4.17) and a Danger Zone delete-Workspace block (FR 3.4.15).

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the caller's authenticated identity.
    - **Input optional**: name, timezone, defaultPlatforms, reportFrequency (WEEKLY / MONTHLY), industry, companySize, website, phone, location. For the logo control: the uploaded image file.
    - **System data**: the existing Workspace record and its stored settings; the caller's role in that Workspace; the stored URL of the uploaded logo.
    - **Output**: the updated Workspace profile - id, name, agencyId, slug, ownerId, settings, industry, companySize, website, phone, location, description, branding fields, social links, isActive, createdAt.

- **Business Rules**
    - **BR-25**: Workspace settings and logo can only be updated by MANAGER; all settings fields are optional (partial update).
    - **BR-35**: The role check re-reads the caller's role from the database at request time and runs before the not-found lookup. SystemRole.ADMIN bypasses the check.
    - The Workspace must exist -> otherwise 404 WORKSPACE_NOT_FOUND.
    - Fields not supplied in the request keep their current values; the stored settings are merged rather than replaced.
    - A failure while reading the uploaded logo file -> 400 FILE_READ_ERROR.
    - The logo is uploaded through its own dedicated action, not through the profile settings update.

- **Validation**
    - The caller must hold the MANAGER role in that Workspace; otherwise 403 FORBIDDEN.
    - The Workspace must exist; otherwise 404 WORKSPACE_NOT_FOUND.
    - industry must be a valid WorkspaceIndustry value; companySize must be a valid CompanySize value. Empty required field -> Display: **MSG02**. Exceeding max length -> Display: **MSG03**.
    - An unreadable logo file -> 400 FILE_READ_ERROR. The frontend rejects non-image files and files over 5 MB before the request is sent.

**Functionalities**
- **Normal Flow**
    1. MANAGER opens Workspace settings and edits the name, timezone, default platforms, report frequency, industry, company size, website, phone, or location.
    2. System confirms the caller holds the MANAGER role in that Workspace; otherwise the request fails with 403 FORBIDDEN.
    3. System loads the Workspace; if it does not exist the request fails with 404 WORKSPACE_NOT_FOUND.
    4. System applies the supplied fields and merges the new timezone / default platforms into the stored settings, keeping previous values for fields left out.
    5. System returns the updated Workspace profile; the screen shows a success confirmation, toast **MSG32**. The separate logo upload action, on success, shows toast **MSG94**.

- **Abnormal Cases**
    - 2.a1: Caller is not the MANAGER of that Workspace -> 403 FORBIDDEN, toast **MSG39**. 2.a2: The caller stays on the same screen with the edit controls hidden.
    - 3.a1: The Workspace does not exist -> 404 WORKSPACE_NOT_FOUND, toast **MSG38**. 3.a2: The MANAGER returns to the Workspace list.
    - 3.b1: Logo upload file cannot be read -> 400 FILE_READ_ERROR. 3.b2: The user retries with another file.

**Post-Conditions**

- The Workspace record and its settings carry the new values; fields not supplied are unchanged.
- When a logo was uploaded, the Workspace holds the new logo location.

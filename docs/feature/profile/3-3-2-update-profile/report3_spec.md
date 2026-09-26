**3.3.2 Update Profile**

**Function Trigger**

Begins when a signed-in user saves edits to their profile fields on /profile, or selects a new avatar image in the avatar upload dialog.

**Function Description**

- **Actors / Roles**: Any authenticated user (role USER); a user updates only their own profile.
- **Purpose**: Let the user keep their personal information accurate — display name, phone number, professional title, bio, portfolio links, working language, timezone, notification preferences — and refresh their avatar.
- **Interface**: The Profile screen at /profile in edit mode: editable full-name field, phone field, job-title field, working-language field, bio textarea, a repeatable portfolio-URL list, a timezone selector, and a Save button. Saving submits a full update (PUT semantics). The avatar is changed separately through the avatar upload dialog. Cancel restores every field (including all four listed above) to its last-saved value.
- **Data Processing**: The system loads the user record, writes the submitted full name, phone, professional title, bio, portfolio URLs, and working language directly onto the record, merges the submitted timezone and notification preferences into the stored preferences data (only submitted fields are overwritten), persists the record, and returns the updated profile. Avatar upload is handled independently: the file is validated, stored, the previous avatar file removed when one exists, and the new reference saved.
- Known gap: notificationPreferences is wired end-to-end on the backend, but the Profile screen has no UI for it yet.

**Screen Layout**

Figure — Profile Screen (/profile, edit mode):

- Center: full-name input (required), phone input, job-title input, working-language input, bio textarea, repeatable portfolio URL inputs (add/remove), timezone selector. Email and avatar are shown but not editable from this form.
- Buttons: Save (primary); Cancel — discards changes and restores last-saved values.
- Footer: none.

Figure — Avatar Upload Dialog:

- Center: image file selector and preview.
- Buttons: Upload — submits the image; Cancel — closes without changes.

**Function Details**
- **Data Specifications**
    - **Input required**: fullName; an image file for the avatar upload action.
    - **Input optional**: phone, professionalTitle, bio, portfolioUrls, workingLanguage, timezone, notificationPreferences.
    - **System data**: users (fullName, phone, professionalTitle, bio, portfolioUrls, workingLanguage, preferences JSON, avatarUrl).
    - **Output**: userId, email, fullName, avatarUrl, phone, role, workspaceId, professionalTitle, bio, portfolioUrls, workingLanguage, timezone, notificationPreferences, createdAt; avatar upload returns the new avatarUrl.

- **Business Rules**
    - **BR-19**: The update request carries no email or avatar field, so neither can be submitted through this action; changing email is out of scope.
    - Only fields actually submitted (non-empty) overwrite the stored preferences data.
    - **BR-20**: Avatar upload — file required, content type must start with image/, max 5 MB.
    - When a new avatar uploads successfully, the previous avatar file is deleted.
    - Removing the avatar results in the default initials avatar, not an error.
    - Avatar upload is independent of the profile field update; one failing does not block the other.

- **Validation**
    - fullName empty or blank → Display: **MSG02**.
    - Preferences data cannot be serialized (rare) → Display: **MSG02**.
    - Avatar upload: no file provided → Display: **MSG27**; wrong content type → Display: **MSG28**; file exceeds 5 MB → Display: **MSG29**; file cannot be read → Display: **MSG38**.
    - Missing, expired, or invalid access token → Display: **MSG22**.
    - User record no longer exists → Display: **MSG38**.

**Functionalities**
- **Normal Flow**
    1. The user edits the form on /profile and clicks Save.
    2. The application submits the changed profile fields.
    3. The system loads the user record and writes the submitted full name and phone number.
    4. The system merges the submitted timezone and notification preferences into the stored preferences data, overwriting only submitted fields.
    5. The system persists the record and returns the complete updated profile.
    6. The application shows a success confirmation and refreshes the profile without a page reload; toast **MSG26**.
    7. Separately, the user selects an image in the avatar upload dialog and submits it.
    8. The system validates the file, stores it, deletes the previous avatar file when one exists, saves the new reference, and returns the new avatar value; toast **MSG30**.

- **Abnormal Cases**
    - 3.a1: The user record no longer exists, the system displays **MSG38**. 3.a2: The user is signed out and returned to /login.
    - 3.b1: fullName submitted empty or blank, the system displays **MSG02**. 3.b2: The user re-enters a full name and saves again.
    - 4.a1: The preferences data cannot be serialized, the system displays **MSG02**. 4.a2: The user retries Save.
    - 8.a1: No file is provided, the system displays **MSG27**. 8.a2: The user selects a file and submits again.
    - 8.b1: The file's content type is not an image, the system displays **MSG28**. 8.b2: The user selects an image file and submits again.
    - 8.c1: The file exceeds 5 MB, the system displays **MSG29**. 8.c2: The user selects a smaller image and submits again.
    - 8.d1: The file cannot be read during upload, the system displays **MSG38**. 8.d2: The user retries the upload.
    - 8.e1: The avatar is removed instead of replaced, the default initials avatar is shown, no error.
    - N.a1: Missing, expired, or invalid access token at any step, the system displays **MSG22**. N.a2: The user signs in again at /login (3.2.2).

**Post-Conditions**

- fullName, phone, professionalTitle, bio, portfolioUrls, workingLanguage, timezone, and notificationPreferences hold the submitted values; fields left out keep their previous values.
- The avatar reference reflects the most recent successful upload, or the default initials avatar when removed.
- The avatar is stored independently of the profile field update.

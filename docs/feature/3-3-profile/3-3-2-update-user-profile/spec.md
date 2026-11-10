# 3.3.2 Update Profile

## Function Trigger

Begins when a signed-in user saves edits to their profile fields on `/profile`, or selects a new avatar image in the avatar upload dialog.

## Function Description

- **Actors / Roles:** Any authenticated user (role `USER`); a user updates only their own profile.
- **Purpose:** Let the user keep their personal information accurate — display name, phone number, professional title, bio, portfolio links, working language, timezone, notification preferences — and refresh their avatar.
- **Interface:** The Profile screen at `/profile` in edit mode: an editable full-name field, a phone field, a job-title field, a working-language field, a bio textarea, a repeatable portfolio-URL list, a timezone selector, and a Save button. Saving submits a full update of the signed-in user's own profile (PUT semantics). The avatar is not part of that form — it is changed through a separate image-upload action opened from the avatar upload dialog. Cancel discards in-progress edits and restores every field (including the four fields listed above) to their last-saved values, not just full name and phone.
- **Data Processing:** The system loads the user record, writes the submitted full name, phone number, professional title, bio, portfolio URLs and working language directly onto the user record, merges the submitted timezone and notification preferences into the stored preferences data (only fields actually submitted are overwritten; fields left out keep their previous values), persists the record, and returns the updated profile. The avatar upload is handled independently: the file is validated, stored in file storage, the previous avatar file is removed when one exists, and the new avatar reference is saved.
- **Known gap (not yet implemented):** the spec's `notificationPreferences` field is wired end-to-end on the backend (merged into the stored preferences JSON, returned in the response) but the Profile screen has no notification-preference UI — there is nothing on `/profile` for the user to toggle. This is a real gap, not a stale spec claim about the backend; the backend behavior described above is accurate and code-verified.

## Screen Layout

Figure — Profile Screen (`/profile`, edit mode):

- Center: the profile card in edit mode — full-name input (required), phone input, job-title input, working-language input, bio textarea, a repeatable list of portfolio URL inputs (add/remove), and a timezone selector. Email address and avatar are displayed but are not editable from this form. Notification preferences have no UI yet (see Known gap above).
- Buttons: Save (primary) — submits the update; Cancel — discards the changes and restores every editable field to its last-saved value.
- Footer: none.

Figure — Avatar Upload Dialog:

- Center: image file selector and preview of the selected image.
- Buttons: Upload — submits the selected image; Cancel — closes the dialog without changes.

## Function Details

### Data Specifications

- **Input required:** `fullName`; and an image file for the avatar upload action.
- **Input optional:** `phone`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, `notificationPreferences`.
- **System data:** `users` (`fullName`, `phone`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, preferences JSON holding the timezone and notification preferences, `avatarUrl`).
- **Output:** The complete updated profile field set — `userId`, `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, `notificationPreferences`, `createdAt`; the avatar upload returns the new `avatarUrl`.

### Business Rules

- **BR-19:** The update request carries no email field and no avatar field, so neither can be submitted through this action — this is structural (there is no place to carry them), not a silent discard by the system. Changing the email address is out of scope for this feature.
- **Implementation note (no dedicated global BR):** Only the fields actually submitted (non-empty) are overwritten inside the stored preferences data; fields left out keep their previous values.
- **BR-20:** Avatar upload: file required, content type must start with `image/`, max 5 MB.
- **Implementation note (no dedicated global BR):** When a new avatar is uploaded successfully, the previous avatar file in file storage is deleted.
- **Implementation note (no dedicated global BR):** Removing the avatar (setting it to none) is a valid action and results in the default initials avatar, not an error.
- **Implementation note (no dedicated global BR):** The avatar upload is independent of the profile field update; one failing does not roll back or block the other.

### Validation

- `fullName` empty or blank → 400 `VALIDATION_ERROR`, Display: MSG02.
- The preferences data cannot be serialized (rare) → 400 `INVALID_REQUEST`, Display: MSG02.
- Avatar upload: no file provided (BR-20) → 400 `NO_FILE_PROVIDED`, Display: MSG27; the content type is not an image (BR-20) → 400 `INVALID_FILE_TYPE`, Display: MSG28; the file exceeds 5 MB (BR-20) → 400 `FILE_TOO_LARGE`, Display: MSG29; the file cannot be read → 400 `UPLOAD_FAILED`, Display: MSG38.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`, Display: MSG22.
- The user record no longer exists (theoretical) → 404 `USER_NOT_FOUND`, Display: MSG38.

## Functionalities

### Normal Flow

1. The user edits the form on `/profile` and clicks Save.
2. The application submits the changed profile fields.
3. The system loads the user record and writes the submitted full name and phone number.
4. The system merges the submitted timezone and notification preferences into the stored preferences data, overwriting only the fields submitted.
5. The system persists the record and returns the complete updated profile.
6. The application shows a success confirmation and refreshes the displayed profile immediately, without a page reload; toast MSG26.
7. Separately, the user selects an image in the avatar upload dialog and submits it.
8. The system validates the file (BR-20), stores it, deletes the previous avatar file when one exists, saves the new avatar reference, and returns the new avatar value; toast MSG30.

### Abnormal Cases

- 3.a1: The user record no longer exists (theoretical) → 404 `USER_NOT_FOUND`, toast MSG38.
  3.a2: The user is signed out and returned to /login.
- 3.b1: `fullName` submitted empty or blank → 400 `VALIDATION_ERROR`, Display: MSG02.
  3.b2: The form stays open with the error shown; the user re-enters a full name and saves again.
- 4.a1: The preferences data cannot be serialized (rare) → 400 `INVALID_REQUEST`, Display: MSG02.
  4.a2: The form stays open; the user retries Save.
- 8.a1: No file is provided for the avatar upload (BR-20) → 400 `NO_FILE_PROVIDED`, Display: MSG27.
  8.a2: The user selects a file and submits again.
- 8.b1: The selected file's content type is not an image (BR-20) → 400 `INVALID_FILE_TYPE`, Display: MSG28.
  8.b2: The user selects an image file and submits again.
- 8.c1: The selected file exceeds 5 MB (BR-20) → 400 `FILE_TOO_LARGE`, Display: MSG29.
  8.c2: The user selects a smaller image and submits again.
- 8.d1: The file cannot be read during upload → 400 `UPLOAD_FAILED`, toast MSG38.
  8.d2: The user retries the upload.
- 8.e1: The avatar is removed instead of replaced (BR-20) → the default initials avatar is shown, with no error.
  8.e2: No retry is needed; the profile card reflects the default initials avatar.
- N.a1: Missing, expired, or invalid access token at any step → 401 `UNAUTHORIZED`, toast MSG22.
  N.a2: The user signs in again at /login (3.2.2).

## Post-Conditions

- `fullName`, `phone`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, and `notificationPreferences` hold the submitted values; fields left out of the request keep their previous values.
- The avatar reference reflects the most recent successful upload, or the default initials avatar when the avatar was removed.
- The avatar is stored independently of the profile field update.

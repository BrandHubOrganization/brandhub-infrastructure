# 3.3.2 Update Profile

## Function Trigger

Begins when a signed-in user saves edits to their profile fields on `/settings/profile`, or selects a new avatar image in the avatar upload dialog.

## Function Description

- **Actors / Roles:** Any authenticated user (role `USER`); a user updates only their own profile.
- **Purpose:** Let the user keep their personal information accurate — display name, phone number, timezone, notification preferences — and refresh their avatar.
- **Interface:** The Profile screen at `/settings/profile` in edit mode: an editable full-name field, a phone field, a timezone selector, notification-preference toggles, and a Save button. Saving submits a full update of the signed-in user's own profile (PUT semantics). The avatar is not part of that form — it is changed through a separate image-upload action opened from the avatar upload dialog.
- **Data Processing:** The system loads the user record, writes the submitted full name and phone number, merges the submitted timezone and notification preferences into the stored preferences data (only fields actually submitted are overwritten; fields left out keep their previous values), persists the record, and returns the updated profile. The avatar upload is handled independently: the file is validated, stored in file storage, the previous avatar file is removed when one exists, and the new avatar reference is saved.

## Screen Layout

Figure — Profile Screen (`/settings/profile`, edit mode):

- Center: the profile card in edit mode — full-name input (required), phone input, timezone selector, notification-preference toggles. Email address and avatar are displayed but are not editable from this form.
- Buttons: Save (primary) — submits the update; Cancel — discards the changes.
- Footer: none.

Figure — Avatar Upload Dialog:

- Center: image file selector and preview of the selected image.
- Buttons: Upload — submits the selected image; Cancel — closes the dialog without changes.

## Function Details

### Data Specifications

- **Input required:** `fullName`; and an image file for the avatar upload action.
- **Input optional:** `phone`, `timezone`, `notificationPreferences`.
- **System data:** `users` (`fullName`, `phone`, preferences JSON holding the timezone and notification preferences, `avatarUrl`).
- **Output:** The complete updated profile field set — `userId`, `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `timezone`, `notificationPreferences`, `createdAt`; the avatar upload returns the new `avatarUrl`.

### Business Rules

- **BR-01:** The update request carries no email field and no avatar field, so neither can be submitted through this action — this is structural (there is no place to carry them), not a silent discard by the system. Changing the email address is out of scope for this feature.
- **BR-02:** Only the fields actually submitted (non-empty) are overwritten inside the stored preferences data; fields left out keep their previous values.
- **BR-03:** The avatar upload accepts image files only, up to 5 MB.
- **BR-04:** When a new avatar is uploaded successfully, the previous avatar file in file storage is deleted.
- **BR-05:** Removing the avatar (setting it to none) is a valid action and results in the default initials avatar, not an error.
- **BR-06:** The avatar upload is independent of the profile field update; one failing does not roll back or block the other.

### Validation

- `fullName` empty or blank → 400 `VALIDATION_ERROR`.
- The preferences data cannot be serialized (rare) → 400 `INVALID_REQUEST`.
- Avatar upload: no file provided → 400 `NO_FILE_PROVIDED`; the content type is not an image → 400 `INVALID_FILE_TYPE`; the file exceeds 5 MB → 400 `FILE_TOO_LARGE`; the file cannot be read → 400 `UPLOAD_FAILED`.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`.
- The user record no longer exists (theoretical) → 404 `USER_NOT_FOUND`.

## Functionalities

### Normal Flow

1. The user edits the form on `/settings/profile` and clicks Save.
2. The application submits the changed profile fields.
3. The system loads the user record and writes the submitted full name and phone number.
4. The system merges the submitted timezone and notification preferences into the stored preferences data, overwriting only the fields submitted (BR-02).
5. The system persists the record and returns the complete updated profile.
6. The application shows a success confirmation and refreshes the displayed profile immediately, without a page reload.
7. Separately, the user selects an image in the avatar upload dialog and submits it.
8. The system validates the file (BR-03), stores it, deletes the previous avatar file when one exists (BR-04), saves the new avatar reference, and returns the new avatar value.

### Abnormal Cases

- `fullName` empty or blank → 400 `VALIDATION_ERROR`; the form stays open with the error shown.
- Avatar upload with no file, a non-image type, a file over 5 MB, or an unreadable file → 400 `NO_FILE_PROVIDED` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE` / `UPLOAD_FAILED`.
- Preferences data cannot be serialized → 400 `INVALID_REQUEST`.
- User record no longer exists → 404 `USER_NOT_FOUND`.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`.
- The avatar is removed instead of replaced → the default initials avatar is shown, with no error (BR-05).

## Post-Conditions

- `fullName`, `phone`, `timezone`, and `notificationPreferences` hold the submitted values; fields left out of the request keep their previous values.
- The avatar reference reflects the most recent successful upload, or the default initials avatar when the avatar was removed.
- The avatar is stored independently of the profile field update.

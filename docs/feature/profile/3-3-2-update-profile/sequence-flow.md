# Sequence Flow — Update Profile

> Supplements `spec.md` (FR 3.3.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-09-25. Matches the current implementation.

## Actors

- **User** — the signed-in user.
- **Client** — the Profile screen at `/settings/profile` and the avatar upload dialog.
- **System** — `UserController` / `UserServiceImpl`.
- **Database** — PostgreSQL (`users`).
- **File Storage** — object storage holding avatar images.

---

## Flow A — Update the profile fields (full name, phone, professional title, bio, portfolio URLs, working language, timezone, notification preferences)

1. User → Client: edits the form on `/settings/profile` (full name, phone, job title, bio, portfolio URLs, working language, timezone; notification preferences have no UI yet) and clicks Save.
2. Client → System: `PUT /api/v1/users/me`, submitting the full set of editable fields.
   - The update request carries **no email field and no avatar field** — they cannot be submitted through this action because there is no place to carry them, not because the system silently discards them.
   - An empty or blank full name is rejected at the point of entry → `400 VALIDATION_ERROR`.
3. System (`UserServiceImpl.updateUserProfile`):
   a. System → Database: `UserRepository.findById(currentUser.getId())` — not found → `404 USER_NOT_FOUND` (theoretical).
   b. Writes the submitted full name (trimmed).
   c. When submitted (non-null), writes phone (trimmed), professionalTitle (trimmed), bio, workingLanguage (trimmed) directly onto the user record.
   d. When `portfolioUrls` is submitted, JSON-serializes the list and writes it to the `portfolioUrls` column — serialization failure (rare) → `400 INVALID_REQUEST`.
   e. Reads the stored preferences JSON, merges in the submitted timezone (when submitted) and notification preferences (when submitted), and writes the merged preferences back to the user record — serialization failure (rare) → `400 INVALID_REQUEST`.
4. System → Database: saves the user record.
5. System → Client: returns the complete updated profile — `userId`, `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, `notificationPreferences`, `createdAt` (same shape as the profile view, FR 3.3.1).
6. Client: shows a success confirmation and refreshes the display from the returned values, without a page reload.

## Flow B — Upload an avatar

A separate action, independent of Flow A (never part of the profile update).

1. User → Client: opens the avatar upload dialog and selects an image file.
2. Client → System: submits the selected image file (multipart).
3. System:
   a. No file, or an empty file → `400 NO_FILE_PROVIDED`.
   b. Content type does not start with `image/` → `400 INVALID_FILE_TYPE`.
   c. File larger than 5 MB → `400 FILE_TOO_LARGE`.
   d. System → Database: loads the user record — not found → `404 USER_NOT_FOUND` (theoretical).
   e. Reading the file bytes fails → `400 UPLOAD_FAILED`.
   f. System → File Storage: stores the image and receives the new avatar reference.
   g. When the user already has an avatar, System → File Storage: deletes the previous avatar file (clean-up).
   h. Writes the new avatar reference onto the user record → System → Database: saves the user record.
4. System → Client: returns the new avatar reference.
5. Client: shows the new avatar, replacing any temporary local preview.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Update (Flow A) | Full name empty or blank | 400 | `VALIDATION_ERROR` |
| Update (Flow A) | Preferences or portfolioUrls data cannot be serialized (rare) | 400 | `INVALID_REQUEST` |
| Update (Flow A/B) | The user record no longer exists (theoretical) | 404 | `USER_NOT_FOUND` |
| Update (Flow A/B) | Missing, expired, or invalid token | 401 | `UNAUTHORIZED` |
| Upload avatar (Flow B) | No file provided | 400 | `NO_FILE_PROVIDED` |
| Upload avatar (Flow B) | File is not an image | 400 | `INVALID_FILE_TYPE` |
| Upload avatar (Flow B) | File larger than 5 MB | 400 | `FILE_TOO_LARGE` |
| Upload avatar (Flow B) | File cannot be read | 400 | `UPLOAD_FAILED` |

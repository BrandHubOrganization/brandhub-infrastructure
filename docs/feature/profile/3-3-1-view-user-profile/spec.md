# 3.3.1 View User Profile

## Function Trigger

Begins when a signed-in user opens the Profile screen at `/settings/profile`.

## Function Description

- **Actors / Roles:** Any authenticated user (role `USER`); a user reads only their own profile.
- **Purpose:** Display the personal information the system holds for the signed-in user, so the user can verify it.
- **Interface:** The Profile screen at `/settings/profile`, read-only section. Every field is rendered as text and cannot be edited here — the Edit action moves to Update Profile (3.3.2).
- **Data Processing:** The system resolves the caller's identity from the access token only (no user identifier is accepted from the caller), loads the matching user record, resolves the system role, resolves the current workspace, and derives the timezone and notification preferences from the preferences data stored on that user record. No data is modified.

## Screen Layout

Figure — Profile Screen (`/settings/profile`):

- Header: page title "Profile".
- Center: read-only profile card — avatar image, full name, email address, phone number (when present), system role, workspace, timezone, notification preferences, and member-since date.
- Buttons: Edit — routes to Update Profile (3.3.2).
- Footer: none.
- When no avatar has ever been set, a default initials avatar is shown in place of the avatar image.

## Function Details

### Data Specifications

- **Input required:** None — the signed-in user's identity is derived from the access token; the caller cannot supply another user's identifier.
- **Input optional:** None.
- **System data:** `users` (userId, email, fullName, avatarUrl, phone, preferences JSON holding the timezone and notification preferences, createdAt); `user_system_roles` (system role); `workspace_members` (workspaceId).
- **Output:** The complete profile field set — `userId`, `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `timezone`, `notificationPreferences`, `createdAt`.

### Business Rules

- **BR-01:** The caller's identity is taken from the access token only; no user identifier is accepted as a parameter, so a user can never read another user's profile.
- **BR-02:** `role` is read from the user's system role records; when no role record exists, `role` defaults to `USER`.
- **BR-03:** `workspaceId` is taken from the token; when the token carries none, the system falls back to the user's first active workspace membership.
- **BR-04:** `timezone` and `notificationPreferences` have no dedicated columns — both are stored inside the JSON `preferences` field of the user record.
- **BR-05:** `avatarUrl` is empty when the user has never uploaded an avatar; the interface then shows a default initials avatar. This is not an error.

### Validation

- No request body is accepted; validation is limited to authentication.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`.
- The user record no longer exists (theoretical: a valid token held for a deleted user) → 404 `USER_NOT_FOUND`.

## Functionalities

### Normal Flow

1. The signed-in user opens `/settings/profile`.
2. The application requests the signed-in user's own profile.
3. The system resolves the caller's identity from the access token and loads the matching user record.
4. The system resolves the system role, applying the default when no role record exists (BR-02).
5. The system resolves the current workspace, falling back to the first active workspace membership when the token carries none (BR-03).
6. The system derives `timezone` and `notificationPreferences` from the stored preferences data (BR-04).
7. The system returns the complete profile field set.
8. The application renders the read-only profile card, showing a default initials avatar when no avatar exists (BR-05).

### Abnormal Cases

- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`.
- User record no longer exists → 404 `USER_NOT_FOUND`.
- No avatar set → `avatarUrl` is empty and the default initials avatar is shown; not an error.

## Post-Conditions

- The signed-in user's profile is displayed with the values currently stored in the system.
- No data is changed; the operation is read-only.

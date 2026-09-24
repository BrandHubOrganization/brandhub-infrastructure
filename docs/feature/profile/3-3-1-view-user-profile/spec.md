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

- **BR-18:** `/users/me` resolves identity from the JWT principal only — no `userId` path/query parameter, so a user can never read another user's profile.
- **Implementation note (no dedicated global BR):** `role` is read from the user's system role records; when no role record exists, `role` defaults to `USER`. `workspaceId` is taken from the token; when the token carries none, the system falls back to the user's first active workspace membership. `timezone` and `notificationPreferences` have no dedicated columns — both are stored inside the JSON `preferences` field of the user record.
- **Implementation note (no dedicated global BR):** `avatarUrl` is empty when the user has never uploaded an avatar; the interface then shows a default initials avatar. This is not an error.

### Validation

- No request body is accepted; validation is limited to authentication.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`, Display: MSG22.
- The user record no longer exists (theoretical: a valid token held for a deleted user) → 404 `USER_NOT_FOUND`, Display: MSG38.

## Functionalities

### Normal Flow

1. The signed-in user opens `/settings/profile`.
2. The application requests the signed-in user's own profile.
3. The system resolves the caller's identity from the access token and loads the matching user record.
4. The system resolves the system role, applying the default when no role record exists.
5. The system resolves the current workspace, falling back to the first active workspace membership when the token carries none.
6. The system derives `timezone` and `notificationPreferences` from the stored preferences data.
7. The system returns the complete profile field set.
8. The application renders the read-only profile card, showing a default initials avatar when no avatar exists.

### Abnormal Cases

- 3.a1: Missing, expired, or invalid access token (CR-AUTH-01) → 401 `UNAUTHORIZED`, toast MSG22.
  3.a2: The user signs in again at /login (3.2.2).
- 3.b1: The user record no longer exists (BR-18) → 404 `USER_NOT_FOUND`, toast MSG38.
  3.b2: The user is signed out and returned to /login.
- 8.a1: No avatar has ever been set → `avatarUrl` is empty; not an error.
  8.a2: The application shows a default initials avatar in place of the avatar image.

## Post-Conditions

- The signed-in user's profile is displayed with the values currently stored in the system.
- No data is changed; the operation is read-only.

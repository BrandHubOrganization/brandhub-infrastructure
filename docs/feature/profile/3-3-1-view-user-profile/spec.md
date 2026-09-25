# 3.3.1 View User Profile

## Function Trigger

Begins when a signed-in user opens the Profile screen at `/profile`.

## Function Description

- **Actors / Roles:** Any authenticated user (role `USER`); a user reads only their own profile.
- **Purpose:** Display the personal information the system holds for the signed-in user, so the user can verify it.
- **Interface:** The Profile screen at `/profile` (`pages/profile/index.tsx`), a single page that combines the read-only view and the edit form (Edit toggles the same section into edit mode — see FR 3.3.2 for the edit behavior). In view mode, every field is rendered as text and cannot be edited — the Edit button switches the section into edit mode.
- **Data Processing:** The system resolves the caller's identity from the access token only (no user identifier is accepted from the caller), loads the matching user record, resolves the system role, resolves the current workspace, and derives the timezone and notification preferences from the preferences data stored on that user record. No data is modified.

## Screen Layout

Figure — Profile Screen (`/profile`, view mode):

- Header: page title "Profile".
- Top card: avatar image (or default initials avatar when none is set), full name, email address, a "Verified" badge, and an Edit button that switches the section into edit mode.
- Below, in a two-column grid: system role, phone number (with a change/add-phone link opening the Link Phone dialog), member-since date, last-login date, job title (`professionalTitle`), working language, timezone, bio, and portfolio URLs (rendered as a list of clickable links) — each field showing an empty-state placeholder when not set.
- Side panel: Danger Zone card with a Deactivate Account button (opens a confirmation dialog; separate flow, not part of this FR).
- Buttons: Edit — switches the profile card into edit mode (FR 3.3.2).
- Footer: none.

## Function Details

### Data Specifications

- **Input required:** None — the signed-in user's identity is derived from the access token; the caller cannot supply another user's identifier.
- **Input optional:** None.
- **System data:** `users` (userId, email, fullName, avatarUrl, phone, professionalTitle, bio, portfolioUrls JSON array, workingLanguage, preferences JSON holding the timezone and notification preferences, createdAt); `user_system_roles` (system role); `workspace_members` (workspaceId).
- **Output:** The complete profile field set — `userId`, `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `professionalTitle`, `bio`, `portfolioUrls` (array of strings), `workingLanguage`, `timezone`, `notificationPreferences`, `createdAt`.

### Business Rules

- **BR-18:** `/users/me` resolves identity from the JWT principal only — no `userId` path/query parameter, so a user can never read another user's profile.
- **Implementation note (no dedicated global BR):** `role` is read from the user's system role records; when no role record exists, `role` defaults to `USER`. `workspaceId` is taken from the token; when the token carries none, the system falls back to the user's first active workspace membership. `timezone` and `notificationPreferences` have no dedicated columns — both are stored inside the JSON `preferences` field of the user record.
- **Implementation note (no dedicated global BR):** `avatarUrl` is empty when the user has never uploaded an avatar; the interface then shows a default initials avatar. This is not an error.
- **Implementation note (no dedicated global BR):** `professionalTitle`, `bio`, and `workingLanguage` are plain nullable columns on the user record; `portfolioUrls` is stored as a JSON-serialized string column and deserialized to a list of strings for the response (an unparsable or blank value returns an empty list, never an error).

### Validation

- No request body is accepted; validation is limited to authentication.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`, Display: MSG22.
- The user record no longer exists (theoretical: a valid token held for a deleted user) → 404 `USER_NOT_FOUND`, Display: MSG38.

## Functionalities

### Normal Flow

1. The signed-in user opens `/profile`.
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

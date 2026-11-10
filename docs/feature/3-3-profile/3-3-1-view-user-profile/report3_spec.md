**3.3.1 View User Profile**

**Function Trigger**

Begins when a signed-in user opens the Profile screen at /profile.

**Function Description**

- **Actors / Roles**: Any authenticated user (role USER); a user reads only their own profile.
- **Purpose**: Display the personal information the system holds for the signed-in user, so the user can verify it.
- **Interface**: The Profile screen at /profile, a single page combining the read-only view and the edit form. Edit toggles the section into edit mode (see FR 3.3.2). In view mode every field is text-only.
- **Data Processing**: The system resolves the caller's identity from the access token only, loads the matching user record, resolves the system role, resolves the current workspace, and derives timezone and notification preferences from the preferences data on the user record. No data is modified.

**Screen Layout**

Figure — Profile Screen (/profile, view mode):

- Header: page title "Profile".
- Top card: avatar image (or default initials avatar), full name, email, a "Verified" badge, and an Edit button.
- Two-column grid: system role, phone number (with a change/add-phone link), member-since date, last-login date, job title (professionalTitle), working language, timezone, bio, portfolio URLs (list of links) — each showing an empty-state placeholder when not set.
- Side panel: Danger Zone card with a Deactivate Account button (separate flow, not part of this FR).
- Buttons: Edit — switches the profile card into edit mode (FR 3.3.2).
- Footer: none.

**Function Details**
- **Data Specifications**
    - **Input required**: None — identity is derived from the access token; the caller cannot supply another user's identifier.
    - **Input optional**: None.
    - **System data**: users (userId, email, fullName, avatarUrl, phone, professionalTitle, bio, portfolioUrls, workingLanguage, preferences JSON, createdAt); user_system_roles (system role); workspace_members (workspaceId).
    - **Output**: userId, email, fullName, avatarUrl, phone, role, workspaceId, professionalTitle, bio, portfolioUrls, workingLanguage, timezone, notificationPreferences, createdAt.

- **Business Rules**
    - **BR-18**: /users/me resolves identity from the JWT principal only, so a user can never read another user's profile.
    - role defaults to USER when no role record exists; workspaceId falls back to the user's first active workspace membership when the token carries none.
    - timezone and notificationPreferences have no dedicated columns; both live inside the JSON preferences field.
    - avatarUrl is empty when no avatar was ever uploaded; a default initials avatar is shown — not an error.
    - professionalTitle, bio, and workingLanguage are plain nullable columns; portfolioUrls is a JSON string deserialized to a list (unparsable or blank returns an empty list, never an error).

- **Validation**
    - Empty required fields → not applicable (no request body).
    - Missing, expired, or invalid access token → Display: **MSG22**.
    - User record no longer exists → Display: **MSG38**.

**Functionalities**
- **Normal Flow**
    1. The signed-in user opens /profile.
    2. The application requests the signed-in user's own profile.
    3. The system resolves the caller's identity from the access token and loads the matching user record.
    4. The system resolves the system role, applying the default when no role record exists.
    5. The system resolves the current workspace, falling back to the first active workspace membership when needed.
    6. The system derives timezone and notificationPreferences from the stored preferences data.
    7. The system returns the complete profile field set.
    8. The application renders the read-only profile card, showing a default initials avatar when none exists.

- **Abnormal Cases**
    - 3.a1: Missing, expired, or invalid access token, the system displays **MSG22**. 3.a2: The user signs in again at /login (3.2.2).
    - 3.b1: The user record no longer exists, the system displays **MSG38**. 3.b2: The user is signed out and returned to /login.
    - 8.a1: No avatar has ever been set, avatarUrl is empty. 8.a2: The application shows a default initials avatar.

**Post-Conditions**

- The signed-in user's profile is displayed with the values currently stored in the system.
- No data is changed; the operation is read-only.

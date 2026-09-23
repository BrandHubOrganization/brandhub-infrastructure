# Sequence Flow — View User Profile

> Supplements `spec.md` (FR 3.3.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-09-23. Matches the current implementation.

## Actors

- **User** — the signed-in user.
- **Client** — the Profile screen at `/settings/profile`.
- **System** — the application services.
- **Database** — PostgreSQL (`users`, `user_system_roles`, `workspace_members`).

---

## Flow A — View the signed-in user's own profile

1. User → Client: opens `/settings/profile`.
2. Client → System: requests the signed-in user's own profile, carrying the access token and no user identifier.
3. System: resolves the caller's identity from the authenticated token.
4. System → Database: loads the user record for that identity — not found → `404 USER_NOT_FOUND` (theoretical: with a valid token the user always exists).
5. System → Database: reads the user's system role; when no role record exists, the role defaults to `USER`.
6. System → Database: when the token carries no workspace, falls back to the user's first active workspace membership.
7. System: derives the timezone and notification preferences from the preferences data stored on the user record.
8. System → Client: returns the complete profile field set — id (`userId`), `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `timezone`, `notificationPreferences`, `createdAt`.
9. Client: renders the fields in the read-only view — no direct editing, the Edit action moves to FR 3.3.2.
   - `avatarUrl` empty → a default initials avatar is shown.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| View profile | Missing, expired, or invalid token (blocked before the operation is reached) | 401 | `UNAUTHORIZED` |
| View profile | The user record no longer exists (theoretical: valid token held for a deleted user) | 404 | `USER_NOT_FOUND` |

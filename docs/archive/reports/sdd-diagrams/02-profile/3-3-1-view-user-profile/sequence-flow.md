# Sequence Flow — View User Profile

> Supplements `spec.md` (FR 3.3.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-09-25. Matches the current implementation.

## Actors

- **User** — the signed-in user.
- **Client** — the Profile screen at `/profile` (view mode).
- **System** — `UserController` / `UserServiceImpl`.
- **Database** — PostgreSQL (`users`, `user_system_roles`, `workspace_members`).

---

## Flow A — View the signed-in user's own profile

1. User → Client: opens `/profile`.
2. Client → System: `GET /api/v1/users/me`, carrying the access token and no user identifier.
3. System (`UserServiceImpl.getUserProfile`): resolves the caller's identity from the authenticated token.
4. System → Database: `UserRepository.findById(currentUser.getId())` — not found → `404 USER_NOT_FOUND` (theoretical: with a valid token the user always exists).
5. System → Database: `UserSystemRoleRepository.findByUserId(...)`; when no role record exists, the role defaults to `USER`.
6. System → Database: when `currentUser.getWorkspaceId()` is null, falls back to `WorkspaceMemberRepository.findFirstByUserIdAndIsActiveTrue(...)`.
7. System: parses the user's `preferences` JSON column to derive `timezone` and `notificationPreferences`; parses the `portfolioUrls` JSON column into a list of strings (blank/unparsable → empty list, never an error).
8. System → Client: returns the complete profile field set — `userId`, `email`, `fullName`, `avatarUrl`, `phone`, `role`, `workspaceId`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, `notificationPreferences`, `createdAt`.
9. Client: renders the fields in the read-only view — job title, working language, timezone, bio, and portfolio links included; no direct editing here, the Edit button switches the same page into edit mode (FR 3.3.2).
   - `avatarUrl` empty → a default initials avatar is shown.
   - Any optional field empty (`phone`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`) → an empty-state placeholder is shown, not an error.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| View profile | Missing, expired, or invalid token (blocked before the operation is reached) | 401 | `UNAUTHORIZED` |
| View profile | The user record no longer exists (theoretical: valid token held for a deleted user) | 404 | `USER_NOT_FOUND` |

# Sequence Flow — Update Client Profile

> Supplements `spec.md` (FR 3.3.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-10-02. ClientProfile reworked — owned by the User, independent of any Agency.

## Actors

- **User** — any signed-in user, creating or editing a Client Profile they own.
- **Client** — the create/edit form on "My Brand Profiles" (FR 3.3.3).
- **System** — the application services.
- **Database** — PostgreSQL (`client_profiles`, `workspace_members`).

## Reminder — owned by the User, never scoped to an Agency

Unlike the reverted 2026-09-21 model, there is no "(user, agency) pair" — a single profile row can be linked to workspaces of any number of Agencies. Editing it changes that one row; the change is visible wherever it is linked.

---

## Flow A — Create a new Client Profile

1. User → Client: fills the form — display name (required), company, phone, note, logo, website, industry, location, description, social links, brand fields — and clicks Save.
2. Client → System: `POST /api/v1/client-profile` with the full field set.
   - An empty or blank display name is rejected → `400 VALIDATION_ERROR`.
   - The request carries no email field — the owner's own email cannot be submitted through this action.
3. System:
   a. Resolves the caller's identity from the access token.
   b. Builds a new `ClientProfile` with `userId = caller`, no Agency reference of any kind.
4. System → Database: inserts the record.
5. System → Client: returns the complete Client Profile.
6. Client: shows a success confirmation and adds the new card to the list.

## Flow B — Update an existing Client Profile

1. User → Client: edits an existing card's form and clicks Save.
2. Client → System: `PUT /api/v1/client-profile/{profileId}` with the full field set.
3. System:
   a. System → Database: `findById(profileId)` — no record → `404 CLIENT_PROFILE_NOT_FOUND`.
   b. Checks `profile.userId == caller.id` — mismatch → `403 CLIENT_PROFILE_NOT_OWNED`.
   c. Writes the complete field set over the record (full overwrite) and stamps the update time.
4. System → Database: saves the record.
5. System → Client: returns the complete Client Profile.
6. Client: shows a success confirmation and refreshes the list. Because the profile is never Agency-scoped, the new values are visible wherever it is linked (every workspace of every Agency) immediately — no manual synchronization, no "per-Agency copy" to keep in sync.

## Flow C — Delete a Client Profile

1. User → Client: clicks Delete on a card.
2. Client → System: `DELETE /api/v1/client-profile/{profileId}`.
3. System:
   a. Checks ownership as in Flow B step b.
   b. System → Database: `workspaceMemberRepository.findByClientProfileIdInAndIsActiveTrue([profileId])` — not empty → `409 CLIENT_PROFILE_IN_USE`.
4. System → Database: deletes the record.
5. System → Client: confirms deletion; the card is removed from the list.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Create/Update (Flow A/B) | Display name empty or blank | 400 | `VALIDATION_ERROR` |
| Update/Delete (Flow B/C) | Profile not found | 404 | `CLIENT_PROFILE_NOT_FOUND` |
| Update/Delete (Flow B/C) | Profile belongs to a different user | 403 | `CLIENT_PROFILE_NOT_OWNED` |
| Delete (Flow C) | Profile linked to an active workspace membership | 409 | `CLIENT_PROFILE_IN_USE` |
| Any | Missing, expired, or invalid token | 401 | `UNAUTHORIZED` |

## Notes

- There is no upsert anymore — create (`POST`) and update (`PUT /{profileId}`) are distinct requests. The 2026-09-21 upsert-by-`(userId, agencyId)` behaviour was reverted on 2026-10-02 along with the `agency_id` column.
- There is no dedicated error code to block the owner's own email field — the request simply has no place to carry it, so it can never be sent.

# Sequence Flow — Update Client Profile

> Supplements `spec.md` (FR 3.3.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-09-23. Matches the current implementation.

## Actors

- **User** — a user acting as a Client in a workspace of an Agency.
- **Client** — the edit form on the Client Profile screen (FR 3.3.3).
- **System** — the application services.
- **Database** — PostgreSQL (`client_profiles`).

## Reminder — keyed by the pair (user, agency)

As in FR 3.3.3, every update applies to one specific Agency: editing the Client Profile for Agency A does **not** affect the record held for Agency B (when the user is also a Client there). "Synchronized across all workspaces" holds only within the workspaces of the **same Agency**, because they all read the one (user, agency) record.

---

## Flow A — Update an existing Client Profile

1. User → Client: edits the form — display name, company, phone number, note, and the other fields when the interface offers them (logo, website, industry, location, description, social links) — and clicks Save. The Client knows the Agency currently in context from the page.
2. Client → System: submits the update for the signed-in user's Client Profile in the current Agency.
   - An empty or blank display name is rejected at the point of entry → `400 VALIDATION_ERROR`.
   - The update request carries **no email field** — an email address cannot be submitted through this action because there is no place to carry it, not because the system rejects it with a dedicated error code.
   - The Agency identifier is mandatory → missing → `400 VALIDATION_ERROR`.
3. System:
   a. System → Database: looks up the Client Profile by the pair (user, agency) — a record exists → it is used for the update (continues at step b).
   b. Writes the complete field set: display name (trimmed), company, phone number, note, logo, website, industry, location, description, social links, and stamps the update time.
4. System → Database: saves the record.
5. System → Client: returns the complete Client Profile — `id`, `userId`, `agencyId`, `displayName`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`, `createdAt`, `updatedAt`.
6. Client: shows a success confirmation and refreshes the display immediately. Because every workspace of the same Agency reads this one record, the change is visible at once everywhere that Agency is used, with no manual synchronization.

## Flow B — Update when the Agency has no Client Profile yet (upsert creates the record)

Same action as Flow A, differing only at step 3a:

- 3a'. System → Database: looks up the Client Profile by the pair (user, agency) — **no record** → the system creates a new Client Profile for that (user, agency) pair (not yet stored), then writes the fields as in Flow A step b and saves — an insert rather than an update.

- This is the genuine upsert behaviour of the action. A Client Profile is created either when a Client invitation is accepted **or** on the first update for that Agency; the update path creates the record when it is missing and does not return `404`.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Update (Flow A/B) | Display name empty or blank | 400 | `VALIDATION_ERROR` |
| Update (Flow A/B) | Agency identifier not supplied | 400 | `VALIDATION_ERROR` |
| Update (Flow A/B) | Missing, expired, or invalid token | 401 | `UNAUTHORIZED` |

## Notes

- The upsert behaviour (Flow B) is intentional and has been confirmed as the behaviour to keep, rather than splitting record creation into a separate flow. `spec.md` states the same: a Client Profile is created either when a Client invitation is accepted or on the first update for that Agency.
- There is no dedicated error code to block the email field — the update request simply has no place to carry an email address, so it can never be sent. This is stated in `spec.md` under Validation and Business Rules.

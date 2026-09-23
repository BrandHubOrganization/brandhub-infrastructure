# Sequence Flow — View Client Profile

> Supplements `spec.md` (FR 3.3.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-09-23. Matches the current implementation.

## Actors

- **User** — a user acting as a Client in a workspace of an Agency.
- **Agency member** — an Owner or Manager viewing the Agency's Client list.
- **Client** — the Client Profile screen at `/client-profile` and the Client list view.
- **System** — the application services.
- **Database** — PostgreSQL (`client_profiles`).

---

## Key point — a Client Profile is keyed by the pair (user, agency), never global

Unlike the conceptual business description of "one Client Profile shared across every Agency", the stored record is keyed by the **pair (user, agency)**. This means:

- One user acting as a Client of Agency A and Agency B holds **two separate records**, one per Agency, not a single record shared system-wide.
- Reuse applies only **within the same Agency**: when a user is already a Client in one workspace of Agency A and is invited into another workspace of the **same Agency A**, the system reuses that exact (user, Agency A) record and creates no new one.
- When the user is invited as a Client of Agency B (a different Agency), a separate (user, Agency B) record is used, fully independent of the Agency A record — the display name, company, and other fields may differ.

## Flow A — View the Client Profile within one Agency

1. User → Client: opens `/client-profile`; the Client determines the Agency currently in context (from the workspace/Agency the user is working in).
2. Client → System: requests the signed-in user's Client Profile for that Agency.
3. System:
   a. Resolves the caller's identity from the access token.
   b. System → Database: looks up the Client Profile by the pair (user, agency) — no record → `404 CLIENT_PROFILE_NOT_FOUND`.
4. System → Client: returns the complete Client Profile — `id`, `userId`, `agencyId`, `displayName`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`, `createdAt`, `updatedAt`.
5. Client: renders the Client Profile for the Agency currently in context.

## Flow B — An Agency views its own Client list (supports choosing a Client when adding one to a workspace)

1. Agency member → Client: opens the screen for adding a Client to a workspace and needs the existing Client Profiles as suggestions.
2. Client → System: requests the Client Profiles held by the Agency.
3. System:
   a. System → Database: reads every Client Profile belonging to that Agency.
4. System → Client: returns the list of Client Profiles.
5. Client: displays the list so an existing Client Profile can be reused when inviting a Client into another workspace of the same Agency.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| View Client Profile (Flow A) | No Client Profile exists for the (user, agency) pair | 404 | `CLIENT_PROFILE_NOT_FOUND` |
| View Client Profile (Flow A) | Missing, expired, or invalid token | 401 | `UNAUTHORIZED` |
| View Client Profile or list (Flow A/B) | Agency identifier not supplied | 400 | `VALIDATION_ERROR` |

## Notes

- Creating a Client Profile happens in the invitation-acceptance flow (see the agency-workspace sequence flow) **or** on the first update for that Agency (FR 3.3.4, upsert) — never in FR 3.3.3. Viewing always returns `404 CLIENT_PROFILE_NOT_FOUND` when no record exists for the (user, agency) pair.

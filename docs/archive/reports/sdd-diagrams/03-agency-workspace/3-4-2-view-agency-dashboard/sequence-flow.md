# Sequence Flow — View Agency Dashboard

> Companion to `spec.md` (FR 3.4.2). This feature is **proposed and not yet implemented**: the system has no dashboard screen and no summary of Workspace, Member and Client counts. There is no dashboard route among the Agency routes that exist today.
>
> Updated 2026-09-23.

## Conclusion

**There is no real sequence to describe yet.** No dashboard route exists, and nothing counts Workspaces, Members, Clients or recent activity for an Agency. The steps below are an **indicative draft**, taken from the proposed interface described in `spec.md`. They are meant as a reference for the eventual design and are **not a working flow**.

## Actors (proposed)

- **Owner**
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agencies`, `agency_members`; the Workspace and Client Profile sources still have to be designed).

## Indicative flow (draft — not implemented)

1. Owner → Client: opens the dashboard of an Agency.
2. Client → System: requests the dashboard summary of the Agency. *(Proposed — not yet implemented.)*
3. System (proposed):
   a. Confirms the Agency exists and is not soft-deleted — otherwise `404 AGENCY_NOT_FOUND`.
   b. Confirms the caller is the Owner of the Agency — otherwise `403 FORBIDDEN`.
   c. Counts the Members of the Agency from the member records, which are available today.
   d. Counts the Workspaces of the Agency and the distinct Clients across them. **The data source for these counts still has to be designed.**
   e. Collects recent activity. **The data source for recent activity is still undecided.**
4. System → Client: the summary with the Workspace count, the Member count, the Client count and the recent-activity list. *(Proposed shape, not fixed.)*
5. Client: renders the dashboard.

## Error paths (proposed, draft)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Dashboard | Caller is not the Agency Owner | 403 | `FORBIDDEN` |
| Dashboard | Agency does not exist or is soft-deleted | 404 | `AGENCY_NOT_FOUND` |

## Notes

- No divergence from `spec.md`: that document already states that the feature is proposed and not yet implemented. This file only confirms that nothing has been built, and adds no new claim.

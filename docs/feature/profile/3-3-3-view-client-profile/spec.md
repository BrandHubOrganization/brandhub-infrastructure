# 3.3.3 View Client Profile

## Function Trigger

Begins when a user acting as a Client opens the Client Profile screen in the context of a specific Agency, or when an Agency member opens the Agency's Client list while adding a Client to a workspace.

## Function Description

- **Actors / Roles:** A user acting as a Client in a workspace of an Agency; Agency members (Owner/Manager) when viewing the Agency's Client list.
- **Purpose:** Show the Client Profile held for one specific Agency, independently of the user's own User Profile (3.3.1), so the Client can confirm what that Agency sees and so details can be reused within the same Agency without re-entering them.
- **Interface:** The Client Profile screen at `/client-profile`, scoped to the Agency currently in context (the Agency is taken from the page context / URL). The screen shows the Client Profile as a read-only card. A separate Client list view, also in an Agency context, shows every Client Profile held by that Agency and is used as a picker when adding a Client to a workspace. In both cases the Agency identifier must be supplied by the caller; no Agency is assumed.
- **Data Processing:** The system resolves the caller's identity from the access token only, looks up the Client Profile by the pair (user, agency), and returns the complete field set. For the list view, the system returns every Client Profile belonging to the given Agency.

## Screen Layout

Figure — Client Profile Screen (`/client-profile`, Agency context):

- Header: page title "Client Profile" and the Agency currently in context.
- Center: read-only card — display name, company, phone number, note, logo, website, industry, location, description, social links, and the created and last-updated dates.
- Buttons: Edit — routes to Update Client Profile (3.3.4).
- Footer: none.
- When no Agency is in context, the screen shows a clear error instead of requesting data.

Figure — Client List (Agency context):

- Center: list of the Agency's Client Profiles — display name, company, and contact details.
- Used when adding a Client to a workspace, so an existing Client Profile can be reused.

## Function Details

### Data Specifications

- **Input required:** The Agency identifier, for both the Client Profile view and the Agency Client list.
- **Input optional:** None.
- **System data:** `client_profiles`, keyed by the pair (userId, agencyId) — `id`, `userId`, `agencyId`, `displayName`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`, `createdAt`, `updatedAt`.
- **Output:** The complete Client Profile field set for one Agency, or the list of Client Profiles held by an Agency.

### Business Rules

- **BR-41:** A client account is a member of type `CLIENT`; clients have a read-only + approve/reject scope, never workspace admin. A Client Profile is keyed by the pair (user, agency) and is never global — one user may hold several independent Client Profiles, one per Agency.
- **Implementation note (no dedicated global BR):** Reuse of a Client Profile applies only within the same Agency. When the user is already a Client in one workspace of Agency A and is later invited into another workspace of the same Agency A, the existing (user, Agency A) record is reused and no new record is created. An invitation from Agency B uses a separate (user, Agency B) record, independent of the Agency A record.
- **Implementation note (no dedicated global BR):** A Client Profile is created either when a Client invitation is accepted, or on the first update for that Agency (upsert — see 3.3.4). Viewing never creates a record.
- **Implementation note (no dedicated global BR):** The Agency identifier is mandatory; no default Agency is assumed.
- **BR-38:** Client access is scoped by `clientId` (agencyId) — a client can only see/approve its own content. A Client Profile is independent of the user's own User Profile — one user may hold both at the same time, for example owning their own Agency while being a Client of another Agency.
- **Implementation note (no dedicated global BR):** A user who is a Client of Agency A and of Agency B holds two independent records. No data is shared between them: the display name, company, and other fields may differ per Agency.

### Validation

- Missing Agency identifier → 400 `VALIDATION_ERROR`, Display: MSG02.
- No Client Profile exists for the (user, agency) pair (BR-41) → 404 `CLIENT_PROFILE_NOT_FOUND`, Display: MSG38.
- Missing, expired, or invalid access token → 401 `UNAUTHORIZED`, Display: MSG22.

## Functionalities

### Normal Flow

1. The user opens the Client Profile screen in the context of a specific Agency.
2. The application determines the Agency identifier from the current context.
3. The application requests the signed-in user's Client Profile for that Agency.
4. The system resolves the caller's identity from the access token.
5. The system looks up the Client Profile by the pair (user, agency) (BR-41).
6. The system returns the complete Client Profile field set.
7. The application renders the Client Profile for the Agency currently in context.
8. Alternatively, an Agency member opens the Agency's Client list; the system returns every Client Profile held by that Agency, and the application displays them for selection when adding a Client to a workspace.

### Abnormal Cases

- 2.a1: No Agency identifier is supplied → 400 `VALIDATION_ERROR`, Display: MSG02.
  2.a2: The interface shows a clear error instead of requesting data; the user selects an Agency context and retries.
- 5.a1: No Client Profile exists for the (user, agency) pair (BR-41) → 404 `CLIENT_PROFILE_NOT_FOUND`, toast MSG38. Viewing never creates one.
  5.a2: The user is offered Update Client Profile (3.3.4) to create the record, or returns to the Client list.
- N.a1: Missing, expired, or invalid access token at any step → 401 `UNAUTHORIZED`, toast MSG22.
  N.a2: The user signs in again at /login (3.2.2).
- 7.a1: The user owns Agency A while also being a Client of Agency B (BR-38) → both profiles exist independently.
  7.a2: The interface makes clear which context is being viewed (own User Profile versus Client Profile).
- 7.b1: The user is a Client of both Agency A and Agency B (BR-41) → two independent records exist.
  7.b2: The application displays each record only within its own Agency context, never mixed.

## Post-Conditions

- The Client Profile for the requested Agency is displayed with the values currently stored for that pair.
- No data is changed; the operation is read-only.

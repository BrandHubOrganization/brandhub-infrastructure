# 3.2.8 Sign Out

## Function Trigger
Begins when a signed-in user activates Sign Out.

## Function Description
- **Actors / Roles:** USER who is signed in.
- **Purpose:** End the current session by invalidating its tokens, and remember the sign-in method used so that the next visit is faster.
- **Interface:** Sign Out action available to a signed-in user; afterwards the screen returns to /login and highlights the method used last.
- **Data Processing:** The system invalidates the current access token and the current refresh token, clears the refresh cookie, records the sign-out event, and the screen stores the last sign-in method locally.

## Screen Layout
Figure — Sign Out:
- Entry point: Sign Out action in the account menu.
- The screen returns to /login and highlights the button matching the method used last, for example with a "Used last time" badge.

## Function Details
### Data Specifications
- **Input required:** the current access token and the current refresh token.
- **Input optional:** none.
- **System data:** userId, token identifier, the recorded sign-out event with its source address and client description.
- **Output:** no data; the refresh cookie is cleared.

### Business Rules
- **BR-01:** A missing or malformed access token → 401 INVALID_CREDENTIALS.
- **BR-02:** An expired or otherwise unusable access token is not an error: the sign-out still reports success.
- **BR-03:** The current access token and the current refresh token are both invalidated; an unusable token is skipped without failing the request.
- **BR-04:** The sign-out event is recorded only when the access token yields a user identity; otherwise nothing is recorded while success is still reported.
- **BR-05:** A sign-out affects only the device it was performed on; refresh tokens held by other devices stay valid, unlike a password change which invalidates them all.
- **BR-06:** The method used last, for example email or Google, is remembered by the screen itself and is never sent to the server; no cross-device synchronization is provided.

### Validation
- Missing or malformed access token → 401 INVALID_CREDENTIALS.
- Any unusable token during sign-out → reported as success.

## Functionalities
### Normal Flow
1. The user activates Sign Out.
2. The system checks the access token and identifies the account.
3. The system invalidates the access token and the refresh token, and clears the refresh cookie.
4. The system records the sign-out event with the source address and the client description.
5. The system returns success; the screen clears the stored access token, remembers the sign-in method used and returns to /login.

### Abnormal Cases
- Missing or malformed access token → 401 INVALID_CREDENTIALS.
- Expired or tampered access token → the sign-out still reports success; the identity is unknown, so nothing is recorded and only the refresh token is invalidated.
- Expired or unusable refresh token → the sign-out still reports success.

## Post-Conditions
- The access token and the refresh token are invalid and the refresh cookie is cleared in the browser.
- A sign-out event is recorded with the source address and the client description whenever the identity is known.
- The screen remembers the sign-in method used, and other devices stay signed in.

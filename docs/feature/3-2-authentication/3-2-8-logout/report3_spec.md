**3.2.8 Sign Out (Logout)**

**Function Trigger**

Begins when a signed-in user clicks "Log out" in the account/navbar menu (or the dashboard's logout button).

**Function Description**

- **Actors / Roles**: Any authenticated USER.
- **Purpose**: End the current session. Blacklists the current access and refresh token server-side and records a LOGOUT audit event, then clears local client state and redirects to /login.
- **Interface**: A "Log out" menu item / icon button in the Navbar and in the Dashboard page header.
- **Data Processing**: The client fires the logout call (fire-and-forget, not awaited) and, independent of its outcome, immediately clears local auth state and navigates to /login. The backend reads the access token header, the refresh token cookie, and request metadata, blacklists the access token (best-effort) and the refresh token (best-effort), writes an audit log when the access token yielded a user id, clears the refresh cookie, and returns 200.

**Screen Layout**

Figure — Sign Out entry points (no dedicated Sign Out screen exists):

- Navbar: a "Log out" icon button inside the account area.
- Dashboard page header: a separate "Log out" button that clears local state directly, without calling the logout endpoint.
- After either action, the user becomes unauthenticated and any protected route redirects to /login.
- A 401 response interceptor also forces logout automatically on session expiry, with toast **MSG22**; this path also does not call the logout endpoint.

**Function Details**
- **Data Specifications**
    - **Input required (backend)**: Authorization Bearer header. The refresh token cookie is optional.
    - **Input optional (backend)**: IP address and user-agent headers, used for the audit record.
    - **Input (frontend)**: none — no body is sent; the header and cookie are attached automatically.
    - **System data**: userId resolved from the access token's subject (only if it parses); the token's jti for blacklisting; the caller's ipAddress/userAgent.
    - **Output**: no payload, 200. The refresh token cookie is cleared.

- **Business Rules**
    - **BR-14**: Sign-out blacklists both access and refresh token jti values and clears the refresh cookie. Each blacklisting step is independently best-effort — either one failing (expired, malformed, wrong signature) is swallowed silently and does not fail the request. The refresh cookie is cleared unconditionally on every successful response. The frontend call itself is best-effort and swallows any error, proceeding to clear local state regardless.
    - **BR-16**: Security events (LOGIN, LOGOUT, PASSWORD_RESET) are always persisted to the audit log with IP + user agent. For logout, the audit row is written only if the access token successfully parsed to a userId; otherwise no row is written but success is still reported.
    - Only the tokens for the current device/session are invalidated; refresh tokens held by other devices are unaffected, unlike a password change which invalidates every refresh token.
    - Missing or malformed Authorization header is the one case that is not best-effort on the backend, though this never surfaces to the user since the client clears local state and navigates away regardless.

- **Validation**
    - Authorization header missing, or not starting with "Bearer " -> 401 INVALID_CREDENTIALS.
    - Expired or unparsable access token (header well-formed) -> not an error; sign-out still returns 200.
    - Missing, expired, or unparsable refresh token -> not an error; sign-out still returns 200.

**Functionalities**
- **Normal Flow**
    1. The user clicks "Log out" in the Navbar.
    2. The client calls the logout endpoint with the Bearer header and refresh cookie sent automatically, without awaiting it, and swallows any rejection.
    3. Independent of that outcome, the client clears local auth/workspace state and navigates to /login without waiting for the API response.
    4. The backend validates the Authorization header format, strips the prefix, and calls the service.
    5. The service parses the access token; on success it extracts the userId and blacklists the access token's jti.
    6. If a refresh token is present, the service blacklists its jti too, independent of step 5's outcome.
    7. If a userId was resolved in step 5, the service writes a LOGOUT audit log with ipAddress and userAgent.
    8. The backend clears the refresh token cookie and returns 200 with no data.
    9. By the time the response arrives, the user is typically already on /login; no toast is shown for the success case.

- **Abnormal Cases**
    - 4.a1: Authorization header missing or malformed -> the backend returns 401 INVALID_CREDENTIALS without calling the service. 4.a2: The frontend's error handler swallows it; the client still clears local state and navigates to /login with no user-facing error.
    - 5.a1: Access token present but expired or fails to parse -> caught and ignored; userId stays null; sign-out proceeds as idempotent success, no audit row written. 5.a2: Refresh token blacklisting still runs if present.
    - 6.a1: Refresh token absent, expired, or fails to parse -> caught and ignored; sign-out still returns 200.
    - N.a1: The logout call fails on the network (offline, timeout, server down) -> the client proceeds exactly as in the success case: local state cleared, redirect to /login, no error toast; the server-side token remains valid until natural expiry.
    - N.a2: A 401 from any API call triggers a forced local-only logout with toast **MSG22** ("session expired"); this path does not call the logout endpoint.

**Post-Conditions**

- The access token's and refresh token's jti values are blacklisted server-side (best-effort), the refresh cookie is cleared, and, when the access token was resolvable, a LOGOUT audit row exists.
- Regardless of the API call's outcome, local auth/workspace state is cleared and the user is redirected to /login.
- Sessions on other devices are unaffected.
- If the API call failed, the server-side token may remain valid until natural expiry, but the user is signed out of the current browser session either way.

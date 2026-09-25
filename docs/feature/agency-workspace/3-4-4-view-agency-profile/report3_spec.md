**3.4.4 View Agency Profile**

**Function Trigger**

A signed-in user opens the profile of an Agency they belong to, as Owner or as a Member. The profile is also shown right after selecting an Agency from the Agency list (3.4.1).

**Function Description**

- **Actors / Roles**: Agency Owner or Agency Member (any member role).
- **Purpose**: Show the branding and company information of an Agency to the people who work in it.
- **Interface**: Agency Profile page (/agencies/:agencyId/profile) — the branding section with name, logo, description, category, company size, contact details, brand colour, logo icon, tagline, founded year and social links. No separate profile data source; the page reads the same Agency profile used elsewhere.
- **Data Processing**: The system loads the Agency by its identifier, checks that the caller is the Owner or holds a Member record, and returns the branding and company information.

**Screen Layout**

Figure — Agency Profile page:

- Header with name, logo, tagline and brand colour.
- Company information: description, category, company size, website, phone, location, founded year (rendered as years in business).
- Social links: Facebook, LinkedIn, Instagram.
- No Workspace list and no Member list are shown here — company information only.

**Function Details**
- **Data Specifications**
    - **Input required**: the Agency identifier (agencyId) and a signed-in session.
    - **Input optional**: none.
    - **System data**: Agency profile — name, logoUrl, description, category, companySize, website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, plus id, ownerId, status, createdAt, updatedAt. The caller's Agency Member records are used for the access check.
    - **Output**: the profile of the Agency, restricted to branding and company information; no Workspace or Member data.

- **Business Rules**
    - **BR-29 (analogous)**: only the Owner, or a user holding a Member record, may view the profile. Any other signed-in user is refused with 400 NOT_AGENCY_MEMBER.
    - The Owner always has access, even with no Agency Member record; the Owner check stands on its own.
    - Every member role may view the profile — role does not narrow access.
    - The profile is not public; a user must be signed in and belong to the Agency.
    - This screen differs from the Agency Dashboard (3.4.2): profile carries branding and company information, dashboard carries management figures.
    - The profile response holds no internal detail beyond branding and company information.

- **Validation**
    - No signed-in session, or an invalid one → 401 UNAUTHORIZED, refused before Agency logic runs.
    - Agency does not exist → Display: **MSG38**
    - Caller is neither the Owner nor a Member → Display: **MSG39**
    - Agency already soft-deleted → the record is still returned, so Owner and Members can still view it. See 3.4.6 for removal behaviour.

**Functionalities**
- **Normal Flow**
    1. The user opens the profile of an Agency.
    2. The client requests the Agency profile with the signed-in session.
    3. The system confirms the session, then loads the Agency by its identifier.
    4. The system confirms the caller is the Owner or holds a Member record.
    5. The system returns the branding and company information.
    6. The client renders the profile, including years in business.

- **Abnormal Cases**
    - 2.a1: No signed-in session, or an invalid one → 401 UNAUTHORIZED, toast **MSG22**. 2.a2: The user signs in again and retries.
    - 3.a1: Agency does not exist → 404 AGENCY_NOT_FOUND, toast **MSG38**. 3.a2: The user returns to the Agency list.
    - 4.a1: Caller belongs to no part of the Agency → 400 NOT_AGENCY_MEMBER, toast **MSG39**; no profile data returned. 4.a2: The user returns to the Agency list and opens an Agency they belong to.
    - 4.b1: Agency already soft-deleted → the profile is still returned; no error, no toast. 4.b2: The user continues viewing normally.

**Post-Conditions**

- No Agency data is created, changed or removed.
- The profile shows correct company information and exposes no internal information.

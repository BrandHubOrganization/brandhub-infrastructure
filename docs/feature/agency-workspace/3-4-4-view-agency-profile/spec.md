# 3.4.4 View Agency Profile

## Function Trigger
A signed-in user opens the profile of an Agency they belong to — either as its Owner or as one of its Members. The profile is also shown straight after selecting an Agency from the Agency list (3.4.1).

## Function Description
- **Actors / Roles:** Agency Owner or Agency Member (any member role).
- **Purpose:** Show the branding and company information of an Agency to the people who work in it, so they know which company they represent.
- **Interface:** Agency Profile page (`/agencies/:agencyId/profile`) — the branding section of the Agency with name, logo, description, category, company size, contact details, brand colour, logo icon, tagline, founded year and the social links. There is no separate profile data source; the page reads the same Agency profile used elsewhere.
- **Data Processing:** The system loads the Agency by its identifier and then checks the caller: the caller must be the Owner of that Agency or hold an Agency Member record in it. When the caller is neither, the request is refused. The system then returns the branding and company information of the Agency.

## Screen Layout
Figure — Agency Profile page:
- Header with name, logo, tagline and brand colour.
- Company information: description, category, company size, website, phone, location, founded year (rendered as years in business, counted from the current year).
- Social links: Facebook, LinkedIn, Instagram.
- No Workspace list and no Member list are shown here — this screen carries company information only.

## Function Details
### Data Specifications
- **Input required:** The Agency identifier (`agencyId`) and a signed-in session.
- **Input optional:** None.
- **System data:** Agency profile — name, logoUrl, description, category (AgencyCategory), companySize (CompanySize), website, phone, location, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, plus id, ownerId, status (EntityStatus: ACTIVE / SOFT_DELETED), createdAt and updatedAt (full field list at 3.4.1). The Agency Member records of the caller are used for the access check.
- **Output:** The profile of the Agency, restricted to branding and company information. No internal data such as Workspace or Member lists is returned.

### Business Rules
- **BR-01:** Only the Owner of the Agency, or a user holding an Agency Member record in it, may view the profile. Any other signed-in user is refused with `400 NOT_AGENCY_MEMBER`.
- **BR-02:** The Owner always has access, even when no Agency Member record exists for them; the Owner check stands on its own.
- **BR-03:** Every member role may view the profile — role does not narrow access.
- **BR-04:** The profile is not public. A user must be signed in and belong to the Agency; an outside party cannot preview an Agency profile.
- **BR-05:** This screen differs from the Agency Dashboard (3.4.2): the profile carries branding and company information, while the dashboard carries management figures.
- **BR-06:** The profile response holds no internal detail beyond branding and company information.

### Validation
- No signed-in session, or an invalid one → `401 UNAUTHORIZED`, refused before the Agency logic runs.
- Agency does not exist → `404 AGENCY_NOT_FOUND`.
- Caller is neither the Owner nor a Member of the Agency → `400 NOT_AGENCY_MEMBER`.
- Agency already soft-deleted → the record is still returned, so the Owner and Members can still view the profile. See 3.4.6 for the removal behaviour.

## Functionalities
### Normal Flow
1. The user opens the profile of an Agency.
2. The client requests the Agency profile with the signed-in session.
3. The system confirms the session, then loads the Agency by its identifier.
4. The system confirms that the caller is the Owner of the Agency or holds an Agency Member record in it.
5. The system returns the branding and company information of the Agency.
6. The client renders the profile, including the years in business counted from the founded year.

### Abnormal Cases
- No signed-in session, or an invalid one → `401 UNAUTHORIZED`.
- Agency does not exist → `404 AGENCY_NOT_FOUND`.
- Caller belongs to no part of the Agency → `400 NOT_AGENCY_MEMBER`, no profile data returned.
- Agency already soft-deleted → the profile is still returned to the Owner and Members; removal does not revoke viewing at this point.

## Post-Conditions
- No Agency data is created, changed or removed.
- The profile shows correct company information and exposes no internal information.

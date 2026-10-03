**3.7.12 Recommend Collaborator**

**Function Trigger**

A Creator or Manager opens `/workspaces/:id/campaigns/:campaignId/recommend-collaborator` from within a Campaign to get AI-suggested media partners.

**Function Description**

- **Actors / Roles**: Creator, Manager.
- **Purpose**: Let a Creator/Manager ask AI for third-party media partner suggestions (newspapers, banner sites, TV channels) given industry/target audience/budget, then convert a chosen suggestion into a `ThirdPartyCollaborator` record (agency-level contact book) or link it to the current Campaign as a `CampaignCollaborator`.
- **Interface**: A Recommend Collaborator page showing AI-ranked suggestions with a "save to contact book" / "link to campaign" action.
- **Data Processing**: The system calls an AI model with `industry`/`targetAudience`/`budgetRange` and returns tiered recommendations; choosing one either creates a new `ThirdPartyCollaborator` row or attaches an existing one to the Campaign via `CampaignCollaborator`.

**Screen Layout**

Figure — Recommend Collaborator View:

- Input panel: industry, target audience, budget range.
- Results panel: ranked recommendation cards (name, type, tier, reason).
- Per-card action: "Add to Contacts" (save to `ThirdPartyCollaborator`) or "Link to Campaign" (link as `CampaignCollaborator`).

**Function Details**
- **Data Specifications**
    - **Input required**: `industry`, `targetAudience`, `budgetRange` for the AI call; `collaboratorId` (if choosing from the existing contact book) or `newCollaborator{name, type, contactInfo}` for the link-to-campaign step.
    - **Input optional**: none.
    - **System data**: `ThirdPartyCollaborator` (agency-level contact book: agencyId, partnerName, partnerType, contactInfo, notes, createdBy) and `CampaignCollaborator` (mediaCampaignId, collaboratorId, cooperationStatus default `CONTACTED`, updatedBy).
    - **Output**: AI recommendation list `{name, type, tier, reason}`; campaign-link response `{campaignCollaboratorId, collaboratorId, cooperationStatus}`.

- **Business Rules**
    - AI only *suggests* partners — it never auto-contacts or signs anything.
    - A chosen suggestion may become a new `ThirdPartyCollaborator` (agency-level) or link an existing one to the Campaign (`CampaignCollaborator`).
    - Low-budget input still returns the lowest-tier suggestion with a warning rather than an empty list.

- **Validation**
    - No special validation errors beyond standard auth/permission checks.

**Functionalities**
- **Normal Flow**
    - 1. A Creator/Manager opens the Recommend Collaborator page for a Campaign.
    - 2. The client submits industry/targetAudience/budgetRange to the AI recommendation endpoint.
    - 3. The system returns a tiered list of suggested partners.
    - 4. The user picks a suggestion and either saves it as a new `ThirdPartyCollaborator` or links an existing one to the Campaign as a `CampaignCollaborator`.

- **Abnormal Cases**
    - 3.a1: Budget too low for any strong match → the system still returns the lowest tier with a warning, not an empty list.

**Post-Conditions**

- A new `ThirdPartyCollaborator` or `CampaignCollaborator` row is created, available for follow-up tracking.

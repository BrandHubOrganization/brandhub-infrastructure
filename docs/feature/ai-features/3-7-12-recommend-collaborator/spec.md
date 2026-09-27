# 3.7.12 Recommend Collaborator

| | |
|---|---|
| FR Code | 3.7.12 |
| Feature | Recommend Collaborator |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR, MANAGER |
| Version | 2.0 — 2026-09-27 — aligned with PO decisions: system catalog initially, 2 saving branches (Agency ThirdPartyCollaborator vs CampaignCollaborator), handle No-Match cleanly, zero automatic status change to 'contacted' |
| Document status | Target Spec |
| Implementation status | Research-pending |

## Function Trigger

Begins when a Creator or Manager navigates to the Collaborator Recommendation screen within a Campaign (`/workspaces/:workspaceId/campaigns/:campaignId/recommend-collaborators`) or opens the "Find Media Partners" panel in Campaign Planning (`/workspaces/:workspaceId/campaigns/:campaignId`), and submits campaign targeting parameters (industry, audience, budget range, preferred media channels) to receive AI partner suggestions.

## Function Description

- **Actors / Roles:** CREATOR, MANAGER (Workspace members managing marketing campaigns and third-party media partnerships).
- **Purpose:** Provide algorithmic and AI-driven recommendations of external third-party media collaborators (online newspapers such as VnExpress, Tuoi Tre, Kenh14; digital banner networks; television & radio broadcast networks; outdoor billboard/OOH vendors) to expand marketing reach beyond native social media channels.
- **Phased Catalog Architecture (PO Decision D05):**
  - **Phase 1 (Initial Release):** Recommendations query a curated **System Catalog** (`system_collaborator_catalog`) managed by BrandHub administrators, containing verified media outlets, audience demographics, traffic/reach metrics, and indicative price benchmarks.
  - **Phase 2 (Agency Extension):** Allows matching against the current Agency's own private directory (`ThirdPartyCollaborator`).
  - *Multi-Tenant Data Isolation Rule:* The system is STRICTLY FORBIDDEN from searching or exposing private collaborator lists, proprietary rates, or contact histories belonging to other Agencies.
- **Two Distinct Saving Branches (PO Decision):**
  1. **Branch A — Save to Agency Directory (`ThirdPartyCollaborator`):** Adds the chosen media partner to the Agency's permanent address book for ongoing cross-campaign relationship management.
  2. **Branch B — Link to Campaign (`CampaignCollaborator`):** Links the partner directly to the current Campaign to track proposed booking packages, target slots, and campaign deliverables.
- **Strict Cooperation Status Rule (PO Decision):**
  - AI recommendations are strictly advisory. The AI DOES NOT automatically contact partners, negotiate bookings, or execute contracts.
  - When a recommended partner is linked to a Campaign, its status MUST default to `PROPOSED` (or `CONSIDERING`). Under NO circumstance may the system automatically set the status to `CONTACTED` or `SIGNED` without explicit human action.
- **Strict No-Match Handling (PO Decision):**
  - When the requested budget is below the minimum threshold for all catalog outlets, or the niche industry has zero coverage, the system returns an empty result list (`recommendations: []`) with a structured diagnostic explanation (`noMatchReason`).
  - The system MUST NEVER hallucinate (fabricate) fictional media companies, fake journalists, or false pricing to avoid returning an empty list.
- **Interface:**
  - Recommendation Query Form: Industry selector (FMCG, Tech, Fashion, F&B, Healthcare, etc.), Target Audience demographics, Budget range slider (Min – Max in VND), Media Type filters (Online Newspapers, Display Ads/Banners, TV/Radio, OOH/Billboards), Campaign Objective (Brand Awareness, Product Launch, Lead Gen).
  - Recommended Partners Grid / Tiered Cards: Cards grouped by Tier 1 (National/Top Reach), Tier 2 (Targeted/High ROI), Tier 3 (Niche/Cost-Effective). Each card displays outlet logo, verified monthly traffic/readers, matching score (%), rationale explanation, benchmark cost range, and action buttons.
  - Action Dropdowns on Cards: "Add to Campaign as Proposed" and "Save to Agency Directory".
- **Data Processing:**
  - Gateway routes request to Business Service → validates workspace and campaign ownership → reserves AI credits.
  - AI Recommendation Engine computes relevance scores combining attribute filtering with vector/semantic matching against the System Catalog.
  - Ranks results, applies budget feasibility clamping, builds structured rationales, and returns results.

## Routes and DTOs

### Public Client Endpoints (API Gateway → Business Service)

- `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/ai/recommend-collaborators`
  - Body: `RecommendCollaboratorRequest`
  - Response `200 OK`: `ApiResponse<CollaboratorRecommendationResponseDto>`
- `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/collaborators/link`
  - Body: `LinkCampaignCollaboratorRequest`
  - Response `201 Created`: `ApiResponse<CampaignCollaboratorDto>`
- `POST /api/v1/workspaces/{workspaceId}/agency/collaborators`
  - Body: `CreateAgencyCollaboratorRequest`
  - Response `201 Created`: `ApiResponse<ThirdPartyCollaboratorDto>`

### DTO Schemas

```json
// RecommendCollaboratorRequest
{
  "industry": "TECH_CONSUMER_ELECTRONICS",
  "targetAudience": "Tech enthusiasts, gamers, and early adopters aged 18-35 in Vietnam urban areas",
  "minBudgetVnd": 15000000,
  "maxBudgetVnd": 60000000,
  "preferredMediaTypes": ["ONLINE_NEWSPAPER", "TECH_PORTAL"],
  "campaignObjective": "PRODUCT_LAUNCH",
  "includeAgencyDirectory": false // Phase 2 toggle
}

// CollaboratorRecommendationResponseDto
{
  "totalMatches": 2,
  "noMatchReason": null, // enum: null, "BUDGET_BELOW_MINIMUM", "UNSUPPORTED_INDUSTRY", "NO_MATCHING_CRITERIA"
  "recommendations": [
    {
      "catalogCollaboratorId": "sys-collab-vnexpress-tech",
      "name": "VnExpress - Số Hóa",
      "mediaType": "ONLINE_NEWSPAPER",
      "tier": "TIER_1", // enum: TIER_1 (Top Reach), TIER_2 (Category Leader), TIER_3 (Niche)
      "reachMetric": "45M monthly pageviews, #1 tech readership in VN",
      "matchScore": 94,
      "estimatedCostVndRange": {
        "min": 25000000,
        "max": 50000000
      },
      "rationale": "Matches your product launch objective with high credibility and reach among urban tech buyers. Benchmark pricing for PR article fits within your 60M budget.",
      "suggestedPackage": "Standard PR Article + Homepage Sidebar Tech Spotlight"
    },
    {
      "catalogCollaboratorId": "sys-collab-tinhte-01",
      "name": "Tinh Tế (Tinhte.vn)",
      "mediaType": "TECH_PORTAL",
      "tier": "TIER_2",
      "reachMetric": "12M monthly visits, highly engaged hardware enthusiast community",
      "matchScore": 89,
      "estimatedCostVndRange": {
        "min": 15000000,
        "max": 35000000
      },
      "rationale": "Ideal for unboxing and in-depth specs discussion. Community engagement rate is 3x higher than general news portals for electronic gadgets.",
      "suggestedPackage": "Dedicated Video Review + Forum Discussion Thread"
    }
  ],
  "suggestedAdvice": null,
  "creditSettled": 5
}

// LinkCampaignCollaboratorRequest (Branch B)
{
  "catalogCollaboratorId": "sys-collab-vnexpress-tech",
  "allocatedBudgetVnd": 35000000,
  "proposedDeliverables": "1 Sponsored Tech Review Article on So Hoa sub-portal",
  "notes": "Need to confirm publishing date before October 15"
}

// CampaignCollaboratorDto
{
  "campaignCollaboratorId": "cc-4455-6677",
  "campaignId": "c-1122-3344",
  "name": "VnExpress - Số Hóa",
  "mediaType": "ONLINE_NEWSPAPER",
  "cooperationStatus": "PROPOSED", // STRICTLY PROPOSED; NEVER "CONTACTED"
  "allocatedBudgetVnd": 35000000,
  "proposedDeliverables": "1 Sponsored Tech Review Article on So Hoa sub-portal",
  "contactPerson": "TBD",
  "createdAt": "2026-09-27T09:45:00Z"
}

// CreateAgencyCollaboratorRequest (Branch A)
{
  "catalogCollaboratorId": "sys-collab-vnexpress-tech",
  "notes": "Added from System Catalog recommendation for Q4 Campaigns"
}
```

## Screen Layout

Figure — Recommend Collaborator Dashboard (`brandhub-web/src/pages/campaigns/RecommendCollaboratorPage.tsx`):
- Top Breadcrumbs: `Campaigns / [Campaign Name] / Media Collaborator Recommendations`.
- Left Form Panel: "Targeting & Budget Parameters"
  - Industry Dropdown: Select single or multi-industry category.
  - Audience Description Textarea: Pre-filled from Campaign brief with editable text.
  - Budget Dual-Slider: Range selector from 5,000,000 VND to 500,000,000 VND.
  - Media Channel Checkboxes: `[x] Online Newspapers`, `[x] Tech/Specialist Portals`, `[ ] TV & Radio Broadcast`, `[ ] Outdoor Billboards (OOH)`.
  - Button "Find Matching Collaborators (5 Credits)" (primary orange).
- Right Results Canvas:
  - If matches found:
    - Tier Groups:
      - Section `Tier 1: High-Authority National Outlets` (Gold badge).
      - Section `Tier 2: Targeted Vertical Outlets` (Silver badge).
      - Section `Tier 3: Cost-Effective & Niche Outlets` (Bronze badge).
    - Card Component: Outlet name, MediaType chip, Match score gauge (e.g. `94% Match`), Estimated pricing range pill (`25M - 50M VND`), Rationale callout box explaining why this partner fits the objective.
    - Card Action Buttons:
      - Primary Button: "Add to Campaign Plan" (opens link drawer).
      - Secondary Button: "Save to Agency Directory" (bookmark icon).
  - If No-Match (`recommendations: []`):
    - Empty state graphic with warning banner: "No matching media partners found within your current budget range (10,000,000 VND max)".
    - Diagnostic advice: "Top tech newspapers typically require a minimum budget of 15,000,000 VND for sponsored articles. Consider adjusting your maximum budget slider or exploring niche community forums."
    - Action button: "Adjust Search Filters".

## Function Details

### Data Specifications

- **Input required:**
  - `workspaceId` (path, UUID): Current workspace ID.
  - `campaignId` (path, UUID): Target campaign ID.
  - `industry` (body, enum): Target industry code.
  - `targetAudience` (body, string, 10–500 characters).
  - `minBudgetVnd` (body, number): Non-negative integer.
  - `maxBudgetVnd` (body, number): Must be `>= minBudgetVnd`.
- **Input optional:**
  - `preferredMediaTypes` (body, array of enums): `ONLINE_NEWSPAPER`, `TECH_PORTAL`, `DISPLAY_NETWORK`, `TV_RADIO`, `OOH_BILLBOARD`.
  - `campaignObjective` (body, enum): `BRAND_AWARENESS`, `PRODUCT_LAUNCH`, `LEAD_GENERATION`, `PR_CRISIS`.
  - `includeAgencyDirectory` (body, boolean): Default `false`.
- **System data:**
  - Database table `system_collaborator_catalog`: `id`, `name`, `media_type`, `tier`, `target_industries`, `monthly_reach_description`, `min_budget_vnd`, `max_budget_vnd`, `audience_profile_json`, `is_active`.
  - Database table `third_party_collaborators`: Agency-level directory records (`agency_id`, `name`, `contact_info`, `notes`).
  - Database table `campaign_collaborators`: Campaign-level booking records (`campaign_id`, `collaborator_id`, `cooperation_status`, `budget`).
- **Output:**
  - `CollaboratorRecommendationResponseDto` containing matching partners, rationale, and advice, or explicit no-match explanation.

### Business Rules

- **BR-AI-1201 (System Catalog Primary Source & Agency Isolation):**
  - Recommendations query the curated `system_collaborator_catalog`.
  - When Phase 2 Agency search is enabled, the search only queries collaborators belonging to `request.agencyId`. Cross-agency data lookup is strictly prohibited to protect agency competitive intelligence.
- **BR-AI-1202 (Two Distinct Saving Branches):**
  - **Branch A (`ThirdPartyCollaborator`):** Adds partner to the Agency's reusable directory (`/agency/collaborators`).
  - **Branch B (`CampaignCollaborator`):** Associates partner directly with the Campaign (`/campaigns/{campaignId}/collaborators/link`). Both branches are distinct, independent actions.
- **BR-AI-1203 (Strict Cooperation Status Invariant — Zero Auto-Contact):**
  - AI only provides recommendations. It possesses zero authority to initiate outreach or alter commercial statuses.
  - When linking a recommended partner to a Campaign, the initial `cooperation_status` MUST be set to `PROPOSED`.
  - The system MUST NEVER set `cooperation_status = CONTACTED`, `NEGOTIATING`, or `SIGNED`. Only human managers may manually transition status after real-world contact.
- **BR-AI-1204 (Honest No-Match & Anti-Hallucination Policy):**
  - If no partner in the catalog matches the budget, media type, or industry criteria, the system MUST return an empty array `recommendations: []` with an appropriate `noMatchReason`.
  - The AI MUST NOT invent fake media companies, fictitious PR packages, or non-existent contacts.
- **BR-AI-1205 (Credit Deduction for Recommendations):**
  - Running a recommendation search consumes 5 credits per query. Credits are reserved before matching and settled upon delivering recommendations or valid empty no-match analysis.
- **BR-AI-1206 (Tier Categorization Hierarchy):**
  - `TIER_1`: Top-tier national publications / high-traffic networks (e.g. VnExpress, Tuoi Tre, VTV).
  - `TIER_2`: Category-leading vertical portals (e.g. CafeF for finance, Tinhte for tech, Kenh14 for youth lifestyle).
  - `TIER_3`: Niche publications, regional broadcast stations, and boutique digital media.

### Validation

- Missing `industry`, `targetAudience`, or negative budget values → 400 `VALIDATION_ERROR`, Display: MSG-AI-1201 ("Please provide a valid industry, audience description, and budget range.").
- `minBudgetVnd > maxBudgetVnd` → 400 `INVALID_BUDGET_RANGE`, Display: MSG-AI-1202 ("Minimum budget cannot exceed maximum budget.").
- Creator/Manager has insufficient credits (< 5 credits) → 402 `INSUFFICIENT_AI_CREDIT`, Display: MSG-AI-701.
- Campaign does not exist or user lacks access → 403 `FORBIDDEN` / 404 `CAMPAIGN_NOT_FOUND`, Display: MSG-AI-01.
- Attempting to set `cooperationStatus: "CONTACTED"` during initial creation → 400 `INVALID_INITIAL_STATUS`, Display: MSG-AI-1203 ("Initial status must be PROPOSED; cannot create directly as CONTACTED.").
- Partner already linked to Campaign → 409 `COLLABORATOR_ALREADY_LINKED`, Display: MSG-AI-1204 ("This collaborator is already part of the campaign plan.").

## Functionalities

### Normal Flow — Search Recommendations

1. Manager opens Campaign Detail (`/workspaces/:workspaceId/campaigns/:campaignId`) and navigates to the "Media Collaborators" tab.
2. Manager clicks "AI Recommend Collaborators".
3. Manager fills in: Industry = `TECH_CONSUMER_ELECTRONICS`, Audience = "Urban tech enthusiasts 18-35", Budget = `15,000,000 – 60,000,000 VND`, Channels = `[Online Newspaper, Tech Portal]`.
4. Manager clicks "Find Matching Collaborators".
5. Client submits `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/ai/recommend-collaborators`.
6. Business Service validates permissions and reserves 5 credits.
7. AI Recommendation Engine filters active records from `system_collaborator_catalog`, evaluates audience semantic match, checks budget feasibility, and constructs rationale statements.
8. System records 5 credits settled and returns `200 OK` with 2 matching partners (VnExpress - Số Hóa and Tinh Tế).
9. Frontend renders the tiered cards with match scores and rationales.

### Normal Flow — Branch B: Link Collaborator to Campaign

1. Manager clicks "Add to Campaign Plan" on the "VnExpress - Số Hóa" card.
2. A drawer opens displaying prefilled partner information with editable fields: Allocated Budget (defaults to 35,000,000 VND) and Proposed Deliverables ("1 Sponsored Tech Review").
3. Manager confirms and clicks "Save to Campaign".
4. Client sends `POST .../campaigns/{campaignId}/collaborators/link` with `{ "catalogCollaboratorId": "sys-collab-vnexpress-tech", "allocatedBudgetVnd": 35000000, ... }`.
5. Business Service creates a `campaign_collaborators` row with `cooperationStatus = 'PROPOSED'`.
6. Endpoint returns `201 Created` with `CampaignCollaboratorDto`.
7. Toast MSG-AI-1205 ("Partner added to campaign as Proposed."). Card in recommendation view shows badge "Added to Plan".

### Normal Flow — Branch A: Save Collaborator to Agency Directory

1. Manager clicks "Save to Agency Directory" (Branch A) on the "Tinh Tế" card.
2. Client sends `POST .../agency/collaborators` with `{ "catalogCollaboratorId": "sys-collab-tinhte-01" }`.
3. Business Service creates a record in `third_party_collaborators` scoped to the current Agency ID.
4. Endpoint returns `201 Created`. Toast MSG-AI-1206 ("Partner saved to Agency permanent directory.").

### Abnormal Cases

- 6.a1: Credit balance is insufficient (< 5 credits) → 402 `INSUFFICIENT_AI_CREDIT`, toast MSG-AI-701.
- 7.a1: User inputs budget below catalog minimums (e.g. Max budget = 2,000,000 VND for national newspapers) → AI Engine detects zero matches; returns `200 OK` with `recommendations: []`, `noMatchReason: "BUDGET_BELOW_MINIMUM"`, and suggested advice: "Minimum pricing for digital news PR starts at 5,000,000 VND. Increase budget slider to view available outlets."
- 7.b1: Requested industry is unsupported in system catalog → returns `200 OK` with `recommendations: []`, `noMatchReason: "UNSUPPORTED_INDUSTRY"`, and message advising general business media alternatives.
- 4.a1 (Branch B): Partner is already attached to this Campaign → 409 `COLLABORATOR_ALREADY_LINKED`, toast MSG-AI-1204.
- 5.a1 (Branch B): Request payload attempts to specify `cooperationStatus: "CONTACTED"` → Business Service validation fails with 400 `INVALID_INITIAL_STATUS`, forcing the status to remain `PROPOSED`.

## Post-Conditions

- On recommendation query: Search transaction logged in audit table; 5 AI credits settled.
- On Branch B link: A new row exists in `campaign_collaborators` with `cooperation_status = PROPOSED`; campaign estimated budget updated.
- On Branch A save: A new row exists in `third_party_collaborators` scoped to the Agency ID.

## Out of Scope

- Automated email dispatch, API booking integration, or contract negotiation with media agencies.
- Automated media monitoring / post verification of published newspaper links (handled in publishing/tracking modules).
- Payment processing or escrow for collaborator booking fees.

## References

- [06-ai-features.md](../../../ba/06-ai-features.md)
- [07-publishing-social-collaborator.md](../../../ba/07-publishing-social-collaborator.md)
- [08-subscription-billing.md](../../../ba/08-subscription-billing.md)
- [11-data-entities-glossary.md](../../../ba/11-data-entities-glossary.md) (Entities: `ThirdPartyCollaborator`, `CampaignCollaborator`)
- [ai-features-spec-alignment-plan.md](../../../plan/ai-features-spec-alignment-plan.md) (PO Decision D05, Section 2.7, Section 4: 3.7.12)

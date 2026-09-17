# Task: [DA-E04-01] Write functional objectives per role (6 roles x features)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical  
**Output Document:** [`docs/ba/DA-E04-01-functional-objectives-per-role.md`](docs/ba/DA-E04-01-functional-objectives-per-role.md)

---

## Goal
Translate the approved use cases into a concise functional requirements section organized by role so that each team member has a definitive feature checklist for their implementation work.

## Acceptance Criteria
- [x] Functional objectives exist for all 6 roles: `ADMIN`, `OWNER`, `MANAGER`, `CREATOR`, `CLIENT`, `GUEST`
- [x] Each role section lists its features as testable "The system shall…" statements
- [x] Every functional objective traces back to at least one UC/FR ID (`FR-3.X.Y`) from the approved list
- [x] Use the exact role names from the JWT claim (`ADMIN`, `OWNER`, `MANAGER`, `CREATOR`, `CLIENT`, `GUEST`) throughout

## Technical Notes
- Used exact role names from JWT claims to ensure absolute consistency across frontend/backend RBAC.
- Organized 128 testable statements across all 10 business domains (Authentication, Profile, Agency, Workspace, Media Package, Campaign, Content Editor, AI Features, Social Publishing, Subscription & Admin).

## Dependencies
- **Blocked by:** DA-E03-02, DA-E03-03, DA-E03-04, DA-E03-05 (Completed)
- **Blocks:** DA-E04-05, DA-E07-01 (Unblocked)


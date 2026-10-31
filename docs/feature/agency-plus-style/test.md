# Test Specification — Agency Plus Sidebar & Badge Visual Styling

## 1. Traceability & Scope

| Field | Value |
| :--- | :--- |
| **Feature** | Agency Plus Active Tier Styling (`agency-plus-style`) |
| **Related FRs** | `FR 3.9.1 Upgrade Plan`, `FR 3.4.1 List Agency` |
| **Canonical Roles** | `Owner`, `Manager`, `Creator`, `Client` |
| **Overall Status** | **Passed (100%)** |

---

## 2. Verification & Test Case Matrix

| Test Case ID | Type | Condition / Input | Expected Result | Status |
| :--- | :---: | :--- | :--- | :---: |
| `UTCID01` | `N` | Selected agency has confirmed `ACTIVE` `PLUS` subscription | Sidebar switcher renders orange border, subtle orange tint, diamond icon, and `Plus` badge in both expanded and compact modes | **Passed** |
| `UTCID02` | `N` | User switches from `PLUS` agency to `FREE` (Basic) agency | Plus styling resets immediately to neutral border/background with no stale badge | **Passed** |
| `UTCID03` | `B` | Subscription status is loading, `EXPIRED`, or non-Owner lacks billing read | Retains neutral styling; never renders a fake `Plus` fallback badge | **Passed** |
| `UTCID04` | `A` | Subscription endpoint returns network/5xx error | Gracefully falls back to neutral styling without crashing sidebar switcher | **Passed** |
| `UTCID05` | `N` | Theme and locale toggle (`VI` / `EN`, Light / Dark mode) | Contrasts and localized product titles render cleanly without layout shift | **Passed** |

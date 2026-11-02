# Package quantity input correction

Fix leading zero accumulation when replacing deliverable quantity. Allow clearing the field while typing; required integer >=1 validation remains native and on the backend. Normalize leading zeros without silently replacing an empty/invalid quantity with 1. Same editor for package creation and negotiation, both roles. Keep numeric API contract and all service/unit/approval permissions. Existing labels/translations and semantic theme controls unchanged; verify vi/en, light/dark, keyboard and mobile.

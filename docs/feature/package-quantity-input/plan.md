# Plan

OfferingEditor currently converts an empty input to numeric zero, which React writes back and browser number inputs retain as leading zeros. Render the zero/empty draft as an empty string and strip redundant leading zeros on input before updating numeric parent state. Keep required/min/step constraints. No DB/API/i18n changes. Verify the actual editor in a private browser with local fixture, no real API. Run Web checks. QA artifacts stay ignored in keep-local-only.

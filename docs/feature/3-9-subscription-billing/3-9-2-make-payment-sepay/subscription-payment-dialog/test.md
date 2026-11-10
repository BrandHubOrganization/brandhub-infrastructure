# Payment dialog

Assert Upgrade keeps plans URL and opens named dialog; automatically creates QR; closing and reopening preserves idempotency key; pending changes only from backend; fulfillment refreshes current plan; test legacy route and keyboard close. Run typecheck and subscription Playwright suite.

Results: Type-check and git diff --check passed. All 13 subscription Chromium tests passed, including plans URL retained, named dialog opening, Escape closing, automatic QR order creation and identical Idempotency-Key after reopening. Catalog light/dark, responsive and VI/EN checks passed. Payment API is mocked; no real transfer initiated. Fulfillment query invalidation is implemented; a dedicated fulfillment browser assertion has not been added.

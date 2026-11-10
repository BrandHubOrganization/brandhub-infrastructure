# Verification plan
Mock billing API: entering checkout creates an order without a click; StrictMode creates once; reload reuses idempotency key; pending stays pending until server fulfillment. Invalid tier/non-owner creates zero orders. Error permits retry with same key. Verify localized loading text and theme token contrast.

Results: TypeScript type-check passed. Targeted Chromium test passed: automatic creation without initial button, one POST on initial mount, reload uses the same Idempotency-Key, pending status remains server-controlled. Existing semantic tokens preserved; VI/EN generatingQr labels added. No real payment was initiated by these mocked API tests.

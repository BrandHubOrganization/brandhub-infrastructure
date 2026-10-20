# Tests

- Open Image tab and ambassador dialog: describe/review only, no sheet controls.
- Generate: request includes prompt, steps 25, width 832, height 1248.
- Review supports editing and regenerating; select closes modal and selects portrait.
- Failed request displays error and allows retry.
- No character-sheet endpoint requested.
- Check Vietnamese/English labels and light/dark layout.

## Verification
- TypeScript: passed (before regression test addition).
- Service regression: passed; confirms authenticated gateway payload with steps 25, width 832, height 1248.
- ESLint: no errors; existing set-state-in-effect warning in product reference selection.
- Browser tests added for vi/light and en/dark; execution blocked by localhost network access/connection timeout. Visual and live worker verification remain unconfirmed.

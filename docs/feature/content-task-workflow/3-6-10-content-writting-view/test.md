# Test — Content Writing View (FR 3.6.10)

> Status: **Draft — not yet coded, no concrete test cases.** V3: canvas + real-time OT architecture (see [spec.md](spec.md), [plan.md](plan.md)).

Test cases will be added once the API Contract and the OT/CRDT direction in [plan.md §6](plan.md#6-technical-risks) are finalized. Expected groups:

- **Happy path**: open content → canvas renders correctly from snapshot + tail operations; typing → operation sent/received over WebSocket → persisted correctly.
- **Version history**: restoring an older snapshot → the canvas re-renders the content correctly as of that point.
- **Task type**: content writing on a Task that is not `post` → 400.
- **Canvas rendering**: clicking a point on the canvas → the cursor lands at the correct character position (correct text measurement); line-breaking is correct once content exceeds one line.
- **Vietnamese IME**: typing diacritics via Unikey/Telex in the hidden input → characters render correctly on the canvas (not split apart due to forwarding raw keystrokes mid-composition).
- **Operational Transformation — convergence**: two clients both submit operations based on the same `baseSequenceNumber` (e.g. both insert near the same position) → after the server transforms + broadcasts, both clients must converge to the exact same document. Should be written as a property-based test (random sequences of operation pairs, always assert convergence) rather than only a few fixed cases.
- **Offline/reconnect**: a client loses its WebSocket connection mid-session, types a few more operations (queued locally) → reconnects → the operations are resent and applied in the correct order; if `baseSequenceNumber` has since been compacted by the server, the client must reload a fresh snapshot instead of erroring.
- **Accessibility**: the canvas content must have a matching text copy in the hidden DOM layer used by screen readers, kept in sync after every operation.
- **Font auto-conversion**: publishing content with characters needing font conversion → the output matches the target platform's standard.

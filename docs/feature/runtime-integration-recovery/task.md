# Execution checklist

- [x] Back up and migrate local Mail schema; fold exact definitions into init; verify parity and rerun safety.
- [x] Route Task WebSocket through Gateway; test handshake forwarding and rejection.
- [x] Fix bounded concurrent HTTP retries and invalid refresh envelope handling; test.
- [x] Refresh editor connection credentials per attempt without losing pending edits; expose initial load errors.
- [x] Reject malformed Request envelopes; verify valid empty results and error propagation.
- [x] Inspect deployment absence handling without modifying successful deployment data.
- [x] Bundle licensed local emoji data; retain search/categories and fix retry.
- [x] Update vi/en keys and check light/dark + keyboard interaction.
- [x] Run focused regressions, type-check, lint and isolated browser checks; record actual results in test.md.

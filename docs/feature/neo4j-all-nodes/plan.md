# Plan
1. New AI overview selection/page model, parameterized keyset node query and bounded induced-edge query. Preserve any label in all-scope node mapping; public mapping unchanged. Reuse read-only/timeouts/real-driver guard.
2. Add scope public/all to expand, apply unrestricted node/relationship read only for explicit all; preserve caps. New overview API internal key.
3. Business admin-only overview proxy with bounded validation; explicit scoped expand overload preserves existing Java callers. No access-rule changes to public endpoints.
4. Web overview response schema/API method and All nodes mode with search/page-size/keyset previous stack/refetch; reuse workspace with scope=all, no default-hidden posts, disconnected nodes visible. Error/empty have no invented graph.
5. Existing test files cover keyset continuation, unknown/disconnected/brand nodes, edge caps/projection, scoped expand, auth/validation; run AI, Business tests and Web CI. Use isolated local Neo4j fixture for actual queries if available; never shared DB writes.

# Plan

1. AI models define bounded search/neighborhood and explicit node/edge/result
   contracts. New graph explorer service uses parameterized Cypher, read sessions,
   one managed transaction per request, transaction timeout and overall deadline.
2. Search pages include limit+1 lookahead; neighborhood uses bounded breadth-first
   expansion (fanout+1 per node), deterministic ordering, elementId deduplication,
   endpoint closure, property allowlists and truncation reasons. No path explosion
   or APOC dependency. Both endpoints restrict public trend graph vocabulary.
3. Protected explorer router is mounted before the legacy catch-all trend route.
   Fix legacy real-driver traversal to rethrow failures and select the real root
   even if it has no relationships; retain its successful response contract.
4. Business thin controller, request records and Admin service guard every method
   before forwarding. Validate bounded input and upstream shape. Map only graph
   resource-not-found to 404. Add an explicit encoded-URI GET method to the shared
   client to prevent WebClient double encoding; existing String calls keep their
   behavior. Verify raw query strings with a local HTTP stub.
   Node search and expansion share public-node predicates and parameter bounds;
   explicit label validation avoids dynamic label/Cypher injection.
5. Local-only unit/HTTP fixtures and direct read-only live graph smoke validate
   no writes, real topology, empty vs missing vs unavailable, and authorization.
   No frontend or locale changes in this backend-only phase.

## Operational notes

- Existing pipeline/Neo4j credentials remain server-side; READ_ACCESS selects the
  read routing mode, not a database permission boundary. Only fixed read Cypher
  is exposed. A dedicated read-only Neo4j account can be provisioned separately;
  this phase does not rotate or reduce the writer's existing credentials.
- Uses the importing-WITH subquery form supported before Neo4j 5.23. Current Aura
  emits a deprecation warning for that form; queries succeed. No APOC, graph DDL
  or installation of Bloom is required for these APIs.
- Start/restart Business and AI to register the routes after review. No automatic
  service restart is performed during implementation. JWT/Gateway live smoke is
  separate from isolated controller and direct Neo4j checks.
- Driver reference: https://neo4j.com/docs/api/python-driver/current/api.html

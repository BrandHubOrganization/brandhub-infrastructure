# Plan

1. Add `app/services/trend_fit/graph_context.py`, reusing `get_neo4j_driver`. Run a fixed parameterized Cypher query in a read session; restrict exact trend ID, source-backed mention edges and client scope. Bound records and serialize compact JSON with source provenance.
2. Apply a two-second Neo4j query timeout and a three-second async deadline. Missing graph data and failures yield no context. Never use the generic traversal's mock or inferred semantic edges as evidence.
3. In the existing async caption endpoint, load graph context only after resolving a pipeline event trend. Pass it as an optional keyword to `generate_caption_variants`; callers without graph context keep their existing call signature.
4. Add the observations and interpretation rules to the prompt. Keep graph observations out of the verified numeric-claim sources so an engagement count or entity name cannot authorize product claims.
5. Add retrieval tests, endpoint wiring/skip tests, and a captured-provider-prompt test. Update the architecture report with the new source and its limits.

No Java, frontend, model contract, database schema, ingestion, or dependency changes. Existing staged edits to the general Neo4j service remain untouched. UI i18n/theme work is not applicable.

Neo4j driver references: https://neo4j.com/docs/python-manual/current/concurrency/ and https://neo4j.com/docs/python-manual/current/query-advanced/.

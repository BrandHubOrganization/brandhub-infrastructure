# Neo4j trend graph core

## Objective and acceptance criteria

Provide a read-only backend for a future Bloom-style explorer of the public trend
graph. This phase changes no UI, Chroma, scoring, ingestion, schema or stored data.
An active Admin can search persisted Trends, inspect the graph vocabulary, and
retrieve a bounded neighborhood around a Trend. These are Neo4j records, not the
Redis published ranking; a stored Trend may not be in a published top list.

Nodes include Trend, CrawledPost and evidenced Entity subtypes. Restrict traversal
to BELONGS_TO, MENTIONS and ASSOCIATED_WITH and nodes without a brand namespace.
Only Trend IDs beginning `trend:` are eligible. Do not expose private RAG graphs.
Return node/edge IDs, labels/type, selected properties, directed source/target,
counts, requested depth, and explicit truncation reasons. Preserve parallel edges.
IDs based on Neo4j elementId are opaque and valid for the existing graph lifetime;
clients must refetch after database recreation, not persist these as business IDs.

## Contract

Business endpoints, all GET under `/api/v1/admin/ai/trend-graph`:
- `/catalog`: fixed supported labels, relationships and request limits.
- `/trends?q=&date=YYYY-MM-DD&offset=0&limit=20`: bounded search with hasMore.
- `/neighborhood?trendId=trend:...&depth=2&maxNodes=100&maxEdges=200&fanout=25`.
- `/nodes?q=&label=&date=YYYY-MM-DD&offset=0&limit=20`: search eligible public
  nodes, optionally restricted to a supported label. Date matches stored n.date.
- `/expand?nodeId=...&depth=1&maxNodes=100&maxEdges=200&fanout=25`: center the
  bounded neighborhood on an eligible public node by elementId or business ID.

AI exposes the same suffixes under `/api/v1/ai/graph/explorer`, protected by the
existing internal key. Business wraps results in ApiResponse. Search uses literal
case-insensitive text, no user Cypher, and date matches Trend.date exactly.
Limits: depth 1..2, nodes 1..200, edges 1..400, fanout 1..50, page 1..100,
offset 0..10000, q <=100, trendId <=300. Unknown Trend returns 404; disconnected
existing Trend returns one real node. Invalid input returns 400/422. Neo4j failure
or timeout returns structured 503, never an empty-success or synthetic node.
The legacy graph read must also stop hiding failures; existing write APIs remain.

Search returns `{items, offset, limit, hasMore}` without an expensive exact count.
Each node has `{id, businessId, name, labels, type, properties,
propertiesTruncated}`; each edge has `{id, source, target, type, properties,
propertiesTruncated}`. Graph returns `{trendId, rootId, nodes, edges, nodeCount,
edgeCount, depth, maxNodes, maxEdges, fanout, truncated, truncationReasons}`.
Properties use a public allowlist, omit non-finite numbers and cap each text value
at 4000 characters. No arbitrary node-property dump.

`truncationReasons` can contain `FANOUT_LIMIT`, `NODE_LIMIT` or `EDGE_LIMIT`.
`truncated=false` means no additional safety limit was encountered within the
requested depth and supported vocabulary; it never claims to include the entire
database. Fanout flags conservatively report omitted adjacency rows, even if an
edge might also be visible from another expanded node. Expansion from a selected
public node keeps the same visibility rules, vocabulary and depth 1..2 bounds.
No unrestricted Cypher or private brand-graph access is exposed.

## Definition of done / out of scope

Pass isolated validation, traversal/security/error tests, Business compile and
read-only live Neo4j smoke checks if available. No new test artifacts committed;
local checks belong in ignored keep-local-only. No migration, seeding, graph
editing, arbitrary query API, automatic restart, Bloom UI, vector plot or push.

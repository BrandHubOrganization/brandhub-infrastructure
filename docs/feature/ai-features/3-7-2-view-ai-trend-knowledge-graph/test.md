# Test Specification — FR 3.7.2: View AI Trend Knowledge Graph

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.2` |
| **Function Name** | View AI Trend Knowledge Graph |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Admin, Owner` |
| **Target Class & Method** | `AdminTrendGraphService.neighborhood()` (35 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminTrendGraphServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Query bounded Neo4j trend knowledge graph neighborhoods with depth, maxNodes, maxEdges, fanout, and truncation indicators |
| **Preconditions** | Can connect with server; Caller has ADMIN role and trendId exists in Neo4j |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN user UUID`, `filter` = `neighborhood(trendId, depth=1, maxNodes=50, maxEdges=100, fanout=10)` | 200 OK - neighborhood() returns JsonNode with rootId, nodes[], edges[], truncated, truncationReasons[] | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN user UUID`, `filter` = `search(q='AI', offset=0, limit=20, date)` | 200 OK - catalog() returns supported public node labels and relationship types | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN querying neighborhood`, `filter` = `neighborhood(trendId, depth=1, maxNodes=50, maxEdges=100, fanout=10)` | 200 OK - search() returns matching persisted Trends with items[] and hasMore boolean | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN querying neighborhood`, `filter` = `search(q='AI', offset=0, limit=20, date)` | 200 OK - searchNodes() filters public graph nodes by VALID_LABELS (Trend, Entity, Person, etc.) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Target trendId / nodeId exists in the Neo4j trend knowledge graph | `actor` = `ADMIN user UUID`, `filter` = `searchNodes(q='Brand', label='Entity', offset=0, limit=20)` | 200 OK - expandNode() expands node neighborhood up to depth=2 | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Target trendId / nodeId exists in the Neo4j trend knowledge graph | `actor` = `ADMIN querying neighborhood`, `filter` = `searchNodes(q='Brand', label='Entity', offset=0, limit=20)` | 200 OK - Optional date filter forwarded to AI Service /trends and /nodes queries | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN user UUID`, `filter` = `neighborhood(trendId, depth=1, maxNodes=50, maxEdges=100, fanout=10)` | 200 OK - Blank label in searchNodes normalized to null (searches across all allowed labels) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN user UUID`, `filter` = `search(q='AI', offset=0, limit=20, date)` | 200 OK - Response schema strictly validated (nodes, edges, rootId, truncated, truncationReasons) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Neighborhood query hits maxNodes/maxEdges/fanout boundary with truncated=true | `actor` = `ADMIN expanding node`, `filter` = `expandNode(nodeId, depth=2, maxNodes=200, maxEdges=400, fanout=50)` | 200 OK - Boundary depth=1, maxNodes=1, maxEdges=1, fanout=1 accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Neighborhood query hits maxNodes/maxEdges/fanout boundary with truncated=true | `actor` = `ADMIN expanding node`, `filter` = `expandNode(nodeId, depth=2, maxNodes=200, maxEdges=400, fanout=50)` | 200 OK - Upper boundary depth=2, maxNodes=200, maxEdges=400, fanout=50 accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN user UUID`, `filter` = `searchNodes(q='Brand', label='Entity', offset=0, limit=20)` | 200 OK - Query string at exact MAX_QUERY_LENGTH=100 characters accepted | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Filter parameters (depth, maxNodes, maxEdges, fanout, q, label) are out of range | `actor` = `ADMIN with invalid filter params`, `filter` = `neighborhood(trendId, depth=1, maxNodes=50, maxEdges=100, fanout=10)` | INVALID_REQUEST - 400 depth outside [1..2], maxNodes outside [1..200], or maxEdges outside [1..400] | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Filter parameters (depth, maxNodes, maxEdges, fanout, q, label) are out of range | `actor` = `non-ADMIN user UUID`, `filter` = `neighborhood(trendId, depth=1, maxNodes=50, maxEdges=100, fanout=10)` | INVALID_REQUEST - 400 Invalid node label or query length > 100 chars | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Target trendId is not found in Neo4j or caller is not ADMIN | `actor` = `ADMIN user UUID`, `filter` = `neighborhood(trendId, depth=1, maxNodes=50, maxEdges=100, fanout=10)` | FORBIDDEN - 403 Caller does not have ADMIN system role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `ADMIN with invalid filter params`, `filter` = `depth=5 or maxNodes=500 (out of bounds)` | TREND_GRAPH_NOT_FOUND - 404 Requested trendId or nodeId does not exist in Neo4j | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); AI Service graph explorer endpoints (/catalog, /trends, /neighborhood, /nodes, /expand) are reachable | `actor` = `non-ADMIN user UUID`, `filter` = `non-existent trendId (TREND_GRAPH_NOT_FOUND)` | AI_SERVICE_INVALID_RESPONSE - 502 AI Service returned malformed graph payload | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

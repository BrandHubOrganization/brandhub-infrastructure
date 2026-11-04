# Test Specification — FR 3.10.3: System Health Monitoring

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.3` |
| **Function Name** | System Health Monitoring |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `HealthQueryService.list()` (34 LOC) |
| **Unit Test File** | `brandhub-monitoring-service/src/test/java/com/brandhub/monitoring/service/HealthQueryServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Return real-time health status (UP/DOWN/DEGRADED), CPU %, RAM %, latency, and DB/queue connectivity for all microservices |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 5, `Abnormal (A)`: 4 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role; All services respond | `serviceFilter` = `none` | 200 OK - each service status=UP with cpuPercent, ramPercent, uptime | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role; business-service not responding | `serviceFilter` = `none` | 200 OK - business-service status=DOWN, others UP | Service marked DOWN | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role; All services respond | `serviceFilter` = `business-service` | 200 OK - only business-service entry | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role; All services respond | `status` = `UP` | 200 OK - only UP services | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role; One service DOWN | `status` = `DOWN` | 200 OK - only DOWN services | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role; Collector heartbeat received recently | `serviceFilter` = `none` | 200 OK - latest evidence returned, no probe credentials | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role; Two refreshes 30s apart | `serviceFilter` = `none` | 200 OK - second call returns newer sample time | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Caller has ADMIN system role; CPU at 100% usage | `serviceFilter` = `none` | 200 OK - cpuPercent=100 | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role; RAM at 0% usage | `serviceFilter` = `none` | 200 OK - ramPercent=0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role; Service just started | `serviceFilter` = `none` | 200 OK - uptime=0s | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role; No services registered | `serviceFilter` = `none` | 200 OK - empty list | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller has ADMIN system role; All services DOWN | `serviceFilter` = `none` | 200 OK - every service status=DOWN, no page-level error | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller does not have ADMIN system role | `serviceFilter` = `none` | BusinessException(MONITORING_FORBIDDEN) - Monitoring access denied | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Request has no authenticated principal | `serviceFilter` = `none` | BusinessException(UNAUTHORIZED) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role | `serviceFilter` = `unknown-service` | 200 OK - empty list | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role; Latest sample is stale | `serviceFilter` = `none` | 200 OK - stale service reported as DOWN | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

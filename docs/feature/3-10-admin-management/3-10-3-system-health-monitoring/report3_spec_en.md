**§3.10.3 System Health Monitoring**

**Function Trigger**

Begins when an Administrator (ADMIN) accesses the monitoring page at /admin/system-health.

**Function Description**

- **Actors / Roles**: ADMIN. Technical system administrator monitoring microservices infrastructure status.
- **Purpose**: Monitor operational status (UP, DEGRADED, DOWN), CPU/RAM utilization, and response latency across 7 microservices in the BrandHub platform.
- **Interface**: System Health Monitoring Screen (SCR-ADM-03), featuring a service status card grid, real-time resource consumption charts, and system incident alert log.
- **Data Processing**: The system dispatches health check requests (/actuator/health) to all 7 microservices (BR-65), measures response latency, collects CPU/RAM utilization, determines overall cluster health, and triggers alerts if any service fails.

**Screen Layout**

Figure — System Health Monitoring Screen (SCR-ADM-03):

- Left/Header: Sidebar Admin Navigation; Top Header displaying title "System Health Monitoring", global status badge ("7/7 Services Operational"), and button "Ping All Services".
- Center: 7 microservice cards grid (api-gateway, auth-service, business-service, ai-service, publisher-service, notification-service, payment-service): Each card displays Service Name, Status Badge (UP in green, DEGRADED in yellow, DOWN in red), Response Latency (ms), % CPU, % RAM, Continuous Uptime; 24-hour historical latency chart; Recent Incident log table.
- Buttons: Button "Ping All Services" (green), Button "Refresh", Service Status Filter (All, Error, Warning).
- Footer: Last check timestamp and auto-refresh interval indicator (default every 30 seconds).

**Function Details**
- **Data Specifications**
    - **Input required**: None (system probes periodically every 30 seconds by default).
    - **Input optional**: serviceName (filter by specific service), refreshInterval (refresh cycle: 10s, 30s, 60s).
    - **System data**: servicesList (array of 7 services), status (UP, DEGRADED, DOWN), latencyMs, cpuUsagePercent, memoryUsagePercent, diskFreeBytes, lastPingTimestamp.
    - **Output**: Detailed microservices health status list with HTTP status code 200 OK.

- **Business Rules**
    - **BR-65**: Microservices system health monitoring is an exclusive technical domain restricted to the ADMIN role.
    - **BR-35**: Authenticate ADMIN permissions before accepting requests and exposing sensitive infrastructure telemetry.
    - **BR-16**: Service outage incidents or status transitions to DOWN/DEGRADED are automatically logged into the system audit log.

- **Validation**
    - User does not possess ADMIN role permissions -> Display: **MSG39**
    - Microservice is unresponsive or connection lost -> Display: **MSG38**

**Functionalities**
- **Normal Flow**
    1. Admin navigates to System Health screen (/admin/system-health).
    2. System validates ADMIN role authority under BR-35, BR-65.
    3. System dispatches health check requests (/actuator/health) to 7 microservices.
    4. System receives probe responses, computes latency, CPU, RAM, and determines individual service status.
    5. System renders service statuses on SCR-ADM-03 with visual color badges.
    6. System automatically re-checks and refreshes telemetry every 30 seconds.

- **Abnormal Cases**
    - 2.a1: If user does not possess ADMIN role, system rejects access and displays MSG39.
    - 4.a1: If a service fails to respond after 3,000ms, system marks status as DOWN (red badge) and displays MSG38.

**Post-Conditions**

- Microservices telemetry is continuously refreshed and displayed on the monitoring interface.
- Service interruption incidents are persisted in system_health_logs (BR-16).

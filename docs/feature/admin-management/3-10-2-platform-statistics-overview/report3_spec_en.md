**3.10.2 Platform Statistics Overview**

**Function Trigger**

Begins when an Administrator (ADMIN) accesses the administrative dashboard home at route /admin/dashboard.

**Function Description**

- **Actors / Roles**: ADMIN. System administrator monitoring operational performance, user growth, and platform revenue.
- **Purpose**: Display successful-login activity, user growth, FLAGGED accounts, active strikes and financial indicators with explicit definitions.
- **Interface**: Platform Statistics Overview Dashboard (SCR-ADM-02), featuring 4 KPI metric cards, user acquisition growth chart, monthly revenue breakdown chart, subscription plan distribution chart, and top active agencies table.
- **Data Processing**: Verify ADMIN; aggregate login events, post/activity counts, active strike state and reconciled payments. Cache for up to 15 minutes by filters, timezone and ranking metric; return asOf and period boundaries.

**Screen Layout**

Figure — Platform Statistics Overview Dashboard (SCR-ADM-02, responsive grid layout):

- Left/Header: Admin navigation, period filters and timezone selector UTC / Asia/Ho_Chi_Minh (default).
- Center: KPI cards: total users / successful-login users in trailing 30 days, FLAGGED users, active YELLOW/ORANGE/RED strikes, gross receipts. Growth, receipts and plan-distribution charts; Top 5 Agency table with separate ranking selectors for posts, business activity and revenue. Show the metric and period for each ranking.
- Buttons: Button "Refresh Data" (clears Redis cache and reloads), Button "Custom Date Range", Button "Export PDF Report".
- Footer: Last synchronization time, selected timezone and stale/error indicator.

**Function Details**

- **Data Specifications**
    - **Input required**: None (defaults to trailing 12-month period).
    - **Input optional**: period, startDate, endDate, timezone (UTC or Asia/Ho_Chi_Minh), agencyRankBy (POSTS, ACTIVITY, REVENUE).
    - **System data**: totalUsers, activeUsers30d, flaggedUsersCount, activeStrikeCounts, grossReceipts, refunds, netReceipts, topAgencies, asOf, timezone.
    - **Output**: Aggregated platform statistics JSON payload with HTTP status code 200 OK.

- **Business Rules**
    - **BR-65**: Platform statistics are restricted to ADMIN.
    - **BR-65**: activeUsers30d counts distinct users with a successful login in the trailing 30 days. Failed logins and token refresh alone do not count.
    - **BR-65**: Provide all three Agency ranking views: post count, business activity count and revenue for the selected period; do not invent a weighted composite score. The technical plan must map the existing post, activity-event and payment attribution sources explicitly.
    - **BR-94**: Active strike counters use FR 3.10.5 eligibility and clean-period state, not a createdAt >= now−30d filter. Show converted/pardoned/expired history separately.
    - **BR-60**: MRR is the monthly-normalized value of active paid subscriptions after applicable discounts; annual plans contribute annual price / 12. ARR = MRR × 12. Gross receipts include successful subscription and one-off AI Credit payments in the period. Show refunds separately; net receipts = gross receipts − refunds. AI Credits are excluded from MRR. Refunds change MRR only when subscription value/status changes; never deduct them twice.
    - **BR-65**: Reporting stores timestamps in UTC and supports UTC or Asia/Ho_Chi_Minh (default). Resolve date boundaries and daily/monthly buckets in the selected timezone; include timezone in responses, exports and cache keys.

- **Validation**
    - User does not possess ADMIN role permissions → Display: MSG39
    - Custom date range yields no transaction or operational records → Display: MSG122
    - Data refresh request frequency exceeds rate limiting threshold → Display: MSG48

**Functionalities**

- **Normal Flow**
    1. Admin opens SCR-ADM-02; system verifies ADMIN authority.
    2. Select period, timezone and one of three Agency ranking metrics.
    3. Return fresh cached aggregates or calculate using the same filter and timezone boundaries.
    4. Render KPIs, charts, rankings and asOf; retain filter context for PDF export.

- **Abnormal Cases**
    - 2.a1: If user does not possess ADMIN role, system blocks access and displays MSG39.
    - 5.a1: If selected date range contains no operational data, system displays MSG122.

**Post-Conditions**

- Aggregated statistics data is rendered visually on Admin interface.
- Newly computed metrics payload is cached in Redis with a 15-minute TTL.

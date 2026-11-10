**3.10.11 View Revenue Dashboard**

**Function Trigger**

Begins when an Administrator (ADMIN) accesses financial management at route /admin/revenue.

**Function Description**

- **Actors / Roles**: ADMIN. System administrator tracking platform-wide revenue streams and payment transaction data.
- **Purpose**: Display detailed revenue analytics from recurring subscription service plans (PayOS) and ad-hoc AI Credit token purchases.
- **Interface**: Platform Revenue Dashboard (SCR-ADM-10), featuring revenue KPI cards (MRR, ARR, Cumulative Gross Revenue), revenue trend charts over time, revenue breakdown distribution, and recent payment transaction ledger.
- **Data Processing**: Verify ADMIN; calculate subscription MRR/ARR from active paid entitlements and separately aggregate reconciled payments/refunds using the selected reporting timezone. Apply current discounts and existing subscription plan catalog.

**Screen Layout**

Figure — Revenue Dashboard Screen (SCR-ADM-10, financial analytics grid layout):

- Left/Header: Admin navigation, period filters, timezone UTC / Asia/Ho_Chi_Minh (default), and Export PDF.
- Center: Cards: MRR, ARR, gross receipts, refunds, net receipts and successful transaction count. Separate subscription and AI Credit receipts in charts; catalog plan filter; payment/refund history with status. Clearly distinguish snapshot MRR from period receipts.
- Buttons: Button "Refresh Data", Time Filter (This Month, This Quarter, This Year, Custom Range), Button "Export Financial PDF Report".
- Footer: Last financial reconciliation timestamp and payment security compliance advisory.

**Function Details**

- **Data Specifications**
    - **Input required**: None (defaults to current month data).
    - **Input optional**: period, startDate, endDate, timezone (UTC/Asia/Ho_Chi_Minh), planId (catalog).
    - **System data**: mrrAmount, arrAmount, grossReceipts, refunds, netReceipts, subscriptionReceipts, aiCreditReceipts, successfulTransactionCount, transactions, asOf, timezone.
    - **Output**: Platform revenue analytics JSON payload with HTTP status code 200 OK.

- **Business Rules**
    - **BR-65**: Only ADMIN accesses platform financial data.
    - **BR-60**: MRR is the monthly-normalized value of active paid subscriptions after applicable discounts; annual plans contribute annual price / 12. ARR = MRR × 12. Gross receipts include successful subscription and one-off AI Credit payments in the period. Show refunds separately; net receipts = gross receipts − refunds. AI Credits are excluded from MRR. Refunds change MRR only when subscription value/status changes; never deduct them twice.
    - **BR-60**: Use actual successful payment and refund events, including partial refunds. A refunded payment remains in gross receipts; its refund appears separately at refund time. Failed/pending payments contribute nothing.
    - **BR-60**: Pending Admin plan changes have no immediate MRR, quota or receipts effect. Next-cycle changes require payment; action alone is not revenue.
    - **BR-80**: Use precise monetary arithmetic and existing currency rules; show asOf for MRR and the reporting interval for receipts.
    - **BR-65**: Reporting stores timestamps in UTC and supports UTC or Asia/Ho_Chi_Minh (default). Resolve date boundaries and daily/monthly buckets in the selected timezone; include timezone in responses, exports and cache keys.
    - **BR-82**: System roles are ADMIN and USER only. Agency/Workspace membership roles are managed separately. Subscription plan identifiers come from the existing catalog (currently BASIC, PRO, ENTERPRISE), not a second hardcoded catalog.
    - **BR-16**: Audit financial queries and exports.

- **Validation**
    - User does not possess ADMIN role permissions → Display: MSG39
    - Selected date filtering interval contains no transaction records → Display: MSG122

**Functionalities**

- **Normal Flow**
    1. Admin opens SCR-ADM-10 and selects period, timezone and optional catalog plan.
    2. Verify ADMIN and resolve reporting boundaries.
    3. Calculate current normalized subscription MRR and ARR independently of receipt dates.
    4. Aggregate successful payments and refunds in the selected period; split subscription/AI Credit and compute net receipts.
    5. Render values with asOf, period and timezone; preserve these parameters for PDF export.

- **Abnormal Cases**
    - 2.a1: If user does not possess ADMIN role, system blocks access and displays MSG39.
    - 3.a1: If selected date range contains no transactions, system displays MSG122.

**Post-Conditions**

- Revenue metrics and transaction histories are rendered accurately on the dashboard.
- Reconciled financial data is staged and ready for PDF report export upon administrative request.

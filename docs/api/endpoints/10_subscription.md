# DA-E07-01 — Subscription Endpoints

**Group:** Subscription | **Base path:** `/api/v1/subscriptions`  
**Auth policy:** Mixed — see per-endpoint

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Auth | Roles |
|---|--------|------|------|-------|
| 59 | GET | `/api/v1/subscriptions/plans` | PUBLIC | — |
| 60 | GET | `/api/v1/subscriptions/current` | JWT | AGENCY_OWNER |
| 61 | POST | `/api/v1/subscriptions/subscribe` | JWT | AGENCY_OWNER |
| 62 | POST | `/api/v1/subscriptions/webhook` | PUBLIC | — (Stripe HMAC auth) |
| 63 | POST | `/api/v1/subscriptions/cancel` | JWT | AGENCY_OWNER |
| 64 | GET | `/api/v1/subscriptions/invoices` | JWT | AGENCY_OWNER |

> **Payment provider:** Stripe. Subscribe flow: frontend gets `clientSecret` from `/subscribe` → Stripe.js confirms payment on frontend → Stripe fires webhook to `/webhook` → service activates subscription.
>
> **Stripe webhook security:** Payload is raw body (not parsed JSON) for signature validation. `Stripe-Signature` header MUST be validated with `STRIPE_WEBHOOK_SECRET` before processing. Invalid signature → 400.

---

## GET /api/v1/subscriptions/plans

**Auth:** `[PUBLIC]`  
**Goal:** List all active subscription plans (used on pricing page, no login required).

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "FREE | BASIC | PRO | ENTERPRISE",
      "displayName": "string",
      "priceMonthly": "number (VND, 0 for FREE)",
      "priceYearly": "number (VND, 0 for FREE)",
      "yearlyDiscountPercent": "number",
      "maxMembers": "number (-1 = unlimited)",
      "maxClients": "number (-1 = unlimited)",
      "maxPostsMonth": "number (-1 = unlimited)",
      "aiCreditsMonth": "number",
      "features": ["string"],
      "isActive": "boolean"
    }
  ]
}
```

**Implementation notes:**
- Query `subscription_plans` PG table where `is_active = true`
- Order by `price_monthly ASC`
- Cache in Redis (TTL 1h) — plans change rarely

---

## GET /api/v1/subscriptions/current

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Get current subscription status for the workspace.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "planId": "uuid",
    "planName": "FREE | BASIC | PRO | ENTERPRISE",
    "displayName": "string",
    "billingCycle": "monthly | yearly",
    "status": "ACTIVE | TRIALING | EXPIRED | CANCELLED",
    "currentPeriodStart": "ISO8601",
    "currentPeriodEnd": "ISO8601",
    "trialEndsAt": "ISO8601 | null",
    "cancelledAt": "ISO8601 | null",
    "stripeSubscriptionId": "string | null",
    "usage": {
      "membersCount": "number",
      "clientsCount": "number",
      "postsThisMonth": "number",
      "aiCreditsThisMonth": "number"
    },
    "limits": {
      "maxMembers": "number",
      "maxClients": "number",
      "maxPostsMonth": "number",
      "aiCreditsMonth": "number"
    }
  }
}
```

**Errors:**
- `404 SUBSCRIPTION_NOT_FOUND` — workspace has no subscription row (edge case: new workspace before any plan)

**Implementation notes:**
- Join `workspace_subscriptions` with `subscription_plans`
- `usage.postsThisMonth`: count MongoDB `posts` for current calendar month
- `usage.aiCreditsThisMonth`: sum from MongoDB `ai_usage_logs` for current month
- Do NOT return full Stripe customer/payment details — only status info

---

## POST /api/v1/subscriptions/subscribe

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Subscribe to or upgrade a plan. Returns Stripe PaymentIntent `clientSecret` for frontend confirmation.

**Request body:**
```json
{
  "planId": "uuid (required — must be an active plan)",
  "billingCycle": "monthly | yearly (required)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "paymentIntentId": "string (Stripe PaymentIntent ID — for tracking)",
    "clientSecret": "string (Stripe client secret — pass to Stripe.js confirmPayment on frontend)",
    "amount": "number (VND)",
    "currency": "VND"
  }
}
```

**Errors:**
- `400 PLAN_NOT_FOUND` — `planId` doesn't exist or `is_active = false`
- `400 ALREADY_ON_PLAN` — workspace already on this plan + billing cycle (upgrade to same plan)
- `400 DOWNGRADE_NOT_ALLOWED` — downgrading to lower plan blocked if usage exceeds new plan limits (return details of what exceeds)

**Implementation notes:**
- Create or retrieve Stripe Customer for workspace
- Create Stripe PaymentIntent for the plan amount
- Store `stripe_payment_intent_id` in `invoices` table (status: ISSUED)
- Subscription NOT activated here — activation happens in webhook handler after payment confirmed
- For FREE plan: no PaymentIntent needed → activate immediately, return `{ "clientSecret": null }`

---

## POST /api/v1/subscriptions/webhook

**Auth:** `[PUBLIC]` — Stripe signature validation replaces JWT  
**Goal:** Process Stripe payment events. Activate/update subscription on successful payment.

**Request:** Raw body (do not parse before signature check)  
**Required header:** `Stripe-Signature`

**Response 200:**
```json
{ "received": true }
```

**Response 400:** Invalid signature (never return 200 for invalid signature — Stripe will retry)

**Handled events:**

| Stripe event | Action |
|---|---|
| `payment_intent.succeeded` | Mark invoice PAID, activate `workspace_subscriptions` |
| `payment_intent.payment_failed` | Mark invoice FAILED, notify workspace owner |
| `customer.subscription.deleted` | Set subscription status = EXPIRED |
| `invoice.payment_succeeded` | (recurring billing) Extend `current_period_end` |

**Implementation notes:**
- Validate `Stripe-Signature` using `stripe.webhooks.constructEvent(rawBody, sigHeader, STRIPE_WEBHOOK_SECRET)`
- **Idempotent:** Check if `paymentIntentId` already processed before applying state changes
- On `payment_intent.succeeded`:
  1. Find matching `invoices` row by `stripe_payment_intent_id`
  2. Set `invoices.status = PAID`, `paid_at = now()`
  3. Upsert `workspace_subscriptions`: `status = ACTIVE`, set `current_period_start/end`
- Always return 200 to Stripe — only return non-200 for signature validation failure (Stripe retries on non-2xx)

---

## POST /api/v1/subscriptions/cancel

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Cancel current subscription at end of billing period. Workspace retains access until `current_period_end`.

**Request body:**
```json
{
  "reason": "string (optional — cancellation reason for internal tracking)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "status": "CANCELLED",
    "cancelledAt": "ISO8601",
    "accessUntil": "ISO8601 (= current_period_end — access retained until then)"
  }
}
```

**Errors:**
- `400 NO_ACTIVE_SUBSCRIPTION` — workspace has no active or trialing subscription
- `400 ALREADY_CANCELLED` — subscription already marked for cancellation

**Implementation notes:**
- Call Stripe API to cancel subscription at period end (`cancel_at_period_end = true`)
- Update `workspace_subscriptions.cancelled_at = now()`, `status = CANCELLED`
- Do NOT downgrade workspace immediately — access continues until `current_period_end`
- After `current_period_end`: background job downgrades to FREE plan

---

## GET /api/v1/subscriptions/invoices

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Paginated billing history for the workspace.

**Query params:**
- `page` (default 1)
- `size` (default 20, max 50)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "invoiceNumber": "string",
        "status": "PAID | ISSUED | OVERDUE | FAILED",
        "amount": "number",
        "currency": "VND",
        "planName": "string",
        "billingCycle": "monthly | yearly",
        "periodStart": "ISO8601",
        "periodEnd": "ISO8601",
        "issuedAt": "ISO8601",
        "paidAt": "ISO8601 | null",
        "downloadUrl": "string | null (PDF invoice URL if available)"
      }
    ],
    "total": "number",
    "page": "number",
    "size": "number"
  }
}
```

**Implementation notes:**
- Query `invoices` table scoped to workspace's `workspace_subscriptions.id`
- Order by `issued_at DESC`
- `downloadUrl`: Stripe invoice PDF URL (retrieved from Stripe API, cached or stored)

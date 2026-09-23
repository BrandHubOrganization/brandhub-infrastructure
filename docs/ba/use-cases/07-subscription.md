# UC 07 — Subscription (UC-90 → UC-96)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [08-subscription-billing.md](../08-subscription-billing.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`
> **Lưu ý:** Plan gắn với User/Owner (tầng Agency), không mua riêng theo từng Workspace.

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-90 | Upgrade Plan | USER | 3.9.1 |
| UC-91 | Downgrade/Cancel Plan | OWNER | 3.9.2 |
| UC-92 | Make Payment via PayOS | USER | 3.9.3 |
| UC-93 | View Invoice History | OWNER | 3.9.4 |
| UC-94 | View AI Credit Tracking | CREATOR/OWNER | 3.9.5 |
| UC-95 | Buy AI Credit | CREATOR/OWNER | 3.9.6 |
| UC-96 | Set AI Credit Limit | OWNER | 3.9.7 |

---

## UC-90 — Upgrade Plan

- **Actor(s):** USER
- **Description:** Upgrade from the Basic plan to Pro/Enterprise for more Workspaces, AI credits, and advanced features.
- **Precondition:** User currently on a lower-tier plan (default new user = Basic).
- **Main Flow:**
  1. USER selects a higher tier (Pro/Enterprise).
  2. System proceeds to payment (UC-92).
  3. On successful payment, plan tier upgraded — limits (max Workspaces, AI credit) increased.

## UC-91 — Downgrade/Cancel Plan

- **Actor(s):** OWNER
- **Description:** Cancel the current plan when no longer needed.
- **Precondition:** OWNER has an active paid plan.
- **Main Flow:**
  1. OWNER requests downgrade/cancel.
  2. System schedules the change (e.g., effective at next billing cycle) or applies immediately per policy.

## UC-92 — Make Payment via PayOS

- **Actor(s):** USER
- **Description:** Create a payment transaction for plan upgrades or credit purchases, ensuring ACID compliance.
- **Precondition:** User initiated an upgrade (UC-90) or credit purchase (UC-95).
- **Main Flow:**
  1. USER confirms payment details.
  2. System creates a Transaction and calls PayOS.
  3. On confirmed payment, System commits the Transaction atomically (ACID) and applies the plan/credit change.
- **Alternate Flow:**
  - A1. Payment fails/cancelled → Transaction rolled back, no plan/credit change applied.

## UC-93 — View Invoice History

- **Actor(s):** OWNER
- **Description:** View the account's transaction history.
- **Precondition:** At least one completed Transaction.
- **Main Flow:**
  1. OWNER opens Invoice History.
  2. System lists past transactions (plan upgrades, credit purchases).

## UC-94 — View AI Credit Tracking

- **Actor(s):** CREATOR/OWNER
- **Description:** Monitor the amount of AI credit used within the current month.
- **Precondition:** User has Workspace access.
- **Main Flow:**
  1. CREATOR views their own usage; OWNER views Agency-wide usage across all Creators.
  2. System displays credit consumed this month (image/content/video generation).

## UC-95 — Buy AI Credit

- **Actor(s):** CREATOR/OWNER
- **Description:** Purchase additional AI credit.
- **Precondition:** Existing plan credit allowance exhausted.
- **Main Flow:**
  1. OWNER initiates a credit purchase (goes through UC-92 payment flow).
  2. System adds purchased credit to the Agency's balance.
- **Business Rule:** Only OWNER can buy credit — Creator cannot purchase credit for themself directly.

## UC-96 — Set AI Credit Limit

- **Actor(s):** OWNER
- **Description:** Set a spending limit on AI credit usage for Creators.
- **Precondition:** OWNER of the Agency.
- **Main Flow:**
  1. OWNER selects a Creator, sets a per-Creator credit usage cap.
  2. System enforces the cap — Creator's AI actions blocked once their individual limit is reached, even if the Agency's shared pool still has balance.

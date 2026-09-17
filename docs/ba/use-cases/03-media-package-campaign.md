# UC 03 — Media Package & Campaign (UC-32 → UC-41)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [04-media-package-campaign.md](../04-media-package-campaign.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`
> **Thứ tự chuẩn:** Workspace → Package (chọn/đàm phán/approve) → Campaign (tạo/approve → auto-gen backlog) → Content Request (kênh bổ sung, độc lập).

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-32 | Create Media Package Template | OWNER/MANAGER | 3.5.1 |
| UC-33 | View Media Package Template | CLIENT | 3.5.2 |
| UC-34 | Negotiate & Request Media Package | CLIENT/OWNER/MANAGER | 3.5.3 |
| UC-35 | Approve Media Package | OWNER/MANAGER/CLIENT | 3.5.4 |
| UC-36 | Create Media Campaign | OWNER/MANAGER/CLIENT | 3.5.5 |
| UC-37 | Approve & Launch Media Campaign | OWNER/MANAGER/CLIENT | 3.5.6 |
| UC-38 | Create Content Request | CLIENT | 3.5.7 |
| UC-39 | Process Content Request Status | MANAGER | 3.5.8 |
| UC-40 | Update Content Request | CLIENT | 3.5.9 |
| UC-41 | Cancel Content Request | CLIENT | 3.5.10 |

---

## UC-32 — Create Media Package Template

- **Actor(s):** OWNER/MANAGER
- **Description:** Choose from pre-built media package templates created by Admin, or customize a new package for the Agency.
- **Precondition:** Workspace already created (Package selection happens right after Workspace creation, before inviting Client).
- **Main Flow:**
  1. OWNER/MANAGER opens Media Package selection screen.
  2. Selects an Admin-provided template, or creates a custom package (name, duration, scope).
  3. System stores selection as a reference ID (`workspace_media_packages` → template or custom package).
- **Alternate Flow:**
  - A1. Package not set at Workspace creation time → system notifies Manager to complete this step.

## UC-33 — View Media Package Template

- **Actor(s):** CLIENT
- **Description:** Client views the sample media strategy templates (scope, staffing, duration) provided by the Agency.
- **Precondition:** Client has been invited into the Workspace.
- **Main Flow:**
  1. CLIENT opens the proposed Media Package.
  2. System displays package details: by duration ("in X weeks, deliver Y"), by budget ("for amount Z, deliver Y"), or full-delegation (Agency decides method, must hit agreed KPI).

## UC-34 — Negotiate & Request Media Package

- **Actor(s):** CLIENT/OWNER/MANAGER
- **Description:** Client submits change requests (price, timeline, format) on a sample package; Owner/Manager respond until both sides finalize the package.
- **Precondition:** A proposed Media Package exists in the Workspace.
- **Main Flow:**
  1. CLIENT reviews the package, submits a change request (price/timeline/format/event).
  2. OWNER/MANAGER responds: accept, reject, or counter-propose.
  3. Loop steps 1–2 until both sides converge on a final package.
- **Note:** CLIENT is the actual actor performing negotiation actions; OWNER/MANAGER only respond — both appear in the FR role list because both need view/respond access.

## UC-35 — Approve Media Package

- **Actor(s):** OWNER/MANAGER/CLIENT
- **Description:** Both parties confirm agreement on the finalized media package.
- **Precondition:** Package negotiation (UC-34) has converged.
- **Main Flow:**
  1. Agency side (Owner/Manager) approves.
  2. Client side approves.
  3. System marks Media Package as `APPROVED` only when **both** sides have approved.
- **Business Rule:** Requires two-sided consensus — Agency internal approval alone is not sufficient (differs from legacy single-sided approval).

## UC-36 — Create Media Campaign

- **Actor(s):** OWNER/MANAGER/CLIENT
- **Description:** Build a detailed execution strategy tailored to the client's brand, based on the selected media package.
- **Precondition:** Media Package is `APPROVED`.
- **Main Flow:**
  1. Agency drafts a Media Campaign — a detailed execution plan matching the Client's brand (not a contract; the Package is the "framework contract", Campaign is the execution plan).
  2. Campaign details submitted for review.
- **Business Rule:** Media Campaign ≠ contract — it is the execution strategy layered on top of the already-approved Package.

## UC-37 — Approve & Launch Media Campaign

- **Actor(s):** OWNER/MANAGER/CLIENT
- **Description:** Once both parties agree, push all campaign work items into the Workspace backlog.
- **Precondition:** Media Campaign drafted (UC-36).
- **Main Flow:**
  1. Both Agency and Client approve the Campaign.
  2. System auto-generates Task backlog entries from Campaign work items (task name + rough timing only — not yet detailed; see [05-content-task-workflow.md](../05-content-task-workflow.md) UC "Define Task Detail").
- **Postcondition:** Campaign becomes **immutable** — no further edits. Mid-campaign additions must go through Content Request (UC-38) or Manager manually adding a Task, not by amending the original Campaign.

## UC-38 — Create Content Request

- **Actor(s):** CLIENT
- **Description:** Client creates a new content request, pending Manager review before work is assigned.
- **Precondition:** Client is a member of the Workspace.
- **Main Flow:**
  1. CLIENT submits a new content request (independent of the approved Campaign — a supplementary channel).
  2. Request enters `pending` status.
- **Note:** Only CLIENT actually creates requests; OWNER/MANAGER appear in the FR role list solely for view/approve access.

## UC-39 — Process Content Request Status

- **Actor(s):** MANAGER
- **Description:** Manager updates request status (pending → in progress → accepted/denied) and moves it into the backlog upon acceptance.
- **Precondition:** A Content Request exists in `pending` status.
- **Main Flow:**
  1. MANAGER reviews the request, transitions status: `pending → in progress → accepted`.
  2. On `accepted`, system auto-generates a new Task in the Workspace backlog, entering the standard Task flow (Define Detail → Assign → Approval Sequence).
- **Alternate Flow:**
  - A1. MANAGER denies the request → status becomes `denied`, a **terminal** state (differs from Task rejection, which loops back). Client cannot edit a denied request — must submit a brand-new Content Request to re-propose.

## UC-40 — Update Content Request

- **Actor(s):** CLIENT
- **Description:** Client edits their own content request while it is still in pending status.
- **Precondition:** Request status = `pending`.
- **Main Flow:**
  1. CLIENT edits request content/details.
  2. System persists changes only while status remains `pending`.
- **Alternate Flow:**
  - A1. Status has moved past `pending` (in progress/accepted/denied) → edit blocked.

## UC-41 — Cancel Content Request

- **Actor(s):** CLIENT
- **Description:** Client cancels their own content request while it is still in pending status.
- **Precondition:** Request status = `pending`.
- **Main Flow:**
  1. CLIENT selects Cancel on their own request, confirms.
  2. System removes/cancels the request.
- **Alternate Flow:**
  - A1. Status has moved past `pending` → cancel blocked, Client no longer has authority to cancel.

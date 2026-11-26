# Creator Task Creation Policy — Spec

> Module: 04-task-chat-vault · Related FR: 3.6.x Create Task (standalone) · Roles: Owner, Manager, Creator

## Problem
Creators could create any Task themselves and it started immediately (self-assigned, `IN_PROGRESS`).
In an agency workspace the Manager plans and assigns the work, so the Owner needs to be able to limit this.

## Rule
A workspace setting `creatorTaskCreation` controls Tasks **of every type** that a **Creator** creates:

| Value | Behaviour |
|---|---|
| `DISABLED` | Creator cannot create Tasks (MSG: "This Workspace does not allow Creators to create Tasks"). The create buttons are hidden. |
| `FREE` (default, same as before) | Creator creates the Task and it starts right away. |
| `APPROVAL` | Creator sends a proposal. The Task stays `TODO` with `creationApproval.state = PENDING`, workflow locked (`TASK_CREATION_PENDING`), no draft post yet. Owner/Manager approve or reject. |

- Owner and Manager are never gated.
- Only Owner/Manager change the setting (Workspace detail page).
- Approve: `creationApproval = APPROVED`. Standalone Tasks (`sourceType = MANUAL`) move to `IN_PROGRESS` and get their draft post (POST / SHORT_VIDEO). The Creator gets a notification.
- Reject: `creationApproval = REJECTED`, Task `CANCELLED` (reason `NO_LONGER_SUITABLE`, optional note). The Creator gets a notification with the note.
- When a proposal is sent, every active Owner/Manager gets an inbox notification.

## Out of scope
- Mobile app UI (backend already enforces the policy for mobile requests).
- Campaign out-of-scope Tasks: already Owner/Manager only.

# Plan - FR 3.5.5

## Scope

Implement E50-06 creation of a draft campaign from an approved workspace package.

## Plan

1. Add `work_items JSONB NOT NULL DEFAULT '[]'` and `content_version INT NOT NULL DEFAULT 1` migration plus equivalent V2 init schema update.
2. Validate each item has stable ID, task type, name, and due date.
3. Validate approved package, workspace access, and campaign payload.
4. Create `DRAFT` campaign and return it; test rejected preconditions and multiple campaigns.


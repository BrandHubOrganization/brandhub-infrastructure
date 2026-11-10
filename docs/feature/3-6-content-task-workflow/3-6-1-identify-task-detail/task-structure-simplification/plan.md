# Plan

1. Update TaskDocument/workflow detail and assignment DTOs, field allowlist, date validation, service and readiness checker.
2. Remove QC/planned-date controls and request fields from Task-only UI; keep dueDate/date bounds and revision queue.
3. Add 2026-10-17-task-structure-simplification.js, synchronize fresh init and read-only migration checker. Existing QC states/history remain read-compatible.
4. Tests cover removed fields, rejected QC requests, assignment/start/CAS, deadlines and schema readiness without plannedPublishAt. Run focused Backend tests, scoped lint and whole-Web type-check; record unrelated baseline failures.
5. Hand off DRY_RUN/APPLY instructions. No data cleanup or approval module changes.

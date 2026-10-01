# Plan - FR 3.5.7

## Scope

Implement the first E50-10 content-request endpoint and persistence.

## Plan

1. Add an idempotent V2 Mongo migration for content requests; retain/migrate legacy data as agreed with the team.
2. Add Client membership and payload validation for title, description, type, and due date.
3. Persist a `PENDING` request with audit fields and return its read DTO.
4. Test Client-only creation and workspace isolation.

## Dependency

Task creation is excluded here and occurs only on acceptance in FR 3.5.8.

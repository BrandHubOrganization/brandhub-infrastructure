# Verification

1. Business header: realistic synthetic JSON converts to the local DTO, preserving
   identifiers, content, token field, media URL, schedule, target and duration.
2. Publisher header and headerless payload: both remain readable.
3. Retry: converter serialization followed by deserialization preserves the job.
4. Unsupported class outside trusted packages: conversion is rejected.
5. Run existing Publisher regression tests; no real social API/queue traffic.

Do not equate passing converter tests with successful Facebook publication. The
running process requires restart, and existing DLQ messages remain untouched.

## Result (2026-10-22)

- `mvn.cmd -Dtest=PublishJobConsumerTest test`: 9 tests passed, including the five
  new converter cases in the existing tracked test file.
- `mvn.cmd test`: 86 tests passed, zero failures/errors/skips.
- `git diff --check`: passed. No service restart, real publication, DB change or
  DLQ replay performed. Runtime end-to-end publishing remains to be verified.

# Plan
1. Regression test missing token fails before creating job.
2. Add import-specific errors and authenticated config endpoint; remove agency connection fallback. Add import-specific Google HTTP error mapping without altering old API behavior.
3. Browser GIS loader requests read-only token in click event; pass token to existing import endpoint, map errors and refresh materials after completed job.
4. Add backend tests for token import and provider errors; frontend verification outside src.
5. Run Maven tests, frontend lint/build and actual Chrome popup initiation. Restart local business service if needed, preserving configured environment.

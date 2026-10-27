# Verification
Target workspace gains 24 active synthetic hashtags, eight per ordinary purpose. Page size 20 yields two pages. Creator-owned and Manager-owned samples permit ownership tests. Rerun inserts zero, existing/soft-deleted rows untouched. Other workspaces unchanged. Required campaign hashtag tests excluded if no campaign exists.

Applied 2026-10-27 to local brandhub PostgreSQL: first run INSERT 0 24; rerun expected INSERT 0 0. No campaign/Client exists, so required EVENT_SPECIFIC samples intentionally excluded. No application code or schema changes.

JSON has 142 distinct valid normalized hashtags and zero invalid entries. Verify every source key exists, TRENDING count includes new rows, rerun inserts zero and other workspaces unchanged.

Trend import applied: INSERT 0 142; rerun INSERT 0 0. Active counts BRAND 8 / CAMPAIGN 8 / TRENDING 150, total 166. Source normalized keys matched 142/142 including Unicode; other workspace rows remain zero.

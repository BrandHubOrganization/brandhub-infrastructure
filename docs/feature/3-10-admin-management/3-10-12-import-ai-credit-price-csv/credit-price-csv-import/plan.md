# Plan

1. Add Apache Commons CSV RFC4180 parsing, strict UTF-8/BOM/size/metadata validation
   and structured record/field issues. Keep parsing independent from DB operations.
2. Add import request/response records and Admin-only thin controller/service.
   Reuse CreditConfigurationStore price history/advisory transaction locks;
   preserve enabled state, compare every expected revision, skip no-ops, audit
   benchmark provenance in the same transaction. No schema modifications.
3. Add credit module types/service/hook and inline review component; wire a single
   Import CSV action into the existing price page. Keep all other page behavior.
   File choice starts preview, generation/abort guards ignore stale preview responses,
   apply double-click guard, explicit refresh after conflicts, targeted cache invalidation.
4. Add `src/i18n/locales/{vi,en}/credit.json` keys together. Follow existing design,
   keyboard/error focus, responsive/light/dark review and disabled-state feedback.
5. Verify parser against benchmark's actual CSV and malformed/edge cases; isolated
   PostgreSQL transaction/concurrency/rollback and Admin guard/API tests; Web lint/
   type/build and mocked browser flow. New executable QA stays in keep-local-only.

Parser reference: https://commons.apache.org/proper/commons-csv/apidocs/.
Use existing backend dependency conventions; verify resolved runtime dependencies.

## Mixed-dimension correction
Accept only paired-empty dimensions in CreditPriceCsv; use nullable Integer metadata in Proposal. Update Web proposal types to number|null and its configuration preview with parallel vi/en mixedDimensions text. Verify actual producer output and malformed/partial pairs in isolated local QA; no database writes.

## Feature-only implementation
Keep operation-keyed import and credit reservation. Export empty dimension metadata, preserve validation of actual benchmark samples and legacy CSV. Add regression proving identical measured time/output gives identical credits across dimensions. Update benchmark help and CSV contract; Web uses allDimensions and featurePricing keys in both locale credit.json files. No DB changes.

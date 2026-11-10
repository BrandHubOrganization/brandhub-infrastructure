# Plan

1. Add AI moderation models and service using DEPLOY_ACCESS_KEY, bounded requests with total budget and no automatic retry; normalize documented V3 responses and aggregate segment verdicts conservatively.
2. Add authenticated internal moderation endpoint and attach verdict to generic generated captions. Add optional compliance to structured caption models and check generate/refine/adapt outputs at route boundary.
3. Map returned compliance in business caption adapter, replacing the NOT_CHECKED stub with a parser. Add workspace manual check using existing role and access checks. No schema/credit changes.
4. Add typed moderation service, shared result/check component and hook. Wire editor generated results and Content Writing draft. An edited generated caption needs a new check before Apply.
5. Update brandhub-web/src/i18n/locales/{vi,en}/editor.json. Use existing border/card/destructive tokens; verify light/dark, responsive and keyboard.
6. Unit-test provider parsing, segmentation, timeouts/auth failures and HTTP endpoint authentication using mocks. Run Java adapter tests and web typecheck/build.

Sources: https://docs.deploy.com/quickstart and https://docs.thehive.ai/docs/text-moderation-api. Playground contract source: https://docs.thehive.ai/docs/text-moderation-playground. Verify exact key compatibility using the approved V3 endpoint.

7. Add a small editor moderation coordinator with a 3-second timer, cancellation, exact snapshot caching and in-flight deduplication; a React hook subscribes to it.
8. EditorWorkspace wires caption/hashtags into that hook, displays inline status and gates onPublishNow before invoking the form handler; guards duplicate clicks throughout check+publish. Do not change API keys or existing backend publishing flow.
9. Add fake-timer/request-race unit tests and Playwright request-order tests, update vi/en editor locales.

10. Classify moderation failures at the provider boundary; preserve aggregation and dedicated-key behavior. Add parallel vi/en issue labels through existing components. Use mocked failure tests and log-redaction assertions; no live credential transmission.

11. Normalize known entity/PII filter types, validate filter containers, retain blocking IWF and unknown custom matches. Add unsupported_<category> issue codes and fixed category-only logs. Update vi/en status/recovery text in existing components without theme/layout changes. Verify provider and editor coordinator regressions offline. Source: https://docs.thehive.ai/docs/classification-text (language coverage, -1 semantics, filter types).

## Generic partial response diagnosis
At normalization boundaries log only fixed reason codes and field types/counts, not provider data or text. Log unrecognized-class count and classification coverage.

## Class entry contract correction
Parse whole field pairs, prefer documented class/score when present; accept both pairs only if name and typed severity agree. Regression through moderate_text HTTP response boundary. Source https://docs.thehive.ai/docs/text-moderation-api .

## Live schema diagnosis
Log the first class entry shape once per provider output with field types for class, class_name, name, score, value, severity, category. Correct parsing only after observing live schema.

## Observed V3 class/value schema
Use explicit class/value, class/score, class_name/value pairs. Validate redundant aliases before normalization. Replace default fixture with observed live class/value shape. Remove temporary schema instrumentation.

## Partial coverage policy (ReLoop reference)
Separate explicit per-category -1 from incomplete/error flags. Supported benign classifications plus -1 => WARNING. Keep all-unsupported/error aggregation conservative. Add coveragePartial vi/en copy in both moderation components. Keep existing semantic theme/layout, debounce 3s and gate. Validate provider and editor gate regression.

## User requested unsupported-as-safe policy
Remove unsupported issues; count valid -1 classifications as evaluated for user policy. Add nullable score across Python, Java and TypeScript; render severity beside actual issues. Log detection JSON with bounded matched excerpt and nullable score.

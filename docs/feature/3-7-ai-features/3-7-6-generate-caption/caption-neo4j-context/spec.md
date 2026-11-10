# Neo4j context for trend captions

## Objective and user story

When a creator generates three captions with a selected pipeline trend, include source-backed Neo4j observations so the model understands the people, places, organizations, products and events being discussed.

## Acceptance criteria

- Resolve the existing trend card first; unknown/expired IDs remain rejected.
- For a selected pipeline event (`trend:...`), read Neo4j by the exact ID. Do not search by approximate name or read unrelated graph neighborhoods.
- Use only `CrawledPost - BELONGS_TO -> Trend` and `CrawledPost - MENTIONS -> Entity` evidence, with source URLs. Do not treat inferred relationships such as PROMOTED as verified endorsements.
- Retrieve at most three source posts and twelve mentions. Filter records scoped to another client; format at most 3,000 characters for the prompt.
- Add observations to the caption prompt alongside the existing Redis trend card and brand context. Graph names/URLs are contextual evidence, not verified prices, offers, or product claims.
- Use the existing Neo4j driver, read access, a query timeout, and a three-second application deadline. On outage, missing data or test mock storage, omit graph context and keep the existing caption flow.
- No new LLM call, graph write, dependency, UI control or request/response schema change. The quick generator has no selected trend ID and remains outside this change.

## UI, API and error behavior

Existing VI/EN forms, light/dark styling, authorization, credits, moderation and response payloads remain. No new locale keys or theme styles. Invalid trends return the current 404; optional graph failures are logged by exception type without exposing credentials or source content.

## Edge cases and definition of done

Cover absent/mismatched/private records, malformed URLs, duplicated mentions, long text, graph timeout, plain captions, and invalid trend IDs. Mocked tests must prove graph observations reach one generation call and do not disable factual checks. A configured live graph read may verify the Cypher separately without calling a paid LLM.

## Out of scope

Re-crawling, schema migration, storing new article text, loading every trend graph during ranking, inferred causal claims, or unifying the two frontend generators.

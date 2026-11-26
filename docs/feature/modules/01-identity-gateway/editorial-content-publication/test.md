# Acceptance checks

1. Seed twice and compare all content with the initial source. Preserve legacy IDs, existing URL paths and cross references.
2. Verify Admin write permissions, draft isolation, stale revision conflicts and restoring a previous revision through an explicit subsequent publish.
3. Verify no duplicate canonical or sitemap routes. Build from an edited snapshot and compare the title and body rendered by the browser, the pre-rendered HTML and metadata.
4. Verify Guest playback, signed-in resume, previous/next and syllabus on desktop and mobile, notes reload, and working material links.
5. Make a failed snapshot request and verify the web release halts before publishing any assets.

# Admin trend data view

Admins can choose Redis snapshots or Neo4j trends and filter by Facebook, Threads, or TikTok. The date controls support today, a selected date, and seven calendar days ending on the selected date. Redis also supports its existing live view. Platform filtering happens before the response limit; the score is the overall trend score. Neo4j uses stored platform metadata or linked post evidence when metadata is absent. Graph rows may differ from published snapshots.

The existing admin list API accepts optional source and platform. Redis stays the default. Empty results and source failures remain distinct. New text uses matching admin.trends keys in en/admin.json and vi/admin.json (dataSource, platform, allPlatforms, today, redisHint, neo4jHint and platformNames). Existing semantic colors and accessible controls support light and dark themes.

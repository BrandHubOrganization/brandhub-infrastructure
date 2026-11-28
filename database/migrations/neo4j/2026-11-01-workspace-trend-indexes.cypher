// Optional additive indexes for Workspace trend history. No node/data changes.
// Same definitions are maintained in Neo4jTrendService.ensure_schema().
// Run only against the intended Neo4j database after checking existing indexes.
CREATE INDEX trend_date_id_idx IF NOT EXISTS FOR (t:Trend) ON (t.date, t.id);
CREATE INDEX trend_date_score_id_idx IF NOT EXISTS FOR (t:Trend) ON (t.date, t.score, t.id);
CREATE INDEX trend_normalized_date_idx IF NOT EXISTS FOR (t:Trend) ON (t.normalized_name, t.date);

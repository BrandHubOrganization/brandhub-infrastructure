-- Keep the immediately preceding terms for an accurate before/after comparison.
-- A user inbox entry may originate from a package proposal, not only an Admin broadcast.
BEGIN;
ALTER TABLE workspace_media_packages ADD COLUMN IF NOT EXISTS previous_terms JSONB;
ALTER TABLE user_notifications ALTER COLUMN notification_id DROP NOT NULL;

-- Move the legacy per-deliverable value to one package-wide value.
UPDATE media_packages p
SET offering_details = jsonb_set(
    jsonb_set(p.offering_details, '{maxChanges}',
        COALESCE(p.offering_details->'maxChanges', p.offering_details->'deliverables'->0->'revisionLimit')),
    '{deliverables}',
    (SELECT jsonb_agg(item - 'revisionLimit' ORDER BY ordinal)
       FROM jsonb_array_elements(p.offering_details->'deliverables') WITH ORDINALITY AS entry(item, ordinal)))
WHERE p.offering_details IS NOT NULL
  AND jsonb_typeof(p.offering_details->'deliverables') = 'array'
  AND jsonb_array_length(p.offering_details->'deliverables') > 0
  AND (p.offering_details ? 'maxChanges' OR p.offering_details->'deliverables'->0 ? 'revisionLimit');
COMMIT;

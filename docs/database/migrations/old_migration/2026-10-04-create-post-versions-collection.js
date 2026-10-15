// ============================================================
// BrandHub — MongoDB migration: post content versions for moderation
// Date: 2026-10-04
// Reason: FR 3.10.4 (BR-64) reviews an immutable version of a post.
//         posts.content_version starts at 1 and grows on every edit;
//         post_versions keeps the exact content that entered moderation.
//         Decisions live in PostgreSQL content_moderation_reviews.
//
// Idempotent: creates the collection when absent, refreshes the
// validator, and creates indexes by stable names. Existing posts
// without content_version are read as version 1 by the application.
//
// Run:
//   mongosh "$MONGODB_URI" docs/database/migrations/2026-10-04-create-post-versions-collection.js
// ============================================================

db = db.getSiblingDB('brandhub');

const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['_id', 'post_id', 'version', 'content_hash', 'captured_at'],
    properties: {
      _id:              { bsonType: 'string' },            // "<postId>:<version>"
      post_id:          { bsonType: 'string' },
      version:          { bsonType: ['long', 'int'], minimum: 1 },
      workspace_id:     { bsonType: ['string', 'null'] },
      created_by:       { bsonType: ['string', 'null'] },
      content_text:     { bsonType: ['string', 'null'] },
      hashtags:         { bsonType: 'array' },
      media:            { bsonType: 'array' },
      target_platforms: { bsonType: 'array' },
      content_hash:     { bsonType: 'string', minLength: 64, maxLength: 64 },
      captured_at:      { bsonType: 'date' },
    },
  },
};

if (!db.getCollectionNames().includes('post_versions')) {
  db.createCollection('post_versions', { validator, validationLevel: 'strict' });
} else {
  db.runCommand({ collMod: 'post_versions', validator, validationLevel: 'strict' });
}

db.post_versions.createIndex({ post_id: 1, version: -1 }, { name: 'post_versions_post_version' });

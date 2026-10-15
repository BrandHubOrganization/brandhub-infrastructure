// ============================================================
// BrandHub — MongoDB migration: mail_templates collection
// Date: 2026-10-12
// Reason: FR 3.6.28-3.6.32 (DA-998..DA-1001). Workspace mail templates and
//         Admin-managed SYSTEM_DEFAULT templates (workspaceId null). Soft
//         delete through deletedAt; every read filters deletedAt = null.
//
// Idempotent: creates the collection when absent, refreshes the validator
// and creates indexes by stable names.
//
// Run:
//   mongosh "$MONGODB_URI" docs/database/migrations/2026-10-12-create-mail-templates-collection.js
// ============================================================

db = db.getSiblingDB('brandhub');

const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['_id', 'name', 'subject', 'bodyHtml', 'type', 'createdAt', 'updatedAt'],
    properties: {
      workspaceId:  { bsonType: ['string', 'null'], description: 'null for SYSTEM_DEFAULT' },
      name:         { bsonType: 'string', minLength: 1, maxLength: 120 },
      subject:      { bsonType: 'string', minLength: 1, maxLength: 200 },
      bodyHtml:     { bsonType: 'string', minLength: 1, maxLength: 102400 },
      type:         { enum: ['SYSTEM_DEFAULT', 'CUSTOM'] },
      attachments:  {
        bsonType: 'array',
        maxItems: 3,
        items: {
          bsonType: 'object',
          required: ['attachmentId', 's3Key'],
          properties: {
            attachmentId: { bsonType: 'string' },
            name:         { bsonType: 'string' },
            contentType:  { bsonType: 'string' },
            size:         { bsonType: ['long', 'int'] },
            s3Key:        { bsonType: 'string' },
          },
        },
      },
      clonedFromId: { bsonType: ['string', 'null'] },
      createdBy:    { bsonType: ['string', 'null'] },
      createdAt:    { bsonType: 'date' },
      updatedAt:    { bsonType: 'date' },
      deletedAt:    { bsonType: ['date', 'null'] },
    },
  },
};

if (!db.getCollectionNames().includes('mail_templates')) {
  db.createCollection('mail_templates', { validator, validationAction: 'error' });
} else {
  const result = db.runCommand({ collMod: 'mail_templates', validator, validationAction: 'error' });
  if (!result.ok) throw new Error('Updating the mail_templates validator failed: ' + result.errmsg);
}

db.mail_templates.createIndex(
  { workspaceId: 1, deletedAt: 1, createdAt: -1 },
  { name: 'ix_mail_templates_workspace_created' });
db.mail_templates.createIndex(
  { type: 1, deletedAt: 1 },
  { name: 'ix_mail_templates_type' });

print('mail_templates ready');

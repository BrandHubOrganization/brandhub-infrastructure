// ============================================================
// BrandHub - MongoDB migration: mail_recipient_groups collection
// Date: 2026-10-13
// Reason: FR 3.6.32 follow-up. Named recipient lists a Workspace sends mail to
//         repeatedly (max 50 groups per Workspace, 200 recipients per group,
//         enforced by the service).
//
// Idempotent. Run:
//   mongosh "$MONGODB_URI" docs/database/migrations/2026-10-13-create-mail-recipient-groups-collection.js
// ============================================================

db = db.getSiblingDB('brandhub');

const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['_id', 'workspaceId', 'name', 'recipients', 'createdAt'],
    properties: {
      workspaceId: { bsonType: 'string' },
      name:        { bsonType: 'string', minLength: 1, maxLength: 80 },
      recipients:  {
        bsonType: 'array',
        maxItems: 200,
        items: {
          bsonType: 'object',
          required: ['email'],
          properties: {
            email: { bsonType: 'string', maxLength: 255 },
            name:  { bsonType: ['string', 'null'], maxLength: 120 },
          },
        },
      },
      createdBy:   { bsonType: ['string', 'null'] },
      createdAt:   { bsonType: 'date' },
    },
  },
};

if (!db.getCollectionNames().includes('mail_recipient_groups')) {
  db.createCollection('mail_recipient_groups', { validator, validationAction: 'error' });
} else {
  const result = db.runCommand({ collMod: 'mail_recipient_groups', validator, validationAction: 'error' });
  if (!result.ok) throw new Error('Updating the mail_recipient_groups validator failed: ' + result.errmsg);
}

db.mail_recipient_groups.createIndex(
  { workspaceId: 1, name: 1 },
  { name: 'ix_mail_recipient_groups_workspace_name' });

print('mail_recipient_groups ready');

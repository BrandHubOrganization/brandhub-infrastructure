// ============================================================
// BrandHub — MongoDB migration: workspace realtime chat
// Date: 2026-10-02
// Reason: DA-1007 / DA-E51-15 persists Workspace chat history
//         and per-user read state.
//
// Idempotent: creates missing collections, refreshes validators,
// and creates indexes by stable names.
//
// Run:
//   mongosh "$MONGODB_URI" docs/database/migrations/2026-10-02-create-workspace-chat-collections.js
// ============================================================

db = db.getSiblingDB('brandhub');

const messageValidator = {
  $jsonSchema: {
    bsonType: 'object',
    required: [
      'workspaceId', 'senderMemberId', 'senderUserId', 'senderRole',
      'senderDisplayName', 'content', 'contextType', 'clientMessageId',
      'createdAt',
    ],
    properties: {
      workspaceId:       { bsonType: 'string' },
      senderMemberId:    { bsonType: 'string' },
      senderUserId:      { bsonType: 'string' },
      senderRole:        { enum: ['MANAGER', 'CREATOR', 'CLIENT'] },
      senderDisplayName: { bsonType: 'string' },
      content:           { bsonType: 'string', minLength: 1, maxLength: 4000 },
      contextType:       { enum: ['GENERAL', 'MEDIA_PACKAGE', 'MEDIA_CAMPAIGN'] },
      contextId:         { bsonType: ['string', 'null'] },
      clientMessageId:   { bsonType: 'string' },
      createdAt:         { bsonType: 'date' },
    },
  },
};

const readStateValidator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['workspaceId', 'userId', 'lastReadMessageId', 'lastReadAt'],
    properties: {
      workspaceId:       { bsonType: 'string' },
      userId:            { bsonType: 'string' },
      lastReadMessageId: { bsonType: 'string' },
      lastReadAt:        { bsonType: 'date' },
    },
  },
};

function ensureCollection(name, validator) {
  if (db.getCollectionInfos({ name }).length === 0) {
    db.createCollection(name, { validator, validationAction: 'error' });
    return;
  }
  db.runCommand({ collMod: name, validator, validationAction: 'error' });
}

ensureCollection('chat_messages', messageValidator);
ensureCollection('chat_read_states', readStateValidator);

db.chat_messages.createIndex(
  { workspaceId: 1, createdAt: -1, _id: -1 },
  { name: 'idx_chat_messages_workspace_created' },
);
db.chat_messages.createIndex(
  { workspaceId: 1, senderUserId: 1, clientMessageId: 1 },
  { name: 'uq_chat_messages_client_message', unique: true },
);
db.chat_messages.createIndex(
  { workspaceId: 1, contextType: 1, contextId: 1, createdAt: -1 },
  { name: 'idx_chat_messages_workspace_context' },
);
db.chat_read_states.createIndex(
  { workspaceId: 1, userId: 1 },
  { name: 'uq_chat_read_states_workspace_user', unique: true },
);

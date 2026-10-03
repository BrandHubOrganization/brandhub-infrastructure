// ============================================================
// BrandHub — MongoDB migration: create generic tasks collection
// Date: 2026-09-26
// Reason: DA-E51-01 replaces separate post/livestream/survey task
//         collections with one `tasks` collection discriminated by `type`.
//         Tasks created from Content Requests use campaignId = null.
//
// Idempotent: creates the collection when absent; otherwise updates its
// validator. Existing documents are not rewritten by collMod.
//
// Run:
//   mongosh "$MONGODB_URI" docs/database/migrations/2026-09-26-create-generic-tasks-collection.js
// ============================================================

db = db.getSiblingDB('brandhub');

const taskValidator = {
  $jsonSchema: {
    bsonType: 'object',
    required: [
      'workspaceId', 'type', 'name', 'status', 'requiresClientApproval',
      'typeMetadata', 'createdAt', 'updatedAt',
    ],
    properties: {
      workspaceId:            { bsonType: 'string' },
      campaignId:             { bsonType: ['string', 'null'] },
      type:                   { enum: ['POST', 'LIVESTREAM', 'SURVEY'] },
      name:                   { bsonType: 'string' },
      dueDate:                { bsonType: 'date' },
      status:                 { enum: ['BACKLOG', 'DETAIL_IDENTIFIED', 'ASSIGNED', 'IN_PROGRESS', 'QC_REVIEW', 'MANAGER_REVIEW', 'CLIENT_REVIEW', 'COMPLETED'] },
      assigneeId:             { bsonType: ['string', 'null'] },
      qcAssigneeId:           { bsonType: ['string', 'null'] },
      requiresClientApproval: { bsonType: 'bool' },
      description:            { bsonType: ['string', 'null'] },
      typeMetadata:           { bsonType: 'object' },
      createdAt:              { bsonType: 'date' },
      updatedAt:              { bsonType: 'date' },
    },
  },
};

if (db.getCollectionInfos({ name: 'tasks' }).length === 0) {
  db.createCollection('tasks', {
    validator: taskValidator,
    validationAction: 'error',
  });
} else {
  db.runCommand({
    collMod: 'tasks',
    validator: taskValidator,
    validationAction: 'error',
  });
}

db.tasks.createIndex({ workspaceId: 1, status: 1 }, { name: 'idx_tasks_workspace_status' });
db.tasks.createIndex({ workspaceId: 1, assigneeId: 1 }, { name: 'idx_tasks_workspace_assignee' });
db.tasks.createIndex({ workspaceId: 1, type: 1 }, { name: 'idx_tasks_workspace_type' });
db.tasks.createIndex({ workspaceId: 1, campaignId: 1 }, { name: 'idx_tasks_workspace_campaign' });

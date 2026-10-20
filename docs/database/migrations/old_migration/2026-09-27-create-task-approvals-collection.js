// ============================================================
// BrandHub — MongoDB migration: create append-only task approvals
// Date: 2026-09-27
// Reason: DA-E51-02 records QC, Manager, and Client approval actions in
//         a separate collection. Rejects preserve earlier records; the
//         approvalRound distinguishes each reject → resubmit cycle.
//
// Prerequisite: DA-E51-01 tasks collection must already exist.
// Idempotent: updates collection validators and creates missing indexes.
//
// Run:
//   mongosh "$MONGODB_URI" docs/database/migrations/2026-09-27-create-task-approvals-collection.js
// ============================================================

db = db.getSiblingDB('brandhub');

if (db.getCollectionInfos({ name: 'tasks' }).length === 0) {
  throw new Error('tasks collection is missing; run DA-E51-01 migration first.');
}

const taskValidator = {
  $jsonSchema: {
    bsonType: 'object',
    required: [
      'workspaceId', 'type', 'name', 'status', 'requiresClientApproval',
      'approvalRound', 'typeMetadata', 'createdAt', 'updatedAt',
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
      approvalRound:          { bsonType: 'int', minimum: 0 },
      typeMetadata:           { bsonType: 'object' },
      createdAt:              { bsonType: 'date' },
      updatedAt:              { bsonType: 'date' },
    },
  },
};

const approvalValidator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['taskId', 'approvalRound', 'step', 'action', 'actorId', 'createdAt'],
    properties: {
      taskId:        { bsonType: 'string' },
      approvalRound: { bsonType: 'int', minimum: 1 },
      step:          { enum: ['QC', 'MANAGER', 'CLIENT'] },
      action:        { enum: ['APPROVE', 'REJECT'] },
      actorId:       { bsonType: 'string' },
      comment:       { bsonType: ['string', 'null'] },
      createdAt:     { bsonType: 'date' },
    },
  },
};

db.runCommand({
  collMod: 'tasks',
  validator: taskValidator,
  validationAction: 'error',
});

if (db.getCollectionInfos({ name: 'task_approvals' }).length === 0) {
  db.createCollection('task_approvals', {
    validator: approvalValidator,
    validationAction: 'error',
  });
} else {
  db.runCommand({
    collMod: 'task_approvals',
    validator: approvalValidator,
    validationAction: 'error',
  });
}

db.task_approvals.createIndex(
  { taskId: 1, approvalRound: 1, step: 1, createdAt: 1 },
  { name: 'idx_task_approvals_task_round_step_created' }
);

// DA-948 Stage 4. Run on the existing Atlas database after E51-01/E51-02.
// Does not initialize or seed MongoDB. Existing tasks are not rewritten.
db = db.getSiblingDB('brandhub');
if (db.getCollectionInfos({ name: 'tasks' }).length === 0) {
  throw new Error('Generic tasks collection is missing; run E51 migrations first.');
}

const duplicateKeys = db.tasks.aggregate([
  { $match: { campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' } } },
  { $group: { _id: { campaignId: '$campaignId', campaignWorkItemId: '$campaignWorkItemId' }, count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } },
  { $limit: 1 },
]).toArray();
if (duplicateKeys.length) throw new Error('Duplicate Campaign work-item Tasks exist; reconcile before migration.');

const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['workspaceId', 'type', 'name', 'status', 'requiresClientApproval',
      'approvalRound', 'typeMetadata', 'createdAt', 'updatedAt'],
    properties: {
      workspaceId: { bsonType: 'string' },
      campaignId: { bsonType: ['string', 'null'] },
      campaignWorkItemId: { bsonType: ['string', 'null'] },
      type: { enum: ['POST', 'LIVESTREAM', 'SURVEY', 'EVENT_PLAN', 'PRESS_RECOMMENDATION'] },
      name: { bsonType: 'string' }, dueDate: { bsonType: ['date', 'null'] },
      status: { enum: ['BACKLOG', 'DETAIL_IDENTIFIED', 'ASSIGNED', 'IN_PROGRESS',
        'QC_REVIEW', 'MANAGER_REVIEW', 'CLIENT_REVIEW', 'COMPLETED'] },
      assigneeId: { bsonType: ['string', 'null'] },
      qcAssigneeId: { bsonType: ['string', 'null'] },
      requiresClientApproval: { bsonType: 'bool' },
      description: { bsonType: ['string', 'null'] },
      approvalRound: { bsonType: 'int', minimum: 1 },
      typeMetadata: { bsonType: 'object' },
      sourceType: { bsonType: ['string', 'null'] }, sourceRefId: { bsonType: ['string', 'null'] },
      createdBy: { bsonType: ['string', 'null'] },
      createdAt: { bsonType: 'date' }, updatedAt: { bsonType: 'date' },
    },
  },
};
const result = db.runCommand({ collMod: 'tasks', validator, validationAction: 'error' });
if (!result.ok) throw new Error('Updating the Task validator failed: ' + result.errmsg);
db.tasks.createIndex({ campaignId: 1, campaignWorkItemId: 1 }, {
  name: 'uq_tasks_campaign_work_item', unique: true,
  partialFilterExpression: { campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' } },
});

for (const name of ['event_plans', 'press_recommendations']) {
  const specialistValidator = { $jsonSchema: {
    bsonType: 'object', required: ['taskId', 'contentVersion', 'createdAt', 'updatedAt'],
    properties: {
      taskId: { bsonType: 'string' }, contentVersion: { bsonType: 'int', minimum: 1 },
      createdAt: { bsonType: 'date' }, updatedAt: { bsonType: 'date' },
      planContent: { bsonType: ['string', 'null'] }, referenceLinks: { bsonType: 'array' },
      recommendations: { bsonType: 'array' },
    },
  } };
  if (db.getCollectionInfos({ name }).length === 0) {
    db.createCollection(name, { validator: specialistValidator, validationAction: 'error' });
  } else {
    const updated = db.runCommand({ collMod: name, validator: specialistValidator, validationAction: 'error' });
    if (!updated.ok) throw new Error('Updating ' + name + ' validator failed: ' + updated.errmsg);
  }
  db.getCollection(name).createIndex({ taskId: 1 }, { name: 'uq_' + name + '_task', unique: true });
}

print('DA-948 Mongo migration complete: tasks validator, Campaign work-item index, specialist collections.');

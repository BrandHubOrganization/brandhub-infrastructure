// Read-only preflight for DA-948. Run against existing Mongo Atlas before migration.
const campaignDb = db.getSiblingDB('brandhub');
const taskCollection = campaignDb.getCollectionInfos({ name: 'tasks' });
const duplicateKeys = taskCollection.length ? campaignDb.tasks.aggregate([
  { $match: { campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' } } },
  { $group: { _id: { campaignId: '$campaignId', campaignWorkItemId: '$campaignWorkItemId' }, count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } },
  { $limit: 5 },
]).toArray() : [];
print(JSON.stringify({
  database: campaignDb.getName(),
  collectionNames: campaignDb.getCollectionNames(),
  tasksCollectionExists: taskCollection.length > 0,
  taskCount: taskCollection.length ? campaignDb.tasks.countDocuments({}) : 0,
  campaignTaskCount: taskCollection.length ? campaignDb.tasks.countDocuments({ campaignId: { $type: 'string' } }) : 0,
  duplicateCampaignWorkItemKeys: duplicateKeys,
  indexNames: taskCollection.length ? campaignDb.tasks.getIndexes().map(index => index.name) : [],
}));

// READ ONLY. Run the WHOLE file in the intended VS Code MongoDB Playground connection.
// Explicit brandhub selection, counts/metadata only: no IDs, brief/comment text, tokens or emails.
// This is inventory, NOT an APPLY migration or proof of legacy workflow history.
(() => {
  const target = db.getSiblingDB("brandhub");
  const report = {
    database: target.getName(),
    initialDatabase: db.getName(),
    mode: "READ_ONLY",
    checkedAt: new Date().toISOString(),
    collections: {},
    errors: [],
  };
  const names = [
    "tasks",
    "task_approvals",
    "task_comments",
    "task_comment_uploads",
    "task_notification_outbox",
  ];
  for (const name of names) {
    try {
      const info = target.getCollectionInfos({ name })[0];
      if (!info) {
        report.collections[name] = { exists: false };
        continue;
      }
      const col = target.getCollection(name);
      const properties = info.options?.validator?.$jsonSchema?.properties ?? {};
      const metadata = {
        exists: true,
        count: col.countDocuments({}),
        validationLevel: info.options?.validationLevel ?? "strict",
        validationAction: info.options?.validationAction ?? "error",
        indexNames: col.getIndexes().map((item) => item.name),
      };
      if (name === "tasks") {
        metadata.validatorSupportsCancellation =
          Array.isArray(properties.status?.enum) &&
          properties.status.enum.includes("CANCELLED") &&
          !!properties.cancellation;
        metadata.foundationProperties = [
          "workflowRevision",
          "plannedPublishAt",
          "firstStartedAt",
          "firstStartedBy",
        ].filter((field) => !!properties[field]);
        metadata.byStatusAndSource = col
          .aggregate([
            {
              $group: {
                _id: {
                  status: "$status",
                  sourceType: "$sourceType",
                  type: "$type",
                },
                count: { $sum: 1 },
              },
            },
            { $sort: { "_id.status": 1, "_id.sourceType": 1, "_id.type": 1 } },
          ])
          .toArray();
        metadata.missingRevision = col.countDocuments({
          workflowRevision: { $exists: false },
        });
        metadata.missingFirstStartEvidence = col.countDocuments({
          firstStartedAt: { $exists: false },
        });
        metadata.assignedWithoutFirstStartEvidence = col.countDocuments({
          status: "ASSIGNED",
          firstStartedAt: { $exists: false },
        });
        metadata.requestTasksWithoutCampaign = col.countDocuments({
          sourceType: "CONTENT_REQUEST",
          campaignId: null,
        });
      }
      report.collections[name] = metadata;
    } catch (error) {
      report.collections[name] = { status: "UNKNOWN" };
      report.errors.push({
        collection: name,
        code: typeof error.code === "number" ? error.code : null,
        message:
          "Cannot inspect; verify connection/read/listCollections/listIndexes permissions. Details suppressed.",
      });
    }
  }
  report.notes = [
    "Missing firstStartedAt is UNKNOWN history, not proof that work never started.",
    "Read/comment access uses active Workspace membership for all Task sources; first-start evidence only gates workflow mutations.",
    "No document or schema changes performed. Review checker separately for exact migration effects.",
  ];
  return report;
})();

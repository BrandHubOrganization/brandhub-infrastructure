// DA-951 / FR 3.5.7–3.5.10. Default is READ-ONLY preflight; never rerun init on Atlas.
// In mongosh / VS Code Playground select the intended database first.
// After backup, writer freeze and review: globalThis.CONTENT_REQUEST_MIGRATION_APPLY = true;
// Then load this file. Ambiguous legacy statuses/fields abort BEFORE any write.
(function () {
  const apply = globalThis.CONTENT_REQUEST_MIGRATION_APPLY === true;
  const name = "content_requests";
  const statuses = [
    "PENDING",
    "IN_PROGRESS",
    "ACCEPTED",
    "DENIED",
    "CANCELLED",
  ];
  const types = ["POST", "LIVESTREAM", "SURVEY"];
  const exists = db.getCollectionInfos({ name }).length > 0;
  const collection = db.getCollection(name);
  const changes = [];
  const failures = [];
  let count = 0;
  const uuid =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  function choose(record, modern, legacy) {
    if (
      record[modern] !== undefined &&
      record[legacy] !== undefined &&
      String(record[modern]) !== String(record[legacy])
    )
      throw new Error("Conflicting " + modern);
    return record[modern] !== undefined ? record[modern] : record[legacy];
  }
  function normalise(record) {
    const candidate = {
      workspaceId: choose(record, "workspaceId", "workspace_id"),
      requestedBy: choose(record, "requestedBy", "requested_by"),
      title: record.title,
      description: record.description,
      type: record.type,
      dueDate: choose(record, "dueDate", "due_date"),
      status: record.status,
      createdAt: choose(record, "createdAt", "created_at"),
      updatedAt: choose(record, "updatedAt", "updated_at"),
      version: record.version === undefined ? NumberLong(1) : record.version,
      history: record.history === undefined ? [] : record.history,
      generatedTaskId:
        choose(record, "generatedTaskId", "generated_task_id") ?? null,
      reviewedBy: record.reviewedBy ?? null,
      reviewedAt: record.reviewedAt ?? null,
    };
    if (!uuid.test(candidate.workspaceId) || !uuid.test(candidate.requestedBy))
      throw new Error("Missing/invalid scope");
    if (
      typeof candidate.title !== "string" ||
      !candidate.title.trim() ||
      candidate.title.length > 255
    )
      throw new Error("Missing/invalid title");
    if (
      typeof candidate.description !== "string" ||
      candidate.description.length > 10000
    )
      throw new Error("Missing/invalid description");
    if (!types.includes(candidate.type) || !statuses.includes(candidate.status))
      throw new Error("Ambiguous type/status");
    for (const field of ["dueDate", "createdAt", "updatedAt"]) {
      if (
        !(candidate[field] instanceof Date) ||
        !Number.isFinite(candidate[field].getTime())
      )
        throw new Error("Missing/invalid " + field);
    }
    if (
      !Number.isSafeInteger(Number(candidate.version)) ||
      Number(candidate.version) < 1 ||
      !Array.isArray(candidate.history)
    )
      throw new Error("Invalid version/history");
    for (const field of ["generatedTaskId", "reviewedBy"]) {
      if (candidate[field] !== null && typeof candidate[field] !== "string")
        throw new Error("Invalid " + field);
    }
    if (
      candidate.reviewedAt !== null &&
      (!(candidate.reviewedAt instanceof Date) ||
        !Number.isFinite(candidate.reviewedAt.getTime()))
    )
      throw new Error("Invalid reviewedAt");
    if (
      candidate.status === "ACCEPTED" &&
      (!candidate.generatedTaskId ||
        !db.getCollection("tasks").findOne({
          _id: candidate.generatedTaskId,
          workspaceId: candidate.workspaceId,
          sourceType: "CONTENT_REQUEST",
          sourceRefId: String(record._id),
        }))
    )
      throw new Error("Accepted legacy request has no verified Task reference");
    return candidate;
  }
  if (exists)
    collection.find({}).forEach((record) => {
      count++;
      try {
        changes.push({ id: record._id, fields: normalise(record) });
      } catch (error) {
        failures.push(error.message);
      }
    });
  print(
    JSON.stringify({
      database: db.getName(),
      mode: apply ? "APPLY" : "DRY_RUN",
      count,
      ready: changes.length,
      blocked: failures.length,
      reasons: [...new Set(failures)],
    }),
  );
  if (failures.length)
    throw new Error(
      "Preflight blocked: review legacy data with team; nothing was written.",
    );
  if (!apply) return;
  if (!exists) db.createCollection(name);
  // Pause all writers before apply; the two passes are not a collection-wide transaction.
  for (const change of changes)
    collection.updateOne(
      { _id: change.id },
      { $set: change.fields },
      { bypassDocumentValidation: true },
    ); // Legacy validator can reject the modern shape during cutover.
  const validator = {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "workspaceId",
        "requestedBy",
        "title",
        "description",
        "type",
        "dueDate",
        "status",
        "version",
        "history",
        "createdAt",
        "updatedAt",
      ],
      properties: {
        workspaceId: { bsonType: "string" },
        requestedBy: { bsonType: "string" },
        title: { bsonType: "string", minLength: 1, maxLength: 255 },
        description: { bsonType: "string", maxLength: 10000 },
        type: { enum: types },
        dueDate: { bsonType: "date" },
        status: { enum: statuses },
        version: {
          bsonType: ["long", "int", "double", "decimal"],
          minimum: 1,
          multipleOf: 1,
        },
        history: { bsonType: "array" },
        generatedTaskId: { bsonType: ["string", "null"] },
        reviewedBy: { bsonType: ["string", "null"] },
        reviewedAt: { bsonType: ["date", "null"] },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" },
      },
    },
  };
  const result = db.runCommand({
    collMod: name,
    validator,
    validationLevel: "strict",
    validationAction: "error",
  });
  if (result.ok !== 1)
    throw new Error(
      "Validator update failed; keep API disabled and inspect backup/preflight.",
    );
  collection.createIndex(
    { workspaceId: 1, status: 1, createdAt: -1 },
    { name: "idx_content_requests_v2_workspace_status" },
  );
  collection.createIndex(
    { workspaceId: 1, requestedBy: 1 },
    { name: "idx_content_requests_v2_requester" },
  );
  if (collection.countDocuments() !== count)
    throw new Error(
      "Count changed; writers were not frozen. Review before enabling API.",
    );
  // Readiness index is installed LAST, only after normalisation and strict validator.
  collection.createIndex(
    { workspaceId: 1, createdAt: -1, _id: -1 },
    { name: "idx_content_requests_v2_workspace_created" },
  );
  print(
    "DA-951 V2 migration complete; legacy fields/indexes retained for review, no Task was created.",
  );
})();

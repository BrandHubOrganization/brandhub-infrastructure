// FR 3.6.9 / E51-03. Metadata/indexes ONLY; no document writes, snapshots or backfill.
// Run the WHOLE file in VS Code Playground or mongosh. Always targets brandhub, not test.
// DEFAULT DRY_RUN. APPLY requires BOTH TASK_APPROVAL_FOUNDATION_APPLY=true and
// TASK_APPROVAL_WRITERS_PAUSED=true after review/backup and pausing ALL shared writers.
// Do not run old Task/foundation validators afterward. See task-approval-setup.md.
(() => {
  const target = db.getSiblingDB("brandhub");
  const apply = globalThis.TASK_APPROVAL_FOUNDATION_APPLY === true;
  const string = { bsonType: "string" };
  const nullableString = { bsonType: ["string", "null"] };
  const nullableDate = { bsonType: ["date", "null"] };
  const positiveInt = { bsonType: "int", minimum: 1 };
  // BEGIN APPROVAL DEFINITIONS: parity with init/checker is tested.
  const lastSubmission = {
    bsonType: ["object", "null"],
    required: ["round", "submittedBy", "submittedAt"],
    properties: {
      round: positiveInt,
      submittedBy: string,
      submittedAt: { bsonType: "date" },
      closedBy: nullableString,
      closedAt: nullableDate,
      outcome: {
        enum: ["APPROVED", "REJECTED", "WITHDRAWN", "CANCELLED", null],
      },
    },
  };
  const additions = [
    { name: "tasks", properties: { lastSubmission }, indexes: [] },
    {
      name: "posts",
      properties: { task_id: { ...nullableString, minLength: 1 } },
      indexes: [
        {
          name: "uq_posts_task",
          key: { task_id: 1 },
          unique: true,
          partialFilterExpression: { task_id: { $type: "string" } },
        },
      ],
    },
    {
      name: "task_approvals",
      properties: {},
      indexes: [
        {
          name: "uq_task_approvals_round_step",
          key: { taskId: 1, approvalRound: 1, step: 1 },
          unique: true,
        },
        {
          name: "idx_task_approvals_timeline",
          key: { taskId: 1, createdAt: -1, _id: -1 },
        },
      ],
    },
    {
      name: "task_notification_outbox",
      properties: {
        approvalRound: positiveInt,
        reviewStep: {
          bsonType: ["string", "null"],
          enum: ["MANAGER", "CLIENT", null],
        },
        decisionId: nullableString,
        postId: { ...nullableString, minLength: 1 },
        postContentVersion: { bsonType: ["long", "int"], minimum: 1 },
      },
      indexes: [],
    },
  ];
  // END APPROVAL DEFINITIONS. Existing enum values and unrelated rules are preserved.
  const canonical = (value) => JSON.stringify(sort(value));
  function sort(value) {
    if (Array.isArray(value)) return value.map(sort);
    if (value && typeof value === "object")
      return Object.fromEntries(
        Object.keys(value)
          .sort()
          .map((key) => [key, sort(value[key])]),
      );
    return value;
  }
  const sameKeys = (left, right) =>
    JSON.stringify(Object.entries(left)) ===
    JSON.stringify(Object.entries(right));
  const indexMatches = (actual, expected) =>
    sameKeys(actual.key, expected.key) &&
    !!actual.unique === !!expected.unique &&
    canonical(actual.partialFilterExpression) ===
      canonical(expected.partialFilterExpression) &&
    !actual.sparse &&
    !actual.hidden &&
    actual.expireAfterSeconds === undefined &&
    !actual.collation;
  const problems = [];
  const problem = (collection, reason) => problems.push({ collection, reason });
  const infos = new Map();
  const indexes = new Map();
  for (const addition of additions) {
    try {
      const info = target.getCollectionInfos({ name: addition.name })[0];
      infos.set(addition.name, info);
      indexes.set(
        addition.name,
        info ? target.getCollection(addition.name).getIndexes() : [],
      );
      if (!info) problem(addition.name, "COLLECTION_MISSING");
      else if (
        info.type === "view" ||
        !info.options?.validator?.$jsonSchema?.properties
      )
        problem(addition.name, "JSON_SCHEMA_BASELINE_REQUIRED");
      else if (info.options.collation)
        problem(addition.name, "CUSTOM_COLLATION_REQUIRES_REVIEW");
    } catch (_) {
      problem(addition.name, "METADATA_READ_UNAVAILABLE");
    }
  }
  const properties = (name) =>
    infos.get(name)?.options?.validator?.$jsonSchema?.properties ?? {};
  const tasks = properties("tasks");
  const taskStates = tasks.status?.enum ?? [];
  if (canonical(tasks.approvalRound) !== canonical(positiveInt))
    problem("tasks", "APPROVAL_ROUND_BASELINE_CONFLICT");
  if (
    !["TODO", "IN_PROGRESS", "IN_REVIEW", "FINISHED", "CANCELLED"].every(
      (state) => taskStates.includes(state),
    ) ||
    ![
      "workflowRevision",
      "firstStartedAt",
      "firstStartedBy",
      "reviewStep",
      "inputReferences",
      "assignedAt",
      "assignedBy",
      "cancellation",
    ].every((field) => tasks[field]) ||
    tasks.plannedPublishAt
  )
    problem("tasks", "APPLY_TASK_STRUCTURE_SIMPLIFICATION_FIRST");
  const approvals = properties("task_approvals");
  const approvalRequired =
    infos.get("task_approvals")?.options?.validator?.$jsonSchema?.required ??
    [];
  const approvalActions = approvals.action?.enum ?? [];
  const approvalSteps = approvals.step?.enum ?? [];
  if (canonical(approvals.approvalRound) !== canonical(positiveInt))
    problem("task_approvals", "APPROVAL_ROUND_BASELINE_CONFLICT");
  if (
    ![
      "taskId",
      "approvalRound",
      "step",
      "action",
      "actorId",
      "createdAt",
    ].every((field) => approvalRequired.includes(field)) ||
    !["APPROVE", "REJECT"].every((action) =>
      approvalActions.includes(action),
    ) ||
    !["MANAGER", "CLIENT"].every((step) => approvalSteps.includes(step))
  )
    problem("task_approvals", "APPROVAL_BASELINE_REQUIRED");
  const oldEvents = properties("task_notification_outbox").eventType?.enum;
  if (
    !Array.isArray(oldEvents) ||
    !["TASK_ASSIGNED", "TASK_COMMENTED"].every((event) =>
      oldEvents.includes(event),
    )
  )
    problem("task_notification_outbox", "OUTBOX_BASELINE_REQUIRED");
  if (
    !(indexes.get("task_notification_outbox") ?? []).some(
      (index) =>
        indexMatches(index, { key: { eventKey: 1 }, unique: true }) &&
        index.name === "uq_task_notification_outbox_event",
    )
  )
    problem("task_notification_outbox", "OUTBOX_UNIQUENESS_REQUIRED");

  const plans = additions.flatMap((addition) => {
    const info = infos.get(addition.name);
    const current = info?.options?.validator;
    const prior = current?.$jsonSchema;
    if (!prior?.properties) return [];
    const level = info.options.validationLevel ?? "strict";
    const action = info.options.validationAction ?? "error";
    if (
      level !== "strict" ||
      (addition.name !== "posts" && action !== "error") ||
      (addition.name === "posts" && !["warn", "error"].includes(action))
    )
      problem(addition.name, "VALIDATION_OPTIONS_REQUIRE_REVIEW");
    for (const [field, definition] of Object.entries(addition.properties)) {
      if (
        prior.properties[field] &&
        canonical(prior.properties[field]) !== canonical(definition)
      )
        problem(addition.name, "OWNED_FIELD_CONFLICT:" + field);
      if ((prior.required ?? []).includes(field))
        problem(addition.name, "OPTIONAL_FIELD_REQUIRED:" + field);
    }
    const nextProperties = { ...prior.properties, ...addition.properties };
    if (
      addition.name === "task_notification_outbox" &&
      Array.isArray(oldEvents)
    ) {
      nextProperties.eventType = {
        ...prior.properties.eventType,
        enum: [
          ...new Set([
            ...oldEvents,
            "TASK_REVIEW_REQUESTED",
            "TASK_REVIEW_REJECTED",
            "TASK_POST_SUBMITTED",
          ]),
        ],
      };
    }
    const validator = {
      ...current,
      $jsonSchema: { ...prior, properties: nextProperties },
    };
    for (const expected of addition.indexes) {
      const existing = indexes.get(addition.name) ?? [];
      const named = existing.find((index) => index.name === expected.name);
      const sameKey = existing.find((index) =>
        sameKeys(index.key, expected.key),
      );
      if (
        (named && !indexMatches(named, expected)) ||
        (sameKey && sameKey.name !== expected.name)
      )
        problem(addition.name, "INDEX_CONFLICT:" + expected.name);
    }
    return [
      {
        ...addition,
        validator,
        validationLevel: level,
        validationAction: action,
      },
    ];
  });
  const inventory = {};
  function count(name, key, query) {
    if (!infos.get(name)) return;
    try {
      (inventory[name] ??= {})[key] = target
        .getCollection(name)
        .countDocuments(query);
    } catch (_) {
      problem(name, "DOCUMENT_READ_UNAVAILABLE:" + key);
    }
  }
  function aggregateCount(name, key, pipeline) {
    if (!infos.get(name)) return;
    try {
      (inventory[name] ??= {})[key] =
        target
          .getCollection(name)
          .aggregate([...pipeline, { $count: "groups" }], {
            allowDiskUse: false,
          })
          .toArray()[0]?.groups ?? 0;
    } catch (_) {
      problem(name, "AGGREGATE_READ_UNAVAILABLE:" + key);
    }
  }
  for (const plan of plans) {
    count(plan.name, "count", {});
    count(plan.name, "invalidDocuments", { $nor: [plan.validator] });
    // posts keeps its warn/error policy; unrelated legacy Post validation drift is informational.
    if (plan.name === "posts")
      count(plan.name, "invalidLinkFields", {
        $nor: [
          { $jsonSchema: { bsonType: "object", properties: plan.properties } },
        ],
      });
    for (const expected of plan.indexes.filter((index) => index.unique)) {
      const group = Object.fromEntries(
        Object.keys(expected.key).map((field) => [field, "$" + field]),
      );
      aggregateCount(plan.name, "duplicates:" + expected.name, [
        ...(expected.partialFilterExpression
          ? [{ $match: expected.partialFilterExpression }]
          : []),
        { $group: { _id: group, count: { $sum: 1 } } },
        { $match: { count: { $gt: 1 } } },
      ]);
    }
  }
  count("tasks", "missingRevision", { workflowRevision: { $exists: false } });
  count("tasks", "missingFirstStartEvidence", {
    firstStartedAt: { $exists: false },
  });
  count("tasks", "legacyQcAssignments", { qcAssigneeId: { $type: "string" } });
  count("tasks", "unverifiedActiveReviews", {
    status: {
      $in: ["IN_REVIEW", "QC_REVIEW", "MANAGER_REVIEW", "CLIENT_REVIEW"],
    },
    $or: [
      { status: { $ne: "IN_REVIEW" } },
      { reviewStep: { $nin: ["MANAGER", "CLIENT"] } },
      { lastSubmission: null },
      { firstStartedAt: { $not: { $type: "date" } } },
      { firstStartedBy: { $not: { $type: "string" } } },
      { "lastSubmission.outcome": { $ne: null } },
      { $expr: { $ne: ["$lastSubmission.round", "$approvalRound"] } },
    ],
  });
  aggregateCount("posts", "invalidTaskLinks", [
    { $match: { task_id: { $type: "string" } } },
    {
      $lookup: {
        from: "tasks",
        localField: "task_id",
        foreignField: "_id",
        as: "linkedTask",
      },
    },
    { $unwind: { path: "$linkedTask", preserveNullAndEmptyArrays: true } },
    {
      $match: {
        $or: [
          { "linkedTask._id": { $exists: false } },
          { "linkedTask.type": { $ne: "POST" } },
          { $expr: { $ne: ["$workspace_id", "$linkedTask.workspaceId"] } },
        ],
      },
    },
  ]);
  aggregateCount("task_approvals", "orphanDecisions", [
    {
      $lookup: {
        from: "tasks",
        localField: "taskId",
        foreignField: "_id",
        as: "linkedTask",
      },
    },
    { $match: { "linkedTask.0": { $exists: false } } },
  ]);
  for (const [name, counts] of Object.entries(inventory)) {
    for (const [key, value] of Object.entries(counts)) {
      const unsafe =
        key.startsWith("duplicates:") ||
        [
          "invalidLinkFields",
          "unverifiedActiveReviews",
          "invalidTaskLinks",
          "orphanDecisions",
        ].includes(key) ||
        (key === "invalidDocuments" &&
          (name !== "posts" ||
            infos.get(name).options.validationAction !== "warn"));
      if (unsafe && value > 0) problem(name, key);
    }
  }
  const report = {
    database: target.getName(),
    initialDatabase: db.getName(),
    migration: "2026-10-18-task-approval-foundation.js",
    mode: apply ? "APPLY" : "DRY_RUN",
    blocked: problems.length > 0,
    problems,
    inventory,
    collections: plans.map((plan) => ({
      name: plan.name,
      validationLevel: plan.validationLevel,
      validationAction: plan.validationAction,
      indexes: plan.indexes.map((index) => index.name),
    })),
    note: "Metadata only. No document writes/linking/cleanup, snapshots or PostgreSQL changes. Legacy evidence is not inferred.",
  };
  globalThis.BRANDHUB_TASK_APPROVAL_MIGRATION_REPORT = report;
  print(JSON.stringify(report));
  if (!apply) return report;
  if (report.blocked)
    throw new Error(
      "Approval preflight blocked; no writes performed. Review report.problems.",
    );
  if (globalThis.TASK_APPROVAL_WRITERS_PAUSED !== true)
    throw new Error(
      "Confirm ALL shared writers paused with TASK_APPROVAL_WRITERS_PAUSED=true; no writes performed.",
    );
  // Recheck all metadata before the first DDL. This is not a writer lock; operator freeze is mandatory.
  for (const plan of plans) {
    const current = target.getCollectionInfos({ name: plan.name })[0];
    if (
      canonical(current?.options) !== canonical(infos.get(plan.name).options) ||
      canonical(target.getCollection(plan.name).getIndexes()) !==
        canonical(indexes.get(plan.name))
    )
      throw new Error("Metadata changed after preflight; no writes performed.");
  }
  const appliedCollections = [];
  try {
    for (const plan of plans) {
      const result = target.runCommand({
        collMod: plan.name,
        validator: plan.validator,
        validationLevel: plan.validationLevel,
        validationAction: plan.validationAction,
      });
      if (result.ok !== 1) throw new Error("DDL_FAILED");
      appliedCollections.push(plan.name);
      for (const { key, ...options } of plan.indexes)
        target.getCollection(plan.name).createIndex(key, options);
    }
  } catch (_) {
    report.partialApply = true;
    report.appliedCollections = appliedCollections;
    print(
      JSON.stringify({
        migration: report.migration,
        partialApply: true,
        appliedCollections,
      }),
    );
    throw new Error(
      "Approval DDL failed; keep feature disabled. Inspect partial metadata; no automatic rollback/drop.",
    );
  }
  report.applied = true;
  report.appliedCollections = appliedCollections;
  print(JSON.stringify(report));
  return report;
})();

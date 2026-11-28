globalThis.BRANDHUB_CHAT_SCHEDULE_APPLY = false;

// Run the whole script in mongosh or VS Code Playground. Default is DRY_RUN.
// After a clean preflight: globalThis.BRANDHUB_CHAT_SCHEDULE_APPLY = true;
(() => {
  const target = db.getSiblingDB("brandhub");
  const apply = globalThis.BRANDHUB_CHAT_SCHEDULE_APPLY === true;
  // BEGIN CHAT SCHEDULE CONTRACT (mirrored in fresh init)
  const chatScheduleUuid =
    "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
  const chatScheduleValidator = {
    $and: [
      {
        $jsonSchema: {
          bsonType: "object",
          required: [
            "workspaceId",
            "channelId",
            "senderUserId",
            "clientMessageId",
            "requestHash",
            "deliveryMessageId",
            "content",
            "mentionUserIds",
            "contextType",
            "scheduledAt",
            "timeZone",
            "status",
            "revision",
            "attempts",
            "availableAt",
            "createdAt",
            "updatedAt",
          ],
          properties: {
            _id: { bsonType: "objectId" },
            workspaceId: { bsonType: "string", pattern: chatScheduleUuid },
            senderUserId: { bsonType: "string", pattern: chatScheduleUuid },
            channelId: { bsonType: "string", minLength: 1, maxLength: 100 },
            clientMessageId: { bsonType: "string", pattern: chatScheduleUuid },
            deliveryMessageId: {
              bsonType: "string",
              pattern: chatScheduleUuid,
            },
            requestHash: { bsonType: "string", pattern: "^[0-9a-f]{64}$" },
            content: { bsonType: "string", minLength: 1, maxLength: 4000 },
            richContent: {
              bsonType: ["object", "null"],
              properties: {
                type: { enum: ["doc"] },
                content: { bsonType: "array", maxItems: 500 },
              },
            },
            mentionUserIds: {
              bsonType: "array",
              uniqueItems: true,
              maxItems: 20,
              items: { bsonType: "string", pattern: chatScheduleUuid },
            },
            contextType: {
              enum: ["GENERAL", "MEDIA_PACKAGE", "MEDIA_CAMPAIGN"],
            },
            contextId: {
              bsonType: ["string", "null"],
              pattern: chatScheduleUuid,
            },
            threadRootId: {
              bsonType: ["string", "null"],
              pattern: "^[0-9a-f]{24}$",
            },
            scheduledAt: { bsonType: "date" },
            availableAt: { bsonType: "date" },
            timeZone: { bsonType: "string", minLength: 1, maxLength: 64 },
            status: {
              enum: ["PENDING", "SENDING", "SENT", "FAILED", "CANCELLED"],
            },
            revision: { bsonType: ["int", "long"], minimum: 0 },
            attempts: { bsonType: ["int", "long"], minimum: 0 },
            leaseOwner: { bsonType: "string", pattern: chatScheduleUuid },
            leaseUntil: { bsonType: "date" },
            createdAt: { bsonType: "date" },
            updatedAt: { bsonType: "date" },
            sentAt: { bsonType: "date" },
            cancelledAt: { bsonType: "date" },
            sentMessageId: { bsonType: "string", pattern: "^[0-9a-f]{24}$" },
            errorCode: { bsonType: "string", minLength: 1, maxLength: 100 },
            broadcastPending: { bsonType: "bool" },
          },
        },
      },
      {
        $or: [
          {
            status: "SENDING",
            leaseOwner: { $type: "string" },
            leaseUntil: { $type: "date" },
          },
          {
            status: "PENDING",
            leaseOwner: { $exists: false },
            leaseUntil: { $exists: false },
          },
          {
            status: "FAILED",
            errorCode: { $type: "string" },
            leaseOwner: { $exists: false },
            leaseUntil: { $exists: false },
          },
          {
            status: "CANCELLED",
            cancelledAt: { $type: "date" },
            leaseOwner: { $exists: false },
            leaseUntil: { $exists: false },
          },
          {
            status: "SENT",
            sentAt: { $type: "date" },
            sentMessageId: { $type: "string" },
            leaseOwner: { $exists: false },
            leaseUntil: { $exists: false },
          },
        ],
      },
    ],
  };
  const chatScheduleIndexes = [
    {
      key: { workspaceId: 1, senderUserId: 1, clientMessageId: 1 },
      name: "uq_chat_schedule_request",
      unique: true,
    },
    {
      key: { workspaceId: 1, senderUserId: 1, scheduledAt: 1, _id: 1 },
      name: "idx_chat_schedule_own",
    },
    {
      key: { status: 1, availableAt: 1, _id: 1 },
      name: "idx_chat_schedule_due",
    },
    { key: { status: 1, leaseUntil: 1 }, name: "idx_chat_schedule_lease" },
    {
      key: { status: 1, broadcastPending: 1, updatedAt: 1, _id: 1 },
      name: "idx_chat_schedule_broadcast",
    },
  ];
  // END CHAT SCHEDULE CONTRACT
  const info = target.getCollectionInfos({
    name: "chat_scheduled_messages",
  })[0];
  const issues = [];
  const baseline = target.getCollectionInfos({ name: "chat_messages" })[0];
  if (!baseline || !target.getCollectionInfos({ name: "chat_channels" }).length)
    issues.push("CHAT_BASELINE_MISSING");
  const hello = target.runCommand({ hello: 1 });
  if (!hello.setName && hello.msg !== "isdbgrid")
    issues.push("REPLICA_SET_REQUIRED");
  if (
    baseline &&
    !target.chat_messages
      .getIndexes()
      .some(
        (index) =>
          index.unique === true &&
          !index.partialFilterExpression &&
          !index.sparse &&
          JSON.stringify(index.key) ===
            JSON.stringify({
              workspaceId: 1,
              senderUserId: 1,
              clientMessageId: 1,
            }),
      )
  ) {
    issues.push("CHAT_MESSAGE_IDEMPOTENCY_INDEX_MISSING");
  }
  let invalid = 0,
    duplicates = 0;
  const conflicts = [];
  if (info) {
    const old = info.options?.validator || {};
    if (
      Object.keys(old).length &&
      JSON.stringify(old) !== JSON.stringify(chatScheduleValidator)
    )
      issues.push("UNEXPECTED_SCHEDULE_VALIDATOR");
    if (info.options?.collation && info.options.collation.locale !== "simple")
      issues.push("UNEXPECTED_SCHEDULE_COLLATION");
    invalid = target.chat_scheduled_messages.countDocuments({
      $nor: [chatScheduleValidator],
    });
    duplicates = target.chat_scheduled_messages
      .aggregate([
        {
          $group: {
            _id: {
              workspaceId: "$workspaceId",
              senderUserId: "$senderUserId",
              clientMessageId: "$clientMessageId",
            },
            n: { $sum: 1 },
          },
        },
        { $match: { n: { $gt: 1 } } },
        { $limit: 1 },
      ])
      .toArray().length;
    const indexes = target.chat_scheduled_messages.getIndexes();
    for (const expected of chatScheduleIndexes) {
      for (const current of indexes) {
        const sameKey =
          JSON.stringify(current.key) === JSON.stringify(expected.key);
        if (
          (current.name === expected.name || sameKey) &&
          (!sameKey ||
            current.name !== expected.name ||
            !!current.unique !== !!expected.unique ||
            current.sparse ||
            current.partialFilterExpression ||
            current.expireAfterSeconds !== undefined ||
            current.hidden ||
            (current.collation && current.collation.locale !== "simple"))
        )
          conflicts.push(expected.name);
      }
    }
  }
  const blocked =
    issues.length > 0 || invalid > 0 || duplicates > 0 || conflicts.length > 0;
  print(
    JSON.stringify({
      migration: "chat-scheduled-messages-2026-10-26",
      database: target.getName(),
      mode: apply ? "APPLY" : "DRY_RUN",
      blocked,
      issues,
      invalid,
      duplicates,
      conflicts,
      backfill: false,
    }),
  );
  if (!apply) return;
  if (blocked)
    throw new Error("Scheduled chat preflight blocked; no writes performed.");
  if (!info)
    target.createCollection("chat_scheduled_messages", {
      validator: chatScheduleValidator,
      validationLevel: "strict",
      validationAction: "error",
    });
  else {
    const result = target.runCommand({
      collMod: "chat_scheduled_messages",
      validator: chatScheduleValidator,
      validationLevel: "strict",
      validationAction: "error",
    });
    if (result.ok !== 1)
      throw new Error("Could not apply scheduled chat validator.");
  }
  for (const { key, ...options } of chatScheduleIndexes)
    target.chat_scheduled_messages.createIndex(key, options);
  print(
    "Scheduled chat metadata ready. No messages, schedules or notifications seeded/backfilled.",
  );
})();

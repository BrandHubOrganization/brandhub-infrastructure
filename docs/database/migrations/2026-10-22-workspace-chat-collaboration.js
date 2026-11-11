// Run with mongosh against the intended deployment. Default: read-only DRY_RUN.
// APPLY changes collection/index metadata only; no messages are deleted or backfilled.
(() => {
  const target = db.getSiblingDB("brandhub");
  // Playground: set globalThis.BRANDHUB_CHAT_COLLABORATION_APPLY = true before this script.
  const apply = globalThis.BRANDHUB_CHAT_COLLABORATION_APPLY === true
    || (typeof process !== "undefined" && process.env?.BRANDHUB_CHAT_COLLABORATION_APPLY === "true");
  const existing = new Set(target.getCollectionNames());
  if (!existing.has("chat_messages")) throw new Error("Install the existing workspace-chat baseline first.");
  const additions = [
    { name: "chat_channels", validator: { $jsonSchema: {
      bsonType: "object",
      required: ["_id", "workspaceId", "name", "type", "createdBy", "creationKey", "memberUserIds", "createdAt"],
      properties: {
        _id: { bsonType: "string" }, workspaceId: { bsonType: "string" },
        name: { bsonType: "string", minLength: 1, maxLength: 80 },
        description: { bsonType: ["string", "null"], maxLength: 500 },
        type: { enum: ["PUBLIC", "PRIVATE", "DIRECT"] },
        createdBy: { bsonType: "string" }, creationKey: { bsonType: "string" },
        memberUserIds: { bsonType: "array", maxItems: 100, uniqueItems: true, items: { bsonType: "string" } },
        archived: { bsonType: "bool" }, managersOnly: { bsonType: "bool" }, createdAt: { bsonType: "date" },
      },
    } } },
    { name: "chat_channel_reads", validator: { $jsonSchema: {
      bsonType: "object", required: ["_id", "workspaceId", "channelId", "userId", "lastReadAt", "lastReadMessageId"],
      properties: {
        _id: { bsonType: "string" }, workspaceId: { bsonType: "string" }, channelId: { bsonType: "string" },
        userId: { bsonType: "string" }, lastReadAt: { bsonType: "date" }, lastReadMessageId: { bsonType: "string" },
      },
    } } },
  ];
  const indexes = [
    ["chat_messages", { workspaceId: 1, senderUserId: 1, clientMessageId: 1 },
      { name: "uq_chat_messages_client_message", unique: true }],
    ["chat_messages", { workspaceId: 1, channelId: 1, threadRootId: 1, createdAt: -1, _id: -1 },
      { name: "idx_chat_channel_thread_history" }],
    ["chat_messages", { workspaceId: 1, channelId: 1, pinned: 1, createdAt: -1, _id: -1 },
      { name: "idx_chat_channel_pins" }],
    ["chat_channels", { workspaceId: 1, memberUserIds: 1, createdAt: 1, _id: 1 },
      { name: "idx_chat_channels_members" }],
    ["chat_channels", { workspaceId: 1, type: 1, createdAt: 1, _id: 1 },
      { name: "idx_chat_channels_visibility" }],
    ["chat_channels", { workspaceId: 1, nameKey: 1 },
      { name: "uq_chat_channel_name", unique: true, partialFilterExpression: { nameKey: { $type: "string" } } }],
  ];
  // Validate before any metadata writes, including collections created by init.
  const invalid = additions.filter(collection => existing.has(collection.name))
    .map(collection => ({ collection: collection.name,
      invalidDocuments: target.getCollection(collection.name).countDocuments({ $nor: [collection.validator] }) }))
    .filter(result => result.invalidDocuments > 0);
  print(JSON.stringify({ mode: apply ? "APPLY" : "DRY_RUN", database: target.getName(),
    blocked: invalid.length > 0, invalid,
    createCollections: additions.filter(collection => !existing.has(collection.name)).map(collection => collection.name),
    indexes: indexes.map(([collection, key, options]) => ({ collection, key, options })) }, null, 2));
  if (!apply) return;
  if (invalid.length) throw new Error("Invalid existing chat documents; no writes performed.");
  for (const collection of additions) {
    if (!existing.has(collection.name)) target.createCollection(collection.name,
      { validator: collection.validator, validationLevel: "strict", validationAction: "error" });
    else {
      const result = target.runCommand({ collMod: collection.name, validator: collection.validator,
        validationLevel: "strict", validationAction: "error" });
      if (result.ok !== 1) throw new Error("Failed to update chat validator: " + collection.name);
    }
  }
  for (const [collection, key, options] of indexes) target.getCollection(collection).createIndex(key, options);
  print("Workspace chat collaboration metadata ready. Legacy message documents are unchanged.");
})();

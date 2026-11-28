// Metadata only; no message backfill. Execute the entire script in Playground.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.BRANDHUB_CHAT_RICH_APPLY === true;
  const info = target.getCollectionInfos({ name: 'chat_messages' })[0];
  if (!info) throw new Error('chat_messages collection is missing; no writes performed.');
  const existingValidator = info.options?.validator || {};
  const noValidator = Object.keys(existingValidator).length === 0;
  if (!noValidator && !existingValidator.$jsonSchema) {
    throw new Error('Unsupported non-empty chat_messages validator; review its structure before applying. No writes performed.');
  }
  const property = { bsonType: ['object', 'null'], properties: {
    type: { enum: ['doc'] }, content: { bsonType: 'array', maxItems: 500 },
  } };
  // Do not impose fresh-init required fields on legacy rows that had no validator.
  const validator = noValidator ? { $jsonSchema: { bsonType: 'object', properties: {} } } : existingValidator;
  const previous = validator.$jsonSchema.properties?.richContent;
  const conflict = previous && JSON.stringify(previous) !== JSON.stringify(property);
  if (conflict) throw new Error('Unexpected richContent definition; review before applying. No writes performed.');
  validator.$jsonSchema.properties = { ...validator.$jsonSchema.properties, richContent: property };
  const invalid = target.chat_messages.countDocuments({ $nor: [validator] });
  print(JSON.stringify({ migration: 'chat-rich-content-2026-10-24', database: target.getName(),
    mode: apply ? 'APPLY' : 'DRY_RUN', blocked: invalid > 0, invalid, backfill: false,
    previousValidator: noValidator ? 'NONE' : 'JSON_SCHEMA' }));
  if (!apply) return;
  if (invalid) throw new Error('Invalid message documents; no writes performed.');
  const result = target.runCommand({ collMod: 'chat_messages', validator,
    validationLevel: info.options?.validationLevel || 'strict',
    validationAction: info.options?.validationAction || 'error' });
  if (result.ok !== 1) throw new Error('Could not update richContent metadata.');
  print('Rich content metadata ready. No messages modified; all indexes and other validator fields preserved.');
})();

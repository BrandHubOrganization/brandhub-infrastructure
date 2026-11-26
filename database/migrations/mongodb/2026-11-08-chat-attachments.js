// MongoDB Playground/mongosh. Default is read-only; no data backfill, seed, or storage writes.
// use('brandhub'); globalThis.CHAT_ATTACHMENTS_APPLY = false; then execute the whole file.
(() => {
  const apply = globalThis.CHAT_ATTACHMENTS_APPLY === true;
  const uuid = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  // BEGIN CHAT ATTACHMENT CONTRACT
  const attachmentIds = { bsonType: ['array', 'null'], maxItems: 5, uniqueItems: true,
    items: { bsonType: 'string', pattern: uuid } };
  const attachmentValidator = { $jsonSchema: { bsonType: 'object', required: ['_id', 'workspaceId',
    'channelId', 'uploadedBy', 'source', 'state', 'filename', 'mimeType', 'byteSize',
    'storageProvider', 'storageKey', 'createdAt'], properties: {
    _id: { bsonType: 'string', pattern: uuid }, workspaceId: { bsonType: 'string', pattern: uuid },
    channelId: { bsonType: 'string', minLength: 1, maxLength: 100 }, uploadedBy: { bsonType: 'string', pattern: uuid },
    source: { enum: ['UPLOAD', 'REPOSITORY'] }, state: { enum: ['UPLOADING', 'READY', 'ATTACHED', 'FAILED', 'DELETING'] },
    filename: { bsonType: 'string', minLength: 1, maxLength: 255 }, mimeType: { bsonType: 'string', minLength: 1, maxLength: 255 },
    byteSize: { bsonType: ['int', 'long'], minimum: 1 }, storageProvider: { bsonType: 'string', minLength: 1 },
    storageKey: { bsonType: 'string', minLength: 1 }, materialId: { bsonType: ['string', 'null'] },
    materialWorkspaceId: { bsonType: ['string', 'null'] }, versionNumber: { bsonType: ['int', 'long', 'null'], minimum: 1 },
    createdAt: { bsonType: 'date' }, expiresAt: { bsonType: ['date', 'null'] },
  } } };
  const attachmentIndexes = [
    { name: 'idx_chat_attachments_owner', key: { workspaceId: 1, channelId: 1, uploadedBy: 1, state: 1 } },
    { name: 'idx_chat_attachments_cleanup', key: { expiresAt: 1, _id: 1 } },
  ];
  const messageAttachmentIndexes = [{ name: 'idx_chat_message_attachments', key: { workspaceId: 1, channelId: 1, attachmentIds: 1 } }];
  const scheduleAttachmentIndexes = [{ name: 'idx_chat_schedule_attachments', key: { workspaceId: 1, channelId: 1, attachmentIds: 1, status: 1 } }];
  const referenceAttachmentIndexes = [{ name: 'idx_material_chat_references', key: { source_type: 1, source_id: 1 } }];
  const textOrAttachment = { $or: [{ content: { $regex: '\\S' } }, { 'attachmentIds.0': { $exists: true } }] };
  function extendChatValidator(existing) {
    const next = typeof EJSON !== 'undefined' ? EJSON.parse(EJSON.stringify(existing)) : JSON.parse(JSON.stringify(existing));
    const find = value => value.$jsonSchema || (value.$and || []).map(find).find(Boolean);
    const schema = find(next);
    if (!schema || !schema.properties) throw new Error('Expected chat JSON schema baseline');
    // Earlier rich-content rollout may have installed only its own field contract.
    // Preserve that validator and add the missing text field rather than replace the baseline.
    if (!schema.properties.content) schema.properties.content = { bsonType: 'string', maxLength: 4000 };
    if (schema.properties.content.bsonType !== 'string') throw new Error('Incompatible chat content schema');
    schema.properties.attachmentIds = attachmentIds;
    schema.properties.content.minLength = 0;
    // Keep existing predicates and fields; this additive rule enables attachment-only messages.
    const isTextOrAttachment = clause => {
      if (!clause.$or || clause.$or.length !== 2) return false;
      const text = clause.$or.find(part => part.content)?.content;
      const expression = text?.$regex ?? text?.$regularExpression?.pattern ?? text?.pattern ?? text?.source;
      return expression === '\\S' && clause.$or.some(part => part['attachmentIds.0']?.$exists === true);
    };
    if (next.$and) {
      if (!next.$and.some(isTextOrAttachment)) next.$and.push(textOrAttachment);
    } else if (!next.$or) next.$or = textOrAttachment.$or;
    else if (!isTextOrAttachment(next)) return { $and: [next, textOrAttachment] };
    return next;
  }
  // END CHAT ATTACHMENT CONTRACT
  const problems = [];
  const specs = [];
  for (const [name, indexes] of [['chat_messages', messageAttachmentIndexes], ['chat_scheduled_messages', scheduleAttachmentIndexes]]) {
    const info = db.getCollectionInfos({name})[0];
    if (!info) { problems.push({collection:name, reason:'MISSING_BASELINE'}); continue; }
    try { specs.push({name, validator:extendChatValidator(info.options?.validator || {}), indexes}); }
    catch (error) { problems.push({collection:name,reason:error.message}); }
  }
  specs.push({name:'chat_attachments',validator:attachmentValidator,indexes:attachmentIndexes});
  const references = db.getCollectionInfos({name:'material_references'})[0];
  if (!references) problems.push({collection:'material_references',reason:'Apply repository baseline first'});
  else specs.push({name:'material_references',validator:references.options?.validator || {},indexes:referenceAttachmentIndexes});
  for (const spec of specs) {
    if (!db.getCollectionInfos({name:spec.name}).length) continue;
    if (Object.keys(spec.validator).length) {
      const invalid = db.getCollection(spec.name).countDocuments({$nor:[spec.validator]});
      if (invalid) problems.push({collection:spec.name,reason:'INVALID_DOCUMENTS',count:invalid});
    }
    const actual = db.getCollection(spec.name).getIndexes();
    for (const index of spec.indexes) {
      const conflict = actual.find(other => other.name === index.name || JSON.stringify(other.key) === JSON.stringify(index.key));
      if (conflict && (JSON.stringify(conflict.key)!==JSON.stringify(index.key) || !!conflict.unique || conflict.expireAfterSeconds!==undefined || conflict.partialFilterExpression || conflict.sparse))
        problems.push({collection:spec.name,reason:'INDEX_CONFLICT',index:index.name});
    }
  }
  print(JSON.stringify({migration:'chat-attachments-2026-11-08',database:db.getName(),mode:apply?'APPLY':'DRY_RUN',blocked:!!problems.length,problems,backfill:false}));
  if (problems.length || !apply) return;
  for (const spec of specs) {
    if (!db.getCollectionInfos({name:spec.name}).length) db.createCollection(spec.name,{validator:spec.validator,validationLevel:'strict',validationAction:'error'});
    else if (spec.name!=='material_references') {
      const result = db.runCommand({collMod:spec.name,validator:spec.validator,validationLevel:'strict',validationAction:'error'});
      if (result.ok !== 1) throw new Error('Could not update validator: ' + spec.name);
    }
    for (const {key,...options} of spec.indexes) db.getCollection(spec.name).createIndex(key,options);
  }
  print('Chat attachment metadata ready. No messages, files, references or storage objects were backfilled.');
})();

// Addendum B (3.6.28-32, chưa chốt): mở rộng mail_templates validator cho scope/agencyId/layoutJson,
// nới bodyHtml thành optional (render-cache), rồi backfill scope cho document cũ (type -> scope).
// Default mode is read-only (DRY_RUN).
// Run with globalThis.MAIL_TEMPLATE_SCOPE_APPLY = true to apply schema modification + backfill.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.MAIL_TEMPLATE_SCOPE_APPLY === true;
  const info = target.getCollectionInfos({ name: 'mail_templates' })[0];
  if (!info) {
    throw new Error('Collection mail_templates not found in brandhub database.');
  }

  const validator = info?.options?.validator || { $jsonSchema: { bsonType: 'object', properties: {}, required: [] } };
  const schema = validator.$jsonSchema || { bsonType: 'object', properties: {}, required: [] };
  const properties = schema.properties || {};

  const nextProperties = {
    ...properties,
    bodyHtml: { bsonType: 'string', maxLength: 102400, description: 'Render-cache từ layoutJson (Addendum B); có thể rỗng tới khi save lần đầu' },
    type: { enum: ['SYSTEM_DEFAULT', 'CUSTOM'] },
    scope: {
      enum: ['CAMPAIGN_BROADCAST', 'ADMIN_SYSTEM_BROADCAST', 'AGENCY_INTERNAL', 'WORKSPACE_MANAGER', 'AGENCY_CLIENT', 'TRANSACTIONAL_AUTO'],
      description: 'Addendum B: thay type nhị phân cũ',
    },
    agencyId: { bsonType: ['string', 'null'], description: 'Addendum B: set cho AGENCY_INTERNAL/AGENCY_CLIENT' },
    layoutJson: { bsonType: ['string', 'null'], description: 'Addendum B: danh sách block JSON, nguồn thật của nội dung' },
  };

  // bodyHtml không còn bắt buộc non-empty khi layoutJson đã có nội dung — bỏ khỏi required.
  const nextRequired = (schema.required || []).filter((f) => f !== 'bodyHtml');

  // MongoDB rejects `required: []`, so drop the key when nothing is left.
  const { required: _oldRequired, ...schemaWithoutRequired } = schema;
  const nextValidator = {
    ...validator,
    $jsonSchema: {
      ...schemaWithoutRequired,
      properties: nextProperties,
      ...(nextRequired.length > 0 ? { required: nextRequired } : {}),
    },
  };

  const col = target.getCollection('mail_templates');
  const toBackfillCount = col.countDocuments({ scope: { $exists: false } });
  const totalCount = col.countDocuments({});

  const report = {
    database: target.getName(),
    collection: 'mail_templates',
    mode: apply ? 'APPLY' : 'DRY_RUN',
    totalDocuments: totalCount,
    toBackfillCount,
    note: 'Nới validator (scope/agencyId/layoutJson, bodyHtml optional) rồi backfill scope cho document cũ (type -> scope).',
  };

  print(JSON.stringify(report));

  if (!apply) return report;

  const result = target.runCommand({
    collMod: 'mail_templates',
    validator: nextValidator,
    validationAction: info.options?.validationAction || 'error',
    validationLevel: info.options?.validationLevel || 'strict',
  });

  if (result.ok !== 1) {
    throw new Error('Updating collection mail_templates validator failed: ' + JSON.stringify(result));
  }

  col.find({ scope: { $exists: false } }).forEach((doc) => {
    const scope = doc.type === 'SYSTEM_DEFAULT' ? 'ADMIN_SYSTEM_BROADCAST' : 'WORKSPACE_MANAGER';
    col.updateOne({ _id: doc._id }, {
      $set: { scope, agencyId: null, layoutJson: JSON.stringify({ version: 1, blocks: [] }) },
    });
  });

  col.createIndex({ scope: 1, workspaceId: 1 }, { name: 'ix_mail_templates_scope_workspace' });
  col.createIndex({ scope: 1, agencyId: 1 }, { name: 'ix_mail_templates_scope_agency' });

  print('Successfully migrated mail_templates validator and backfilled scope for ' + toBackfillCount + ' documents.');
  return { ...report, applied: true };
})();

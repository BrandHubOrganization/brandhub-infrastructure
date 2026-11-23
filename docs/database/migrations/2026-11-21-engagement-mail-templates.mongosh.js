// Engagement mails M1–M5 as Admin-editable system templates (plan 2026-11-21-profile-data-utilization/04-auto-mail.md).
// mail_templates lives in MongoDB, so this is a mongosh script, not SQL. Playground: use('brandhub');
// globalThis.ENGAGEMENT_TEMPLATES_APPLY = false (dry run, default) / true.
// Inserts 10 TRANSACTIONAL_AUTO rows (vi + en) with stable _id 'engagement-m<N>-<vi|en>' — the ids
// EngagementKind.templateId() looks up. Additive and re-runnable: an existing _id (edited or soft-deleted by an
// Admin) is never touched. bodyHtml is left empty: the backend renders layoutJson when bodyHtml is blank, and
// MailTemplateSeeder fills the render-cache on the next start. Local/dev get the same rows from MailTemplateSeeder.
// If a row is missing at send time the job falls back to the built-in text in EngagementKind.
(() => {
  const apply = globalThis.ENGAGEMENT_TEMPLATES_APPLY === true;
  // [kind, lang, subject, heading, line, button] — same text as EngagementKind, in {{var}} syntax.
  const rows = [
    ['m1', 'vi', 'Hoàn thiện hồ sơ của bạn', 'Hồ sơ của bạn mới hoàn thiện {{percent}}%',
      'Thêm kỹ năng, kinh nghiệm và khu vực để Manager giao đúng việc cho bạn.', 'Cập nhật hồ sơ'],
    ['m1', 'en', 'Complete your profile', 'Your profile is {{percent}}% complete',
      'Add skills, experience and location so Managers can assign you the right work.', 'Update profile'],
    ['m2', 'vi', 'Tổng hợp công việc tuần này', 'Bạn có {{count}} việc đang mở',
      'Xem danh sách và hạn chót các việc được giao cho bạn tuần này.', 'Xem công việc'],
    ['m2', 'en', 'Your weekly task digest', 'You have {{count}} open subtasks',
      'Review the subtasks assigned to you and their due dates this week.', 'Open tasks'],
    ['m3', 'vi', 'Đang chờ bạn duyệt', '{{subject}} đang chờ bạn duyệt',
      'Agency đã duyệt và đang chờ phản hồi của bạn để tiếp tục.', 'Mở để duyệt'],
    ['m3', 'en', 'Waiting for your approval', '{{subject}} is waiting for your approval',
      'The agency has approved it and needs your response to move on.', 'Open to review'],
    ['m4', 'vi', 'Chiến dịch có nguy cơ trễ', 'Chiến dịch {{subject}} có nguy cơ trễ',
      'Mới hoàn thành {{done}}/{{expected}} hạng mục đến hạn hôm nay ({{percent}}%).', 'Xem tiến độ'],
    ['m4', 'en', 'Campaign at risk', 'Campaign {{subject}} is at risk',
      'Only {{done}}/{{expected}} work items due by today are finished ({{percent}}%).', 'Open timeline'],
    ['m5', 'vi', 'Kết nối tài khoản mạng xã hội', 'Workspace {{subject}} chưa kết nối {{platforms}}',
      'Hồ sơ có liên kết nhưng chưa kết nối tài khoản để đăng bài và xem số liệu.', 'Kết nối ngay'],
    ['m5', 'en', 'Connect your social accounts', 'Workspace {{subject}} has not connected {{platforms}}',
      'The profile links these pages but no account is connected for publishing and insights.', 'Connect now'],
  ];
  if (!db.getCollectionInfos({ name: 'mail_templates' })[0]) {
    throw new Error('Apply the mail_templates baseline first; no writes performed.');
  }
  const now = new Date();
  let inserted = 0;
  rows.forEach(([kind, lang, subject, heading, line, button]) => {
    const _id = `engagement-${kind}-${lang}`;
    if (db.mail_templates.countDocuments({ _id }) > 0) { print(`skip ${_id} (exists)`); return; }
    const layoutJson = JSON.stringify({ version: 1, locale: lang, blocks: [
      { id: 'b1', type: 'HEADING', props: { text: heading, align: 'left' } },
      { id: 'b2', type: 'PARAGRAPH', props: { text: line } },
      { id: 'b3', type: 'CTA_BUTTON', props: { label: button, urlType: 'site' } },
    ] });
    const doc = {
      _id, workspaceId: null, agencyId: null, scope: 'TRANSACTIONAL_AUTO', type: 'SYSTEM_DEFAULT',
      category: 'TRANSACTIONAL_AUTO', name: `${kind.toUpperCase()} - ${subject} (${lang.toUpperCase()})`,
      subject, bodyHtml: '', layoutJson, attachments: [], clonedFromId: null, createdBy: 'system',
      createdAt: now, updatedAt: now, deletedAt: null,
      _class: 'com.brandhub.business.document.MailTemplateDocument',
    };
    if (apply) db.mail_templates.insertOne(doc);
    inserted++;
    print(`${apply ? 'inserted' : 'would insert'} ${_id}`);
  });
  print(`${apply ? 'Applied' : 'Dry run'}: ${inserted} engagement template(s).`);
})();

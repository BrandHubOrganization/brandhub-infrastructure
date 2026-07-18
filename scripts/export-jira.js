#!/usr/bin/env node
/**
 * Export status/assignee thật từ Jira ra jira_status.json cho dashboard đọc.
 * Không qua MCP (hay treo) — gọi thẳng Jira REST API v3.
 *
 * Setup 1 lần:
 *   1. Tạo API token: https://id.atlassian.com/manage-profile/security/api-tokens
 *   2. Copy .env.example -> .env ở gốc repo (brandhub-infrastructure/.env), điền JIRA_EMAIL + JIRA_API_TOKEN
 *
 * Chạy (từ gốc repo hoặc từ scripts/):
 *   node scripts/export-jira.js
 *
 * Kết quả: ghi docs/plan/jira_status.json
 */

const fs = require('fs');
const path = require('path');

// ── Config ──────────────────────────────────────────────────────────
const JIRA_SITE = process.env.JIRA_SITE || 'letritrung2605.atlassian.net';
const PROJECT_KEY = 'DA';
const OUT_PATH = path.join(__dirname, '..', 'docs', 'plan', 'jira_status.json');

// Map tên hiển thị Jira (đủ dạng lệch: "27.Nguyễn Chơn Phước", "Nguyen Thanh Loc (K18 DN)"...)
// về đúng tên ngắn dùng trong Master Plan, để merge theo assignee không bị lệch.
const NAME_MAP = [
  [/trung/i, 'Trung'],
  [/l[oộ]c/i, 'Lộc'],
  [/tu[aấ]n/i, 'Tuấn'],
  [/^[aâ]n\s|^[aâ]n$|ân\s?h[aà]/i, 'Ân'],
  [/ph[uướ]+c/i, 'Phước'],
];

function normalizeAssigneeName(displayName) {
  if (!displayName) return null;
  for (const [re, name] of NAME_MAP) {
    if (re.test(displayName)) return name;
  }
  return displayName; // không khớp ai trong team -> giữ nguyên để dễ debug
}

// Load .env nếu có (không phụ thuộc thư viện ngoài) — .env nằm ở gốc repo
function loadEnv() {
  const envPath = path.join(__dirname, '..', '.env');
  if (!fs.existsSync(envPath)) return;
  const lines = fs.readFileSync(envPath, 'utf8').split('\n');
  for (const line of lines) {
    const m = line.match(/^([A-Z_]+)=(.*)$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2].trim();
  }
}

async function main() {
  loadEnv();
  const email = process.env.JIRA_EMAIL;
  const token = process.env.JIRA_API_TOKEN;

  if (!email || !token) {
    console.error('❌ Thiếu JIRA_EMAIL / JIRA_API_TOKEN.');
    console.error('   Tạo file .env ở gốc repo (xem .env.example) hoặc set env var trước khi chạy.');
    process.exit(1);
  }

  const auth = Buffer.from(`${email}:${token}`).toString('base64');
  const tasks = [];
  let nextPageToken = null;
  let page = 1;

  console.log(`Đang export project ${PROJECT_KEY} từ ${JIRA_SITE}...`);

  do {
    const body = {
      jql: `project = ${PROJECT_KEY} AND issuetype = Task ORDER BY key ASC`,
      fields: ['summary', 'status', 'assignee'],
      maxResults: 100,
      ...(nextPageToken ? { nextPageToken } : {}),
    };

    const res = await fetch(`https://${JIRA_SITE}/rest/api/3/search/jql`, {
      method: 'POST',
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
      console.error(`❌ Jira API lỗi ${res.status}: ${await res.text()}`);
      process.exit(1);
    }

    const data = await res.json();
    for (const issue of data.issues || []) {
      const idMatch = issue.fields.summary.match(/\[(DA-[A-Za-z0-9-]+)\]/i);
      if (!idMatch) continue; // bỏ task không có bracket prefix (task rác, task cũ không format)
      tasks.push({
        taskId: idMatch[1].toUpperCase(),
        jiraKey: issue.key,
        status: issue.fields.status?.name || 'Unknown',
        assignee: normalizeAssigneeName(issue.fields.assignee?.displayName),
      });
    }

    console.log(`  page ${page++}: +${data.issues?.length || 0} task (tổng ${tasks.length})`);
    nextPageToken = data.nextPageToken || null;
  } while (nextPageToken);

  const output = {
    exportedAt: new Date().toISOString().slice(0, 19).replace('T', ' '),
    project: PROJECT_KEY,
    total: tasks.length,
    tasks,
  };

  fs.mkdirSync(path.dirname(OUT_PATH), { recursive: true });
  fs.writeFileSync(OUT_PATH, JSON.stringify(output, null, 2), 'utf8');
  console.log(`✅ Ghi ${tasks.length} task vào ${OUT_PATH}`);
}

main().catch(err => {
  console.error('❌', err.message);
  process.exit(1);
});

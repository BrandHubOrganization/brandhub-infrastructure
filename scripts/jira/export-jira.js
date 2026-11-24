#!/usr/bin/env node
/**
 * Export status/assignee thật từ Jira ra docs/plan/jira-status.json cho docs-site dashboard đọc.
 * Gọi thẳng Jira REST API v3.
 *
 * Setup 1 lần:
 *   1. Tạo API token: https://id.atlassian.com/manage-profile/security/api-tokens
 *   2. Copy .env.example -> .env ở gốc repo (brandhub-infrastructure/.env),
 *      điền JIRA_SITE, JIRA_EMAIL, JIRA_API_TOKEN
 *
 * Chạy (từ bất kỳ thư mục nào):
 *   node scripts/jira/export-jira.js
 *
 * Kết quả: ghi docs/plan/jira-status.json
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..', '..');
const PROJECT_KEY = 'DA';
const OUT_PATH = path.join(REPO_ROOT, 'docs', 'plan', 'jira-status.json');

// Map tên hiển thị Jira về đúng tên ngắn dùng trong Master Plan để merge theo assignee chính xác.
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
  return displayName;
}

// Load .env ở gốc repo (không phụ thuộc thư viện ngoài)
function loadEnv() {
  const envPath = path.join(REPO_ROOT, '.env');
  if (!fs.existsSync(envPath)) return;
  const lines = fs.readFileSync(envPath, 'utf8').split(/\r?\n/);
  for (const line of lines) {
    const m = line.match(/^([A-Z_]+)=(.*)$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2].trim();
  }
}

function resolveJiraBaseUrl(rawSite) {
  const cleaned = (rawSite || 'https://letritrung2605.atlassian.net').trim().replace(/\/+$/, '');
  return /^https?:\/\//i.test(cleaned) ? cleaned : `https://${cleaned}`;
}

async function main() {
  loadEnv();
  const baseUrl = resolveJiraBaseUrl(process.env.JIRA_SITE);
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

  console.log(`Đang export project ${PROJECT_KEY} từ ${baseUrl}...`);

  do {
    const body = {
      jql: `project = ${PROJECT_KEY} AND issuetype = Task ORDER BY key ASC`,
      fields: ['summary', 'status', 'assignee'],
      maxResults: 100,
      ...(nextPageToken ? { nextPageToken } : {}),
    };

    const res = await fetch(`${baseUrl}/rest/api/3/search/jql`, {
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
      if (!idMatch) continue;
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

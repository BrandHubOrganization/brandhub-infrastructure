// BrandHub Workload Dashboard
// Đọc BrandHub_Master_Plan.md (nguồn kế hoạch, luôn có) + jira_status.json (nguồn status thật, optional)
// Không hardcode task nào — toàn bộ parse runtime từ 2 file trên.

// Absolute path từ site root — hoạt động cả khi chạy trực tiếp (docs/dashboard/index.html
// qua Live Server) lẫn khi nhúng qua VitePress /raw/dashboard/index.html (base: '/').
const MD_PATH = '/plan/BrandHub_Master_Plan.md';
const JSON_PATH = '/plan/jira_status.json';

const STATUS_COLORS = {
  Done: '#3fb950',
  'In Review': '#d29922',
  'In Progress': '#58a6ff',
  'To Do': '#4b5163',
  Planned: '#4b5163', // fallback khi không có Jira snapshot
};

const PRIORITY_ORDER = { '🔴 Critical': 0, '🟡 High': 1, '🟢 Medium': 2, '🟢 Low': 3 };

let ALL_TASKS = [];
let JIRA_MAP = {}; // taskId -> {status, assignee}
let JIRA_META = null;

async function init() {
  const statusBar = document.getElementById('statusBar');
  try {
    const mdText = await fetch(MD_PATH).then(r => {
      if (!r.ok) throw new Error(`Không tải được ${MD_PATH} (HTTP ${r.status})`);
      return r.text();
    });
    ALL_TASKS = parseMasterPlan(mdText);

    try {
      const jiraData = await fetch(JSON_PATH).then(r => r.ok ? r.json() : null);
      if (jiraData) {
        JIRA_META = jiraData.exportedAt || null;
        (jiraData.tasks || []).forEach(t => { JIRA_MAP[t.taskId] = t; });
      }
    } catch (e) { /* jira_status.json optional — im lặng nếu thiếu */ }

    applyJiraStatus();
    renderStatusBar(statusBar);
    renderMemberChart();
    renderEpicChart();
    setupFilters();
  } catch (err) {
    statusBar.innerHTML = `⚠️ Lỗi tải dữ liệu: ${err.message}. Kiểm tra đang chạy qua Live Server (không mở file:// trực tiếp) và đường dẫn ${MD_PATH} đúng.`;
  }
}

/** Parse bảng markdown "| [DA-XXX](#anchor) 🆕🔀 | Description | Assignee | Priority |" */
function parseMasterPlan(md) {
  const lines = md.split('\n');
  const tasks = [];
  let currentEpic = null;
  let currentSprint = null;

  const epicRe = /^### EPIC ([A-Za-z0-9-]+) — (.+)$/u;
  const sprintRe = /^## Sprint (\d+) — (.+)$/u;
  const rowRe = /^\|\s*\[(DA-[A-Za-z0-9-]+)\]\(#([^)]*)\)\s*([🆕🔀⚠️\s]*)\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*([🔴🟡🟢]\s*\w+)\s*\|\s*$/u;

  for (const line of lines) {
    // Chỉ parse Phần 1 (bảng tổng quan) — dừng khi vào Phần 2 chi tiết task để tránh double-count
    if (line.startsWith('# PHẦN 2')) break;

    const epicMatch = line.match(epicRe);
    if (epicMatch) { currentEpic = { id: epicMatch[1], title: epicMatch[2].replace(/🔀.*$/, '').trim() }; continue; }

    const sprintMatch = line.match(sprintRe);
    if (sprintMatch) { currentSprint = sprintMatch[1]; continue; }

    const rowMatch = line.match(rowRe);
    if (rowMatch && currentEpic) {
      const [, taskId, anchor, markers, description, assignee, priority] = rowMatch;
      tasks.push({
        taskId,
        anchor,
        epic: currentEpic.id,
        epicTitle: currentEpic.title,
        sprint: currentSprint,
        description: description.replace(/\*.*?\*/g, '').trim(),
        assignee: normalizeAssignee(assignee),
        priority: priority.trim(),
        isNew: markers.includes('🆕'),
        isMoved: markers.includes('🔀'),
        status: 'Planned',
      });
    }
  }
  return tasks;
}

function normalizeAssignee(raw) {
  const name = raw.split('(')[0].trim();
  return name || raw.trim();
}

function applyJiraStatus() {
  ALL_TASKS.forEach(t => {
    const jira = JIRA_MAP[t.taskId];
    if (jira) {
      t.status = jira.status || 'Planned';
      if (jira.assignee) t.assignee = jira.assignee; // Jira assignee thật ưu tiên hơn plan
    }
  });
}

function renderStatusBar(el) {
  const total = ALL_TASKS.length;
  const withJira = ALL_TASKS.filter(t => t.status !== 'Planned').length;
  if (JIRA_META) {
    el.innerHTML = `<b>${total}</b> task từ Master Plan &nbsp;·&nbsp; <span class="badge badge-ok">${withJira} có status Jira thật</span> &nbsp;·&nbsp; Jira snapshot: <b>${JIRA_META}</b>`;
  } else {
    el.innerHTML = `<b>${total}</b> task từ Master Plan &nbsp;·&nbsp; <span class="badge badge-warn">Chưa có jira_status.json</span> — đang hiển thị khối lượng theo kế hoạch (chưa phải tiến độ thật). Chạy <code>node export-jira.js</code> để cập nhật.`;
  }
}

function groupBy(arr, key) {
  return arr.reduce((acc, item) => {
    const k = item[key] || 'Unassigned';
    (acc[k] = acc[k] || []).push(item);
    return acc;
  }, {});
}

function statusBreakdown(tasks) {
  const order = ['Done', 'In Review', 'In Progress', 'To Do', 'Planned'];
  const counts = {};
  order.forEach(s => counts[s] = 0);
  tasks.forEach(t => { counts[t.status] = (counts[t.status] || 0) + 1; });
  return order.filter(s => counts[s] > 0).map(s => ({ status: s, count: counts[s] }));
}

function renderMemberChart() {
  const byMember = groupBy(ALL_TASKS, 'assignee');
  const entries = Object.entries(byMember).sort((a, b) => b[1].length - a[1].length);
  const max = Math.max(...entries.map(([, v]) => v.length));
  document.getElementById('totalCount').textContent = `(${entries.length} người)`;

  const container = document.getElementById('memberChart');
  container.innerHTML = entries.map(([name, tasks]) => {
    const segs = statusBreakdown(tasks);
    const widthPct = (tasks.length / max) * 100;
    const segHtml = segs.map(s =>
      `<div class="bar-seg" style="width:${(s.count / tasks.length) * 100}%; background:${STATUS_COLORS[s.status]}" title="${s.status}: ${s.count}"></div>`
    ).join('');
    return `<div class="bar-row" onclick="openDetail('assignee','${escapeAttr(name)}')">
      <div class="bar-name">${escapeHtml(name)}</div>
      <div class="bar-track" style="width:${widthPct}%"><div style="display:flex;width:100%">${segHtml}</div></div>
      <div class="bar-total">${tasks.length}</div>
    </div>`;
  }).join('');

  const legend = document.getElementById('legend');
  legend.innerHTML = Object.entries(STATUS_COLORS).filter(([k]) => k !== 'Planned' || !JIRA_META)
    .map(([k, c]) => `<span><span class="dot" style="background:${c}"></span>${k}</span>`).join('');
}

function renderEpicChart() {
  const byEpic = groupBy(ALL_TASKS, 'epic');
  const entries = Object.entries(byEpic).sort((a, b) => b[1].length - a[1].length).slice(0, 12);
  const max = Math.max(...entries.map(([, v]) => v.length));
  document.getElementById('epicCount').textContent = `(${Object.keys(byEpic).length} epic tổng)`;

  const container = document.getElementById('epicChart');
  container.innerHTML = entries.map(([epic, tasks]) => {
    const widthPct = (tasks.length / max) * 100;
    return `<div class="bar-row" onclick="openDetail('epic','${escapeAttr(epic)}')">
      <div class="bar-name" title="${escapeAttr(tasks[0].epicTitle)}">${epic}</div>
      <div class="bar-track" style="width:${widthPct}%"><div class="bar-seg" style="width:100%; background:var(--accent)"></div></div>
      <div class="bar-total">${tasks.length}</div>
    </div>`;
  }).join('');
}

let currentDetailTasks = [];

function openDetail(field, value) {
  currentDetailTasks = ALL_TASKS.filter(t => t[field] === value);
  const label = field === 'assignee' ? value : `${value} — ${currentDetailTasks[0]?.epicTitle || ''}`;
  document.getElementById('detailTitle').textContent = `📋 ${label} (${currentDetailTasks.length} task)`;
  document.getElementById('detail').classList.add('open');
  populateFilterOptions();
  renderDetailTable();
  document.getElementById('detail').scrollIntoView({ behavior: 'smooth' });
}

function closeDetail() {
  document.getElementById('detail').classList.remove('open');
}

function populateFilterOptions() {
  const statuses = [...new Set(currentDetailTasks.map(t => t.status))];
  const priorities = [...new Set(currentDetailTasks.map(t => t.priority))].sort((a, b) => (PRIORITY_ORDER[a] ?? 9) - (PRIORITY_ORDER[b] ?? 9));
  const statusSel = document.getElementById('filterStatus');
  const prioSel = document.getElementById('filterPriority');
  statusSel.innerHTML = '<option value="">Tất cả status</option>' + statuses.map(s => `<option value="${s}">${s}</option>`).join('');
  prioSel.innerHTML = '<option value="">Tất cả priority</option>' + priorities.map(p => `<option value="${p}">${p}</option>`).join('');
}

function setupFilters() {
  ['filterStatus', 'filterPriority', 'filterSearch'].forEach(id => {
    document.getElementById(id).addEventListener('input', renderDetailTable);
  });
}

function renderDetailTable() {
  const statusF = document.getElementById('filterStatus').value;
  const prioF = document.getElementById('filterPriority').value;
  const searchF = document.getElementById('filterSearch').value.toLowerCase();

  const filtered = currentDetailTasks.filter(t =>
    (!statusF || t.status === statusF) &&
    (!prioF || t.priority === prioF) &&
    (!searchF || t.taskId.toLowerCase().includes(searchF) || t.description.toLowerCase().includes(searchF))
  ).sort((a, b) => (PRIORITY_ORDER[a.priority] ?? 9) - (PRIORITY_ORDER[b.priority] ?? 9));

  const tbody = document.querySelector('#detailTable tbody');
  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="empty-state">Không có task khớp bộ lọc</td></tr>`;
    return;
  }
  tbody.innerHTML = filtered.map(t => `
    <tr>
      <td><a class="task-link" href="${MD_PATH}#${t.anchor}" target="_blank">${t.taskId}</a>${t.isNew ? ' 🆕' : ''}${t.isMoved ? ' 🔀' : ''}</td>
      <td>${t.epic}</td>
      <td>${escapeHtml(t.description)}</td>
      <td><span class="pill ${priorityClass(t.priority)}">${t.priority}</span></td>
      <td><span class="pill ${statusClass(t.status)}">${t.status}</span></td>
    </tr>
  `).join('');
}

function priorityClass(p) { return p.includes('Critical') ? 'pill-crit' : p.includes('High') ? 'pill-high' : 'pill-med'; }
function statusClass(s) { return { Done: 'pill-done', 'In Review': 'pill-review', 'In Progress': 'pill-progress' }[s] || 'pill-todo'; }
function escapeHtml(s) { return s.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }
function escapeAttr(s) { return s.replace(/'/g, "\\'"); }

init();

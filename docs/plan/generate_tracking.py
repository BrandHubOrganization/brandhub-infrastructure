#!/usr/bin/env python3
"""Generate final Document_Upload_Tracking.md + update .doc_epic_results.json."""
import json, time, os, io, sys
from collections import Counter
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

BASE_URL = 'https://letritrung2605.atlassian.net/browse'
OUT_DIR = os.path.join(os.path.dirname(__file__), 'json')

epic_keys = {f'D{i:02d}': f'DA-{614+i}' for i in range(1, 24)}
epic_titles = {
    'D01': 'EPIC D01 — Context & Architecture Diagrams',
    'D02': 'EPIC D02 — Use Case, ERD & Config Diagrams',
    'D03': 'EPIC D03 — Screen Flows, Authorization Matrix & Mockups',
    'D04': 'EPIC D04 — Diagram Review',
    'D05': 'EPIC D05 — R1 §2-3: Product Background & Existing Systems',
    'D06': 'EPIC D06 — R1 §4-5: Business Opportunity & Vision',
    'D07': 'EPIC D07 — R1 §6-7: Scope, Limitations & References',
    'D08': 'EPIC D08 — R2 §1: Overview (WBS, Objectives, Risks)',
    'D09': 'EPIC D09 — R2 §2: Management Approach & Quality',
    'D10': 'EPIC D10 — R2 §3, §5, §6: Deliverables, Communications, Config',
    'D11': 'EPIC D11 — R2 §2.3, §4, §6.3: Training, Responsibility, Tools',
    'D12': 'EPIC D12 — R3 §1: Product Overview & System Context',
    'D13': 'EPIC D13 — R3 §2: User Requirements (Actors & Use Cases)',
    'D14': 'EPIC D14 — R3 §3.1: System Functional Overview',
    'D15': 'EPIC D15 — R3 §3.2-3.5: FR — Auth & Core Business',
    'D16': 'EPIC D16 — R3 §3.6-3.10: FR — Content & Workflow',
    'D17': 'EPIC D17 — R3 §3.11-3.16: FR — AI Features',
    'D18': 'EPIC D18 — R3 §3.17-3.23: FR — Publishing & Social',
    'D19': 'EPIC D19 — R3 §3.24-3.27: FR — Sub, Analytics, Admin, Mobile',
    'D20': 'EPIC D20 — R3 §4-5: NFR & Appendices',
    'D21': 'EPIC D21 — Review & Feedback',
    'D22': 'EPIC D22 — Merge & Format',
    'D23': 'EPIC D23 — Final Package & Submission',
}

tasks = [
    ('D01','DA-D01-01','Tuan','Critical'),('D01','DA-D01-02','Phuoc','Critical'),('D01','DA-D01-03','Phuoc','Critical'),('D01','DA-D01-04','Phuoc','Critical'),
    ('D02','DA-D02-01','Tuan','Critical'),('D02','DA-D02-02','Tuan','Critical'),('D02','DA-D02-03','Loc','Medium'),('D02','DA-D02-04','Loc','Medium'),
    ('D03','DA-D03-01','Loc','Critical'),('D03','DA-D03-02','Loc','Critical'),('D03','DA-D03-03','Phuoc','Critical'),('D03','DA-D03-04','Phuoc','Critical'),('D03','DA-D03-05','Tuan','Critical'),('D03','DA-D03-06','Tuan','Critical'),('D03','DA-D03-07','Loc','High'),('D03','DA-D03-08','Loc','High'),
    ('D04','DA-D04-01','Trung','Critical'),
    ('D05','DA-D05-01','Loc','High'),('D05','DA-D05-02','Loc','High'),
    ('D06','DA-D06-01','Tuan','High'),('D06','DA-D06-02','Tuan','High'),
    ('D07','DA-D07-01','An','High'),('D07','DA-D07-02','An','High'),('D07','DA-D07-03','An','Medium'),
    ('D08','DA-D08-01','Trung','Critical'),('D08','DA-D08-02','Trung','High'),('D08','DA-D08-03','Trung','High'),
    ('D09','DA-D09-01','Phuoc','Critical'),('D09','DA-D09-02','Phuoc','High'),
    ('D10','DA-D10-01','Phuoc','High'),('D10','DA-D10-02','Phuoc','Medium'),('D10','DA-D10-03','Phuoc','Medium'),
    ('D11','DA-D11-01','Tuan','Medium'),('D11','DA-D11-02','An','High'),('D11','DA-D11-03','An','Medium'),
    ('D12','DA-D12-01','Trung','Critical'),('D12','DA-D12-02','Trung','High'),('D12','DA-D12-03','Trung','High'),
    ('D13','DA-D13-01','Tuan','Critical'),('D13','DA-D13-02','Loc','Critical'),('D13','DA-D13-03','Tuan','Critical'),
    ('D14','DA-D14-01','Loc','High'),('D14','DA-D14-02','Phuoc','High'),('D14','DA-D14-03','Tuan','High'),('D14','DA-D14-04','Tuan','High'),
    ('D15','DA-D15-01','Trung','Critical'),('D15','DA-D15-02','Trung','High'),('D15','DA-D15-03','Trung','High'),('D15','DA-D15-04','Trung','High'),
    ('D16','DA-D16-01','Loc','High'),('D16','DA-D16-02','Loc','High'),('D16','DA-D16-03','Loc','High'),('D16','DA-D16-04','Loc','High'),('D16','DA-D16-05','Loc','High'),
    ('D17','DA-D17-01','Tuan','High'),('D17','DA-D17-02','Tuan','High'),('D17','DA-D17-03','Tuan','High'),('D17','DA-D17-04','Tuan','High'),('D17','DA-D17-05','Tuan','High'),('D17','DA-D17-06','Tuan','High'),
    ('D18','DA-D18-01','Phuoc','High'),('D18','DA-D18-02','Phuoc','Critical'),('D18','DA-D18-03','Phuoc','High'),('D18','DA-D18-04','Phuoc','High'),('D18','DA-D18-05','Phuoc','High'),('D18','DA-D18-06','Phuoc','High'),('D18','DA-D18-07','Phuoc','High'),
    ('D19','DA-D19-01','An','High'),('D19','DA-D19-02','An','High'),('D19','DA-D19-03','An','High'),('D19','DA-D19-04','An','High'),
    ('D20','DA-D20-01','Trung','Critical'),('D20','DA-D20-02','An','High'),('D20','DA-D20-03','An','High'),
    ('D21','DA-D21-01','Trung','Critical'),('D21','DA-D21-02','Loc','Critical'),('D21','DA-D21-03','Tuan','Critical'),('D21','DA-D21-04','An','Critical'),('D21','DA-D21-05','Trung','Critical'),('D21','DA-D21-06','Phuoc','Critical'),('D21','DA-D21-07','Tuan','Critical'),('D21','DA-D21-08','An','Critical'),('D21','DA-D21-09','Trung','Critical'),('D21','DA-D21-10','Loc','Critical'),('D21','DA-D21-11','Phuoc','Critical'),('D21','DA-D21-12','Tuan','Critical'),('D21','DA-D21-13','An','Critical'),('D21','DA-D21-14','Trung','Critical'),('D21','DA-D21-15','Loc','Critical'),('D21','DA-D21-16','Phuoc','Critical'),('D21','DA-D21-17','Tuan','Critical'),('D21','DA-D21-18','An','Critical'),
    ('D22','DA-D22-01','Trung','Critical'),('D22','DA-D22-02','Trung','Critical'),('D22','DA-D22-03','Trung','Critical'),('D22','DA-D22-04','Trung','Critical'),
    ('D23','DA-D23-01','Trung','Critical'),('D23','DA-D23-02','Trung','High'),
]

task_jira_map = {}
for i, (_, tid, _, _) in enumerate(tasks):
    task_jira_map[tid] = f'DA-{638+i}'

name_map = {'Trung':'Trung','Phuoc':'Phuoc','An':'An','Loc':'Loc','Tuan':'Tuan'}

lines = [
    '# BrandHub — Document Tasks Jira Upload Tracking',
    f'> Generated: {time.strftime("%Y-%m-%d %H:%M")}',
    f'> **23 Epics | {len(tasks)} Tasks**',
    f'> Source: Document_Plan.md | Script: create_document_epics.py',
    '',
    '---',
    '',
    '## Summary',
    '',
]

ac = Counter(name_map.get(t[2], t[2]) for t in tasks)
for name in ['Trung','Loc','Phuoc','Tuan','An']:
    lines.append(f'- **{name}**: {ac.get(name,0)} tasks')

lines += ['', '---', '', '## Epics (23)', '']
for i in range(1, 24):
    eid = f'D{i:02d}'
    ek = epic_keys[eid]
    et = epic_titles.get(eid, f'EPIC {eid}')
    etasks = [t for t in tasks if t[0] == eid]
    lines.append(f'- [ ] **EPIC {eid}** — [{ek}]({BASE_URL}/{ek}) — {et} ({len(etasks)} tasks)')

lines += ['', '---', '', '## Tasks by Epic (98)', '']
cur = None
for i, (eid, tid, assignee, priority) in enumerate(tasks):
    if eid != cur:
        cur = eid
        ek = epic_keys[eid]
        lines.append(f'### EPIC {eid} — [{ek}]({BASE_URL}/{ek}) — {epic_titles.get(eid, "?")}')
        lines.append('')
    jk = task_jira_map[tid]
    disp_name = name_map.get(assignee, assignee)
    lines.append(f'- [ ] `{tid}` — [{jk}]({BASE_URL}/{jk}) — {disp_name} | {priority}')

lines += ['', '---', '', f'*23 Epics (DA-615..DA-637) + {len(tasks)} Tasks (DA-638..DA-{637+len(tasks)})*', '']

os.makedirs(OUT_DIR, exist_ok=True)

out = os.path.join(OUT_DIR, 'Document_Upload_Tracking.md')
with open(out, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print(f'Tracking: {out}')

json_data = {
    'epics': {eid: {'key': ek, 'title': epic_titles.get(eid, '')} for eid, ek in epic_keys.items()},
    'tasks': [{'task_id': tid, 'jira_key': task_jira_map[tid], 'epic': eid, 'assignee': a, 'priority': p}
              for eid, tid, a, p in tasks],
    'errors': []
}
json_out = os.path.join(OUT_DIR, '.doc_epic_results.json')
with open(json_out, 'w', encoding='utf-8') as f:
    json.dump(json_data, f, ensure_ascii=False, indent=2)
print(f'JSON: {json_out}')
print('Done.')

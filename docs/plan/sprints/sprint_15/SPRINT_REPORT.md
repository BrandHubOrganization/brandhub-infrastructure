# Sprint 15 Report — Testing & Bug Fixes

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 15 |
| Timeline | Weeks 29–30 (Dec 2–15, 2026) |
| Phase | Phase 7 — Testing, Deployment & Final Report |
| Goal | Unit + integration + E2E tests, security audit, fix all critical bugs |
| Report date | *(Điền ngày nộp)* |
| Reported by | Lê Trí Trung (Leader) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| E42 — Unit & Integration Testing | 5 | | | | | |
| E43 — Bug Fixes & Polish | 3 | | | | | |
| **Tổng** | **8** | | | | | |

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Trung (Leader) | — | — | — | |
| Tuấn (AI) | — | — | — | |
| Ân (AI) | — | — | — | |
| Phước (Publisher) | — | — | — | |
| Lộc (Frontend) | — | — | — | |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Chất lượng |
|---|---|---|---|
| Unit tests business-service | `src/test/` | Trung | |
| Unit tests ai-service | `tests/` | Tuấn | |
| Integration tests | `src/test/integration/` | Phước | |
| JMeter/k6 load test report | | All | |
| E2E publish test on sandbox | | Phước | |
| Security audit checklist | | Trung | |

---

## 4. Test results summary

| Test suite | Pass | Fail | Coverage |
|---|---|---|---|
| AuthService unit tests | | | |
| WorkspaceService unit tests | | | |
| PostService unit tests | | | |
| ai-service unit tests | | | |
| Integration tests | | | |
| Load test (200 concurrent users) | p95 = | Errors = | |

---

## 5. Security audit results

| Check | Result | Notes |
|---|---|---|
| SQL injection | | |
| NoSQL injection | | |
| XSS | | |
| CSRF | | |
| JWT security | | |
| AES key exposure | | |
| S3 bucket | | |
| RabbitMQ | | |
| Admin endpoints | | |
| Internal endpoints | | |

---

## 6. Bug list from testing

| Bug | Severity | Assignee | Status |
|---|---|---|---|
| *(Điền)* | | | |

---

## 7. Sprint Retrospective

*(Điền)*

---

## 8. Kế hoạch Sprint 16

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E44-01/02 Production deployment | Trung | |
| 🔴 Critical | DA-E45-04 Demo video | All | |
| 🔴 Critical | DA-E46-01 Capstone report | All | |

---

## 9. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 15 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |

---

*Deadline nộp: 2026-12-15*

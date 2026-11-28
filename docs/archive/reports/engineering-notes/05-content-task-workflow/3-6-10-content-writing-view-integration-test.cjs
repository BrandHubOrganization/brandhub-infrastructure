// Real-backend integration test for FR 3.6.10 (REST + STOMP + Yjs). Run: WS_ID=<workspace uuid> node it.cjs
const { createRequire } = require("module");
const req = createRequire("D:/ProjectCode/BrandHub/brandhub-web-dashboard/package.json");
const Y = req("yjs");
const { Client } = req("@stomp/stompjs");
const BASE = "http://localhost:8081";
const WS = "ws://localhost:8081/ws/tasks";
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
function check(id, name, cond, detail = "") {
  results.push({ id, name, ok: !!cond, detail });
  console.log(`${cond ? "PASS" : "FAIL"} ${id} ${name}${cond ? "" : "  -> " + detail}`);
}
async function api(method, path, token, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: { "Content-Type": "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  let json = null;
  try { json = await res.json(); } catch { /* empty */ }
  return { status: res.status, json };
}
async function login(n) {
  const r = await api("POST", "/api/v1/auth/login", null, { identifier: `e2e_${n}@test.local`, password: "Passw0rdx1" });
  return { token: r.json.data.accessToken, id: JSON.parse(Buffer.from(r.json.data.accessToken.split(".")[1], "base64url")).sub };
}
const b64 = (u8) => Buffer.from(u8).toString("base64");
const unb64 = (s) => new Uint8Array(Buffer.from(s, "base64"));

// A STOMP client wrapping a Y.Doc, mirrors useTaskContentSync.
function makeClient(token, taskId, label) {
  const doc = new Y.Doc();
  const received = [];
  const c = { doc, received, label, connected: false, error: null };
  c.stomp = new Client({
    brokerURL: `${WS}?token=${token}`,
    reconnectDelay: 0,
    onConnect: () => {
      c.connected = true;
      c.stomp.subscribe(`/topic/tasks/${taskId}/content`, (m) => {
        const b = JSON.parse(m.body);
        received.push(b);
        Y.applyUpdate(doc, unb64(b.update), "remote");
      });
    },
    onStompError: (f) => (c.error = f.headers.message),
    onWebSocketError: () => (c.error = "ws-error"),
    onWebSocketClose: () => (c.connected = false),
  });
  doc.on("update", (u, origin) => {
    if (origin === "remote" || !c.connected) return;
    c.stomp.publish({ destination: `/app/tasks/${taskId}/content`, body: JSON.stringify({ update: b64(u) }) });
  });
  c.activate = async () => {
    c.stomp.activate();
    for (let i = 0; i < 50 && !c.connected && !c.error; i++) await sleep(100);
    await sleep(200);
    return c.connected;
  };
  c.text = () => doc.getText("content").toString();
  return c;
}
async function loadFromRest(wsId, taskId, token) {
  const r = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content`, token);
  const d = new Y.Doc();
  if (r.json?.data?.snapshot) Y.applyUpdate(d, unb64(r.json.data.snapshot));
  for (const u of r.json?.data?.operationsSinceSnapshot ?? []) Y.applyUpdate(d, unb64(u));
  return { doc: d, text: d.getText("content").toString(), data: r.json?.data, status: r.status };
}
async function opCount(wsId, taskId, token) {
  const r = await loadFromRest(wsId, taskId, token);
  return r.data.sequenceNumber;
}

(async () => {
  const A = await login("a"), B = await login("b"), C = await login("c");
  const wsId = process.env.WS_ID;
  const mk = await api("POST", `/api/v1/workspaces/${wsId}/tasks`, A.token, { title: "IT task " + Date.now() });
  check("IT-01", "manager creates task", mk.status < 300 && mk.json?.data?.id, JSON.stringify(mk.json).slice(0, 200));
  const taskId = mk.json.data.id;

  // ---- REST: empty load, RBAC
  const empty = await loadFromRest(wsId, taskId, A.token);
  check("IT-02", "empty task: snapshot null, no ops, seq 0", empty.status === 200 && empty.data.snapshot == null && empty.data.operationsSinceSnapshot.length === 0 && empty.data.sequenceNumber === 0, JSON.stringify(empty.data));
  const asB = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content`, B.token);
  check("IT-03", "creator member can load content", asB.status === 200, asB.status);
  const asC = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content`, C.token);
  check("IT-04", "non-member gets 403/404 on content", [403, 404].includes(asC.status), asC.status);
  const noTok = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content`, null);
  check("IT-05", "no token gets 401", noTok.status === 401, noTok.status);
  const missing = await api("GET", `/api/v1/workspaces/${wsId}/tasks/00000000-0000-0000-0000-000000000000/content`, A.token);
  check("IT-06", "unknown task gets 404", missing.status === 404, missing.status);

  // ---- WS handshake
  const bad = makeClient("not.a.jwt", taskId, "bad");
  check("IT-07", "WS with invalid JWT rejected", !(await bad.activate()), "connected");
  bad.stomp.deactivate();
  const none = makeClient("", taskId, "none");
  check("IT-08", "WS with empty token rejected", !(await none.activate()));
  none.stomp.deactivate();

  // ---- two live clients
  const ca = makeClient(A.token, taskId, "A"), cb = makeClient(B.token, taskId, "B");
  check("IT-09", "two creators connect over STOMP", (await ca.activate()) && (await cb.activate()));
  ca.doc.getText("content").insert(0, "Hello");
  await sleep(600);
  check("IT-10", "A's edit reaches B", cb.text() === "Hello", cb.text());
  check("IT-11", "broadcast carries editedBy=A and sequenceNumber=1", cb.received[0]?.editedBy === A.id && cb.received[0]?.sequenceNumber === 1, JSON.stringify(cb.received[0]));

  ca.doc.getText("content").insert(5, " from A");
  cb.doc.getText("content").insert(5, " from B");
  await sleep(1000);
  check("IT-12", "concurrent edits converge to identical text", ca.text() === cb.text() && ca.text().includes("from A") && ca.text().includes("from B"), `${ca.text()} | ${cb.text()}`);

  const before = await opCount(wsId, taskId, A.token);
  for (let i = 0; i < 60; i++) {
    ca.doc.getText("content").insert(0, "a");
    cb.doc.getText("content").insert(cb.doc.getText("content").length, "b");
  }
  await sleep(3000);
  const after = await opCount(wsId, taskId, A.token);
  check("IT-13", "burst of 120 concurrent updates all persisted (seq +120)", after - before === 120, `before=${before} after=${after}`);
  const uniq = new Set(ca.received.map((x) => x.sequenceNumber));
  const maxSeq = Math.max(...ca.received.map((x) => x.sequenceNumber));
  check("IT-14", "sequence numbers unique across broadcasts and reach latest", uniq.size === ca.received.length && maxSeq === after, `uniq=${uniq.size} recv=${ca.received.length} max=${maxSeq} after=${after}`);
  check("IT-15", "both clients converge after burst", ca.text() === cb.text(), `${ca.text().length} vs ${cb.text().length}`);
  const fresh = await loadFromRest(wsId, taskId, A.token);
  check("IT-16", "fresh REST load rebuilds exactly the live text (persistence)", fresh.text === ca.text(), `${fresh.text.length} vs ${ca.text().length}`);

  // ---- snapshots / versions
  const seqNow = fresh.data.sequenceNumber;
  const snap = { yjsState: b64(Y.encodeStateAsUpdate(ca.doc)), atSequenceNumber: seqNow };
  const snapV1 = await api("POST", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/snapshot`, A.token, snap);
  check("IT-17", "snapshot report accepted", snapV1.status < 300, snapV1.status + JSON.stringify(snapV1.json).slice(0, 150));
  await api("POST", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/snapshot`, A.token, snap);
  const vList1 = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions`, A.token);
  check("IT-18", "duplicate snapshot ignored (still 1 version)", vList1.json.data.length === 1, vList1.json.data.length);
  const v1 = vList1.json.data[0];
  const textV1 = ca.text();
  check("IT-19", "version has editedBy + editedByName (who)", !!v1.editedBy && /E2E User/.test(v1.editedByName ?? ""), JSON.stringify(v1));

  ca.doc.getText("content").insert(0, "NEW-TITLE ");
  await sleep(500);
  const seq2 = await opCount(wsId, taskId, A.token);
  await api("POST", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/snapshot`, A.token, { yjsState: b64(Y.encodeStateAsUpdate(ca.doc)), atSequenceNumber: seq2 });
  const vList2 = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions`, A.token);
  check("IT-20", "versions newest first", vList2.json.data.length === 2 && vList2.json.data[0].sequenceNumber === seq2, JSON.stringify(vList2.json.data.map((v) => v.sequenceNumber)));
  check("IT-21", "newest version editedBy = A", vList2.json.data[0].editedBy === A.id, vList2.json.data[0].editedBy);

  const getV = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions/${v1.snapshotId}`, A.token);
  const dv = new Y.Doc(); Y.applyUpdate(dv, unb64(getV.json.data.snapshot));
  check("IT-22", "GET version returns that version's text", getV.status === 200 && dv.getText("content").toString() === textV1, getV.status);
  const getVC = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions/${v1.snapshotId}`, C.token);
  check("IT-23", "non-member cannot read a version", [403, 404].includes(getVC.status), getVC.status);
  const getVBad = await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions/00000000-0000-0000-0000-000000000000`, A.token);
  check("IT-24", "unknown version 404", getVBad.status === 404, getVBad.status);

  // ---- restore: read-only on server, client applies as normal edit
  const seqBeforeRestore = await opCount(wsId, taskId, A.token);
  const vcountBefore = (await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions`, A.token)).json.data.length;
  const rest = await api("POST", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions/${v1.snapshotId}/restore`, A.token);
  const seqAfterRestore = await opCount(wsId, taskId, A.token);
  const vcountAfter = (await api("GET", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/versions`, A.token)).json.data.length;
  check("IT-25", "restore endpoint writes nothing (no op, no snapshot)", rest.status === 200 && seqAfterRestore === seqBeforeRestore && vcountAfter === vcountBefore, `${seqBeforeRestore}->${seqAfterRestore} v ${vcountBefore}->${vcountAfter}`);
  const yt = ca.doc.getText("content");
  const old = new Y.Doc(); Y.applyUpdate(old, unb64(rest.json.data.snapshot));
  const oldText = old.getText("content").toString();
  ca.doc.transact(() => { yt.delete(0, yt.length); yt.insert(0, oldText); });
  await sleep(800);
  check("IT-26", "restore propagates live to B as normal edit", cb.text() === textV1, `${cb.text().length} vs ${textV1.length}`);
  const afterR = await loadFromRest(wsId, taskId, B.token);
  check("IT-27", "restored text survives reload; log append-only (seq grew)", afterR.text === textV1 && afterR.data.sequenceNumber > seqBeforeRestore, `${afterR.text.length} seq ${afterR.data.sequenceNumber}`);
  cb.doc.getText("content").insert(0, "after-restore ");
  await sleep(500);
  const afterR2 = await loadFromRest(wsId, taskId, A.token);
  check("IT-28", "edit after restore persists & reaches A", afterR2.text.startsWith("after-restore ") && ca.text().startsWith("after-restore "), afterR2.text.slice(0, 30));

  // ---- RBAC over WS: non-member publishes / subscribes
  const cc = makeClient(C.token, taskId, "C");
  const cConn = await cc.activate();
  const seqBeforeC = await opCount(wsId, taskId, A.token);
  if (cConn) cc.doc.getText("content").insert(0, "INTRUDER ");
  await sleep(800);
  const seqAfterC = await opCount(wsId, taskId, A.token);
  check("IT-29", "non-member WS publish is NOT persisted", seqAfterC === seqBeforeC, `connected=${cConn} ${seqBeforeC}->${seqAfterC}`);
  check("IT-30", "non-member does NOT receive task broadcasts", cc.received.length === 0 && !cb.text().includes("INTRUDER"), `received=${cc.received.length}`);
  cc.stomp.deactivate();

  const badSnap = await api("POST", `/api/v1/workspaces/${wsId}/tasks/${taskId}/content/snapshot`, A.token, { atSequenceNumber: 5 });
  check("IT-31", "snapshot without yjsState rejected (4xx)", badSnap.status >= 400 && badSnap.status < 500, badSnap.status);

  ca.stomp.deactivate(); cb.stomp.deactivate();
  await sleep(200);
  const failed = results.filter((r) => !r.ok);
  console.log(`\nTOTAL ${results.length}, PASS ${results.length - failed.length}, FAIL ${failed.length}`);
  require("fs").writeFileSync(process.env.OUT || "it-result.json", JSON.stringify(results, null, 2));
  process.exit(failed.length ? 1 : 0);
})().catch((e) => { console.error("FATAL", e); process.exit(2); });
